module timer.timerqueue;
import core.time;
import job;
import std.datetime.systime;
import task;
import std.container.binaryheap;
import core.sync.mutex;
import core.sync.condition;
import core.thread;
import std.stdio;
import statetracker;

public interface ITimerQueue
{
    public void Enqueue(ITimer timer);
    public void Execute();
    public void Start();
}

public class TimerQueue : Thread, ITimerQueue
{
    private BinaryHeap!(ITimer[]) _priorityQueue;
    private Mutex _mutex;
    private Condition _condition;

    public this()
    {
        super(&Run);
        _priorityQueue = BinaryHeap!(ITimer[])([], 0);
        _mutex = new Mutex();
        _condition = new Condition(_mutex);
    }

    public void Start()
    {
        start();
    }

    private void Run()
    {
        while (true)
        {
            ITimer timer;

            synchronized (_mutex)
            {
                while (_priorityQueue.empty())
                {
                    _condition.wait();
                }

                while (true)
                {
                    auto front = _priorityQueue.front();
                    auto now = Clock.currTime();
                    auto delta = (front.Deadline() - now);
                    auto duration = delta.total!"msecs";

                    if (duration <= 0)
                    {
                        break;
                    }                    

                    _condition.wait(duration.msecs);
                }

                timer = _priorityQueue.front();

                _priorityQueue.popFront();
            }

            timer.Trigger();
            // writeln("StateTracker.Instance().Poke();");
            StateTracker.Instance().Poke();
        }
    }

    public void Enqueue(ITimer timer)
    {
        synchronized (_mutex)
        {
            _priorityQueue.insert(timer);
            _condition.notify();
        }
    }

    public void Execute()
    {
        auto now = Clock.currTime();

        while (!_priorityQueue.empty())
        {
            auto item = _priorityQueue.front();

            if (!item.IsExpired(now))
            {
                break;
            }

            item.Trigger();
            _priorityQueue.popFront();
        }
    }
}

public interface ITimer
{
    public bool IsExpired(SysTime now);
    public void Trigger();
    public SysTime Deadline();
    public int opCmp(ITimer rhs);
}

public abstract class Timer : ITimer
{
    private SysTime _deadline;

    public int opCmp(ITimer rhs)
    {
        return rhs.Deadline().opCmp(Deadline());
    }

    public SysTime Deadline()
    {
        return _deadline;
    }

    protected this(Duration duration)
    {
        auto now = Clock.currTime();

        _deadline = (now + duration);
    }

    public bool IsExpired(SysTime now)
    {
        return _deadline <= now;
    }

    public abstract void Trigger();
}

public class TaskTimer : Timer
{
    private ITask _task;

    public this(ITask task, Duration duration)
    {
        super(duration);
        _task = task;
    }

    public override void Trigger()
    {
        _task.Complete();
    }
}

public class DummyTimer : Timer
{
    private void delegate() _func;

    public this(Duration duration, void delegate() func)
    {
        super(duration);
        _func = func;
    }

    public override void Trigger()
    {
        _func();
    }
}
