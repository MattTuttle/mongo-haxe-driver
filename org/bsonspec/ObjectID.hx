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
#if haxe3
			out.writeInt32(Math.floor(Date.now().getTime() / 1000)); // seconds
#else
			out.writeInt32(haxe.Int32.ofInt(Math.floor(Date.now().getTime() / 1000))); // seconds
#end
			out.writeBytes(machine, 0, 3); // machine
			out.writeInt16(Math.floor(32768 * Math.random())); // pid
			out.writeInt24(sequence--);
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
	private static var sequence:Int = 0;

	// machine host name
#if (neko || php || cpp)
	private static var machine:Bytes = Bytes.ofString(sys.net.Host.localhost());
#else
	private static var machine:Bytes = Bytes.ofString("flash");
#end

}