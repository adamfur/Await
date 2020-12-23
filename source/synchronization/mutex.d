module synchronization.mutex;
import job;
import std.stdio;
import synchronization.lock;
import synchronization.semaphore;
import task;

public class Mutex : Semaphore
{
    private IJob _owner;
    private int _count = 0;

    public this()
    {
        super(1);
    }

    public override void lock()
    {
        if (_owner == TaskContext.Executing)
        {
            _count += 1;
            return;
        }

        while (true)
        {
            if (_owner is null)
            {
                _owner = TaskContext.Executing;
                _count = 1;
                return;
            }

            _task.Await();
        }
    }

    public override void unlock()
    {
        _count -= 1;

        if (_count == 0)
        {
            _owner = null;
            _task.ReleaseNo(1);
        }
    }
}
