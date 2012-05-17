package org.bsonspec;

import haxe.io.Bytes;
import haxe.io.Input;

class BSON
{

	public inline static function encode(o:Dynamic):Bytes {
		return new BSONEncoder(o).getBytes();
	}

	public inline static function decode(i:Input):Dynamic {
		return new BSONDecoder(i).getObject();
	}

}