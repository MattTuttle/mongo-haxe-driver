package org.mongodb;

class Mongo implements Dynamic<Database>
{
	public function new(?host:String = "localhost", ?port:Int = 27017)
	{
		cnx = Protocol.open(host, port);
	}

	public inline function getDB(name:String):Database
	{
		return new Database(name, this);
	}

	public function resolve(name:String):Database
	{
		return getDB(name);
	}

	public function close() {
		cnx.close();
	}

	@:allow(org.mongodb.Collection)
	@:allow(org.mongodb.Cursor)
	private var cnx:Protocol;
}

