module taskqueue;
import std.container : DList;
import task;

public interface ITaskQueue
{
    public void Enqueue(ITask task);
    public void Dequeue(int count);
    public void Bind(ITask owner);
}

public class TaskQueue : ITaskQueue
{
    private DList!ITask _list;
    private ITask _owner;

    public void Bind(ITask owner)
    {
        _owner = owner;
    }

    public void Enqueue(ITask task)
    {
        _list.insertBack(task);
    }

    public void Dequeue(int count)
    {
        while (count-- != 0 && !_list.empty())
        {
            auto item = _list.front();

            item.Awake(_owner);
            _list.removeFront();
        }
    }
}
