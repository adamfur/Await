module synchronization.mutex;
import synchronization.semaphore;
import job;

public class Mutex : Semaphore
{
    private IJob _owner;

    public this()
    {
        super(1);
    }

    protected override void Lock()
    {

    }
}
