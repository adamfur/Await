module taskvalue;
import task;
import taskqueue;

public abstract class TaskValue(S) : Task
{
    protected S _value;

    public this(ITaskQueue queue)
    {
        super(queue);
    }

    public S Result()
    {
        Await();
        return _value;
    }
}

public class TaskValueSet(S) : TaskValue!S
{
    public this(ITaskQueue queue)
    {
        super(queue);
    }

    public this()
    {
        this(new TaskQueue());
    }

    public void Set(S value)
    {
        _value = value;
        Complete();
    }
}
