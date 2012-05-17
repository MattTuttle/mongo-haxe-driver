package org.mongodb;

import haxe.Int32;
import haxe.io.Bytes;
import haxe.io.BytesOutput;
import haxe.io.Output;
import org.bsonspec.BSON;

class Collection
{
	public function new(name:String, output:Output)
	{
		requestId = 0;

		this.name = name;
		this.out = output;
	}

	private inline function request(opcode:Int, data:Bytes, ?responseTo:Int = 0):Int
	{
		out.writeInt32(Int32.ofInt(data.length + 16));
		out.writeInt32(Int32.ofInt(requestId));
		out.writeInt32(Int32.ofInt(responseTo));
		out.writeInt32(Int32.ofInt(opcode));
		out.writeBytes(data, 0, data.length);
		out.flush();
		return requestId++;
	}

	public function message(msg:String)
	{
		trace("deprecated");
		var out:BytesOutput = new BytesOutput();
		out.writeString(msg);
		out.writeByte(0x00);

		request(OP_MSG, out.getBytes());
	}

	public function find(?query:Dynamic, skip:Int = 0, number:Int = 50, ?returnFields:Dynamic):Cursor
	{
		var out:BytesOutput = new BytesOutput();
		out.writeInt32(Int32.ofInt(0)); // TODO: flags
		out.writeString(name);
		out.writeByte(0x00); // string terminator
		out.writeInt32(Int32.ofInt(skip));
		out.writeInt32(Int32.ofInt(number));
		if (query != null) {
			writeDocument(out, query);
		}

		request(OP_QUERY, out.getBytes());
		return new Cursor(name);
	}

	public function insert(fields:Dynamic)
	{
		var out:BytesOutput = new BytesOutput();
		out.writeInt32(Int32.ofInt(0)); // TODO: flags
		out.writeString(name);
		out.writeByte(0x00); // string terminator

		writeDocument(out, fields);

		// write request
		request(OP_INSERT, out.getBytes());
	}

	public function update(select:Dynamic, fields:Dynamic)
	{
		var out:BytesOutput = new BytesOutput();
		out.writeInt32(Int32.ofInt(0)); // reserved
		out.writeString(name);
		out.writeByte(0x00); // string terminator
		out.writeInt32(Int32.ofInt(0)); // TODO: flags

		writeDocument(out, select);
		writeDocument(out, fields);

		// write request
		request(OP_UPDATE, out.getBytes());
	}

	public function remove(select:Dynamic)
	{
		var out:BytesOutput = new BytesOutput();
		out.writeInt32(Int32.ofInt(0)); // reserved
		out.writeString(name);
		out.writeByte(0x00); // string terminator
		out.writeInt32(Int32.ofInt(0)); // TODO: flags
		writeDocument(out, select);

		request(OP_DELETE, out.getBytes());
	}

	private inline function writeDocument(out:BytesOutput, data:Dynamic)
	{
		var d = BSON.encode(data);
		out.writeBytes(d, 0, d.length);
	}

	public var name(default, null):String;
	private var requestId:Int;
	private var out:Output;

	private inline static var OP_REPLY        = 1; // used by server
	private inline static var OP_MSG          = 1000; // not used
	private inline static var OP_UPDATE       = 2001;
	private inline static var OP_INSERT       = 2002;
	private inline static var OP_QUERY        = 2004;
	private inline static var OP_GETMORE      = 2005;
	private inline static var OP_DELETE       = 2006;
	private inline static var OP_KILL_CURSORS = 2007;
}