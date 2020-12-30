module tests.synchronization.semaphore;
import synchronization.semaphore;
import synchronization.barrier;
import statetracker;
import task;
import timerqueue;
import xunit.core;

protected class SemaphoreTests
{
    private IStateTracker _stateTracker;

    public this()
    {
        _stateTracker = new StateTracker(new TimerQueue());
    }

    public void Lock_AlreadyLocked_Stuck()
    {
        auto finnished = 0;
        auto semaphore = new Semaphore(1);
        void delegate() func = () {

            semaphore.lock();
            synchronized (semaphore)
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
        auto semaphore = new Semaphore(1);
        void delegate() func = () {

            synchronized (semaphore)
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

    public void Lock_MaxNoAtTheTime_Success()
    {
        auto inside = 0;
        auto peak = 0;
        auto semaphore = new Semaphore(2);
        void delegate() func = () {

            synchronized (semaphore)
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
            Task.Run(func);
        });

        Assert.Equal(2, peak);
    }
}

unittest
{
    TestRunner!(SemaphoreTests).Execute();
}
