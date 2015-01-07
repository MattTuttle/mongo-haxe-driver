class TestCase extends haxe.unit.TestCase
{
	// rough/simplified assertSame
	public function assertSame(exp:Dynamic, got:Dynamic, ?p:haxe.PosInfos):Void
	{
		function compareOrRecurse(exp, got, p)
		{
			// if either is a function, so must the other; otherwise, recurse
			if (Reflect.isFunction(exp) || Reflect.isFunction(got))  // isFunction(null) == false
				assertEquals(Reflect.isFunction(exp), Reflect.isFunction(got), p)
			else
				assertSame(exp, got, p);
		}

		switch (Type.typeof(exp))
		{
			case TClass(Array):
				assertEquals(exp.length, got.length, p);
				for (i in 0...exp.length) {
					compareOrRecurse(exp[i], got[i], p);
				}
			case TClass(c):
				for (f in Type.getInstanceFields(c)) {
					var exp = Reflect.field(exp, f);
					var got = Reflect.field(got, f);
					compareOrRecurse(exp, got, p);
				}
			case TObject:
				for (f in Reflect.fields(exp)) {
					var exp = Reflect.field(exp, f);
					var got = Reflect.field(got, f);
					compareOrRecurse(exp, got, p);
				}
			case all:
				assertEquals(exp, got, p);
		}
	}
}

