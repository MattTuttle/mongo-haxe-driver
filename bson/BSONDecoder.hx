package bson;

import haxe.Int32;
import haxe.io.Bytes;
import haxe.io.BytesInput;

class BSONDecoder
{

	public function new(bytes:Bytes)
	{
		var input:BytesInput = new BytesInput(bytes);
		var length = Int32.toInt(input.readInt32());
		object = readObject(input, length - 4);
	}

	public function getObject():Dynamic
	{
		return object;
	}

	public function readField(type:Int, input:BytesInput):Dynamic
	{
		var value:Dynamic = null;
		var key:String = input.readUntil(0x00); // read cstring
		var bytes = key.length + 1; // add null byte

		switch (type)
		{
			case 0x01: // double
				value = input.readDouble();
				bytes += 8;
			case 0x02: // string
				bytes += Int32.toInt(input.readInt32()) + 4;
				value = input.readUntil(0x00);
			case 0x03: // object
				var len = Int32.toInt(input.readInt32());
				value = readObject(input, len - 4);
				bytes += len;
			case 0x04: // array
				var len = Int32.toInt(input.readInt32());
				value = readArray(input, len - 4);
				bytes += len;
			case 0x05: // binary data
				var len = Int32.toInt(input.readInt32());
				var subtype = input.readByte();
				input.readBytes(value, 0, len);
				bytes += len + 5;
			case 0x06: // DBPointer
				throw "Deprecated: 0x06 undefined";
			case 0x07: // object id
				value = input.readString(12);
				bytes += 12;
			case 0x08: // boolean
				value = (input.readByte() == 1) ? true : false;
				bytes += 1;
			case 0x09: // utc datetime (int64)
				throw "Unimplemented: Timestamp";
			case 0x0A: // null
				value = null;
			case 0x0B: // regular expression
				throw "Unimplemented: Regex";
			case 0x0C: // DBPointer
				throw "Deprecated: 0x0C DBPointer";
			case 0x0D: // javascript
				bytes += Int32.toInt(input.readInt32()) + 4;
				value = input.readUntil(0x00);
			case 0x0E: // symbol
				bytes += Int32.toInt(input.readInt32()) + 4;
				value = input.readUntil(0x00);
			case 0x0F: // code w/ scope
				throw "Unimplemented: code w/ scope";
			case 0x10: // integer
				value = Int32.toInt(input.readInt32());
				bytes += 4;
			case 0x11: // timestamp
				throw "Unimplemented: Timestamp";
			case 0x12: // int64
				throw "Unimplemented: int64";
			case 0xFF: // min key
				value = "MIN";
			case 0x7F: // max key
				value = "MAX";
			default:
				throw "Unknown type " + type;
		}

		return { key:key, value:value, length:bytes };
	}

	public function readObject(input:BytesInput, length:Int):Dynamic
	{
		var object:Dynamic = {};
		while (length > 0)
		{
			var type:Int = input.readByte();
			length -= 1;
			if (type == 0x00) continue; // end of object
//			trace("type: " + type + " length: " + length);
			var field = readField(type, input);

			Reflect.setField(object, field.key, field.value);
			length -= field.length;
		}
		return object;
	}

	public function readArray(input:BytesInput, length:Int):Array<Dynamic>
	{
		var array:Array<Dynamic> = [];
		while (length > 0)
		{
			var type:Int = input.readByte();
			length -= 1;
			if (type == 0x00) continue; // end of array
//			trace("type: " + type + " length: " + length);
			var field = readField(type, input);

			array.insert(Std.parseInt(field.key), field.value);
			length -= field.length;
		}
		return array;
	}

	private var object:Dynamic;

}