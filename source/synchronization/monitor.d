module synchronization.monitor;
import core.time;
import std.datetime.systime;
import synchronization.mutex;
import synchronization.lock;
import task;

public class Monitor : Mutex
{
    private Task _inner;

    public this()
    {
        _inner = new Task();
    }

    public void Wait()
    {
        _inner.Await();
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
