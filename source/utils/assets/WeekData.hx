package utils.assets;

// JOELwindows7: https://github.com/Altronix-Team/FNF-AltronixEngine/blob/main/source/data/WeekData.hx
#if sys
import sys.FileSystem;
import sys.io.File;
#end
import haxe.Json;
import haxe.format.JsonParser;
import tjson.TJSON;
import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;

typedef WeekFile =
{
	var songs:Array<String>;
	var weekCharacters:Array<String>;
	var ?weekBackground:String;
	var weekBefore:String;
	var ?storyName:String;
	var difficulties:String;
	var ?weekImage:String;
	var ?weekColor:String;
	var ?weekClickSound:String;
}

class WeekData
{
	public static var weeksLoaded:Map<String, WeekData> = new Map<String, WeekData>();
	public static var weeksList:Array<String> = [];

	public var folder:String = '';

	// JSON variables
	public var songs:Array<String>;
	public var weekCharacters:Array<String>;
	public var weekBackground:String;
	public var weekColor:String;
	public var weekBefore:String;
	public var storyName:String;
	public var difficulties:String;
	public var weekImage:String;
	public var weekClickSound:String;

	public var fileName:String;

	public var fileItself:WeekFile; // JOELwindows7: For clarification

	public static function createWeekFile():WeekFile
	{
		var weekFile:WeekFile = {
			songs: ["Bopeebo", "Fresh", "Dad Battle"],
			weekCharacters: ['dad', 'bf', 'gf'],
			weekBackground: 'Dad',
			weekBefore: 'tutorial',
			weekImage: 'week1',
			weekColor: '#F9CF51',
			weekClickSound: 'confirmMenu',
			storyName: 'Your New Week',
			difficulties: 'Easy, Normal, Hard, Hard P'
		};
		return weekFile;
	}

	// HELP: Is there any way to convert a WeekFile to WeekData without having to put all variables there manually? I'm kind of a noob in haxe lmao
	public function new(weekFile:WeekFile, fileName:String)
	{
		songs = weekFile.songs;
		weekCharacters = weekFile.weekCharacters;
		weekBackground = weekFile.weekBackground;
		weekBefore = weekFile.weekBefore;
		storyName = weekFile.storyName;
		difficulties = weekFile.difficulties;
		weekImage = weekFile.weekImage;
		weekColor = weekFile.weekColor;
		weekClickSound = weekFile.weekClickSound;
		// JOELwindows7: Sorry, Max, idk too aswell, AFAIK. maybe just.. have the weekFile variable to itself at one final point.
		fileItself = weekFile;

		this.fileName = fileName;
	}

	static var defaultWeeks:Array<String> = ['tutorial', 'week1', 'week2', 'week3', 'week4', 'week5', 'week6', 'week7'];

	public static function reloadWeekFiles(isStoryMode:Null<Bool> = false)
	{
		trace('Lets reload week files');
		weeksList = [];
		weeksLoaded.clear();

		var sexList:Array<String> = listWeeks();
		trace('WeekData: Weeks consists of\n${sexList}');
		for (i in 0...sexList.length)
		{
			var fileToCheck:String = Paths.json('weeks/${sexList[i]}');
			if (!weeksLoaded.exists(sexList[i]))
			{
				var week:WeekFile = getWeekFile(fileToCheck);
				if (week != null)
				{
					var weekFile:WeekData = new WeekData(week, sexList[i]);
					if (weekFile != null)
					{
						// trace('push konka');
						weeksLoaded.set(sexList[i], weekFile);
						weeksList.push(sexList[i]);
					}
				}
			}
			trace('Week ${i}: ${sexList[i]}\n${weeksLoaded.get(weeksList[i])}');
		}
		trace('Weeks Loaded: ${weeksLoaded.toString()}');
	}

	static function listWeeks():Array<String>
	{
		var returnArr:Array<String> = [];
		var mods:Array<String> = listWeeksInPath('data/weeks/');
		trace('List Weeks:\n${mods}');

		returnArr = defaultWeeks;

		for (i in mods)
		{
			returnArr.push(i);
		}

		return returnArr;
	}

	/**
	 * List all the data JSON files under a given subdirectory.
	 * @param path The path to look under.
	 * @return The list of JSON files under that path.
	 */
	static function listWeeksInPath(path:String)
	{
		trace('hey list the week at ${path}');
		var library = OpenFlAssets.getLibrary("default");
		var dataAssets = library.list(null);
		// trace('Listing Weeks in Path ${path}:\n${dataAssets}');

		var queryPath = '${path}';

		var results:Array<String> = [];

		for (data in dataAssets)
		{
			// if (data.contains("/assets/"))
			// 	continue;
			// if (!data.contains('/assets/${path}'))
			// 	continue;
			// trace('listing path week ${data}');

			if (data.indexOf(queryPath) != -1
				&& data.endsWith('.json')
				&& !results.contains(data.substr(data.indexOf(queryPath) + queryPath.length).replaceAll('.json', '')))
			{
				var suffixPos = data.indexOf(queryPath) + queryPath.length;
				if (!defaultWeeks.contains(data.substr(suffixPos).replaceAll('.json', '')))
				{
					results.push(data.substr(suffixPos).replaceAll('.json', ''));
					trace('Weeksin JSONing: ${results}');
				}
			}
		}
		trace('List Weeks in Path we got:\n${results}');
		return results;
	}

	private static function addWeek(weekToCheck:String, path:String, directory:String, i:Int, originalLength:Int)
	{
		if (!weeksLoaded.exists(weekToCheck))
		{
			var week:WeekFile = getWeekFile(path);
			if (week != null)
			{
				var weekFile:WeekData = new WeekData(week, weekToCheck);
				weeksLoaded.set(weekToCheck, weekFile);
				weeksList.push(weekToCheck);
			}
		}
	}

	private static function getWeekFile(path:String):WeekFile
	{
		var rawJson:String = null;
		if (OpenFlAssets.exists(path))
		{
			rawJson = Assets.getText(path);
		}

		if (rawJson != null && rawJson.length > 0)
		{
			return cast TJSON.parse(rawJson);
		}
		return null;
	}
}
