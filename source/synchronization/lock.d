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
    protected Task _task = new Task();

    public this()
    {
        _proxy.link = this;
        this.__monitor = cast(void*) &_proxy;
    }

    public abstract void lock();
    public abstract void unlock();
}


