package org.mongodb;

import haxe.Int32;
import haxe.io.Bytes;
import haxe.io.BytesOutput;
import neko.net.Socket;
import neko.net.SocketOutput;
import neko.net.Host;
import neko.io.File;
import bson.BSON;

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
		requestId = 0;
	}

	public function init(hostname:String, port:Int)
	{
		socket = new Socket();
		socket.connect(new Host(hostname), port);
	}

	public function request(data:Bytes, opCode:Int)
	{
		var out:SocketOutput = socket.output;
		out.writeInt32(Int32.ofInt(data.length));
		out.writeInt32(Int32.ofInt(requestId));
//		out.writeInt32(responseTo);
		out.writeInt32(Int32.ofInt(opCode));
		requestId += 1;
	}

	public function find(name:String)
	{
//		request(OP_QUERY);
	}

	public function insert(name:String, data:Dynamic)
	{
		var out:BytesOutput = new BytesOutput();
		var bytes = BSON.encode(data);
		out.writeBytes(bytes, 0, bytes.length);
		request(out.getBytes(), OP_INSERT);
	}

	public static function main()
	{
		/*
		var db:Mongo = new Mongo();
		db.insert("users", {
			name: {
				first: "Phil",
				last: "Finkelstein"
			},
			age: 32
		});
		*/

		var object = {
			name: "Matt",
			date: {
				year: 1985,
				month: "August",
				day: 13
			},
			male: true,
			array: [
				"more",
				2,
				false
			]
		};

		var bytes:Bytes = BSON.encode(object);
		var result:Dynamic = BSON.decode(bytes);
		trace(result);
	}

	private var socket:Socket;
	private var requestId:Int;

	private static inline var OP_INSERT = 2002;
	private static inline var OP_QUERY = 2004;

}
