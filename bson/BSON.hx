package bson;

import haxe.io.Bytes;
import neko.io.File;

class BSON
{

	public inline static function encode(o:Dynamic):Bytes {
		return new BSONEncoder(o).getBytes();
	}

	public inline static function decode(b:Bytes):Dynamic {
		return new BSONDecoder(b).getObject();
	}

	public static function main()
	{
		/*
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
		*/

		var fin = File.read("php.bson");
		var result:Dynamic = BSON.decode(fin.readAll());
		trace(result);
	}

}