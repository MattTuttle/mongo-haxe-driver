import org.mongodb.*;

@:publicFields class QueryTest extends haxe.unit.TestCase
{

	var cnx : Mongo;
	var db : Database;

	override function setup()
	{
		cnx = new Mongo();
		db = cnx.queryTest;
		db.users.drop();
		db.posts.drop();
	}

	override function tearDown()
	{
		db = null;
		cnx.close();
		cnx = null;
	}

	// function testCriteria()
	// {
	// 	db.users.insert({ _id : 1, age : 10});
	// 	db.users.insert({ _id : 1, age : 20});
	// 	db.users.find({ age : { "$gt" : 18 } });
	// 	assertTrue(true);
	// }

	function testMultipleCursors()
	{
		db.users.insert({ _id : 1, name : "Coulson", type : "user" });
		db.users.insert({ _id : 2, name : "Fury", type : "user" });
		db.users.insert({ _id : 3, name : "Ward", type : "user" });

		db.posts.insert({ _id : 1, user : 1, title : "The Avenger Initiative", type : "post" });
		db.posts.insert({ _id : 2, user : 1, title : "Hydra", type : "post" });
		db.posts.insert({ _id : 3, user : 1, title : "Ward is Hydra", type : "post" });
		db.posts.insert({ _id : 4, user : 2, title : "Agent Coulson", type : "post" });
		db.posts.insert({ _id : 5, user : 2, title : "Director Coulson", type : "post" });
		db.posts.insert({ _id : 6, user : 2, title : "Short stories", type : "post" });
		
		var userCnt = 0;
		var postCnt = 0;

		// limit number of returned to 1 to make potencial issues on
		// the protocol easier to spot
		for (u in db.users.find(null, null, 0, 2))
		{
			userCnt++;
			assertEquals("user", u.type);
			for (p in db.posts.find({ user : u._id }, null, 0, 2))
			{
				postCnt++;
				assertEquals("post", p.type);
			}
		}

		assertEquals(3, userCnt);
		assertEquals(6, postCnt);
	}

}

