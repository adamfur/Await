module task;
import core.thread : Fiber;
import core.time;
import job;
import statetracker;
import taskqueue;
import taskvalue;
import timerqueue;

public enum TaskStatus
{
    Pending,
    Completed,
    Faulted,
}

public static class TaskContext
{
    public static IJob Executing;
    public static IStateTracker State;
}

public interface ITask
{
    public void Complete();
    public void Await();
}

public class Task : TaskContext, ITask
{
    private TaskStatus _status = TaskStatus.Pending;
    private Exception _exception;
    protected ITaskQueue _queue;

    public this()
    {
        _queue = new TaskQueue();
    }

    public this(ITaskQueue queue)
    {
        _queue = queue;
    }

    public TaskStatus Status()
    {
        return _status;
    }

    public void Await()
    {
        if (_status == TaskStatus.Completed)
        {
            return;
        }

        Throw();
        _queue.Enqueue(Executing);
        Fiber.yield();
        Cancelled();
        Throw();
    }

    private void Cancelled()
    {
        // if (_cancelled)
        // {
        //     throw new TaskCancelledException();
        // }
    }

    private void Throw()
    {
        if (_status == TaskStatus.Faulted)
        {
            throw _exception;
        }
    }

    public void SetException(Exception exception)
    {
        if (_status == TaskStatus.Completed)
        {
            return;
        }

        _exception = exception;
        _status = TaskStatus.Faulted;
        ReleaseAll();
    }

    public void Complete()
    {
        _status = TaskStatus.Completed;
        ReleaseAll();
    }

    public static TaskValue!S FromResult(S)(S value)
    {
        auto task = new TaskValueSet!S(new TaskQueue());

        task.Set(value);
        return task;
    }

    public static Task CompletedTask()
    {
        auto task = new Task(new TaskQueue());

        task.Complete();
        return task;
    }

    import std.stdio;

    public void ReleaseAll()
    {
        const intMax = 2_147_483_647;

        ReleaseNo(intMax);
    }

    public void ReleaseNo(int count)
    {
        _queue.Dequeue(count);
    }

    public static Task Run(void delegate() func)
    {
        return Run(() {
            func(); //

            return 0;
        });
    }

    public static void Yield()
    {
        State.Schedule(Executing);
        Fiber.yield();
    }

    public static TaskValue!S Run(S)(S delegate() func)
    {
        if (State is null)
        {
            throw new Exception("Not in async context");
        }

        auto task = new TaskValueSet!S(new TaskQueue());
        auto job = new Job(new TaskQueue(), () {
            try
            {
                auto result = func();

                task.Set(result);
            }
            catch (Exception ex)
            {
                task.SetException(ex);
            }
        }, State);

        State.Schedule(job);

        return task;
    }

    public static Task Delay(Duration duration)
    {
        auto task = new Task(new TaskQueue());
        auto timer = new TaskTimer(task, duration);

        State.Enqueue(timer);

        return task;
    }
}
