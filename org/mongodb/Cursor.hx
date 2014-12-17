package org.mongodb;

import haxe.Int64;

class Cursor
{
	public function new(collection:Collection, query:Dynamic, returnFields:Dynamic, skip:Int, number:Int)
	{
		this.collection = collection;
		this.query = query;
		this.returnFields = returnFields;
		noSkip = skip;
		noReturn = number;
		noLimit = 0;

		cnx = collection.db.mongo.cnx;
		finished = false;
		documents = null;  // null marks that the query was not yet submitted
	}

	private inline function checkResponse():Bool
	{
		cursorId = cnx.response(documents);
		if (documents.length == 0)
		{
			finished = true;
			if (cursorId != null)
			{
				cnx.killCursors([cursorId]);
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
		if (documents == null)
		{
			// no query submitted yet
			documents = [];
			// trace(query);
			cnx.query(collection.fullname, query, returnFields, noSkip, noReturn);
			checkResponse();
		}

		// we've depleted the cursor
		if (finished) return false;

		if (documents.length > 0)
		{
			return true;
		}
		else if (noLimit == 0 || noLimit != noReturn)
		{
			cnx.getMore(collection.fullname, cursorId);
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
	
	public function limit(number:Int):Cursor
	{
		if (documents != null)
			throw "Cursor.limit() must be used before retrieving anything";
		noReturn = noLimit = number;
		return this;
	}

	public function skip(number:Int):Cursor
	{
		if (documents != null)
			throw "Cursor.skip() must be used before retrieving anything";
		noSkip = number;
		return this;
	}

	public function sort(spec:Dynamic):Cursor
	{
		if (documents != null)
			throw "Cursor.sort() must be used before retrieving anything";
		addQueryElement("$orderby", spec);
		return this;
	}

	public function toArray():Array<Dynamic>
	{
		if (documents != null)
			throw "Cursor.toArray() must be used before retrieving anything";
		var ret = [];
		for (x in this)
			ret.push(x);
		return ret;
	}

	private function addQueryElement(name:String, el:Dynamic):Void
	{
		if (query == null)
			query = {};
		if (!Reflect.hasField(query, "$query"))
			query = { "$query" : query };
		Reflect.setField(query, name, el);
	}

	public var collection(default, null):Collection;
	private var query:Dynamic;
	private var returnFields:Dynamic;
	private var noSkip:Int;
	private var noReturn:Int;
	private var noLimit:Int;

	private var cnx:Protocol;
	private var cursorId:Int64;
	private var documents:Array<Dynamic>;
	private var finished:Bool;
}

