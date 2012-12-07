MongoDB driver for Haxe
====================================

This is a database driver for MongoDB written in Haxe and available for all targets allowing a socket connection (neko/php/cpp).

Find all objects in a collection
------------------------------------

Finding rows in a relational database can be a daunting process. Thankfully with Mongo it's just like accessing a regular Haxe object instance.

```haxe
import org.mongodb.Mongo;

class Main
{
	public static function main()
	{
		var mongo = new Mongo();       // connects to MongoDB
		var posts = mongo.blog.posts;  // get the "blog.posts" collection

		// loops through all objects in "test.posts"
		for (post in posts.find())
		{
			trace(post.title); // assumes that all posts have a title
		}
	}
}
```

Inserting and updating
------------------------------------

Inserting object in Mongo is just as simple as putting values in an Array<Dynamic>. Just create an object and put it in the collection by calling insert(). Updating objects is just as simple except we need a way to find the original object so we pass a selector object first.

```haxe
import org.mongodb.Mongo;

class Main
{
	public static function main()
	{
		var mongo = new Mongo();       // connects to MongoDB
		var posts = mongo.blog.posts;  // get the "blog.posts" collection

		// creating a new post is as easy as making a new object
		var post = {
			title: 'My awesome post',
			body: 'MongoDB is easy as pie'
		};
		posts.insert(post); // save the post in Mongo

		post.body = 'Made some updates to my post';
		posts.update({title: post.title}, post); // update the post
	}
}
```

Driver Roadmap
------------------------------------

Here are the features planned for future versions.

** v0.9 **
* Replica sets
* Automatic reconnection
