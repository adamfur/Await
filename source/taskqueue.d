module taskqueue;
import job;
import std.container : DList;
import task;

public interface ITaskQueue
{
    public void Enqueue(IJob task);
    public void Dequeue(int count);
}

public class TaskQueue : ITaskQueue
{
    private DList!IJob _list;

    public void Enqueue(IJob task)
    {
        _list.insertBack(task);
    }

    public void Dequeue(int count)
    {
        while (count-- != 0 && !_list.empty())
        {
            auto item = _list.front();

            item.Awake();
            _list.removeFront();
        }
    }
}
