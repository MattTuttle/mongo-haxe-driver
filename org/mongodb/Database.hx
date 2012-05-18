package org.mongodb;

class Database implements Dynamic<Collection>
{
	public function new(name:String)
	{
		this.name = name;
		this.cmd = new Collection("$cmd", name);
	}

	public inline function getCollection(name:String):Collection
	{
		return new Collection(name, this.name);
	}

	public function resolve(name:String):Collection
	{
		return getCollection(name);
	}

	public function createCollection(collection:String):Dynamic
	{
		return runCommand({create: collection});
	}

	public function dropCollection(collection:String)
	{
		runCommand({drop: collection});
	}

	public function drop()
	{
		runCommand({dropDatabase: 1});
	}

	public inline function runCommand(command:Dynamic)
	{
		cmd.findOne(command);
	}

	public var name(default, null):String;
	private var cmd:Collection;
}