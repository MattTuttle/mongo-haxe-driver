import haxe.unit.TestCase;
import org.mongodb.Collection;
import org.mongodb.Cursor;
import org.mongodb.Database;
import org.mongodb.Mongo;

class MongoTest extends TestCase
{

	public override function setup()
	{
		mongo = new Mongo();
		db = mongo.test;
		posts = db.posts;

		posts.insert({'name': 'John Doe'});
	}

	public function testCursor()
	{
		var cursor:Cursor = posts.find();
		for (obj in cursor)
		{
			trace('hi');
		}
		assertTrue(true);
	}

	public static function main()
	{
		var r = new haxe.unit.TestRunner();
		r.add(new BSONTest());
		r.add(new MongoTest());
		r.run();
	}

	private var mongo:Mongo;
	private var db:Database;
	private var posts:Collection;
}