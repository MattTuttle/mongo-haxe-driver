package org.mongodb;

import haxe.Int32;
import haxe.io.Bytes;
import haxe.io.BytesOutput;
import neko.net.Socket;
import neko.net.SocketOutput;
import neko.net.Host;
import neko.io.File;
import bson.BSON;

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

	public function request(opcode:Int, data:Bytes, ?responseTo:Int):Int
	{
		var out:SocketOutput = socket.output;
		out.writeInt32(Int32.ofInt(data.length + 16));
		out.writeInt32(Int32.ofInt(requestId));
		out.writeInt32(Int32.ofInt(responseTo));
		out.writeInt32(Int32.ofInt(opcode));
		out.writeBytes(data, 0, data.length);
		out.flush();
		return requestId++;
	}

	public function find(collection:String, skip:Int, number:Int, query:Dynamic, ?returnFields:Dynamic)
	{
		var out:BytesOutput = new BytesOutput();
		out.writeInt32(Int32.ofInt(0)); // TODO: flags
		out.writeString(collection);
		out.writeByte(0x00); // string terminator
		out.writeInt32(Int32.ofInt(skip));
		out.writeInt32(Int32.ofInt(number));
		writeDocument(out, query);
		if (query != null) {
			writeDocument(out, query);
		}

		request(OP_QUERY, out.getBytes());
	}

	public function insert(collection:String, fields:Dynamic)
	{
		var out:BytesOutput = new BytesOutput();
		out.writeInt32(Int32.ofInt(0)); // TODO: flags
		out.writeString(collection);
		out.writeByte(0x00); // string terminator

		writeDocument(out, fields);

		// write request
		request(OP_INSERT, out.getBytes());
	}

	public function update(collection:String, select:Dynamic, fields:Dynamic)
	{
		var out:BytesOutput = new BytesOutput();
		out.writeInt32(Int32.ofInt(0)); // reserved
		out.writeString(collection);
		out.writeByte(0x00); // string terminator
		out.writeInt32(Int32.ofInt(0)); // TODO: flags

		writeDocument(out, select);
		writeDocument(out, fields);

		// write request
		request(OP_UPDATE, out.getBytes());
	}

	public function getmore(collection:String, number:Int, cursor:Int)
	{
		var out:BytesOutput = new BytesOutput();
		out.writeInt32(Int32.ofInt(0)); // reserved
		out.writeString(collection);
		out.writeByte(0x00); // string terminator
		out.writeInt32(Int32.ofInt(number));

		// TODO: write cursor
//		out.writeBytes(cursor, 0, 16);

		request(OP_GETMORE, out.getBytes());
	}

	public function remove(collection:String, select:Dynamic)
	{
		var out:BytesOutput = new BytesOutput();
		out.writeInt32(Int32.ofInt(0)); // reserved
		out.writeString(collection);
		out.writeByte(0x00); // string terminator
		out.writeInt32(Int32.ofInt(0)); // TODO: flags
		writeDocument(out, select);

		request(OP_DELETE, out.getBytes());
	}

	public function message(msg:String)
	{
		var out:BytesOutput = new BytesOutput();
		out.writeString(msg);
		out.writeByte(0x00);

		request(OP_MSG, out.getBytes());
	}

	private inline function writeDocument(out:BytesOutput, data:Dynamic)
	{
		var d = BSON.encode(data);
		out.writeBytes(d, 0, d.length);
	}

	// test case
	public static function main()
	{
		/*
		var db:Mongo = new Mongo();
		db.message("Hi there");
		db.update("users", { _id: "matt" }, {
			name : {
				first: "Matt",
				last: "Tuttle"
			}
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

	private inline static var OP_REPLY        = 1; // used by server
	private inline static var OP_MSG          = 1000; // not used
	private inline static var OP_UPDATE       = 2001;
	private inline static var OP_INSERT       = 2002;
	private inline static var OP_QUERY        = 2004;
	private inline static var OP_GETMORE      = 2005;
	private inline static var OP_DELETE       = 2006;
	private inline static var OP_KILL_CURSORS = 2007;

}
