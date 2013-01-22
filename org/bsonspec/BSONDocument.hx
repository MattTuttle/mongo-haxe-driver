package org.bsonspec;

/**
 * This class use String for key and Dynamic for storing
 * the value part. The $ is permit for encoding mongoDB query.
 * 
 * Example
 * 
 * var doc:BSONDocument = BSONDocument.create()
 *			.append( "_id", new ObjectID() )
 *			.append( "title", 'My awesome post' )
 *			.append( "hol", ['first', 2, Date.now()] )
 *			.append( "options", BSONDocument.create()
 *				.append( "delay", 1.565 )
 *				.append( "test", true )
 *				)
 *			.append( "monkey", null )
 *			.append( "$in", [1,3] );
 * 
 * BSON.encode( doc );
 * 
 * @author Andre Lacasse
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
		var iterator:Iterator<String> = _keysValues.keys();
		var s:StringBuf = new StringBuf();
		s.add( "{" );

		for ( key in iterator )
		{
			s.add( " " + key + " => " + _keysValues.get( key ) );
			
			if ( iterator.hasNext() ) s.add( "," );
		}
		
		s.add( "}" );
		
		return s.toString();
	}
	
}