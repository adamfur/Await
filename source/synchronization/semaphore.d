module synchronization.semaphore;
import task;

public class Semaphore : Task
{
    private int _max;
    private int _count = 0;

    public this(int max)
    {
        _max = max;
    }

    public override void Await()
    {
        if (_count >= _max)
        {
            super.Await();
        }

        ++_count;
    }

    public void Release()
    {
        ReleaseNo(1);
    }
}
