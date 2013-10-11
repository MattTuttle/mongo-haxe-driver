package org.mongodb;

class Collection
{
	public function new(name:String, db:Database)
	{
		this.name = name;
		this.fullname = db.name + "." + name;
		this.db = db;
	}

	public inline function find(?query:Dynamic, ?returnFields:Dynamic, skip:Int = 0, number:Int = 0):Cursor
	{
		Protocol.query(fullname, query, returnFields, skip, number);
		return new Cursor(fullname);
	}

	public inline function findOne(?query:Dynamic, ?returnFields:Dynamic):Dynamic
	{
		Protocol.query(fullname, query, returnFields, 0, -1);
		return Protocol.getOne();
	}

	public inline function insert(fields:Dynamic):Void
	{
		Protocol.insert(fullname, fields);
	}

	public inline function update(select:Dynamic, fields:Dynamic, ?upsert:Bool, ?multi:Bool):Void
	{
		var flags = 0x0 | (upsert ? 0x1 : 0) | (multi ? 0x2 : 0);
		Protocol.update(fullname, select, fields, flags);
	}

	public inline function remove(?select:Dynamic):Void
	{
		Protocol.remove(fullname, select);
	}

	public inline function create():Void { db.createCollection(name); }
	public inline function drop():Void { db.dropCollection(name); }
	public inline function rename(to:String):Void { db.renameCollection(name, to); }

	public function getIndexes():Cursor
	{
		Protocol.query(db.name + ".system.indexes", {ns: fullname});
		return new Cursor(fullname);
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

		Protocol.insert(db.name + ".system.indexes", options);
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
	private var db:Database;

}