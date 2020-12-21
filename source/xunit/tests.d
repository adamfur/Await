module xunit.tests;
import xunit.core;

protected class BaseException : Exception
{
    public this(string msg = "", string file = __FILE__, size_t line = __LINE__)
    {
        super(msg, file, line);
    }
}

protected class SubException : BaseException
{
    public this(string msg = "", string file = __FILE__, size_t line = __LINE__)
    {
        super(msg, file, line);
    }
}

protected class XUnitTests
{
    public void Equals_SameValue_Nothing()
    {
        Assert.Equal(1, 1);
    }

    public void Equals_DifferentValue_Nothing()
    {
        Assert.Throws!(XUnitException)(() { Assert.Equal(1, 2); });
    }

    public void NotEquals_SameValue_Throws()
    {
        Assert.Throws!(XUnitException)(() { Assert.NotEqual(1, 1); });
    }

    public void NotEquals_DifferentValue_Nothing()
    {
        Assert.NotEqual(1, 2);
    }

    public void Null_IsNull_Nothing()
    {
        Assert.Null(null);
    }

    public void Null_NotNull_Throws()
    {
        Assert.Throws!(XUnitException)(() { Assert.Null("hello"); });
    }

    public void NotNull_IsNull_Throws()
    {
        Assert.Throws!(XUnitException)(() { Assert.NotNull(null); });
    }

    public void NotNull_NotNull_Nothing()
    {
        Assert.NotNull("hello");
    }

    public void True_IsTrue_Nothing()
    {
        Assert.True(true);
    }

    public void True_False_Throws()
    {
        Assert.Throws!(XUnitException)(() { Assert.True(false); });
    }

    public void False_IsTrue_Throws()
    {
        Assert.Throws!(XUnitException)(() { Assert.False(true); });
    }

    public void False_False_Nothing()
    {
        Assert.False(false);
    }

    public void Zero_IsZero_Nothing()
    {
        Assert.Zero(0);
    }

    public void Zero_IsNotZero_Throws()
    {
        Assert.Throws!(XUnitException)(() { Assert.Zero(1); });
    }

    public void Throws_ThrowsNothing_Throws()
    {
        try
        {
            Assert.Throws!Exception(() {});
        }
        catch (XUnitException)
        {
            return;
        }

        assert(0);
    }

    public void Throws_BaseClass_Capture()
    {
        Assert.Throws!BaseException(() { throw new BaseException(); });
    }

    public void Throws_SubClass_Capture()
    {
        Assert.Throws!BaseException(() { throw new SubException(); });
    }

    public void Assert_Empty_True()
    {
        auto array = [];

        Assert.Empty(array);
    }

    public void Assert_NotEmpty_True()
    {
        auto array = [1];

        Assert.NotEmpty(array);
    }

    public void Assert_Empty_Throws()
    {
        auto array = [1];

        Assert.Throws!XUnitException(() => Assert.Empty(array));
    }

    public void Assert_NotEmpty_Throws()
    {
        auto array = [];

        Assert.Throws!XUnitException(() => Assert.NotEmpty(array));
    }
}

unittest
{
    TestRunner!(XUnitTests).Execute();
}
