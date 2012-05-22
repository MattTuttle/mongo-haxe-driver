import haxe.unit.TestCase;
import haxe.Timer;
import org.mongodb.Collection;
import org.mongodb.Cursor;
import org.mongodb.Database;
import org.mongodb.Mongo;

class MongoTest extends TestCase
{

	public function new()
	{
		super();
		mongo = new Mongo();
	}

	public function init()
	{
		db = mongo.blog;
		posts = db.posts;

		// push posts into an array
		var data = new Array<Dynamic>();
		for (i in 0...NUM_POSTS)
		{
			data.push({
				title: 'My awesome post',
				body: 'More awesome content',
				thing: ['first', 5, 25.5],
				obj: {
					updated: Date.now(),
					bool: true
				}
			});
		}
		posts.insert(data);
	}

	public function shutdown()
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
		db.addUser("user", "pass");
		assertTrue(db.login("user", "pass"));
	}

	public static function main()
	{
		var r = new haxe.unit.TestRunner();
#if (neko || cpp || php)
		r.add(new BSONTest());
#end
		var mt = new MongoTest();
		r.add(mt);

		// flash workaround
#if flash
		var timer:Timer = new Timer(1000);
		timer.run = function() {
#end
			mt.init();
			r.run();
			mt.shutdown();
#if flash
			timer.stop();
		}
#end
	}

	private static inline var NUM_POSTS = 5;

	private var mongo:Mongo;
	private var db:Database;
	private var posts:Collection;
}