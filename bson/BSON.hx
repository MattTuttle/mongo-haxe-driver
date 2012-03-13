package bson;

import haxe.io.Bytes;

class BSON
{

	public inline static function encode(o:Dynamic):Bytes {
		return new BSONEncoder(o).getBytes();
	}

	public inline static function decode(b:Bytes):Dynamic {
		return new BSONDecoder(b).getObject();
	}

}