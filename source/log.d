module log;
import core.sys.posix.sys.time;
import std.format;
import std.stdio;

public enum LogLevel
{
    Trace,
    Debug,
    Information,
    Warning,
    Error,
    Panic,
    Off,
}

public class Log
{
    private LogLevel _currentLogLevel;
    private static __gshared Log _log;

    public shared static this()
    {
        _log = new Log(LogLevel.Trace);
    }

    public static void Set(Log log)
    {
        _log = log;
    }

    public this(LogLevel logLevel)
    {
        _currentLogLevel = logLevel;
    }

    public LogLevel Level()
    {
        return _currentLogLevel;
    }

    public static void Trace(scope string delegate() message)
    {
        _log.Submit(LogLevel.Trace, message, "Trace", "\x1b[35m");
    }

    public static void Debug(scope string delegate() message)
    {
        _log.Submit(LogLevel.Debug, message, "Debug", "\x1b[34m");
    }

    public static void Information(scope string delegate() message)
    {
        _log.Submit(LogLevel.Information, message, "Information", "\x1b[32m");
    }

    public static void Warning(scope string delegate() message)
    {
        _log.Submit(LogLevel.Warning, message, "Warning", "\x1b[33m");
    }

    public static void Error(scope string delegate() message)
    {
        _log.Submit(LogLevel.Error, message, "Error", "\x1b[31m");
    }

    public static void Panic(scope string delegate() message)
    {
        _log.Submit(LogLevel.Panic, message, "PANIC", "\x1b[1;31m");
        assert(0);
    }

    private void Submit(LogLevel logLevel, string delegate() message, string logType, string color)
    {
        if (logLevel < _currentLogLevel)
        {
            return;
        }

        timeval timeval;

        gettimeofday(&timeval, null);

        auto seconds = timeval.tv_sec;
        auto timeinfo = gmtime(cast(const time_t*)&seconds);

        stderr.writeln("%04d-%02d-%02d %02d:%02d:%02d.%06dZ [***] %s%s\x1b[0m: %s".format(timeinfo.tm_year + 1900,
                timeinfo.tm_mon + 1, timeinfo.tm_mday, timeinfo.tm_hour, timeinfo.tm_min,
                timeinfo.tm_sec, timeval.tv_usec, color, logType, message()));
    }
}
