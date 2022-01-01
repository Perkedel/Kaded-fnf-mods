package;

import flixel.addons.util.FlxAsyncLoop;
import CoreState;
import MusicBeatState;
import GalleryAchievements;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import lime.app.Application;
import openfl.utils.Future;
import openfl.media.Sound;
import flixel.system.FlxSound;
#if FEATURE_STEPMANIA
import smTools.SMFile;
#end
#if FEATURE_FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end
import Song.SongData;
import flixel.input.gamepad.FlxGamepad;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
#if FEATURE_DISCORD
import Discord.DiscordClient;
#end

using StringTools;

class FreeplayState extends MusicBeatState
{
	public static var songs:Array<FreeplaySongMetadata> = [];

	var selector:FlxText;

	public static var rate:Float = 1.0;

	public static var curSelected:Int = 0;
	public static var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var comboText:FlxText;
	var diffText:FlxText;
	var diffCalcText:FlxText;
	var previewtext:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var combo:String = '';

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	public static var openedPreview = false;

	public static var songData:Map<String, Array<SongData>> = [];

	// JOELwindows7: globalize bg variable to be refered for color change
	var bg:FlxSprite;

	// JOELwindows7: week data here
	var weekInfo:SwagWeeks;

	static var legacyJSONWeekList:Bool = false; // JOELwindows7: in case you want to use the old JSONed week list.

	var asyncLoader:FlxAsyncLoop; // JOELwindows7: here loader thingy.
	var loadedUp:Bool = false; // JOELwindows7: flag to raise when loading complete.
	var legacySynchronousLoading:Bool = true; // JOELwindows7: keep false to use new async loading.

	public static function loadDiff(diff:Int, songId:String, array:Array<SongData>)
	{
		var diffName:String = "";

		switch (diff)
		{
			case 0:
				diffName = "-easy";
			case 2:
				diffName = "-hard";
		}

		array.push(Song.conversionChecks(Song.loadFromJson(songId, diffName)));
	}

	// JOELwindows7: Load week datas
	public static function loadWeekDatas(weekDatas:SwagWeeks):SwagWeeks
	{
		try
		{
			// JOELwindows7: load weeks
			if (legacyJSONWeekList)
				weekDatas = StoryMenuState.loadFromJson('weekList')
			else
			{
				// JOELwindows7: copy from StoryMenuState.hx
				Debug.logInfo("Load texted week datas");
				var weekStuffs:Array<String> = CoolUtil.coolTextFile(Paths.txt('data/weekStuffs')); // Week Display! Character & Color
				var weekLoads:Array<String> = CoolUtil.coolTextFile(Paths.txt('data/weekLoads')); // Week Loads! each lines represents songs in the week
				var weekNames:Array<String> = CoolUtil.coolTextFile(Paths.txt('data/weekNames')); // Week Names! each lines represents the name of the week

				// Chamber for datasoids
				Debug.logInfo("Preparing Chamber");
				var weekArray = new Array<Dynamic>();
				var weekCharacters = new Array<Dynamic>();
				var weekColor = new Array<String>();
				var weekBannerPath = new Array<String>();
				var weekUnderlayPath = new Array<String>();
				var weekUnlocked = new Array<Bool>();
				var weekClickSoundPath = new Array<String>();

				// separate Week things
				Debug.logInfo("Fill chamber");
				for (i in 0...weekLoads.length)
				{
					var weekLine:Array<String> = weekLoads[i].split(':');
					var weekSongs:Array<String> = new Array<String>();
					for (j in 0...weekLine.length)
					{
						var song:String = weekLine[j];
						// weekArray.push(song);
						weekSongs.push(song);
					}
					weekArray.insert(i, weekSongs);
					var lineStuffs:Array<String> = weekStuffs[i].split(':');
					weekCharacters.insert(i, [lineStuffs[0], lineStuffs[1], lineStuffs[2]]);
					weekColor.insert(i, lineStuffs[3]);
					weekBannerPath.insert(i, lineStuffs[4]);
					weekUnderlayPath.insert(i, lineStuffs[5]);
					weekClickSoundPath.insert(i, lineStuffs[6]);
					weekUnlocked.push(true);
					Debug.logInfo("Week " + Std.string(i) + ": " + weekSongs.toString() + "; line stuff = " + lineStuffs.toString());

					// Just pecking insert them now directly immediately
					// weekDatas.weekData.insert(i, weekSongs);
					// weekDatas.weekCharacters.insert(i, [lineStuffs[0], lineStuffs[1], lineStuffs[2]]);
					// weekDatas.weekColor.insert(i, lineStuffs[3]);
					// weekDatas.weekBannerPath.insert(i, lineStuffs[4]);
					// weekDatas.weekUnderlayPath.insert(i, lineStuffs[5]);
					// weekDatas.weekUnlocked.push(true);
				}

				// Also init the weekDatas
				Debug.logInfo("Preparing weekDatas");
				weekDatas = {
					weekData: weekArray,
					weekCharacters: weekCharacters,
					weekColor: weekColor,
					weekBannerPath: weekBannerPath,
					weekUnderlayPath: weekUnderlayPath,
					weekUnlocked: weekUnlocked,
					weekNames: weekNames,
					weekClickSoundPath: weekClickSoundPath
				};
				// weekDatas.weekData = new Array<Dynamic>();
				// weekDatas.weekCharacters = new Array<String>();
				// weekDatas.weekColor = new Array<String>();
				// weekDatas.weekBannerPath = new Array<String>();
				// weekDatas.weekUnderlayPath = new Array<String>();
				// weekDatas.weekUnlocked = new Array<Bool>();

				// Testing the chamber
				// Debug.logInfo("Testing Chamber");
				// for (i in 0...weekArray.length)
				// {
				// 	Debug.logInfo("Week " + Std.string(i) + ": " + weekArray[i].toString());
				// }

				// Now insert them to here
				// Debug.logInfo("Inserting into week datas");
				// weekDatas.weekData = weekArray;
				// Debug.logInfo(weekDatas.weekData.toString());
				// weekDatas.weekUnlocked = weekUnlocked;
				// Debug.logInfo(weekDatas.weekUnlocked.toString());
				// weekDatas.weekCharacters = weekCharacters;
				// Debug.logInfo(weekDatas.weekCharacters.toString());
				// weekDatas.weekNames = weekNames;
				// Debug.logInfo(weekDatas.weekNames.toString());
				// weekDatas.weekColor = weekColor;
				// Debug.logInfo(weekDatas.weekColor.toString());
				// weekDatas.weekBannerPath = weekBannerPath;
				// Debug.logInfo(weekDatas.weekBannerPath.toString());
				// weekDatas.weekUnderlayPath = weekUnderlayPath;
				// Debug.logInfo(weekDatas.weekUnderlayPath.toString());

				Debug.logInfo("Week datas loaded");
			}
			return weekDatas;
		}
		catch (ex)
		{
			// werror
			Debug.logError("wError " + ex + "\n unable to load weeklist");
			return null;
		}
	}

	public static var list:Array<String> = [];

	// JOELwindows7: globalize button variables.
	var accepted:Bool;
	var charting:Bool;

	override function create()
	{
		// JOELwindows7: seriously, cannot you just scan folders and count what folders are in it?
		clean();

		// JOELwindows7: go loading bar
		if (legacySynchronousLoading)
		{
			_loadingBar.popNow();
			_loadingBar.setLoadingType(ExtraLoadingType.VAGUE);
		}

		// JOELwindows7: pls install weekData
		weekInfo = FreeplayState.loadWeekDatas(weekInfo);

		list = CoolUtil.coolTextFile(Paths.txt('data/freeplaySonglist'));

		cached = false;

		// JOELwindows7: excuse me, just just this instead
		// if (!legacySynchronousLoading)
		// 	asyncLoader = new FlxAsyncLoop(1, asynchronouslyLoadSongList);
		// wait, wrong. in down!

		if (legacySynchronousLoading)
			populateSongData(); // JOELwindows7: uncomment for synchronous
		PlayState.inDaPlay = false;
		PlayState.currentSong = "bruh";

		if (legacySynchronousLoading)
		{
			#if !FEATURE_STEPMANIA
			trace("FEATURE_STEPMANIA was not specified during build, sm file loading is disabled.");
			#elseif FEATURE_STEPMANIA
			// TODO: Refactor this to use OpenFlAssets.
			trace("tryin to load sm files");
			_loadingBar.setInfoText("Loading StepMania files...");
			_loadingBar.setLoadingType(ExtraLoadingType.VAGUE);
			// JOELwindows7: android crash if attempt FileSystem stuffs
			for (i in FileSystem.readDirectory("assets/sm/"))
			{
				trace(i);

				if (FileSystem.isDirectory("assets/sm/" + i))
				{
					trace("Reading SM file dir " + i);
					for (file in FileSystem.readDirectory("assets/sm/" + i))
					{
						if (file.contains(" "))
							FileSystem.rename("assets/sm/" + i + "/" + file, "assets/sm/" + i + "/" + file.replace(" ", "_"));
						if (file.endsWith(".sm") && !FileSystem.exists("assets/sm/" + i + "/converted.json"))
						{
							trace("reading " + file);
							_loadingBar.setInfoText("Reading StepMania " + file + " file...");
							var file:SMFile = SMFile.loadFile("assets/sm/" + i + "/" + file.replace(" ", "_"));
							trace("Converting " + file.header.TITLE);
							_loadingBar.setInfoText("Converting StepMania " + file.header.TITLE + " file...");
							var data = file.convertToFNF("assets/sm/" + i + "/converted.json");
							var meta = new FreeplaySongMetadata(file.header.TITLE, 0, "sm", file, "assets/sm/" + i);
							songs.push(meta);
							var song = Song.loadFromJsonRAW(data);
							songData.set(file.header.TITLE, [song, song, song]);
						}
						else if (FileSystem.exists("assets/sm/" + i + "/converted.json") && file.endsWith(".sm"))
						{
							trace("reading " + file);
							_loadingBar.setInfoText("Reading StepMania " + file + " file...");
							var file:SMFile = SMFile.loadFile("assets/sm/" + i + "/" + file.replace(" ", "_"));
							trace("Converting " + file.header.TITLE);
							_loadingBar.setInfoText("Converting StepMania " + file.header.TITLE + " file...");
							var data = file.convertToFNF("assets/sm/" + i + "/converted.json");
							var meta = new FreeplaySongMetadata(file.header.TITLE, 0, "sm", file, "assets/sm/" + i);
							songs.push(meta);
							var song = Song.loadFromJsonRAW(File.getContent("assets/sm/" + i + "/converted.json"));
							trace("got content lol");
							songData.set(file.header.TITLE, [song, song, song]);
						}
					}
				}
			}
			#end
		}

		// JOELwindows7: propose odysee and thief song list
		#if odysee
		trace("Pls pull Odysee song list");
		#end

		#if thief
		trace("Pls pull stolen song list");
		#end

		#if FEATURE_DISCORD
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Freeplay Menu", null);
		#end

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

		persistentUpdate = true;

		// LOAD MUSIC

		// LOAD CHARACTERS

		// var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage('menuBGBlue'));
		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat')); // JOELwindows7: here global
		bg.antialiasing = FlxG.save.data.antialiasing;
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		// JOELwindows7: back button
		addBackButton(20, FlxG.height);
		// JOELwindows7: and difficulty button
		addLeftButton(FlxG.width - 350, -100);
		addRightButton(FlxG.width - 100, -100);

		if (legacySynchronousLoading)
		{
			for (i in 0...songs.length)
			{
				var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false, true);
				songText.isMenuItem = true;
				songText.targetY = i;
				songText.ID = i; // ID the song text to compare curSelected song.
				grpSongs.add(songText);

				var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
				icon.sprTracker = songText;
				icon.ID = i;

				// using a FlxGroup is too much fuss!
				iconArray.push(icon);
				add(icon);

				// songText.x += 40;
				// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
				// songText.screenCenter(X);
			}
		}

		scoreText = new FlxText(FlxG.width * 0.65, 5, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		// scoreText.alignment = RIGHT;

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.4), 135, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		diffCalcText = new FlxText(scoreText.x, scoreText.y + 66, 0, "", 24);
		diffCalcText.font = scoreText.font;
		add(diffCalcText);

		previewtext = new FlxText(scoreText.x, scoreText.y + 96, 0, "Rate: " + FlxMath.roundDecimal(rate, 2) + "x", 24);
		previewtext.font = scoreText.font;
		add(previewtext);

		comboText = new FlxText(diffText.x + 100, diffText.y, 0, "", 24);
		comboText.font = diffText.font;
		add(comboText);

		add(scoreText);

		if (legacySynchronousLoading)
		{
			changeSelection();
			changeDiff();
		}

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		super.create();

		FlxTween.tween(backButton, {y: FlxG.height - 100}, 2, {ease: FlxEase.elasticInOut}); // JOELwindows7: also tween back button!
		FlxTween.tween(leftButton, {y: 90}, 2, {ease: FlxEase.elasticInOut}); // JOELwindows7: also tween left button!
		FlxTween.tween(rightButton, {y: 90}, 2, {ease: FlxEase.elasticInOut}); // JOELwindows7: also tween right button!

		if (legacySynchronousLoading)
		{
			// JOELwindows7: done loading bar
			_loadingBar.setInfoText("Done loading!");
			_loadingBar.setLoadingType(ExtraLoadingType.DONE);
			_loadingBar.delayedUnPopNow(5);
		}

		// JOELwindows7: stuff
		AchievementUnlocked.whichIs("freeplay_mode");

		// JOELwindows7: excuse me, just just this instead
		if (!legacySynchronousLoading)
			asyncLoader = new FlxAsyncLoop(1, asynchronouslyLoadSongList);
		else
		{
			loadedUp = true;
			// JOELwindows7: do it again because last time it ignored because not loaded yet to this point.
			changeSelection();
			changeDiff();
		}
	}

	public static var cached:Bool = false;

	/**
	 * Load song data from the data files.
	 */
	static function populateSongData()
	{
		cached = false;
		// TODO: JOELwindows7: make this loading procedural & automatic
		Main.loadingBar.setInfoText("Loading songs...");
		Main.loadingBar.setLoadingType(ExtraLoadingType.GOING);
		list = CoolUtil.coolTextFile(Paths.txt('data/freeplaySonglist'));
		// JOELwindows7: hey, you must say goodbye to this. just load this one up from directory shall we?
		// right, how do we do this..

		songData = [];
		songs = [];

		for (i in 0...list.length)
		{
			var data:Array<String> = list[i].split(':');
			var songId = data[0];
			var meta = new FreeplaySongMetadata(songId, Std.parseInt(data[2]), data[1]);
			// JOELwindows7: loading text
			Main.loadingBar.setInfoText("Loading song " + songId + "...");
			Main.loadingBar.setPercentage((i / list.length) * 100);

			var diffs = [];
			var diffsThatExist = [];
			#if FEATURE_FILESYSTEM
			if (Paths.doesTextAssetExist(Paths.json('songs/$songId/$songId-hard')))
				diffsThatExist.push("Hard");
			if (Paths.doesTextAssetExist(Paths.json('songs/$songId/$songId-easy')))
				diffsThatExist.push("Easy");
			if (Paths.doesTextAssetExist(Paths.json('songs/$songId/$songId')))
				diffsThatExist.push("Normal");

			if (diffsThatExist.length == 0)
			{
				Debug.displayAlert(meta.songName + " Chart", "No difficulties found for chart, skipping.");
			}
			#else
			diffsThatExist = ["Easy", "Normal", "Hard"];
			#end

			if (diffsThatExist.contains("Easy"))
				FreeplayState.loadDiff(0, songId, diffs);
			if (diffsThatExist.contains("Normal"))
				FreeplayState.loadDiff(1, songId, diffs);
			if (diffsThatExist.contains("Hard"))
				FreeplayState.loadDiff(2, songId, diffs);

			meta.diffs = diffsThatExist;

			if (diffsThatExist.length != 3)
				trace("I ONLY FOUND " + diffsThatExist);

			FreeplayState.songData.set(songId, diffs);
			trace('loaded diffs for ' + songId);
			FreeplayState.songs.push(meta);

			#if FFEATURE_FILESYSTEM
			sys.thread.Thread.create(() ->
			{
				FlxG.sound.cache(Paths.inst(songId));
			});
			#else
			FlxG.sound.cache(Paths.inst(songId));
			#end
		}
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new FreeplaySongMetadata(songName, weekNum, songCharacter));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['dad'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	// JOELwindows7: stepmania loading copy into here instead
	function loadStepmania()
	{
		#if !FEATURE_STEPMANIA
		trace("FEATURE_STEPMANIA was not specified during build, sm file loading is disabled.");
		#elseif FEATURE_STEPMANIA
		// TODO: Refactor this to use OpenFlAssets.
		trace("tryin to load sm files");
		_loadingBar.setInfoText("Loading StepMania files...");
		_loadingBar.setLoadingType(ExtraLoadingType.VAGUE);
		// JOELwindows7: android crash if attempt FileSystem stuffs
		for (i in FileSystem.readDirectory("assets/sm/"))
		{
			trace(i);

			if (FileSystem.isDirectory("assets/sm/" + i))
			{
				trace("Reading SM file dir " + i);
				for (file in FileSystem.readDirectory("assets/sm/" + i))
				{
					if (file.contains(" "))
						FileSystem.rename("assets/sm/" + i + "/" + file, "assets/sm/" + i + "/" + file.replace(" ", "_"));
					if (file.endsWith(".sm") && !FileSystem.exists("assets/sm/" + i + "/converted.json"))
					{
						trace("reading " + file);
						_loadingBar.setInfoText("Reading StepMania " + file + " file...");
						var file:SMFile = SMFile.loadFile("assets/sm/" + i + "/" + file.replace(" ", "_"));
						trace("Converting " + file.header.TITLE);
						_loadingBar.setInfoText("Converting StepMania " + file.header.TITLE + " file...");
						var data = file.convertToFNF("assets/sm/" + i + "/converted.json");
						var meta = new FreeplaySongMetadata(file.header.TITLE, 0, "sm", file, "assets/sm/" + i);
						songs.push(meta);
						var song = Song.loadFromJsonRAW(data);
						songData.set(file.header.TITLE, [song, song, song]);
					}
					else if (FileSystem.exists("assets/sm/" + i + "/converted.json") && file.endsWith(".sm"))
					{
						trace("reading " + file);
						_loadingBar.setInfoText("Reading StepMania " + file + " file...");
						var file:SMFile = SMFile.loadFile("assets/sm/" + i + "/" + file.replace(" ", "_"));
						trace("Converting " + file.header.TITLE);
						_loadingBar.setInfoText("Converting StepMania " + file.header.TITLE + " file...");
						var data = file.convertToFNF("assets/sm/" + i + "/converted.json");
						var meta = new FreeplaySongMetadata(file.header.TITLE, 0, "sm", file, "assets/sm/" + i);
						songs.push(meta);
						var song = Song.loadFromJsonRAW(File.getContent("assets/sm/" + i + "/converted.json"));
						trace("got content lol");
						songData.set(file.header.TITLE, [song, song, song]);
					}
				}
			}
		}
		#end
	}

	// JOELwindows7: here list the song in that list file.
	function listTheSongs()
	{
		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false, true);
			songText.isMenuItem = true;
			songText.targetY = i;
			songText.ID = i; // ID the song text to compare curSelected song.
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;
			icon.ID = i;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}
	}

	// JOELwindows7: attempt to async the loading of this freeplay song list. use FlxAsyncLoop
	function asynchronouslyLoadSongList()
	{
		_loadingBar.setInfoText("Loading Songs");
		_loadingBar.popNow();
		_loadingBar.setLoadingType(ExtraLoadingType.VAGUE);
		Debug.logInfo("Begin Loading pls");
		// see https://github.com/HaxeFlixel/flixel-demos/blob/master/Other/FlxAsyncLoop/source/MenuState.hx
		populateSongData();
		loadStepmania();
		listTheSongs();
		Debug.logInfo("End Loading pls");
	}

	// JOELwindows7: and async complete
	function asyncCompleteLoad()
	{
		changeSelection();
		changeDiff();

		// JOELwindows7: done loading bar
		_loadingBar.setInfoText("Done loading!");
		_loadingBar.setLoadingType(ExtraLoadingType.DONE);
		_loadingBar.delayedUnPopNow(5);

		// JOELwindows7: now clean up the loader.
		asyncLoader.kill();
		asyncLoader.destroy();

		loadedUp = true;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		// JOELwindows7: now, begin the async process
		if (!legacySynchronousLoading)
		{
			if (!asyncLoader.started)
			{
				Debug.logInfo("start da loaging");
				asyncLoader.start();
			}
			else
			{
				if (asyncLoader.finished)
				{
					asyncCompleteLoad();
				}
			}
		}

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST:" + lerpScore;
		comboText.text = combo + '\n';

		if (FlxG.sound.music.volume > 0.8)
		{
			FlxG.sound.music.volume -= 0.5 * FlxG.elapsed;
		}

		// JOELwindows7: add mouse support in here
		// huh, how inconsistent. now the keypress bools are syndicated via
		// each variable. interesting.
		var upP = FlxG.keys.justPressed.UP || FlxG.mouse.wheel == 1;
		var downP = FlxG.keys.justPressed.DOWN || FlxG.mouse.wheel == -1;
		accepted = FlxG.keys.justPressed.ENTER || haveClicked; // JOELwindows7: pls globalize
		var dadDebug = FlxG.keys.justPressed.SIX;
		charting = FlxG.keys.justPressed.SEVEN || haveDebugSevened; // JOELwindows7: pls globalize
		var bfDebug = FlxG.keys.justPressed.ZERO;

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.DPAD_UP)
			{
				changeSelection(-1);
			}
			if (gamepad.justPressed.DPAD_DOWN)
			{
				changeSelection(1);
			}
			if (gamepad.justPressed.DPAD_LEFT)
			{
				changeDiff(-1);
			}
			if (gamepad.justPressed.DPAD_RIGHT)
			{
				changeDiff(1);
			}

			// if (gamepad.justPressed.X && !openedPreview)
			// openSubState(new DiffOverview());
		}

		// JOELwindows7: prevent go if shift is being held
		if (!FlxG.keys.pressed.SHIFT)
			if (upP)
			{
				changeSelection(-1);
			}
		if (downP)
		{
			changeSelection(1);
		}

		// if (FlxG.keys.justPressed.SPACE && !openedPreview)
		// openSubState(new DiffOverview());

		if (FlxG.keys.pressed.SHIFT)
		{
			if (FlxG.keys.justPressed.LEFT || FlxG.mouse.wheel == -1 || haveLefted)
			{
				rate -= 0.05;
				diffCalcText.text = 'RATING: ${DiffCalc.CalculateDiff(songData.get(songs[curSelected].songName)[curDifficulty])}';
				haveLefted = false;
			}
			if (FlxG.keys.justPressed.RIGHT || FlxG.mouse.wheel == 1 || haveRighted)
			{
				rate += 0.05;
				diffCalcText.text = 'RATING: ${DiffCalc.CalculateDiff(songData.get(songs[curSelected].songName)[curDifficulty])}';
				haveRighted = false;
			}

			if (FlxG.keys.justPressed.R || FlxG.mouse.justPressedMiddle)
			{
				rate = 1;
				diffCalcText.text = 'RATING: ${DiffCalc.CalculateDiff(songData.get(songs[curSelected].songName)[curDifficulty])}';
			}

			if (rate > 3)
			{
				rate = 3;
				diffCalcText.text = 'RATING: ${DiffCalc.CalculateDiff(songData.get(songs[curSelected].songName)[curDifficulty])}';
			}
			else if (rate < 0.5)
			{
				rate = 0.5;
				diffCalcText.text = 'RATING: ${DiffCalc.CalculateDiff(songData.get(songs[curSelected].songName)[curDifficulty])}';
			}

			previewtext.text = "Rate: " + FlxMath.roundDecimal(rate, 2) + "x";
		}
		else
		{
			if (FlxG.keys.justPressed.LEFT || haveLefted)
			{
				changeDiff(-1);
				haveLefted = false;
			}
			if (FlxG.keys.justPressed.RIGHT || FlxG.mouse.justPressedMiddle || haveRighted)
			{
				changeDiff(1);
				haveRighted = false;
			}
		}

		// JOELwindows7: there you are, audio manipulate lol
		#if FEATURE_AUDIO_MANIPULATE
		@:privateAccess
		{
			if (FlxG.sound.music.playing)
				lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, rate);
		}
		#end

		if (controls.BACK || haveBacked)
		{
			FlxG.switchState(new MainMenuState());

			haveBacked = false;
		}

		if (accepted)
			loadSong();
		else if (charting)
			loadSong(true);

		// AnimationDebug and StageDebug are only enabled in debug builds.
		#if debug
		if (dadDebug)
		{
			loadAnimDebug(true);
		}
		if (bfDebug)
		{
			loadAnimDebug(false);
		}
		#end
	}

	function loadAnimDebug(dad:Bool = true)
	{
		// First, get the song data.
		var hmm;
		try
		{
			hmm = songData.get(songs[curSelected].songName)[curDifficulty];
			if (hmm == null)
				return;
		}
		catch (ex)
		{
			return;
		}
		PlayState.SONG = hmm;

		var character = dad ? PlayState.SONG.player2 : PlayState.SONG.player1;

		LoadingState.loadAndSwitchState(new AnimationDebug(character));
	}

	function loadSong(isCharting:Bool = false)
	{
		loadSongInFreePlay(songs[curSelected].songName, curDifficulty, isCharting);

		clean();
	}

	/**
	 * Load into a song in free play, by name.
	 * This is a static function, so you can call it anywhere.
	 * @param songName The name of the song to load. Use the human readable name, with spaces.
	 * @param isCharting If true, load into the Chart Editor instead.
	 */
	public static function loadSongInFreePlay(songName:String, difficulty:Int, isCharting:Bool, reloadSong:Bool = false)
	{
		// Make sure song data is initialized first.
		if (songData == null || Lambda.count(songData) == 0)
			populateSongData();

		var currentSongData;
		try
		{
			if (songData.get(songName) == null)
				return;
			currentSongData = songData.get(songName)[difficulty];
			if (songData.get(songName)[difficulty] == null)
				return;
		}
		catch (ex)
		{
			return;
		}

		PlayState.SONG = currentSongData;
		PlayState.isStoryMode = false;
		PlayState.storyDifficulty = difficulty;
		PlayState.storyWeek = songs[curSelected].week;
		Debug.logInfo('Loading song ${PlayState.SONG.songName} from week ${PlayState.storyWeek} into Free Play...');
		#if FEATURE_STEPMANIA
		if (songs[curSelected].songCharacter == "sm")
		{
			Debug.logInfo('Song is a StepMania song!');
			PlayState.isSM = true;
			PlayState.sm = songs[curSelected].sm;
			PlayState.pathToSm = songs[curSelected].path;
		}
		else
			PlayState.isSM = false;
		#else
		PlayState.isSM = false;
		#end
		// trace("Loaded Song into Playstate " + (FlxG.save.data.traceSongChart ? Std.string(hmm) : "bla bla bla")); // JOELwindows7: what hapened

		PlayState.songMultiplier = rate;

		if (isCharting)
			LoadingState.loadAndSwitchState(new ChartingState(reloadSong));
		else
			LoadingState.loadAndSwitchState(new PlayState());
	}

	function changeDiff(change:Int = 0)
	{
		// JOELwindows7: only proceed if loaded
		if (!loadedUp)
			return;

		if (!songs[curSelected].diffs.contains(CoolUtil.difficultyFromInt(curDifficulty + change)))
			return;

		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		// adjusting the highscore song name to be compatible (changeDiff)
		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");
		switch (songHighscore)
		{
			case 'Dad-Battle':
				songHighscore = 'Dadbattle';
			case 'Philly-Nice':
				songHighscore = 'Philly';
			case 'M.I.L.F':
				songHighscore = 'Milf';
		}

		#if !switch
		intendedScore = Highscore.getScore(songHighscore, curDifficulty);
		combo = Highscore.getCombo(songHighscore, curDifficulty);
		#end
		diffCalcText.text = 'RATING: ${DiffCalc.CalculateDiff(songData.get(songs[curSelected].songName)[curDifficulty])}';
		diffText.text = CoolUtil.difficultyFromInt(curDifficulty).toUpperCase();
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		// JOELwindows7: only proceed if loaded
		if (!loadedUp)
			return;

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		if (songs[curSelected].diffs.length != 3)
		{
			switch (songs[curSelected].diffs[0])
			{
				case "Easy":
					curDifficulty = 0;
				case "Normal":
					curDifficulty = 1;
				case "Hard":
					curDifficulty = 2;
			}
		}

		// selector.y = (70 * curSelected) + 30;

		// adjusting the highscore song name to be compatible (changeSelection)
		// would read original scores if we didn't change packages
		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");
		switch (songHighscore)
		{
			case 'Dad-Battle':
				songHighscore = 'Dadbattle';
			case 'Philly-Nice':
				songHighscore = 'Philly';
			case 'M.I.L.F':
				songHighscore = 'Milf';
		}

		#if !switch
		intendedScore = Highscore.getScore(songHighscore, curDifficulty);
		combo = Highscore.getCombo(songHighscore, curDifficulty);
		// lerpScore = 0;
		#end

		diffCalcText.text = 'RATING: ${DiffCalc.CalculateDiff(songData.get(songs[curSelected].songName)[curDifficulty])}';
		diffText.text = CoolUtil.difficultyFromInt(curDifficulty).toUpperCase();

		#if PRELOAD_ALL
		if (songs[curSelected].songCharacter == "sm")
		{
			#if FEATURE_STEPMANIA // JOELwindows7: froget the filter lmao
			var data = songs[curSelected];
			trace("Loading " + data.path + "/" + data.sm.header.MUSIC);
			var bytes = File.getBytes(data.path + "/" + data.sm.header.MUSIC);
			var sound = new Sound();
			sound.loadCompressedDataFromByteArray(bytes.getData(), bytes.length);
			FlxG.sound.playMusic(sound);
			#end
		}
		else
			FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
		#end

		var hmm;
		try
		{
			hmm = songData.get(songs[curSelected].songName)[curDifficulty];
			if (hmm != null)
			{
				Conductor.changeBPM(hmm.bpm);
				GameplayCustomizeState.freeplayBf = hmm.player1;
				GameplayCustomizeState.freeplayDad = hmm.player2;
				GameplayCustomizeState.freeplayGf = hmm.gfVersion;
				GameplayCustomizeState.freeplayNoteStyle = hmm.noteStyle;
				GameplayCustomizeState.freeplayStage = hmm.stage;
				GameplayCustomizeState.freeplaySong = hmm.songId;
				GameplayCustomizeState.freeplayWeek = songs[curSelected].week;
			}
		}
		catch (ex)
		{
		}

		if (openedPreview)
		{
			closeSubState();
			openSubState(new DiffOverview());
		}

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}

		// JOELwindows7: now change bg color based on what week did this on
		changeColorByWeekOf(curSelected);
	}

	// JOELwindows7: copy from above but this time it set selection number
	function goToSelection(change:Int = 0)
	{
		#if newgrounds
		// NGio.logEvent('Fresh');
		#end

		// NGio.logEvent('Fresh');
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		// JOELwindows7: only proceed if loaded
		if (!loadedUp)
			return;

		curSelected = change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		// lerpScore = 0;
		#end

		#if PRELOAD_ALL
		FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}

		// JOELwindows7: now change bg color based on what week did this on
		changeColorByWeekOf(curSelected);
	}

	function changeColorByWeekOf(which:Int = 0)
	{
		var colores:FlxColor = FlxColor.fromString("purple");
		if (bg != null)
			if (which <= -1)
			{
				colores = FlxColor.fromString("purple");
				// bg.color = FlxColor.fromString("purple");
			}
			else
			{
				try
				{
					colores = FlxColor.fromString(weekInfo.weekColor[songs[which].week]);
					// bg.color = FlxColor.fromString(weekInfo.weekColor[songs[which].week]);
				}
				catch (e)
				{
					Debug.logError("error Week color selection no. " + Std.string(curSelected) + ". " + e);
					Debug.logInfo("Week datas " + Std.string(weekInfo));
					// FlxG.log.warn(e);
					// bg.color = FlxColor.fromString("purple");
					colores = FlxColor.fromString("purple");
				}
			}

		// FlxTween.tween(bg.color, {redFloat: colores.redFloat, greenFloat: colores.greenFloat, blueFloat: colores.blueFloat}, 1, {ease: FlxEase.elasticInOut});
		// FlxTween.tween(bg.color, {redFloat: colores.redFloat}, 1, {ease: FlxEase.elasticInOut});
		// FlxTween.tween(bg.color, {greenFloat: colores.greenFloat}, 1, {ease: FlxEase.elasticInOut});
		// FlxTween.tween(bg.color, {redFloat: colores.redFloat}, 1, {ease: FlxEase.elasticInOut});
		// FlxTween.tween(bg, {
		// 	color:{
		// 	redFloat: colores.redFloat,
		// 	greenFloat: colores.greenFloat,
		// 	blueFloat: colores.blueFloat
		// 	}
		// }, 1, {ease: FlxEase.elasticInOut});
		FlxTween.color(bg, 1, bg.color, colores, {ease: FlxEase.linear}); // JOELwindows7: FINALLY!!!
		// bg.color = colores;
	}

	override function manageMouse()
	{
		if (accepted || charting)
		{
			// JOELwindows7: invisiblize the mouse after accepted
			FlxG.mouse.visible = false;

			haveClicked = false;
			haveDebugSevened = false;
		}
		else
		{
			// JOELwindows7: make mouse visible when moved.
			if (FlxG.mouse.justMoved)
			{
				// trace("mouse moved");
				FlxG.mouse.visible = true;
			}
			// JOELwindows7: detect any keypresses or any button presses
			if (FlxG.keys.justPressed.ANY)
			{
				// lmao! inspire from GameOverState.hx!
				FlxG.mouse.visible = false;
			}
			if (FlxG.gamepads.lastActive != null)
			{
				if (FlxG.gamepads.lastActive.justPressed.ANY)
				{
					FlxG.mouse.visible = false;
				}
				// peck this I'm tired! plns work lol
			}
		}

		// if Mouse mode is active (detecting by when it's visible now)
		// do something for mouse
		if (FlxG.mouse.visible)
		{
			var givThing:Bool = false;
			var givIcon:Bool = false;

			// JOELwindows7: mouse support
			grpSongs.forEach(function(thing:Alphabet)
			{
				if (FlxG.mouse.overlaps(thing) && !FlxG.mouse.overlaps(backButton) && !FlxG.mouse.overlaps(leftButton) && !FlxG.mouse.overlaps(rightButton))
				{
					givThing = true;
					if (FlxG.mouse.justPressed)
					{
						if (thing.ID == curSelected)
						{
							// run the song
							haveClicked = true;
						}
						else
						{
							// go to the song
							goToSelection(thing.ID);
						}
					}
				}
			});

			// JOELwindows7: same mouse support, for icons too as well!
			for (i in 0...iconArray.length)
			{
				if (FlxG.mouse.overlaps(iconArray[i]) && !FlxG.mouse.overlaps(backButton) && !FlxG.mouse.overlaps(leftButton)
					&& !FlxG.mouse.overlaps(rightButton))
				{
					givIcon = true;
					if (FlxG.mouse.justPressed)
					{
						if (iconArray[i].ID == curSelected)
						{
							// run the song
							haveClicked = true;
						}
						else
						{
							// go to the song
							goToSelection(iconArray[i].ID);
						}
					}
				}
			}
			// I'm afraid adding more `for` could kill performance here
			// help!
			// Back buttoner
			if (FlxG.mouse.overlaps(backButton) && !givThing && !givIcon)
			{
				if (FlxG.mouse.justPressed)
					if (!haveBacked)
					{
						haveBacked = true;
					}
			}

			// Diff Buttoner
			if (FlxG.mouse.overlaps(leftButton) && !givThing && !givIcon)
			{
				if (FlxG.mouse.justPressed)
					if (!haveLefted)
					{
						haveLefted = true;
					}
			}
			if (FlxG.mouse.overlaps(rightButton) && !givThing && !givIcon)
			{
				if (FlxG.mouse.justPressed)
					if (!haveRighted)
					{
						haveRighted = true;
					}
			}
		}
		super.manageMouse();
	}
}

class FreeplaySongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	#if FEATURE_STEPMANIA
	public var sm:SMFile;
	public var path:String;
	#end
	public var songCharacter:String = "";

	public var diffs = [];

	#if FEATURE_STEPMANIA
	public function new(song:String, week:Int, songCharacter:String, ?sm:SMFile = null, ?path:String = "")
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.sm = sm;
		this.path = path;
	}
	#else
	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
	}
	#end
}
