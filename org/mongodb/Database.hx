package org.mongodb;

import haxe.Md5;

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

	public function listCollections():Array<String>
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

	/**
	 * Adds a user to the database
	 * @param username the name of the user to add/update
	 * @param password the password to encrypt
	 */
	public function addUser(username:String, password:String)
	{
		var users = getCollection("system.users");

		var user = users.findOne({user: username});
		if (user == null)
		{
			user =  { user: username, pwd: "" };
		}
		user.pwd = Md5.encode(username + ":mongo:" + password);

		users.insert(user);
	}

	/**
	 * Authenticates with the server to gain access to the database
	 * @param username the user to login
	 * @param password the password to authenticate with
	 */
	public function login(username:String, password:String):Bool
	{
		var n = runCommand({getnonce: 1});
		if (n == null) return false; // command failed

#if neko
		// neko likes to reorder object fields due to hashing (patch on google code)
		// http://code.google.com/p/nekovm/issues/detail?id=11
		var a = runScript("function() { db.auth('" + username + "', '" + password + "'); }");
		trace("Warning: neko authentication is not secure");
#else
		var a = runCommand({
			authenticate: 1,
			user: username,
			nonce: n.nonce,
			key: Md5.encode(n.nonce + username + Md5.encode(username + ":mongo:" + password))
		});
#end

		return (Std.int(a.ok) == 1);
	}

	/**
	 * Deauthorizes usage of the database
	 * Note: other databases may still be authorized
	 */
	public inline function logout()
	{
		runCommand({logout: 1});
	}

	public inline function createCollection(collection:String):Collection
	{
		runCommand({create: collection});
		return getCollection(collection);
	}

	public inline function dropCollection(collection:String)
	{
		runCommand({drop: collection});
	}

	public inline function renameCollection(from:String, to:String)
	{
		runCommand({renameCollection: from, to: to});
	}

	public inline function drop()
	{
		runCommand({dropDatabase: 1});
	}

	public inline function runCommand(command:Dynamic):Dynamic
	{
		return cmd.findOne(command);
	}

	public inline function runScript(script:String):Dynamic
	{
		return cmd.findOne({eval: script});
	}

	public var name(default, null):String;
	private var cmd:Collection;
}