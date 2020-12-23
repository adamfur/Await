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
import synchronization.semaphore;
import synchronization.mutex;
import synchronization.fastmutex;
import synchronization.barrier;
import synchronization.lock;
import std.format;

void main()
{
	scope stateTracker = new StateTracker(new TimerQueue());
	auto count = 0;
	auto thread = 0;

	// stateTracker.Execute(() {
	stateTracker.Forever(() {
		auto lock = new NewSempahore(3);
		auto barrier = new Barrier(4);
		void delegate() func = () {
			auto copy = thread++;
			synchronized (lock)
			{
				++count;
				writeln("%d: hello (1): %d".format(copy, count));
				Task.Yield();
				--count;
			}
			barrier.Await();
			writeln("%d: hello (2)".format(copy));
		};

		auto t1 = Task.Run(func);
		auto t2 = Task.Run(func);
		auto t3 = Task.Run(func);
		auto t4 = Task.Run(func);

		Task.Delay(250.msecs).Await();
		// t1.Await();
		// t2.Await();
		// t3.Await();
		// t4.Await();

		writeln("... done");
		stateTracker.Shutdown();
	});
}

void main3()
{
	scope stateTracker = new StateTracker(new TimerQueue());

	stateTracker.Forever(() {
		writeln("...");
		// scope lock = new Semaphore(2);
		// scope lock = new Mutex();
		scope lock = new FastMutex();
		// scope lock = new Barrier(2);

		auto tx1 = Task.Run(() {
			lock.Await();
			Task.Delay(1.seconds).Await(); //
			writeln("1");
			lock.Release();
		});

		auto tx2 = Task.Run(() {
			lock.Await();
			Task.Delay(1.seconds).Await(); //
			writeln("2");
			lock.Release();
		});

		auto tx3 = Task.Run(() {
			Task.Delay(1.seconds).Await(); //
			lock.Await();
			writeln("3");
			lock.Release();
		});

		auto tx4 = Task.Run(() {
			Task.Delay(1.seconds).Await(); //
			lock.Await();
			writeln("4");
			lock.Release();
		});

		tx1.Await();
		tx2.Await();
		tx3.Await();
		tx4.Await();
	});
}

void main2()
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
