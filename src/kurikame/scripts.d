module kurikame.scripts;

import kurikame.ircsocket;
import kurikame.log;
import kurikame.message;
import std.algorithm;
import std.string;

public void loadScripts(IrcSocket socket)
{
	scripts ~= new EchoScript(socket);

	// load up lua ;3
}

public void processWithScripts(Message message)
{
	foreach (Script s; scripts)
	{
		if(s.Process(message))
		{
			break;
		}
	}
}

private Script[] scripts;

// Base class of scripts
private abstract class Script
{
	protected:
		IrcSocket socket;

		// Maybe this is a bad idea?
		@property abstract string keyword();
		@property abstract bool adminOnly();

		abstract void doWork(Message message);

	public:
		this(IrcSocket socket)
		{
			this.socket = socket;
		}

		bool Process(Message message)
		{
			if (message.MessageBody.indexOf(keyword) == 0)
			{
				doWork(message);
				return true;
			}
			return false;
		}
}

// TODO : Add lua script support

// Any hardcoded message scripts can be added below
private class EchoScript : Script
{
	protected:
		@property override string keyword()
		{
			return "kuriecho";
		}

		@property override bool adminOnly()
		{
			return false;
		}

		override void doWork(Message message)
		{
			if (message.Type == MessageType.PrivateMessage)
			{
				socket.SendMessage(message.Destination, message.MessageBody);
			}
		}
	public:
		this(IrcSocket socket)
		{
			super(socket);
		}
}

