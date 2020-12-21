module timer.timerqueue;

public interface ITimerQueue
{
    public void Add(ITimer timer);
    public void Remove(ITimer timer);
}

public class TimerQueue : ITimerQueue
{
    public void Add(ITimer timer)
    {
    }

    public void Remove(ITimer timer)
    {
    }
}

public interface ITimer
{
}

public class Timer : ITimer
{
}
