module dsubstitute.core;
import std.conv;
import std.string;
import std.traits;
import dsubstitute.dynamic;

import task;
import job;

public class DSubstituteException : Exception
{
	public this(string msg = "", string file = __FILE__, size_t line = __LINE__)
	{
		super(msg, file, line);
	}
}

public class ArgumentMatcher
{
	private IDynamic _dynamic;

	public this(IDynamic dynamic)
	{
		_dynamic = dynamic;
	}

	public bool IsExpected(IDynamic dynamic)
	{
		return dynamic.Compare(_dynamic) == true;
	}
}

public class TypedArgumentMatcher(T) : ArgumentMatcher
{
	public this(IDynamic dynamic)
	{
		super(dynamic);
	}
}

public class AnyArgumentMatcher(T) : TypedArgumentMatcher!T
{
	public this()
	{
		super(new DynamicLambda!(T)((x) { return true; }));
	}
}

public class ExactArgumentMatcher(T) : TypedArgumentMatcher!T
{
	public this(bool delegate(T) predicate)
	{
		super(new DynamicLambda!(T)(predicate));
	}
}

public interface IPostCondition
{
	public IDynamic Value();
}

public class PostCondition(T) : IPostCondition
{
	private IDynamic _value;
	private void delegate() _doFunc;

	public this()
	{
		T _default;

		_value = new DynamicValue!(T)(_default);
		_doFunc = () {};
	}

	public void Returns(T value)
	{
		_value = new DynamicValue!(T)(value);
		_doFunc = () {};
	}

	public void Do(void delegate() func)
	{
		_doFunc = func;
	}

	public IDynamic Value()
	{
		_doFunc();
		return _value;
	}
}

public class ExecutedCondition
{
	private int _count = 0;

	public this(int count)
	{
		_count = count;
	}

	public void Once()
	{
		if (_count != 1)
		{
			throw new DSubstituteException("Once()");
		}
	}

	public void Twice()
	{
		if (_count != 2)
		{
			throw new DSubstituteException("Once()");
		}
	}

	public void Times(int value)
	{
		if (_count != value)
		{
			throw new DSubstituteException("Times(int value)");
		}
	}
}

static class Arg
{
	public static TypedArgumentMatcher!T Any(T)()
	{
		return new AnyArgumentMatcher!T();
	}

	public static TypedArgumentMatcher!T Is(T)(bool delegate(T) predicate)
	{
		return new ExactArgumentMatcher!T(predicate);
	}

	public static TypedArgumentMatcher!T Is(T)(T value)
	{
		return new ExactArgumentMatcher!T((x) { return x == value; });
	}
}

public class Call
{
	private string _signature;
	private IPostCondition _postCondition;
	public ArgumentMatcher[] _parameters;
	private int _called = 0;

	public this(string signature, IPostCondition postCondition, ArgumentMatcher[] arguments)
	{
		_signature = signature;
		_postCondition = postCondition;
		_parameters ~= arguments;
	}

	public IPostCondition PostCondition()
	{
		return _postCondition;
	}

	public ArgumentMatcher IndexOf(int index)
	{
		return _parameters[index];
	}

	public void IncreaseCallCount()
	{
		++_called;
	}

	public string Signature()
	{
		return _signature;
	}

	public int CallCount()
	{
		return _called;
	}
}

public class Receive(T)
{
	private Mock!T _mock;
	private Record[] _records;
	private int _count;

	public this(Mock!T mock, Record[] records, int count)
	{
		_mock = mock;
		_records = records;
		_count = count;
	}

	public ExecutedCondition Invoke(string signature, ArgumentMatcher[] args...)
	{
		auto count = 0;

		foreach (record; _records)
		{
			if (record.Signature() != signature)
			{
				continue;
			}

			auto index = 0;
			auto good = true;

			foreach (arg; args)
			{
				auto dynamic = record.IndexOf(index);

				if (arg.IsExpected(dynamic) == true)
				{
					++index;
					continue;
				}

				good = false;
				break;
			}

			if (good)
			{
				++count;
			}
		}

		// writeln("Wanted: %d, got: %d".format(_count, count));

		if (_count == 0)
		{
			if (count != _count)
			{
				throw new DSubstituteException("Method with signature: %s, expected: %d, got: %d".format(signature,
						_count, count));
			}
		}
		else
		{
			if (count <= 0)
			{
				throw new DSubstituteException("Method with signature: %s, expected: %d, got: %d".format(signature,
						_count, count));
			}
		}

		return null;
	}

	mixin(Gen());

	public static string Gen()
	{
		auto doJoin = (string[] array) {
			if (array.length == 0)
			{
				return "";
			}

			return ", " ~ array.join(", ");
		};
		string method = "";

		foreach (name; __traits(allMembers, T))
		{
			foreach (t; __traits(getVirtualMethods, T, name))
			{
				string[] parameters;
				string[] parameters2;
				string[] matchers;
				auto p = 0;

				foreach (type; ParameterTypeTuple!(t))
				{
					parameters ~= "p%d".format(p);
					matchers ~= "TypedArgumentMatcher!(%s) p%d".format(fullyQualifiedName!(type),
							p);
					parameters2 ~= "%s p%d".format(fullyQualifiedName!(type), p);
					++p;
				}

				string signature = "%s %s(%s)".format(fullyQualifiedName!(ReturnType!(t)),
						name, parameters2.join(", "));

				// Argument Matcher
				method ~= "public ExecutedCondition %s(%s)\n".format(name, matchers.join(", "));
				method ~= "{\n";
				method ~= "\tstring signature = \"%s\";\n".format(signature);
				method ~= "\n";
				method ~= "\treturn Invoke(signature%s);\n".format(doJoin(parameters));
				method ~= "}\n";
			}
		}

		return method;
	}
}

public class Record
{
	private string _signature;
	private IDynamic[] _args;

	public this(string signature, IDynamic[] args)
	{
		_signature = signature;
		_args ~= args;
	}

	public IDynamic IndexOf(int index)
	{
		return _args[index];
	}

	public string Signature()
	{
		return _signature;
	}
}

public class Mocked(T) if (is(T == class) || is(T == interface))
{
	private Mock!(T) _mock;

	this(Mock!(T) mock)
	{
		_mock = mock;
	}

	private void Register(E)(string signature, IPostCondition postCondition,
			ArgumentMatcher[] arguments...)
	{
		_mock.Register!(E)(signature, postCondition, arguments);
	}

	mixin(Gen());

	public static string Gen()
	{
		string method = "";

		auto doJoin = (string[] array) {
			if (array.length == 0)
			{
				return "";
			}

			return ", " ~ array.join(", ");
		};

		foreach (name; __traits(allMembers, T))
		{
			foreach (t; __traits(getVirtualMethods, T, name))
			{
				string[] parameters;
				string[] names;
				string[] parameters2;
				auto p = 0;

				foreach (type; ParameterTypeTuple!(t))
				{
					parameters ~= "%s p%d".format(fullyQualifiedName!(type), p);
					names ~= "p%s".format(to!string(p));
					parameters2 ~= "TypedArgumentMatcher!(%s) p%d".format(fullyQualifiedName!(type),
							p);
					++p;
				}

				string signature = "%s %s(%s)".format(fullyQualifiedName!(ReturnType!(t)),
						name, parameters.join(", "));

				// Bastard
				auto returnType = fullyQualifiedName!(ReturnType!(t));

				if (returnType == "void")
				{
					returnType = "int";
				}

				method ~= "public PostCondition!(%s) %s(%s)".format(returnType,
						name, parameters2.join(", "));
				method ~= "{\n";
				method ~= "	string signature = \"%s\";\n".format(signature);
				method ~= "\n";
				method ~= "	auto post = new PostCondition!(%s)();\n".format(returnType);
				method ~= "	Register!int(signature, post%s);\n".format(doJoin(names));
				method ~= "\treturn post;\n";
				method ~= "}\n";
			}
		}

		return method;
	}
}

public class Mock(T) : T
{
	public int[string] called;
	public Call[] _calls;
	public Record[] _record;

	public Receive!(T) Received()
	{
		return new Receive!(T)(this, _record, 1);
	}

	public Receive!(T) DidNotReceive()
	{
		return new Receive!(T)(this, _record, 0);
	}

	public Mocked!(T) Mock()
	{
		return new Mocked!(T)(this);
	}

	public void ResetMock()
	{
		_record = [];
	}

	public void Register(E)(string signature, IPostCondition postCondition,
			ArgumentMatcher[] arguments...)
	{
		auto call = new Call(signature, postCondition, arguments);

		_calls ~= call;
	}

	private void RegisterCallCount(string signature)
	{
		called[signature] += 1;
	}

	public Call Find(string signature, IDynamic[] dynamics)
	{
		foreach (call; _calls)
		{
			if (call.Signature() != signature)
			{
				continue;
			}

			auto index = 0;
			bool good = true;

			foreach (dynamic; dynamics)
			{
				auto matcher = call.IndexOf(index); // lambda

				if (matcher.IsExpected(dynamic) == true)
				{
					++index;
					continue;
				}

				good = false;
				break;
			}

			if (good)
			{
				return call;
			}
		}

		throw new DSubstituteException("Find Failed: %s".format(signature));
	}

	public E Invoke(E)(string signature, IDynamic[] args...)
	{
		_record ~= new Record(signature, args);

		try
		{
			auto call = Find(signature, args);
			auto post = call.PostCondition();
			auto value = post.Value();
			auto result = (cast(DynamicValue!(E)) value).Value();

			call.IncreaseCallCount();
			return result;
		}
		catch (DSubstituteException)
		{
			E value;

			return value;
		}
	}

	public void Invoke(string signature, IDynamic[] args...)
	{
		_record ~= new Record(signature, args);

		try
		{
			auto call = Find(signature, args);
			auto post = call.PostCondition();
			auto value = post.Value();

			call.IncreaseCallCount();
		}
		catch (DSubstituteException)
		{
		}
	}

	mixin(Gen());

	public static string Gen()
	{
		string method = "";

		auto doJoin = (string[] array) {
			if (array.length == 0)
			{
				return "";
			}

			return ", " ~ array.join(", ");
		};

		foreach (name; __traits(allMembers, T))
		{
			foreach (t; __traits(getVirtualMethods, T, name))
			{
				string[] parameters;
				string[] xyz;
				auto p = 0;

				foreach (type; ParameterTypeTuple!(t))
				{
					parameters ~= "%s p%d".format(fullyQualifiedName!(type), p);
					xyz ~= "new DynamicValue!(%s)(p%s)".format(fullyQualifiedName!(type),
							to!string(p));
					++p;
				}

				string signature = "%s %s(%s)".format(fullyQualifiedName!(ReturnType!(t)),
						name, parameters.join(", "));

				// Normal Method
				method ~= "public %s\n".format(signature);
				method ~= "{\n";
				method ~= "\tstring signature = \"%s\";\n".format(signature);
				method ~= "\n";

				if (ReturnType!(t).stringof != "void")
				{
					method ~= "\treturn Invoke!(%s)(signature%s);\n".format(
							fullyQualifiedName!(ReturnType!(t)), doJoin(xyz));
				}
				else
				{
					method ~= "\tInvoke(signature%s);\n".format(doJoin(xyz));
				}
				method ~= "}\n";
				method ~= "\n";
			}
		}

		return method;
	}
}

public static class Reflection
{
	public static string[] Types(T)(T method)
	{
		string[] types;

		foreach (type; ParameterTypeTuple!(method))
		{
			types ~= type.stringof;
		}

		return types;
	}

	public static string[] StorageClasses(T)(T method)
	{
		string[] storageClasses;
		string code;

		foreach (storageClass; ParameterStorageClassTuple!(method))
		{
			code = "";

			static if (storageClass == ParameterStorageClass.scope_)
			{
				code ~= "scope ";
			}

			static if (storageClass == ParameterStorageClass.lazy_)
			{
				code ~= "lazy ";
			}

			static if (storageClass == ParameterStorageClass.out_)
			{
				code ~= "out ";
			}

			static if (storageClass == ParameterStorageClass.ref_)
			{
				code ~= "ref ";
			}

			storageClasses ~= code;
		}
		
		return storageClasses;
	}
}

public static class Substitute
{
	public static Mock!(T) For(T)()
	{
		return new Mock!(T);
	}
}
