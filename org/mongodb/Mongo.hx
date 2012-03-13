package org.mongodb;

import haxe.io.Bytes;
import neko.net.Socket;
import neko.net.Host;

/*
enum MongoOpCodes
{
	REPLY(1), // only used by database
	MSG(1000),
	UPDATE(2001),
	INSERT(2002),
	QUERY(2004),
	GETMORE(2005),
	DELETE(2006),
	KILL_CURSORS(2007),

	public function new(id:Int) { _id = id; }

	public var id(getId, null);
	private function getId():Int { return _id; }

	private var _id:Int;
}
*/

class Mongo
{

	public function new(?host:String="localhost", ?port:Int=27017)
	{
		init(host, port);
	}

	public function init(hostname:String, port:Int)
	{
		socket = new Socket();
		socket.connect(new Host(hostname), port);
	}

	public function request(data:Bytes, opCode:Int)
	{
		var out:SocketOutput = socket.output;
		out.writeInt32(data.length);
		out.writeInt32(requestID);
		out.writeInt32(responseTo);
		out.writeInt32(opCode);
	}

	public function find(name:String)
	{
		writeHeader(2004);
	}

	public function insert(name:String, data:Dynamic)
	{

	}

	public static function main()
	{
		var db:Mongo = new Mongo();
		db.insert("users", "monkey = me");
	}

	private var socket:Socket;

	private static inline var OP_INSERT = 2002;
	private static inline var OP_QUERY = 2004;

}
