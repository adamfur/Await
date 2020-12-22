module synchronization.fastmutex;
import synchronization.semaphore;

public class FastMutex : Semaphore
{
    public this()
    {
        super(1);
    }
}