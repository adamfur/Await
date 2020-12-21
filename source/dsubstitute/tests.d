module dsubstitute.tests;
import xunit.core;
import dsubstitute.dynamic;
import dsubstitute.core;

protected interface IVoidMethod
{
    public void Foo();
}

protected interface IIntMethod
{
    public int Foo();
}

public class DummyException : Exception
{
    public this(string msg = "", string file = __FILE__, size_t line = __LINE__)
    {
        super(msg, file, line);
    }
}

protected class DSubstituteTests
{
    public void ArgumentMatcher_AlwaysPositive_Match()
    {
        IDynamic d1 = new DynamicValue!(int)(13);
        ArgumentMatcher d2 = new ExactArgumentMatcher!int((x) { return true; });

        Assert.True(d2.IsExpected(d1));
    }

    public void ArgumentMatcher_AlwaysNegative_NoMatch()
    {
        IDynamic d1 = new DynamicValue!(int)(13);
        ArgumentMatcher d2 = new ExactArgumentMatcher!int((x) { return false; });

        Assert.False(d2.IsExpected(d1));
    }

    public void ArgumentMatcher_LambdaExact_Match()
    {
        IDynamic d1 = new DynamicValue!(int)(13);
        ArgumentMatcher d2 = new ExactArgumentMatcher!int((x) { return x == 13; });

        Assert.True(d2.IsExpected(d1));
    }

    public void ArgumentMatcher_LambdaInexact_NoMatch()
    {
        IDynamic d1 = new DynamicValue!(int)(13);
        ArgumentMatcher d2 = new ExactArgumentMatcher!int((x) { return x == 15; });

        Assert.False(d2.IsExpected(d1));
    }

    public void Received_MethodCalled_Nothing()
    {
        auto mock = Substitute.For!(IVoidMethod)();

        mock.Foo();

        mock.Received().Foo();
    }

    public void Received_MethodNotCalled_Throws()
    {
        auto mock = Substitute.For!(IVoidMethod)();

        Assert.Throws!DSubstituteException(() { mock.Received().Foo(); });
    }

    public void DidNotReceive_MethodCalled_Throws()
    {
        auto mock = Substitute.For!(IVoidMethod)();

        mock.Foo();

        Assert.Throws!DSubstituteException(() { mock.DidNotReceive().Foo(); });
    }

    public void DidNotReceive_MethodNotCalled_Nothing()
    {
        auto mock = Substitute.For!(IVoidMethod)();

        mock.DidNotReceive().Foo();
    }

    public void Do_VoidAction_Throws()
    {
        auto mock = Substitute.For!(IVoidMethod)();

        mock.Mock().Foo().Do(() { throw new DummyException(); });

        Assert.Throws!DummyException(() { mock.Foo(); });
    }

    public void Do_IntAction_Throws()
    {
        auto mock = Substitute.For!(IIntMethod)();

        mock.Mock().Foo().Do(() { throw new DummyException(); });

        Assert.Throws!DummyException(() { mock.Foo(); });
    }

    public void Do_IntAction_Value()
    {
        auto mock = Substitute.For!(IIntMethod)();

        mock.Mock().Foo().Returns(42);

        auto result = mock.Foo();
        Assert.Equal(42, result);
    }

    public void Do_IntAction_DefaultValue()
    {
        auto mock = Substitute.For!(IIntMethod)();

        auto result = mock.Foo();
        Assert.Zero(result);
    }
}

protected class DynamicTests
{
    public void Compare_AlwaysTrueLambda_True()
    {
        auto d1 = new DynamicValue!(int)(13);
        auto d2 = new DynamicLambda!(int)((x) { return true; });

        Assert.True(d1.Compare(d2));
    }

    public void Compare_AlwaysFlaseLambda_False()
    {
        auto d1 = new DynamicValue!(int)(13);
        auto d2 = new DynamicLambda!(int)((x) { return false; });

        Assert.False(d1.Compare(d2));
    }

    public void Compare_MatchedLambda_True()
    {
        auto d1 = new DynamicValue!(int)(13);
        auto d2 = new DynamicLambda!(int)((x) { return x == 13; });

        Assert.True(d1.Compare(d2));
    }

    public void Compare_UnmatchedLambda_False()
    {
        auto d1 = new DynamicValue!(int)(13);
        auto d2 = new DynamicLambda!(int)((x) { return x == 15; });

        Assert.False(d1.Compare(d2));
    }
}

unittest
{
    TestRunner!(DSubstituteTests).Execute();
    TestRunner!(DynamicTests).Execute();
}
