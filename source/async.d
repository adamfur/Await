module async;
import core.sys.posix.netinet.in_;
import core.sys.posix.unistd;
import core.sys.posix.unistd : write;
import std.datetime.stopwatch;
import std.stdio;
import task;
import taskvalue;

public static class Async
{
    public static TaskValue!(int) AcceptAsync(int fd, sockaddr* addr, socklen_t* addrlen)
    {
        return Task.Run(() {
            // StateTracker.Instance.QueueRead(fd);
            return accept(fd, addr, addrlen);
        });
    }

    public static TaskValue!(long) ReadAsync(int fd, byte[] buffer)
    {
        return Task.Run(() {
            // StateTracker.Instance.QueueRead(fd);
            return read(fd, buffer.ptr, buffer.length);
        });
    }

    public static TaskValue!(long) WriteAsync(int fd, byte[] buffer)
    {
        return Task.Run(() {
            // StateTracker.Instance.QueueWrite(fd);
            return write(fd, buffer.ptr, buffer.length);
        });
    }
}
