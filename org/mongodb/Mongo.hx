package org.mongodb;

import neko.io.File;

class Mongo implements Dynamic<Database>
{

	public function new(?host:String = "localhost", ?port:Int = 27017)
	{
		Protocol.connect(host, port);
	}

	public inline function getDB(name:String):Database
	{
		return new Database(name);
	}

	public function resolve(name:String):Database
	{
		return getDB(name);
	}

}
