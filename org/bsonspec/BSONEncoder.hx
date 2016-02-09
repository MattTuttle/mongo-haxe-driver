package org.bsonspec;

import haxe.Int64;
import haxe.io.Bytes;
import haxe.io.BytesOutput;

class BSONEncoder
{

	public function new(o:Dynamic)
	{
		// base object must have key/value pairs
		if ( !Std.is( o, BSONDocument ) && !Type.typeof(o).match(TObject | TClass(_)))
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

		switch( Type.typeof(value) )
		{
			case TNull:
				writeHeader(out, key, 0x0A);

			case TInt:
				writeHeader(out, key, 0x10);
				out.writeInt32(#if haxe3 value #else haxe.Int32.ofInt(value) #end);

			case TFloat:
				writeHeader(out, key, 0x01);
				out.writeDouble(value);

			case TBool:
				writeHeader(out, key, 0x08);
				out.writeByte( value ? 0x01 : 0x00 );

			case TClass(String):
				writeHeader(out, key, 0x02);
				writeString(out, value);

			case TClass(Bytes):
				writeHeader(out, key, 0x05);
				out.writeInt32(value.length);
				out.writeByte(0x00); // generic
				out.writeBytes(value, 0, value.length);


			#if (haxe_ver < 3.2)

			case TClass(Int64):
				writeHeader(out, key, 0x12);
				out.writeInt32(Int64.getLow(value));
				out.writeInt32(Int64.getHigh(value));

			case TClass(Date):
				var d64 = (value : MongoDate).getTimeInt64();
				writeHeader(out, key, 0x09);
				out.writeInt32(Int64.getLow(d64));
				out.writeInt32(Int64.getHigh(d64));

			#else

			case TClass(Date):
				var d64 = (value : MongoDate).getTimeInt64();
				writeHeader(out, key, 0x09);
				out.writeInt32(d64.low);
				out.writeInt32(d64.high);

			#end


			case TClass(Array):
				writeHeader(out, key, 0x04);
				bytes = arrayToBytes(value);
				out.writeInt32(#if haxe3 bytes.length + 4 #else haxe.Int32.ofInt(bytes.length + 4) #end);
				out.writeBytes(bytes, 0, bytes.length);

			case TClass(ObjectID):
				writeHeader(out, key, 0x07);
				out.writeBytes(value.bytes, 0, 12);

			case TClass(BSONDocument):
				writeHeader(out, key, 0x03);
				bytes = documentToBytes(value);
				out.writeInt32(#if haxe3 bytes.length + 4 #else haxe.Int32.ofInt(bytes.length + 4) #end);
				out.writeBytes(bytes, 0, bytes.length);

			default:
				#if (haxe_ver >= 3.2)
				if (Int64.is(value))
				{
					writeHeader(out, key, 0x12);
					out.writeInt32(value.low);
					out.writeInt32(value.high);
				}
				else
				#end
				if (Std.is(value, Dynamic)) // document/object
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
		}

		return out.getBytes();
	}

	private inline function writeString(out:BytesOutput, str:String):Void
	{
		var bytes = Bytes.ofString(str);
		out.writeInt32(#if haxe3 bytes.length + 1 #else haxe.Int32.ofInt(bytes.length + 1) #end);
		out.writeBytes(bytes, 0, bytes.length);
		out.writeByte(0x00); // terminator
	}

	private inline function writeHeader(out:BytesOutput, key:String, type:Int):Void
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
