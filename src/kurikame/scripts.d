module kurikame.scripts;

import kurikame.config;
import kurikame.ircsocket;
import kurikame.log;
import kurikame.message;
import luad.all;
import std.algorithm;
import std.file;
import std.string;

private Script[] scripts;

public void initialLoadScripts(IrcSocket socket)
{
	scripts ~= new EchoScript(socket);
	loadLuaScripts(socket);
}

public void loadLuaScripts(IrcSocket socket)
{
	auto files = dirEntries(Config.ScriptsDirectory, SpanMode.breadth).filter!(entry => isFile(entry));

	foreach (string file; files)
	{
		// Unsafe ~ might just explode if there is a screwy script
		scripts ~= new LuaScript(socket, file);
	}
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

final class LuaScript : Script
{
	private:
		string key;
		bool admin;
		LuaFunction workFunction;

	protected:
		@property override string keyword()
		{
			return key;
		}

		@property override bool adminOnly()
		{
			return admin;
		}

		override void doWork(Message message)
		{
			if (message.Type == MessageType.PrivateMessage)
			{
				string value = workFunction.call!string(message.MessageBody);
				socket.SendMessage(message.Destination, value);
			}
		}

	public:
		this(IrcSocket socket, string luaFile)
		{
			super(socket);
			auto lua = new LuaState();
			lua.openLibs();
			lua.doFile(luaFile);

			key          = lua.get!string("keyword");
			admin        = lua.get!bool("adminOnly");
			workFunction = lua.get!LuaFunction("doWork");
		}
}

// Any hardcoded message scripts can be added below
private final class EchoScript : Script
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

