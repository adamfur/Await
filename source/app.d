import core.thread : Fiber;
import core.time;
import dsubstitute.core;
import exception;
import job;
import statetracker;
import std.datetime.systime;
import std.stdio;
import task;
import taskqueue;
import taskvalue;
import timer.timerqueue;
import xunit.core;

void main()
{
	scope stateTracker = new StateTracker(new TimerQueue());

	stateTracker.Forever(() {
		writeln("Hello world (1)");
		Task.Run(() => writeln("Hello world (2)")).Await();
		writeln("Hello world (3)");
		Task.Run(() => writeln("Hello world (4)")).Await();
		auto t1 = Task.Run(() => writeln("Hello world (6)"));
		auto t7 = Task.Run(() => writeln("Hello world (7)"));
		writeln("Hello world (5)");
		t7.Await();
		t1.Await();

		auto tx1 = Task.Run(() {
			Task.Delay(3.seconds).Await(); //
			writeln("3");
		});

		auto tx2 = Task.Run(() {
			Task.Delay(2.seconds).Await(); //
			writeln("2");
		});

		auto tx3 = Task.Run(() {
			Task.Delay(1.seconds).Await(); //
			writeln("1");
		});

		tx3.Await();
		tx2.Await();
		tx1.Await();

		writeln("done...");
	});
}
