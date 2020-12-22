module tests.taskvaluetests;
import xunit.core;
import task;
import taskvalue;
import dsubstitute.core;
import core.thread : Fiber;
import exception;
import taskqueue;
import job;

protected class TaskValueTests : TaskContext
{
    public Mock!ITaskQueue _queue;
    private Fiber _fiber;
    private TaskValueSet!int _task;

    public this()
    {
        _queue = Substitute.For!ITaskQueue();
        _task = new TaskValueSet!int(_queue);
        Executing = Substitute.For!IJob();
    }

    public void Result_ResultWithException_Throws()
    {
        Execute(() {
            _task.Result(); //
        });

        _task.SetException(new TaskCancellationException(""));
        Assert.Throws!TaskCancellationException(() => Tick(() {}));
    }

    public void Result_ResultSetValue_Value()
    {
        Execute(() {
            Assert.Equal(13, _task.Result()); //
        });

        Tick(() => _task.Set(13));
    }

    public void Result_ResultWithValue_Value()
    {
        _task.Set(13);
        Assert.Equal(13, _task.Result());
    }

    private void Execute(void delegate() func)
    {
        _fiber = new Fiber(func);

        _fiber.call();
    }

    private void Tick(void delegate() func)
    {
        func();
        _fiber.call();
    }
}

unittest
{
    TestRunner!(TaskValueTests).Execute();
}
