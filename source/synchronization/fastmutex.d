module synchronization.fastmutex;
import synchronization.semaphore;
import synchronization.lock;

public class FastMutex : Semaphore
{
    public this()
    {
        super(1);
    }
}