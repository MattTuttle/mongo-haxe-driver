MongoDB driver for Haxe
====================================

This is a database driver for MongoDB written in Haxe and available for all targets allowing a socket connection (neko/php/cpp).

Querying a collection
------------------------------------

Finding rows in a database can seem daunting but with Mongo's object model it is no different than accessing a Haxe object instance.

```haxe
class Test
{
	public static function main()
	{
		var mongo = new Mongo();       // connects to MongoDB
		var posts = mongo.blog.posts;  // gets the "blog.posts" collection

		// loops through all objects in "test.posts"
		for (post in coll.find())
		{
			trace(post.title); // assumes that all posts have a title
		}
	}
}
```