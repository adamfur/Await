module synchronization.monitor;
import core.time;
import std.datetime.systime;
import synchronization.mutex;

public class Monitor : Mutex
{
    public void Wait()
    {
        super.Await();
    }

    public void Wait(Duration duration)
    {
        // create timer
        super.Await();
    }

    public void Broadcast()
    {
        ReleaseAll();
    }

    public void Signal()
    {
        ReleaseNo(1);
    }
}
