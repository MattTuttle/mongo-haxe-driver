package org.bsonspec;

import haxe.Int64;
import haxe.io.Bytes;
import haxe.io.BytesOutput;

class BSONEncoder
{

	public function new(o:Dynamic)
	{
		// base object must have key/value pairs
		if ( !Std.is( o, BSONDocument ) && Type.typeof(o) != Type.ValueType.TObject)
		{
			throw "Cannot convert a non-object to BSON";
		}

		var out:BytesOutput = new BytesOutput();
		bytes = objectToBytes(o);
		out.writeInt32(#if haxe3 bytes.length + 4 #else haxe.Int32.ofInt(bytes.length + 4) #end);
		out.writeBytes(bytes, 0, bytes.length);
//		out.writeByte(0x00);
		bytes = out.getBytes();
	}

	public function getBytes():Bytes
	{
		return bytes;
	}

	private function convertToBytes(key:String, value:Dynamic):Bytes
	{
		var out:BytesOutput = new BytesOutput();
		var bytes:Bytes;

		if (value == null)
		{
			writeHeader(out, key, 0x0A);
		}
		else if (Std.is(value, Bool))
		{
			writeHeader(out, key, 0x08);
			if (value == true)
				out.writeByte(0x01);
			else
				out.writeByte(0x00);
		}
		else if (Std.is(value, String))
		{
			writeHeader(out, key, 0x02);
			writeString(out, value);
		}
		else if (Std.is(value, Int))
		{
			writeHeader(out, key, 0x10);
			out.writeInt32(#if haxe3 value #else haxe.Int32.ofInt(value) #end);
		}
		else if (Std.is(value, Float))
		{
			writeHeader(out, key, 0x01);
			out.writeDouble(value);
		}
		else if (Std.is(value, Int64))
		{
			writeHeader(out, key, 0x12);
			out.writeInt32(Int64.getHigh(value));
			out.writeInt32(Int64.getLow(value));
		}
		else if (Std.is(value, Date))
		{
			writeHeader(out, key, 0x09);
			out.writeDouble(value.getTime());
		}
		else if (Std.is(value, Array))
		{
			writeHeader(out, key, 0x04);
			bytes = arrayToBytes(value);
			out.writeInt32(#if haxe3 bytes.length + 4 #else haxe.Int32.ofInt(bytes.length + 4) #end);
			out.writeBytes(bytes, 0, bytes.length);
		}
		else if (Std.is(value, ObjectID))
		{
			writeHeader(out, key, 0x07);
			out.writeBytes(value.bytes, 0, 12);
		}
		else if (Std.is(value, BSONDocument)) // document/object
		{
			writeHeader(out, key, 0x03);
			bytes = documentToBytes(value);
			out.writeInt32(#if haxe3 bytes.length + 4 #else haxe.Int32.ofInt(bytes.length + 4) #end);
			out.writeBytes(bytes, 0, bytes.length);
		}
		else if (Std.is(value, Dynamic)) // document/object
		{
			writeHeader(out, key, 0x03);
			bytes = objectToBytes(value);
			out.writeInt32(#if haxe3 bytes.length + 4 #else haxe.Int32.ofInt(bytes.length + 4) #end);
			out.writeBytes(bytes, 0, bytes.length);
		}
		else
		{
			trace("could not encode " + Std.string(value));
		}

		return out.getBytes();
	}

	private inline function writeString(out:BytesOutput, str:String)
	{
		out.writeInt32(#if haxe3 str.length + 1 #else haxe.Int32.ofInt(str.length + 1) #end);
		out.writeString(str);
		out.writeByte(0x00); // terminator
	}

	private inline function writeHeader(out:BytesOutput, key:String, type:Int)
	{
		out.writeByte(type);
		out.writeString(key);
		out.writeByte(0x00); // terminator
	}

	private function arrayToBytes(a:Array<Dynamic>):Bytes
	{
		var out:BytesOutput = new BytesOutput();
		var bytes:Bytes;

		for (i in 0...a.length)
		{
			bytes = convertToBytes(Std.string(i), a[i]);
			out.writeBytes(bytes, 0, bytes.length);
		}
		out.writeByte(0x00); // terminate array
		return out.getBytes();
	}

	private function objectToBytes(o:Dynamic):Bytes
	{
		if ( Std.is( o, BSONDocument ) )
		{
			return documentToBytes( o );
		}
		else
		{
			return dynamicToBytes( o );
		}
	}

	private function documentToBytes( o:BSONDocument ):Bytes
	{
		var out:BytesOutput = new BytesOutput();
		var bytes:Bytes;

		for ( node in o.nodes() )
		{
			bytes = convertToBytes( node.key, node.data );
			out.writeBytes(bytes, 0, bytes.length);
		}
		out.writeByte(0x00); // terminate object
		return out.getBytes();
	}

	private function dynamicToBytes(o:Dynamic):Bytes
	{
		var out:BytesOutput = new BytesOutput();
		var bytes:Bytes;

		// TODO: figure out ordering??
		for ( key in Reflect.fields(o) )
		{
			var value:Dynamic = Reflect.field(o, key);

			if ( ! Reflect.isFunction(value) )
			{
				bytes = convertToBytes(key, value);
				out.writeBytes(bytes, 0, bytes.length);
			}
		}
		out.writeByte(0x00); // terminate object
		return out.getBytes();
	}

	private var bytes:Bytes;

}