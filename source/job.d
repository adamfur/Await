module job;
import core.thread : Fiber;
import statetracker;
import std.stdio;
import task;
import taskqueue;
import taskvalue;

public interface IJob : ITask
{
    public void Execute();
    public void Awake();
}

public class Job : Task, IJob
{
    private Fiber _fiber;
    private IStateTracker _stateTracker;

    public this(ITaskQueue queue, void delegate() func, IStateTracker stateTracker)
    {
        super(queue);
        _stateTracker = stateTracker;
        _fiber = new Fiber(func);
    }

    public void Awake()
    {
        _stateTracker.Schedule(this);
    }

    public void Execute()
    {
        Executing = this;
        State = _stateTracker;
        _fiber.call();

        // if (_fiber.state == Fiber.State.TERM)
        // {
        // }
    }
}
