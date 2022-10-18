package flixel.system;

import flixel.util.typeLimit.OneOfThree;
import haxe.io.Bytes;
import openfl.utils.ByteArray;

typedef FlxGifAsset = OneOfThree<String, Bytes, ByteArray>;
