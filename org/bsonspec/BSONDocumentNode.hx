package org.bsonspec;

/**
 * Class used by the BSONDocument class.
 * 
 * @author Andre Lacasse
 */
class BSONDocumentNode {
	public var key:String;
	public var data:Dynamic;
	
	public function new( k:String, d:Dynamic )
	{
		key = k;
		data = d;
	}
}