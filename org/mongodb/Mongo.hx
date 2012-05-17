package org.mongodb;

import sys.net.Socket;
import neko.net.Host;
import neko.io.File;

class Mongo implements Dynamic<Database>
{

	public function new(?host:String = "localhost", ?port:Int = 27017)
	{
		socket = new Socket();
		socket.connect(new Host(host), port);
	}

	public inline function getDB(name:String):Database
	{
		return new Database(name, socket);
	}

	public function resolve(name:String):Database
	{
		return getDB(name);
	}

	private var socket:Socket;

}
