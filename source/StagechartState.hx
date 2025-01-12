// this file is for Stage chart things, this is to declutter ModchartState.hx
// Lua
// JOELwindows7: okay, please widen the area of support for macOS and Linux too.
// dang failed. I guess we go back to only Windows..
import Character;
import openfl.display3D.textures.VideoTexture;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
#if FEATURE_LUAMODCHART // LuaJit only works for C++
// https://lib.haxe.org/p/linc_luajit/
import flixel.tweens.FlxEase;
import openfl.filters.ShaderFilter;
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
#end
import haxe.Json;
import haxe.format.JsonParser;
import tjson.TJSON;
import lime.utils.Assets;

using StringTools;

// JOELwindows7: inspire from Song.hx
// enum BackgroundMode {GRAPHIC; MAKE;}

typedef SwagBackground =
{
	var callName:String;
	var generateMode:Bool;
	var graphic:String;
	var active:Bool;
	var isXML:Bool;
	var ?AtlasType:String;
	var ?extraAtlases:Array<ExtraAtlasAssets>;

	var ?hasExtraAtlases:Bool;
	var frameXMLName:String;
	var prefixXMLName:String;
	var frameRate:Int;
	var mirrored:Bool;
	var position:Array<Float>;
	var scrollFactor:Array<Float>;
	var size:Array<Float>;
	var scale:Array<Float>;
	var colorable:Bool;
	var initColor:String;
	var initVisible:Bool;
	var antialiasing:Bool;
	var hasTrail:Bool;
	var layInFrontNow:Bool; // Lay this in front
	var inFrontOfWhich:Int; // in front of which?
	/* in Front of which index?
		0 = gf
		1 = dad
		2 = bf
	 */
};

typedef SwagStage =
{
	var name:String;

	var useStageScript:Bool;
	var backgroundImages:Array<SwagBackground>;
	var isHalloween:Bool;
	// var halloweenLevel:Bool;
	var defaultCamZoom:Float;
	var bfPosition:Array<Float>;
	var gfPosition:Array<Float>;
	var dadPosition:Array<Float>;
	var bfHasTrail:Bool;
	var gfHasTrail:Bool;
	var dadHasTrail:Bool;
	var forceLuaModchart:Bool;
	var forceHscriptModchart:Bool;
	var ignoreMainImages:Bool;
	var overrideCamFollowP1:Bool;
	var overrideCamFollowP2:Bool;
	var camFollowP1Pos:Array<Float>;
	var camFollowP2Pos:Array<Float>;
};

class StageChart
{
	public var useStageScript:Bool = false;
	public var name:String = "anStage";
	public var backgroundImages:Array<SwagBackground>;
	public var isHalloween:Bool = false;

	public var defaultCamZoom:Float = 0.9;

	public var bfPosition:Array<Float> = [500, 0];
	public var gfPosition:Array<Float> = [0, 100];
	public var dadPosition:Array<Float> = [-300, 0];

	public var forceLuaModchart:Bool = false;
	public var forceHscriptModchart:Bool = false;

	public var ignoreMainImages:Bool = false;

	public var overrideCamFollowP1:Bool = false;
	public var overrideCamFollowP2:Bool = false;

	public var camFollowP1Pos:Array<Float> = [0, 0];
	public var camFollowP2Pos:Array<Float> = [0, 0];

	public function new(name:String = "anStage", backgroundImages:Array<SwagBackground>, isHalloween:Bool = false)
	{
		this.name = name;
		this.backgroundImages = backgroundImages;
		this.isHalloween = isHalloween;
	}

	public static function loadFromJson(jsonInput:String):SwagStage
	{
		trace(jsonInput);

		trace('loading stageChart ' + jsonInput.toLowerCase());

		var rawJson = Assets.getText(Paths.json(jsonInput.toLowerCase())).trim();

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
			// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
		}

		// FIX THE CASTING ON WINDOWS/NATIVE
		// Windows???
		// trace(songData);

		// trace('LOADED FROM JSON: ' + songData.notes);
		/* 
			for (i in 0...songData.notes.length)
			{
				trace('LOADED FROM JSON: ' + songData.notes[i].sectionNotes);
				// songData.notes[i].sectionNotes = songData.notes[i].sectionNotes
			}

				daNotes = songData.notes;
				daSong = songData.song;
				daBpm = songData.bpm; */

		return parseJSONshit(rawJson);
	}

	public static function parseJSONshit(rawJson:String):SwagStage
	{
		// var swagShit:SwagStage = cast Json.parse(rawJson).stage;
		var swagShit:SwagStage = cast TJSON.parse(rawJson).stage; // Use TJSON instead of regular HaxeJSON, I think..
		return swagShit;
	}
}

// JOELwindows7: use modChart state class for the stage script!
