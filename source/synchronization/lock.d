module synchronization.lock;
import object;
import std.stdio;

struct MonitorProxy
{
    Object.Monitor link;
}

public class Lock : Object.Monitor
{
    public this()
    {
        auto proxy = new MonitorProxy();

        proxy.link = this;
        this.__monitor = cast(void*) proxy;
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
