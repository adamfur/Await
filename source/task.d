module task;
import core.thread : Fiber;
import taskvalue;
import taskqueue;
import job;
import statetracker;

public enum TaskStatus
{
    Pending,
    Completed,
    Faulted,
}

public static class TaskContext
{
    protected static ITask Executing;
}

public interface ITask
{
    public void Awake(ITask task);
}

public class Task : TaskContext, ITask
{
    private TaskStatus _status = TaskStatus.Pending;
    private Exception _exception;
    private ITaskQueue _queue;

    public this(ITaskQueue queue)
    {
        _queue = queue;
        _queue.Bind(this);
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
        Throw();
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

    public void ReleaseAll()
    {
        const intMax = 2_147_483_647;

        ReleaseNo(intMax);
    }

    protected void ReleaseNo(int count)
    {
        _queue.Dequeue(count);
    }

    public void Awake(ITask task)
    {
    }

    // Task opBinary(string op, T)(T y) const pure nothrow @safe
    //         if ((op == "await") && is(T : Task))
    // {
    //     return null;
    // }

    public static Task Run(void delegate() func)
    {
        auto job = new Job(new TaskQueue(), func, StateTracker.Instance());

        StateTracker.Instance().Schedule(job);
        return job;
        // return Run(() {
        //     func(); //
        //     return null;
        // });
    }

    // public TaskValue!S Run(S)(S delegate() func)
    // {
    //     void delegate() = 
    //     auto job = new Job(new TaskQueue(), );
    //     return null;
    // }
}
