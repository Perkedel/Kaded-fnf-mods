// this file is for modchart things, this is to declutter playstate.hx
// JOELwindows7: okay, please widen the area of support for macOS and Linux too.
// dang failed. I guess we go back to only Windows..
// LuaJit only works for C++; JOELwindows7: wtf Linux not working?
// https://lib.haxe.org/p/linc_luajit/
// Lua
import LuaClass;
#if FEATURE_GIF
import flixel.FlxGifSprite;
#end
import flixel.util.FlxAxes;
#if FEATURE_LUAMODCHART
import LuaClass.LuaGame;
import LuaClass.LuaWindow;
import LuaClass.LuaSprite;
import LuaClass.LuaCamera;
import LuaClass.LuaReceptor;
import openfl.display3D.textures.VideoTexture;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxEase;
import openfl.filters.ShaderFilter;
import openfl.filters.BitmapFilter;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import lime.app.Application;
import flixel.FlxSprite;
import llua.Convert;
import llua.Lua;
import llua.State;
import llua.LuaL;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import openfl.Lib;
import HaxeScriptState;

using StringTools;

class ModchartState
{
	// public static var shaders:Array<LuaShader> = null; // JOELwindows7: uncomment now!!! nvm
	public static var lua:State = null;

	// JOELwindows7: kem0x mod shader
	#if EXPERIMENTAL_KEM0X_SHADERS
	public var luaShaders:Map<String, DynamicShaderHandler> = new Map<String, DynamicShaderHandler>();
	#end
	public var camTarget:FlxCamera;

	function callLua(func_name:String, args:Array<Dynamic>, ?type:String):Dynamic
	{
		var result:Any = null;

		Lua.getglobal(lua, func_name);

		for (arg in args)
		{
			Convert.toLua(lua, arg);
		}

		result = Lua.pcall(lua, args.length, 1, 0);
		var p = Lua.tostring(lua, result);
		var e = getLuaErrorMessage(lua);

		Lua.tostring(lua, -1);

		if (e != null)
		{
			if (e != "attempt to call a nil value")
			{
				trace(StringTools.replace(e, "c++", "haxe function"));
			}
		}
		if (result == null)
		{
			return null;
		}
		else
		{
			return convert(result, type);
		}
	}

	static function toLua(l:State, val:Any):Bool
	{
		switch (Type.typeof(val))
		{
			case Type.ValueType.TNull:
				Lua.pushnil(l);
			case Type.ValueType.TBool:
				Lua.pushboolean(l, val);
			case Type.ValueType.TInt:
				Lua.pushinteger(l, cast(val, Int));
			case Type.ValueType.TFloat:
				Lua.pushnumber(l, val);
			case Type.ValueType.TClass(String):
				Lua.pushstring(l, cast(val, String));
			case Type.ValueType.TClass(Array):
				Convert.arrayToLua(l, val);
			case Type.ValueType.TObject:
				objectToLua(l, val);
			default:
				trace("haxe value not supported - " + val + " which is a type of " + Type.typeof(val));
				return false;
		}

		return true;
	}

	static function objectToLua(l:State, res:Any)
	{
		var FUCK = 0;
		for (n in Reflect.fields(res))
		{
			trace(Type.typeof(n).getName());
			FUCK++;
		}

		Lua.createtable(l, FUCK, 0); // TODONE: I did it

		for (n in Reflect.fields(res))
		{
			if (!Reflect.isObject(n))
				continue;
			Lua.pushstring(l, n);
			toLua(l, Reflect.field(res, n));
			Lua.settable(l, -3);
		}
	}

	function getType(l, type):Any
	{
		return switch Lua.type(l, type)
		{
			case t if (t == Lua.LUA_TNIL): null;
			case t if (t == Lua.LUA_TNUMBER): Lua.tonumber(l, type);
			case t if (t == Lua.LUA_TSTRING): (Lua.tostring(l, type) : String);
			case t if (t == Lua.LUA_TBOOLEAN): Lua.toboolean(l, type);
			case t: throw 'you don goofed up. lua type error ($t)';
		}
	}

	function getReturnValues(l)
	{
		var lua_v:Int;
		var v:Any = null;
		while ((lua_v = Lua.gettop(l)) != 0)
		{
			var type:String = getType(l, lua_v);
			v = convert(lua_v, type);
			Lua.pop(l, 1);
		}
		return v;
	}

	private function convert(v:Any, type:String):Dynamic
	{ // I didn't write this lol
		if (Std.isOfType(v, String) && type != null) // JOELwindows7: was Std.is(v,t). unuse deprecated function pls!
		{
			var v:String = v;
			if (type.substr(0, 4) == 'array')
			{
				if (type.substr(4) == 'float')
				{
					var array:Array<String> = v.split(',');
					var array2:Array<Float> = new Array();

					for (vars in array)
					{
						array2.push(Std.parseFloat(vars));
					}

					return array2;
				}
				else if (type.substr(4) == 'int')
				{
					var array:Array<String> = v.split(',');
					var array2:Array<Int> = new Array();

					for (vars in array)
					{
						array2.push(Std.parseInt(vars));
					}

					return array2;
				}
				else
				{
					var array:Array<String> = v.split(',');
					return array;
				}
			}
			else if (type == 'float')
			{
				return Std.parseFloat(v);
			}
			else if (type == 'int')
			{
				return Std.parseInt(v);
			}
			else if (type == 'bool')
			{
				if (v == 'true')
				{
					return true;
				}
				else
				{
					return false;
				}
			}
			else
			{
				return v;
			}
		}
		else
		{
			return v;
		}
	}

	function getLuaErrorMessage(l)
	{
		var v:String = Lua.tostring(l, -1);
		Lua.pop(l, 1);
		return v;
	}

	public function setVar(var_name:String, object:Dynamic)
	{
		// trace('setting variable ' + var_name + ' to ' + object);

		Lua.pushnumber(lua, object);
		Lua.setglobal(lua, var_name);
	}

	public function getVar(var_name:String, type:String):Dynamic
	{
		var result:Any = null;

		// trace('getting variable ' + var_name + ' with a type of ' + type);

		Lua.getglobal(lua, var_name);
		result = Convert.fromLua(lua, -1);
		Lua.pop(lua, 1);

		if (result == null)
		{
			return null;
		}
		else
		{
			var result = convert(result, type);
			// trace(var_name + ' result: ' + result);
			return result;
		}
	}

	function getActorByName(id:String):Dynamic
	{
		// pre defined names
		switch (id)
		{
			case 'boyfriend':
				@:privateAccess
				return PlayState.boyfriend;
			case 'girlfriend':
				@:privateAccess
				return PlayState.gf;
			case 'dad':
				@:privateAccess
				return PlayState.dad;
		}
		// lua objects or what ever
		if (luaSprites.get(id) == null)
		{
			if (Std.parseInt(id) == null)
				return Reflect.getProperty(PlayState.instance, id);
			return PlayState.PlayState.strumLineNotes.members[Std.parseInt(id)];
		}
		return luaSprites.get(id);
	}

	function getPropertyByName(id:String)
	{
		return Reflect.field(PlayState.instance, id);
	}

	public static var luaSprites:Map<String, FlxSprite> = [];

	function changeDadCharacter(id:String)
	{
		var olddadx = PlayState.dad.x;
		var olddady = PlayState.dad.y;
		PlayState.instance.removeObject(PlayState.dad);
		PlayState.dad = new Character(olddadx, olddady, id);
		PlayState.instance.addObject(PlayState.dad);
		PlayState.instance.iconP2.changeIcon(id);
	}

	function changeBoyfriendCharacter(id:String)
	{
		var oldboyfriendx = PlayState.boyfriend.x;
		var oldboyfriendy = PlayState.boyfriend.y;
		PlayState.instance.removeObject(PlayState.boyfriend);
		PlayState.boyfriend = new Boyfriend(oldboyfriendx, oldboyfriendy, id);
		PlayState.instance.addObject(PlayState.boyfriend);
		PlayState.instance.iconP1.changeIcon(id);
	}

	// JOELwindows7: also change girlfriend yess
	function changeGirlfriendCharacter(id:String)
	{
		var oldgfx = PlayState.gf.x;
		var oldgfy = PlayState.gf.y;
		PlayState.instance.removeObject(PlayState.gf);
		PlayState.gf = new Character(oldgfx, oldgfy, id);
		PlayState.instance.addObject(PlayState.gf);
	}

	function makeAnimatedLuaSprite(spritePath:String, names:Array<String>, prefixes:Array<String>, startAnim:String, id:String, imageFolder:Bool = false,
			?library:String = '')
	{
		// JOELwindows7: heuristical
		#if FEATURE_FILESYSTEM
		// TODO: Make this use OpenFlAssets.
		// var data:BitmapData = BitmapData.fromFile(Sys.getCwd() + "assets/data/songs/" + PlayState.SONG.songId + '/' + spritePath + ".png");
		var data:BitmapData = BitmapData.fromFile(#if !mobile Sys.getCwd()
			+ "assets/"
			+ (imageFolder ? (library != null && library != '' ? library + "/" : '') + "images" : "data/songs/" + PlayState.SONG.songId)
			+ '/'
			+ spritePath
			+ ".png" #else Asset2File.getPath("assets/"
				+ (imageFolder ? (library != null && library != '' ? library + "/" : '') + "images" : "data/songs/" + PlayState.SONG.songId)
				+ '/'
				+ spritePath
				+ ".png") #end);

		var sprite:FlxSprite = new FlxSprite(0, 0);

		// JOELwindows7: heuristical
		sprite.frames = FlxAtlasFrames.fromSparrow(FlxGraphic.fromBitmapData(data),
			#if !mobile // Sys.getCwd() + "assets/data/songs/" + PlayState.SONG.songId + "/" + spritePath + ".xml");
			Sys.getCwd()
			+ "assets/"
			+ (imageFolder ? (library != null && library != '' ? library + "/" : '') + "images" : "data/songs/" + PlayState.SONG.songId)
			+ '/'
			+ spritePath
			+ ".xml" #else
			Asset2File.getPath("assets/"
				+ (imageFolder ? (library != null && library != '' ? library + "/" : '') + "images" : "data/songs/" + PlayState.SONG.songId)
				+ '/'
				+ spritePath
				+ ".xml")
			#end);

		trace(sprite.frames.frames.length);

		for (p in 0...names.length)
		{
			var i = names[p];
			var ii = prefixes[p];
			sprite.animation.addByPrefix(i, ii, 24, false);
		}

		luaSprites.set(id, sprite);

		PlayState.instance.addObject(sprite);

		sprite.animation.play(startAnim);
		#end
		return id;
	}

	function makeLuaSprite(spritePath:String, toBeCalled:String, drawBehind:Bool, imageFolder:Bool = false, ?library:String = '')
	{
		#if FEATURE_FILESYSTEM
		// pre lowercasing the song name (makeLuaSprite)
		// var songLowercase = StringTools.replace(PlayState.SONG.songId, " ", "-").toLowerCase();
		var songLowercase = PlayState.SONG.songId;
		// switch (songLowercase)
		// {
		// 	case 'dad-battle':
		// 		songLowercase = 'dadbattle';
		// 	case 'philly-nice':
		// 		songLowercase = 'philly';
		// 	case 'm.i.l.f':
		// 		songLowercase = 'milf';
		// }

		// var path = Sys.getCwd() + "assets/data/songs/" + PlayState.SONG.songId + '/';
		var path = Sys.getCwd()
			+ "assets/"
			+ (imageFolder ? (library != null && library != '' ? library + "/" : '') + "images" : "data/songs/" + PlayState.SONG.songId)
			+ '/';

		if (PlayState.isSM && !imageFolder)
			path = PlayState.pathToSm + "/";

		// var data:BitmapData = BitmapData.fromFile(path + spritePath + ".png");
		var data:BitmapData = BitmapData.fromFile(#if !mobile path + "/" + spritePath + ".png" #else Asset2File.getPath(path + "/" + spritePath + ".png") #end);

		var sprite:FlxSprite = new FlxSprite(0, 0);
		var imgWidth:Float = FlxG.width / data.width;
		var imgHeight:Float = FlxG.height / data.height;
		var scale:Float = imgWidth <= imgHeight ? imgWidth : imgHeight;

		// Cap the scale at x1
		if (scale > 1)
			scale = 1;

		sprite.makeGraphic(Std.int(data.width * scale), Std.int(data.width * scale), FlxColor.TRANSPARENT);

		var data2:BitmapData = sprite.pixels.clone();
		var matrix:Matrix = new Matrix();
		matrix.identity();
		matrix.scale(scale, scale);
		data2.fillRect(data2.rect, FlxColor.TRANSPARENT);
		data2.draw(data, matrix, null, null, null, true);
		sprite.pixels = data2;

		luaSprites.set(toBeCalled, sprite);
		// and I quote:
		// shitty layering but it works!
		@:privateAccess
		{
			if (drawBehind)
			{
				PlayState.instance.removeObject(PlayState.gf);
				PlayState.instance.removeObject(PlayState.boyfriend);
				PlayState.instance.removeObject(PlayState.dad);
			}
			PlayState.instance.addObject(sprite);
			if (drawBehind)
			{
				PlayState.instance.addObject(PlayState.gf);
				PlayState.instance.addObject(PlayState.boyfriend);
				PlayState.instance.addObject(PlayState.dad);
			}
		}
		
		new LuaSprite(sprite, toBeCalled).Register(lua);
		#end // JOELwindows7: do not register if there is no sprite! null object reference

		return toBeCalled;
	}

	function makeLuaGifSprite(spritePath:String, toBeCalled:String, drawBehind:Bool, imageFolder:Bool = false, ?library:String = '')
	{
		#if (FEATURE_FILESYSTEM && FEATURE_GIF)
		// pre lowercasing the song name (makeLuaGifSprite)
		// var songLowercase = StringTools.replace(PlayState.SONG.songId, " ", "-").toLowerCase();
		var songLowercase = PlayState.SONG.songId;
		// switch (songLowercase)
		// {
		// 	case 'dad-battle':
		// 		songLowercase = 'dadbattle';
		// 	case 'philly-nice':
		// 		songLowercase = 'philly';
		// 	case 'm.i.l.f':
		// 		songLowercase = 'milf';
		// }

		// var path = Sys.getCwd() + "assets/data/songs/" + PlayState.SONG.songId + '/';
		var path = Sys.getCwd()
			+ "assets/"
			+ (imageFolder ? (library != null && library != '' ? library + "/" : '') + "images" : "data/songs/" + PlayState.SONG.songId)
			+ '/';

		if (PlayState.isSM && !imageFolder)
			path = PlayState.pathToSm + "/";

		// var data:BitmapData = BitmapData.fromFile(path + spritePath + ".png");
		// var data:BitmapData = BitmapData.fromFile(#if !mobile path + "/" + spritePath + ".png" #else Asset2File.getPath(path + "/" + spritePath + ".png") #end);

		var sprite:FlxGifSprite = new FlxGifSprite(path, 0, 0);
		// var imgWidth:Float = FlxG.width / data.width;
		// var imgHeight:Float = FlxG.height / data.height;
		// var scale:Float = imgWidth <= imgHeight ? imgWidth : imgHeight;

		// Cap the scale at x1
		// if (scale > 1)
		// 	scale = 1;

		// sprite.makeGraphic(Std.int(data.width * scale), Std.int(data.width * scale), FlxColor.TRANSPARENT);

		// var data2:BitmapData = sprite.pixels.clone();
		// var matrix:Matrix = new Matrix();
		// matrix.identity();
		// matrix.scale(scale, scale);
		// data2.fillRect(data2.rect, FlxColor.TRANSPARENT);
		// data2.draw(data, matrix, null, null, null, true);
		// sprite.pixels = data2;

		luaSprites.set(toBeCalled, sprite);
		// and I quote:
		// shitty layering but it works!
		@:privateAccess
		{
			if (drawBehind)
			{
				PlayState.instance.removeObject(PlayState.gf);
				PlayState.instance.removeObject(PlayState.boyfriend);
				PlayState.instance.removeObject(PlayState.dad);
			}
			PlayState.instance.addObject(sprite);
			if (drawBehind)
			{
				PlayState.instance.addObject(PlayState.gf);
				PlayState.instance.addObject(PlayState.boyfriend);
				PlayState.instance.addObject(PlayState.dad);
			}
		}
		
		new LuaGifSprite(sprite, toBeCalled).Register(lua);
		#end // JOELwindows7: do not register if there is no sprite! null object reference

		return toBeCalled;
	}

	public function die()
	{
		Lua.close(lua);
		lua = null;
	}

	public var luaWiggles:Map<String, WiggleEffect> = new Map<String, WiggleEffect>();

	// LUA SHIT

	function new(?isStoryMode = true, rawMode:Bool = false, pathu:String = "") // JOELwindows7: make lua stageont. ? isStoryMode is upstream pls push away!
	{
		trace('opening a lua state (because we are cool :))');
		lua = LuaL.newstate();
		LuaL.openlibs(lua);
		trace("Lua version: " + Lua.version());
		trace("LuaJIT version: " + Lua.versionJIT());
		Lua.init_callbacks(lua);

		// if (PPlayStateChangeables.legacyLuaModchartSupport)
		// 	shaders = new Array<LuaShader>(); // JOELwindows7: uncomment now!!!! nvm

		// pre lowercasing the song name (new)
		var songLowercase = StringTools.replace(PlayState.SONG.songId, " ", "-").toLowerCase();
		switch (songLowercase)
		{
			case 'dad-battle':
				songLowercase = 'dadbattle';
			case 'philly-nice':
				songLowercase = 'philly';
			case 'm.i.l.f':
				songLowercase = 'milf';
		}

		var path = Paths.lua('songs/${PlayState.SONG.songId}/modchart');
		if (PlayState.isSM)
			path = PlayState.pathToSm + "/modchart.lua";

		// JOELwindows7: okeh if you ask raw path there you have it.
		if (rawMode)
			path = pathu;

		var result = LuaL.dofile(lua, path); // execute le file

		if (result != 0)
		{
			Application.current.window.alert("LUA COMPILE ERROR:\n" + Lua.tostring(lua, result), "Kade Engine Modcharts");
			FlxG.log.warn(["LUA COMPILE ERROR:\n" + Lua.tostring(lua, result)]);
			FlxG.switchState(new FreeplayState());
			return;
		}

		// get some fukin globals up in here bois

		setVar("difficulty", PlayState.storyDifficulty);
		setVar("bpm", Conductor.bpm);
		setVar("scrollspeed", FlxG.save.data.scrollSpeed != 1 ? FlxG.save.data.scrollSpeed : PlayState.SONG.speed);
		setVar("fpsCap", FlxG.save.data.fpsCap);
		setVar("downscroll", FlxG.save.data.downscroll);
		setVar("flashing", FlxG.save.data.flashing);
		setVar("distractions", FlxG.save.data.distractions);
		setVar("colour", FlxG.save.data.colour);

		setVar("curStep", 0);
		setVar("curBeat", 0);
		setVar("crochet", Conductor.stepCrochet);
		setVar("safeZoneOffset", Conductor.safeZoneOffset);

		setVar("hudZoom", PlayState.instance.camHUD.zoom);
		setVar("cameraZoom", FlxG.camera.zoom);

		setVar("cameraAngle", FlxG.camera.angle);
		setVar("camHudAngle", PlayState.instance.camHUD.angle);

		setVar("followXOffset", 0);
		setVar("followYOffset", 0);

		setVar("showOnlyStrums", false);
		setVar("strumLine1Visible", true);
		setVar("strumLine2Visible", true);

		setVar("screenWidth", FlxG.width);
		setVar("screenHeight", FlxG.height);
		setVar("windowWidth", FlxG.width);
		setVar("windowHeight", FlxG.height);
		setVar("hudWidth", PlayState.instance.camHUD.width);
		setVar("hudHeight", PlayState.instance.camHUD.height);

		setVar("mustHit", false);

		setVar("strumLineY", PlayState.instance.strumLine.y);

		// JOELwindows7: mirror the variables here!
		// Colored bg
		setVar("originalColor", PlayState.Stage.originalColor);
		setVar("isChromaScreen", PlayState.Stage.isChromaScreen);

		// stage
		setVar("thisStage", PlayState.Stage);

		// BulbyVR specialty
		setVar("BEHIND_GF", DisplayLayer.BEHIND_GF);
		setVar("BEHIND_BF", DisplayLayer.BEHIND_BF);
		setVar("BEHIND_DAD", DisplayLayer.BEHIND_DAD);
		setVar("BEHIND_ALL", DisplayLayer.BEHIND_ALL);
		setVar("BEHIND_NONE", 0);
		setVar("songData", PlayState.SONG);
		setVar("camHUD", PlayState.instance.camHUD);
		setVar("playerStrums", PlayState.playerStrums);
		setVar("enemyStrums", PlayState.cpuStrums);
		setVar("hscriptPath", path);
		@:privateAccess { // JOELwindows7: Oh yeah, I suggest that uh... idk. maybe keep those characters private? no idk.
			setVar("boyfriend", PlayState.boyfriend);
			setVar("gf", PlayState.gf);
			setVar("dad", PlayState.dad);
		}
		setVar("vocals", PlayState.instance.vocals);
		setVar("gfSpeed", PlayState.instance.gfSpeed);
		setVar("health", PlayState.instance.health);
		setVar("iconP1", PlayState.instance.iconP1);
		setVar("iconP2", PlayState.instance.iconP2);
		setVar("currentPlayState", PlayState.instance);
		setVar("PlayState", PlayState);
		setVar("Paths", Paths);
		setVar("window", Lib.application.window);
		// end mirror variables

		// init just in case
		setVar("songLength", 0);

		// callbacks

		Lua_helper.add_callback(lua, "makeSprite", makeLuaSprite);
		Lua_helper.add_callback(lua, "makeGifSprite", makeLuaGifSprite); // JOELwindows7: gifs are now supported. GWebDev gif sprite

		// bulbyVR callbackers
		Lua_helper.add_callback(lua, "add", PlayState.instance.add);
		Lua_helper.add_callback(lua, "remove", PlayState.instance.remove);
		Lua_helper.add_callback(lua, "insert", PlayState.instance.insert);
		Lua_helper.add_callback(lua, "setDefaultZoom", function(zoom)
		{
			PlayState.Stage.camZoom = zoom;
		});
		Lua_helper.add_callback(lua, "removeSprite", function(sprite)
		{
			PlayState.instance.remove(sprite);
		});
		// Lua_helper.add_callback(lua, "instancePluginClass", createScriptClassInstance);
		// Lua_helper.add_callback(lua, "instancePluginClass", function(className, ...args) {
		// 	return createScriptClassInstance(className, ...args);
		// });
		Lua_helper.add_callback(lua, "addSprite", function(sprite, position)
		{
			// sprite is a FlxSprite
			// position is a Int
			if (position & DisplayLayer.BEHIND_GF != 0)
				PlayState.instance.remove(PlayState.gf);
			if (position & DisplayLayer.BEHIND_DAD != 0)
				PlayState.instance.remove(PlayState.dad);
			if (position & DisplayLayer.BEHIND_BF != 0)
				PlayState.instance.remove(PlayState.boyfriend);
			PlayState.instance.add(sprite);
			if (position & DisplayLayer.BEHIND_GF != 0)
				PlayState.instance.add(PlayState.gf);
			if (position & DisplayLayer.BEHIND_DAD != 0)
				PlayState.instance.add(PlayState.dad);
			if (position & DisplayLayer.BEHIND_BF != 0)
				PlayState.instance.add(PlayState.boyfriend);
		});

		// sprites

		// JOELwindows7: Other actor stuffs old
		if (PlayStateChangeables.legacyLuaModchartSupport)
		{
			Lua_helper.add_callback(lua, "changeDadCharacter", changeDadCharacter);

			Lua_helper.add_callback(lua, "changeBoyfriendCharacter", changeBoyfriendCharacter);
			
			Lua_helper.add_callback(lua, "changeGirlfriendCharacter", changeGirlfriendCharacter);

			Lua_helper.add_callback(lua, "getProperty", getPropertyByName);
		}

		// end Other actor stuffs old

		Lua_helper.add_callback(lua, "setNoteWiggle", function(wiggleId)
		{
			PlayState.instance.camNotes.setFilters([new ShaderFilter(luaWiggles.get(wiggleId).shader)]);
		});

		Lua_helper.add_callback(lua, "setSustainWiggle", function(wiggleId)
		{
			PlayState.instance.camSustains.setFilters([new ShaderFilter(luaWiggles.get(wiggleId).shader)]);
		});

		Lua_helper.add_callback(lua, "createWiggle", function(freq:Float, amplitude:Float, speed:Float)
		{
			var wiggle = new WiggleEffect();
			wiggle.waveAmplitude = amplitude;
			wiggle.waveSpeed = speed;
			wiggle.waveFrequency = freq;

			var id = Lambda.count(luaWiggles) + 1 + "";

			luaWiggles.set(id, wiggle);
			return id;
		});

		Lua_helper.add_callback(lua, "setWiggleTime", function(wiggleId:String, time:Float)
		{
			var wiggle = luaWiggles.get(wiggleId);

			wiggle.shader.uTime.value = [time];
		});

		Lua_helper.add_callback(lua, "setWiggleAmplitude", function(wiggleId:String, amp:Float)
		{
			var wiggle = luaWiggles.get(wiggleId);

			wiggle.waveAmplitude = amp;
		});

		// JOELwindows7: pls don't delete
		if (PlayStateChangeables.legacyLuaModchartSupport)
		{
			Lua_helper.add_callback(lua, "makeAnimatedSprite", makeAnimatedLuaSprite);
			// this one is still in development
			Lua_helper.add_callback(lua, "destroySprite", function(id:String)
			{
				var sprite = luaSprites.get(id);
				if (sprite == null)
					return false;
				PlayState.instance.removeObject(sprite);
				return true;
			});

			// hud/camera

			Lua_helper.add_callback(lua, "initBackgroundVideo", function(videoName:String)
			{
				trace('playing assets/videos/' + videoName + '.webm');
				PlayState.instance.backgroundVideo("assets/videos/" + videoName + ".webm");
			});

			Lua_helper.add_callback(lua, "pauseVideo", function()
			{
				if (PlayState.instance.useVLC)
				{
					PlayState.instance.vlcHandler.pause();
				}
				else if (!GlobalVideo.get().paused)
					GlobalVideo.get().pause();
			});

			Lua_helper.add_callback(lua, "resumeVideo", function()
			{
				if (PlayState.instance.useVLC)
				{
					PlayState.instance.vlcHandler.resume();
				}
				else if (GlobalVideo.get().paused)
					GlobalVideo.get().pause();
			});

			Lua_helper.add_callback(lua, "restartVideo", function()
			{
				if (PlayState.instance.useVLC)
				{
					// PlayState.instance.vlcHandler.restart();
				}
				else
					GlobalVideo.get().restart();
			});

			Lua_helper.add_callback(lua, "getVideoSpriteX", function()
			{
				return PlayState.instance.videoSprite.x;
			});

			Lua_helper.add_callback(lua, "getVideoSpriteY", function()
			{
				return PlayState.instance.videoSprite.y;
			});

			Lua_helper.add_callback(lua, "setVideoSpritePos", function(x:Int, y:Int)
			{
				PlayState.instance.videoSprite.setPosition(x, y);
			});

			Lua_helper.add_callback(lua, "setVideoSpriteScale", function(scale:Float)
			{
				PlayState.instance.videoSprite.setGraphicSize(Std.int(PlayState.instance.videoSprite.width * scale));
			});

			Lua_helper.add_callback(lua, "setHudAngle", function(x:Float)
			{
				PlayState.instance.camHUD.angle = x;
			});

			Lua_helper.add_callback(lua, "setHealth", function(heal:Float)
			{
				PlayState.instance.health = heal;
			});

			Lua_helper.add_callback(lua, "setHudPosition", function(x:Int, y:Int)
			{
				PlayState.instance.camHUD.x = x;
				PlayState.instance.camHUD.y = y;
			});

			Lua_helper.add_callback(lua, "getHudX", function()
			{
				return PlayState.instance.camHUD.x;
			});

			Lua_helper.add_callback(lua, "getHudY", function()
			{
				return PlayState.instance.camHUD.y;
			});

			Lua_helper.add_callback(lua, "setCamPosition", function(x:Int, y:Int)
			{
				FlxG.camera.x = x;
				FlxG.camera.y = y;
			});

			Lua_helper.add_callback(lua, "getCameraX", function()
			{
				return FlxG.camera.x;
			});

			Lua_helper.add_callback(lua, "getCameraY", function()
			{
				return FlxG.camera.y;
			});

			Lua_helper.add_callback(lua, "setCamZoom", function(zoomAmount:Float)
			{
				FlxG.camera.zoom = zoomAmount;
			});

			Lua_helper.add_callback(lua, "setHudZoom", function(zoomAmount:Float)
			{
				PlayState.instance.camHUD.zoom = zoomAmount;
			});
		}

		// JOELwindows7: whoah forgor this cam function!
		Lua_helper.add_callback(lua, "camShake", function(intensity:Float = .05, duration:Float = .5, force:Bool = true, axes:Int = 0, onComplete:String)
		{
			// JOELwindows7: decide which axes this shakes at. yoink from HaxeFlixel snippet of camera shake.
			// https://snippets.haxeflixel.com/camera/shake/
			var shakeAxes:FlxAxes = switch (axes)
			{
				case 0: FlxAxes.XY;
				case 1: FlxAxes.X;
				case 2: FlxAxes.Y;
				case _: FlxAxes.XY;
			}

			// JOELwindows7: "I'm, not, that, OLD!!!" lol vs. oswald damn forgor user author.
			FlxG.camera.shake(intensity, duration, function()
			{
				if (onComplete != '' && onComplete != null)
				{
					callLua(onComplete, ["camera"]);
				}
			}, force);
		});
		// end don't delete

		// strumline

		Lua_helper.add_callback(lua, "setStrumlineY", function(y:Float)
		{
			PlayState.instance.strumLine.y = y;
		});

		// actors
		// JOELwindows7: olde
		if (PlayStateChangeables.legacyLuaModchartSupport)
		{
			Lua_helper.add_callback(lua, "getRenderedNotes", function()
			{
				return PlayState.instance.notes.length;
			});

			Lua_helper.add_callback(lua, "getRenderedNoteX", function(id:Int)
			{
				return PlayState.instance.notes.members[id].x;
			});

			Lua_helper.add_callback(lua, "getRenderedNoteY", function(id:Int)
			{
				return PlayState.instance.notes.members[id].y;
			});

			Lua_helper.add_callback(lua, "getRenderedNoteType", function(id:Int)
			{
				return PlayState.instance.notes.members[id].noteData;
			});

			Lua_helper.add_callback(lua, "isSustain", function(id:Int)
			{
				return PlayState.instance.notes.members[id].isSustainNote;
			});

			Lua_helper.add_callback(lua, "isParentSustain", function(id:Int)
			{
				return PlayState.instance.notes.members[id].prevNote.isSustainNote;
			});

			Lua_helper.add_callback(lua, "getRenderedNoteParentX", function(id:Int)
			{
				return PlayState.instance.notes.members[id].prevNote.x;
			});

			Lua_helper.add_callback(lua, "getRenderedNoteParentY", function(id:Int)
			{
				return PlayState.instance.notes.members[id].prevNote.y;
			});

			Lua_helper.add_callback(lua, "getRenderedNoteHit", function(id:Int)
			{
				return PlayState.instance.notes.members[id].mustPress;
			});

			Lua_helper.add_callback(lua, "getRenderedNoteCalcX", function(id:Int)
			{
				if (PlayState.instance.notes.members[id].mustPress)
					return PlayState.playerStrums.members[Math.floor(Math.abs(PlayState.instance.notes.members[id].noteData))].x;
				return PlayState.strumLineNotes.members[Math.floor(Math.abs(PlayState.instance.notes.members[id].noteData))].x;
			});

			Lua_helper.add_callback(lua, "anyNotes", function()
			{
				return PlayState.instance.notes.members.length != 0;
			});

			Lua_helper.add_callback(lua, "getRenderedNoteStrumtime", function(id:Int)
			{
				return PlayState.instance.notes.members[id].strumTime;
			});

			Lua_helper.add_callback(lua, "getRenderedNoteScaleX", function(id:Int)
			{
				return PlayState.instance.notes.members[id].scale.x;
			});

			Lua_helper.add_callback(lua, "setRenderedNotePos", function(x:Float, y:Float, id:Int)
			{
				if (PlayState.instance.notes.members[id] == null)
					throw('error! you cannot set a rendered notes position when it doesnt exist! ID: ' + id);
				else
				{
					PlayState.instance.notes.members[id].modifiedByLua = true;
					PlayState.instance.notes.members[id].x = x;
					PlayState.instance.notes.members[id].y = y;
				}
			});

			Lua_helper.add_callback(lua, "setRenderedNoteAlpha", function(alpha:Float, id:Int)
			{
				PlayState.instance.notes.members[id].modifiedByLua = true;
				PlayState.instance.notes.members[id].alpha = alpha;
			});

			Lua_helper.add_callback(lua, "setRenderedNoteScale", function(scale:Float, id:Int)
			{
				PlayState.instance.notes.members[id].modifiedByLua = true;
				PlayState.instance.notes.members[id].setGraphicSize(Std.int(PlayState.instance.notes.members[id].width * scale));
			});

			Lua_helper.add_callback(lua, "setRenderedNoteScale", function(scaleX:Int, scaleY:Int, id:Int)
			{
				PlayState.instance.notes.members[id].modifiedByLua = true;
				PlayState.instance.notes.members[id].setGraphicSize(scaleX, scaleY);
			});

			Lua_helper.add_callback(lua, "getRenderedNoteWidth", function(id:Int)
			{
				return PlayState.instance.notes.members[id].width;
			});

			Lua_helper.add_callback(lua, "setRenderedNoteAngle", function(angle:Float, id:Int)
			{
				PlayState.instance.notes.members[id].modifiedByLua = true;
				PlayState.instance.notes.members[id].angle = angle;
			});

			Lua_helper.add_callback(lua, "setActorX", function(x:Int, id:String)
			{
				getActorByName(id).x = x;
			});

			// JOELwindows7: moar
			Lua_helper.add_callback(lua, "setActorScrollFactor", function(x:Int, y:Int, id:String)
			{
				getActorByName(id).scrollFactor.set(x, y);
			});

			Lua_helper.add_callback(lua, "setActorAccelerationX", function(x:Int, id:String)
			{
				getActorByName(id).acceleration.x = x;
			});

			Lua_helper.add_callback(lua, "setActorDragX", function(x:Int, id:String)
			{
				getActorByName(id).drag.x = x;
			});

			Lua_helper.add_callback(lua, "setActorVelocityX", function(x:Int, id:String)
			{
				getActorByName(id).velocity.x = x;
			});

			Lua_helper.add_callback(lua, "playActorAnimation", function(id:String, anim:String, force:Bool = false, reverse:Bool = false)
			{
				getActorByName(id).playAnim(anim, force, reverse);
			});

			Lua_helper.add_callback(lua, "setActorAlpha", function(alpha:Float, id:String)
			{
				getActorByName(id).alpha = alpha;
			});

			Lua_helper.add_callback(lua, "setActorY", function(y:Int, id:String)
			{
				getActorByName(id).y = y;
			});

			Lua_helper.add_callback(lua, "setActorAccelerationY", function(y:Int, id:String)
			{
				getActorByName(id).acceleration.y = y;
			});

			Lua_helper.add_callback(lua, "setActorDragY", function(y:Int, id:String)
			{
				getActorByName(id).drag.y = y;
			});

			Lua_helper.add_callback(lua, "setActorVelocityY", function(y:Int, id:String)
			{
				getActorByName(id).velocity.y = y;
			});

			Lua_helper.add_callback(lua, "setActorAngle", function(angle:Int, id:String)
			{
				getActorByName(id).angle = angle;
			});

			Lua_helper.add_callback(lua, "setActorScale", function(scale:Float, id:String)
			{
				getActorByName(id).setGraphicSize(Std.int(getActorByName(id).width * scale));
			});

			Lua_helper.add_callback(lua, "setActorScaleXY", function(scaleX:Float, scaleY:Float, id:String)
			{
				getActorByName(id).setGraphicSize(Std.int(getActorByName(id).width * scaleX), Std.int(getActorByName(id).height * scaleY));
			});

			Lua_helper.add_callback(lua, "setActorFlipX", function(flip:Bool, id:String)
			{
				getActorByName(id).flipX = flip;
			});

			Lua_helper.add_callback(lua, "setActorFlipY", function(flip:Bool, id:String)
			{
				getActorByName(id).flipY = flip;
			});

			Lua_helper.add_callback(lua, "getActorWidth", function(id:String)
			{
				return getActorByName(id).width;
			});

			Lua_helper.add_callback(lua, "getActorHeight", function(id:String)
			{
				return getActorByName(id).height;
			});

			Lua_helper.add_callback(lua, "getActorAlpha", function(id:String)
			{
				return getActorByName(id).alpha;
			});

			Lua_helper.add_callback(lua, "getActorAngle", function(id:String)
			{
				return getActorByName(id).angle;
			});

			Lua_helper.add_callback(lua, "getActorX", function(id:String)
			{
				return getActorByName(id).x;
			});

			Lua_helper.add_callback(lua, "getActorY", function(id:String)
			{
				return getActorByName(id).y;
			});

			// JOELwindows7: moar get
			Lua_helper.add_callback(lua, "getActorScrollFactorX", function(id:String)
			{
				return getActorByName(id).scrollFactor.x;
			});

			Lua_helper.add_callback(lua, "getActorScrollFactorY", function(id:String)
			{
				return getActorByName(id).scrollFactor.y;
			});

			Lua_helper.add_callback(lua, "getActorVelocityX", function(id:String)
			{
				return getActorByName(id).velocity.x;
			});

			Lua_helper.add_callback(lua, "getActorVelocityY", function(id:String)
			{
				return getActorByName(id).velocity.y;
			});
		}
		// end olde
		Lua_helper.add_callback(lua, "getNumberOfNotes", function(y:Float)
		{
			return PlayState.instance.notes.members.length;
		});

		for (i in 0...PlayState.strumLineNotes.length)
		{
			var member = PlayState.strumLineNotes.members[i];
			new LuaReceptor(member, "receptor_" + i).Register(lua);

			// JOELwindows7: old
			if (PlayStateChangeables.legacyLuaModchartSupport)
			{
				var member = PlayState.strumLineNotes.members[i];
				Debug.logTrace(PlayState.strumLineNotes.members[i].x
					+ " "
					+ PlayState.strumLineNotes.members[i].y + " " + PlayState.strumLineNotes.members[i].angle + " | strum" + i);
				// setVar("strum" + i + "X", Math.floor(member.x));
				setVar("defaultStrum" + i + "X", Math.floor(member.x));
				// setVar("strum" + i + "Y", Math.floor(member.y));
				setVar("defaultStrum" + i + "Y", Math.floor(member.y));
				// setVar("strum" + i + "Angle", Math.floor(member.angle));
				setVar("defaultStrum" + i + "Angle", Math.floor(member.angle));
				Debug.logTrace("Adding strum" + i);
			}
			// end old
		}

		new LuaGame().Register(lua);

		new LuaWindow().Register(lua);

		// JOELwindows7: windowing old
		if (PlayStateChangeables.legacyLuaModchartSupport)
		{
			Lua_helper.add_callback(lua, "setWindowPos", function(x:Int, y:Int)
			{
				Application.current.window.x = x;
				Application.current.window.y = y;
			});

			Lua_helper.add_callback(lua, "getWindowX", function()
			{
				return Application.current.window.x;
			});

			Lua_helper.add_callback(lua, "getWindowY", function()
			{
				return Application.current.window.y;
			});

			Lua_helper.add_callback(lua, "resizeWindow", function(Width:Int, Height:Int)
			{
				Application.current.window.resize(Width, Height);
			});

			Lua_helper.add_callback(lua, "getScreenWidth", function()
			{
				return Application.current.window.display.currentMode.width;
			});

			Lua_helper.add_callback(lua, "getScreenHeight", function()
			{
				return Application.current.window.display.currentMode.height;
			});

			Lua_helper.add_callback(lua, "getWindowWidth", function()
			{
				return Application.current.window.width;
			});

			Lua_helper.add_callback(lua, "getWindowHeight", function()
			{
				return Application.current.window.height;
			});
		}
		// end windowing old

		// JOELwindows7: tweener old
		if (PlayStateChangeables.legacyLuaModchartSupport)
		{
			// tweens

			Lua_helper.add_callback(lua, "tweenCameraPos", function(toX:Int, toY:Int, time:Float, onComplete:String)
			{
				FlxTween.tween(FlxG.camera, {x: toX, y: toY}, time, {
					ease: FlxEase.linear,
					onComplete: function(flxTween:FlxTween)
					{
						if (onComplete != '' && onComplete != null)
						{
							callLua(onComplete, ["camera"]);
						}
					}
				});
			});

			Lua_helper.add_callback(lua, "tweenCameraAngle", function(toAngle:Float, time:Float, onComplete:String)
			{
				FlxTween.tween(FlxG.camera, {angle: toAngle}, time, {
					ease: FlxEase.linear,
					onComplete: function(flxTween:FlxTween)
					{
						if (onComplete != '' && onComplete != null)
						{
							callLua(onComplete, ["camera"]);
						}
					}
				});
			});

			Lua_helper.add_callback(lua, "tweenCameraZoom", function(toZoom:Float, time:Float, onComplete:String)
			{
				FlxTween.tween(FlxG.camera, {zoom: toZoom}, time, {
					ease: FlxEase.linear,
					onComplete: function(flxTween:FlxTween)
					{
						if (onComplete != '' && onComplete != null)
						{
							callLua(onComplete, ["camera"]);
						}
					}
				});
			});

			Lua_helper.add_callback(lua, "tweenHudPos", function(toX:Int, toY:Int, time:Float, onComplete:String)
			{
				FlxTween.tween(PlayState.instance.camHUD, {x: toX, y: toY}, time, {
					ease: FlxEase.linear,
					onComplete: function(flxTween:FlxTween)
					{
						if (onComplete != '' && onComplete != null)
						{
							callLua(onComplete, ["camera"]);
						}
					}
				});
			});

			Lua_helper.add_callback(lua, "tweenHudAngle", function(toAngle:Float, time:Float, onComplete:String)
			{
				FlxTween.tween(PlayState.instance.camHUD, {angle: toAngle}, time, {
					ease: FlxEase.linear,
					onComplete: function(flxTween:FlxTween)
					{
						if (onComplete != '' && onComplete != null)
						{
							callLua(onComplete, ["camera"]);
						}
					}
				});
			});

			Lua_helper.add_callback(lua, "tweenHudZoom", function(toZoom:Float, time:Float, onComplete:String)
			{
				FlxTween.tween(PlayState.instance.camHUD, {zoom: toZoom}, time, {
					ease: FlxEase.linear,
					onComplete: function(flxTween:FlxTween)
					{
						if (onComplete != '' && onComplete != null)
						{
							callLua(onComplete, ["camera"]);
						}
					}
				});
			});

			Lua_helper.add_callback(lua, "tweenPos", function(id:String, toX:Int, toY:Int, time:Float, onComplete:String)
			{
				FlxTween.tween(getActorByName(id), {x: toX, y: toY}, time, {
					ease: FlxEase.linear,
					onComplete: function(flxTween:FlxTween)
					{
						if (onComplete != '' && onComplete != null)
						{
							callLua(onComplete, [id]);
						}
					}
				});
			});

			Lua_helper.add_callback(lua, "tweenPosXAngle", function(id:String, toX:Int, toAngle:Float, time:Float, onComplete:String)
			{
				FlxTween.tween(getActorByName(id), {x: toX, angle: toAngle}, time, {
					ease: FlxEase.linear,
					onComplete: function(flxTween:FlxTween)
					{
						if (onComplete != '' && onComplete != null)
						{
							callLua(onComplete, [id]);
						}
					}
				});
			});

			Lua_helper.add_callback(lua, "tweenPosYAngle", function(id:String, toY:Int, toAngle:Float, time:Float, onComplete:String)
			{
				FlxTween.tween(getActorByName(id), {y: toY, angle: toAngle}, time, {
					ease: FlxEase.linear,
					onComplete: function(flxTween:FlxTween)
					{
						if (onComplete != '' && onComplete != null)
						{
							callLua(onComplete, [id]);
						}
					}
				});
			});

			Lua_helper.add_callback(lua, "tweenAngle", function(id:String, toAngle:Int, time:Float, onComplete:String)
			{
				FlxTween.tween(getActorByName(id), {angle: toAngle}, time, {
					ease: FlxEase.linear,
					onComplete: function(flxTween:FlxTween)
					{
						if (onComplete != '' && onComplete != null)
						{
							callLua(onComplete, [id]);
						}
					}
				});
			});

			Lua_helper.add_callback(lua, "tweenCameraPosOut", function(toX:Int, toY:Int, time:Float, onComplete:String)
			{
				FlxTween.tween(FlxG.camera, {x: toX, y: toY}, time, {
					ease: FlxEase.cubeOut,
					onComplete: function(flxTween:FlxTween)
					{
						if (onComplete != '' && onComplete != null)
						{
							callLua(onComplete, ["camera"]);
						}
					}
				});
			});

			Lua_helper.add_callback(lua, "tweenCameraAngleOut", function(toAngle:Float, time:Float, onComplete:String)
			{
				FlxTween.tween(FlxG.camera, {angle: toAngle}, time, {
					ease: FlxEase.cubeOut,
					onComplete: function(flxTween:FlxTween)
					{
						if (onComplete != '' && onComplete != null)
						{
							callLua(onComplete, ["camera"]);
						}
					}
				});
			});

			Lua_helper.add_callback(lua, "tweenCameraZoomOut", function(toZoom:Float, time:Float, onComplete:String)
			{
				FlxTween.tween(FlxG.camera, {zoom: toZoom}, time, {
					ease: FlxEase.cubeOut,
					onComplete: function(flxTween:FlxTween)
					{
						if (onComplete != '' && onComplete != null)
						{
							callLua(onComplete, ["camera"]);
						}
					}
				});
			});

			Lua_helper.add_callback(lua, "tweenHudPosOut", function(toX:Int, toY:Int, time:Float, onComplete:String)
			{
				FlxTween.tween(PlayState.instance.camHUD, {x: toX, y: toY}, time, {
					ease: FlxEase.cubeOut,
					onComplete: function(flxTween:FlxTween)
					{
						if (onComplete != '' && onComplete != null)
						{
							callLua(onComplete, ["camera"]);
						}
					}
				});
			});

			Lua_helper.add_callback(lua, "tweenHudAngleOut", function(toAngle:Float, time:Float, onComplete:String)
			{
				FlxTween.tween(PlayState.instance.camHUD, {angle: toAngle}, time, {
					ease: FlxEase.cubeOut,
					onComplete: function(flxTween:FlxTween)
					{
						if (onComplete != '' && onComplete != null)
						{
							callLua(onComplete, ["camera"]);
						}
					}
				});
			});

			Lua_helper.add_callback(lua, "tweenHudZoomOut", function(toZoom:Float, time:Float, onComplete:String)
			{
				FlxTween.tween(PlayState.instance.camHUD, {zoom: toZoom}, time, {
					ease: FlxEase.cubeOut,
					onComplete: function(flxTween:FlxTween)
					{
						if (onComplete != '' && onComplete != null)
						{
							callLua(onComplete, ["camera"]);
						}
					}
				});
			});

			Lua_helper.add_callback(lua, "tweenPosOut", function(id:String, toX:Int, toY:Int, time:Float, onComplete:String)
			{
				FlxTween.tween(getActorByName(id), {x: toX, y: toY}, time, {
					ease: FlxEase.cubeOut,
					onComplete: function(flxTween:FlxTween)
					{
						if (onComplete != '' && onComplete != null)
						{
							callLua(onComplete, [id]);
						}
					}
				});
			});

			Lua_helper.add_callback(lua, "tweenPosXAngleOut", function(id:String, toX:Int, toAngle:Float, time:Float, onComplete:String)
			{
				FlxTween.tween(getActorByName(id), {x: toX, angle: toAngle}, time, {
					ease: FlxEase.cubeOut,
					onComplete: function(flxTween:FlxTween)
					{
						if (onComplete != '' && onComplete != null)
						{
							callLua(onComplete, [id]);
						}
					}
				});
			});

			Lua_helper.add_callback(lua, "tweenPosYAngleOut", function(id:String, toY:Int, toAngle:Float, time:Float, onComplete:String)
			{
				FlxTween.tween(getActorByName(id), {y: toY, angle: toAngle}, time, {
					ease: FlxEase.cubeOut,
					onComplete: function(flxTween:FlxTween)
					{
						if (onComplete != '' && onComplete != null)
						{
							callLua(onComplete, [id]);
						}
					}
				});
			});

			Lua_helper.add_callback(lua, "tweenAngleOut", function(id:String, toAngle:Int, time:Float, onComplete:String)
			{
				FlxTween.tween(getActorByName(id), {angle: toAngle}, time, {
					ease: FlxEase.cubeOut,
					onComplete: function(flxTween:FlxTween)
					{
						if (onComplete != '' && onComplete != null)
						{
							callLua(onComplete, [id]);
						}
					}
				});
			});

			Lua_helper.add_callback(lua, "tweenCameraPosIn", function(toX:Int, toY:Int, time:Float, onComplete:String)
			{
				FlxTween.tween(FlxG.camera, {x: toX, y: toY}, time, {
					ease: FlxEase.cubeIn,
					onComplete: function(flxTween:FlxTween)
					{
						if (onComplete != '' && onComplete != null)
						{
							callLua(onComplete, ["camera"]);
						}
					}
				});
			});

			Lua_helper.add_callback(lua, "tweenCameraAngleIn", function(toAngle:Float, time:Float, onComplete:String)
			{
				FlxTween.tween(FlxG.camera, {angle: toAngle}, time, {
					ease: FlxEase.cubeIn,
					onComplete: function(flxTween:FlxTween)
					{
						if (onComplete != '' && onComplete != null)
						{
							callLua(onComplete, ["camera"]);
						}
					}
				});
			});

			Lua_helper.add_callback(lua, "tweenCameraZoomIn", function(toZoom:Float, time:Float, onComplete:String)
			{
				FlxTween.tween(FlxG.camera, {zoom: toZoom}, time, {
					ease: FlxEase.cubeIn,
					onComplete: function(flxTween:FlxTween)
					{
						if (onComplete != '' && onComplete != null)
						{
							callLua(onComplete, ["camera"]);
						}
					}
				});
			});

			Lua_helper.add_callback(lua, "tweenHudPosIn", function(toX:Int, toY:Int, time:Float, onComplete:String)
			{
				FlxTween.tween(PlayState.instance.camHUD, {x: toX, y: toY}, time, {
					ease: FlxEase.cubeIn,
					onComplete: function(flxTween:FlxTween)
					{
						if (onComplete != '' && onComplete != null)
						{
							callLua(onComplete, ["camera"]);
						}
					}
				});
			});

			Lua_helper.add_callback(lua, "tweenHudAngleIn", function(toAngle:Float, time:Float, onComplete:String)
			{
				FlxTween.tween(PlayState.instance.camHUD, {angle: toAngle}, time, {
					ease: FlxEase.cubeIn,
					onComplete: function(flxTween:FlxTween)
					{
						if (onComplete != '' && onComplete != null)
						{
							callLua(onComplete, ["camera"]);
						}
					}
				});
			});

			Lua_helper.add_callback(lua, "tweenHudZoomIn", function(toZoom:Float, time:Float, onComplete:String)
			{
				FlxTween.tween(PlayState.instance.camHUD, {zoom: toZoom}, time, {
					ease: FlxEase.cubeIn,
					onComplete: function(flxTween:FlxTween)
					{
						if (onComplete != '' && onComplete != null)
						{
							callLua(onComplete, ["camera"]);
						}
					}
				});
			});

			Lua_helper.add_callback(lua, "tweenPosIn", function(id:String, toX:Int, toY:Int, time:Float, onComplete:String)
			{
				FlxTween.tween(getActorByName(id), {x: toX, y: toY}, time, {
					ease: FlxEase.cubeIn,
					onComplete: function(flxTween:FlxTween)
					{
						if (onComplete != '' && onComplete != null)
						{
							callLua(onComplete, [id]);
						}
					}
				});
			});

			Lua_helper.add_callback(lua, "tweenPosXAngleIn", function(id:String, toX:Int, toAngle:Float, time:Float, onComplete:String)
			{
				FlxTween.tween(getActorByName(id), {x: toX, angle: toAngle}, time, {
					ease: FlxEase.cubeIn,
					onComplete: function(flxTween:FlxTween)
					{
						if (onComplete != '' && onComplete != null)
						{
							callLua(onComplete, [id]);
						}
					}
				});
			});

			Lua_helper.add_callback(lua, "tweenPosYAngleIn", function(id:String, toY:Int, toAngle:Float, time:Float, onComplete:String)
			{
				FlxTween.tween(getActorByName(id), {y: toY, angle: toAngle}, time, {
					ease: FlxEase.cubeIn,
					onComplete: function(flxTween:FlxTween)
					{
						if (onComplete != '' && onComplete != null)
						{
							callLua(onComplete, [id]);
						}
					}
				});
			});

			Lua_helper.add_callback(lua, "tweenAngleIn", function(id:String, toAngle:Int, time:Float, onComplete:String)
			{
				FlxTween.tween(getActorByName(id), {angle: toAngle}, time, {
					ease: FlxEase.cubeIn,
					onComplete: function(flxTween:FlxTween)
					{
						if (onComplete != '' && onComplete != null)
						{
							callLua(onComplete, [id]);
						}
					}
				});
			});

			Lua_helper.add_callback(lua, "tweenFadeIn", function(id:String, toAlpha:Float, time:Float, onComplete:String)
			{
				FlxTween.tween(getActorByName(id), {alpha: toAlpha}, time, {
					ease: FlxEase.circIn,
					onComplete: function(flxTween:FlxTween)
					{
						if (onComplete != '' && onComplete != null)
						{
							callLua(onComplete, [id]);
						}
					}
				});
			});

			Lua_helper.add_callback(lua, "tweenFadeOut", function(id:String, toAlpha:Float, time:Float, onComplete:String)
			{
				FlxTween.tween(getActorByName(id), {alpha: toAlpha}, time, {
					ease: FlxEase.circOut,
					onComplete: function(flxTween:FlxTween)
					{
						if (onComplete != '' && onComplete != null)
						{
							callLua(onComplete, [id]);
						}
					}
				});
			});

			// forgot and accidentally commit to master branch
			// shader

			/*Lua_helper.add_callback(lua, "createShader", function(frag:String, vert:String)
				{
					var shader:LuaShader = new LuaShader(frag, vert);

					trace(shader.glFragmentSource);

					shaders.push(shader);
					// if theres 1 shader we want to say theres 0 since 0 index and length returns a 1 index.
					return shaders.length == 1 ? 0 : shaders.length;
			});*/
		}
		// end tweener old

		// JOELwindows7: kem0x mod shader
		Lua_helper.add_callback(lua, "createShaders", function(shaderName, ?optimize:Bool = false)
		{
			#if EXPERIMENTAL_KEM0X_SHADERS
			var shader = new DynamicShaderHandler(shaderName, optimize);

			return shaderName;
			#else
			return null;
			#end
		});

		Lua_helper.add_callback(lua, "modifyShaderProperty", function(shaderName, propertyName, value)
		{
			#if EXPERIMENTAL_KEM0X_SHADERS
			var handler = luaShaders[shaderName];
			handler.modifyShaderProperty(propertyName, value);
			#end
		});

		// shader set

		Lua_helper.add_callback(lua, "setShadersToCamera", function(shaderName:Array<String>, cameraName)
		{
			switch (cameraName)
			{
				case 'hud':
					camTarget = PlayState.instance.camHUD;
				case 'notes':
					camTarget = PlayState.instance.camNotes;
				case 'sustains':
					camTarget = PlayState.instance.camSustains;
				case 'game':
					camTarget = FlxG.camera;
			}

			#if EXPERIMENTAL_KEM0X_SHADERS
			var shaderArray = new Array<BitmapFilter>();

			for (i in shaderName)
			{
				shaderArray.push(new ShaderFilter(luaShaders[i].shader));
			}

			camTarget.setFilters(shaderArray);
			#end
		});

		// shader clear

		Lua_helper.add_callback(lua, "clearShadersFromCamera", function(cameraName)
		{
			switch (cameraName)
			{
				case 'hud':
					camTarget = PlayState.instance.camHUD;
				case 'notes':
					camTarget = PlayState.instance.camNotes;
				case 'sustains':
					camTarget = PlayState.instance.camSustains;
				case 'game':
					camTarget = FlxG.camera;
			}
			camTarget.setFilters([]);
		});
		// end kem0x mod shader

		// JOELwindows7: HUD rest old
		if (PlayStateChangeables.legacyLuaModchartSupport)
		{
			// forgot and accidentally commit to master branch
			// shader

			/*Lua_helper.add_callback(lua, "createShader", function(frag:String, vert:String)
				{
					var shader:LuaShader = new LuaShader(frag, vert);

					trace(shader.glFragmentSource);

					shaders.push(shader);
					// if theres 1 shader we want to say theres 0 since 0 index and length returns a 1 index.
					return shaders.length == 1 ? 0 : shaders.length;
				});

				Lua_helper.add_callback(lua, "setFilterHud", function(shaderIndex:Int)
				{
					PlayState.instance.camHUD.setFilters([new ShaderFilter(shaders[shaderIndex])]);
				});

				Lua_helper.add_callback(lua, "setFilterCam", function(shaderIndex:Int)
				{
					FlxG.camera.setFilters([new ShaderFilter(shaders[shaderIndex])]);
			});*/
		}
		// end HUD rest old

		// JOELwindows7: Special additional functions
		Lua_helper.add_callback(lua, "cheerNow",
			function(ooutOfBeatFractioning:Int = 4, doItOn:Int = 0, randomizeColor:Bool = false, justOne:Bool = false, toWhichBg:Int = 0, forceIt:Bool = false)
			{
				PlayState.instance.cheerNow(ooutOfBeatFractioning, doItOn, randomizeColor, justOne, toWhichBg, forceIt);
			});

		Lua_helper.add_callback(lua, "heyNow",
			function(ooutOfBeatFractioning:Int = 4, doItOn:Int = 0, randomizeColor:Bool = false, justOne:Bool = false, toWhichBg:Int = 0, forceIt:Bool = false)
			{
				PlayState.instance.heyNow(ooutOfBeatFractioning, doItOn, randomizeColor, justOne, toWhichBg, forceIt);
			});

		Lua_helper.add_callback(lua, "justCheer", function(forceIt:Bool = false)
		{
			PlayState.instance.justCheer(forceIt);
		});

		Lua_helper.add_callback(lua, "justHey", function(forceIt:Bool = false)
		{
			PlayState.instance.justHey(forceIt);
		});

		// JOELwindows7: blackbars yey
		Lua_helper.add_callback(lua, "appearBlackbar", function(forHowLong:Float = 1, useStageLevel:Bool = false)
		{
			if (useStageLevel)
				PlayState.Stage.appearBlackBar(forHowLong)
			else
				PlayState.instance.appearRealBlackBar(forHowLong);
		});

		Lua_helper.add_callback(lua, "disappearBlackbar", function(forHowLong:Float = 1, useStageLevel:Bool = false)
		{
			if (useStageLevel)
				PlayState.Stage.disappearBlackBar(forHowLong)
			else
				PlayState.instance.disappearRealBlackBar(forHowLong);
		});

		Lua_helper.add_callback(lua, "prepareColorableBg",
			function(useImage:Bool = false, positionX:Float = -500, positionY:Float = -500, imagePath:String = '', animated:Bool = false,
					color:String = "WHITE", width:Int = 1, height:Int = 1, upscaleX:Int = 1, upscaleY:Int = 1, antialiasing:Bool = true,
					scrollFactorX:Float = .5, scrollFactorY:Float = .5, active:Bool = false, callNow:Bool = true, unique:Bool = false)
			{
				PlayState.Stage.prepareColorableBg(useImage, positionX, positionY, imagePath, animated, FlxColor.fromString(color), width, height, upscaleX,
					upscaleY, antialiasing, scrollFactorX, scrollFactorY, active, callNow, unique);
				// HOOF! so complicated!
				// idk man who will use this. but just in case you would like to reset spawn
				// a graphics here, you can use this.
				// and this is NOT RECOMMENDED to be used at all
				// because loading new image or generate graphic has lags on it.
				// Just don't touch this.
			});

		Lua_helper.add_callback(lua, "randomizeColoring", function(justOne:Bool = false, toWhichBg:Int = 0, inHowLong:Float = 0)
		{
			PlayState.Stage.randomizeColoring(justOne, toWhichBg, inHowLong);
			// ARE YOU SERIOUS??!?!? i SUPPOSED TO MEANT randomizeColoring not randomizeColor
			// and you, Haxe Language Server laggs on purpose
			// hence I blinded & mistyped!!! C'MON!!!! REALLY??!?!
		});

		Lua_helper.add_callback(lua, "chooseColoringColor", function(color:String = "WHITE", justOne:Bool = true, toWhichBg:Int = 0, inHowLong:Float = 0)
		{
			PlayState.Stage.chooseColoringColor(FlxColor.fromString(color.trim()), justOne, toWhichBg, inHowLong);
			// hmm, I am afraid using raw FlxColor data doing won't work.
			// You see, I believe Lua can't have weird datatype other than Int, Float, String, Array, something like that.
			// so, maybe you should use the.. string version?
			// so here it is. the FlxCOlor.fromString() is magic. it can understand 0x000000, #FFFFFFFF, or even Name!!! wow!!
		});

		Lua_helper.add_callback(lua, "hideColoring", function(justOne:Bool = false, toWhichBg:Int = 0, inHowLong:Float = 0)
		{
			PlayState.Stage.hideColoring(justOne, toWhichBg, inHowLong);
			// hide the colorings
		});

		Lua_helper.add_callback(lua, "camZoomNow", function(howMuchZoom:Float = .015, howMuchZoomHUD:Float = .03, maxZoom:Float = 1.35)
		{
			PlayState.instance.camZoomNow(howMuchZoom, howMuchZoomHUD, maxZoom);
			// zoom the cam now
		});

		Lua_helper.add_callback(lua, "trainStart", function()
		{
			// Manually start the train right from the modchart anyway.
			PlayState.Stage.trainStart();
		});

		Lua_helper.add_callback(lua, "trainReset", function()
		{
			// Also reset the train from modchart as well
			PlayState.Stage.trainReset();
		});

		Lua_helper.add_callback(lua, "lightningStrikeHit", function()
		{
			// Now you can abuse the lightning lol!!!
			PlayState.Stage.lightningStrikeShit();
		}); // what the heck, Haxe Language server? you didn't quickly tell me
		// That I missed semicolon? what cause of all these lags?

		Lua_helper.add_callback(lua, "fastCarDrive", function()
		{
			// haha fast car go brrrrr!!!
			PlayState.Stage.fastCarDrive();
		});

		Lua_helper.add_callback(lua, "resetFastCar", function()
		{
			// reset da cars! now!!
			PlayState.Stage.resetFastCar();
		});

		Lua_helper.add_callback(lua, "vibrate",
			function(player:Int = 0, duration:Float = 100, period:Float = 0, strengthLeft:Float = 0, strengthRight:Float = 0)
			{
				// vibration, sensation, okeh self explanatory. lol TheFatRat - Electrified
				Controls.vibrate(player, duration, period, strengthLeft, strengthRight);
			});

		Lua_helper.add_callback(lua, "createToast", function(iconPath:String = "", title:String = "", description:String = "", sound:Bool = false)
		{
			// JOELwindows7: gamejolt toast
			Main.gjToastManager.createToast(iconPath, title, description, sound);
		});

		// Cutscene Calls
		Lua_helper.add_callback(lua, "introSceneIsDone", function()
		{
			@:privateAccess {
				if (!PlayState.instance.introDoneCalled)
					PlayState.instance.recallIntroSceneDone();
			}
		});

		Lua_helper.add_callback(lua, "outroSceneIsDone", function()
		{
			@:privateAccess {
				if (!PlayState.instance.outroDoneCalled)
					PlayState.instance.recallOutroSceneDone();
			}
		});

		// end more special functions
		// So you don't have to hard code your cool effects.
		// end Special additional functions
	}

	/**
	 * Create instance of a class in the lua script?..
	 * @author JOELwindows7
	 * @param className 
	 * @param args 
	 * @param addModule 
	 */
	/*
		public function createScriptClassInstance(className:String, args:Array<Dynamic> = null, addModule:String)
		{
			if (interp != null)
			{
				if (addModule != null && addModule != "")
					interp.addModule(addModule);
				return interp.createScriptClassInstance(className, args);
			}
			else
			{
				interp = createInterp();
				return createScriptClassInstance(className, args, addModule);
			}
		}
	 */
	public function executeState(name, args:Array<Dynamic>)
	{
		return Lua.tostring(lua, callLua(name, args));
	}

	// JOELwindows7: raw mode pls!
	public static function createModchartState(?isStoryMode = true, rawMode:Bool = false, path:String = ""):ModchartState
	{
		return new ModchartState(isStoryMode, rawMode, path);
	}
}
#end
