module tests.synchronization.monitor;
import statetracker;
import synchronization.barrier;
import synchronization.monitor;
import synchronization.mutex;
import task;
import timerqueue;
import xunit.core;

protected class MonitorTests
{
    private IStateTracker _stateTracker;
    private synchronization.monitor.Monitor _monitor;

    public this()
    {
        _stateTracker = new StateTracker(new TimerQueue());
        _monitor = new synchronization.monitor.Monitor();
    }

    public void Monitor_Signal_WakeOne()
    {
        int awaken = 0;
        int[] queue;

        void delegate() func = () {
            synchronized (_monitor)
            {
                while (queue.length == 0)
                {
                    _monitor.Wait();
                }

                awaken += 1;
            }
        };
        void delegate() notify = () {
            synchronized (_monitor)
            {
                queue ~= 1;
                _monitor.Signal();
            }
        };
        _stateTracker.Execute(() {
            Task.Run(func); //
            Task.Run(func);
            Task.Run(func);
            Task.Run(notify);
        });

        Assert.Equal(1, awaken);
    }

    public void Monitor_Signal_WakeAll()
    {
        int awaken = 0;
        int[] queue;

        void delegate() func = () {
            synchronized (_monitor)
            {
                while (queue.length == 0)
                {
                    _monitor.Wait();
                }

                awaken += 1;
            }
        };
        void delegate() notify = () {
            synchronized (_monitor)
            {
                queue ~= 1;
                _monitor.Broadcast();
            }
        };
        _stateTracker.Execute(() {
            Task.Run(func); //
            Task.Run(func);
            Task.Run(func);
            Task.Run(notify);
        });

        Assert.Equal(3, awaken);
    }    
}

unittest
{
    TestRunner!(MonitorTests).Execute();
}
