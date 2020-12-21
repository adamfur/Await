module statetracker;
import job;
import std.container : DList;
import task;
import taskqueue;

public interface IStateTracker
{
    public void Schedule(Job job);
    public void Unschedule(Job job);
}

public class StateTracker : IStateTracker
{
    private DList!Job _work;
    private static __gshared IStateTracker _instance;

    public this(void delegate() func)
    {
        _instance = this;
        Schedule(new Job(new TaskQueue(), func, this));
    }

    public static IStateTracker Instance()
    {
        return _instance;
    }

    public void Schedule(Job job)
    {
        _work.insertBack(job);
    }

    public void Unschedule(Job job)
    {
        _work.linearRemoveElement(job);
    }

    public void Execute()
    {
        while (!_work.empty())
        {
            auto job = _work.front();

            _work.removeFront();

            job.Execute();
        }
    }
}
