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

		db = mongo.testDriver;
		posts = db.posts;
		db.drop(); // clear stuff

		// push posts into an array
		var data = new Array<Dynamic>();
		for (i in 0...NUM_POSTS)
		{
			data.push({
				title: 'My awesome post',
				body: 'More awesome content \xc4\x83',
				thing: [10, 5, 25.5],
				obj: {
					updated: Date.now(),
					bool: true
				},
				setDate: Date.fromTime(1e10),
				postDate: Date.now(),
				seq: i
			});
		}
		posts.insert(data);

		// posts.ensureIndex({title: 1}, {unique:true});
		// posts.dropIndexes();
		// for (index in posts.getIndexes())
		// {
		// 	trace(index);
		// }
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
		assertEquals(obj.setDate.getTime(), 1e10);
	}

	public function testLogin()
	{
		db.addUser("user", "pass");
		assertTrue(db.login("user", "pass"));
	}

	public function testReturnOpts()
	{
		assertEquals(NUM_POSTS, posts.find(null, null, 0, 2).toArray().length);
		// however:
		//     If numberToReturn is 1 the server will treat it as -1 (closing the cursor automatically).
		//     —MongoDB Wire Protocol
		assertEquals(1, posts.find(null, null, 0, 1).toArray().length);
	}

        public function testCursorMethods()
        {
		assertEquals(NUM_POSTS - 2, posts.find().skip(2).toArray().length);
		assertEquals(NUM_POSTS - 2, posts.find().limit(NUM_POSTS - 2).toArray().length);
		assertEquals(NUM_POSTS - 1, posts.find().sort({ seq : -1 }).limit(1).toArray()[0].seq);
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
			r.run();
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
