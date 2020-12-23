module statetracker;
import core.sync.mutex;
import job;
import std.container : DList;
import task;
import taskqueue;
import timer.timerqueue;
import core.sync.mutex;
import core.sync.condition;
import std.stdio;
import std.format;

public interface IStateTracker
{
    public void Schedule(IJob job);
    public void Unschedule(IJob job);
    public void Execute(void delegate() func);
    public void Enqueue(ITimer timer);
    public void Forever(void delegate() func);
    public void Poke();
    public void Shutdown();
}

public class StateTracker : IStateTracker
{
    private DList!IJob _work;
    private static __gshared IStateTracker _instance;
    private ITimerQueue _timerQueue;
    private Mutex _mutex;
    private Condition _condition;
    private long _ticks = 0;
    private bool _running = true;

    public this(ITimerQueue timerQueue)
    {
        _timerQueue = timerQueue;
        _mutex = new Mutex();
        _condition = new Condition(_mutex);
        _instance = this;
        _timerQueue.Start();
    }

    public static IStateTracker Instance()
    {
        return _instance;
    }

    public void Enqueue(ITimer timer)
    {
        synchronized (_mutex)
        {
            _timerQueue.Enqueue(timer);
        }
    }

    public void Poke()
    {
        synchronized (_mutex)
        {
            _condition.notify();
        }
    }

    public void Schedule(IJob job)
    {
        synchronized (_mutex)
        {
            _work.insertBack(job);
            _condition.notify();
        }
    }

    public void Unschedule(IJob job)
    {
        synchronized (_mutex)
        {
            _work.linearRemoveElement(job);
        }
    }

    public void Execute(void delegate() func)
    {
        Schedule(new Job(new TaskQueue(), func, this));

        Run(() => !_work.empty());
        _timerQueue.Shutdown();
        // writeln("StateTracker: %d fiber switches".format(_ticks));
    }

    public void Forever(void delegate() func)
    {
        Schedule(new Job(new TaskQueue(), func, this));

        Run(() => _running);
        // writeln("StateTracker: %d fiber switches".format(_ticks));
    }

    public void Shutdown()
    {
        _timerQueue.Shutdown();
        synchronized (_mutex)
        {
            _running = false;
            _condition.notify();
        }
    }

    private void Run(bool delegate() predicate)
    {
        while (predicate())
        {
            IJob job;

            synchronized (_mutex)
            {
                while (_work.empty())
                {
                    _condition.wait(1_000.msecs);
                }

                job = _work.front();

                _work.removeFront();
            }

            job.Execute();
            _ticks += 1;
        }
    }
}
