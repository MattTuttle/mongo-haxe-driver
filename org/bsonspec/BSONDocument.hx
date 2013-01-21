package org.bsonspec;

/**
 * ...
 * @author 
 */

class BSONDocument
{
	private var _keysValues:Hash<Dynamic>;
	
	public function new() 
	{
		_keysValues = new Hash<Dynamic>();
	}
	
	public static function create():BSONDocument
	{
		return new BSONDocument();
	}
	
	public function append(key:String, value:Dynamic):BSONDocument 
	{
		_keysValues.set(key, value);
		
		return this;
	}
	
	public function keys():Iterator<String>
	{
		return _keysValues.keys();
	}
	
	public function get( k:String ):Dynamic 
	{
		return _keysValues.get( k );
	}
	
	public function toString():String
	{
		return "";
	}
	
}