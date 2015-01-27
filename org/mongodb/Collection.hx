package org.mongodb;

class Collection
{
	public function new(name:String, db:Database)
	{
		this.name = name;
		this.fullname = db.name + "." + name;
		this.db = db;
		this.cnx = db.mongo.cnx;
	}

	public inline function find(?query:Dynamic, ?returnFields:Dynamic, skip:Int = 0, number:Int = 0):Cursor<Dynamic>
	{
		return new Cursor(this, query, returnFields, skip, number);
	}

	public inline function findOne(?query:Dynamic, ?returnFields:Dynamic):Dynamic
	{
		cnx.query(fullname, query, returnFields, 0, -1);
		return cnx.getOne();
	}

	public inline function insert(fields:Dynamic):Void
	{
		cnx.insert(fullname, fields);
	}

	public inline function update(select:Dynamic, fields:Dynamic, ?upsert:Bool, ?multi:Bool):Void
	{
		var flags = 0x0 | (upsert ? 0x1 : 0) | (multi ? 0x2 : 0);
		cnx.update(fullname, select, fields, flags);
	}

	public inline function remove(?select:Dynamic):Void
	{
		cnx.remove(fullname, select);
	}

	public inline function create():Void { db.createCollection(name); }
	public inline function drop():Void { db.dropCollection(name); }
	public inline function rename(to:String):Void { db.renameCollection(name, to); }

	public function getIndexes():Cursor<Dynamic>
	{
		return new Cursor(db.getCollection("system.indexes"), { ns : fullname }, null, 0, 0);
	}

	public function ensureIndex(keyPattern:Dynamic, ?options:Dynamic):Void
	{
		// TODO: remove when name is deprecated
		var nameList = new List<String>();
		for (field in Reflect.fields(keyPattern))
		{
			nameList.add(field + "_" + Reflect.field(keyPattern, field));
		}
		var name = nameList.join("_");

		if (options == null)
		{
			options = { name: name, ns: fullname, key: keyPattern };
		}
		else
		{
			Reflect.setField(options, "name", name);
			Reflect.setField(options, "ns", fullname);
			Reflect.setField(options, "key", keyPattern);
		}

		cnx.insert(db.name + ".system.indexes", options);
	}

	public function dropIndexes():Void
	{
		db.runCommand({dropIndexes: name, index: '*'});
	}

	public function dropIndex(nameOrPattern:Dynamic):Void
	{
		db.runCommand({dropIndexes: name, index: nameOrPattern});
	}

	public function reIndex():Void
	{
		db.runCommand({reIndex: name});
	}

	public inline function count():Int
	{
		var result = db.runCommand({count: name});
		return result.n;
	}

	public inline function distinct(key:String, ?query:Dynamic):Array<Dynamic>
	{
		var cmd:{ distinct:String, key:String, ?query:Dynamic } = { distinct: name, key: key };
		if (query != null)
			cmd.query = query;
		var result = db.runCommand(cmd);
		return result.values;
	}

	public var fullname(default, null):String;
	public var name(default, null):String;
	public var db(default, null):Database;
	private var cnx:Protocol;
}

