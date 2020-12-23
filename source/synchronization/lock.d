module synchronization.lock;
import object;
import std.stdio;

struct MonitorProxy
{
    Object.Monitor link;
}

public class Lock : Object.Monitor
{
    private MonitorProxy _proxy;

    public this()
    {
        _proxy.link = this;
        this.__monitor = cast(void*) &_proxy;
    }

    public void lock()
    {
        writeln("lock");
    }

    public void unlock()
    {
        writeln("unlock");
    }
}
