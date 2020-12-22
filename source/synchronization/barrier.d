module synchronization.barrier;
import task;

public class Barrier : Task
{
    private int _max;
    private int _count = 0;

    public this(int max)
    {
        _max = max;
    }

    public override void Await()
    {
        if (_count > _max)
        {
            return;
        }

        _count += 1;

        if (_count >= _max)
        {
            ReleaseAll();
            return;
        }        

        super.Await();
    }
}
