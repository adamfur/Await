module synchronization.monitor;
import core.time;
import std.datetime.systime;
import synchronization.fastmutex;
import synchronization.lock;
import synchronization.mutex;
import task;

public class Monitor : FastMutex
{
    private Task _condition;

    public this()
    {
        _condition = new Task();
    }

    public void Wait()
    {
        unlock();
        _condition.Await();
        lock();
    }

    public void Broadcast()
    {
        _condition.ReleaseAll();
    }

    public void Signal()
    {
        _condition.ReleaseNo(1);
    }
}
