module tests.synchronization.fastmutex;
import synchronization.fastmutex;
import synchronization.barrier;
import statetracker;
import task;
import timerqueue;
import xunit.core;

protected class FastMutexTests
{
    private IStateTracker _stateTracker;

    public this()
    {
        _stateTracker = new StateTracker(new TimerQueue());
    }

    public void Lock_AlreadyLocked_Stuck()
    {
        auto finnished = 0;
        auto mutex = new FastMutex();
        void delegate() func = () {

            mutex.lock();
            synchronized (mutex)
            {
                finnished += 1;
            }
        };

        _stateTracker.Execute(() {
            Task.Run(func); //
        });

        Assert.Equal(0, finnished);
    }

    public void Lock_Unlocked_Success()
    {
        auto finnished = 0;
        auto mutex = new FastMutex();
        void delegate() func = () {

            synchronized (mutex)
            {
                finnished += 1;
            }
        };

        _stateTracker.Execute(() {
            Task.Run(func); //
            Task.Run(func);
        });

        Assert.Equal(2, finnished);
    }

    public void Lock_MaxOneAtTheTime_Success()
    {
        auto inside = 0;
        auto peak = 0;
        auto mutex = new FastMutex();
        void delegate() func = () {

            synchronized (mutex)
            {
                inside += 1;

                if (inside > peak)
                {
                    peak = inside;
                }

                Task.Yield();
                inside -= 1;
            }
        };

        _stateTracker.Execute(() {
            Task.Run(func); //
            Task.Run(func);
        });

        Assert.Equal(1, peak);
    }
}

unittest
{
    TestRunner!(FastMutexTests).Execute();
}
