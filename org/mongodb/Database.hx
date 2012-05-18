package org.mongodb;

class Database implements Dynamic<Collection>
{
	public function new(name:String)
	{
		this.name = name;
		this.cmd = new Collection("$cmd", this);
	}

	public inline function getCollection(name:String):Collection
	{
		return new Collection(name, this);
	}

	public function resolve(name:String):Collection
	{
		return getCollection(name);
	}

	public function getCollectionNames():Array<String>
	{
		var collections = getCollection("system.namespaces").find({
			options: { '$exists': 1 } // find namespaces where options exists
		});

		var names = new Array<String>();
		for (collection in collections)
		{
			var name:String = collection.name;
			names.push(name.substr(this.name.length + 1));
		}
		return names;
	}

	public function createCollection(collection:String):Dynamic
	{
		return runCommand({create: collection});
	}

	public function dropCollection(collection:String)
	{
		runCommand({drop: collection});
	}

	public function renameCollection(from:String, to:String)
	{
		runCommand({renameCollection: from, to: to});
	}

	public function drop()
	{
		runCommand({dropDatabase: 1});
	}

	public inline function runCommand(command:Dynamic):Dynamic
	{
		return cmd.findOne(command);
	}

	public var name(default, null):String;
	private var cmd:Collection;
}