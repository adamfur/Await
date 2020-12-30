module synchronization.monitor;
import core.time;
import std.datetime.systime;
import synchronization.fastmutex;
import synchronization.lock;
import synchronization.mutex;
import task;

public class Monitor : FastMutex
{
    private Task _inner;

    public this()
    {
        _inner = new Task();
    }

    public void Wait()
    {
        unlock();
        _inner.Await();
        lock();
    }

    public void Broadcast()
    {
        _inner.ReleaseAll();
    }

    public void Signal()
    {
        _inner.ReleaseNo(1);
    }
}
