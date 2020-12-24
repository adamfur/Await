module tests.timertests;
import core.thread : Fiber;
import core.time;
import dsubstitute.core;
import exception;
import job;
import std.datetime.systime;
import task;
import taskqueue;
import taskvalue;
import timerqueue;
import xunit.core;

protected class TimerTests
{
    private ITimerQueue _queue;

    public this()
    {
        _queue = new TimerQueue();
    }

    public void VerifyOrder()
    {
        int[] array;

        _queue.Enqueue(new DummyTimer(-5.msecs, () { array ~= 3; }));
        _queue.Enqueue(new DummyTimer(-20.msecs, () { array ~= 1; }));
        _queue.Enqueue(new DummyTimer(-10.msecs, () { array ~= 2; }));
        _queue.Enqueue(new DummyTimer(10.msecs, () { array ~= 4; }));

        _queue.Execute();

        Assert.Equal([1, 2, 3], array);
    }
}

unittest
{
    TestRunner!(TimerTests).Execute();
}
