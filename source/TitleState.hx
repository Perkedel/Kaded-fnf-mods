package;

import flixel.addons.display.FlxBackdrop;
import plugins.sprites.QmovephBackground;
import GalleryAchievements;
#if FEATURE_STEPMANIA
import smTools.SMFile;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;
import flixel.input.keyboard.FlxKey;
#if gamejolt
import GameJolt.GameJoltAPI;
#end
// import grig.midi.MidiOut;
#if FEATURE_DISCORD
import Discord.DiscordClient;
#end
#if FEATURE_MULTITHREADING
import sys.thread.Thread;
import sys.thread.Mutex;
#end

using StringTools;

class TitleState extends MusicBeatState
{
	static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;
	var perkedelSpr:FlxSprite; // JOELwindows7: the Perkedel Logo
	var odyseeSpr:FlxSprite; // JOELwindows7: the Odysee Logo

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	var alreadyDecideOutdated:Bool = false; // JOELwindows7: flag to decide outdated.

	// to prevent reselectoid after seen outdated on previously
	// var hbdWhen:Map<Date, String>; // JOELwindows7: store lines of birthday stuffs, and its date when.
	var hbdList:Array<Dynamic>;

	override public function create():Void
	{
		// JOELwindows7: Yoinkered Kade + YinYang48 Hex
		// https://github.com/KadeDev/Hex-The-Weekend-Update/blob/main/source/TitleState.hx
		// #if FEATURE_MULTITHREADING
		// MasterObjectLoader.mutex = new Mutex(); // JOELwindows7: you must first initialize the mutex.
		// #end

		// JOELwindows7: fetch birthday lines
		// hbdWhen = new Map<Date, String>();
		hbdList = new Array<Dynamic>();
		CarryAround.hbdLines = CoolUtil.coolTextFile(Paths.txt("data/hbd"));
		for (i in 0...CarryAround.hbdLines.length)
		{
			var line:String = CarryAround.hbdLines[i];
			var breakdown:Array<String> = line.split(":");
			var name:String = breakdown[0];
			var month:Int = Std.parseInt(breakdown[1]);
			var day:Int = Std.parseInt(breakdown[2]);
			// var date:Date = Date.;
			// hbdWhen.set(new Date(null, month, day), name);
			var hbdCell:Array<Dynamic> = [name, month, day];
			hbdList.push(hbdCell);
			// JOELwindows7: pls idk how to make it elegant and work.
		}

		// JOELwindows7: luckydog7 added this, maybe to prevent absolute quit by back button.
		// https://github.com/luckydog7/trickster/blob/master/source/TitleState.hx
		// https://github.com/luckydog7/trickster/commit/677e0c5e7d644482066322a8ab99ee67c2d18088
		// JOELwindows7: title state in trickster android luckydog7
		#if android
		FlxG.android.preventDefaultKeys = [BACK];
		#end

		// TODO: Refactor this to use OpenFlAssets.
		#if FEATURE_FILESYSTEM
		if (!sys.FileSystem.exists(Sys.getCwd() + "/assets/replays"))
			sys.FileSystem.createDirectory(Sys.getCwd() + "/assets/replays");
		#end
		// JOELwindows7: Since we do not have the ability to spawn ask permission in Android somehow (despite our best effort),
		// we disabled create directory of replay. man that's disappointing.
		// we need help for creating dir and file in Android!

		// JOELwindows7: add Odysee titler
		#if odysee
		Debug.logTrace("Odysee lol!");
		#else
		Debug.logTrace("Not Odysee. okeh.. I guess. Or perhaps yes, just forgot the Odysee definition?");
		#end

		@:privateAccess
		{
			Debug.logTrace("We loaded " + openfl.Assets.getLibrary("default").assetsLoaded + " assets into the default library");
		}

		// FlxG.autoPause = false;

		// FlxG.save.bind('funkin', 'ninjamuffin99');

		// PlayerSettings.init();

		// KadeEngineData.initSave();

		// JOELwindows7: TentaRJ GameJolter
		// #if gamejolt
		// // Main.gjToastManager.createToast(Paths.image("art/LFMicon64"), "Cool and good", "Welcome to Last Funkin Moments",
		// // 	false); // JOELwindows7: create GameJolt Toast here.
		// GameJoltAPI.connect();
		// GameJoltAPI.authDaUser(FlxG.save.data.gjUser, FlxG.save.data.gjToken);
		// #end

		// KeyBinds.keyCheck();
		// It doesn't reupdate the list before u restart rn lmao

		// NoteskinHelpers.updateNoteskins();

		// if (FlxG.save.data.volDownBind == null)
		// 	FlxG.save.data.volDownBind = "MINUS";
		// if (FlxG.save.data.volUpBind == null)
		// 	FlxG.save.data.volUpBind = "PLUS";

		// FlxG.sound.muteKeys = [FlxKey.fromString(FlxG.save.data.muteBind)];
		// FlxG.sound.volumeDownKeys = [FlxKey.fromString(FlxG.save.data.volDownBind)];
		// FlxG.sound.volumeUpKeys = [FlxKey.fromString(FlxG.save.data.volUpBind)];

		FlxG.mouse.visible = false;

		// FlxG.worldBounds.set(0, 0);

		// FlxGraphic.defaultPersist = FlxG.save.data.cacheImages;

		// MusicBeatState.initSave = true;

		fullscreenBind = FlxKey.fromString(FlxG.save.data.fullscreenBind);
		// JOElwindows7: save inits & some other inits are already splashed

		Highscore.load();

		curWacky = FlxG.random.getObject(getIntroTextShit());

		trace('hello');

		// DEBUG BULLSHIT

		super.create();

		#if FREEPLAY
		// FlxG.switchState(new FreeplayState());
		switchState(new FreeplayState()); // JOELwindows7: switch to freeplay state hexly.
		clean();
		#elseif CHARTING
		// FlxG.switchState(new ChartingState());
		switchState(new ChartingState()); // JOELwindows7: switch to charting state hexly.
		clean();
		#else
		#if !cpp
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			startIntro();
		});
		#else
		startIntro();
		#end
		#end
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;

	// JOELwindows7: globalize button
	var pressedEnter:Bool = false;

	function startIntro()
	{
		persistentUpdate = true;

		// JOELwindows7: the default background pls
		if (Main.watermarks && Main.perkedelMark)
		{
			// installDefaultBekgron();
			installSophisticatedDefaultBekgron();
		}
		else
		{
			var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			// bg.antialiasing = FlxG.save.data.antialiasing;
			// bg.setGraphicSize(Std.int(bg.width * 0.6));
			// bg.updateHitbox();
			add(bg);
		}

		if (Main.watermarks)
		{
			logoBl = new FlxSprite(-150, 1500);
			// logoBl.frames = Paths.getSparrowAtlas('KadeEngineLogoBumpin');
			logoBl.frames = Paths.getSparrowAtlas(Main.perkedelMark ? 'LFMLogoBumpin' : 'KadeEngineLogoBumpin');
		}
		else
		{
			logoBl = new FlxSprite(-150, -100);
			logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		}
		logoBl.antialiasing = FlxG.save.data.antialiasing;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.updateHitbox();
		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;

		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = FlxG.save.data.antialiasing;
		add(gfDance);
		add(logoBl);

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = FlxG.save.data.antialiasing;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		// titleText.screenCenter(X);
		add(titleText);

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage('logo'));
		logo.screenCenter();
		logo.antialiasing = FlxG.save.data.antialiasing;
		// add(logo);

		// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "ninjamuffin99\nPhantomArcade\nkawaisprite\nevilsk8er", true);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.loadImage('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = FlxG.save.data.antialiasing;

		// JOELwindows7: odysee spriter
		odyseeSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.loadImage('odysee_Logo_Transparent_White_Text'));
		add(odyseeSpr);
		odyseeSpr.visible = false;
		odyseeSpr.setGraphicSize(Std.int(odyseeSpr.width * .5), Std.int(odyseeSpr.height * .5));
		odyseeSpr.updateHitbox();
		odyseeSpr.screenCenter(X);
		odyseeSpr.antialiasing = FlxG.save.data.antialiasing;

		// JOELwindows7: Perkedel spriter
		perkedelSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.loadImage('Perkedel_Logo_Typeborder'));
		add(perkedelSpr);
		perkedelSpr.visible = false;
		perkedelSpr.setGraphicSize(Std.int(perkedelSpr.width * .2), Std.int(perkedelSpr.height * .2));
		perkedelSpr.updateHitbox();
		perkedelSpr.screenCenter(X);
		perkedelSpr.antialiasing = FlxG.save.data.antialiasing;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		FlxG.mouse.visible = false;

		if (initialized)
			skipIntro();
		else
		{
			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
				new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;

			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

			// var music:FlxSound = new FlxSound();
			// music.loadStream(Paths.music('freakyMenu'));
			// FlxG.sound.list.add(music);
			// music.play();
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);

			FlxG.sound.music.fadeIn(4, 0, 0.7);
			Conductor.changeBPM(102);

			initialized = true;
		}

		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('data/introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;
	var fullscreenBind:FlxKey;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.keys.anyJustPressed([fullscreenBind]))
		{
			FlxG.fullscreen = !FlxG.fullscreen;
			// JOELwindows7: save data for fullscreen mode
			FlxG.save.data.fullscreen = FlxG.fullscreen;
			FlxG.save.flush(); // JOELwindows7: from OptionMenu.hx it constantly save data.
		}

		// JOELwindows7: globalize this
		pressedEnter = controls.ACCEPT;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		// JOELwindows7: add mouse click to press enter
		if (FlxG.mouse.justPressed)
		{
			pressedEnter = true;
		}
		// Well sure enough guys. on my Samsung Galaxy S since Dex support
		// the mouse and touch is different. you need this ON all the time in case
		// somebody uses mouse in Android device.

		if (pressedEnter && !transitioning && skippedIntro)
		{
			// JOELwindows7: start game on friday real time
			AchievementUnlocked.whichIs("anFunkin");
			if (Date.now().getDay() == 5)
				AchievementUnlocked.whichIs("just_like_the_game");

			// JOELwindows7: oke now hbd time.
			for (i in 0...hbdList.length)
			{
				// Today, Early & late birthday too
				if (Date.now().getMonth() == (Std.int(hbdList[i][2])-1))
				{
					if (Date.now().getDate() == Std.int(hbdList[i][1]))
					{
						createToast(null, "HBD at " + Date.now().toString(), Std.string(hbdList[i][0]) + "\nSemoga panjang umur & sehat selalu!!! ");
					}
					if (Date.now().getDate() == Std.int(hbdList[i][1] - 1) || Date.now().getDate() == Std.int(hbdList[i][1] - 2))
					{
						createToast(null, "Early HBD at " + Date.now().toString(), Std.string(hbdList[i][0]) + "\nSemoga panjang umur & sehat selalu!!!");
					}
					if (Date.now().getDate() == Std.int(hbdList[i][1] + 1) || Date.now().getDate() == Std.int(hbdList[i][1] + 2))
					{
						createToast(null, "Late HBD at " + Date.now().toString(), Std.string(hbdList[i][0]) + "\nSemoga panjang umur & sehat selalu!!!");
					}
				}
			}

			if (FlxG.save.data.flashing)
				titleText.animation.play('press');

			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;
			// FlxG.sound.music.stop();

			MainMenuState.firstStart = true;
			MainMenuState.finishedFunnyMove = false;

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				// Get current version of Kade Engine

				// JOELwindows7: do this if not mobile since in there this doesn't work
				// according to the luckydog7 and mods that don't care update
				#if FEATURE_HTTP
				var http = new haxe.Http("https://raw.githubusercontent.com/KadeDev/Kade-Engine/master/version.downloadMe");
				var returnedData:Array<String> = [];

				http.onData = function(data:String)
				{
					returnedData[0] = data.substring(0, data.indexOf(';'));
					returnedData[1] = data.substring(data.indexOf('-'), data.length);
					if (!MainMenuState.kadeEngineVer.contains(returnedData[0].trim()) && !OutdatedSubState.leftState)
					{
						alreadyDecideOutdated = true;
						trace('outdated lmao! ' + returnedData[0] + ' != ' + MainMenuState.kadeEngineVer);
						OutdatedSubState.needVer = returnedData[0];
						OutdatedSubState.currChanges = returnedData[1];
						// FlxG.switchState(new OutdatedSubState());
						switchState(new OutdatedSubState()); // JOELwindows7: hex switch state lol
						clean();
					}
					else
					{
						// FlxG.switchState(new MainMenuState());
						switchState(new MainMenuState()); // JOELwindows7: hex switch state lol
						clean();
					}
				}

				http.onError = function(error)
				{
					trace('error: $error');
					// FlxG.switchState(new MainMenuState()); // fail but we go anyway
					switchState(new MainMenuState()); // fail but we go anyway; JOELwindows7: hex switch state lol
					clean();
				}

				http.request();
				#else
				// see bellow update (LFM update check) check else
				// it already done go to menu for me.
				#end
			});
			// FlxG.sound.play(Paths.music('titleShoot'), 0.7);

			// JOELwindows7: Last Funkin Moments outdated marks
			// copy from above
			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				// Get the current version of Last Funkin Moments

				#if FEATURE_HTTP
				var http = new haxe.Http("https://raw.githubusercontent.com/Perkedel/kaded-fnf-mods/stable/versionLastFunkin.downloadMe");
				var returnedData:Array<String> = [];

				http.onData = function(data:String)
				{
					returnedData[0] = data.substring(0, data.indexOf(';'));
					returnedData[1] = data.substring(data.indexOf('-'), data.length);
					if (!MainMenuState.lastFunkinMomentVer.contains(returnedData[0].trim()) && !OutdatedSubState.tinggalkanState)
					{
						if (!alreadyDecideOutdated)
							OutdatedSubState.whichAreaOutdated = 1; // mark that LFM one is outdated
						alreadyDecideOutdated = true;
						trace('LFM outdated lmao! ' + returnedData[0] + ' != ' + MainMenuState.lastFunkinMomentVer);
						OutdatedSubState.needVerLast = returnedData[0];
						OutdatedSubState.perubahanApaSaja = returnedData[1];
						// FlxG.switchState(new OutdatedSubState());
						switchState(new OutdatedSubState()); // JOELwindows7: get here hex switch state yeah
					}
					else
					{
						// FlxG.switchState(new MainMenuState());
						switchState(new MainMenuState()); // JOELwindows7: get here hex switch state yeah
					}
				}

				http.onError = function(error)
				{
					trace('error: $error');
					// FlxG.switchState(new MainMenuState()); // fail but we go anyway
					switchState(new MainMenuState()); // fail but we go anyway; JOELwindows7: get here hex switch state yeah
				}

				http.request();
				#else
				// FlxG.switchState(new MainMenuState()); // Just pecking go to menu already!
				switchState(new MainMenuState()); // Just pecking go to menu already! JOELwindows7: get here hex switch state yeah
				#end
			});
		}

		if (pressedEnter && !skippedIntro && initialized)
		{
			skipIntro();
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	override function beatHit()
	{
		super.beatHit();

		logoBl.animation.play('bump', true);
		danceLeft = !danceLeft;

		if (danceLeft)
			gfDance.animation.play('danceRight');
		else
			gfDance.animation.play('danceLeft');

		// FlxG.log.add(curBeat);

		switch (curBeat)
		{
			case 0:
				deleteCoolText();
			case 1:
				createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']);
			// credTextShit.visible = true;
			case 3:
				addMoreText('present');
			// credTextShit.text += '\npresent...';
			// credTextShit.addText();
			case 4:
				deleteCoolText();
			// credTextShit.visible = false;
			// credTextShit.text = 'In association \nwith';
			// credTextShit.screenCenter();
			case 5:
				if (Main.watermarks)
				{
					if (Main.odyseeMark)
						createCoolText(['are we partnered', 'with']);
					else if (Main.perkedelMark)
						createCoolText(['last funkin moments', 'by']);
					else
						createCoolText(['Kade Engine', 'by']);
				}
				else
					createCoolText(['In Partnership', 'with']);
			case 7:
				if (Main.watermarks)
					if (Main.odyseeMark)
					{
						// addMoreText('Odysee');
						odyseeSpr.visible = true;
					}
					else if (!Main.odyseeMark && Main.perkedelMark)
					{
						// JOELwindows7: uuhhh, can we be more efficient here? uh, is there enum?
						perkedelSpr.visible = true;
					}
					else
						addMoreText('KadeDeveloper');
				else
				{
					addMoreText('Newgrounds');
					ngSpr.visible = true;
				}
			// credTextShit.text += '\nNewgrounds';
			case 8:
				deleteCoolText();
				ngSpr.visible = false;
				perkedelSpr.visible = false;
				odyseeSpr.visible = false;
			// credTextShit.visible = false;

			// credTextShit.text = 'Shoutouts Tom Fulp';
			// credTextShit.screenCenter();
			case 9:
				createCoolText([curWacky[0]]);
			// credTextShit.visible = true;
			case 11:
				addMoreText(curWacky[1]);
			// credTextShit.text += '\nlmao';
			case 12:
				deleteCoolText();
			// credTextShit.visible = false;
			// credTextShit.text = "Friday";
			// credTextShit.screenCenter();
			case 13:
				// addMoreText('Friday');
				addMoreText(Main.perkedelMark ? 'Last' : 'Friday');
			// credTextShit.visible = true;
			case 14:
				// addMoreText('Night');
				addMoreText(Main.perkedelMark ? 'Funkin' : 'Night');
			// credTextShit.text += '\nNight';
			case 15:
				// addMoreText('Funkin'); // credTextShit.text += '\nFunkin';
				addMoreText(Main.perkedelMark ? 'Moments' : 'Funkin');
			case 16:
				skipIntro();
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			Debug.logInfo("Skipping intro...");

			remove(ngSpr);
			remove(odyseeSpr);
			remove(perkedelSpr);

			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(credGroup);

			FlxTween.tween(logoBl, {y: -100}, 1.4, {ease: FlxEase.expoInOut});

			logoBl.angle = -4;

			new FlxTimer().start(0.01, function(tmr:FlxTimer)
			{
				if (logoBl.angle == -4)
					FlxTween.angle(logoBl, logoBl.angle, 4, 4, {ease: FlxEase.quartInOut});
				if (logoBl.angle == 4)
					FlxTween.angle(logoBl, logoBl.angle, -4, 4, {ease: FlxEase.quartInOut});
			}, 0);

			// It always bugged me that it didn't do this before.
			// Skip ahead in the song to the drop.
			FlxG.sound.music.time = 9400; // 9.4 seconds

			skippedIntro = true;
		}
	}

	override function manageMouse()
	{
		// JOELwindows7: add mouse click to press enter
		if (FlxG.mouse.justPressed)
		{
			pressedEnter = true;
		}
		// Well sure enough guys. on my Samsung Galaxy S since Dex support
		// the mouse and touch is different. you need this ON all the time in case
		// somebody uses mouse in Android device.
		super.manageMouse();
	}
}
