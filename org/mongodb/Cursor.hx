package org.mongodb;

import haxe.Int64;

class Cursor
{

	public function new(collection:String)
	{
		this.collection = collection;
		this.finished = false;
		this.documents = new Array<Dynamic>();

		checkResponse();
	}

	private inline function checkResponse():Bool
	{
		cursorId = Protocol.response(documents);
		if (documents.length == 0)
		{
			finished = true;
			if (cursorId != null)
			{
				Protocol.killCursors([cursorId]);
			}
			return false;
		}
		else
		{
			return true;
		}
	}

	public function hasNext():Bool
	{
		// we've depleted the cursor
		if (finished) return false;

		if (documents.length > 0)
		{
			return true;
		}
		else
		{
			Protocol.getMore(collection, cursorId);
			if (checkResponse())
			{
				return true;
			}
		}
		return false;
	}

	public function next():Dynamic
	{
		return documents.shift();
	}

	private var collection:String;
	private var cursorId:Int64;
	private var documents:Array<Dynamic>;
	private var finished:Bool;

}