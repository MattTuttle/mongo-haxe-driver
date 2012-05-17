package org.mongodb;

class Collection
{
	public function new(name:String, parent:Database)
	{
		this.name = name;
		this.db = parent;
	}

	public function find(?query:Dynamic, ?returnFields:Dynamic, skip:Int = 0, number:Int = 0):Cursor
	{
		Protocol.query(fullname, query, returnFields, skip, number);
		return new Cursor(fullname);
	}

	public function insert(fields:Dynamic)
	{
		Protocol.insert(fullname, fields);
	}

	public function update(select:Dynamic, fields:Dynamic)
	{
		Protocol.update(fullname, select, fields);
	}

	public function remove(select:Dynamic)
	{
		Protocol.remove(fullname, select);
	}

	public var fullname(getFullName, never):String;
	private function getFullName():String
	{
		return db.name + '.' + name;
	}

	public var name(default, null):String;

	private var db:Database;
}