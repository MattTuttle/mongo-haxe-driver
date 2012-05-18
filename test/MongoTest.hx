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
		db = mongo.blog;
		posts = db.posts;

		var post = {
			title: 'My awesome post',
			body: 'More awesome content'
		};
		var p = new Array<Dynamic>();
		for (i in 0...NUM_POSTS)
			p.push(post);
		posts.insert(p);
	}

	public override function tearDown()
	{
		posts.remove({ title: 'My awesome post' });
	}

	public function testCount()
	{
		assertTrue(posts.count() == NUM_POSTS);
	}

	public function testCursor()
	{
		var count = 0;
		for (obj in posts.find())
		{
			count += 1;
		}
		assertTrue(count == NUM_POSTS);
	}

	public function testData()
	{
		var obj = posts.findOne();
		assertTrue(obj.title == 'My awesome post');
	}

	public function testLogin()
	{
		//db.addUser("user", "pass");
		assertTrue(db.login("user", "pass"));
	}

	public static function main()
	{
		var r = new haxe.unit.TestRunner();
		r.add(new MongoTest());
		r.run();
	}

	private static inline var NUM_POSTS = 105;

	private var mongo:Mongo;
	private var db:Database;
	private var posts:Collection;
}