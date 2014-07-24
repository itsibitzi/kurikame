module kurikame.main;

import core.thread;
import kurikame.config;
import kurikame.ircsocket;
import kurikame.log;
import kurikame.message;
import kurikame.scripts;
import std.conv;
import std.stdio;
import std.string;

void main()
{
	IrcSocket irc = new IrcSocket(Config.Server, Config.Port);
	scope (exit)
	{
		irc.Disconnect();
	}

	loadScripts(irc);

	irc.Connect();
	irc.Nick(Config.Nick);
	irc.User(Config.Nick, 0, "*", "kurikame bot");
	irc.Join(Config.Channels);

	while (irc.Connected)
	{
		Message message = new Message(irc.ReadLine());
		// First deal with pings.
		if (message.Type == MessageType.Ping)
		{
			irc.Pong(message.MessageBody);
		}

		// Can now pass off to scripts
		processWithScripts(message);
	}
}
