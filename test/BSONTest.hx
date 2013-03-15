import haxe.unit.TestCase;
import org.bsonspec.BSON;
import org.bsonspec.BSONDocument;
import org.bsonspec.ObjectID;
import sys.io.File;

class BSONTest extends TestCase
{

	function testEncodeDecode()
	{
		var data = {
			_id: new ObjectID(),
			title: 'My awesome post',
			hol: [10, 2, 20.5],
			options: {
				delay: 1.565,
				test: true,
				nested: [
					{
						going: 'deeper',
						mining: -35
					}
				]
			},
			monkey: null
		};
		File.saveBytes("test.bson", BSON.encode(data));

		var out = BSON.decode(File.read("test.bson", true));

		File.saveContent("test.txt", Std.string( out ) );

		assertEquals(Std.string(data), Std.string(out));
	}

	function testBSONDocument()
	{
		var doc:BSONDocument = BSONDocument.create()
			.append( "_id", new ObjectID() )
			.append( "title", 'My awesome post' )
			.append( "hol", ['first', 2, Date.now()] )
			.append( "options", BSONDocument.create()
				.append( "delay", 1.565 )
				.append( "test", true )
				.append( "nested", [
					53,
					BSONDocument.create()
						.append( "going", 'deeper' )
						.append( "mining", -35 )
					] )
				)
			.append( "monkey", null )
			.append( "$in", [1, 3] );

		File.saveBytes("test-doc.bson", BSON.encode( doc ) );
		File.saveContent("test-doc.txt", doc.toString() );

		var out:Dynamic = BSON.decode(File.read("test.bson", true));
	}

}
