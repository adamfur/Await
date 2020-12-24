module tests.synchronization.barrier;
import synchronization.barrier;
import statetracker;
import task;
import timerqueue;
import xunit.core;

protected class BarrierTests
{
    private IStateTracker _stateTracker;

    public this()
    {
        _stateTracker = new StateTracker(new TimerQueue());
    }

    public void Lock_BarrierNotBroken_Stuck()
    {
        auto finnished = 0;
        auto barrier = new Barrier(2);
        void delegate() func = () {

            synchronized (barrier)
            {
            }

            finnished += 1;
        };

        _stateTracker.Execute(() {
            Task.Run(func); //
        });

        Assert.Equal(0, finnished);
    }

    public void Lock_BarrierBroken_Done()
    {
        auto finnished = 0;
        auto barrier = new Barrier(2);
        void delegate() func = () {

            synchronized (barrier)
            {
            }

            finnished += 1;
        };

        _stateTracker.Execute(() {
            Task.Run(func); //
            Task.Run(func);
        });

        Assert.Equal(2, finnished);
    }

    public void Lock_BarrierAlreadyBroken_Done()
    {
        auto finnished = 0;
        auto barrier = new Barrier(2);
        void delegate() func = () {

            synchronized (barrier)
            {
            }

            finnished += 1;
        };

        _stateTracker.Execute(() {
            Task.Run(func);
            Task.Run(func);
            Task.Run(func);
        });

        Assert.Equal(3, finnished);
    }
}

unittest
{
    TestRunner!(BarrierTests).Execute();
}
