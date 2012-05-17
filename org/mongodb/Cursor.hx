package org.mongodb;

class Cursor
{

	public function new(collection:String)
	{
		this.collection = collection;
	}

	public function hasNext():Bool
	{
		return false;
	}

	public function next():Dynamic
	{
		return {};
	}

	// fill the cursor
	/*private function getMore(number:Int, cursor:Int)
	{
		var out:BytesOutput = new BytesOutput();
		out.writeInt32(Int32.ofInt(0)); // reserved
		out.writeString(name);
		out.writeByte(0x00); // string terminator
		out.writeInt32(Int32.ofInt(number));

		// TODO: write cursor
//		out.writeBytes(cursor, 0, 16);

		request(OP_GETMORE, out.getBytes());
	}*/

	public var collection(default, null):String;

}