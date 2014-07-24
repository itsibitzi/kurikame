module kurikame.message;

import kurikame.log;
import std.algorithm;
import std.conv;
import std.regex;
import std.string;

final class Message
{
	private:
		static immutable string MESSAGE_REGEX = "^(?:[:](\\S+) )?(\\S+)(?: (?!:)(.+?))?(?: [:](.+))?$";

		string prefix;
		string type;
		string destination;
		string messageBody;

	public:
		this(string input)
		{
			debug
			{
				log(input);
			}

			auto r = regex(MESSAGE_REGEX, "g");
			auto m = match(input, r);

			// captures[0] contains the whole message
			prefix      = m.captures[1];
			type        = m.captures[2];
			destination = m.captures[3];
			messageBody = m.captures[4];
		}

		@property auto Prefix() const
		{
			return prefix;
		}

		@property auto Type() const
		{
			return type;
		}

		@property auto Destination() const
		{
			return destination;
		}

		@property auto MessageBody() const
		{
			return messageBody;
		}
}

final abstract class MessageType
{
static:
immutable:
	public:
		@property string Ping()
		{
			return "PING";
		}

		@property string PrivateMessage()
		{
			return "PRIVMSG";
		}

		// Add as necessary
}
