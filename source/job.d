module job;
import task;
import taskqueue;
import core.thread : Fiber;
import taskvalue;
import statetracker;

public class Job : Task
{
    private Fiber _fiber;
    private IStateTracker _stateTracker;

    public this(ITaskQueue queue, void delegate() func, IStateTracker stateTracker)
    {
        super(queue);
        _stateTracker = stateTracker;
        _fiber = new Fiber(func);
    }

    public override void Awake(ITask task)
    {
        _stateTracker.Schedule(this);
    }

    public void Execute()
    {
        _fiber.call();
    }
}
