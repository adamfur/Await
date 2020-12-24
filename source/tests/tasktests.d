module tests.tasktests;
import xunit.core;
import task;
import dsubstitute.core;
import core.thread : Fiber;
import exception;
import taskqueue;
import statetracker;
import job;
import std.stdio;
import timerqueue;

protected class TaskTests : TaskContext
{
    public Mock!ITaskQueue _queue;
    private Fiber _fiber;
    private Task _task;
    private Mock!IJob _subTask1;
    private Mock!IJob _subTask2;

    public this()
    {
        _queue = Substitute.For!ITaskQueue();
        _task = new Task(_queue);
        Executing = Substitute.For!IJob();
        // State = new StateTracker(new TimerQueue());
        State = new StateTracker(Substitute.For!ITimerQueue());
        _subTask1 = Substitute.For!IJob();
        _subTask2 = Substitute.For!IJob();
    }

    public void Await_Await_Nothing()
    {
        Execute(() {
            _task.Await(); //
        });

        _queue.Received().Enqueue(Arg.Is!IJob(Executing));
    }

    public void Await_SetException_AwaitException()
    {
        _task.SetException(new TaskCancellationException(""));

        Assert.Throws!TaskCancellationException(() => _task.Await());
        _queue.DidNotReceive().Enqueue(Arg.Is!IJob(Executing));
    }

    public void Await_SetExceptionOnCompleted_NoException()
    {
        _task.Complete();
        _task.SetException(new TaskCancellationException(""));

        _task.Await();
        _queue.DidNotReceive().Enqueue(Arg.Is!IJob(Executing));
    }

    public void Await_CompletedOnSetException_NoException()
    {
        _task.SetException(new TaskCancellationException(""));
        _task.Complete();

        _task.Await();
        _queue.DidNotReceive().Enqueue(Arg.Is!IJob(Executing));
    }

    public void Await_ResumeWithFault_Throws()
    {
        Execute(() {
            _task.Await(); //
        });

        Assert.Throws!TaskCancellationException(
                () => Tick(() => _task.SetException(new TaskCancellationException(""))));
    }

    public void Await_ResumeWithCompletation_Nothing()
    {
        Execute(() {
            _task.Await(); //
        });

        Tick(() => _task.Complete());
    }

    public void FromResult_Create_HasValue()
    {
        auto value = Task.FromResult!int(13);

        Assert.Equal(TaskStatus.Completed, value.Status());
        Assert.Equal(13, value.Result());
    }

    public void CompletedTask_Create_IsCompleted()
    {
        auto task = Task.CompletedTask();

        Assert.Equal(TaskStatus.Completed, task.Status());
    }

    public void CompletedTask_Complete_AwakenAll()
    {
        auto task = new Task(new TaskQueue());

        Execute(() {
            Executing = _subTask1; //
            task.Await();
        });

        Execute(() {
            Executing = _subTask2; //
            task.Await();
        });

        task.Complete();

        _subTask1.Received().Awake();
        _subTask2.Received().Awake();
    }

    public void CompletedTask_SetException_AwakenAll()
    {
        auto task = new Task(new TaskQueue());

        Execute(() {
            Executing = _subTask1; //
            task.Await();
        });

        Execute(() {
            Executing = _subTask2; //
            task.Await();
        });

        task.SetException(new TaskCancellationException(""));

        _subTask1.Received().Awake();
        _subTask2.Received().Awake();
    }

    public void Run_Result_Expected()
    {
        int result = 0;

        State.Execute(() {
            result = Task.Run(() => 13).Result(); //
        });

        Assert.Equal(13, result);
    }

    public void Run_Throws_Propagate()
    {
        Assert.Throws!TaskCancellationException(() {
            State.Execute(() {
                Task.Run(() {
                    throw new TaskCancellationException(""); //
                }).Await();
            });
        });
    }

    private void Execute(void delegate() func)
    {
        _fiber = new Fiber(func);

        _fiber.call();
    }

    private void Tick()
    {
        Tick(() {});
    }

    private void Tick(void delegate() func)
    {
        func();

        if (_fiber.state != Fiber.State.TERM)
        {
            _fiber.call();
        }
    }
}

unittest
{
    TestRunner!(TaskTests).Execute();
}
