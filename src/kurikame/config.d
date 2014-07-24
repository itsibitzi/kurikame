module kurikame.config;

import kurikame.scripts;
import std.algorithm;
import std.c.stdlib;
import std.conv;
import std.file;
import std.string;

// Configuration is loaded from (KURIKAME_HOME ~ "/etc/config")
final abstract class Config
{
static:
	private:
		ushort   port;
		string   nick;
		string   server;
		string[] channels;

		string   homeDirectory;

		string[] admins;

		static this()
		{
			// Need a place to look for the config files, target server and what not.
			homeDirectory = to!string(getenv("KURIKAME_HOME")).dup;

			auto lines = readText(homeDirectory ~ "/etc/config").splitLines();

			foreach (string line ; lines)
			{
				assignConfigLine(line);
			}
		}

		void assignConfigLine(string line)
		{
			auto equalsIndex = line.indexOf('=');

			string key = line[0 .. equalsIndex];
			string value = line[equalsIndex + 1 .. line.length];

			switch (key)
			{
				case ("port"):
					port = to!ushort(value);
					break;
				case ("server"):
					server = value;
					break;
				case ("channels"):
					channels = split(value, ',');
					break;
				case ("nick"):
					nick = value;
					break;
				case ("admins"):
					admins = split(value, ',');
					break;
				default:
					throw new Exception("Invalid config key: " ~ key);
					break;
			}
		}

	public:
		@property auto Nick()
		{
			return nick;
		}

		@property auto Port()
		{
			return port;
		}

		@property auto Server()
		{
			return server;
		}

		@property auto Channels()
		{
			return channels;
		}

		@property auto Admins()
		{
			return admins;
		}
}


unittest
{
	assert(equal(split("a,b,c", ','), ["a", "b", "c"]));
}
