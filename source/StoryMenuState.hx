package;

import utils.assets.WeekData;
import flixel.addons.ui.FlxUIText;
import flixel.addons.ui.FlxUISprite;
import ui.states.IBGColorTweening;
import flixel.tweens.misc.ColorTween;
import Options.LockWeeksOption;
import CoreState;
import GalleryAchievements;
import flixel.tweens.FlxEase;
import lime.utils.Assets;
import flixel.input.actions.FlxActionManager.ActionSetJson;
import flixel.input.gamepad.FlxGamepad;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
import haxe.Json;
import haxe.format.JsonParser;
import tjson.TJSON;
#if FEATURE_DISCORD
import Discord.DiscordClient;
#end
#if FEATURE_VLC
// import vlc.MP4Handler; // wJOELwindows7: BrightFyre & PolybiusProxy hxCodec
// import vlc.MP4Sprite; // yep.
// import VideoHandler as MP4Handler; // wJOELwindows7: BrightFyre & PolybiusProxy hxCodec
// import VideoSprite as MP4Sprite; // yep.
import hxcodec.flixel.FlxVideo as MP4Handler; // wJOELwindows7: BrightFyre & PolybiusProxy hxCodec
import hxcodec.flixel.FlxVideoSprite as MP4Sprite; // yep.

#end
using StringTools;

// JOELwindows7: FlxUI fy here yeah!
class StoryMenuState extends MusicBeatState implements IBGColorTweening
{
	var scoreText:FlxUIText;

	// JOELwindows7: ahei. so, we have already make the week list as a json file.
	// therefore, you just have to do edit assets/data/weekList.json (rendered version)
	// and follow the way it works like the tutorial. also, use "" instead of '',
	// because JSON only consider value a string and variable name like that with "".
	// have fun!
	// wait. it's already covered?
	static var weekDatas:Array<Dynamic>; // nope. only week names. they also borked weekData variable.

	// non-gamer move lol! you supposed to let it be filed procedural!!!
	static function weekData(hardcoded:Bool = false):Array<Dynamic>
	{
		if (hardcoded)
			return [
				['tutorial'],
				['bopeebo', 'fresh', 'dadbattle'],
				['spookeez', 'south', "monster"],
				['pico', 'philly', "blammed"],
				['satin-panties', "high", "milf"],
				['cocoa', 'eggnog', 'winter-horrorland'],
				['senpai', 'roses', 'thorns'],
				['ugh', 'guns', 'stress'],
				['windfall', 'rule-the-world', 'well-meet-again'],
			];
		else
			return weekDatas;
	}

	// JOELwindows7: yeah, so, these hard code edit no longer needed.
	var curDifficulty:Int = 1;

	public static var weekUnlocked:Array<Bool> = [];

	var weekCharacters:Array<Dynamic> = [
		['', 'bf', 'gf'],
		['dad', 'bf', 'gf'],
		['spooky', 'bf', 'gf'],
		['pico', 'bf', 'gf'],
		['mom', 'bf', 'gf'],
		['parents-christmas', 'bf', 'gf'],
		['senpai', 'bf', 'gf'],
		['tankman', 'bf', 'gf'],
		['hookx', 'bf', 'gf'],
	];

	var weekNames:Array<String> = CoolUtil.coolTextFile(Paths.txt('data/weekNames'));

	// JOELwindows7: and other text files for that yuss week list.
	// Yep, in order to make mod core works and loading extra week just by appending the weeklines, we unfortunately
	// have to abandon JSONed week loading `weekList.json` and use these two above.
	// TODO: week per JSON file Psychedly
	/*
		weekStuffs line represents = left char, mid char, right char, color, bannerPath, underlayPath
	 */
	var weekStuffs:Array<String> = CoolUtil.coolTextFile(Paths.txt('data/weekStuffs')); // Week Display! Character & Color
	var weekLoads:Array<String> = CoolUtil.coolTextFile(Paths.txt('data/weekLoads')); // Week Loads! each lines represents songs in the week

	var legacyJSONWeekList:Bool = false; // JOELwindows7: in case you want to use the old JSONed week list.

	// JOELwindows7: custom week parameters
	var weekColor:Array<String>; // LED backlight color
	var weekBannerPath:Array<String>; // Menu item banner image path
	var weekUnderlayPath:Array<String>; // LCD underlay image path
	var weekClickSoundPath:Array<String>; // Click sound path
	var weekIds:Array<String>; // Week IDs for unique identifying

	var txtWeekTitle:FlxUIText;

	var curWeek:Int = 0;

	var txtTracklist:FlxUIText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<FlxUISprite>;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxUISprite;
	var leftArrow:FlxUISprite;
	var rightArrow:FlxUISprite;

	var yellowBG:FlxUISprite; // JOELwindows7: globalize this bg so we can colorize it.
	var underlayBG:FlxUISprite; // JOELwindows7: for Underlay. the image appear between character & yellowBG.
	var bgColorTween:ColorTween; // JOELwindows7: to manage week display color change tween

	function unlockWeeks():Array<Bool>
	{
		var weeks:Array<Bool> = [];
		#if debug
		for (i in 0...weekNames.length)
			weeks.push(true);
		return weeks;
		#else
		// JOELwindows7: in Stepmania home use mode, you can have all songs preunlocked by default
		// You can enable lock progress if you wish to have adventure sensation.
		if (FlxG.save.data.preUnlocked)
		{
			for (i in 0...weekNames.length)
				weeks.push(true);
			return weeks;
		}
		#end

		weeks.push(true);

		for (i in 0...FlxG.save.data.weekUnlocked)
		{
			weeks.push(true);
		}
		return weeks;
	}

	function jsonWeekList()
	{
		// JOELwindows7: okay fine let's just json it.
		var initWeekJson:SwagWeeks = loadFromJson('weekList');
		weekDatas = initWeekJson.weekData;
		// weekUnlocked = initWeekJson.weekUnlocked;
		weekCharacters = initWeekJson.weekCharacters;
		// weekNames = initWeekJson.weekNames;
		weekColor = initWeekJson.weekColor;
		weekBannerPath = initWeekJson.weekBannerPath;
		weekUnderlayPath = initWeekJson.weekUnderlayPath;
		weekClickSoundPath = initWeekJson.weekClickSoundPath;
	}

	// JOELwindows7: modcore compatible texted week list loading
	function textedWeekList()
	{
		weekDatas = new Array<Dynamic>();
		weekCharacters = new Array<Dynamic>();
		weekColor = new Array<String>();
		weekBannerPath = new Array<String>();
		weekUnderlayPath = new Array<String>();
		weekClickSoundPath = new Array<String>();
		weekIds = new Array<String>();
		// use the first standardized (from top most upstream possible) array of weeks, which in this one is Week Names array.
		for (i in 0...weekNames.length)
		{
			var weekLine:Array<String> = weekLoads[i].split(':');
			var weekSongs:Array<String> = new Array<String>(); // remember, if empty, must initialize!
			for (j in 0...weekLine.length)
			{
				var song:String = weekLine[j];
				// weekDatas[i].push(song);
				weekSongs.push(song);
			}
			weekDatas.insert(i, weekSongs);
			var lineStuffs:Array<String> = weekStuffs[i].split(':');
			weekCharacters.insert(i, [lineStuffs[0], lineStuffs[1], lineStuffs[2]]);
			weekColor.insert(i, lineStuffs[3]);
			weekBannerPath.insert(i, lineStuffs[4]);
			weekUnderlayPath.insert(i, lineStuffs[5]);
			weekClickSoundPath.insert(i, lineStuffs[6]);
			weekIds.insert(i, lineStuffs[7]);
		}
	}

	// JOELwindows7: Okay, so I Altronix
	function altronixWeekList()
	{
		weekDatas = new Array<Dynamic>();
		weekCharacters = new Array<Dynamic>();
		weekColor = new Array<String>();
		weekBannerPath = new Array<String>();
		weekUnderlayPath = new Array<String>();
		weekClickSoundPath = new Array<String>();
		weekNames = new Array<String>();
		weekIds = new Array<String>();
		for (i in 0...WeekData.weeksList.length)
		{
			var weekLine:Array<String> = WeekData.weeksLoaded.get(WeekData.weeksList[i]).songs;
			var weekSongs:Array<String> = new Array<String>(); // remember, if empty, must initialize!
			for (j in 0...weekLine.length)
			{
				var song:String = weekLine[j];
				// weekDatas[i].push(song);
				weekSongs.push(song);
			}
			weekDatas.insert(i, weekSongs);
			// var lineStuffs:Array<String> = weekStuffs[i].split(':');
			weekCharacters.insert(i, WeekData.weeksLoaded.get(WeekData.weeksList[i]).weekCharacters);
			weekColor.insert(i, WeekData.weeksLoaded.get(WeekData.weeksList[i]).weekColor);
			weekBannerPath.insert(i, WeekData.weeksLoaded.get(WeekData.weeksList[i]).weekImage);
			weekUnderlayPath.insert(i, WeekData.weeksLoaded.get(WeekData.weeksList[i]).weekBackground);
			weekClickSoundPath.insert(i, WeekData.weeksLoaded.get(WeekData.weeksList[i]).weekClickSound);
			weekNames.insert(i, WeekData.weeksLoaded.get(WeekData.weeksList[i]).storyName);
			weekIds.insert(i, WeekData.weeksLoaded.get(WeekData.weeksList[i]).fileName);
		}
	}

	// TODO: JOELwindows7: use better week loading JSON granular from Master Eric's Enigma or whatever.

	override function create()
	{
		// JOELwindows7: Do the work for the weeklist pls!
		// JOELwindows7: Okay, why not weeklist also procedural? just asking?
		// not all people are into coding.
		// hmm isn't that better to use JSON instead? it's easier to manage!
		// just copy 3 week list variables above, JSONify them all! yeah!
		/*
				Pain is temporary
				GLORY IS FOREVER
				LOL wintergatan
			// */ // a fed. looks like comment inside comment block doesn't affect. only after closing.
		legacyJSONWeekList = false; // JOELwindows7: turn off after you completed new weeklist. DONE

		// JOELwindows7: the Altronix week JSON
		WeekData.reloadWeekFiles(true);

		// DONE: JOELwindow7: implement Master Eric's granular week JSON. nvm, maybe we have Altronix already?
		if (legacyJSONWeekList)
			jsonWeekList();
		else
			textedWeekList();
		// altronixWeekList(); // JOELwindows7: Whenever it's ready!

		if (curWeek >= WeekData.weeksList.length)
			curWeek = 0;

		weekUnlocked = unlockWeeks();

		PlayState.currentSong = "bruh";
		PlayState.inDaPlay = false;
		#if FEATURE_DISCORD
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Story Mode Menu", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		// if (FlxG.sound.music != null)
		// {
		// 	if (!FlxG.sound.music.playing)
		// 	{
		// 		FlxG.sound.playMusic(Paths.music('freakyMenu'));
		// 		Conductor.changeBPM(102);
		// 	}
		// }
		CoolUtil.playMainMenuSong(1); // JOELwindows7: NEW PLAY THE MENU!!!

		persistentUpdate = persistentDraw = true;

		scoreText = new FlxUIText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		txtWeekTitle = new FlxUIText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		var rankText:FlxUIText = new FlxUIText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		// JOELwindows7: yeah
		// Mark selection for campaign menu ui assets
		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		yellowBG = cast new FlxUISprite(0, 56).makeGraphic(FlxG.width, 400, FlxColor.WHITE); // JOELwindows7: globalized lol
		// original color was 0xFFF9CF51
		// You must be white as a base colorable.

		trace("Line smothing");
		// JOELwindows7: add Underlay image first. also the cast
		underlayBG = cast new FlxUISprite(0, 56).makeGraphic(FlxG.width, 400, FlxColor.TRANSPARENT);
		underlayBG.alpha = .3; // Just like the LCD watch game toy.
		// 64 bit, 32 bit, 16 bit. 8 bit, 4 Bit, 2 BIt, 1 BiT, HALF bIT, QUARTER BIT, THE WRIST GAAAAAAAAAME!!!
		// lmao angry game review lololol

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		grpLocks = new FlxTypedGroup<FlxUISprite>();
		add(grpLocks);

		// JOELwindows7: yo! sup!
		var blackBarThingie:FlxUISprite = cast new FlxUISprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		trace("Line 70");

		for (i in 0...weekData().length)
		{
			// JOELwindows7: first, check weekStuffs first.
			var shouldCustomPath:Bool = weekBannerPath[i] != null && weekBannerPath[i] != "";

			// JOELwindows7: then apply to another arguments
			var weekThing:MenuItem = new MenuItem(0, yellowBG.y + yellowBG.height + 10, i, shouldCustomPath, weekBannerPath[i]);
			weekThing.y += ((weekThing.height + 20) * i);
			weekThing.targetY = i;
			weekThing.ID = i; // JOELwindows7: add ID to compare with curSelected week
			weekThing.flashingColor = FlxColor.fromString(weekColor[i]);
			weekThing.uniqueName = weekIds[i];
			grpWeekText.add(weekThing);

			weekThing.screenCenter(X);
			weekThing.antialiasing = FlxG.save.data.antialiasing;
			// weekThing.updateHitbox();

			// Needs an offset thingie
			if (!weekUnlocked[i])
			{
				trace('locking week ' + i);
				var lock:FlxUISprite = new FlxUISprite(weekThing.width + 10 + weekThing.x);
				lock.frames = ui_tex;
				lock.animation.addByPrefix('lock', 'lock');
				lock.animation.play('lock');
				lock.ID = i;
				lock.antialiasing = FlxG.save.data.antialiasing;
				grpLocks.add(lock);
			}
		}

		trace("Line 96");

		grpWeekCharacters.add(new MenuCharacter(0, 100, 0.5, false));
		grpWeekCharacters.add(new MenuCharacter(450, 25, 0.9, true));
		grpWeekCharacters.add(new MenuCharacter(850, 100, 0.5, true));
		// JOELwindows7: hey, try the week 7 way, yoinked by luckdydog7
		// for (char in 0...3)
		// {
		// 	var weekCharacterThing = new MenuCharacter(Std.int((FlxG.width * 0.25) * (1 + char) - 150), 100, 0.5, false);
		// var weekCharacterThing:MenuCharacter = new MenuCharacter((FlxG.width * 0.25) * (1 + char) - 150, weekCharacters[curWeek][char]);
		// weekCharacterThing.y += 70;
		// weekCharacterThing.antialiasing = FlxG.save.data.antialiasing;
		// switch (weekCharacterThing.character)
		// {
		// 	case 'dad':
		// 		weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 0.5));
		// 		weekCharacterThing.updateHitbox();

		// 	case 'bf':
		// 		weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 0.9));
		// 		weekCharacterThing.updateHitbox();
		// 		weekCharacterThing.x -= 80;
		// 	case 'gf':
		// 		weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 0.5));
		// 		weekCharacterThing.updateHitbox();
		// 	case 'pico':
		// 		weekCharacterThing.flipX = true;
		// 	case 'parents-christmas':
		// 		weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 0.9));
		// 		weekCharacterThing.updateHitbox();
		// }

		// grpWeekCharacters.add(weekCharacterThing);

		// }

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		trace("Line 124");

		leftArrow = new FlxUISprite(grpWeekText.members[0].x + grpWeekText.members[0].width + 10, grpWeekText.members[0].y + 10);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		leftArrow.antialiasing = FlxG.save.data.antialiasing;
		difficultySelectors.add(leftArrow);

		sprDifficulty = new FlxUISprite(leftArrow.x + 130, leftArrow.y);
		sprDifficulty.frames = ui_tex;
		sprDifficulty.animation.addByPrefix('easy', 'EASY');
		sprDifficulty.animation.addByPrefix('normal', 'NORMAL');
		sprDifficulty.animation.addByPrefix('hard', 'HARD');
		sprDifficulty.animation.play('easy');
		sprDifficulty.antialiasing = FlxG.save.data.antialiasing;
		changeDifficulty();

		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxUISprite(sprDifficulty.x + sprDifficulty.width + 50, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		rightArrow.antialiasing = FlxG.save.data.antialiasing;
		difficultySelectors.add(rightArrow);

		trace("Line 150");

		add(yellowBG);
		add(underlayBG); // JOELwindows7: here add underlay
		add(grpWeekCharacters);

		txtTracklist = new FlxUIText(FlxG.width * 0.05, yellowBG.x + yellowBG.height + 100, 0, "Tracks", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = rankText.font;
		txtTracklist.color = 0xFFe55777;
		add(txtTracklist);
		// add(rankText);
		add(scoreText);
		add(txtWeekTitle);

		updateText();

		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) && weekUnlocked[curWeek])
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		trace("Line 165");

		// JOELwindows7: add back button now
		addBackButton(10, Std.int((FlxG.height / 2) + 40), .25);

		super.create();

		// JOELwindows7: stuffs
		AchievementUnlocked.whichIs("story_mode");

		CoolUtil.playMainMenuSong(1); // JOELwindows7: do it again for good measure
	}

	override function update(elapsed:Float)
	{
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.5));

		scoreText.text = "WEEK SCORE:" + lerpScore;

		txtWeekTitle.text = weekNames[curWeek].toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		// FlxG.watch.addQuick('font', scoreText.font);

		difficultySelectors.visible = weekUnlocked[curWeek];

		grpLocks.forEach(function(lock:FlxUISprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
		});

		if (!movedBack)
		{
			if (!selectedWeek)
			{
				var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

				if (gamepad != null)
				{
					if (gamepad.justPressed.DPAD_UP)
					{
						changeWeek(-1);
					}
					if (gamepad.justPressed.DPAD_DOWN)
					{
						changeWeek(1);
					}

					if (gamepad.pressed.DPAD_RIGHT)
						rightArrow.animation.play('press')
					else
						rightArrow.animation.play('idle');
					if (gamepad.pressed.DPAD_LEFT)
						leftArrow.animation.play('press');
					else
						leftArrow.animation.play('idle');

					if (gamepad.justPressed.DPAD_RIGHT)
					{
						changeDifficulty(1);
					}
					if (gamepad.justPressed.DPAD_LEFT)
					{
						changeDifficulty(-1);
					}
				}

				// JOELwindows7: add the mouse support here too as well
				if (FlxG.keys.justPressed.UP || FlxG.mouse.wheel == 1)
				{
					changeWeek(-1);
				}

				if (FlxG.keys.justPressed.DOWN || FlxG.mouse.wheel == -1)
				{
					changeWeek(1);
				}

				// JOELwindows7: regular mouse overlaps click sprite
				// https://gamefromscratch.com/haxeflixel-tutorial-mouse-input/
				if (controls.RIGHT || (FlxG.mouse.overlaps(rightArrow) && FlxG.mouse.pressed) || FlxG.mouse.pressedMiddle)
					rightArrow.animation.play('press')
				else
					rightArrow.animation.play('idle');

				if (controls.LEFT || (FlxG.mouse.overlaps(leftArrow) && FlxG.mouse.pressed))
					leftArrow.animation.play('press');
				else
					leftArrow.animation.play('idle');

				if (controls.RIGHT_P || (FlxG.mouse.overlaps(rightArrow) && FlxG.mouse.justPressed) || FlxG.mouse.justPressedMiddle)
					changeDifficulty(1);
				if (controls.LEFT_P || (FlxG.mouse.overlaps(leftArrow) && FlxG.mouse.justPressed))
					changeDifficulty(-1);

				// manage mouse visibility
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
			else
			{
				// JOELwindows7: week has been selected
				FlxG.mouse.visible = false;
			}

			if (controls.ACCEPT || haveClicked)
			{
				selectWeek();
				haveClicked = false;
			}
		}

		if ((controls.BACK || haveBacked) && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			// FlxG.switchState(new MainMenuState());
			switchState(new MainMenuState()); // JOELwindows7: switch state hex

			haveBacked = false;
		}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	// JOELwindows7: Okay so, cleanup Json? and then parse? okeh
	// yeah I know, I copied from Song.hx. for this one, the weekList.json isn't anywhere in special folder
	// but root of asset/data . that's all... idk
	public static function loadFromJson(jsonInput:String):SwagWeeks
	{
		var rawJson = Assets.getText(Paths.json(jsonInput)).trim();
		trace("load weeklist Json");

		while (!rawJson.endsWith("}"))
		{
			// JOELwindows7: okay also going through bullshit cleaning what the peck strange
			rawJson = rawJson.substr(0, rawJson.length - 1);
		}
		return parseJSONshit(rawJson);
	}

	// JOELwindows7: lol!literally copy from Song.hx minus the
	// changing valid score which SwagWeeks typedef doesn't have, idk..
	public static function parseJSONshit(rawJson:String):SwagWeeks
	{
		// var swagShit:SwagWeeks = cast Json.parse(rawJson);
		var swagShit:SwagWeeks = cast TJSON.parse(rawJson); // JOELwindows7: use TJSON from now on, I guess.
		return swagShit;
	}

	// JOELwindows7: a.k.a. new week game
	function selectWeek()
	{
		// JOELwindows7: reset blue balls
		GameOverSubstate.resetBlueball();

		// JOELwindows7: also reset the week
		resetWeekSave();

		if (weekUnlocked[curWeek])
		{
			if (stopspamming == false)
			{
				// JOELwindows7: change click sound based on week selected
				Controls.vibrate(0, 50); // JOELwindows7: give feedback!!!
				// FlxG.sound.play(Paths.sound(weekClickSoundPath[curWeek] != null
				// 	&& weekClickSoundPath[curWeek] != ''
				// 	&& Paths.doesSoundAssetExist(weekClickSoundPath[curWeek]) ? weekClickSoundPath[curWeek] : 'confirmMenu'));
				FlxG.sound.play(Paths.sound(weekClickSoundPath[curWeek] != null
					&& weekClickSoundPath[curWeek] != '' ? weekClickSoundPath[curWeek] : 'confirmMenu'));

				grpWeekText.members[curWeek].startFlashing();
				grpWeekCharacters.members[1].animation.play('bfConfirm');
				stopspamming = true;
			}

			PlayState.storyPlaylist = weekData()[curWeek];
			PlayState.isStoryMode = true;
			selectedWeek = true;
			PlayState.songMultiplier = 1;

			PlayState.isSM = false;

			PlayState.storyDifficulty = curDifficulty;

			var diff:String = ["-easy", "", "-hard"][PlayState.storyDifficulty];
			PlayState.sicks = 0;
			PlayState.bads = 0;
			PlayState.shits = 0;
			PlayState.goods = 0;
			PlayState.campaignMisses = 0;
			PlayState.SONG = Song.conversionChecks(Song.loadFromJson(PlayState.storyPlaylist[0], diff));
			PlayState.storyWeek = curWeek;
			PlayState.campaignScore = 0;
			PlayStateChangeables.howManySongThisWeek = PlayState.storyPlaylist.length; // JOELwindows7: set to how many songs we have this week yess.
			PlayStateChangeables.weekColor = FlxColor.fromString(weekColor[curWeek]); // JOELwindows7: the obvious week color for any references.
			PlayStateChangeables.songPosBarColor = FlxColor.fromString(weekColor[curWeek]); // JOELwindows7: here change color for song bar pls.
			PlayStateChangeables.songPosBarColorBg = FlxColor.fromRGBFloat(PlayStateChangeables.songPosBarColor.brightness,
				PlayStateChangeables.songPosBarColor.brightness, PlayStateChangeables.songPosBarColor.brightness)
				.getInverted();
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				// JOELwindows7: check if the song has video files
				// #if !mobile
				// LoadingState.loadAndSwitchState(PlayState.SONG.hasVideo ? VideoCutscener.getThe(PlayState.SONG.videoPath, new PlayState()) : new PlayState(),
				// 	true);
				switchState(PlayState.SONG.hasVideo ? VideoCutscener.getThe(PlayState.SONG.videoPath, new PlayState()) : new PlayState(), true, true, true,
					true, new StoryMenuState()); // JOELwindows7: switch state hex
				// #else //workaround for Video cutscener not working in Android
				// LoadingState.loadAndSwitchState(new PlayState(), true);
				// #end
			});
		}
	}

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		sprDifficulty.offset.x = 0;

		switch (curDifficulty)
		{
			case 0:
				sprDifficulty.animation.play('easy');
				sprDifficulty.offset.x = 20;
			case 1:
				sprDifficulty.animation.play('normal');
				sprDifficulty.offset.x = 70;
			case 2:
				sprDifficulty.animation.play('hard');
				sprDifficulty.offset.x = 20;
		}

		sprDifficulty.alpha = 0;

		// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
		sprDifficulty.y = leftArrow.y - 15;
		// intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		intendedScore = Highscore.getNewWeekScore(weekIds[curWeek], curDifficulty); // JOELwindows7: from mod file names

		#if !switch
		// intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		intendedScore = Highscore.getNewWeekScore(weekIds[curWeek], curDifficulty); // JOELwindows7: from mod file names
		#end

		FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07);
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= weekData().length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = weekData().length - 1;

		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) && weekUnlocked[curWeek])
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		FlxG.sound.play(Paths.sound('scrollMenu'));

		updateText();
	}

	// JOELwindows7: copy above but this time set week selection
	function goToWeek(change:Int = 0)
	{
		curWeek = change;

		if (curWeek >= weekData().length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = weekData().length - 1;

		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) && weekUnlocked[curWeek])
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		FlxG.sound.play(Paths.sound('scrollMenu'));

		updateText();
	}

	function updateText()
	{
		grpWeekCharacters.members[0].setCharacter(weekCharacters[curWeek][0]);
		grpWeekCharacters.members[1].setCharacter(weekCharacters[curWeek][1]);
		grpWeekCharacters.members[2].setCharacter(weekCharacters[curWeek][2]);

		// JOELwindows7: set underlay image
		if (weekUnderlayPath[curWeek] != null && weekUnderlayPath[curWeek] != "")
		{
			try
			{
				underlayBG.loadGraphic(Paths.image('menuBackgrounds/' + weekUnderlayPath[curWeek]));
				underlayBG.alpha = .3;
			}
			catch (e)
			{
				Debug.logError("Werror " + e + ": " + e.message);
				underlayBG.makeGraphic(FlxG.width, 400, FlxColor.TRANSPARENT);
				underlayBG.alpha = .3;
			}
		}
		else
		{
			underlayBG.makeGraphic(FlxG.width, 400, FlxColor.TRANSPARENT);
			underlayBG.alpha = .3;
		}

		txtTracklist.text = "Tracks\n";
		var stringThing:Array<String> = weekData()[curWeek];

		for (i in stringThing)
			txtTracklist.text += "\n" + i;

		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		txtTracklist.text += "\n";

		if (bgColorTween != null)
		{
			// JOELwindows7: first, cancel running tween to prevent color
			// tweetch after running through colored item selections.
			bgColorTween.cancel();
			// then to bellow, reinitiate new change color tween.
		}
		// JOELwindows7: change yellowBG color pls
		var colores:FlxColor = FlxColor.fromString("0xFFF9CF51");
		// yellowBG.color = FlxColor.fromString(weekColor[curWeek]);
		// FlxTween.tween(
		// 	yellowBG,
		// 	{color:FlxColor.fromString(weekColor[curWeek])},
		// 	.5,
		// 	{ease:FlxEase.linear}
		// 	);
		// wtf bro, the tweener triggers epilepsy!
		colores = FlxColor.fromString(weekColor[curWeek]);
		// FlxTween.tween(yellowBG.color, {redFloat: colores.redFloat}, 0.5, {ease: FlxEase.linear});
		// FlxTween.tween(yellowBG.color, {greenFloat: colores.greenFloat}, 0.5, {ease: FlxEase.linear});
		// FlxTween.tween(yellowBG.color, {blueFloat: colores.blueFloat}, 0.5, {ease: FlxEase.linear});
		// FlxTween.tween(yellowBG, {color:{
		// 	redFloat: colores.redFloat,
		// 	greenFloat: colores.greenFloat,
		// 	blueFloat: colores.blueFloat
		// }}, 0.5, {ease: FlxEase.linear});
		bgColorTween = FlxTween.color(yellowBG, .5, yellowBG.color, colores, {ease: FlxEase.linear}); // JOELwindows7: FINALLY!!!

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end
	}

	public static function unlockNextWeek(week:Int):Void
	{
		if (week <= weekData().length - 1 /*&& FlxG.save.data.weekUnlocked == week*/) // fuck you, unlocks all weeks
		{
			weekUnlocked.push(true);
			trace('Week ' + week + ' beat (Week ' + (week + 1) + ' unlocked)');
		}

		FlxG.save.data.weekUnlocked = weekUnlocked.length - 1;
		FlxG.save.flush();
	}

	override function beatHit()
	{
		super.beatHit();

		if (curBeat % 2 == 0)
		{
			grpWeekCharacters.members[0].bopHead();
			grpWeekCharacters.members[1].bopHead();
		}
		else if (weekCharacters[curWeek][0] == 'spooky' || weekCharacters[curWeek][0] == 'gf')
			grpWeekCharacters.members[0].bopHead();

		if (weekCharacters[curWeek][2] == 'spooky' || weekCharacters[curWeek][2] == 'gf')
			grpWeekCharacters.members[2].bopHead();
	}

	// JOELwindows7: put mouse function here yea
	override function manageMouse()
	{
		// JOELwindows7: mouse support
		grpWeekText.forEach(function(item:MenuItem)
		{
			if (!selectedWeek)
			{
				if (FlxG.mouse.overlaps(item) && !FlxG.mouse.overlaps(backButton))
				{
					if (FlxG.mouse.justPressed)
					{
						if (item.ID == curWeek)
						{
							haveClicked = true;
						}
						else
						{
							// go to week which
							goToWeek(item.ID);
						}
					}
				}
			}

			// back Buttoning
			if (FlxG.mouse.overlaps(backButton) && !FlxG.mouse.overlaps(item))
			{
				if (FlxG.mouse.justPressed)
					if (!haveBacked)
					{
						haveBacked = true;
					}
			}
		});
	}

	// JOELwindows7: Week save functions people! BrightFyre!!!!!!!!
	public static function saveWeek(andQuit:Bool = false)
	{
		FlxG.save.data.leftAWeek = andQuit;
		FlxG.save.data.leftStoryWeek = PlayState.storyWeek;
		FlxG.save.data.leftWeekSongAt = PlayState.storyPlaylist[0];
		FlxG.save.data.leftFullPlaylistCurrently = PlayState.storyPlaylist;
		FlxG.save.data.leftCampaignScore = PlayState.campaignScore;
		FlxG.save.data.leftCampaignMisses = PlayState.campaignMisses;
		FlxG.save.data.leftCampaignSicks = PlayState.campaignSicks;
		FlxG.save.data.leftCampaignGoods = PlayState.campaignGoods;
		FlxG.save.data.leftCampaignBads = PlayState.campaignBads;
		FlxG.save.data.leftCapaignShits = PlayState.campaignShits;
		FlxG.save.data.leftBlueBall = GameOverSubstate.getBlueballCounter();
		FlxG.save.flush();
	}

	public static function resetWeekSave()
	{
		FlxG.save.data.leftAWeek = false;
		FlxG.save.data.leftStoryWeek = 0;
		FlxG.save.data.leftWeekSongAt = '';
		FlxG.save.data.leftFullPlaylistCurrently = [];
		FlxG.save.data.leftCampaignScore = 0;
		FlxG.save.data.leftCampaignMisses = 0;
		FlxG.save.data.leftCampaignSicks = 0;
		FlxG.save.data.leftCampaignGoods = 0;
		FlxG.save.data.leftCampaignBads = 0;
		FlxG.save.data.leftCapaignShits = 0;
		FlxG.save.data.leftBlueBall = 0;
		FlxG.save.flush();
	}
}
