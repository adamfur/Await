module synchronization.monitor;
import core.time;
import std.datetime.systime;
import synchronization.mutex;
import synchronization.lock;

public class Monitor : Mutex
{
    public void Wait()
    {
        _task.Await();
    }

    public void Broadcast()
    {
        _task.ReleaseAll();
    }

    public void Signal()
    {
        _task.ReleaseNo(1);
    }
}
