package;

import openfl.display.BitmapData;
import flixel.FlxSprite;
import lime.utils.Assets;
import lime.system.System;
import tjson.TJSON;
import openfl.utils.Assets as OpenFlAssets;
import Song.SongData;

using StringTools;

class CoolUtil
{
	public static var difficultyArray:Array<String> = ['Easy', "Normal", "Hard"];

	public static var suffixDiffsArray:Array<String> = ['-easy', "", "-hard"]; // JOELwindows7: BOLO

	public static var daPixelZoom:Float = 6;

	public static function difficultyFromInt(difficulty:Int):String
	{
		// JOELwindows7: But first, refresh based on current language!
		difficultyArray = [
			getText("$GAMEPLAY_DIFFICULTY_EASY"), // Easy
			getText("$GAMEPLAY_DIFFICULTY_MEDIUM"), // Normal
			getText("$GAMEPLAY_DIFFICULTY_HARD"), // Hard
			getText("$GAMEPLAY_DIFFICULTY_INSANE"), // Pro
			getText("$GAMEPLAY_DIFFICULTY_IMPOSSIBLE"), // Errected
		];
		return difficultyArray[difficulty];
	}

	public static function coolTextFile(path:String):Array<String>
	{
		// JOELwindows7: WHoahoho, calm down buddy, sometimes it could not be found! BOLO here fix
		// var daList:Array<String> = OpenFlAssets.getText(path).trim().split('\n');
		var daList:Array<String>;

		try
		{
			daList = OpenFlAssets.getText(path).trim().split('\n');
		}
		catch (e)
		{
			Debug.logError('WERROR Cool Text File! ${e.message}\n${e.details()}');
			daList = null;
		}

		// JOELwindows7: only do this if not null! BOLO
		if (daList != null)
			for (i in 0...daList.length)
			{
				daList[i] = daList[i].trim();
			}

		return daList;
	}

	public static function coolStringFile(path:String):Array<String>
	{
		// JOELwindows7: Hey, fix this up too!
		// var daList:Array<String> = path.trim().split('\n');
		var daList:Array<String>;

		try
		{
			daList = path.trim().split('\n');
		}
		catch (e)
		{
			Debug.logError('WERROR Cool String File! ${e.message}\n${e.details()}');
			daList = null;
			// wait we're talking just string or what?
		}

		if (daList != null)
			for (i in 0...daList.length)
			{
				daList[i] = daList[i].trim();
				// we're talking that string. not file open.
			}

		// eh, whatever.
		return daList;
	}

	// public static function coolLyricFile(path:String, onSong:String):Array<Array<String>>
	// public static function coolLyricFile(path:String):Array<Array<String>>
	// {
	// 	// JOELwindows7: here it is. Kpop lyric file.
	// 	var daList:Array<Array<String>> = new Array<Array<String>>();
	// 	try
	// 	{
	// 		var stood:Array<String> = CoolUtil.coolTextFile(Path.getKpopLyric(path));
	// 		for (i in 0...stood.length)
	// 		{
	// 			daList[i] = stood[i].trim().split('::');
	// 		}
	// 	}
	// 	catch (e)
	// 	{
	// 		Debug.logError('WERROR Cool Text File! ${e.message}\n${e.details()}');
	// 		daList = [['a', '...'], ['b', '...']];
	// 	}
	// 	return daList;
	// }
	// JOELwindows7: Pls standalone FireTongue Text
	public static function coolFireTongueText(Flag:String, Context:String = "ui", Safe:Bool = true)
	{
		try
		{
			if (Main.tongue != null)
				return Main.tongue.get(Flag, Context, Safe);
		}
		catch (e)
		{
		}
		return Flag;
	}

	// JOELwindows7: Alias FireTongue
	public static function getText(Flag:String, Context:String = "ui", Safe:Bool = true)
	{
		return coolFireTongueText(Flag, Context, Safe);
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	// JOELwindows7: BOLO incoming stuff
	// https://github.com/BoloVEVO/Kade-Engine-Public/blob/stable/source/CoolUtil.hx
	inline public static function boundTo(value:Float, min:Float, max:Float):Float
	{
		return Math.max(min, Math.min(max, value));
	}

	public static function dashToSpace(string:String):String
	{
		return string.replace("-", " ");
	}

	public static function spaceToDash(string:String):String
	{
		return string.replace(" ", "-");
	}

	public static function swapSpaceDash(string:String):String
	{
		return StringTools.contains(string, '-') ? dashToSpace(string) : spaceToDash(string);
	}

	// end BOLO stuff
	// JOELwindows7: Because BOLO uses curStep times round in which what step where times song multipler
	// here we have handidover fancy
	inline public static function mRoundSmul(stepWhich:Int, yourSongMultiplier:Float):Float
	{
		return Math.round(stepWhich * yourSongMultiplier);
	}

	// JOELwindows7: also you know what, let's make it easy shall we?
	// okay, so complicated. so it's up to you use it or not.
	inline public static function stepModulo(yourCurStep:Int, stepWhich:Int, yourSongMultiplier:Float, equalsWhat:Float = 0):Bool
	{
		return yourCurStep % mRoundSmul(stepWhich, yourSongMultiplier) == equalsWhat;
	}

	// JOELwindows7: the step compare like BOLO did.
	inline public static function stepCompare(yourCurStep:Int, stepWhich:Int, yourSongMultiplier:Float, compareType:CompareTypes):Bool
	{
		return switch (compareType)
		{
			case MORE:
				yourCurStep > Math.round(stepWhich * yourSongMultiplier);
			case LESSER:
				yourCurStep < Math.round(stepWhich * yourSongMultiplier);
			case MORE_EQUALS:
				yourCurStep >= Math.round(stepWhich * yourSongMultiplier);
			case LESSER_EQUALS:
				yourCurStep <= Math.round(stepWhich * yourSongMultiplier);
			case EQUALS:
				yourCurStep == Math.round(stepWhich * yourSongMultiplier);
			case NOT_EQUALS:
				yourCurStep != Math.round(stepWhich * yourSongMultiplier);
			default:
				yourCurStep == Math.round(stepWhich * yourSongMultiplier);
		}
	}

	// JOELwindows7: Oh, you need the numbered version? okeh..
	inline public static function stepCompareInt(yourCurStep:Int, stepWhich:Int, yourSongMultiplier:Float, compareType:Int)
	{
		return stepCompare(yourCurStep, stepWhich, yourSongMultiplier, switch (compareType)
		{
			case 0:
				MORE;
			case 1:
				LESSER;
			case 2:
				MORE_EQUALS;
			case 3:
				LESSER_EQUALS;
			case 4:
				EQUALS;
			case 5:
				NOT_EQUALS;
			default:
				EQUALS;
		});
	}

	// JOELwindows7: wait, you might wanna the string version yess!!!
	inline public static function stepCompareStr(yourCurStep:Int, stepWhich:Int, yourSongMultiplier:Float, compareType:String)
	{
		return stepCompare(yourCurStep, stepWhich, yourSongMultiplier, switch (compareType.toLowerCase())
		{
			case 'more' | '>':
				MORE;
			case 'lesser' | '<' | 'less':
				LESSER;
			case 'more_equals' | '>=':
				MORE_EQUALS;
			case 'lesser_equals' | '<=':
				LESSER_EQUALS;
			case 'equals' | '==':
				EQUALS;
			case 'not_equals' | '!=':
				NOT_EQUALS;
			default:
				EQUALS;
		});
	}

	// JOELwindows7: OH WOW, got an idea!! step between yess!!!
	inline public static function stepBetween(yourCurStep:Int, stepLeft:Int, stepRight:Int, yourSongMultiplier:Float, withEquals:Bool = false,
			leftEquals:Bool = true, rightEquals:Bool = true):Bool
	{
		return stepCompare(yourCurStep, stepLeft, yourSongMultiplier, withEquals && leftEquals ? MORE_EQUALS : MORE)
			&& stepCompare(yourCurStep, stepRight, yourSongMultiplier, withEquals && rightEquals ? LESSER_EQUALS : LESSER);
	}

	// JOELwindows7: Oh this is lowercasify & turn space to dash.
	public static function toCompatCase(daString:String):String
	{
		return StringTools.replace(daString, " ", "-").toLowerCase();
	}

	// JOELwindows7: steal BulbyVR FNFM+ for compatibility
	public static function clamp(mini:Float, maxi:Float, value:Float):Float
	{
		return Math.min(Math.max(mini, value), maxi);
	}

	public static function parseJson(json:String):Dynamic
	{
		// the reason we do this is to make it easy to swap out json parsers
		return TJSON.parse(json);
	}

	public static function stringifyJson(json:Dynamic, ?fancy:Bool = true):String
	{
		// use tjson to prettify it
		var style:String = if (fancy) 'fancy' else null;
		return TJSON.encode(json, style);
	}

	// JOELwindows7: BOLO's way of selecting & playing main menu song based on watermark situation
	public static function playMainMenuSong(volume:Float = 1)
	{
		var chooseMusicPath:String;
		var chooseMusicBpm:Float;
		switch (FlxG.save.data.kadeMusic)
		{
			case 0:
				chooseMusicPath = "freakyMenu";
				chooseMusicBpm = 102;
			case 1:
				chooseMusicPath = "ke_freakyMenu";
				chooseMusicBpm = 102;
			default:
				chooseMusicPath = "freakyMenu";
				chooseMusicBpm = 102;
		}
		// if (MainMenuState.freakyPlaying)
		// {
		if (FlxG.sound.music != null)
		{
			// TODO: if there is menu with different BPM, get this handled! maybe use table list of BPM with its event of BPM change idk..
			if (!FlxG.sound.music.playing)
			{
				// FlxG.sound.playMusic(Paths.music(FlxG.save.data.watermark ? "ke_freakyMenu" : "freakyMenu"));
				FlxG.sound.playMusic(Paths.music(chooseMusicPath), 0);
				// Conductor.changeBPM(102);
				Conductor.changeBPM(chooseMusicBpm);
				MainMenuState.freakyPlaying = true;
			}
		}
		// }
	}

	// JOELwindows7: Portable song data cleaner
	public static function cleanedSongData(SONG:SongData, ?reallyCleanTheSong = false):SongData
	{
		// take from Pogger in Playstate
		var notes = [];

		var cleanedSong:SongData = SONG;

		for (section in cleanedSong.notes)
		{
			var removed = [];

			for (note in section.sectionNotes)
			{
				// commit suicide
				var old = note[0];
				if (note[0] < section.startTime)
				{
					notes.push(note);
					removed.push(note);
				}
				if (note[0] > section.endTime)
				{
					notes.push(note);
					removed.push(note);
				}
			}

			for (i in removed)
			{
				section.sectionNotes.remove(i);
			}
		}

		for (section in cleanedSong.notes)
		{
			var saveRemove = [];

			for (i in notes)
			{
				if (i[0] >= section.startTime && i[0] < section.endTime)
				{
					saveRemove.push(i);
					section.sectionNotes.push(i);
				}
			}

			for (i in saveRemove)
				notes.remove(i);
		}

		trace("FUCK YOU BITCH FUCKER CUCK SUCK BITCH " + cleanedSong.notes.length);

		return cleanedSong;
	}
}

// JOELwindows7: another more things like compare type
// compare types
enum CompareTypes
{
	EQUALS;
	NOT_EQUALS;
	MORE;
	LESSER;
	MORE_EQUALS;
	LESSER_EQUALS;
}
