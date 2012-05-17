package org.mongodb;

class Database implements Dynamic<Collection>
{
	public function new(name:String)
	{
		this.name = name;
	}

	public inline function getCollection(name:String):Collection
	{
		return new Collection(name, this);
	}

	public function resolve(name:String):Collection
	{
		return getCollection(name);
	}

	public function createCollection(collection:String)
	{

	}

	public function dropCollection(collection:String)
	{

	}

	public var name(default, null):String;
}