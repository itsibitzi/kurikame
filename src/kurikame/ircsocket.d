module kurikame.ircsocket;

import kurikame.config;
import kurikame.log;
import std.conv;
import std.socket;
import std.socketstream;
import std.string;

// IrcSockets limit a TcpSocket to only IRC functions
class IrcSocket
{
	private:
		ushort port;
		string host;

		TcpSocket    socket = null;
		SocketStream stream = null;

		void write(string message)
		{
			log(message);
			stream.writeString(message ~ "\r\n");
			stream.flush();
		}

	public:
		this(string host, ushort port)
		{
			this.host = host;
			this.port = port;
		}

		void Connect()
		{
			socket = new TcpSocket(new InternetAddress(host, port));
			stream = new SocketStream(socket);
		}

		void Join(string[] channels)
		{
			foreach (string channel; channels)
			{
				write("JOIN " ~ channel);
			}
		}

		void SendMessage(string target, string message)
		{
			write("PRIVMSG " ~ target ~ " :" ~ message);
		}

		void User(string username, uint mode, string unused, string realname)
		{
			write("USER " ~ [username, to!string(mode), unused, ":" ~ realname].join(" "));
		}

		void Leave(string channel)
		{

		}

		void LeaveAll()
		{

		}

		string ReadLine()
		{
			return to!string(stream.readLine()).chomp();
		}

		void Nick(string nick)
		{
			write("NICK " ~ nick);
		}

		void Pong(string server)
		{
			write("PONG " ~ server);
		}

		void Disconnect()
		{
			if (Connected)
			{
				socket.close();
				socket = null;
			}
		}

		@property bool Connected()
		{
			return socket !is null;
		}
}
