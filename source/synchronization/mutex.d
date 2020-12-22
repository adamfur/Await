module synchronization.mutex;
import synchronization.semaphore;
import job;
import std.stdio;

public class Mutex : Semaphore
{
    private IJob _owner;
    private int _count = 0;

    public this()
    {
        super(1);
    }

    public override void Await()
    {
        while (true)
        {
            if (_owner == Executing)
            {
                _count += 1;
                return;
            }
            else if (_owner is null)
            {
                _owner = Executing;
                _count = 1;
                return;
            }

            super.Await();
        }
    }

    public override void Release()
    {
        _count -= 1;

        if (_count == 0)
        {
            _owner = null;
            ReleaseNo(1);
        }
    }
}
