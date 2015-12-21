.PHONY: all unit haxelib

all: unit haxelib

haxelib: mongo.zip
	haxelib local $<

mongo.zip:
	zip $@ haxelib.json README.md changelog.txt license.txt
	zip -r $@ org

unit:
	haxe test.hxml
