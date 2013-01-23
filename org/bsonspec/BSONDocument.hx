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
	private var _nodes:List<BSONDocumentNode>;
	
	public function new() 
	{
		
		_nodes = new List<BSONDocumentNode>();
	}
	
	public static function create():BSONDocument
	{
		return new BSONDocument();
	}
	
	public function append(key:String, value:Dynamic):BSONDocument 
	{
		_nodes.add( new BSONDocumentNode( key, value ) ); 
		
		return this;
	}
	
	public function nodes():Iterator<BSONDocumentNode>
	{
		return _nodes.iterator();
	}
	
	public function toString():String
	{
		var iterator:Iterator<BSONDocumentNode> = _nodes.iterator();
		var s:StringBuf = new StringBuf();
		s.add( "{" );

		for ( node in iterator )
		{
			s.add( " " + node.key + " : " + node.data );
			
			if ( iterator.hasNext() ) s.add( "," );
		}
		
		s.add( "}" );
		
		return s.toString();
	}
	
}
