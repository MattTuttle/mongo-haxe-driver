import haxe.unit.TestCase;
import org.bsonspec.BSON;

class BSONTest extends TestCase
{

	public function testEncode()
	{
		var obj = {
			'hello': 'mom',
			'blob': [1, 2, 3, 'q'],
			'help': 5.3
		}
		BSON.encode(obj);
		assertTrue(true);
	}

	public function testDecode()
	{
		//BSON.decode();
		assertTrue(true);
	}

}