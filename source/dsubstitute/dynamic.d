module dsubstitute.dynamic;

public interface IDynamic
{
    public TypeInfo Type();
    public bool Compare(IDynamic other);
}

public class DynamicValue(T) : IDynamic
{
    private T _value;

    public this(T value)
    {
        _value = value;
    }

    public TypeInfo Type()
    {
        return typeid(T);
    }

    public bool Compare(IDynamic other)
    {
        if (Type() != other.Type())
        {
            return false;
        }

        if (!(cast(DynamicLambda!(T)) other)._predicate(_value))
        {
            return false;
        }

        return true;
    }

    public T Value()
    {
        return _value;
    }
}

public class DynamicLambda(T) : IDynamic
{
    private bool delegate(T) _predicate;

    public this(bool delegate(T) predicate)
    {
        _predicate = predicate;
    }

    public TypeInfo Type()
    {
        return typeid(T);
    }

    public bool Compare(IDynamic other)
    {
        return false;
    }
}
