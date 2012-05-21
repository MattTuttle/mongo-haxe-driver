package org.bsonspec;

import haxe.io.Input;
import haxe.io.Bytes;

class ObjectID
{

	public function new(input:Dynamic)
	{
		if (Std.is(input, Input))
		{
			bytes = Bytes.alloc(12);
			input.readBytes(bytes, 0, 12);
		}
		else
		{
			bytes = Bytes.ofString(input);
		}
	}

	public function toString():String
	{
		return 'ObjectID("' + bytes.toHex() + '")';
	}

	public var bytes(default, null):Bytes;

}