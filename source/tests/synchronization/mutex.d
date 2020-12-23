module tests.synchronization.mutex;
import synchronization.mutex;
import synchronization.barrier;
import statetracker;
import task;
import timer.timerqueue;
import xunit.core;

protected class MutexTests
{
    private IStateTracker _stateTracker;

    public this()
    {
        _stateTracker = new StateTracker(new TimerQueue());
    }

    public void Lock_AlreadyLockedByAnother_Stuck()
    {
        auto finnished = 0;
        auto mutex = new Mutex();
        void delegate() func = () {

            synchronized (mutex)
            {
                finnished += 1;
            }
        };

        _stateTracker.Execute(() {
            Task.Run((() => mutex.lock())).Await();
            Task.Run(func); //
        });

        Assert.Equal(0, finnished);
    }

    public void Lock_Unlocked_Success()
    {
        auto finnished = 0;
        auto mutex = new Mutex();
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
        auto mutex = new Mutex();
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

    public void Lock_SameTaskCanLockMultipleTimes_Success()
    {
        auto finnished = 0;
        auto mutex = new Mutex();
        void delegate() func = () {

            synchronized (mutex)
            {
                synchronized (mutex)
                {
                    finnished += 1;
                }
            }
        };

        _stateTracker.Execute(() {
            Task.Run(func); //
            Task.Run(func);
        });

        Assert.Equal(2, finnished);
    }
}

unittest
{
    TestRunner!(MutexTests).Execute();
}
