package org.mongodb;

import sys.net.Socket;

class Database implements Dynamic<Collection>
{
	public function new(name:String, socket:Socket)
	{
		this.name = name;
		this.socket = socket;
	}

	public inline function getCollection(name:String):Collection
	{
		return new Collection(name, socket.output);
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
	private var socket:Socket;
}