package;

import flixel.graphics.frames.FlxFramesCollection;
import flash.media.Sound;
import openfl.display.BitmapData;
import openfl.media.Video;
import openfl.utils.Assets;
import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.system.System;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import openfl.display3D.textures.Texture;
import haxe.Json;
import tjson.TJSON;

using StringTools;

class Paths
{
	// JOELwindows7: not my code. but hey uh, is it has to be it, the web cannot ogg?
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;
	// inline public static var VIDEO_EXT = #if FEATURE_MP4VIDEOS "mp4" #elseif (!FEATURE_MP4VIDEOS || FEATURE_WEBM) "webm" #end; // JOELwindows7: BOLO
	inline public static var VIDEO_EXT = "webm"; // JOELwindows7: or just settle on WEBM? man that takes time to rerender everything to mo.

	static var currentLevel:String;

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	static function getPath(file:String, type:AssetType, library:Null<String>)
	{
		// JOELwindows7: hey, you gotta also ignore if it's literally empty string!
		if (library != null && library != '')
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	// JOELwindows7: BOLO stuffs!
	// https://github.com/BoloVEVO/Kade-Engine-Public/blob/stable/source/Paths.hx
	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
	public static var currentTrackedBitmapData:Map<String, BitmapData> = [];
	public static var currentTrackedTextures:Map<String, Texture> = [];
	public static var currentTrackedSounds:Map<String, Sound> = [];

	public static function loadSound(path:String, key:String, ?library:String)
	{
		// I hate this so god damn much
		var gottenPath:String = getPath('$path/$key.$SOUND_EXT', SOUND, library);
		// JOELwindows7: BOLO move addedin here
		var folder:String = '';
		if (path == 'songs')
			folder = 'songs:';
		gottenPath = gottenPath.substring(gottenPath.indexOf(':') + 1, gottenPath.length);
		// trace(gottenPath);
		// JOELwindows7: BOLO safety!!!
		if (OpenFlAssets.exists(folder + gottenPath, SOUND))
		{
			if (!currentTrackedSounds.exists(gottenPath))
			{
				currentTrackedSounds.set(gottenPath, OpenFlAssets.getSound(folder + getPath('$path/$key.$SOUND_EXT', SOUND, library)));
			}
		}
		else
		{
			Debug.logWarn('Could not find sound at ${folder + gottenPath}');
		}

		localTrackedAssets.push(gottenPath);

		return currentTrackedSounds.get(gottenPath);
	}

	// JOELwindows7: da hx file
	static public function getHaxeScript(string:String)
	{
		return Assets.getText('assets/data/$string/HaxeModchart.hx');
	}

	// JOELwindows7: wait, Hx file? okay, my modchart is in hscript!
	static public function getHaxeModscript(string:String)
	{
		return Assets.getText('assets/data/$string/modchart.hscript');
	}

	// JOELwindows7: BOLO GPU render

	/**
	 * For a given key and library for an image, returns the corresponding BitmapData.
	 		* We can probably move the cache handling here.
	 * @param key 
	 * @param library 
	 * @return BitmapData
	 */
	static public function loadImage(key:String, ?library:String, ?gpuRender:Bool):FlxGraphic
	{
		// var path = image(key, library);
		// JOELwindows7: NEW BOLO
		var path = '';

		path = getPath('images/$key.png', IMAGE, library);

		gpuRender = gpuRender != null ? gpuRender : FlxG.save.data.gpuRender;

		#if FEATURE_FILESYSTEM
		if (Caching.bitmapData != null)
		{
			if (Caching.bitmapData.exists(key))
			{
				Debug.logTrace('Loading image from bitmap cache: $key');
				// Get data from cache.
				return Caching.bitmapData.get(key);
			}
		}
		#end

		if (OpenFlAssets.exists(path, IMAGE))
		{
			// var bitmap = OpenFlAssets.getBitmapData(path);
			// return FlxGraphic.fromBitmapData(bitmap);

			// JOELwindows7: NEW BOLO OBJECT
			if (!currentTrackedAssets.exists(key))
			{
				var bitmap:BitmapData = OpenFlAssets.getBitmapData(path, false);
				var graphic:FlxGraphic = null;

				var graphic:FlxGraphic = null;
				if (gpuRender)
				{
					var texture = FlxG.stage.context3D.createTexture(bitmap.width, bitmap.height, BGRA, false, 0);
					texture.uploadFromBitmapData(bitmap);
					currentTrackedTextures.set(key, texture);
					bitmap.dispose();
					bitmap.disposeImage();
					bitmap = null;
					graphic = FlxGraphic.fromBitmapData(BitmapData.fromTexture(texture), false, key);
					Debug.logTrace('Adding new texture to cache: $key');
				}
				else
				{
					graphic = FlxGraphic.fromBitmapData(bitmap, false, key, false);
					Debug.logTrace('Adding new bitmap to cache: $key');
				}
				graphic.persist = true;
				currentTrackedAssets.set(key, graphic);
			}
			else
			{
				// Get data from cache.
				// Debug.logTrace('Loading existing image from cache: $key');
			}
			localTrackedAssets.push(key);
			return currentTrackedAssets.get(key);
		}
		// else
		// {
		Debug.logWarn('Could not find image at path $path');
		return null;
		// }
	}

	// JOELwindows7: okay, raw load just bitmap pls.. + BOLO GPU render
	static public function loadBitmap(key:String, ?library:String, ?gpuRender:Bool):BitmapData
	{
		// var path = image(key, library);
		// JOELwindows7: BOLO NEW
		var path = '';

		path = getPath('images/$key.png', IMAGE, library);

		gpuRender = gpuRender != null ? gpuRender : FlxG.save.data.gpuRender;

		#if FEATURE_FILESYSTEM
		if (Caching.bitmapData != null)
		{
			if (Caching.bitmapData.exists(key))
			{
				Debug.logTrace('Loading image from bitmap cache: $key');
				// Get data from cache.
				return Caching.bitmapData.get(key).bitmap;
			}
		}
		#end

		if (OpenFlAssets.exists(path, IMAGE))
		{
			// var bitmap = OpenFlAssets.getBitmapData(path);
			// return bitmap;

			// JOELwindows7: NEW BOLO OBJECT
			if (!currentTrackedBitmapData.exists(key))
			{
				var bitmap:BitmapData = OpenFlAssets.getBitmapData(path, false);
				currentTrackedBitmapData.set(key, bitmap);
				var graphic:FlxGraphic = null;

				var graphic:FlxGraphic = null;
				if (gpuRender)
				{
					var texture = FlxG.stage.context3D.createTexture(bitmap.width, bitmap.height, BGRA, false, 0);
					texture.uploadFromBitmapData(bitmap);
					currentTrackedTextures.set(key, texture);
					bitmap.dispose();
					bitmap.disposeImage();
					bitmap = null;
					graphic = FlxGraphic.fromBitmapData(BitmapData.fromTexture(texture), false, key);
					Debug.logTrace('Adding new texture to cache: $key');
				}
				else
				{
					graphic = FlxGraphic.fromBitmapData(bitmap, false, key, false);
					Debug.logTrace('Adding new bitmap to cache: $key');
				}
				graphic.persist = true;
				currentTrackedAssets.set(key, graphic);
			}
			else
			{
				// Get data from cache.
				// Debug.logTrace('Loading existing image from cache: $key');
			}
			localTrackedAssets.push(key);
			return currentTrackedBitmapData.get(key);
		}
		// else
		// {
		Debug.logWarn('Could not find bitmap at path $path');
		return null;
		// }
	}

	static public function loadJSON(key:String, ?library:String):Dynamic
	{
		var rawJson:String = '';
		// var rawJson = OpenFlAssets.getText(Paths.json(key, library)).trim();

		// JOELwindows7: use safe trick instead like BOLO
		try
		{
			rawJson = OpenFlAssets.getText(Paths.json(key, library)).trim();
		}
		catch (e)
		{
			rawJson = null;
		}

		// Perform cleanup on files that have bad data at the end.
		if (rawJson != null) // JOELwindows7: BOLO make sure not null
		{
			while (!rawJson.endsWith("}"))
			{
				rawJson = rawJson.substr(0, rawJson.length - 1);
			}
		}

		// TODO: JOELwindows7: also cleanup at the beginning too!

		try
		{
			// Attempt to parse and return the JSON data.
			// return Json.parse(rawJson);
			if (rawJson != null) // JOELwindows7: BOLO make sure not null
				return TJSON.parse(rawJson); // JOELwindows7: let's use TJSON rather than regular Haxe JSON instead.

			return null; // JOELwindows7: if all failed
		}
		catch (e)
		{
			Debug.logError("AN ERROR OCCURRED parsing a JSON file.");
			Debug.logError(e + ": " + e.message + "\n" + e.details()); // JOELwindows7: error title & description

			// Return null.
			return null;
		}
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline static function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, ?library:String, type:AssetType = TEXT)
	{
		return getPath(file, type, library);
	}

	inline static public function lua(key:String, ?library:String)
	{
		return getPath('data/$key.lua', TEXT, library);
	}

	/**
	 * Path to an hscript file
	 * @author JOELwindows7
	 * @param key 
	 * @param library 
	 */
	inline static public function hscript(key:String, ?library:String)
	{
		return getPath('data/$key.hscript', TEXT, library);
	}

	inline static public function creditFlashBlink(key:String, ?library:String)
	{
		return getPath('data/creditRolls/flashBlink/$key.txt', TEXT, library);
	}

	inline static public function luaImage(key:String, ?library:String)
	{
		return getPath('data/$key.png', IMAGE, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	// JOELwindows7: MORE BOLO JSON Atlas frame. animJSON
	inline static public function animJson(key:String, ?library:String)
	{
		return getPath('images/$key/Animation.json', TEXT, library);
	}

	// JOELwindows7: & the spritemap
	inline static public function spriteMapJson(key:String, ?library:String)
	{
		return getPath('images/$key/spritemap.json', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	static public function sound(key:String, ?library:String)
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String)
	{
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	// JOELwindows7: MIDI file in music folder, menu music MIDI
	inline static public function midiMeta(key:String, ?library:String)
	{
		return getPath('music/$key.mid', BINARY, library);
	}

	inline static public function voices(song:String, count:Int = 0)
	{
		// var songLowercase = StringTools.replace(song, " ", "-").toLowerCase();
		var songLowercase = StringTools.replace(song, " ", "-").toLowerCase() + '/Voices${count > 0 ? Std.string(count) : ""}'; // JOELwindows7: BOLO
		switch (songLowercase)
		{
			case 'dad-battle':
				songLowercase = 'dadbattle';
			case 'philly-nice':
				songLowercase = 'philly';
			case 'm.i.l.f':
				songLowercase = 'milf';
		}
		// var result = 'songs:assets/songs/${songLowercase}/Voices.$SOUND_EXT';
		// JOELwindows7 : hey, use multi voice now!
		// var result = 'songs:assets/songs/${songLowercase}/Voices${count > 0 ? Std.string(count) : ""}.$SOUND_EXT';
		// Return null if the file does not exist.
		// return doesSoundAssetExist(result) ? result : null;

		// JOElwindows7: BOLO rawly file & I add exist check.. nvm.
		var file;
		#if PRELOAD_ALL
		file = loadSound('songs', songLowercase);
		#else
		file = 'songs:assets/songs/$songLowercase.$SOUND_EXT';
		#end
		// return doesSoundAssetExist(file) ? file : file;
		return file;
	}

	// JOELwindows7: okay, other audio tracks what should it be. + BOLO
	inline static public function multiTracks(song:String, count:Int = 0)
	{
		// var songLowercase = StringTools.replace(song, " ", "-").toLowerCase();
		var songLowercase = StringTools.replace(song, " ", "-").toLowerCase() + '/MultiTracks${Std.string(count)}';
		switch (songLowercase)
		{
			case 'dad-battle':
				songLowercase = 'dadbattle';
			case 'philly-nice':
				songLowercase = 'philly';
			case 'm.i.l.f':
				songLowercase = 'milf';
		}
		// var result = 'songs:assets/songs/${songLowercase}/Voices.$SOUND_EXT';
		// JOELwindows7 : hey, use multi voice now!
		// var result = 'songs:assets/songs/${songLowercase}/MultiTracks${Std.string(count)}.$SOUND_EXT';
		// Return null if the file does not exist.
		// return doesSoundAssetExist(result) ? result : null;

		// JOElwindows7: BOLO rawly file
		var file;
		#if PRELOAD_ALL
		file = loadSound('songs', songLowercase);
		#else
		file = 'songs:assets/songs/$songLowercase.$SOUND_EXT';
		#end
		return file;
	}

	inline static public function inst(song:String)
	{
		// var songLowercase = StringTools.replace(song, " ", "-").toLowerCase();
		var songLowercase = StringTools.replace(song, " ", "-").toLowerCase() + '/Inst'; // JOELwindows7: BOLO
		switch (songLowercase)
		{
			case 'dad-battle':
				songLowercase = 'dadbattle';
			case 'philly-nice':
				songLowercase = 'philly';
			case 'm.i.l.f':
				songLowercase = 'milf';
		}
		// return 'songs:assets/songs/${songLowercase}/Inst.$SOUND_EXT';

		// JOELwindows7: BOLO
		var file;
		#if PRELOAD_ALL
		file = loadSound('songs', songLowercase);
		#else
		file = 'songs:assets/songs/$songLowercase.$SOUND_EXT';
		#end

		return file;
	}

	// JOELwindows7: copy inst but for MIDI
	inline static public function midiInst(song:String)
	{
		var songLowercase = StringTools.replace(song, " ", "-").toLowerCase();
		switch (songLowercase)
		{
			case 'dad-battle':
				songLowercase = 'dadbattle';
			case 'philly-nice':
				songLowercase = 'philly';
			case 'm.i.l.f':
				songLowercase = 'milf';
		}
		return 'songs:assets/songs/${songLowercase}/Inst.mid';
	}

	static public function listSongsToCache()
	{
		// We need to query OpenFlAssets, not the file system, because of Polymod.
		var soundAssets = OpenFlAssets.list(AssetType.MUSIC).concat(OpenFlAssets.list(AssetType.SOUND));

		// TODO: Maybe rework this to pull from a text file rather than scan the list of assets.
		var songNames = [];

		for (sound in soundAssets)
		{
			// Parse end-to-beginning to support mods.
			var path = sound.split('/');
			path.reverse();

			var fileName = path[0];
			var songName = path[1];

			if (path[2] != 'songs')
				continue;

			// Remove duplicates.
			if (songNames.indexOf(songName) != -1)
				continue;

			songNames.push(songName);
		}

		return songNames;
	}

	static public function doesSoundAssetExist(path:String)
	{
		if (path == null || path == "")
			return false;
		return OpenFlAssets.exists(path, AssetType.SOUND) || OpenFlAssets.exists(path, AssetType.MUSIC);
	}

	inline static public function doesTextAssetExist(path:String)
	{
		return OpenFlAssets.exists(path, AssetType.TEXT);
	}

	// JOELwindows7: also other is exists too pls
	inline static public function doesImageAssetExist(path:String)
	{
		return OpenFlAssets.exists(path, AssetType.IMAGE);
	}

	// JOELwidows7: as well as anything does exist..
	inline static public function doesAnythingAssetExist(path:String)
	{
		return OpenFlAssets.exists(path, AssetType.SOUND)
			|| OpenFlAssets.exists(path, AssetType.MUSIC)
			|| OpenFlAssets.exists(path, AssetType.IMAGE)
			|| OpenFlAssets.exists(path, AssetType.TEXT)
			|| OpenFlAssets.exists(path, AssetType.MOVIE_CLIP)
			|| OpenFlAssets.exists(path, AssetType.FONT)
			|| OpenFlAssets.exists(path, AssetType.BINARY);
	}

	// JOELwindows7: too long! make the shorthand.
	inline static public function exist(path:String)
	{
		return doesAnythingAssetExist(path);
	}

	// JOELwindows7: and for those who typo
	inline static public function exists(path:String)
	{
		return exist(path);
	}

	// JOELwindows7: also manually
	inline static public function manuallyExist(path:String, type:AssetType)
	{
		return OpenFlAssets.exists(path, type);
	}

	// JOELwindows7: peck it! typo too aswell!
	inline static public function manuallyExists(path:String, type:AssetType)
	{
		return manuallyExist(path, type);
	}

	inline static public function image(key:String, ?library:String)
	{
		return getPath('images/$key.png', IMAGE, library);
	}

	// JOElwindows7: COnfusingly image BOLO functions are
	inline static public function imageGraphic(key:String, ?library:String, ?gpuRender:Bool):FlxGraphic
	{
		gpuRender = gpuRender != null ? gpuRender : FlxG.save.data.gpuRender;
		var image:FlxGraphic = loadImage(key, library, gpuRender);
		return image;
	}

	// JOELwindows7: xml SparrowAtlas path
	inline static public function sparrowXml(key:String, ?library:String)
	{
		return getPath('images/$key.xml', TEXT, library);
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	// JOELwindows7: BOLO has exclude asset!!!
	// https://github.com/BoloVEVO/Kade-Engine-Public/blame/stable/source/Paths.hx
	public static function excludeAsset(key:String)
	{
		if (!dumpExclusions.contains(key))
			dumpExclusions.push(key);
	}

	// JOELwindows7: BOLO's dump exclusion thingy
	public static var dumpExclusions:Array<String> = ['assets/music/freakyMenu.$SOUND_EXT', 'assets/shared/music/breakfast.$SOUND_EXT'];

	// JOELwindows7: BOLO's star of the show, clear unused memory!!!
	/// haya I love you for the base cache dump I took to the max
	public static function clearUnusedMemory()
	{
		// clear non local assets in the tracked assets list
		var counter:Int = 0;
		for (key in currentTrackedAssets.keys())
		{
			// if it is not currently contained within the used local assets
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key))
			{
				// get rid of it
				var obj = currentTrackedAssets.get(key);
				@:privateAccess
				if (obj != null)
				{
					OpenFlAssets.cache.removeBitmapData(key);
					OpenFlAssets.cache.clear(key);
					FlxG.bitmap._cache.remove(key);
					obj.destroy();
					currentTrackedAssets.remove(key);
					counter++;
					Debug.logTrace('Cleared and removed $counter assets.');
				}
			}
		}
		// run the garbage collector for good measure lmfao

		System.gc();
	}

	public static var localTrackedAssets:Array<String> = [];

	public static function clearStoredMemory(?cleanUnused:Bool = false)
	{
		#if FEATURE_MULTITHREADING
		// clear remaining objects
		MasterObjectLoader.resetAssets();
		#end

		// clear anything not in the tracked assets list
		var counterAssets:Int = 0;
		var counterSound:Int = 0;
		@:privateAccess
		for (key in FlxG.bitmap._cache.keys())
		{
			var obj = FlxG.bitmap._cache.get(key);
			if (obj != null && !currentTrackedAssets.exists(key))
			{
				OpenFlAssets.cache.removeBitmapData(key);
				OpenFlAssets.cache.clear(key);
				FlxG.bitmap._cache.remove(key);
				obj.destroy();
				counterAssets++;
				Debug.logTrace('Cleared and removed $counterAssets cached assets.');
			}
		}

		#if PRELOAD_ALL
		// clear all sounds that are cached
		for (key in currentTrackedSounds.keys())
		{
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key) && key != null)
			{
				// trace('test: ' + dumpExclusions, key);
				Assets.cache.clear(key);
				currentTrackedSounds.remove(key);
				counterSound++;
				Debug.logTrace('Cleared and removed $counterSound cached sounds.');
			}
		}

		// Clear everything everything that's left
		var counterLeft:Int = 0;
		for (key in OpenFlAssets.cache.getKeys())
		{
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key) && key != null)
			{
				OpenFlAssets.cache.clear(key);
				counterLeft++;
				Debug.logTrace('Cleared and removed $counterLeft cached leftover assets.');
			}
		}
		// flags everything to be cleared out next unused memory clear
		localTrackedAssets = [];
		openfl.Assets.cache.clear("songs");
		#end
	}

	// JOELwindows7: BOLO's file exists!!!
	inline static public function fileExists(key:String, type:AssetType, ?library:String)
	{
		if (OpenFlAssets.exists(getPath(key, type, library)))
			return true;
		return false;
	}

	// JOELwindows7: BOLO changes
	static public function getSparrowAtlas(key:String, ?library:String, ?isCharacter:Bool = false, ?gpuRender:Bool)
	{
		gpuRender = gpuRender != null ? gpuRender : FlxG.save.data.gpuRender;
		if (isCharacter)
		{
			// return FlxAtlasFrames.fromSparrow(loadImage('characters/$key', library), file('images/characters/$key.xml', library));
			return FlxAtlasFrames.fromSparrow(imageGraphic('characters/$key', library, gpuRender), file('images/characters/$key.xml', library));
		}
		// return FlxAtlasFrames.fromSparrow(loadImage(key, library), file('images/$key.xml', library));
		return FlxAtlasFrames.fromSparrow(imageGraphic(key, library, gpuRender), file('images/$key.xml', library));
	}

	// JOELwindows7: BOLO add GPU Render

	/**
	 * Senpai in Thorns uses this instead of Sparrow and IDK why.
	 */
	inline static public function getPackerAtlas(key:String, ?library:String, ?isCharacter:Bool = false, ?gpuRender:Bool)
	{
		gpuRender = gpuRender != null ? gpuRender : FlxG.save.data.gpuRender;
		if (isCharacter)
		{
			// return FlxAtlasFrames.fromSpriteSheetPacker(loadImage('characters/$key', library), file('images/characters/$key.txt', library));
			return FlxAtlasFrames.fromSpriteSheetPacker(imageGraphic('characters/$key', library, gpuRender), file('images/characters/$key.txt', library));
		}
		// return FlxAtlasFrames.fromSpriteSheetPacker(loadImage(key, library), file('images/$key.txt', library));
		return FlxAtlasFrames.fromSpriteSheetPacker(imageGraphic(key, library, gpuRender), file('images/$key.txt', library));
	}

	// JOELwindows7: BOLO texture atlas
	inline static public function getTextureAtlas(key:String, ?library:String, ?isCharacter:Bool = false, ?excludeArray:Array<String>):FlxFramesCollection
	{
		if (isCharacter)
			return AtlasFrameMaker.construct('characters/$key', library, excludeArray);

		return AtlasFrameMaker.construct(key, library, excludeArray);
	}

	// JOELwindows7: BOLO Json atlas
	inline static public function getJSONAtlas(key:String, ?library:String, ?isCharacter:Bool = false, ?gpuRender:Bool)
	{
		gpuRender = gpuRender != null ? gpuRender : FlxG.save.data.gpuRender;
		if (isCharacter)
			return FlxAtlasFrames.fromTexturePackerJson(imageGraphic('characters/$key', library, gpuRender), file('images/characters/$key.json', library));

		return FlxAtlasFrames.fromTexturePackerJson(imageGraphic(key, library), file('images/$key.json', library));
	}

	// JOELwindows7: the get bitmap sprite sheet for pixel e.g.
	// inline static public function getBitmapSpriteSheet(key:String, ?library:String, ?isCharacter:Bool = false, ?unique:Bool = false)
	// {
	// 	if (isCharacter)
	// 	{
	// 		return FlxGraphic.getBitmap(loadImage('characters/$key', library), unique);
	// 	}
	// 	return FlxGraphic.getBitmap(loadImage(key, library), unique);
	// }
	//
	// JOELwindows7: add pathers for GrowtopiaFli video cutsceners
	inline static public function video(key:String, ?library:String)
	{
		return getPath('videos/$key.$VIDEO_EXT', TEXT, library);
	}

	inline static public function videoSound(key:String, ?library:String)
	{
		return getPath('videos/$key.ogg', SOUND, library);
	}

	// JOELwindows7: apparently BrightFyre's MP4 support video Cutscener
	inline static public function videoVlc(key:String, ?library:String)
	{
		trace('assets/videos/$key.mp4');
		return getPath('videos/$key.mp4', BINARY, library);
	}

	// JOELwindows7: BOLO webm video too
	static public function webmVideo(key:String)
	{
		return 'assets/videos/$key.webm';
	}

	// JOELwindows7: kem0x shader fragment path https://github.com/kem0x/FNF-ModShaders
	inline static public function shaderFragment(key:String, ?library:String)
	{
		return getPath('shaders/$key.frag', TEXT, library);
	}
}
