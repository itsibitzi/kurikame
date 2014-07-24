module kurikame.log;

import std.stdio;

void log(string message)
{
	// Write to log, replace with perm store
	writeln(">> " ~ message);
}
