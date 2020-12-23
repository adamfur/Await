module synchronization.barrier;
import std.stdio;
import task;
import synchronization.lock;
import synchronization.semaphore;

public class Barrier : AsyncLock
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
            return;
        }

        _count += 1;

        if (_count >= _max)
        {
            _task.ReleaseAll();
            return;
        }        

        _task.Await();
    }

    public override void unlock()
    {
    }
}
