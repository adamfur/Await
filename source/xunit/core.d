module xunit.core;
import std.stdio;
import std.string;
import std.traits;
import std.datetime.stopwatch;

public class XUnitException : Exception
{
    public this(string msg = "", string file = __FILE__, size_t line = __LINE__)
    {
        super(msg, file, line);
    }
}

public static class Assert
{
    // public static void Equal(S)(S expected, S actual)
    // {
    //     if (expected != actual)
    //     {
    //         throw new XUnitException("Equal, expected: \x1b[32m%s\x1b[0m, actual: \x1b[31m%s\x1b[0m".format(expected,
    //                 actual));
    //     }
    // }

    public static void Equal(S)(S expected, S actual, string file = __FILE__, size_t line = __LINE__)
    {
        if (expected != actual)
        {
            throw new XUnitException(
                    "(%s:%d) Equal, expected: \x1b[32m%s\x1b[0m, actual: \x1b[31m%s\x1b[0m".format(file,
                    line, expected, actual));
        }
    }    

    public static void NotEqual(S)(S expected, S actual)
    {
        if (expected == actual)
        {
            throw new XUnitException("Not equal, expected: %s, actual: %s".format(expected, actual));
        }
    }

    public static void Null(S)(S value)
    {
        if (value !is null)
        {
            throw new XUnitException("Not null");
        }
    }

    public static void NotNull(S)(S value)
    {
        if (value is null)
        {
            throw new XUnitException("Is null");
        }
    }

    public static void True(bool condition)
    {
        if (!condition)
        {
            throw new XUnitException("Expected true statement");
        }
    }

    public static void Zero(S)(S value)
    {
        if (value != 0)
        {
            throw new XUnitException("Expected zero statement");
        }
    }

    public static void False(bool condition)
    {
        if (condition)
        {
            throw new XUnitException("Expected false statement");
        }
    }

    public static void Empty(Range)(Range collection)
    {
        if (collection.length != 0)
        {
            throw new XUnitException("Not Empty");
        }
    }

    public static void NotEmpty(Range)(Range collection)
    {
        if (collection.length == 0)
        {
            throw new XUnitException("Empty");
        }
    }

    public static E Throws(E)(void delegate() action)
    {
        try
        {
            action();
        }
        catch (E ex)
        {
            return ex;
        }

        throw new XUnitException("Expected exception: %s wasn't thrown.".format(E.stringof));
    }
}

public class Suit
{
    private string _suit;
    public int Count;
    public int Passed;

    public this(string suit)
    {
        _suit = suit;
    }

    public string Name()
    {
        return _suit;
    }
}

public class StaticTestRunner
{
    protected static int Count;
    protected static int Passed;
    protected static Suit[] Suits;

    version (unittest)
    {
        shared static ~this()
        {
            writeln();
            writeln("Test suit report:");
            writeln();

            foreach (suit; Suits)
            {
                if (suit.Passed == suit.Count)
                {
                    writeln("\x1b[1;32m✓\x1b[0m %s (%d/%d)".format(suit.Name(),
                            suit.Passed, suit.Count));
                }
                else
                {
                    writeln("\x1b[1;31m●\x1b[0m %s (%d/%d)".format(suit.Name(),
                            suit.Passed, suit.Count));
                }
            }
        }
    }
}

public class TestRunner(S) : StaticTestRunner
{
    private Suit _suit;

    mixin(Gen());

    public this(Suit suit)
    {
        _suit = suit;
    }

    public static void Execute()
    {
        auto name = S.stringof;
        auto suit = new Suit(name);

        Suits ~= suit;
        writeln(Pad("Suit: %s".format(name)));

        scope instance = new TestRunner!(S)(suit);

        instance.Run();
    }

    private static string Pad(string str)
    {
        char[80] stripes = '-';

        auto result = "--- %s %s".format(str, stripes.idup);

        return result[0 .. 80].idup;
    }

    private static void Invoke(Suit suit, string className, string name, void function(S) test)
    {
        if (Count != Passed)
        {
            return; //
        }

        auto sw = StopWatch(AutoStart.yes);
        scope instance = new S();

        stdout.write("  #%d: %s".format(Passed, name));
        ++Count;
        ++suit.Count;

        try
        {
            test(instance);
            writeln("\r\x1b[1;32m✓\x1b[0m #%d: %s (%d ms)".format(Passed++,
                    name, sw.peek.total!"msecs"));
            ++suit.Passed;
        }
        catch (Throwable ex)
        {
            writeln("\r\x1b[1;31m●\x1b[0m #%d: %s".format(Passed, name));
            throw ex;
        }
    }

    public static string Gen()
    {
        string method = "void Run()";

        method ~= "{\n";
        foreach (name; __traits(allMembers, S))
        {
            foreach (t; __traits(getVirtualMethods, S, name))
            {
                auto skip = false;

                foreach (type; ParameterTypeTuple!(t))
                {
                    skip = true;
                }

                if (skip)
                {
                    continue;
                }

                const protection = __traits(getProtection, t);

                if (protection != "public")
                {
                    continue;
                }
                else if (ReturnType!t.stringof != "void")
                {
                    continue;
                }

                method ~= "Invoke(_suit, \"%s\", \"%s\", (ins) => ins.%s());\n".format(S.stringof,
                        name, name);
            }
        }

        method ~= "}\n";
        return method;
    }
}
