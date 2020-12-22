module synchronization.mutex;
import synchronization.semaphore;

public class Mutex : Semaphore
{
    public this()
    {
        super(1);
    }
}