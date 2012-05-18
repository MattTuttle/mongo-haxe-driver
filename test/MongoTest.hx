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

		var post = {
			title: 'My awesome post',
			body: 'More awesome content'
		};
		for (i in 0...105)
			posts.insert(post);
	}

	public override function tearDown()
	{
		posts.remove({ title: 'My awesome post' });
	}

	public function testCount()
	{
		assertTrue(posts.count() == 105);
	}

	public function testCursor()
	{
		var count = 0;
		for (obj in posts.find())
		{
			count += 1;
		}
		assertTrue(count == 105);
	}

	public function testData()
	{
		for (obj in posts.find())
		{
			assertTrue(obj.title == 'My awesome post');
		}
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