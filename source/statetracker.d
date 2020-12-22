module statetracker;
import job;
import std.container : DList;
import task;
import taskqueue;

public interface IStateTracker
{
    public void Schedule(IJob job);
    public void Unschedule(IJob job);
    public void Execute(void delegate() func);
}

public class StateTracker : IStateTracker
{
    private DList!IJob _work;
    private static __gshared IStateTracker _instance;

    public this()
    {
        _instance = this;
    }

    public static IStateTracker Instance()
    {
        return _instance;
    }

    public void Schedule(IJob job)
    {
        _work.insertBack(job);
    }

    public void Unschedule(IJob job)
    {
        _work.linearRemoveElement(job);
    }

    public void Execute(void delegate() func)
    {
        Schedule(new Job(new TaskQueue(), func, this));

        while (!_work.empty())
        {
            auto job = _work.front();

            _work.removeFront();

            job.Execute();
        }
    }
}
