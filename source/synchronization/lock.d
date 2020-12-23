module synchronization.lock;
import object;
import std.stdio;
import task;

struct MonitorProxy
{
    Object.Monitor link;
}

public abstract class AsyncLock : Object.Monitor
{
    private MonitorProxy _proxy;
    private Task _task = new Task();

    public this()
    {
        _proxy.link = this;
        this.__monitor = cast(void*) &_proxy;
    }

    public abstract void lock();
    public abstract void unlock();
}

public class NewSempahore : AsyncLock
{
    private int _max;
    private int _count = 0;

    public this(int max)
    {
        _max = max;
    }

    public override void lock()
    {
        if (_count >= _max)
        {
            _task.Await();
        }

        ++_count;
    }

    public override void unlock()
    {
        _count -= 1;
        _task.ReleaseNo(1);
    }
}
