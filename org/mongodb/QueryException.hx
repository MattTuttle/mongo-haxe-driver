package org.mongodb;

class QueryException 
{
	
	private var errorDocument : Dynamic;
	
	@:allow(org.mongodb.Protocol)
	function new( errorDocument :  Dynamic ) {
		this.errorDocument = errorDocument;
	}
	
	public function getErrorCode()
	{
		return errorDocument.code == null ? -1 : errorDocument.code;
	}
	
	public function getErrorMessage() 
	{
		return Reflect.field(errorDocument,"$err");
	}
	
	public function toString() 
	{
		return "QueryException("+Std.string(errorDocument)+")";
	}
	
}