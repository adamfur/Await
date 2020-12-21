import std.stdio;
import statetracker;
import task;

void main()
{
	scope stateTracker = new StateTracker(() {
		//
		writeln("Hello world (1)");
		Task.Run(() => writeln("Hello world (2)")).Await();
		Task.Run(() => writeln("Hello world (3)")).Await();
	});

	stateTracker.Execute();
}
