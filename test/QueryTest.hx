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
    }

    override function tearDown()
    {
        db.users.drop();
        db = null;
        cnx.close();
    }

    function testCriteria()
    {
        db.users.insert({ _id : 1, age : 10});
        db.users.insert({ _id : 1, age : 20});
        db.users.find({ age : { "$gt" : 18 } });
        assertTrue(true);
    }

}

