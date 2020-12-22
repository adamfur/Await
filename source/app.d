import statetracker;
import std.stdio;
import task;
import exception;

void main()
{
	scope stateTracker = new StateTracker();

	stateTracker.Execute(() {
		writeln("Hello world (1)");
		Task.Run(() => writeln("Hello world (2)")).Await();
		writeln("Hello world (3)");
		Task.Run(() => writeln("Hello world (4)")).Await();
		auto t1 = Task.Run(() => writeln("Hello world (6)"));
		auto t7 = Task.Run(() => writeln("Hello world (7)"));
		writeln("Hello world (5)");
		t7.Await();
		t1.Await();

		// Task.Run(() {
		// 	throw new TaskCancellationException(""); //
		// }).Await();
	});
}
