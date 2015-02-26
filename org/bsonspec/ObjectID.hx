package org.bsonspec;

import haxe.io.Input;
import haxe.io.Bytes;
import haxe.io.BytesOutput;

class ObjectID
{

	public function new(?input:Input)
	{
		if (input == null)
		{
			// generate a new id
			var out:BytesOutput = new BytesOutput();
			
			// Endianness: https://github.com/mongodb/mongo/blob/master/src/mongo/bson/oid.h
			out.bigEndian = true;
#if haxe3
			out.writeInt32(Math.floor(Date.now().getTime() / 1000)); // seconds
#else
			out.writeInt32(haxe.Int32.ofInt(Math.floor(Date.now().getTime() / 1000))); // seconds
#end
			out.writeBytes(machine, 0, 3);
			out.writeUInt16(pid);
			out.writeUInt24(sequence++);
			if (sequence > 0xFFFFFF) sequence = 0;
			bytes = out.getBytes();
		}
		else
		{
			bytes = Bytes.alloc(12);
			input.readBytes(bytes, 0, 12);
		}
	}

	public function toString():String
	{
		return 'ObjectID("' + bytes.toHex() + '")';
	}

	public var bytes(default, null):Bytes;
	private static var sequence:Int = Std.random(0x1000000);

	// machine host name
#if (neko || php || cpp)
	private static var machine:Bytes = haxe.crypto.Md5.make(Bytes.ofString(sys.net.Host.localhost()));
#else
	private static var machine:Bytes = Bytes.ofString("flash");
#end
	private static var pid = Std.random(65536);

}