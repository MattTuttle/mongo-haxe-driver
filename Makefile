all:
	haxe build.hxml

haxelib: mongo.zip
	haxelib local $<

mongo.zip:
	zip $@ haxelib.json changelog.txt license.txt
	zip -r $@ org
