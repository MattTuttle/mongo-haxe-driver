import haxe.unit.TestCase;
import org.bsonspec.BSON;
import org.bsonspec.ObjectID;
import sys.io.File;

class BSONTest extends TestCase
{

	function testEncodeDecode()
	{
		var data = {
			title: 'My awesome post',
			hol: ['first', 2, Date.now()],
			options: {
				delay: 1.565,
				test: true,
				nested: [
					53,
					{
						going: 'deeper',
//						id: new ObjectID("4f7eb8a729a1775cb32d"),
					}
				]
			},
			monkey: null
		};

		File.saveBytes("test.bson", BSON.encode(data));

		var out = BSON.decode(File.read("test.bson", true));
		assertEquals(Std.string(data), Std.string(out));
	}

}
