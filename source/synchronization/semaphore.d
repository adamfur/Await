module synchronization.semaphore;
import task;
import synchronization.lock;

public class Semaphore : AsyncLock
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