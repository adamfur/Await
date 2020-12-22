module timer.timerqueue;
import core.time;
import job;
import std.datetime.systime;
import task;
import std.container.binaryheap;

public interface ITimerQueue
{
    public void Enqueue(ITimer timer);
    public void Execute();
}

public class TimerQueue : ITimerQueue
{
    private BinaryHeap!(ITimer[]) _priorityQueue;

    public this()
    {
        _priorityQueue = BinaryHeap!(ITimer[])([], 0);
    }

    public void Enqueue(ITimer timer)
    {
        _priorityQueue.insert(timer);
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
