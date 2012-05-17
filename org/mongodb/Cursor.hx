package org.mongodb;

import haxe.Int64;

class Cursor
{

	public function new(collection:String)
	{
		this.collection = collection;
		//Protocol.getMore(collection, cursorId);
	}

	public function hasNext():Bool
	{
		return false;
	}

	public function next():Dynamic
	{
		return {};
	}

	private var collection:String;
	private var cursorId:Int64;

}