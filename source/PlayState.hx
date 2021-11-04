package;

import GalleryAchievements.AchievementUnlocked;
import Controls;
import TouchScreenControls;
import flixel.util.FlxSpriteUtil;
#if FEATURE_LUAMODCHART
import LuaClass.LuaCamera;
import LuaClass.LuaCharacter;
import LuaClass.LuaNote;
#end
import lime.media.openal.AL;
import Song.Event;
import openfl.media.Sound;
#if FEATURE_STEPMANIA
import smTools.SMFile;
#end
#if FEATURE_FILESYSTEM
import sys.io.File;
import Sys;
import sys.FileSystem;
#end
import openfl.ui.KeyLocation;
import openfl.events.Event;
import haxe.EnumTools;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import Replay.Ana;
import Replay.Analysis;
import flixel.input.actions.FlxAction.FlxActionAnalog;
import DokiDoki; // JOELwindows7: the heartbeat stuff
#if FEATURE_WEBM
import webm.WebmPlayer;
#end
import flixel.input.keyboard.FlxKey;
import ui.FlxVirtualPad;
import haxe.Exception;
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import openfl.utils.AssetType;
import lime.graphics.Image;
import flixel.graphics.FlxGraphic;
import openfl.utils.AssetManifest;
import openfl.utils.AssetLibrary;
import flixel.system.FlxAssets;
import lime.app.Application;
import lime.media.AudioContext;
import lime.media.AudioManager;
import openfl.Lib;
import Section.SwagSection;
import Song.SongData;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
#if FEATURE_DISCORD
import Discord.DiscordClient;
#end
// JOELwindows7: use ki's filesystemer?
// import filesystem.File;
// Adds candy I/O (read/write/append) extension methods onto File
// using filesystem.FileTools;
// JOELwindows7: okay how about vegardit's filesystemer?
import hx.files.*;

using StringTools;

class PlayState extends MusicBeatState
{
	public static var instance:PlayState = null;

	public static var curStage:String = '';
	public static var SONG:SongData;
	// public static var customStage:SwagStage;
	public static var HEART:Array<SwagHeart>; // JOELwindows7: heartbeat spec
	// public static var HEARTS:HeartList; //JOELwindows7: list of heart specs
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var weekSong:Int = 0;
	public static var weekScore:Int = 0;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;

	public static var songPosBG:FlxSprite;

	public var visibleCombos:Array<FlxSprite> = [];

	public var addedBotplay:Bool = false;

	public var visibleNotes:Array<Note> = [];

	public static var songPosBar:FlxBar;

	public static var noteskinSprite:FlxAtlasFrames;
	public static var noteskinPixelSprite:BitmapData;
	public static var noteskinPixelSpriteEnds:BitmapData;

	public static var rep:Replay;
	public static var loadRep:Bool = false;
	public static var inResults:Bool = false;

	public static var inDaPlay:Bool = false;

	public static var noteBools:Array<Bool> = [false, false, false, false];

	var halloweenLevel:Bool = false;

	// JOELwindows7: global backgrounder. to prioritize add() in order after all variable has been filled with instances
	var bgAll:FlxTypedGroup<FlxSprite>;
	var stageFrontAll:FlxTypedGroup<FlxSprite>;
	var stageCurtainAll:FlxTypedGroup<FlxSprite>;
	var trailAll:FlxTypedGroup<FlxTrail>;

	// JOELwindows7: numbers of Missnote sfx! load from text file, how many Miss notes you had?
	var numOfMissNoteSfx:Int = 3;

	var songLength:Float = 0;
	var kadeEngineWatermark:FlxText;
	var reuploadWatermark:FlxText; // JOELwindows7: reupload & no credit protection.

	// last resort is to have links shared in video, hard coded, hard embedded.
	// hopefully the "thiefs" got displeased lmao!
	// JOELwindows7: Doki doki dance thingie
	// bf, dad, gf
	public var heartRate:Array<Int> = [70, 60, 80];
	public var minHR:Array<Int> = [70, 60, 80];
	public var maxHR:Array<Int> = [220, 210, 290];
	public var heartTierIsRightNow:Array<Int> = [0, 0, 0];
	public var heartTierBoundaries:Array<Array<Int>> = [[90, 120, 150, 200], [90, 120, 150, 200], [90, 120, 150, 200],]; // tier when bellow each number
	public var successionAdrenalAdd:Array<Array<Int>> = [[4, 3, 2, 1], [4, 3, 2, 1], [4, 3, 2, 1],];
	public var fearShockAdd:Array<Array<Int>> = [[10, 8, 7, 5], [10, 8, 7, 5], [10, 8, 7, 5],];
	public var relaxMinusPerBeat:Array<Array<Int>> = [[1, 2, 4, 7], [1, 2, 4, 7], [1, 2, 4, 7],];

	var slowedAlready:Array<Bool> = [false, false, false];

	#if FEATURE_DISCORD
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	public var vocals:FlxSound; // JOELwindows7: make public for Moddchart. oh wait. Kade already done that.

	public static var isSM:Bool = false;
	#if FEATURE_STEPMANIA
	public static var sm:SMFile;
	#end
	public static var pathToSm:String; // JOELwindows7: knock this down away. It's just string so no implication.

	// also not too much memory deal though.
	public var originalX:Float; // JOELwindows7: what is this?

	public static var dad:Character;
	public static var gf:Character;
	public static var boyfriend:Boyfriend;

	public var notes:FlxTypedGroup<Note>;

	private var unspawnNotes:Array<Note> = [];

	public var strumLine:FlxSprite;

	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	// JOELwindows7: flag to let stage or whatever override camFollow position
	// private var overrideCamFollowP1:Bool = false;
	// private var overrideCamFollowP2:Bool = false;
	private var manualCamFollowPosP1:Array<Float> = [0, 0];
	private var manualCamFollowPosP2:Array<Float> = [0, 0];

	public var laneunderlay:FlxSprite;
	public var laneunderlayOpponent:FlxSprite;

	public static var strumLineNotes:FlxTypedGroup<StaticArrow> = null;
	public static var playerStrums:FlxTypedGroup<StaticArrow> = null;
	public static var cpuStrums:FlxTypedGroup<StaticArrow> = null;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	public var gfSpeed:Int = 1; // JOELwindows7: making public because setspeed doesnt work without it

	public var health:Float = 1; // making public because sethealth doesnt work without it

	private var combo:Int = 0;

	public static var misses:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var campaignSicks:Int = 0;
	public static var campaignGoods:Int = 0;
	public static var campaignBads:Int = 0;
	public static var campaignShits:Int = 0;

	public var accuracy:Float = 0.00;

	private var accuracyDefault:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalNotesHitDefault:Float = 0;
	private var totalPlayed:Int = 0;
	private var ss:Bool = false;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	private var songPositionBar:Float = 0;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;
	private var finishingSong:Bool = false; // JOELwindows7: here make redundant flag to make sure the song doesn't run alone

	// even the song has been done.
	public var iconP1:HealthIcon; // making these public again because i may be stupid
	public var iconP2:HealthIcon; // what could go wrong?
	public var camHUD:FlxCamera;
	public var camSustains:FlxCamera;
	public var camNotes:FlxCamera;

	public var camGame:FlxCamera; // JOELwindows7: dude whyn't work anymore after 1.7

	public var cannotDie = false;

	public static var offsetTesting:Bool = false;

	public var isSMFile:Bool = false;

	var notesHitArray:Array<Date> = [];
	var currentFrames:Int = 0;
	var idleToBeat:Bool = true; // change if bf and dad would idle to the beat of the song
	var idleBeat:Int = 2; // how frequently bf and dad would play their idle animation(1 - every beat, 2 - every 2 beats and so on)
	var forcedToIdle:Bool = false; // change if bf and dad are forced to idle to every (idleBeat) beats of the song
	var allowedToHeadbang:Bool = true; // Will decide if gf is allowed to headbang depending on the song
	var allowedToCheer:Bool = false; // Will decide if gf is allowed to cheer depending on the song

	// JOELwindows7: oh c'mon. why would not globalize both dialoguebox start and end class?
	public var doof:DialogueBox;
	public var eoof:DialogueBox;

	public var dialogue:Array<String> = ['dad:blah blah blah', 'bf:coolswag'];
	public var epilogue:Array<String> = ['dad:oh no I lose', 'bf: beep boop baaa hey!']; // JOELwindows7: same dialoguer but for after song done

	// JOELwindows7: old halloween
	// var halloweenBG:FlxSprite;
	// var isHalloween:Bool = false;
	// end old halloween
	var useStageScript:Bool = false; // JOELwindows7: flag to start try the stage Lua script
	var attemptStageScript:Bool = false; // JOELwindows7: flag to start prepare stage script after all stuffs loaded.

	// JOELwindows7: old train vars
	// var phillyCityLights:FlxTypedGroup<FlxSprite>;
	// var phillyTrain:FlxSprite;
	// end old train vars
	// public static var trainSound:FlxSound;
	// JOELwindows7: limo old
	// var limo:FlxSprite;
	// var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	// var fastCar:FlxSprite;
	// end limo old
	var songName:FlxText;

	// JOELwindows7: old boopers
	// var upperBoppers:FlxSprite;
	// var bottomBoppers:FlxSprite;
	// var santa:FlxSprite;
	// end old boopers
	var altSuffix:String = "";

	public var currentSection:SwagSection;

	var fc:Bool = true;

	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;

	public static var currentSong = "noneYet";

	public var songScore:Int = 0;

	var songScoreDef:Int = 0;
	var scoreTxt:FlxText;
	var judgementCounter:FlxText;
	var replayTxt:FlxText;

	var needSkip:Bool = false;
	var skipActive:Bool = false;
	var skipText:FlxText;
	var skipTo:Float;

	public static var campaignScore:Int = 0;

	public static var theFunne:Bool = true;

	var funneEffect:FlxSprite;
	var inCutscene:Bool = false;
	var usedTimeTravel:Bool = false;

	public static var stageTesting:Bool = false;

	var camPos:FlxPoint;

	public var randomVar = false;

	public static var Stage:Stage;

	public static var repPresses:Int = 0;
	public static var repReleases:Int = 0;

	public static var timeCurrently:Float = 0;
	public static var timeCurrentlyR:Float = 0;

	// Will fire once to prevent debug spam messages and broken animations
	private var triggeredAlready:Bool = false;

	// Per song additive offset
	public static var songOffset:Float = 0;

	// BotPlay text
	private var botPlayState:FlxText;
	// Replay shit
	private var saveNotes:Array<Dynamic> = [];
	private var saveJudge:Array<String> = [];
	private var replayAna:Analysis = new Analysis(); // replay analysis

	public static var highestCombo:Int = 0;

	public var executeModchart = false;
	public var executeStageScript = false; // JOELwindows7: for stage lua scripter
	public var executeModHscript = false; // JOELwindows7: modchart but hscript. thancc BulbyVR
	public var executeStageHscript = false; // JOELwindows7: stage haxe script yeaha

	// Animation common suffixes
	private var dataSuffix:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
	private var dataColor:Array<String> = ['purple', 'blue', 'green', 'red'];

	public static var startTime = 0.0;

	// JOELwindows7: other stuffs
	public static var creditRollout:CreditRollout; // Credit fade rolls

	// API stuff

	public function addObject(object:FlxBasic)
	{
		add(object);
	}

	public function removeObject(object:FlxBasic)
	{
		remove(object);
	}

	override public function create()
	{
		FlxG.mouse.visible = false;
		instance = this;

		// grab variables here too or else its gonna break stuff later on
		GameplayCustomizeState.freeplayBf = SONG.player1;
		GameplayCustomizeState.freeplayDad = SONG.player2;
		GameplayCustomizeState.freeplayGf = SONG.gfVersion;
		GameplayCustomizeState.freeplayNoteStyle = SONG.noteStyle;
		GameplayCustomizeState.freeplayStage = SONG.stage;
		GameplayCustomizeState.freeplaySong = SONG.songId;
		GameplayCustomizeState.freeplayWeek = storyWeek;

		previousRate = songMultiplier - 0.05;

		if (previousRate < 1.00)
			previousRate = 1;

		if (FlxG.save.data.fpsCap > 290)
		{
			// JOELwindows7: android issue. cast lib current technic crash
			#if !mobile
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(800);
			#end
		}

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		inDaPlay = true;

		if (currentSong != SONG.songName)
		{
			currentSong = SONG.songName;
			Main.dumpCache();
		}

		sicks = 0;
		bads = 0;
		shits = 0;
		goods = 0;

		misses = 0;

		highestCombo = 0;
		repPresses = 0;
		repReleases = 0;
		inResults = false;

		PlayStateChangeables.useDownscroll = FlxG.save.data.downscroll;
		PlayStateChangeables.safeFrames = FlxG.save.data.frames;
		PlayStateChangeables.scrollSpeed = FlxG.save.data.scrollSpeed * songMultiplier;
		PlayStateChangeables.botPlay = FlxG.save.data.botplay;
		PlayStateChangeables.Optimize = FlxG.save.data.optimize;
		PlayStateChangeables.zoom = FlxG.save.data.zoom;

		removedVideo = false;

		#if FEATURE_LUAMODCHART
		// TODO: Refactor this to use OpenFlAssets.
		executeModchart = FileSystem.exists(Paths.lua('songs/${PlayState.SONG.songId}/modchart'));
		if (isSM)
			executeModchart = FileSystem.exists(pathToSm + "/modchart.lua");
		if (executeModchart)
			PlayStateChangeables.Optimize = false;
		/*
			#elseif (cpp)
			//JOELwindows7: for not sys. use vergadit's filesystemers.
			p = Path.of(Paths.lua("./" + PlayState.SONG.songId  + "/modchart"));
			executeModchart = p.exists();
			trace("is modchart file exist? " + Std.string(p.exists()) + " as " + p.getAbsolutePath());
			if (executeModchart)
				PlayStateChangeables.Optimize = false;
			#else
			executeModchart = false; // JOELwindows7: FORCE disable for non sys && cpp targets
			executeStageScript = false; 
		 */
		#end
		#if !cpp
		executeModchart = false; // FORCE disable for non cpp targets
		executeStageScript = false; // JOELwindows7: this too
		#end
		Debug.logInfo("forced hscript exist is " + Std.string(SONG.forceLuaModchart));

		Debug.logInfo('Searching for mod chart? ($executeModchart) at ${Paths.lua('songs/${PlayState.SONG.songId}/modchart')}');

		// JOELwindows7: now for the hscript
		/*
		#if !web
		p = Path.of("./" + Paths.hscript(PlayState.SONG.songId + "/modchart"));
		executeModHscript = p.exists() || SONG.forceHscriptModchart;
		trace("is hscript modchart file exist? " + Std.string(p.exists()) + " as " + p.getAbsolutePath());
		#else
		executeModHscript = SONG.forceHscriptModchart;
		#end
		*/
		//JOELwindows7: new exists
		executeModHscript = 
			Paths.doesTextAssetExist(Paths.hscript('songs/${PlayState.SONG.songId}/modchart'))
			|| SONG.forceHscriptModchart
			;
		// if(SONG.forceHscriptModchart == null){
		// 	executeModHscript = SONG.forceHscriptModchart = false;
		// }
		// trace("forced hscript exist is " + Std.string(SONG.forceHscriptModchart));
		if (executeModHscript)
			PlayStateChangeables.Optimize = false;
		// trace('Mod hscript chart: ' + executeModHscript + " - " + Paths.hscript('songs/${PlayState.SONG.songId}/modchart');

		if (executeModchart)
			songMultiplier = 1;

		#if FEATURE_DISCORD
		// Making difficulty text for Discord Rich Presence.
		storyDifficultyText = CoolUtil.difficultyFromInt(storyDifficulty);

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.songName
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end

		// JOELwindows7: load the num missnote sfx file and interpret!
		// inspire the loader from FreeplayState.hx or OH ChartingState.hx. look at those dropdowns
		// that lists characters, stages, etc.
		// yeah I know, for future use we array this.
		var initMissSfx = CoolUtil.coolTextFile(Paths.txt('data/numbersOfMissSfx'));
		numOfMissNoteSfx = Std.parseInt(initMissSfx[0]);

		// JOELwindows7: init the heartbeat system
		startHeartBeat();

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camSustains = new FlxCamera();
		camSustains.bgColor.alpha = 0;
		camNotes = new FlxCamera();
		camNotes.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camSustains);
		FlxG.cameras.add(camNotes);

		camHUD.zoom = PlayStateChangeables.zoom;

		FlxCamera.defaultCameras = [camGame];
		// FlxG.cameras.setDefaultDrawTarget(camGame, true); //JOELwindows7: try the new one
		// see if it works..
		// nope. well it works, but
		// alot of semantics here has to be changed first before hand, so uh. unfortunately
		// I can't yet.

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial', '');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		Conductor.bpm = SONG.bpm;

		if (SONG.eventObjects == null)
		{
			SONG.eventObjects = [new Song.Event("Init BPM", 0, SONG.bpm, "BPM Change")];
		}

		TimingStruct.clearTimings();

		var currentIndex = 0;
		for (i in SONG.eventObjects)
		{
			if (i.type == "BPM Change")
			{
				var beat:Float = i.position;

				var endBeat:Float = Math.POSITIVE_INFINITY;

				var bpm = i.value * songMultiplier;

				TimingStruct.addTiming(beat, bpm, endBeat, 0); // offset in this case = start time since we don't have a offset

				if (currentIndex != 0)
				{
					var data = TimingStruct.AllTimings[currentIndex - 1];
					data.endBeat = beat;
					data.length = ((data.endBeat - data.startBeat) / (data.bpm / 60)) / songMultiplier;
					var step = ((60 / data.bpm) * 1000) / 4;
					TimingStruct.AllTimings[currentIndex].startStep = Math.floor((((data.endBeat / (data.bpm / 60)) * 1000) / step) / songMultiplier);
					TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length / songMultiplier;
				}

				currentIndex++;
			}
		}

		recalculateAllSectionTimes();

		trace('INFORMATION ABOUT WHAT U PLAYIN WIT:\nFRAMES: ' + PlayStateChangeables.safeFrames + '\nZONE: ' + Conductor.safeZoneOffset + '\nTS: '
			+ Conductor.timeScale + '\nBotPlay : ' + PlayStateChangeables.botPlay);

		// if the song has dialogue, so we don't accidentally try to load a nonexistant file and crash the game
		if (Paths.doesTextAssetExist(Paths.txt('data/songs/${PlayState.SONG.songId}/dialogue')))
		{
			dialogue = CoolUtil.coolTextFile(Paths.txt('data/songs/${PlayState.SONG.songId}/dialogue'));
		}

		// JOELwinodws7: Epilogue shit (sorry, that profanity wasn't mine, it was ninja's semantic)
		if (Paths.doesTextAssetExist(Paths.txt('data/songs/${PlayState.SONG.songId}/epilogue')))
		{
			epilogue = CoolUtil.coolTextFile(Paths.txt('data/songs/${PlayState.SONG.songId}/epilogue'));
		}
		// see, as simple as that
		// NEW: conform the dash is space like in FreeplayState.hx loadings
		// NEWER: copy simplest from above Kade's. pecking finally we have propery doesTextAssetExist

		// defaults if no stage was found in chart
		var stageCheck:String = 'stage';

		// If the stage isn't specified in the chart, we use the story week value.
		if (SONG.stage == null)
		{
			switch (storyWeek)
			{
				case 2:
					stageCheck = 'halloween';
				case 3:
					stageCheck = 'philly';
				case 4:
					stageCheck = 'limo';
				case 5:
					if (SONG.songId == 'winter-horrorland')
					{
						stageCheck = 'mallEvil';
					}
					else
					{
						stageCheck = 'mall';
					}
				case 6:
					if (SONG.songId == 'thorns')
					{
						stageCheck = 'schoolEvil';
					}
					else
					{
						stageCheck = 'school';
					}
					// i should check if its stage (but this is when none is found in chart anyway)
			}
		}
		else
		{
			stageCheck = SONG.stage;
		}

		if (isStoryMode)
			songMultiplier = 1;

		// defaults if no gf was found in chart
		var gfCheck:String = 'gf';

		if (SONG.gfVersion == null)
		{
			switch (storyWeek)
			{
				case 4:
					gfCheck = 'gf-car';
				case 5:
					gfCheck = 'gf-christmas';
				case 6:
					gfCheck = 'gf-pixel';
			}
		}
		else
		{
			gfCheck = SONG.gfVersion;
		}

		if (!stageTesting)
		{
			gf = new Character(400, 130, gfCheck);

			if (gf.frames == null)
			{
				#if debug
				FlxG.log.warn(["Couldn't load gf: " + gfCheck + ". Loading default gf"]);
				#end
				gf = new Character(400, 130, 'gf');
			}

			boyfriend = new Boyfriend(770, 450, SONG.player1);

			if (boyfriend.frames == null)
			{
				#if debug
				FlxG.log.warn(["Couldn't load boyfriend: " + SONG.player1 + ". Loading default boyfriend"]);
				#end
				boyfriend = new Boyfriend(770, 450, 'bf');
			}

			dad = new Character(100, 100, SONG.player2);

			if (dad.frames == null)
			{
				#if debug
				FlxG.log.warn(["Couldn't load opponent: " + SONG.player2 + ". Loading default opponent"]);
				#end
				dad = new Character(100, 100, 'dad');
			}
		}

		if (!stageTesting)
			Stage = new Stage(SONG.stage);

		var positions = Stage.positions[Stage.curStage];
		if (positions != null && !stageTesting)
		{
			for (char => pos in positions)
				for (person in [boyfriend, gf, dad])
					if (person.curCharacter == char)
						person.setPosition(pos[0], pos[1]);
		}
		for (i in Stage.toAdd)
		{
			add(i);
		}
		if (!PlayStateChangeables.Optimize)
			for (index => array in Stage.layInFront)
			{
				switch (index)
				{
					case 0:
						add(gf);
						gf.scrollFactor.set(0.95, 0.95);
						for (bg in array)
							add(bg);
					case 1:
						add(dad);
						for (bg in array)
							add(bg);
					case 2:
						add(boyfriend);
						for (bg in array)
							add(bg);
				}
			}

		camPos = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (dad.curCharacter)
		{
			case 'gf' | 'gf-covid' | 'gf-ht' | 'gf-placeholder':
				// JOELwindows7: multi same with other gf variants. the Home Theater also had left down up right as well!
				// NO, not the deviant of sacred timeline (*Variant*), geez calm down TVA wtf lmao!!!
				if (!stageTesting)
					dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}
			case 'gf-standalone':
				// JOELwindows7: reserved for future use
				// basically gf get down from speaker and duet against player 1
				// dad.y += 100;
				// dad.x -= 100;
				switch (gfCheck)
				{
					case 'gf':
					// remove the gf from speaker
					case 'gf-ht':
					// don't do anything and stay cool. no change.
					default:
						// do something if the GF is speaker.
				}
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
			case 'senpai':
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				if (FlxG.save.data.distractions)
				{
					// trailArea.scrollFactor.set();
					if (!PlayStateChangeables.Optimize)
					{
						var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
						// evilTrail.changeValuesEnabled(false, false, false, false);
						// evilTrail.changeGraphic()
						add(evilTrail);
					}
					// evilTrail.scrollFactor.set(1.1, 1.1);
				}

				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'hookx':
			// JOELwindows7:
			// I am sorry to happened. I have no idea.
			// world is bad. not worth living
			// but why give up, we got something
			// take my hand. I'll be waiting you outside
			// dad.y += 100;
			// dad.x -= 150;
			case 'placeholder':
				// dad.y += 100;
				// dad.x -= 150;
				camPos.set(dad.getGraphicMidpoint().x + 220, dad.getGraphicMidpoint().y);
			default:
				Debug.logTrace("Oh no! it looks like you forgot the offset position data for Player 2 " + SONG.player2);
				Debug.logInfo("Forgot offset position data for Player2 " + SONG.player2);
		}

		// JOELwindows7: REPOSITIONING PER BOYFRIEND
		switch (SONG.player1)
		{
			case 'bf':
			// No need, the stage repositionings has already based on bf itself
			// its positioning has been for bf himself
			case 'placeholder':
			// boyfriend.y -= 220;
			default:
				// no repositioning
		}
		// Optional unless your character is not default bf

		Stage.update(0);

		if (loadRep)
		{
			FlxG.watch.addQuick('rep rpesses', repPresses);
			FlxG.watch.addQuick('rep releases', repReleases);
			// FlxG.watch.addQuick('Queued',inputsQueued);

			PlayStateChangeables.useDownscroll = rep.replay.isDownscroll;
			PlayStateChangeables.safeFrames = rep.replay.sf;
			PlayStateChangeables.botPlay = true;
		}

		trace('uh ' + PlayStateChangeables.safeFrames);

		trace("SF CALC: " + Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));

		doof = null; // JOELwindows7: make it global, pls!
		eoof = null; // JOELwinodws7: epilogue box too!

		if (isStoryMode)
		{
			doof = new DialogueBox(false, dialogue, SONG.hasDialogueChat);
			// doof.x += 70;
			// doof.y = FlxG.height * 0.5;
			doof.scrollFactor.set();
			doof.finishThing = startCountdown;

			// JOELwindows7: new epilogue way
			eoof = new DialogueBox(false, epilogue, SONG.hasEpilogueChat, true);
			// eoof.x += 70;
			// eoof.y = FlxG.height * 0.5;
			eoof.scrollFactor.set(); // JOELwindows7: also set scroll factor too for epilogue box!
			eoof.finishThing = endSong; // JOELwindows7: ahh, now I get it. the callable variable is filled right here. okay! I thought..
		}

		if (!isStoryMode && songMultiplier == 1)
		{
			var firstNoteTime = Math.POSITIVE_INFINITY;
			var playerTurn = false;
			for (index => section in SONG.notes)
			{
				if (section.sectionNotes.length > 0 && !isSM)
				{
					if (section.startTime > 5000)
					{
						needSkip = true;
						skipTo = section.startTime - 1000;
					}
					break;
				}
				else if (isSM)
				{
					for (note in section.sectionNotes)
					{
						if (note[0] < firstNoteTime)
						{
							if (!PlayStateChangeables.Optimize)
							{
								firstNoteTime = note[0];
								if (note[1] > 3)
									playerTurn = true;
								else
									playerTurn = false;
							}
							else if (note[1] > 3)
							{
								firstNoteTime = note[0];
							}
						}
					}
					if (index + 1 == SONG.notes.length)
					{
						var timing = ((!playerTurn && !PlayStateChangeables.Optimize) ? firstNoteTime : TimingStruct.getTimeFromBeat(TimingStruct.getBeatFromTime(firstNoteTime)
							- 4));
						if (timing > 5000)
						{
							needSkip = true;
							skipTo = timing - 1000;
						}
					}
				}
			}
		}

		Conductor.songPosition = -5000;
		Conductor.rawPosition = Conductor.songPosition;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		if (PlayStateChangeables.useDownscroll)
			strumLine.y = FlxG.height - 165;

		laneunderlayOpponent = new FlxSprite(0, 0).makeGraphic(110 * 4 + 50, FlxG.height * 2);
		laneunderlayOpponent.alpha = FlxG.save.data.laneTransparency;
		laneunderlayOpponent.color = FlxColor.BLACK;
		laneunderlayOpponent.scrollFactor.set();

		laneunderlay = new FlxSprite(0, 0).makeGraphic(110 * 4 + 50, FlxG.height * 2);
		laneunderlay.alpha = FlxG.save.data.laneTransparency;
		laneunderlay.color = FlxColor.BLACK;
		laneunderlay.scrollFactor.set();

		if (FlxG.save.data.laneUnderlay && !PlayStateChangeables.Optimize)
		{
			if (!FlxG.save.data.middleScroll || executeModchart)
			{
				add(laneunderlayOpponent);
			}
			add(laneunderlay);
		}

		strumLineNotes = new FlxTypedGroup<StaticArrow>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<StaticArrow>();
		cpuStrums = new FlxTypedGroup<StaticArrow>();

		noteskinPixelSprite = NoteskinHelpers.generatePixelSprite(FlxG.save.data.noteskin);
		noteskinSprite = NoteskinHelpers.generateNoteskinSprite(FlxG.save.data.noteskin);
		noteskinPixelSpriteEnds = NoteskinHelpers.generatePixelSprite(FlxG.save.data.noteskin, true);

		generateStaticArrows(0);
		generateStaticArrows(1);

		// Update lane underlay positions AFTER static arrows :)

		laneunderlay.x = playerStrums.members[0].x - 25;
		laneunderlayOpponent.x = cpuStrums.members[0].x - 25;

		laneunderlay.screenCenter(Y);
		laneunderlayOpponent.screenCenter(Y);

		// startCountdown();

		if (SONG.songId == null)
			trace('song is null???');
		else
			trace('song looks gucci');

		generateSong(SONG.songId);

		#if FEATURE_LUAMODCHART
		if (executeModchart)
		{
			luaModchart = ModchartState.createModchartState(isStoryMode);
			luaModchart.executeState('start', [PlayState.SONG.songId]);
			luaModchart.setVar('songLength', songLength);
		}
		if (executeStageScript && stageScript != null)
		{
			stageScript.executeState('start', [PlayState.SONG.songId]);
			stageScript.setVar('songLength', songLength);
		}
		#end
		// JOELwindows7: now for the hscript init
		if (executeModHscript)
		{
			hscriptModchart = HaxeScriptState.createModchartState();
			hscriptModchart.executeState('start', [PlayState.SONG.songId]);
			hscriptModchart.setVar('executeModchart', executeModchart);
			hscriptModchart.setVar('executeModHscript', executeModHscript);
			hscriptModchart.setVar('songLength', songLength);
		}
		if (executeStageHscript && stageHscript != null)
		{
			stageHscript.executeState('start', [PlayState.SONG.songId]);
			stageHscript.setVar('songLength', songLength);
		}
		// JOELwindows7: tell Lua script whether hscript is running too
		#if FEATURE_LUAMODCHART
		if (executeModchart)
		{
			luaModchart.setVar('executeModchart', executeModchart);
			luaModchart.setVar('executeModHscript', executeModHscript);
		}
		if (executeStageScript && stageScript != null)
		{
			stageScript.setVar('executeModchart', executeModchart);
			stageScript.setVar('executeModHscript', executeModHscript);
		}
		#end

		#if FEATURE_LUAMODCHART
		if (executeModchart)
		{
			new LuaCamera(camGame, "camGame").Register(ModchartState.lua);
			new LuaCamera(camHUD, "camHUD").Register(ModchartState.lua);
			new LuaCamera(camSustains, "camSustains").Register(ModchartState.lua);
			new LuaCamera(camSustains, "camNotes").Register(ModchartState.lua);
			new LuaCharacter(dad, "dad").Register(ModchartState.lua);
			new LuaCharacter(gf, "gf").Register(ModchartState.lua);
			new LuaCharacter(boyfriend, "boyfriend").Register(ModchartState.lua);
		}
		#end

		var index = 0;

		if (startTime != 0)
		{
			var toBeRemoved = [];
			for (i in 0...unspawnNotes.length)
			{
				var dunceNote:Note = unspawnNotes[i];

				if (dunceNote.strumTime <= startTime)
					toBeRemoved.push(dunceNote);
			}

			for (i in toBeRemoved)
				unspawnNotes.remove(i);

			Debug.logTrace("Removed " + toBeRemoved.length + " cuz of start time");
		}

		trace('generated');

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		// trace("add cam follow");

		#if !mobile
		// JOELwindows7: issue with Android version, this function crash!
		FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
		#else
		FlxG.camera.follow(camFollow, LOCKON, 0.008);
		// use Banbud's trickster .008
		// JOELwindows7: from Klavier & Verwex
		// https://github.com/KlavierGayming/FNF-Micd-Up-Mobile/blob/main/source/PlayState.hx
		/*camera lockon/follow tutorial:
			0.01 - Real fucking slow
			0.04 - Normal 60Fps speed
			0.10 - 90 Fps speed
			0.16 - Micd up speed */
		#end
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = Stage.camZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		// trace("set cam FlxG");

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.loadImage('healthBar'));
		if (PlayStateChangeables.useDownscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		/* //JOELwindows7: moved to Character.hx class. embedded at definition of character frame
			if(FlxG.save.data.colour)
			{
			 switch (SONG.player2)
			   {
				 case 'gf' | 'gf-covid' | 'strawberry-clock':
				 healthBar.createFilledBar(0xFFFF0000, 0xFF0097C4); //FULL red
				 case 'hookx' | 'sky' | 'carol': //JOELwindows7: Protoglin Amexamlef. 
				 //we had revealed from reserved folders.
				 healthBar.createFilledBar(0xFF5000E6,0xFF0097C4); //Purple Manifesto
				 case 'whitty':
				 healthBar.createFilledBar(0xFFFF8000,0xFF0097C4); //glowing eye orange
				 case 'updike':
				 healthBar.createFilledBar(0xFFFFFFFF,0xFF0097C4); //Just white
				 case 'sarvente' | 'sarvente-dark':
				 healthBar.createFilledBar(0xFFFF80FF,0xFF0097C4); //Pink Sacred
				 case 'sarvente-lucifer':
				 healthBar.createFilledBar(0xFFFF0066,0xFF0097C4); //Semple Pink, Anish Kappor shoo!
				 case 'selever':
				 healthBar.createFilledBar(0xFFB3003B,0xFF0097C4); //Maroone Velvet
				 case 'ruv' | 'kapi':
				 healthBar.createFilledBar(0xFF5C5C8A,0xFF0097C4); //Russian Blue
				 case 'puella':
				 healthBar.createFilledBar(0xFF9900cc,0xFF0097C4); //Hat purple
				 case 'placeholder':
				 healthBar.createFilledBar(0xFF0D0D0D,0xFF0097C4); //Gray
				 case 'tankman' | 'gamewatch':
				 healthBar.createFilledBar(0xFF000000,0xFF0097C4); //Activated Charcoal	
				 case 'dad' | 'mom-car' | 'parents-christmas':
				 healthBar.createFilledBar(0xFF5A07F5, 0xFF0097C4);
				 case 'spooky':
				  healthBar.createFilledBar(0xFFF57E07, 0xFF0097C4);
				 case 'monster-christmas' | 'monster':
				  healthBar.createFilledBar(0xFFF5DD07, 0xFF0097C4);
				 case 'pico':
				  healthBar.createFilledBar(0xFF52B514, 0xFF0097C4);
				 case 'senpai' | 'senpai-angry':
				  healthBar.createFilledBar(0xFFF76D6D, 0xFF0097C4);
				 case 'spirit':
				  healthBar.createFilledBar(0xFFAD0505, 0xFF0097C4);
				 default:
				  healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
				}
			}
			else
			 healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		 */
		// healthBar
		// add(healthBar);

		// JOELwindows7: add reupload watermark
		// usually, YouTube mod showcase only shows gameplay
		// and there are some naughty youtubers who did not credit link in description neither comment.
		reuploadWatermark = new FlxText((FlxG.width / 2)
			- 100, (FlxG.height / 2)
			+ 50, 0,
			"Download Last Funkin Moments ($0) https://github.com/Perkedel/kaded-fnf-mods,\n"
			+ "Kade Engine ($0) https://github.com/KadeDev/Kade-Engine ,\n"
			+ "and vanilla funkin ($0) https://github.com/ninjamuffin99/Funkin\n",
			12);
		reuploadWatermark.setPosition((FlxG.width / 2) - (reuploadWatermark.width / 2), (FlxG.height / 2) + 50);
		// Ah damn. the pivot of all Haxe Object is top left!
		// right, let's just work this all around anyway.
		// there I got it. hopefully it's centered.
		reuploadWatermark.scrollFactor.set();
		reuploadWatermark.setFormat(Paths.font("vcr.ttf"), 12, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(reuploadWatermark);
		reuploadWatermark.visible = false;
		// follow this example, you must be protected too from those credit-less YouTubers the bastards!
		// We anchored the watermark dead center, just 50 px down abit.

		// JOELwindows7: I add watermark Perkedel Mod
		// Add Kade Engine watermark
		kadeEngineWatermark = new FlxText(4, healthBarBG.y
			+ 50, 0,
			SONG.songName
			+ (FlxMath.roundDecimal(songMultiplier, 2) != 1.00 ? " (" + FlxMath.roundDecimal(songMultiplier, 2) + "x)" : "")
			+ " - "
			+ CoolUtil.difficultyFromInt(storyDifficulty) // + (Main.watermarks ? " | KE " + MainMenuState.kadeEngineVer : "")
				// + (Main.perkedelMark ? " | LFM " + MainMenuState.lastFunkinMomentVer : "")
			, 16);
		kadeEngineWatermark.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		kadeEngineWatermark.scrollFactor.set();
		add(kadeEngineWatermark);

		if (PlayStateChangeables.useDownscroll)
			kadeEngineWatermark.y = FlxG.height * 0.9 + 45;

		scoreTxt = new FlxText(FlxG.width / 2 - 235, healthBarBG.y + 50, 0, "", 20);
		// JOELwindows7: move this up a bit due to elongated texts.
		// Y was 50px beneath health bar BG
		// oh this had Kaded already?
		scoreTxt.screenCenter(X);
		scoreTxt.scrollFactor.set();
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.text = Ratings.CalculateRanking(
			songScore, 
			songScoreDef, 
			nps, 
			maxNPS, 
			accuracy, 
			heartRate[0],
			heartTierIsRightNow[0]
			); // JOELwindows7: this is just recently popped up.
		if (!FlxG.save.data.healthBar)
			scoreTxt.y = healthBarBG.y;

		add(scoreTxt);

		judgementCounter = new FlxText(20, 0, 0, "", 20);
		judgementCounter.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		judgementCounter.borderSize = 2;
		judgementCounter.borderQuality = 2;
		judgementCounter.scrollFactor.set();
		judgementCounter.cameras = [camHUD];
		judgementCounter.screenCenter(Y);
		judgementCounter.text = 'Sicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\nMisses: ${misses}';
		if (FlxG.save.data.judgementCounter)
		{
			add(judgementCounter);
		}

		replayTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0, "REPLAY",
			20);
		replayTxt.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		replayTxt.borderSize = 4;
		replayTxt.borderQuality = 2;
		replayTxt.scrollFactor.set();
		replayTxt.cameras = [camHUD];
		if (loadRep)
		{
			add(replayTxt);
		}
		// Literally copy-paste of the above, fu
		botPlayState = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0,
			"BOTPLAY", 20);
		botPlayState.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botPlayState.scrollFactor.set();
		botPlayState.borderSize = 4;
		botPlayState.borderQuality = 2;
		botPlayState.cameras = [camHUD];
		if (PlayStateChangeables.botPlay && !loadRep)
			add(botPlayState);
		// JOELwindows7: install Psyched blinking botplay Text
		fadeOutBotplayText();

		addedBotplay = PlayStateChangeables.botPlay;

		iconP1 = new HealthIcon(boyfriend.curCharacter, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);

		iconP2 = new HealthIcon(dad.curCharacter, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);

		if (FlxG.save.data.healthBar)
		{
			add(healthBarBG);
			add(healthBar);
			add(iconP1);
			add(iconP2);

			if (FlxG.save.data.colour)
				healthBar.createFilledBar(dad.barColor, boyfriend.barColor);
			else
				healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		}

		// JOELwindows7: install pause button
		addPauseButton(Std.int((FlxG.width / 2) - (128 / 2)), 80);
		trace("install pause button");

		// JOELwindows7: install credit Rolls
		creditRollout = new CreditRollout();
		creditRollout.build();
		// add(creditRollout);
		add(creditRollout.textTitle);
		add(creditRollout.textName);
		add(creditRollout.textRole);

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		laneunderlay.cameras = [camHUD];
		laneunderlayOpponent.cameras = [camHUD];

		if (isStoryMode)
		{
			doof.cameras = [camHUD];
			eoof.cameras = [camHUD]; // JOELwindows7: stick the epilogue to camera
		}
		pauseButton.cameras = [camHUD]; // JOELwindows7: stick the pause button to camera
		// touchscreenButtons.cameras = [camHUD]; //JOELwindows7: stick the touchscreen buttons to camera
		kadeEngineWatermark.cameras = [camHUD];
		reuploadWatermark.cameras = [camHUD]; // JOELwindows7: stick the reupload watermark to camera
		// creditRollout.cameras = [camHUD]; //JOELwindows7: da credit must be stuck to the HUD field
		creditRollout.textTitle.cameras = [camHUD]; // JOELwindows7: pls whynt work wtf
		creditRollout.textName.cameras = [camHUD]; // JOELwindows7: cmon man
		creditRollout.textRole.cameras = [camHUD]; // JOELwindows7: aaaaaaa man
		// JOELwindows7: install touchscreen buttons
		if (FlxG.save.data.useTouchScreenButtons)
		{
			trace("Installing touchscreen buttons...");
			addTouchScreenButtons(4, false);
			trace("Installed touchscreen buttons");
			// onScreenGameplayButtons.cameras = [camHUD];
		}

		startingSong = true;
		finishingSong = false;

		trace('starting');

		dad.dance();
		boyfriend.dance();
		gf.dance();

		if (isStoryMode)
		{
			switch (StringTools.replace(curSong, " ", "-").toLowerCase())
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						// JOELwindows7: vibrate the device
						Controls.vibrate(0, 2700);
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: Stage.camZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});
				case 'senpai' | 'senpai-midi':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					// JOELwindows7: vibrate device as it this angery
					Controls.vibrate(0, 1000);
					schoolIntro(doof);
				case 'roses-midi': // JOELwindows7: for midi version
					FlxG.sound.play(Paths.sound('ANGRY-midi'));
					// JOELwindows7: vibrate device as it this angery
					Controls.vibrate(0, 1000);
					schoolIntro(doof);
				case 'thorns' | 'thorns-midi':
					schoolIntro(doof);
				default:
					introScene(); // JOELwindows7: start intro cutscene!

					new FlxTimer().start(SONG.delayBeforeStart, function(timer:FlxTimer)
					{ // JOELwindows7: also add delay before start
						// for intro cutscene after video and before dialogue chat you know!
						// JOELwindows7: Heuristic for using JSON chart instead
						if (SONG.hasDialogueChat)
						{
							schoolIntro(doof);
						}
						else
						{
							new FlxTimer().start(1, function(timer)
							{
								startCountdown();
							});
						}
					});
			}
		}
		else
		{
			// JOELwindows7: also bring the fix to if not story mode, freeplay thingie
			// trace("No something School Intro to do in freeplay mode for " + curSong + ". start countdown anyway");
			new FlxTimer().start(1, function(timer)
			{
				startCountdown();
			});
		}

		if (!loadRep)
			rep = new Replay("na");

		// This allow arrow key to be detected by flixel. See https://github.com/HaxeFlixel/flixel/issues/2190
		FlxG.keys.preventDefaultKeys = []; // JOELwindows7: wait, put the android back button there!
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, releaseInput);
		super.create();

		trace("grepke super create e");

		// JOELwindows7: install debugge haxeflixeler
		// commands
		FlxG.console.registerFunction("startFakeCountdown", function()
		{
			startFakeCountdown();
		});
		FlxG.console.registerFunction("trainStart", function()
		{
			PlayState.Stage.trainStart();
		});
		FlxG.console.registerFunction("trainReset", function()
		{
			PlayState.Stage.trainReset();
		});
		FlxG.console.registerFunction("fastCarDrive", function()
		{
			PlayState.Stage.fastCarDrive();
		});
		FlxG.console.registerFunction("resetFastCar", function()
		{
			PlayState.Stage.resetFastCar();
		});
		FlxG.console.registerFunction("debugSeven", function()
		{
			haveDebugSevened = true;
		});
		FlxG.console.registerFunction("lightningStrikeShit", function()
		{
			PlayState.Stage.lightningStrikeShit();
		});
		FlxG.console.registerFunction("justCheer", function()
		{
			justCheer();
		});
		FlxG.console.registerFunction("justHey", function()
		{
			justHey();
		});
		FlxG.console.registerFunction("justCheerHey", function()
		{
			justHey();
			justCheer();
		});

		// JOELwindows7: Now Init CustomStage scripts if had to.
		if (attemptStageScript)
		{
			Stage.spawnStageScript("stages/" + toCompatCase(SONG.stage) + "/stageScript");
		}

		// JOELwindows7: show credit rollouts if the song has to do so
		if (SONG.isCreditRoll)
		{
			creditRollout.loadCreditData(Paths.creditFlashBlink(SONG.song), SONG.creditRunsOnce);
		}

		FlxG.autoPause = true; // JOELwindows7: because somehow the film does not return it back

		// JOELwindows7: why the peck with touchscreen button game crash on second run?!
		trace("finish create PlayState");
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		// trace("has school intro " + Std.string(dialogueBox));
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (PlayState.SONG.songId == 'roses'
			|| PlayState.SONG.songId == 'thorns'
			|| PlayState.SONG.songId == 'roses-midi'
			|| PlayState.SONG.songId == 'thorns-midi')
		{
			remove(black);

			if (PlayState.SONG.songId == 'thorns' || PlayState.SONG.songId == 'thorns-midi')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					// JOELwindows7: omg what?!?!
					if (PlayState.SONG.songId == 'thorns' || PlayState.SONG.songId == 'thorns-midi')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								// JOELwindows7: detect MIDI version
								FlxG.sound.play(Paths.sound(PlayState.SONG.songId.contains('midi') ? 'Senpai_Dies-midi' : 'Senpai_Dies'), 1, false, null, true,
									function()
									{
										remove(senpaiEvil);
										remove(red);
										FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
										{
											add(dialogueBox);
										}, true);
									});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
								// JOELwindows7: I hope this is asynchronous here.
								// vibrate device in this seconden
								new FlxTimer().start(2.4, function(deadTime:FlxTimer)
								{
									if (FlxG.save.data.vibration)
									{
										Controls.vibrate(0, 2800);
									}
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	// JOELwindows7: schoolOutro thingy before endSong function in case
	// it had end dialogue a.k.a. Epilogue
	// inspired from above dialogue launcher School intro
	function schoolOutro(?dialogueBox:DialogueBox):Void
	{
		// first, hide these botom bars and their icosn
		// healthBar.visible = false;
		// healthBarBG.visible = false;
		iconP1.visible = false;
		iconP2.visible = false;

		// First, mute the music and vocals. like endSong.
		// also disable the pause to prevent accident pause by press enter which also moves the dialogue.
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;

		// Stop the music and vocal too
		// FlxG.sound.music.stop();
		// vocals.stop();

		// Pay attention for the pre-dialogue effect show like in Rose, senpai got mad thingy
		switch (SONG.song.toLowerCase())
		{
			default:
				{}
		}

		if (dialogueBox != null)
		{
			inCutscene = true;

			// omg what?
			switch (SONG.song.toLowerCase())
			{
				default:
					add(dialogueBox);
			}
		}
		else
			endSong();

		// it looks like the finishThing variable calling means call the function who called it again. right?
		// so it then fell to the empty dialog.
	}

	var startTimer:FlxTimer;
	var fakeTimer:FlxTimer; // JOELwindows7: for fake timing stuff like fake countdown somthing
	var perfectMode:Bool = false;
	var luaWiggles:Array<WiggleEffect> = [];
	var hscriptWiggles:Array<WiggleEffect> = []; // JOELwindows7: same but hscript

	#if FEATURE_LUAMODCHART
	public static var luaModchart:ModchartState = null;
	public static var stageScript:ModchartState = null;
	#end
	// JOELwindows7: same as above but hscript.
	public static var hscriptModchart:HaxeScriptState = null;
	public static var stageHscript:HaxeScriptState = null;

	function startCountdown():Void
	{
		// JOELwindows7: feggin renew song length
		renewSongLengths();

		var silent:Bool = SONG.silentCountdown;
		var invisible:Bool = SONG.invisibleCountdown;
		var reversed:Bool = SONG.reversedCountdown;

		// trace("startCountdown! Begin Funkin now");
		inCutscene = false;

		// JOELwindows7:visiblize buttons
		/*
			if(onScreenGameplayButtons != null){
				trace("visible touchscreen buttons");
				//onScreenGameplayButtons.visible = true;
				//onScreenGameplayButtons.alpha = 0;
			}
		 */
		// trace("visible touchscreen buttons");
		// showOnScreenGameplayButtons();

		// trace("Generate Static arrows");
		appearStaticArrows();
		// generateStaticArrows(0);
		// generateStaticArrows(1);

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		if (FlxG.sound.music.playing)
			FlxG.sound.music.stop();
		if (vocals != null)
			vocals.stop();

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			// this just based on beatHit stuff but compact
			if (allowedToHeadbang && swagCounter % gfSpeed == 0)
				gf.dance();
			if (swagCounter % idleBeat == 0)
			{
				if (idleToBeat && !boyfriend.animation.curAnim.name.endsWith("miss"))
					boyfriend.dance(forcedToIdle);
				if (idleToBeat)
					dad.dance(forcedToIdle);
			}
			else if (dad.curCharacter == 'spooky' || dad.curCharacter == 'gf')
				dad.dance();

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			var altSuffix:String = "";
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('pixel', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var week6Bullshit:String = null;

			// JOELwindows7: detect MIDI suffix
			var detectMidiSuffix:String = '-midi';
			var midiSuffix:String = "midi";

			if (SONG.noteStyle == 'pixel')
			{
				introAlts = introAssets.get('pixel');
				altSuffix = '-pixel';
				week6Bullshit = 'week6';
			}

			// JOELwindows7: scan MIDI suffix in the song name
			if (PlayState.SONG.songId.contains(detectMidiSuffix.trim()))
			{
				midiSuffix = detectMidiSuffix;
			}
			else
				midiSuffix = "";

			switch (swagCounter)

			{
				case 0:
					// JOELwindows7:Lol! I added reverse
					if (!silent)
						FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage(introAlts[0], week6Bullshit));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (SONG.noteStyle == 'pixel')
						ready.setGraphicSize(Std.int(ready.width * CoolUtil.daPixelZoom));

					ready.screenCenter();
					add(ready);
					if (invisible)
						ready.visible = false; // JOELwindows7: infisipel
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					if (!silent) // JOELwindows7: Silencio Bruno!
						FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage(introAlts[1], week6Bullshit));
					set.scrollFactor.set();

					if (SONG.noteStyle == 'pixel')
						set.setGraphicSize(Std.int(set.width * CoolUtil.daPixelZoom));

					set.screenCenter();
					add(set);
					if (invisible)
						set.visible = false; // JOELwindows7: inbizibel
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					if (!silent) // JOELwindows7: ssshhh
						FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage(introAlts[2], week6Bullshit));
					go.scrollFactor.set();

					if (SONG.noteStyle == 'pixel')
						go.setGraphicSize(Std.int(go.width * CoolUtil.daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					if (invisible)
						go.visible = false; // JOELwindows7: disepir
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					if (!silent) // JOELwindows7: quiet!
						FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);

					// JOELwindows7: now visiblize the touchscreen buttons
					/*
						if(touchscreenButtons != null){
							touchscreenButtons.visible = true;
						}
					 */
					// if(onScreenGameplayButtons != null){
					// 	onScreenGameplayButtons.visible = true;
					// 	//and add cool animations
					// 	//FlxTween.tween(onScreenGameplayButtons,{alpha:1}, 1, {ease:FlxEase.circInOut});
					// 	//try luckydog7's renditions
					// 	//well, apparently, adjusting parent's alpha also affects all children's alpha
					// 	//inside it. right, where the peck is self modulate alpha?!??!!?
					// 	/*
					// 	FlxTween.num(onScreenGameplayButtons.alpha, 1, 1,
					// 		{ease: FlxEase.circInOut},
					// 		function (a:Float) {
					// 			onScreenGameplayButtons.alpha = a;
					// 		});
					// 	*/
					// }
					trace("visiblize touchscreen button now");
					showOnScreenGameplayButtons();
					// case 4: //JOELwindows7: don't delete SONG start case!
					// JOELwindows7: just add trace for fun
					trace("Run the song now!");

					// JOELwindows7: start Credit rolling if the song has so
					if (SONG.isCreditRoll && creditRollout != null)
					{
						creditRollout.startRolling();
					}
			}

			swagCounter += 1;
		}, 4);

		// JOELwindows7: num of countdown loop decreased from 5 to 4. ok, Kade.
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	private function getKey(charCode:Int):String
	{
		for (key => value in FlxKey.fromStringMap)
		{
			if (charCode == value)
				return key;
		}
		return null;
	}

	var keys = [false, false, false, false];

	private function releaseInput(evt:KeyboardEvent):Void // handles releases
	{
		@:privateAccess
		var key = FlxKey.toStringMap.get(evt.keyCode);

		var binds:Array<String> = [
			FlxG.save.data.leftBind,
			FlxG.save.data.downBind,
			FlxG.save.data.upBind,
			FlxG.save.data.rightBind
		];

		var data = -1;

		switch (evt.keyCode) // arrow keys
		{
			case 37:
				data = 0;
			case 40:
				data = 1;
			case 38:
				data = 2;
			case 39:
				data = 3;
		}

		for (i in 0...binds.length) // binds
		{
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}

		if (data == -1)
			return;

		keys[data] = false;
	}

	public var closestNotes:Array<Note> = [];

	private function handleInput(evt:KeyboardEvent):Void
	{ // this actually handles press inputs

		if (PlayStateChangeables.botPlay || loadRep || paused)
			return;

		// first convert it from openfl to a flixel key code
		// then use FlxKey to get the key's name based off of the FlxKey dictionary
		// this makes it work for special characters

		@:privateAccess
		var key = FlxKey.toStringMap.get(evt.keyCode);

		var binds:Array<String> = [
			FlxG.save.data.leftBind,
			FlxG.save.data.downBind,
			FlxG.save.data.upBind,
			FlxG.save.data.rightBind
		];

		var data = -1;

		switch (evt.keyCode) // arrow keys
		{
			case 37:
				data = 0;
			case 40:
				data = 1;
			case 38:
				data = 2;
			case 39:
				data = 3;
		}

		for (i in 0...binds.length) // binds
		{
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}
		if (data == -1)
		{
			trace("couldn't find a keybind with the code " + key);
			return;
		}
		if (keys[data])
		{
			trace("ur already holding " + key);
			return;
		}

		keys[data] = true;

		var ana = new Ana(Conductor.songPosition, null, false, "miss", data);

		closestNotes = [];

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.wasGoodHit)
				closestNotes.push(daNote);
		}); // Collect notes that can be hit

		closestNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

		var dataNotes = [];
		for (i in closestNotes)
			if (i.noteData == data && !i.isSustainNote)
				dataNotes.push(i);

		trace("notes able to hit for " + key.toString() + " " + dataNotes.length);

		if (dataNotes.length != 0)
		{
			var coolNote = null;

			for (i in dataNotes)
			{
				coolNote = i;
				break;
			}

			if (dataNotes.length > 1) // stacked notes or really close ones
			{
				for (i in 0...dataNotes.length)
				{
					if (i == 0) // skip the first note
						continue;

					var note = dataNotes[i];

					if (!note.isSustainNote && ((note.strumTime - coolNote.strumTime) < 2) && note.noteData == data)
					{
						trace('found a stacked/really close note ' + (note.strumTime - coolNote.strumTime));
						// just fuckin remove it since it's a stacked note and shouldn't be there
						note.kill();
						notes.remove(note, true);
						note.destroy();
					}
				}
			}

			boyfriend.holdTimer = 0;
			goodNoteHit(coolNote);
			var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
			ana.hit = true;
			ana.hitJudge = Ratings.judgeNote(noteDiff);
			ana.nearestNote = [coolNote.strumTime, coolNote.noteData, coolNote.sustainLength];
		}
		else if (!FlxG.save.data.ghost && songStarted)
		{
			noteMiss(data, null);
			ana.hit = false;
			ana.hitJudge = "shit";
			ana.nearestNote = [];
			health -= 0.20;
		}
	}

	public var songStarted = false;

	public var doAnything = false;

	public static var songMultiplier = 1.0;

	public var bar:FlxSprite;

	public var previousRate = songMultiplier;

	function startSong():Void
	{
		// JOELwindows7: visiblize the watermark once the song has begun
		reuploadWatermark.visible = true;
		// then the Update() function above will invisibilize again
		// after 8 curBeats.

		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.music.play();
		vocals.play();

		// have them all dance when the song starts
		if (allowedToHeadbang)
			gf.dance();
		if (idleToBeat && !boyfriend.animation.curAnim.name.startsWith("sing"))
			boyfriend.dance(forcedToIdle);
		if (idleToBeat && !dad.animation.curAnim.name.startsWith("sing"))
			dad.dance(forcedToIdle);

		// Song check real quick
		switch (curSong)
		{
			//JOELwindows7: frogot to change convention lmao
			case 'bopeebo' | 'philly' | 'blammed' | 'cocoa' | 'eggnog':
				allowedToCheer = true;
			default:
				allowedToCheer = SONG.allowedToHeadbang; // JOELwindows7: define by the JSON chart instead
				// use "allowedToHeadbang": true to your JSON chart (per difficulty) to enable headbangs.
		}

		if (useVideo)
			GlobalVideo.get().resume();

		#if FEATURE_LUAMODCHART
		if (executeModchart)
			luaModchart.executeState("songStart", [null]);
		// JOELwindows7: here on the other side too song started
		if (executeStageScript)
			stageScript.executeState("songStart", [null]);
		#end
		if (executeModHscript)
			hscriptModchart.executeState('songStart', [null]);
		if (executeStageHscript)
			stageHscript.executeState('songStart', [null]);

		#if FEATURE_DISCORD
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end

		FlxG.sound.music.time = startTime;
		if (vocals != null)
			vocals.time = startTime;
		Conductor.songPosition = startTime;
		startTime = 0;

		/*@:privateAccess
			{
				var aux = AL.createAux();
				var fx = AL.createEffect();
				AL.effectf(fx,AL.PITCH,songMultiplier);
				AL.auxi(aux, AL.EFFECTSLOT_EFFECT, fx);
				var instSource = FlxG.sound.music._channel.__source;

				var backend:lime._internal.backend.native.NativeAudioSource = instSource.__backend;

				AL.source3i(backend.handle, AL.AUXILIARY_SEND_FILTER, aux, 1, AL.FILTER_NULL);
				if (vocals != null)
				{
					var vocalSource = vocals._channel.__source;

					backend = vocalSource.__backend;
					AL.source3i(backend.handle, AL.AUXILIARY_SEND_FILTER, aux, 1, AL.FILTER_NULL);
				}

				trace("pitched to " + songMultiplier);
		}*/

		// JOELwindows7: this Haxedef marks if audio manipulation is available. cpp only
		#if FEATURE_AUDIO_MANIPULATE
		@:privateAccess
		{
			lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
			if (vocals.playing)
				lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
		}
		trace("pitched inst and vocals to " + songMultiplier);
		#end

		for (i in 0...unspawnNotes.length)
			if (unspawnNotes[i].strumTime < startTime)
				unspawnNotes.remove(unspawnNotes[i]);

		if (needSkip)
		{
			skipActive = true;
			skipText = new FlxText(healthBarBG.x + 80, healthBarBG.y - 110, 500);
			skipText.text = "Press Space to Skip Intro";
			skipText.size = 30;
			skipText.color = FlxColor.WHITE;
			skipText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2, 1);
			skipText.cameras = [camHUD];
			skipText.alpha = 0;
			FlxTween.tween(skipText, {alpha: 1}, 0.2);
			add(skipText);
		}
	}

	var debugNum:Int = 0;

	public function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.songId;

		#if FEATURE_STEPMANIA
		if (SONG.needsVoices && !isSM)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.songId));
		else
			vocals = new FlxSound();
		#else
		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.songId));
		else
			vocals = new FlxSound();
		#end

		trace('loaded vocals');

		FlxG.sound.list.add(vocals);

		if (!paused)
		{
			// trace("Geh Generate song");
			#if FEATURE_STEPMANIA
			if (!isStoryMode && isSM)
			{
				trace("Loading " + pathToSm + "/" + sm.header.MUSIC);
				var bytes = File.getBytes(pathToSm + "/" + sm.header.MUSIC);
				var sound = new Sound();
				sound.loadCompressedDataFromByteArray(bytes.getData(), bytes.length);
				FlxG.sound.playMusic(sound);
			}
			else
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.songId), 1, false);
			#else
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.songId), 1, false);
			#end
		}

		FlxG.sound.music.looped = false; // JOELwindows7: okay try to make this unloop.
		// FlxG.sound.music.onComplete = endSong;
		// FlxG.sound.music.onComplete = checkEpilogueChat; // Moved to somewhere again
		// JOELwindows7: now instead pls check the epilogue chat!
		FlxG.sound.music.pause();

		if (SONG.needsVoices && !PlayState.isSM)
			FlxG.sound.cache(Paths.voices(PlayState.SONG.songId));
		if (!PlayState.isSM)
			FlxG.sound.cache(Paths.inst(PlayState.SONG.songId));

		// Song duration in a float, useful for the time left feature
		songLength = ((FlxG.sound.music.length / songMultiplier) / 1000);

		Conductor.crochet = ((60 / (SONG.bpm) * 1000));
		Conductor.stepCrochet = Conductor.crochet / 4;

		if (FlxG.save.data.songPosition)
		{
			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.loadImage('healthBar'));
			if (PlayStateChangeables.useDownscroll)
				songPosBG.y = FlxG.height * 0.9 + 35;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();

			songPosBar = new FlxBar(640 - (Std.int(songPosBG.width - 100) / 2), songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 100),
				Std.int(songPosBG.height + 6), this, 'songPositionBar', 0, songLength);
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.BLACK, FlxColor.fromRGB(0, 255, 128));
			add(songPosBar);

			bar = new FlxSprite(songPosBar.x, songPosBar.y).makeGraphic(Math.floor(songPosBar.width), Math.floor(songPosBar.height), FlxColor.TRANSPARENT);

			add(bar);

			FlxSpriteUtil.drawRect(bar, 0, 0, songPosBar.width, songPosBar.height, FlxColor.TRANSPARENT, {thickness: 4, color: FlxColor.BLACK});

			songPosBG.width = songPosBar.width;

			// JOELwindows7: Pls put artist
			songName = new FlxText(songPosBG.x
				+ (songPosBG.width / 2)
				- ((SONG.songName.length + 3 + SONG.artist.length) * 5), songPosBG.y
				- 15, 0,
				SONG.artist
				+ " - "
				+ SONG.songName, 16);
			songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.scrollFactor.set();

			songName.text = SONG.songName + ' (' + FlxStringUtil.formatTime(songLength, false) + ')';
			songName.y = songPosBG.y + (songPosBG.height / 3);

			add(songName);

			songName.screenCenter(X);

			songPosBG.cameras = [camHUD];
			bar.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
			songName.cameras = [camHUD];
		}

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] / songMultiplier;
				if (daStrumTime < 0)
					daStrumTime = 0;
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = true;

				if (songNotes[1] > 3 && section.mustHitSection)
					gottaHitNote = false;
				else if (songNotes[1] < 4 && !section.mustHitSection)
					gottaHitNote = false;

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, false, false, songNotes[4]);

				if (!gottaHitNote && PlayStateChangeables.Optimize)
					continue;

				swagNote.sustainLength = TimingStruct.getTimeFromBeat((TimingStruct.getBeatFromTime(songNotes[2] / songMultiplier)));
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				swagNote.isAlt = songNotes[3]
					|| ((section.altAnim || section.CPUAltAnim) && !gottaHitNote)
					|| (section.playerAltAnim && gottaHitNote);

				if (susLength > 0)
					swagNote.isParent = true;

				var type = 0;

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);
					sustainNote.isAlt = songNotes[3]
						|| ((section.altAnim || section.CPUAltAnim) && !gottaHitNote)
						|| (section.playerAltAnim && gottaHitNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}

					sustainNote.parent = swagNote;
					swagNote.children.push(sustainNote);
					sustainNote.spotInLine = type;
					type++;
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;

		Debug.logTrace("whats the fuckin shit");
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:StaticArrow = new StaticArrow(-10, strumLine.y);

			// defaults if no noteStyle was found in chart
			var noteTypeCheck:String = 'normal';

			if (PlayStateChangeables.Optimize && player == 0)
				continue;

			if (SONG.noteStyle == null && FlxG.save.data.overrideNoteskins)
			{
				switch (storyWeek)
				{
					case 6:
						noteTypeCheck = 'pixel';
				}
			}
			else
			{
				noteTypeCheck = SONG.noteStyle;
			}

			/* //JOELwindows7: use Custom notestyle noteskin folder
				if(SONG.useCustomNoteStyle){
					babyArrow.frames = Paths.getSparrowAtlas('noteskins/'+ noteTypeCheck +'/NOTE_assets');
					for (j in 0...4)
					{
						babyArrow.animation.addByPrefix(dataColor[j], 'arrow' + dataSuffix[j]);	
					}

					var lowerDir:String = dataSuffix[i].toLowerCase();

					babyArrow.animation.addByPrefix('static', 'arrow' + dataSuffix[i]);
					babyArrow.animation.addByPrefix('pressed', lowerDir + ' press', 24, false);
					babyArrow.animation.addByPrefix('confirm', lowerDir + ' confirm', 24, false);

					babyArrow.x += Note.swagWidth * i;

					babyArrow.antialiasing = FlxG.save.data.antialiasing;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 
						(noteTypeCheck.contains('pixel')? daPixelZoom : 0.7)
						)
						);
				} else
			 */ // JOELwindows7: Kade probably has new procedural noteskin loader I guess

			switch (noteTypeCheck)
			{
				case 'pixel':
					babyArrow.loadGraphic(noteskinPixelSprite, true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * CoolUtil.daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					babyArrow.x += Note.swagWidth * i;
					babyArrow.animation.add('static', [i]);
					babyArrow.animation.add('pressed', [4 + i, 8 + i], 12, false);
					babyArrow.animation.add('confirm', [12 + i, 16 + i], 24, false);

					for (j in 0...4)
					{
						babyArrow.animation.add('dirCon' + j, [12 + j, 16 + j], 24, false);
					}
				/*
					case 'saubo':
						//JOELwindows7: LFM original noteskin
						babyArrow.frames = Paths.getSparrowAtlas('noteskins/saubo/NOTE_assets');
						for (j in 0...4)
						{
							babyArrow.animation.addByPrefix(dataColor[j], 'arrow' + dataSuffix[j]);	
							babyArrow.animation.addByPrefix('dirCon' + j, dataSuffix[j].toLowerCase() + ' confirm', 24, false);
						}

						var lowerDir:String = dataSuffix[i].toLowerCase();

						babyArrow.animation.addByPrefix('static', 'arrow' + dataSuffix[i]);
						babyArrow.animation.addByPrefix('pressed', lowerDir + ' press', 24, false);
						babyArrow.animation.addByPrefix('confirm', lowerDir + ' confirm', 24, false);

						babyArrow.x += Note.swagWidth * i;

						babyArrow.antialiasing = FlxG.save.data.antialiasing;
						babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
				 */

				default:
					babyArrow.frames = noteskinSprite;
					Debug.logTrace(babyArrow.frames);
					for (j in 0...4)
					{
						babyArrow.animation.addByPrefix(dataColor[j], 'arrow' + dataSuffix[j]);
						babyArrow.animation.addByPrefix('dirCon' + j, dataSuffix[j].toLowerCase() + ' confirm', 24, false);
					}

					var lowerDir:String = dataSuffix[i].toLowerCase();

					babyArrow.animation.addByPrefix('static', 'arrow' + dataSuffix[i]);
					babyArrow.animation.addByPrefix('pressed', lowerDir + ' press', 24, false);
					babyArrow.animation.addByPrefix('confirm', lowerDir + ' confirm', 24, false);

					babyArrow.x += Note.swagWidth * i;

					babyArrow.antialiasing = FlxG.save.data.antialiasing;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			babyArrow.alpha = 0;
			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				// babyArrow.alpha = 0;
				// TODO: JOELwindows7: execute stage script & hscript
				if (!FlxG.save.data.middleScroll || (executeModchart || executeModHscript) || player == 1)
					FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			switch (player)
			{
				case 0:
					babyArrow.x += 20;
					cpuStrums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
			}

			babyArrow.playAnim('static');
			babyArrow.x += 110;
			babyArrow.x += ((FlxG.width / 2) * player);

			// JOELwindows7: filtere Haxe script
			if (PlayStateChangeables.Optimize || (FlxG.save.data.middleScroll && !(executeModchart || executeModHscript)))
				babyArrow.x -= 320;

			cpuStrums.forEach(function(spr:FlxSprite)
			{
				spr.centerOffsets(); // CPU arrows start out slightly off-center
			});

			strumLineNotes.add(babyArrow);
		}
	}

	private function appearStaticArrows():Void
	{
		var index = 0;
		strumLineNotes.forEach(function(babyArrow:FlxSprite)
		{
			// JOELwindows7: if or haxescript
			if (isStoryMode && !FlxG.save.data.middleScroll || (executeModchart || executeModHscript))
				babyArrow.alpha = 1;
			if (index > 3 && FlxG.save.data.middleScroll)
				babyArrow.alpha = 1;
			index++;
		});
	}

	// JOELwindows7: make public for modchart
	public function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music.playing)
			{
				FlxG.sound.music.pause();
				if (vocals != null)
					if (vocals.playing)
						vocals.pause();
			}

			#if FEATURE_DISCORD
			DiscordClient.changePresence("PAUSED on "
				+ SONG.song
				+ " ("
				+ storyDifficultyText
				+ ") "
				+ Ratings.GenerateLetterRank(accuracy),
				"\nAcc: "
				+ HelperFunctions.truncateFloat(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Misses: "
				+ misses, iconRPC);
			#end
			if (!startTimer.finished)
				startTimer.active = false;

			// JOELwindows7: inviblize buttoneings
			/*
				if(touchscreenButtons != null){
					touchscreenButtons.visible = false;
				}
			 */
			// if(onScreenGameplayButtons != null){
			// 	onScreenGameplayButtons.visible = false;
			// }
			hideOnScreenGameplayButtons();
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (PauseSubState.goToOptions)
		{
			Debug.logTrace("pause thingyt");
			if (PauseSubState.goBack)
			{
				Debug.logTrace("pause thingyt");
				PauseSubState.goToOptions = false;
				PauseSubState.goBack = false;
				openSubState(new PauseSubState());
			}
			else
				openSubState(new OptionsMenu(true));
		}
		else if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if FEATURE_DISCORD
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText
					+ " "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC, true,
					songLength
					- Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.songName + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), iconRPC);
			}
			#end

			// JOELwindows7: revisiblize touchscreen buttons
			/*
				if(touchscreenButtons != null){
					touchscreenButtons.visible = true;
				}
			 */
			// if(onScreenGameplayButtons != null){
			// 	onScreenGameplayButtons.visible = true;
			// }
			showOnScreenGameplayButtons();
		}

		super.closeSubState();
	}

	function resyncVocals():Void
	{
		vocals.stop();
		FlxG.sound.music.stop();

		FlxG.sound.music.play();
		vocals.play();
		FlxG.sound.music.time = Conductor.songPosition * songMultiplier;
		vocals.time = FlxG.sound.music.time;

		@:privateAccess
		{
			// JOELwindows7: add haxedef FEATURE_AUDIO_MANIPULATE if cpp desktop?
			#if FEATURE_AUDIO_MANIPULATE
			// The __backend.handle attribute is only available on native.
			lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
			if (vocals.playing)
				lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
			#end
		}

		#if FEATURE_DISCORD
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end
	}

	public var paused:Bool = false;

	var startedCountdown:Bool = false;
	var startedFakeCounting:Bool = false; // JOELwindows7: oh fake countdown
	var canPause:Bool = true;
	var nps:Int = 0;
	var maxNPS:Int = 0;

	// public static var songRate = 1.5; //JOELwindows7: was here. now deleted.
	public var stopUpdate = false;
	public var removedVideo = false;

	public var currentBPM = 0;

	public var updateFrame = 0;

	public var pastScrollChanges:Array<Song.Event> = [];

	var currentLuaIndex = 0;

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end
		if (!PlayStateChangeables.Optimize)
			Stage.update(elapsed);

		if (!addedBotplay && FlxG.save.data.botplay)
		{
			PlayStateChangeables.botPlay = true;
			addedBotplay = true;
			add(botPlayState);
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 14000 * songMultiplier)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				#if FEATURE_LUAMODCHART
				if (executeModchart)
				{
					new LuaNote(dunceNote, currentLuaIndex);
					dunceNote.luaID = currentLuaIndex;
				}
				#end

				if (executeModchart)
				{
					#if FEATURE_LUAMODCHART
					if (!dunceNote.isSustainNote)
						dunceNote.cameras = [camNotes];
					else
						dunceNote.cameras = [camSustains];
					#end
				}
				else
				{
					dunceNote.cameras = [camHUD];
				}

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
				currentLuaIndex++;
			}
		}

		// JOELwindows7: audio manipulate haxedef
		#if FEATURE_AUDIO_MANIPULATE
		if (FlxG.sound.music.playing)
			@:privateAccess
		{
			lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
			if (vocals.playing)
				lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
		}
		#end

		if (generatedMusic)
		{
			if (songStarted && !endingSong)
			{
				// Song ends abruptly on slow rate even with second condition being deleted,
				// and if it's deleted on songs like cocoa then it would end without finishing instrumental fully,
				// so no reason to delete it at all
				if (unspawnNotes.length == 0 && notes.length == 0 && FlxG.sound.music.time / songMultiplier > (songLength - 100))
				{
					Debug.logTrace("we're fuckin ending the song ");

					endingSong = true;
					new FlxTimer().start(2, function(timer)
					{
						// endSong();
						checkEpilogueChat(); // JOELwindows7: you sneaky little punk!
						// you have endSong just little bit earlier in case stroffs.
					});
				}
			}
		}

		if (updateFrame == 4)
		{
			TimingStruct.clearTimings();

			var currentIndex = 0;
			for (i in SONG.eventObjects)
			{
				if (i.type == "BPM Change")
				{
					var beat:Float = i.position;

					var endBeat:Float = Math.POSITIVE_INFINITY;

					var bpm = i.value * songMultiplier;

					TimingStruct.addTiming(beat, bpm, endBeat, 0); // offset in this case = start time since we don't have a offset

					if (currentIndex != 0)
					{
						var data = TimingStruct.AllTimings[currentIndex - 1];
						data.endBeat = beat;
						data.length = ((data.endBeat - data.startBeat) / (data.bpm / 60)) / songMultiplier;
						var step = ((60 / data.bpm) * 1000) / 4;
						TimingStruct.AllTimings[currentIndex].startStep = Math.floor((((data.endBeat / (data.bpm / 60)) * 1000) / step) / songMultiplier);
						TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length / songMultiplier;
					}

					currentIndex++;
				}
			}

			updateFrame++;
		}
		else if (updateFrame != 5)
			updateFrame++;

		if (FlxG.sound.music.playing)
		{
			var timingSeg = TimingStruct.getTimingAtBeat(curDecimalBeat);

			if (timingSeg != null)
			{
				var timingSegBpm = timingSeg.bpm;

				if (timingSegBpm != Conductor.bpm)
				{
					trace("BPM CHANGE to " + timingSegBpm);
					Conductor.changeBPM(timingSegBpm, false);
					Conductor.crochet = ((60 / (timingSegBpm) * 1000)) / songMultiplier;
					Conductor.stepCrochet = Conductor.crochet / 4;
				}
			}

			var newScroll = 1.0;

			// if(SONG != null && SONG.eventObjects != null) //JOELwindows7: somehow werror if eventObject null. wait. where's it?
			for (i in SONG.eventObjects)
			{
				switch (i.type)
				{
					case "Scroll Speed Change":
						if (i.position <= curDecimalBeat && !pastScrollChanges.contains(i))
						{
							pastScrollChanges.push(i);
							trace("SCROLL SPEED CHANGE to " + i.value);
							newScroll = i.value;
						}
					case "Cheer Now":
						justCheer(true);
					case "Hey Now":
						justHey(true);
					case "Cheer Hey Now":
						if (i.value == 0 || i.value == 1 || i.value > 2 || i.value < 0)
							justCheer(true);
						if (i.value == 0 || i.value == 2 || i.value > 2 || i.value < 0)
							justHey(true);
					case "Camera Zoom in":
						camZoomNow(i.value);
					case "HUD Zoom in":
						camZoomNow(0, i.value);
					case "Both Zoom in":
						camZoomNow(i.value, i.value);
				}
			}

			if (newScroll != 0)
				PlayStateChangeables.scrollSpeed *= newScroll;

			// FlxG.watch.addQuick("Musnic playing",[newScroll,timingSeg]);
		}

		if (PlayStateChangeables.botPlay && FlxG.keys.justPressed.ONE)
			camHUD.visible = !camHUD.visible;

		if (useVideo && GlobalVideo.get() != null && !stopUpdate)
		{
			if (GlobalVideo.get().ended && !removedVideo)
			{
				remove(videoSprite);
				removedVideo = true;
			}
		}

		#if FEATURE_LUAMODCHART
		if (executeModchart && luaModchart != null && songStarted)
		{
			luaModchart.setVar('songPos', Conductor.songPosition);
			luaModchart.setVar('hudZoom', camHUD.zoom);
			luaModchart.setVar('curBeat', HelperFunctions.truncateFloat(curDecimalBeat, 3));
			luaModchart.setVar('cameraZoom', FlxG.camera.zoom);

			luaModchart.executeState('update', [elapsed]);
			// JOELwindows7: okay I think this is a good place to constantly update variable
			// that must be updated. idk.
			luaModchart.setVar("originalColor", Stage.originalColor);
			luaModchart.setVar("isChromaScreen", Stage.isChromaScreen);

			for (key => value in luaModchart.luaWiggles)
			{
				trace('wiggle le gaming');
				value.update(elapsed);
			}

			PlayStateChangeables.useDownscroll = luaModchart.getVar("downscroll", "bool");

			/*for (i in 0...strumLineNotes.length) {
				var member = strumLineNotes.members[i];
				member.x = luaModchart.getVar("strum" + i + "X", "float");
				member.y = luaModchart.getVar("strum" + i + "Y", "float");
				member.angle = luaModchart.getVar("strum" + i + "Angle", "float");
			}*/

			FlxG.camera.angle = luaModchart.getVar('cameraAngle', 'float');
			camHUD.angle = luaModchart.getVar('camHudAngle', 'float');

			if (luaModchart.getVar("showOnlyStrums", 'bool'))
			{
				healthBarBG.visible = false;
				kadeEngineWatermark.visible = false;
				healthBar.visible = false;
				iconP1.visible = false;
				iconP2.visible = false;
				scoreTxt.visible = false;
			}
			else
			{
				healthBarBG.visible = true;
				kadeEngineWatermark.visible = true;
				healthBar.visible = true;
				iconP1.visible = true;
				iconP2.visible = true;
				scoreTxt.visible = true;
			}

			var p1 = luaModchart.getVar("strumLine1Visible", 'bool');
			var p2 = luaModchart.getVar("strumLine2Visible", 'bool');

			for (i in 0...4)
			{
				strumLineNotes.members[i].visible = p1;
				if (i <= playerStrums.length)
					playerStrums.members[i].visible = p2;
			}

			camNotes.zoom = camHUD.zoom;
			camNotes.x = camHUD.x;
			camNotes.y = camHUD.y;
			camNotes.angle = camHUD.angle;
			camSustains.zoom = camHUD.zoom;
			camSustains.x = camHUD.x;
			camSustains.y = camHUD.y;
			camSustains.angle = camHUD.angle;
		}

		// JOELwindows7: for the stagescript
		if (executeStageScript && stageScript != null && songStarted)
		{
			stageScript.setVar('songPos', Conductor.songPosition);
			stageScript.setVar('hudZoom', camHUD.zoom);
			stageScript.setVar('curBeat', HelperFunctions.truncateFloat(curDecimalBeat, 3));
			stageScript.setVar('cameraZoom', FlxG.camera.zoom);
			stageScript.executeState('update', [elapsed]);

			stageScript.setVar("originalColor", Stage.originalColor);
			stageScript.setVar("isChromaScreen", Stage.isChromaScreen);
		}
		#end
		// JOELwindows7: the hscript version
		if (executeModHscript && hscriptModchart != null && songStarted)
		{
			hscriptModchart.setVar('songPos', Conductor.songPosition);
			hscriptModchart.setVar('hudZoom', camHUD.zoom);
			hscriptModchart.setVar('curBeat', HelperFunctions.truncateFloat(curDecimalBeat, 3));
			hscriptModchart.setVar('cameraZoom', FlxG.camera.zoom);
			hscriptModchart.executeState('update', [elapsed]);
			// JOELwindows7: okay I think this is a good place to constantly update variable
			// that must be updated. idk.
			hscriptModchart.setVar("originalColor", Stage.originalColor);
			hscriptModchart.setVar("isChromaScreen", Stage.isChromaScreen);

			for (key => value in hscriptModchart.haxeWiggles)
			{
				trace('wiggle le gaming');
				value.update(elapsed);
			}

			PlayStateChangeables.useDownscroll = hscriptModchart.getVar("downscroll", "bool");

			/*for (i in 0...strumLineNotes.length) {
				var member = strumLineNotes.members[i];
				member.x = hscriptModchart.getVar("strum" + i + "X", "float");
				member.y = hscriptModchart.getVar("strum" + i + "Y", "float");
				member.angle = hscriptModchart.getVar("strum" + i + "Angle", "float");
			}*/

			FlxG.camera.angle = hscriptModchart.getVar('cameraAngle', 'float');
			camHUD.angle = hscriptModchart.getVar('camHudAngle', 'float');

			if (hscriptModchart.getVar("showOnlyStrums"))
			{
				healthBarBG.visible = false;
				kadeEngineWatermark.visible = false;
				healthBar.visible = false;
				iconP1.visible = false;
				iconP2.visible = false;
				scoreTxt.visible = false;
			}
			else
			{
				healthBarBG.visible = true;
				kadeEngineWatermark.visible = true;
				healthBar.visible = true;
				iconP1.visible = true;
				iconP2.visible = true;
				scoreTxt.visible = true;
			}

			var p1 = hscriptModchart.getVar("strumLine1Visible");
			var p2 = hscriptModchart.getVar("strumLine2Visible");

			for (i in 0...4)
			{
				strumLineNotes.members[i].visible = p1;
				if (i <= playerStrums.length)
					playerStrums.members[i].visible = p2;
			}
		}
		// JOELwindows7: stage hscript
		if (executeStageHscript && stageHscript != null && songStarted)
		{
			stageHscript.setVar('songPos', Conductor.songPosition);
			stageHscript.setVar('hudZoom', camHUD.zoom);
			stageHscript.setVar('curBeat', HelperFunctions.truncateFloat(curDecimalBeat, 3));
			stageHscript.setVar('cameraZoom', FlxG.camera.zoom);
			stageHscript.executeState('update', [elapsed]);

			stageHscript.setVar("originalColor", Stage.originalColor);
			stageHscript.setVar("isChromaScreen", Stage.isChromaScreen);
		}

		// reverse iterate to remove oldest notes first and not invalidate the iteration
		// stop iteration as soon as a note is not removed
		// all notes should be kept in the correct order and this is optimal, safe to do every frame/update
		{
			var balls = notesHitArray.length - 1;
			while (balls >= 0)
			{
				var cock:Date = notesHitArray[balls];
				if (cock != null && cock.getTime() + 1000 < Date.now().getTime())
					notesHitArray.remove(cock);
				else
					balls = 0;
				balls--;
			}
			nps = notesHitArray.length;
			if (nps > maxNPS)
				maxNPS = nps;
		}

		if (FlxG.keys.justPressed.NINE)
			iconP1.swapOldIcon();

		// JOELwindows7: update heartbeat moments
		updateHeartbeat();

		if (curBeat > 8)
		{
			// JOELwindows7: invisiblize watermark after 8 curBeat
			// to prevent view obstruction
			reuploadWatermark.visible = false;
		}

		// scoreTxt.text = Ratings.CalculateRanking(
		// 	songScore,
		// 	songScoreDef,
		// 	nps,
		// 	maxNPS,
		// 	accuracy,
		// 	heartRate[0],
		// 	heartTierIsRightNow[0]
		// 	);
		scoreTxt.screenCenter(X);

		var pauseBind = FlxKey.fromString(FlxG.save.data.pauseBind);
		var gppauseBind = FlxKey.fromString(FlxG.save.data.gppauseBind);

		// JOELwindows7: add luckydog7 if pressed back button on Android
		// also add mouse click pause button
		if ((FlxG.keys.anyJustPressed([pauseBind])
			|| KeyBinds.gamepad
			&& FlxG.keys.anyJustPressed([gppauseBind])
			|| havePausened // JOELwindows7: here pause button on screen & android
			#if android || FlxG.android.justReleased.BACK #end)
			&& startedCountdown
			&& canPause
			&& !cannotDie)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				trace('GITAROO MAN EASTER EGG');
				FlxG.switchState(new GitarooPause());
				clean();
			}
			else
				openSubState(new PauseSubState());

			havePausened = false;
		}

		if (FlxG.keys.justPressed.FIVE && songStarted)
			// JOELwindows7:wait. where's debug sevened? why.. WaveformTest?!??!?
		{
			songMultiplier = 1;
			if (useVideo)
			{
				GlobalVideo.get().stop();
				remove(videoSprite);
				removedVideo = true;
			}
			cannotDie = true;
			removeTouchScreenButtons();

			FlxG.switchState(new WaveformTestState());
			clean();
			PlayState.stageTesting = false;
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
			scronchModcharts(); // JOELwindows7: do this immediately from now on.
		}

		if ((FlxG.keys.justPressed.SEVEN || haveDebugSevened) && songStarted)
			// JOELwindows7: have debug sevened, for chart option in pause menu maybe
			// lol comment necklace!
			// THERE YOU ARE. desmo lol
		{
			songMultiplier = 1;
			if (useVideo)
			{
				GlobalVideo.get().stop();
				remove(videoSprite);
				removedVideo = true;
			}
			cannotDie = true;
			removeTouchScreenButtons();

			FlxG.switchState(new ChartingState());
			clean();
			PlayState.stageTesting = false;
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			if (stageScript != null)
			{
				stageScript.die();
				stageScript = null;
			}
			#end
			scronchHscript();
			haveDebugSevened = false;
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;
		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		#if debug
		if (FlxG.keys.justPressed.SIX)
		{
			if (useVideo)
			{
				GlobalVideo.get().stop();
				remove(videoSprite);
				removedVideo = true;
			}

			removeTouchScreenButtons();
			FlxG.switchState(new AnimationDebug(dad.curCharacter));
			clean();
			PlayState.stageTesting = false;
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			// TODO: JOELwindows7: destructively revamp this. wrap these into a function. there's one, use it now!
			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			if (stageScript != null)
			{
				stageScript.die();
				stageScript = null;
			}
			#end
			scronchHscript();
		}

		if (!PlayStateChangeables.Optimize)
			if (FlxG.keys.justPressed.EIGHT && songStarted)
			{
				removeTouchScreenButtons();
				paused = true;
				if (useVideo)
				{
					GlobalVideo.get().stop();
					remove(videoSprite);
					removedVideo = true;
				}
				new FlxTimer().start(0.3, function(tmr:FlxTimer)
				{
					for (bg in Stage.toAdd)
					{
						remove(bg);
					}
					for (array in Stage.layInFront)
					{
						for (bg in array)
							remove(bg);
					}
					for (group in Stage.swagGroup)
					{
						remove(group);
					}
					remove(boyfriend);
					remove(dad);
					remove(gf);
				});
				FlxG.switchState(new StageDebugState(Stage.curStage, gf.curCharacter, boyfriend.curCharacter, dad.curCharacter));
				clean();
				FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
				FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
				#if FEATURE_LUAMODCHART
				if (luaModchart != null)
				{
					luaModchart.die();
					luaModchart = null;
				}
				if (stageScript != null)
				{
					stageScript.die();
					stageScript = null;
				}
				#end
				scronchHscript();
			}

		if (FlxG.keys.justPressed.ZERO)
		{
			removeTouchScreenButtons();
			FlxG.switchState(new AnimationDebug(boyfriend.curCharacter));
			clean();
			PlayState.stageTesting = false;
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			if (stageScript != null)
			{
				stageScript.die();
				stageScript = null;
			}
			#end
			scronchHscript();
		}

		if (FlxG.keys.justPressed.TWO && songStarted)
		{ // Go 10 seconds into the future, credit: Shadow Mario#9396
			if (!usedTimeTravel && Conductor.songPosition + 10000 < FlxG.sound.music.length)
			{
				usedTimeTravel = true;
				FlxG.sound.music.pause();
				vocals.pause();
				Conductor.songPosition += 10000;
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.strumTime - 500 < Conductor.songPosition)
					{
						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});

				FlxG.sound.music.time = Conductor.songPosition;
				FlxG.sound.music.play();

				vocals.time = Conductor.songPosition;
				vocals.play();
				new FlxTimer().start(0.5, function(tmr:FlxTimer)
				{
					usedTimeTravel = false;
				});
			}
		}
		#end

		if (skipActive && Conductor.songPosition >= skipTo)
		{
			remove(skipText);
			skipActive = false;
		}

		if (FlxG.keys.justPressed.SPACE && skipActive)
		{
			FlxG.sound.music.pause();
			vocals.pause();
			Conductor.songPosition = skipTo;
			Conductor.rawPosition = skipTo;

			FlxG.sound.music.time = Conductor.songPosition;
			FlxG.sound.music.play();

			vocals.time = Conductor.songPosition;
			vocals.play();
			FlxTween.tween(skipText, {alpha: 0}, 0.2, {
				onComplete: function(tw)
				{
					remove(skipText);
				}
			});
			skipActive = false;
		}

		if (startingSong && !finishingSong) // JOELwindows7: so let's get back here out here.
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				Conductor.rawPosition = Conductor.songPosition;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;
			Conductor.rawPosition = FlxG.sound.music.time;
			/*@:privateAccess
				{
					FlxG.sound.music._channel.
			}*/
			songPositionBar = (Conductor.songPosition - songLength) / 1000;

			currentSection = getSectionByTime(Conductor.songPosition);

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}

				var curTime:Float = FlxG.sound.music.time / songMultiplier;
				if (curTime < 0)
					curTime = 0;

				var secondsTotal:Int = Math.floor(((curTime - songLength) / 1000));
				if (secondsTotal < 0)
					secondsTotal = 0;

				if (FlxG.save.data.songPosition)
					songName.text = SONG.songName + ' (' + FlxStringUtil.formatTime((songLength - secondsTotal), false) + ')';
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && currentSection != null)
		{
			// Make sure Girlfriend cheers only for certain songs
			if (allowedToCheer)
			{
				// Don't animate GF if something else is already animating her (eg. train passing)
				if (gf.animation.curAnim.name == 'danceLeft'
					|| gf.animation.curAnim.name == 'danceRight'
					|| gf.animation.curAnim.name == 'idle')
				{
					// Per song treatment since some songs will only have the 'Hey' at certain times
					switch (curSong)
					{
						//JOELwindows7: frogot change convention to all lmao!!
						case 'philly':
							{
								// General duration of the song
								if (curBeat < 250)
								{
									// Beats to skip or to stop GF from cheering
									if (curBeat != 184 && curBeat != 216)
									{
										if (curBeat % 16 == 8)
										{
											// Just a garantee that it'll trigger just once
											if (!triggeredAlready)
											{
												gf.playAnim('cheer');
												triggeredAlready = true;
											}
										}
										else
											triggeredAlready = false;
									}
								}
							}
						case 'bopeebo':
							{
								// Where it starts || where it ends
								if (curBeat > 5 && curBeat < 130)
								{
									if (curBeat % 8 == 7)
									{
										if (!triggeredAlready)
										{
											Stage.randomizeColoring(); // JOELwindows7: change the stage light color!
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									}
									else
										triggeredAlready = false;
								}
							}
						case 'blammed':
							{
								if (curBeat > 30 && curBeat < 190)
								{
									if (curBeat < 90 || curBeat > 128)
									{
										if (curBeat % 4 == 2)
										{
											if (!triggeredAlready)
											{
												// randomizeColoring(); //JOELwindows7: change the stage light color!
												gf.playAnim('cheer');
												triggeredAlready = true;
											}
										}
										else
											triggeredAlready = false;
									}
								}
							}
						case 'cocoa':
							{
								if (curBeat < 170)
								{
									if (curBeat < 65 || curBeat > 130 && curBeat < 145)
									{
										if (curBeat % 16 == 15)
										{
											if (!triggeredAlready)
											{
												gf.playAnim('cheer');
												triggeredAlready = true;
											}
										}
										else
											triggeredAlready = false;
									}
								}
							}
						case 'eggnog':
							{
								if (curBeat > 10 && curBeat != 111 && curBeat < 220)
								{
									if (curBeat % 8 == 7)
									{
										if (!triggeredAlready)
										{
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									}
									else
										triggeredAlready = false;
								}
							}
						case 'rule-the-world':
							{
								// JOELwindows7: okay how do I supposed to cheer?
								// copy from above and adjust beat.
								// oh God. well I gotta figure this one out.
								//
								// Okay so curBeat is curStep div by 4.
								// I think if curBeat modulo 4 is 0 means every new section?
								// yes they are. so there are 0 1 2 3 in curBeat modulo 4.
								// you can granularlize it if you want like 0 1 2 3 4 5 6 7 in curBeat % 8 etc.
								if (curBeat < 16 || (curBeat > 80 && curBeat < 96) || (curBeat > 160 && curBeat < 192) || (curBeat > 264 && curBeat < 304))
								{
									if (curBeat % 4 == 0 || curBeat % 4 == 2)
									{
										if (!triggeredAlready)
										{
											Stage.randomizeColoring();
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									}
									else
										triggeredAlready = false;
								}
							}
						case 'well-meet-again':
							{
								// JOELwindows7: cheer on the beatdrop yeay
								if (!inCutscene && curBeat < 307) // make sure do this only when not in cutscene, & song still going
									if ((curBeat > 80 && curBeat < 112) || (curBeat > 176 && curBeat < 208) || (curBeat > 272 && curBeat < 308))
									{
										// copy from the hardcode zoom milfe
										cheerNow(4, 2, true);
									}
							}
						case 'fortritri':
							{
								// JOELwindows7: silence is music lmao
								// John Cage = 4'33", haha
								if (curBeat % 4 == 0)
								{
									if (!triggeredAlready)
									{
										Stage.randomizeColoring();
										triggeredAlready = true;
									}
								}
								else
									triggeredAlready = false;
							}
						case 'getting-freaky':
							{
								// JOELwindows7: temporary degradation fix.
								// the modcharted doesn't work somehow idfk why
							}
						default:
							{}
					}
				}
			}

			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
				luaModchart.setVar("mustHit", currentSection.mustHitSection);
			if (stageScript != null)
				stageScript.setVar("mustHit", PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			#end
			if (hscriptModchart != null)
				hscriptModchart.setVar("mustHit", PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			if (stageHscript != null)
				stageHscript.setVar("mustHit", PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);

			if (camFollow.x != dad.getMidpoint().x + 150 && !currentSection.mustHitSection)
			{
				var offsetX = 0;
				var offsetY = 0;
				#if FEATURE_LUAMODCHART
				if (luaModchart != null)
				{
					offsetX = luaModchart.getVar("followXOffset", "float");
					offsetY = luaModchart.getVar("followYOffset", "float");
				}
				#end
				// JOELwindows7: hscript cam offsetting
				if (hscriptModchart != null)
				{
					offsetX = hscriptModchart.getVar("followXOffset", "float");
					offsetY = hscriptModchart.getVar("followYOffset", "float");
				}
				if (Stage.overrideCamFollowP2)
				{
					// JOELwindows7: override dad cam position
					if (Stage.customStage != null)
					{
						camFollow.setPosition(Stage.customStage.camFollowP2Pos[0] + offsetX, Stage.customStage.camFollowP2Pos[1] + offsetY);
					}
					else
						camFollow.setPosition(dad.getMidpoint().x + 150 + offsetX, dad.getMidpoint().y - 100 + offsetY);
				}
				else
					// JOELwindows7: yeah cam position dad.
					camFollow.setPosition(dad.getMidpoint().x + 150 + offsetX, dad.getMidpoint().y - 100 + offsetY);
				#if FEATURE_LUAMODCHART
				if (luaModchart != null)
					luaModchart.executeState('playerTwoTurn', []);
				if (stageScript != null)
					stageScript.executeState('playerTwoTurn', []);
				#end
				if (hscriptModchart != null)
					hscriptModchart.executeState('playerTwoTurn', []);
				if (stageHscript != null)
					stageHscript.executeState('playerTwoTurn', []);
				// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

				switch (dad.curCharacter)
				{
					case 'mom' | 'mom-car':
						camFollow.y = dad.getMidpoint().y;
					case 'senpai' | 'senpai-angry':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
				}
			}

			if (currentSection.mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
			{
				var offsetX = 0;
				var offsetY = 0;
				#if FEATURE_LUAMODCHART
				if (luaModchart != null)
				{
					offsetX = luaModchart.getVar("followXOffset", "float");
					offsetY = luaModchart.getVar("followYOffset", "float");
				}
				#end
				// JOELwindows7: hscript offsete
				if (hscriptModchart != null)
				{
					offsetX = hscriptModchart.getVar("followXOffset", "float");
					offsetY = hscriptModchart.getVar("followYOffset", "float");
				}
				if (Stage.overrideCamFollowP1)
				{
					// JOELwindows7: override bf cam position
					if (Stage.customStage != null)
					{
						camFollow.setPosition(Stage.customStage.camFollowP1Pos[0] + offsetX, Stage.customStage.camFollowP1Pos[1] + offsetY);
					}
					else
						camFollow.setPosition(boyfriend.getMidpoint().x - 100 + offsetX, boyfriend.getMidpoint().y - 100 + offsetY);
				}
				else
					// JOELwindows7: yeah cam position bf.
					camFollow.setPosition(boyfriend.getMidpoint().x - 100 + offsetX, boyfriend.getMidpoint().y - 100 + offsetY);

				#if FEATURE_LUAMODCHART
				if (luaModchart != null)
					luaModchart.executeState('playerOneTurn', []);
				if (stageScript != null)
					stageScript.executeState('playerOneTurn', []);
				#end
				if (hscriptModchart != null)
					hscriptModchart.executeState('playerOneTurn', []);
				if (stageHscript != null)
					stageHscript.executeState('playerOneTurn', []);

				if (!PlayStateChangeables.Optimize)
					switch (Stage.curStage)
					{
						case 'limo':
							camFollow.x = boyfriend.getMidpoint().x - 300;
						case 'mall':
							camFollow.y = boyfriend.getMidpoint().y - 200;
						case 'school':
							camFollow.x = boyfriend.getMidpoint().x - 200;
							camFollow.y = boyfriend.getMidpoint().y - 200;
						case 'schoolEvil':
							camFollow.x = boyfriend.getMidpoint().x - 200;
							camFollow.y = boyfriend.getMidpoint().y - 200;
					}
			}
		}

		if (camZooming)
		{
			if (FlxG.save.data.zoom < 0.8)
				FlxG.save.data.zoom = 0.8;

			if (FlxG.save.data.zoom > 1.2)
				FlxG.save.data.zoom = 1.2;

			if (!executeModchart)
			{
				FlxG.camera.zoom = FlxMath.lerp(Stage.camZoom, FlxG.camera.zoom, 0.95);
				camHUD.zoom = FlxMath.lerp(FlxG.save.data.zoom, camHUD.zoom, 0.95);

				camNotes.zoom = camHUD.zoom;
				camSustains.zoom = camHUD.zoom;
			}
			else
			{
				FlxG.camera.zoom = FlxMath.lerp(Stage.camZoom, FlxG.camera.zoom, 0.95);
				camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);

				camNotes.zoom = camHUD.zoom;
				camSustains.zoom = camHUD.zoom;
			}
		}

		FlxG.watch.addQuick("curBPM", Conductor.bpm);
		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// JOELwindows7: add more watches too
		FlxG.watch.addQuick("shinzouRateShit", heartRate);
		FlxG.watch.addQuick("songPositionShit", Conductor.songPosition);
		FlxG.watch.addQuick("Ending Song", endingSong);
		FlxG.watch.addQuick("Cam Follow", [camFollow.x, camFollow.y]);
		FlxG.watch.addQuick("In Cutscene", inCutscene);
		FlxG.watch.addQuick("Camera Game Pos", [camGame.x, camGame.y]);
		FlxG.watch.addQuick("Auto Pause", FlxG.autoPause);
		FlxG.watch.addQuick("generated Music", generatedMusic);
		FlxG.watch.addQuick("starting song", startingSong);
		FlxG.watch.addQuick("finishing song", finishingSong);
		FlxG.watch.addQuick("Started Countdown", startedCountdown);
		FlxG.watch.addQuick("Song started", songStarted);
		FlxG.watch.addQuick("Allowed Headbang", allowedToCheer);
		FlxG.watch.addQuick("danced", danced);
		if (currentSection != null)
		{
			FlxG.watch.addQuick("Current Section", Std.string(currentSection));
			FlxG.watch.addQuick("Must hit", currentSection.mustHitSection);
		}

		//JOELwindows7: bruh, don't forget new convention lol
		if (curSong == 'fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				case 163:
					// FlxG.sound.music.stop();
					// FlxG.switchState(new TitleState());
			}
		}

		if (health <= 0 && !cannotDie)
		{
			if (!usedTimeTravel)
			{
				boyfriend.stunned = true;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				if (FlxG.save.data.InstantRespawn)
				{
					FlxG.switchState(new PlayState());
				}
				else
				{
					openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				}

				#if FEATURE_DISCORD
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("GAME OVER -- "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC);
				#end
				// God i love futabu!! so fucking much (From: McChomk)
				// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			}
			else
				health = 1;
		}
		if (!inCutscene && FlxG.save.data.resetButton)
		{
			var resetBind = FlxKey.fromString(FlxG.save.data.resetBind);
			var gpresetBind = FlxKey.fromString(FlxG.save.data.gpresetBind);
			if ((FlxG.keys.anyJustPressed([resetBind]) || KeyBinds.gamepad && FlxG.keys.anyJustPressed([gpresetBind])))
			{
				trace("Pressed self Eik Serkat button"); // JOELwindows7: add trace about that
				boyfriend.stunned = true;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				if (FlxG.save.data.InstantRespawn)
				{
					FlxG.switchState(new PlayState());
				}
				else
				{
					openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				}

				#if FEATURE_DISCORD
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("GAME OVER -- "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC);
				#end

				// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			}
		}

		if (generatedMusic)
		{
			var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
			var stepHeight = (0.45 * Conductor.stepCrochet * FlxMath.roundDecimal(PlayState.SONG.speed, 2));

			notes.forEachAlive(function(daNote:Note)
			{
				// instead of doing stupid y > FlxG.height
				// we be men and actually calculate the time :)

				if (!daNote.modifiedByLua)
				{
					if (PlayStateChangeables.useDownscroll)
					{
						if (daNote.mustPress)
							daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
								+
								0.45 * ((Conductor.songPosition - daNote.strumTime) / songMultiplier) * (FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2)))
								- daNote.noteYOff;
						else
							daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
								+
								0.45 * ((Conductor.songPosition - daNote.strumTime) / songMultiplier) * (FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2)))
								- daNote.noteYOff;
						if (daNote.isSustainNote)
						{
							daNote.y -= daNote.height - stepHeight;

							// If not in botplay, only clip sustain notes when properly hit, botplay gets to clip it everytime
							if ((PlayStateChangeables.botPlay
								|| !daNote.mustPress
								|| daNote.wasGoodHit
								|| holdArray[Math.floor(Math.abs(daNote.noteData))])
								&& daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= (strumLine.y + Note.swagWidth / 2))
							{
								// Clip to strumline
								var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
								swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
									+ Note.swagWidth / 2
									- daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;

								daNote.clipRect = swagRect;
							}
						}

						if (daNote.isParent)
						{
							for (i in 0...daNote.children.length)
							{
								var slide = daNote.children[i];
								slide.y = daNote.y - slide.height;
							}
						}
					}
					else
					{
						if (daNote.mustPress)
							daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
								- 0.45 * ((Conductor.songPosition - daNote.strumTime) / songMultiplier) * (FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2)))
								+ daNote.noteYOff;
						else
							daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
								- 0.45 * ((Conductor.songPosition - daNote.strumTime) / songMultiplier) * (FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2)))
								+ daNote.noteYOff;
						if (daNote.isSustainNote)
						{
							if ((PlayStateChangeables.botPlay
								|| !daNote.mustPress
								|| daNote.wasGoodHit
								|| holdArray[Math.floor(Math.abs(daNote.noteData))])
								&& daNote.y + daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2))
							{
								// Clip to strumline
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
									+ Note.swagWidth / 2
									- daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;

								daNote.clipRect = swagRect;
							}
						}
					}
				}

				if (!daNote.mustPress && Conductor.songPosition >= daNote.strumTime)
				{
					if (SONG.songId != 'tutorial')
						camZooming = true;

					var altAnim:String = "";

					if (daNote.isAlt)
					{
						altAnim = '-alt';
						trace("YOO WTF THIS IS AN ALT NOTE????");
					}

					// Accessing the animation name directly to play it
					if (!daNote.isParent && daNote.parent != null)
					{
						if (daNote.spotInLine != daNote.parent.children.length - 1)
						{
							var singData:Int = Std.int(Math.abs(daNote.noteData));
							dad.playAnim('sing' + dataSuffix[singData] + altAnim, true);

							if (FlxG.save.data.cpuStrums)
							{
								cpuStrums.forEach(function(spr:StaticArrow)
								{
									pressArrow(spr, spr.ID, daNote);
									/*
										if (spr.animation.curAnim.name == 'confirm' && SONG.noteStyle != 'pixel')
										{
											spr.centerOffsets();
											spr.offset.x -= 13;
											spr.offset.y -= 13;
										}
										else
											spr.centerOffsets();
									 */
								});
							}

							#if FEATURE_LUAMODCHART
							if (luaModchart != null)
								luaModchart.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition]);
							if (stageScript != null)
								stageScript.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition]);
							#end
							if (hscriptModchart != null)
								hscriptModchart.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition]);
							if (stageHscript != null)
								stageHscript.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition]);

							dad.holdTimer = 0;

							if (SONG.needsVoices)
								vocals.volume = 1;
						}
					}
					else
					{
						var singData:Int = Std.int(Math.abs(daNote.noteData));
						dad.playAnim('sing' + dataSuffix[singData] + altAnim, true);

						if (FlxG.save.data.cpuStrums)
						{
							cpuStrums.forEach(function(spr:StaticArrow)
							{
								pressArrow(spr, spr.ID, daNote);
								/*
									if (spr.animation.curAnim.name == 'confirm' && SONG.noteStyle != 'pixel')
									{
										spr.centerOffsets();
										spr.offset.x -= 13;
										spr.offset.y -= 13;
									}
									else
										spr.centerOffsets();
								 */
							});
						}

						#if FEATURE_LUAMODCHART
						if (luaModchart != null)
							luaModchart.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition]);
						if (stageScript != null)
							stageScript.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition]);
						#end
						if (hscriptModchart != null)
							hscriptModchart.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition]);
						if (stageHscript != null)
							stageHscript.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition]);

						dad.holdTimer = 0;

						if (SONG.needsVoices)
							vocals.volume = 1;
					}
					daNote.active = false;

					if (!daNote.isSustainNote)
						successfullyStep(1); // JOELwindows7:successfully step for p2

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				if (daNote.mustPress && !daNote.modifiedByLua)
				{
					daNote.visible = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].visible;
					daNote.x = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote)
						daNote.modAngle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].modAngle;
					if (daNote.sustainActive)
					{
						if (executeModchart || executeModHscript)
							daNote.alpha = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					}
					daNote.modAngle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].modAngle;
				}
				else if (!daNote.wasGoodHit && !daNote.modifiedByLua)
				{
					daNote.visible = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].visible;
					daNote.x = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote)
						daNote.modAngle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].modAngle;
					if (daNote.sustainActive)
					{
						if (executeModchart || executeModHscript)
							daNote.alpha = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					}
					daNote.modAngle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].modAngle;
				}

				if (!daNote.mustPress && FlxG.save.data.middleScroll && !executeModchart)
					daNote.alpha = 0;

				if (daNote.isSustainNote)
				{
					daNote.x += daNote.width / 2 + 20;
					if (SONG.noteStyle == 'pixel')
						daNote.x -= 11;
				}

				// trace(daNote.y);
				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				if (daNote.isSustainNote && daNote.wasGoodHit && Conductor.songPosition >= daNote.strumTime)
				{
					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
				else if ((daNote.mustPress && !PlayStateChangeables.useDownscroll || daNote.mustPress && PlayStateChangeables.useDownscroll)
					&& daNote.mustPress
					&& daNote.strumTime / songMultiplier - Conductor.songPosition / songMultiplier < -(166 * Conductor.timeScale)
					&& songStarted)
				{
					if (daNote.isSustainNote && daNote.wasGoodHit)
					{
						daNote.kill();
						notes.remove(daNote, true);
					}
					else
					{
						// JOELwindows7: Skip da mine
						if (daNote.noteType == 2)
						{
							trace("Sneaked past the mine whew");
						}
						// JOELwindows7: Missed supposed note
						if (daNote.noteType == 1 || daNote.noteType == 0)
							if (loadRep && daNote.isSustainNote)
							{
								// im tired and lazy this sucks I know i'm dumb
								if (findByTime(daNote.strumTime) != null)
									totalNotesHit += 1;
								else
								{
									vocals.volume = 0;
									if (theFunne && !daNote.isSustainNote)
									{
										noteMiss(daNote.noteData, daNote);
									}
									if (daNote.isParent)
									{
										health -= 0.15; // give a health punishment for failing a LN
										trace("hold fell over at the start");
										for (i in daNote.children)
										{
											i.alpha = 0.3;
											i.sustainActive = false;
										}
									}
									else
									{
										if (!daNote.wasGoodHit
											&& daNote.isSustainNote
											&& daNote.sustainActive
											&& daNote.spotInLine != daNote.parent.children.length)
										{
											// health -= 0.05; // give a health punishment for failing a LN
											trace("hold fell over at " + daNote.spotInLine);
											for (i in daNote.parent.children)
											{
												i.alpha = 0.3;
												i.sustainActive = false;
											}
											if (daNote.parent.wasGoodHit)
											{
												misses++;
												totalNotesHit -= 1;
											}
											updateAccuracy();
										}
										else if (!daNote.wasGoodHit && !daNote.isSustainNote)
										{
											health -= 0.15;
										}
									}
								}
							}
							else
							{
								vocals.volume = 0;
								if (theFunne && !daNote.isSustainNote)
								{
									if (PlayStateChangeables.botPlay)
									{
										daNote.rating = "bad";
										goodNoteHit(daNote);
									}
									else
										noteMiss(daNote.noteData, daNote);
								}

								if (daNote.isParent && daNote.visible)
								{
									health -= 0.15; // give a health punishment for failing a LN
									trace("hold fell over at the start");
									for (i in daNote.children)
									{
										i.alpha = 0.3;
										i.sustainActive = false;
									}
								}
								else
								{
									if (!daNote.wasGoodHit
										&& daNote.isSustainNote
										&& daNote.sustainActive
										&& daNote.spotInLine != daNote.parent.children.length)
									{
										// health -= 0.05; // give a health punishment for failing a LN
										trace("hold fell over at " + daNote.spotInLine);
										for (i in daNote.parent.children)
										{
											i.alpha = 0.3;
											i.sustainActive = false;
										}
										if (daNote.parent.wasGoodHit)
										{
											misses++;
											totalNotesHit -= 1;
										}
										updateAccuracy();
									}
									else if (!daNote.wasGoodHit && !daNote.isSustainNote)
									{
										health -= 0.15;
									}
								}
							}
					}

					daNote.visible = false;
					daNote.kill();
					notes.remove(daNote, true);
				}
			});
		}

		if (FlxG.save.data.cpuStrums)
		{
			cpuStrums.forEach(function(spr:StaticArrow)
			{
				if (spr.animation.finished)
				{
					spr.playAnim('static');
					spr.centerOffsets();
				}
			});
		}

		if (!inCutscene && songStarted)
			keyShit();

		// JOELwindows7: moved mouse thingy to manageMouse();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end

		super.update(elapsed);
	}

	// JOELwindows7: check if the song should display epilogue chat once the song has finished.
	function checkEpilogueChat():Void
	{
		endingSong = true; // Just in case somekind of forgor
		songStarted = false; // try to do this?
		// startingSong = true; //Oh maybe this helps simulate like if the song is on preparation?
		finishingSong = true; // fine let's phreaking do redundancy.
		FlxG.sound.music.stop(); // Stop the music now man.
		trace("Check Epilogue " + Std.string(SONG.hasEpilogueChat) + "\n and isStoryMode " + Std.string(isStoryMode));
		// fade and hide the touchscreen button
		removeTouchScreenButtons();
		// if song has epilogue chat then do this
		if (SONG.hasEpilogueChat && (isStoryMode))
		{
			schoolOutro(eoof);
		}
		else
			endSong();
	}

	public function getSectionByTime(ms:Float):SwagSection
	{
		// FlxG.watch.addQuick("ms Section by time", ms);
		for (i in SONG.notes)
		{
			var start = TimingStruct.getTimeFromBeat((TimingStruct.getBeatFromTime(i.startTime)));
			var end = TimingStruct.getTimeFromBeat((TimingStruct.getBeatFromTime(i.endTime)));

			// FlxG.watch.addQuick("i in Song Note", [start, end, i]); //JOELwindows7: idk what error
			// is from of the subsequent song wtf man

			if (ms >= start && ms < end)
			{
				return i;
			}
		}

		// FlxG.watch.addQuick("i in Song Note", [null, null, null]); //JOELwindows7: pls help!
		// sir you have to convert the song. you forgot to do this so on next song in story mode.
		return null;
	}

	function recalculateAllSectionTimes()
	{
		trace("RECALCULATING SECTION TIMES");

		for (i in 0...SONG.notes.length) // loops through sections
		{
			var section = SONG.notes[i];

			var currentBeat = 4 * i;

			var currentSeg = TimingStruct.getTimingAtBeat(currentBeat);

			if (currentSeg == null)
				return;

			var start:Float = (currentBeat - currentSeg.startBeat) / ((currentSeg.bpm) / 60);

			section.startTime = (currentSeg.startTime + start) * 1000;

			if (i != 0)
				SONG.notes[i - 1].endTime = section.startTime;
			section.endTime = Math.POSITIVE_INFINITY;
		}
	}

	function endSong():Void
	{
		endingSong = true;
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
		if (useVideo)
		{
			GlobalVideo.get().stop();
			PlayState.instance.remove(PlayState.instance.videoSprite);
		}

		if (!loadRep)
			rep.SaveReplay(saveNotes, saveJudge, replayAna);
		else
		{
			PlayStateChangeables.botPlay = false;
			PlayStateChangeables.scrollSpeed = 1 / songMultiplier;
			PlayStateChangeables.useDownscroll = false;
		}

		if (FlxG.save.data.fpsCap > 290)
		{
			trace("return the FPS cap");
			// JOELwindows7: issue with Android version. cast lib current technic crash it
			#if FEATURE_DISPLAY_FPS_CHANGE
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(290);
			#end
		}

		trace("unload mod chart");

		#if FEATURE_LUAMODCHART
		if (luaModchart != null)
		{
			luaModchart.die();
			luaModchart = null;
		}
		if (stageScript != null)
		{
			stageScript.die();
			stageScript = null;
		}
		#end
		scronchHscript();

		// JOELwindows7: stuff to end
		if (creditRollout != null)
		{
			creditRollout.stopRolling(); // end the credit roll first.
		}

		trace("clearing gameplay"); // JOELwindows7: you trace

		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		FlxG.sound.music.stop();
		vocals.stop();
		if (SONG.validScore)
		{
			#if !switch
			Highscore.saveScore(PlayState.SONG.songId, Math.round(songScore), storyDifficulty);
			Highscore.saveCombo(PlayState.SONG.songId, Ratings.GenerateLetterRank(accuracy), storyDifficulty);
			#end
		}
		trace("saved score now!");

		if (offsetTesting)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			offsetTesting = false;
			LoadingState.loadAndSwitchState(new OptionsMenu());
			clean();
			FlxG.save.data.offset = offsetTest;
		}
		else if (stageTesting)
		{
			new FlxTimer().start(0.3, function(tmr:FlxTimer)
			{
				for (bg in Stage.toAdd)
				{
					remove(bg);
				}
				for (array in Stage.layInFront)
				{
					for (bg in array)
						remove(bg);
				}
				remove(boyfriend);
				remove(dad);
				remove(gf);
			});
			FlxG.switchState(new StageDebugState(Stage.curStage));
		}
		else
		{
			if (isStoryMode)
			{
				campaignScore += Math.round(songScore);
				campaignMisses += misses;
				campaignSicks += sicks;
				campaignGoods += goods;
				campaignBads += bads;
				campaignShits += shits;

				// JOELwindows7: wait! remember the song name first!
				var lastSonginPlaylist = StringTools.replace(PlayState.storyPlaylist[0], " ", "-").toLowerCase();

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;

					paused = true;

					// JOELwindows7: delay time before go to next song
					var delayFirstBeforeThat:Float = SONG.delayAfterFinish;
					// for that eggnog light shut off thingy e.g.

					FlxG.sound.music.stop();
					vocals.stop();
					// JOELwindows7: here timer guys
					outroScene(lastSonginPlaylist);
					new FlxTimer().start(delayFirstBeforeThat, function(tmr:FlxTimer)
					{
						if (FlxG.save.data.scoreScreen)
						{
							if (FlxG.save.data.songPosition)
							{
								FlxTween.tween(songPosBar, {alpha: 0}, 1);
								FlxTween.tween(bar, {alpha: 0}, 1);
								FlxTween.tween(songName, {alpha: 0}, 1);
							}
							openSubState(new ResultsScreen(SONG.hasEpilogueVideo, SONG.hasEpilogueVideo ? SONG.epilogueVideoPath : "null"));
							new FlxTimer().start(1, function(tmr:FlxTimer)
							{
								inResults = true;
							});
						}
						else
						{
							GameplayCustomizeState.freeplayBf = 'bf';
							GameplayCustomizeState.freeplayDad = 'dad';
							GameplayCustomizeState.freeplayGf = 'gf';
							GameplayCustomizeState.freeplayNoteStyle = 'normal';
							GameplayCustomizeState.freeplayStage = 'stage';
							GameplayCustomizeState.freeplaySong = 'bopeebo';
							GameplayCustomizeState.freeplayWeek = 1;
							FlxG.sound.playMusic(Paths.music('freakyMenu'));
							Conductor.changeBPM(102);
							// FlxG.switchState(new StoryMenuState());
							FlxG.switchState(SONG.hasEpilogueVideo ? VideoCutscener.getThe(SONG.epilogueVideoPath,
								new StoryMenuState()) : new StoryMenuState());
							// JOELwindows7: complicated! oh MY GOD!
							clean();
						}
					});
					// JOELwindows7: clean was here, but now inside that?!

					#if FEATURE_LUAMODCHART
					if (luaModchart != null)
					{
						luaModchart.die();
						luaModchart = null;
					}
					if (stageScript != null)
					{
						stageScript.die();
						stageScript = null;
					}
					#end
					scronchHscript();

					if (SONG.validScore)
					{
						// AchievementUnlocked.whichIs("anSpook"); //JOELwindows7: achievement unlocked beat week
						checkWeekComplete();
						Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
					}

					StoryMenuState.unlockNextWeek(storyWeek);
				}
				else
				{
					var diff:String = ["-easy", "", "-hard"][storyDifficulty];

					Debug.logInfo('PlayState: Loading next story song ${PlayState.storyPlaylist[0]}-${diff}');

					// JOELwindows7: delay time before go to next song
					var delayFirstBeforeThat:Float = SONG.delayAfterFinish;
					// for that eggnog light shut off thingy e.g.

					// JOELwindows7: wait a minute sir. the song name
					// has already removed from playlist bruh!
					// this then starts on Cocoa instead of supposed eggnog!
					// if (StringTools.replace(PlayState.storyPlaylist[0], " ", "-").toLowerCase() == 'eggnog')
					if (lastSonginPlaylist == 'eggnog') // Now this should fix it I guess. Not elegant but it works.
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;

						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}
					outroScene(lastSonginPlaylist);
					// JOELwindows7: Psychedly Successfully fixed the light shut off scene!

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					prevCamFollow = camFollow;

					// JOELwindows7: wait wwiat atiw! remember the epilogue path first before go to the next song!
					var hasEpilogueVideo:Bool = SONG.hasEpilogueVideo;
					var epilogueVideoPath:String = SONG.epilogueVideoPath;
					// Okay you can now change the song.

					// JOELwindows7: wait, double safety standard pls.
					// PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0], diff);
					PlayState.SONG = Song.conversionChecks(Song.loadFromJson(PlayState.storyPlaylist[0], diff));
					// JOELwindows7: fix the song with conversionChecks
					// JOELwindows7: conform the story mode oid based on dash is space like StoryMenuState.hx
					FlxG.sound.music.stop();

					// JOELwindows7: log this one in will ya?
					Debug.logTrace("Here's path for this outro " + epilogueVideoPath + "\n and next song intro " + SONG.videoPath);
					Debug.logInfo("Here's path for this outro " + epilogueVideoPath + "\n and next song intro " + SONG.videoPath);
					Debug.logTrace("and outro is enabled " + Std.string(hasEpilogueVideo) + "and next song intro enabled" + SONG.hasVideo);
					Debug.logInfo("and outro is enabled " + Std.string(hasEpilogueVideo) + "and next song intro enabled" + SONG.hasVideo);

					// JOELwindows7: here timer guys
					new FlxTimer().start(delayFirstBeforeThat, function(tmr:FlxTimer)
					{
						// JOELwindows7: if has video, then load the video first before going to new playstate!
						LoadingState.loadAndSwitchState(hasEpilogueVideo ? (VideoCutscener.getThe(epilogueVideoPath,
							(SONG.hasVideo ? VideoCutscener.getThe(SONG.videoPath,
								new PlayState()) : new PlayState()))) : (SONG.hasVideo ? VideoCutscener.getThe(SONG.videoPath,
								new PlayState()) : new PlayState()));
						// LoadingState.loadAndSwitchState(new PlayState()); //Legacy
						// JOELwindows7: oh God, so complicated. I hope it works!
						clean();
					});
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');

				paused = true;

				FlxG.sound.music.stop();
				vocals.stop();

				if (FlxG.save.data.scoreScreen)
				{
					openSubState(new ResultsScreen());
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						inResults = true;
					});
				}
				else
				{
					FlxG.switchState(new FreeplayState());
					clean();
				}
			}
		}

		// JOELwindows7: stuffening
		touchedSongComplete();
	}

	public var endingSong:Bool = false;

	var hits:Array<Float> = [];
	var offsetTest:Float = 0;

	public function getRatesScore(rate:Float, score:Float):Float
	{
		var rateX:Float = 1;
		var lastScore:Float = score;
		var pr = rate - 0.05;
		if (pr < 1.00)
			pr = 1;

		while (rateX <= pr)
		{
			if (rateX > pr)
				break;
			lastScore = score + ((lastScore * rateX) * 0.022);
			rateX += 0.05;
		}

		var actualScore = Math.round(score + (Math.floor((lastScore * pr)) * 0.022));

		return actualScore;
	}

	var timeShown = 0;
	var currentTimingShown:FlxText = null;

	private function popUpScore(daNote:Note):Void
	{
		var noteDiff:Float;
		if (daNote != null)
			noteDiff = -(daNote.strumTime - Conductor.songPosition);
		else
			noteDiff = Conductor.safeZoneOffset; // Assumed SHIT if no note was given
		var wife:Float = EtternaFunctions.wife3(-noteDiff, Conductor.timeScale);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;
		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		coolText.y -= 350;
		coolText.cameras = [camHUD];
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Float = 350;

		if (FlxG.save.data.accuracyMod == 1)
			totalNotesHit += wife;

		var daRating = Ratings.judgeNote(noteDiff);

		switch (daRating)
		{
			case 'shit':
				// JOELwindows7: add da noteType effex
				if (daNote.noteType == 2)
				{
					health -= 10;
				}
				if (daNote.noteType == 1 || daNote.noteType == 0)
				{
					score = -300;
					combo = 0;
					misses++;
					health -= 0.1;
					ss = false;
					shits++;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit -= 1;
				}
			case 'bad':
				if (daNote.noteType == 2)
				{
					health -= 10;
				}
				if (daNote.noteType == 1 || daNote.noteType == 0)
				{
					daRating = 'bad';
					score = 0;
					health -= 0.06;
					ss = false;
					bads++;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 0.50;
				}
			case 'good':
				if (daNote.noteType == 2)
				{
					health -= 10;
				}
				if (daNote.noteType == 1 || daNote.noteType == 0)
				{
					daRating = 'good';
					score = 200;
					ss = false;
					goods++;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 0.75;
				}
			case 'sick':
				if (daNote.noteType == 2)
				{
					health -= 10;
				}
				if (daNote.noteType == 1 || daNote.noteType == 0)
				{
					if (health < 2)
						health += 0.04;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 1;
					sicks++;
				}
		}

		if (songMultiplier >= 1.05)
			score = getRatesScore(songMultiplier, score);

		// trace('Wife accuracy loss: ' + wife + ' | Rating: ' + daRating + ' | Score: ' + score + ' | Weight: ' + (1 - wife));

		if (daRating != 'shit' || daRating != 'bad')
		{
			songScore += Math.round(score);

			/* if (combo > 60)
					daRating = 'sick';
				else if (combo > 12)
					daRating = 'good'
				else if (combo > 4)
					daRating = 'bad';
			 */

			var pixelShitPart1:String = "";
			var pixelShitPart2:String = '';
			var pixelShitPart3:String = null;

			if (SONG.noteStyle == 'pixel')
			{
				pixelShitPart1 = 'weeb/pixelUI/';
				pixelShitPart2 = '-pixel';
				pixelShitPart3 = 'week6';
			}

			rating.loadGraphic(Paths.loadImage(pixelShitPart1 + daRating + pixelShitPart2, pixelShitPart3));
			rating.screenCenter();
			rating.y -= 50;
			rating.x = coolText.x - 125;

			if (FlxG.save.data.changedHit)
			{
				rating.x = FlxG.save.data.changedHitX;
				rating.y = FlxG.save.data.changedHitY;
			}
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);

			var msTiming = HelperFunctions.truncateFloat(noteDiff / songMultiplier, 3);
			if (PlayStateChangeables.botPlay && !loadRep)
				msTiming = 0;

			if (loadRep)
				msTiming = HelperFunctions.truncateFloat(findByTime(daNote.strumTime)[3], 3);

			if (currentTimingShown != null)
				remove(currentTimingShown);

			currentTimingShown = new FlxText(0, 0, 0, "0ms");
			timeShown = 0;
			switch (daRating)
			{
				case 'shit' | 'bad':
					currentTimingShown.color = FlxColor.RED;
				case 'good':
					currentTimingShown.color = FlxColor.GREEN;
				case 'sick':
					currentTimingShown.color = FlxColor.CYAN;
			}
			currentTimingShown.borderStyle = OUTLINE;
			currentTimingShown.borderSize = 1;
			currentTimingShown.borderColor = FlxColor.BLACK;
			currentTimingShown.text = msTiming + "ms";
			currentTimingShown.size = 20;

			if (msTiming >= 0.03 && offsetTesting)
			{
				// Remove Outliers
				hits.shift();
				hits.shift();
				hits.shift();
				hits.pop();
				hits.pop();
				hits.pop();
				hits.push(msTiming);

				var total = 0.0;

				for (i in hits)
					total += i;

				offsetTest = HelperFunctions.truncateFloat(total / hits.length, 2);
			}

			if (currentTimingShown.alpha != 1)
				currentTimingShown.alpha = 1;

			if (!PlayStateChangeables.botPlay || loadRep)
				add(currentTimingShown);

			var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage(pixelShitPart1 + 'combo' + pixelShitPart2, pixelShitPart3));
			comboSpr.screenCenter();
			comboSpr.x = rating.x;
			comboSpr.y = rating.y + 100;
			comboSpr.acceleration.y = 600;
			comboSpr.velocity.y -= 150;

			currentTimingShown.screenCenter();
			currentTimingShown.x = comboSpr.x + 100;
			currentTimingShown.y = rating.y + 100;
			currentTimingShown.acceleration.y = 600;
			currentTimingShown.velocity.y -= 150;

			comboSpr.velocity.x += FlxG.random.int(1, 10);
			currentTimingShown.velocity.x += comboSpr.velocity.x;
			if (!PlayStateChangeables.botPlay || loadRep)
				add(rating);

			if (SONG.noteStyle != 'pixel')
			{
				rating.setGraphicSize(Std.int(rating.width * 0.7));
				rating.antialiasing = FlxG.save.data.antialiasing;
				comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
				comboSpr.antialiasing = FlxG.save.data.antialiasing;
			}
			else
			{
				rating.setGraphicSize(Std.int(rating.width * CoolUtil.daPixelZoom * 0.7));
				comboSpr.setGraphicSize(Std.int(comboSpr.width * CoolUtil.daPixelZoom * 0.7));
			}

			currentTimingShown.updateHitbox();
			comboSpr.updateHitbox();
			rating.updateHitbox();

			currentTimingShown.cameras = [camHUD];
			comboSpr.cameras = [camHUD];
			rating.cameras = [camHUD];

			var seperatedScore:Array<Int> = [];

			var comboSplit:Array<String> = (combo + "").split('');

			if (combo > highestCombo)
				highestCombo = combo;

			// make sure we have 3 digits to display (looks weird otherwise lol)
			if (comboSplit.length == 1)
			{
				seperatedScore.push(0);
				seperatedScore.push(0);
			}
			else if (comboSplit.length == 2)
				seperatedScore.push(0);

			for (i in 0...comboSplit.length)
			{
				var str:String = comboSplit[i];
				seperatedScore.push(Std.parseInt(str));
			}

			var daLoop:Int = 0;
			for (i in seperatedScore)
			{
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2, pixelShitPart3));
				numScore.screenCenter();
				numScore.x = rating.x + (43 * daLoop) - 50;
				numScore.y = rating.y + 100;
				numScore.cameras = [camHUD];

				if (SONG.noteStyle != 'pixel')
				{
					numScore.antialiasing = FlxG.save.data.antialiasing;
					numScore.setGraphicSize(Std.int(numScore.width * 0.5));
				}
				else
				{
					numScore.setGraphicSize(Std.int(numScore.width * CoolUtil.daPixelZoom));
				}
				numScore.updateHitbox();

				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);

				add(numScore);

				visibleCombos.push(numScore);

				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						visibleCombos.remove(numScore);
						numScore.destroy();
					},
					onUpdate: function(tween:FlxTween)
					{
						if (!visibleCombos.contains(numScore))
						{
							tween.cancel();
							numScore.destroy();
						}
					},
					startDelay: Conductor.crochet * 0.002
				});

				if (visibleCombos.length > seperatedScore.length + 20)
				{
					for (i in 0...seperatedScore.length - 1)
					{
						visibleCombos.remove(visibleCombos[visibleCombos.length - 1]);
					}
				}

				daLoop++;
			}
			/* 
				trace(combo);
				trace(seperatedScore);
			 */

			coolText.text = Std.string(seperatedScore);
			// add(coolText);

			FlxTween.tween(rating, {alpha: 0}, 0.2, {
				startDelay: Conductor.crochet * 0.001,
				onUpdate: function(tween:FlxTween)
				{
					if (currentTimingShown != null)
						currentTimingShown.alpha -= 0.02;
					timeShown++;
				}
			});

			FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					coolText.destroy();
					comboSpr.destroy();
					if (currentTimingShown != null && timeShown >= 20)
					{
						remove(currentTimingShown);
						currentTimingShown = null;
					}
					rating.destroy();
				},
				startDelay: Conductor.crochet * 0.001
			});

			curSection += 1;
		}
	}

	public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool
	{
		return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;
	}

	var upHold:Bool = false;
	var downHold:Bool = false;
	var rightHold:Bool = false;
	var leftHold:Bool = false;

	// THIS FUNCTION JUST FUCKS WIT HELD NOTES AND BOTPLAY/REPLAY (also gamepad shit)

	private function keyShit():Void // I've invested in emma stocks
	{
		// control arrays, order L D R U
		var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		var pressArray:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];
		var releaseArray:Array<Bool> = [controls.LEFT_R, controls.DOWN_R, controls.UP_R, controls.RIGHT_R];
		var keynameArray:Array<String> = ['left', 'down', 'up', 'right'];
		#if FEATURE_LUAMODCHART
		if (luaModchart != null)
		{
			for (i in 0...pressArray.length)
			{
				if (pressArray[i] == true)
				{
					luaModchart.executeState('keyPressed', [keynameArray[i]]);
				}
			};

			for (i in 0...releaseArray.length)
			{
				if (releaseArray[i] == true)
				{
					luaModchart.executeState('keyReleased', [keynameArray[i]]);
				}
			};
		};

		// JOELwindows7: stage script keypressings
		if (stageScript != null)
		{
			for (i in 0...pressArray.length)
			{
				if (pressArray[i] == true)
				{
					stageScript.executeState('keyPressed', [keynameArray[i]]);
				}
			};

			for (i in 0...releaseArray.length)
			{
				if (releaseArray[i] == true)
				{
					stageScript.executeState('keyReleased', [keynameArray[i]]);
				}
			};

			// if (FlxG.keys.pressed){stageScript.executeState('rawKeyPressed',[Std.string(FlxG.keys.pressed)]);};
		};
		#end
		// JOELwindows7: lotsa hscript
		if (hscriptModchart != null)
		{
			for (i in 0...pressArray.length)
			{
				if (pressArray[i] == true)
				{
					hscriptModchart.executeState('keyPressed', [keynameArray[i]]);
				}
			};

			for (i in 0...releaseArray.length)
			{
				if (releaseArray[i] == true)
				{
					hscriptModchart.executeState('keyReleased', [keynameArray[i]]);
				}
			};

			// JOELwindows7: any keypresings here
			// if (FlxG.keys.pressed){hscriptModChart.executeState('rawKeyPressed',[Std.string(FlxG.keys.pressed)]);};
		};
		// JOELwindows7: stage script keypressings
		if (stageHscript != null)
		{
			for (i in 0...pressArray.length)
			{
				if (pressArray[i] == true)
				{
					stageHscript.executeState('keyPressed', [keynameArray[i]]);
				}
			};

			for (i in 0...releaseArray.length)
			{
				if (releaseArray[i] == true)
				{
					stageHscript.executeState('keyReleased', [keynameArray[i]]);
				}
			};

			// if (FlxG.keys.pressed){stageHscript.executeState('rawKeyPressed',[Std.string(FlxG.keys.pressed)]);};
		};

		// Prevent player input if botplay is on
		if (PlayStateChangeables.botPlay)
		{
			holdArray = [false, false, false, false];
			pressArray = [false, false, false, false];
			releaseArray = [false, false, false, false];
		}

		var anas:Array<Ana> = [null, null, null, null];

		for (i in 0...pressArray.length)
			if (pressArray[i])
				anas[i] = new Ana(Conductor.songPosition, null, false, "miss", i);

		// HOLDS, check for sustain notes
		if (holdArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData] && daNote.sustainActive)
				{
					// trace(daNote.sustainActive);
					goodNoteHit(daNote);
				}
			});
		}

		if ((KeyBinds.gamepad && !FlxG.keys.justPressed.ANY))
		{
			// PRESSES, check for note hits
			if (pressArray.contains(true) && generatedMusic)
			{
				boyfriend.holdTimer = 0;

				var possibleNotes:Array<Note> = []; // notes that can be hit
				var directionList:Array<Int> = []; // directions that can be hit
				var dumbNotes:Array<Note> = []; // notes to kill later
				var directionsAccounted:Array<Bool> = [false, false, false, false]; // we don't want to do judgments for more than one presses

				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.wasGoodHit && !directionsAccounted[daNote.noteData])
					{
						if (directionList.contains(daNote.noteData))
						{
							directionsAccounted[daNote.noteData] = true;
							for (coolNote in possibleNotes)
							{
								if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
								{ // if it's the same note twice at < 10ms distance, just delete it
									// EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
									dumbNotes.push(daNote);
									break;
								}
								else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
								{ // if daNote is earlier than existing note (coolNote), replace
									possibleNotes.remove(coolNote);
									possibleNotes.push(daNote);
									break;
								}
							}
						}
						else
						{
							directionsAccounted[daNote.noteData] = true;
							possibleNotes.push(daNote);
							directionList.push(daNote.noteData);
						}
					}
				});

				for (note in dumbNotes)
				{
					FlxG.log.add("killing dumb ass note at " + note.strumTime);
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}

				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				var hit = [false, false, false, false];

				if (perfectMode)
					goodNoteHit(possibleNotes[0]);
				else if (possibleNotes.length > 0)
				{
					if (!FlxG.save.data.ghost)
					{
						for (shit in 0...pressArray.length)
						{ // if a direction is hit that shouldn't be
							if (pressArray[shit] && !directionList.contains(shit))
								noteMiss(shit, null);
						}
					}
					for (coolNote in possibleNotes)
					{
						if (pressArray[coolNote.noteData] && !hit[coolNote.noteData])
						{
							if (mashViolations != 0)
								mashViolations--;
							hit[coolNote.noteData] = true;
							scoreTxt.color = FlxColor.WHITE;
							var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
							anas[coolNote.noteData].hit = true;
							anas[coolNote.noteData].hitJudge = Ratings.judgeNote(noteDiff);
							anas[coolNote.noteData].nearestNote = [coolNote.strumTime, coolNote.noteData, coolNote.sustainLength];
							goodNoteHit(coolNote);
						}
					}
				};

				if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay))
				{
					if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
						boyfriend.dance();
				}
				else if (!FlxG.save.data.ghost)
				{
					for (shit in 0...pressArray.length)
						if (pressArray[shit])
							noteMiss(shit, null);
				}
			}

			if (!loadRep)
				for (i in anas)
					if (i != null)
						replayAna.anaArray.push(i); // put em all there
		}
		if (PlayStateChangeables.botPlay)
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.mustPress && Conductor.songPosition >= daNote.strumTime)
				{
					// Force good note hit regardless if it's too late to hit it or not as a fail safe
					if (loadRep)
					{
						// trace('ReplayNote ' + tmpRepNote.strumtime + ' | ' + tmpRepNote.direction);
						var n = findByTime(daNote.strumTime);
						trace(n);
						if (n != null)
						{
							goodNoteHit(daNote);
							boyfriend.holdTimer = 0;
						}
					}
					else
					{
						goodNoteHit(daNote);
						boyfriend.holdTimer = 0;
					}
				}
			});

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay))
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing')
				&& !boyfriend.animation.curAnim.name.endsWith('miss')
				&& (boyfriend.animation.curAnim.curFrame >= 10 || boyfriend.animation.curAnim.finished))
				boyfriend.dance();
		}

		playerStrums.forEach(function(spr:StaticArrow)
		{
			if (!PlayStateChangeables.botPlay)
			{
				if (keys[spr.ID]
					&& spr.animation.curAnim.name != 'confirm'
					&& spr.animation.curAnim.name != 'pressed'
					&& !spr.animation.curAnim.name.startsWith('dirCon'))
					spr.playAnim('pressed', false);
				if (!keys[spr.ID])
					spr.playAnim('static', false);
			}
			else if (FlxG.save.data.cpuStrums)
			{
				if (spr.animation.finished)
					spr.playAnim('static');
			}
		});
	}

	public function findByTime(time:Float):Array<Dynamic>
	{
		for (i in rep.replay.songNotes)
		{
			// trace('checking ' + Math.round(i[0]) + ' against ' + Math.round(time));
			if (i[0] == time)
				return i;
		}
		return null;
	}

	public function findByTimeIndex(time:Float):Int
	{
		for (i in 0...rep.replay.songNotes.length)
		{
			// trace('checking ' + Math.round(i[0]) + ' against ' + Math.round(time));
			if (rep.replay.songNotes[i][0] == time)
				return i;
		}
		return -1;
	}

	public var fuckingVolume:Float = 1;
	public var useVideo = false;

	public static var webmHandler:WebmHandler;

	public var playingDathing = false;

	public var videoSprite:FlxSprite;

	public function backgroundVideo(source:String) // for background videos
	{
		#if FEATURE_WEBM
		useVideo = true;

		var ourSource:String = "assets/videos/daWeirdVid/dontDelete.webm";
		// #if (!mobile)
		// WebmPlayer.SKIP_STEP_LIMIT = 90;
		// GlobalVideo.getWebm().webm.SKIP_STEP_LIMIT = 90; //JOELwindows7: for original gwebdev
		// #end
		// WebmPlayer.SKIP_STEP_LIMIT = 90;
		var str1:String = "WEBM SHIT";
		webmHandler = new WebmHandler();
		webmHandler.source(ourSource);
		webmHandler.makePlayer();
		webmHandler.webm.name = str1;

		GlobalVideo.setWebm(webmHandler);

		GlobalVideo.get().source(source);
		GlobalVideo.get().clearPause();
		if (GlobalVideo.isWebm)
		{
			GlobalVideo.get().updatePlayer();
		}
		GlobalVideo.get().show();

		if (GlobalVideo.isWebm)
		{
			GlobalVideo.get().restart();
		}
		else
		{
			GlobalVideo.get().play();
		}

		var data = webmHandler.webm.bitmapData;

		videoSprite = new FlxSprite(-470, -30).loadGraphic(data);

		videoSprite.setGraphicSize(Std.int(videoSprite.width * 1.2));

		remove(gf);
		remove(boyfriend);
		remove(dad);
		add(videoSprite);
		add(gf);
		add(boyfriend);
		add(dad);

		trace('poggers');

		if (!songStarted)
			webmHandler.pause();
		else
			webmHandler.resume();
		#end
	}

	function noteMiss(direction:Int = 1, daNote:Note):Void
	{
		if (!boyfriend.stunned)
		{
			// health -= 0.2;
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				// JOELwindows7: add girlfriend oop & aah for combo break,
				// Just like osu!
				if (FlxG.save.data.missSounds)
					FlxG.sound.play(Paths.soundRandom('GF_', 1, 2), 0.5);
				trace("Yah, sayang banget padahal kan udah " + Std.string(combo) + " kombo tadi :\'( ");

				gf.playAnim('sad');
			}
			if (combo != 0)
			{
				combo = 0;
				popUpScore(null);
			}
			misses++;

			if (daNote != null)
			{
				if (!loadRep)
				{
					saveNotes.push([
						daNote.strumTime,
						0,
						direction,
						-(166 * Math.floor((PlayState.rep.replay.sf / 60) * 1000) / 166)
					]);
					saveJudge.push("miss");
				}
			}
			else if (!loadRep)
			{
				saveNotes.push([
					Conductor.songPosition,
					0,
					direction,
					-(166 * Math.floor((PlayState.rep.replay.sf / 60) * 1000) / 166)
				]);
				saveJudge.push("miss");
			}

			// var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition);
			// var wife:Float = EtternaFunctions.wife3(noteDiff, FlxG.save.data.etternaMode ? 1 : 1.7);

			totalNotesHit -= 1;

			if (daNote != null)
			{
				if (!daNote.isSustainNote)
					songScore -= 10;
			}
			else
				songScore -= 10;

			if (FlxG.save.data.missSounds)
			{
				// JOELwindows7: now the numbers of miss note sfx depends on the file yay!
				FlxG.sound.play(Paths.soundRandom('missnote' + altSuffix, 1, numOfMissNoteSfx), FlxG.random.float(0.1, 0.2));
				// FlxG.sound.play(Paths.soundRandom('missnote' + altSuffix, 1, 3), FlxG.random.float(0.1, 0.2));
				// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
				// FlxG.log.add('played imss note');
			}

			// JOELwindows7: vibrate the miss
			Controls.vibrate(0, 50);

			// Hole switch statement replaced with a single line :)
			boyfriend.playAnim('sing' + dataSuffix[direction] + 'miss', true);

			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
				luaModchart.executeState('playerOneMiss', [direction, Conductor.songPosition]);
			if (stageScript != null)
				stageScript.executeState('playerOneMiss', [direction, Conductor.songPosition]);
			#end
			if (hscriptModchart != null)
				hscriptModchart.executeState('playerOneMiss', [direction, Conductor.songPosition]);
			if (stageHscript != null)
				stageHscript.executeState('playerOneMiss', [direction, Conductor.songPosition]);

			updateAccuracy();
		}
	}

	/*function badNoteCheck()
		{
			// just double pasting this shit cuz fuk u
			// REDO THIS SYSTEM!
			var upP = controls.UP_P;
			var rightP = controls.RIGHT_P;
			var downP = controls.DOWN_P;
			var leftP = controls.LEFT_P;

			if (leftP)
				noteMiss(0);
			if (upP)
				noteMiss(2);
			if (rightP)
				noteMiss(3);
			if (downP)
				noteMiss(1);
			updateAccuracy();
		}
	 */
	function updateAccuracy()
	{
		totalPlayed += 1;
		accuracy = Math.max(0, totalNotesHit / totalPlayed * 100);
		accuracyDefault = Math.max(0, totalNotesHitDefault / totalPlayed * 100);

		// JOELwindows7: here's where we moved. the bottom score text
		scoreTxt.text = Ratings.CalculateRanking(songScore, songScoreDef, nps, maxNPS, accuracy, heartRate[0], heartTierIsRightNow[0]);
		judgementCounter.text = 'Sicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\nMisses: ${misses}';
	}

	function getKeyPresses(note:Note):Int
	{
		var possibleNotes:Array<Note> = []; // copypasted but you already know that

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress)
			{
				possibleNotes.push(daNote);
				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
			}
		});
		if (possibleNotes.length == 1)
			return possibleNotes.length + 1;
		return possibleNotes.length;
	}

	var mashing:Int = 0;
	var mashViolations:Int = 0;

	var etternaModeScore:Int = 0;

	function noteCheck(controlArray:Array<Bool>, note:Note):Void // sorry lol
	{
		var noteDiff:Float = -(note.strumTime - Conductor.songPosition);

		note.rating = Ratings.judgeNote(noteDiff);

		/* if (loadRep)
			{
				if (controlArray[note.noteData])
					goodNoteHit(note, false);
				else if (rep.replay.keyPresses.length > repPresses && !controlArray[note.noteData])
				{
					if (NearlyEquals(note.strumTime,rep.replay.keyPresses[repPresses].time, 4))
					{
						goodNoteHit(note, false);
					}
				}
		}*/

		if (controlArray[note.noteData])
		{
			goodNoteHit(note, (mashing > getKeyPresses(note)));

			/*if (mashing > getKeyPresses(note) && mashViolations <= 2)
				{
					mashViolations++;

					goodNoteHit(note, (mashing > getKeyPresses(note)));
				}
				else if (mashViolations > 2)
				{
					// this is bad but fuck you
					playerStrums.members[0].animation.play('static');
					playerStrums.members[1].animation.play('static');
					playerStrums.members[2].animation.play('static');
					playerStrums.members[3].animation.play('static');
					health -= 0.4;
					trace('mash ' + mashing);
					if (mashing != 0)
						mashing = 0;
				}
				else
					goodNoteHit(note, false); */
		}
	}

	function goodNoteHit(note:Note, resetMashViolation = true):Void
	{
		if (mashing != 0)
			mashing = 0;

		var noteDiff:Float = -(note.strumTime - Conductor.songPosition);

		if (loadRep)
		{
			noteDiff = findByTime(note.strumTime)[3];
			note.rating = rep.replay.songJudgements[findByTimeIndex(note.strumTime)];
		}
		else
			note.rating = Ratings.judgeNote(noteDiff);

		if (note.rating == "miss")
			return;

		// add newest note to front of notesHitArray
		// the oldest notes are at the end and are removed first
		if (!note.isSustainNote)
			notesHitArray.unshift(Date.now());

		if (!resetMashViolation && mashViolations >= 1)
			mashViolations--;

		if (mashViolations < 0)
			mashViolations = 0;

		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				combo += 1;
				popUpScore(note);
			}

			var altAnim:String = "";
			if (note.isAlt)
			{
				altAnim = '-alt';
				trace("Alt note on BF");
			}

			boyfriend.playAnim('sing' + dataSuffix[note.noteData] + altAnim, true);

			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
				luaModchart.executeState('playerOneSing', [note.noteData, Conductor.songPosition]);
			if (stageScript != null)
				stageScript.executeState('playerOneSing', [note.noteData, Conductor.songPosition]);
			#end
			if (hscriptModchart != null)
				hscriptModchart.executeState('playerOneSing', [note.noteData, Conductor.songPosition]);
			if (stageHscript != null)
				stageHscript.executeState('playerOneSing', [note.noteData, Conductor.songPosition]);

			if (!loadRep && note.mustPress)
			{
				var array = [note.strumTime, note.sustainLength, note.noteData, noteDiff];
				if (note.isSustainNote)
					array[1] = -1;
				saveNotes.push(array);
				saveJudge.push(note.rating);
			}

			if (!PlayStateChangeables.botPlay || FlxG.save.data.cpuStrums)
			{
				playerStrums.forEach(function(spr:StaticArrow)
				{
					pressArrow(spr, spr.ID, note);
				});
			}

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();

				// JOELwindows7: successfully step, add adrenaline heartbeat fass
				successfullyStep();
			}
			else
			{
				note.wasGoodHit = true;
			}
			if (!note.isSustainNote)
				updateAccuracy();
		}
	}

	function pressArrow(spr:StaticArrow, idCheck:Int, daNote:Note)
	{
		if (Math.abs(daNote.noteData) == idCheck)
		{
			if (!FlxG.save.data.stepMania)
			{
				spr.playAnim('confirm', true);
			}
			else
			{
				spr.playAnim('dirCon' + daNote.originColor, true);
				spr.localAngle = daNote.originAngle;
			}
		}
	}

	// JOELwindows7: fast car, lightning gludug, & train moved to Stage.hx
	var danced:Bool = false;

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.rawPosition + 20 || FlxG.sound.music.time < Conductor.rawPosition - 20)
		{
			resyncVocals();
		}

		#if FEATURE_LUAMODCHART
		if (executeModchart && luaModchart != null)
		{
			luaModchart.setVar('curStep', curStep);
			luaModchart.executeState('stepHit', [curStep]);
		}
		if (executeStageScript && stageScript != null)
		{
			stageScript.setVar('curStep', curStep);
			stageScript.executeState('stepHit', [curStep]);
		}
		#end
		if (executeModHscript && hscriptModchart != null)
		{
			hscriptModchart.setVar('curStep', curStep);
			hscriptModchart.executeState('stepHit', [curStep]);
		}
		if (executeStageHscript && stageHscript != null)
		{
			stageHscript.setVar('curStep', curStep);
			stageHscript.executeState('stepHit', [curStep]);
		}
	}

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, (PlayStateChangeables.useDownscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));
		}

		#if FEATURE_LUAMODCHART
		if (executeModchart && luaModchart != null)
		{
			luaModchart.executeState('beatHit', [curBeat]);
		}
		if (executeStageScript && stageScript != null)
		{
			// stageScript.setVar('curBeat',curBeat);
			stageScript.executeState('beatHit', [curBeat]);
		}
		#end
		// JOELwindows7: hscriptoid
		if (executeModHscript && hscriptModchart != null)
		{
			// hscriptModchart.setVar('curBeat',curBeat);
			hscriptModchart.executeState('beatHit', [curBeat]);
		}
		if (executeStageHscript && stageHscript != null)
		{
			// stageHscript.setVar('curBeat',curBeat);
			stageHscript.executeState('beatHit', [curBeat]);
		}

		if (currentSection != null)
		{
			if (curBeat % idleBeat == 0)
			{
				if (idleToBeat && !dad.animation.curAnim.name.startsWith('sing'))
					dad.dance(forcedToIdle, currentSection.CPUAltAnim);
				if (idleToBeat && !boyfriend.animation.curAnim.name.startsWith('sing'))
					boyfriend.dance(forcedToIdle, currentSection.playerAltAnim);
			}
			else if ((dad.curCharacter == 'spooky' || dad.curCharacter == 'gf') && !dad.animation.curAnim.name.startsWith('sing'))
				dad.dance(forcedToIdle, currentSection.CPUAltAnim);
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		if (FlxG.save.data.camzoom && songMultiplier == 1)
		{
			// HARDCODING FOR MILF ZOOMS!
			if (PlayState.SONG.songId == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
			{
				FlxG.camera.zoom += 0.015 / songMultiplier;
				camHUD.zoom += 0.03 / songMultiplier;

				// JOELwindows7: add vibrations!
				Controls.vibrate(0, 150);
			}

			// JOELwindows7: HARDCODING FOR WE'LL MEET YOU AGAIN ZOOMS!
			if (curSong.toLowerCase() == 'well-meet-again'
				&& FlxG.camera.zoom < 1.35
				&& curBeat % 4 == 2
				&& curBeat < 307
				&& !inCutscene)
			{
				// the song is we'll meet again, camera not yet zoomed, when strum is in middle of bar, less than song length, not during cutscene
				// Reminder: CurBeat = CurStep / 4

				if ((curBeat < 52)
					|| (curBeat > 80 && curBeat < 148)
					|| (curBeat > 176 && curBeat < 212)
					|| // shutup, just coincidence. I know, so don't talk it.
					// Oh Wiro Sableng, Oh ok, I thought. Sorry.
					(curBeat > 224 && curBeat < 240)
					|| (curBeat > 256 && curBeat < 304) // lmao! 1024 curStep = 256 curBeat
				)
					camZoomNow();
			}

			if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0 && !inCutscene && !inResults)
			{
				FlxG.camera.zoom += 0.015 / songMultiplier;
				camHUD.zoom += 0.03 / songMultiplier;
			}
		}
		if (songMultiplier == 1)
		{
			iconP1.setGraphicSize(Std.int(iconP1.width + 30));
			iconP2.setGraphicSize(Std.int(iconP2.width + 30));

			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}
		else
		{
			iconP1.setGraphicSize(Std.int(iconP1.width + 4));
			iconP2.setGraphicSize(Std.int(iconP2.width + 4));

			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}

		if (!endingSong && currentSection != null)
		{
			if (allowedToHeadbang)
			{
				gf.dance();
			}

			if (curBeat % 8 == 7 && curSong == 'bopeebo')
			{
				boyfriend.playAnim('hey', true);
			}

			// JOELwindows7: temporary degradation fix
			if (curSong == 'getting-freaky')
			{
				if (curBeat == 7 || curBeat == 23 || curBeat == 39 || curBeat == 55 || curBeat == 71 || curBeat == 87 || curBeat == 103 || curBeat == 119
					|| curBeat == 135 || curBeat == 151 || curBeat == 167 || curBeat == 183)
				{
					// if(!triggeredAlready){
					// 	trace("ayy!");
					// 	justCheer(true);
					// 	justHey(true);
					// 	triggeredAlready = true;
					// }
					justCheer(true);
					justHey(true);
					// C'mon work wtf
					boyfriend.playAnim('hey', true);
					gf.playAnim('cheer', true);
				} /*else triggeredAlready = false;*/
			}

			// JOELwindows7: found pay attention to this if player 2 is gf.
			if (curBeat % 16 == 15
				&& SONG.songId == 'tutorial'
				&& (dad.curCharacter == 'gf' || dad.curCharacter == 'gf-ht')
				&& curBeat > 16
				&& curBeat < 48)
			{
				if (vocals.volume != 0)
				{
					boyfriend.playAnim('hey', true);
					dad.playAnim('cheer', true);
				}
				else
				{
					dad.playAnim('sad', true);
					FlxG.sound.play(Paths.soundRandom('GF_', 1, 4, 'shared'), 0.3);
				}
				// JOELwindows7: hey, you got gf sadd hik hiks too?! whoahow! based, giant w, pogger!
			}

			if (PlayStateChangeables.Optimize)
				if (vocals.volume == 0 && !currentSection.mustHitSection)
					vocals.volume = 1;

			// JOELwindows7: above is not my code. but idea!
			// for Gravis Ultrasound demo, RAIN.MID. you can manually lightning strike as the beat almost drop.
			// wait, where's lightning strike? oh! it's moved to Stage.hx
		}
	}

	public var cleanedSong:SongData;

	function poggers(?cleanTheSong = false)
	{
		var notes = [];

		if (cleanTheSong)
		{
			cleanedSong = SONG;

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

			SONG = cleanedSong;
		}
		else
		{
			for (section in SONG.notes)
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

			for (section in SONG.notes)
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

			SONG = cleanedSong;
		}
	}

	// var curLight:Int = 0; //JOELwindows7: RIP, curLight variable. maybe moved to Stage.hx
	// JOELwindows7: not my code. hey, Ninja! you should've white light like I do above
	// and randomize the color. look at randomizeColoring() above!
	// JOELwindows7: make cam zoom a function pls
	public function camZoomNow(howMuchZoom:Float = .015, howMuchZoomHUD:Float = .03, maxZoom:Float = 1.35)
	{
		if (FlxG.camera.zoom < maxZoom)
		{
			FlxG.camera.zoom += howMuchZoom;
			camHUD.zoom += howMuchZoomHUD;
		}
	}

	// JOELwindows7: make cheer a function
	public function cheerNow(outOfBeatFractioning:Int = 4, doItOn:Int = 0, randomizeColor:Bool = false, justOne:Bool = false, toWhichBg:Int = 0,
			forceIt:Bool = false)
	{
		if (curBeat % outOfBeatFractioning == doItOn)
		{
			if (!triggeredAlready)
			{
				if (randomizeColor)
					Stage.randomizeColoring(justOne, toWhichBg);
				gf.playAnim('cheer', forceIt);
				triggeredAlready = true;
			}
		}
		else
			triggeredAlready = false;
	}

	public function heyNow(outOfBeatFractioning:Int = 4, doItOn:Int = 0, randomizeColor:Bool = false, justOne:Bool = false, toWhichBg:Int = 0,
			forceIt:Bool = false)
	{
		if (curBeat % outOfBeatFractioning == doItOn)
		{
			if (!triggeredAlready)
			{
				if (randomizeColor)
					Stage.randomizeColoring(justOne, toWhichBg);
				boyfriend.playAnim('hey', forceIt);
				triggeredAlready = true;
			}
		}
		else
			triggeredAlready = false;
	}

	// JOELwindows7: just cheer & hey
	var isCheering:Bool = false; // flag to prevent other animation playings before it done

	public function justCheer(forceIt:Bool = false)
	{
		isCheering = true;
		trace("Cheer");
		gf.animation.finishCallback = function(name:String)
		{
			if (name == 'cheer')
			{
				isCheering = false;
				trace("Cheer finish");
			}
		};
		gf.playAnim('cheer', forceIt);
		// gf.playAnim('cheer', forceIt);
		// gf.playAnim('cheer', forceIt);
		trace("did this even Cheer?");
	}

	var isHeying:Bool = false; // flag to prevent other animation playings before it done

	public function justHey(forceIt:Bool = false)
	{
		isHeying = true;
		trace("Hey");
		boyfriend.animation.finishCallback = function(name:String)
		{
			if (name == 'hey')
			{
				isHeying = false;
				trace("Hey finish");
			}
		}
		boyfriend.playAnim('hey', forceIt);
		// boyfriend.playAnim('hey', forceIt);
		// boyfriend.playAnim('hey', forceIt);
		// JOELwindows7: pecking force 3 times because it always been overwritten by dance
		trace("did this even Hey?");
	}

	// JOELwindows7: manage heartbeat moments
	function startHeartBeat()
	{
		DokiDoki.buildHeartsList();
		// HEARTS = DokiDoki.loadFromJson("heartBeatSpec");
		// var chooseIndex = 0;
		// switch(SONG.player1){
		// 	case 'bf': chooseIndex = 0;
		// 	case 'gf': chooseIndex = 1;
		// 	default: chooseIndex = 0;
		// }

		// HEART = HEARTS.heartSpecs[chooseIndex];
		if (HEART == null)
		{
			HEART = new Array<SwagHeart>();
		}
		try
		{
			HEART[0] = DokiDoki.hearts.get(SONG.player1);
			trace(SONG.player1 + " heart\n" + Std.string(HEART[0]));
			if (HEART[0] == null)
				HEART[0] = DokiDoki.hearts.get('bf');
		}
		catch (e)
		{
			trace(SONG.player1 + " heart error " + e);
			trace("attempting rescue");
			HEART[0] = DokiDoki.hearts.get('bf');
		}
		try
		{
			HEART[1] = DokiDoki.hearts.get(SONG.player2);
			trace(SONG.player2 + " heart\n" + Std.string(HEART[1]));
			if (HEART[1] == null)
				HEART[1] = DokiDoki.hearts.get('dad');
		}
		catch (e)
		{
			trace(SONG.player2 + " heart error " + e);
			trace("attempting rescue");
			HEART[1] = DokiDoki.hearts.get('dad');
		}
		try
		{
			HEART[2] = DokiDoki.hearts.get(SONG.gfVersion);
			trace(SONG.gfVersion + " heart\n" + Std.string(HEART[2]));
			if (HEART[2] == null)
				HEART[2] = DokiDoki.hearts.get('gf');
		}
		catch (e)
		{
			trace(SONG.gfVersion + " heart error " + e);
			trace("attempting rescue");
			HEART[2] = DokiDoki.hearts.get('gf');
		}
		for (i in 0...HEART.length)
		{
			heartTierIsRightNow[i] = 0;
			heartRate[i] = HEART[i].initHR;
			minHR[i] = HEART[i].minHR;
			maxHR[i] = HEART[i].maxHR;
			successionAdrenalAdd[i] = HEART[i].successionAdrenalAdd;
			fearShockAdd[i] = HEART[i].fearShockAdd;
			relaxMinusPerBeat[i] = HEART[i].relaxMinusPerBeat;
			heartTierBoundaries[i] = HEART[i].heartTierBoundaries;
			slowedAlready[i] = false;
		}
	}

	function updateHeartbeat()
	{
		// update the tier status
		for (i in 0...HEART.length)
		{
			if (heartRate[i] > heartTierBoundaries[i][heartTierIsRightNow[i]])
			{
			}

			if (curBeat % 4 == 0)
			{
				// Relax heartbeat
				if (!slowedAlready[i])
				{
					increaseHR(-relaxMinusPerBeat[i][heartTierIsRightNow[i]], i);
					slowedAlready[i] = true;
				}
			}
			else
				slowedAlready[i] = false;
		}
	}

	function successfullyStep(whichOne:Int = 0)
	{
		increaseHR(successionAdrenalAdd[whichOne][heartTierIsRightNow[whichOne]], whichOne);
	}

	function checkWhichHeartTierWent(giveHB:Int, whichOne:Int = 0)
	{
		// if(giveHB > heartTierBoundaries[whichOne][heartTierIsRightNow[whichOne]] && giveHB < heartTierBoundaries[whichOne][heartTierIsRightNow[whichOne]+1]){
		// 	heartTierIsRightNow++;
		// } else if (giveHB > heartTierBoundaries[whichOne][heartTierIsRightNow[whichOne]+1]){

		// }

		// Hard code bcause logic brainstorm is haarde
		if (giveHB < heartTierBoundaries[whichOne][0])
			heartTierIsRightNow[whichOne] = 0;
		else if (giveHB >= heartTierBoundaries[whichOne][0] && giveHB < heartTierBoundaries[whichOne][1])
			heartTierIsRightNow[whichOne] = 1;
		else if (giveHB >= heartTierBoundaries[whichOne][1] && giveHB < heartTierBoundaries[whichOne][2])
			heartTierIsRightNow[whichOne] = 2;
		else if (giveHB >= heartTierBoundaries[whichOne][2] && giveHB < heartTierBoundaries[whichOne][3])
			heartTierIsRightNow[whichOne] = 3;
		else if (giveHB >= heartTierBoundaries[whichOne][3])
		{
			// uhhh, idk..
		}
	}

	public function increaseHR(forHowMuch:Int = 0, whichOne:Int = 0)
	{
		heartRate[whichOne] += forHowMuch;

		if (heartRate[whichOne] > maxHR[whichOne])
		{
			heartRate[whichOne] = maxHR[whichOne];
		}
		if (heartRate[whichOne] < minHR[whichOne])
		{
			heartRate[whichOne] = minHR[whichOne];
		}

		// update the tier status
		checkWhichHeartTierWent(heartRate[whichOne], whichOne);
	}

	// JOELwindows7: fake countdowns! also countups too!
	public function startFakeCountdown(silent:Bool = false, invisible:Bool = false, reversed:Bool = false)
	{
		// JOELwindows7: install songLowercaser and its heurestic for specific songs bellow
		// pre lowercasing the song name (create)
		// var songLowercase = StringTools.replace(PlayState.SONG.songId, " ", "-").toLowerCase();
		// switch (songLowercase)
		// {
		// 	case 'dad-battle':
		// 		songLowercase = 'dadbattle';
		// 	case 'philly-nice':
		// 		songLowercase = 'philly';
		// }

		startedFakeCounting = true;

		var swagCounter:Int = 0;

		fakeTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
			introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";
			// JOELwindows7: detect MIDI suffix
			var detectMidiSuffix:String = '-midi';
			var midiSuffix:String = "midi";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			// JOELwindows7: scan MIDI suffix in the song name
			if (PlayState.SONG.songId.contains(detectMidiSuffix.trim()))
			{
				midiSuffix = detectMidiSuffix;
			}
			else
				midiSuffix = "";

			switch (swagCounter)
			{
				case 0:
					if (!silent)
						FlxG.sound.play(Paths.sound(reversed ? 'intro1' : 'intro3' + altSuffix + midiSuffix), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * CoolUtil.daPixelZoom));

					ready.screenCenter();
					add(ready);
					if (invisible)
						ready.visible = false;
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					if (!silent)
						FlxG.sound.play(Paths.sound('intro2' + altSuffix + midiSuffix), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * CoolUtil.daPixelZoom));

					set.screenCenter();
					add(set);
					if (invisible)
						set.visible = false;
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					if (!silent)
						FlxG.sound.play(Paths.sound(reversed ? 'intro3' : 'intro1' + altSuffix + midiSuffix), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * CoolUtil.daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					if (invisible)
						go.visible = false;
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					if (!silent)
						FlxG.sound.play(Paths.sound('introGo' + altSuffix + midiSuffix), 0.6);
				case 4:
					// JOELwindows7: just add trace for fun
					trace("fake count down finished");
					startedFakeCounting = false; // JOELwindows7: reset the lock
			}
			swagCounter += 1;
		}, 5);
	}

	// JOELwindows7: the compatibility conversion case
	public function toCompatCase(daString:String):String
	{
		return StringTools.replace(daString, " ", "-").toLowerCase();
	}

	// JOELwindows7: Ugh, fine, I guess you are my littler pogchamp, come here.
	public function colorizeColorablebyKey(note:String, justOne:Bool, toWhichBg:Int)
	{
		switch (note)
		{
			case "left":
				trace("set color magenta");
				Stage.chooseColoringColor(FlxColor.fromString("magenta"), justOne, toWhichBg);
			case "down":
				trace("set color cyan");
				Stage.chooseColoringColor(FlxColor.fromString("cyan"), justOne, toWhichBg);
			case "up":
				trace("set color lime");
				Stage.chooseColoringColor(FlxColor.fromString("lime"), justOne, toWhichBg);
			case "right":
				trace("set color red");
				Stage.chooseColoringColor(FlxColor.fromString("red"), justOne, toWhichBg);
			default:
		}
	}

	public function colorizeColorablebyKeyNum(note:Int, justOne:Bool, toWhichBg:Int)
	{
		switch (note)
		{
			case 0:
				trace("set color magenta");
				Stage.chooseColoringColor(FlxColor.fromString("magenta"), justOne, toWhichBg);
			case 1:
				trace("set color cyan");
				Stage.chooseColoringColor(FlxColor.fromString("cyan"), justOne, toWhichBg);
			case 2:
				trace("set color lime");
				Stage.chooseColoringColor(FlxColor.fromString("lime"), justOne, toWhichBg);
			case 3:
				trace("set color red");
				Stage.chooseColoringColor(FlxColor.fromString("red"), justOne, toWhichBg);
			default:
		}
	}

	// JOELwindows7: special starfielder for playstate
	public function installStarfield(is3D:Bool = false, x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0, starAmount:Int = 300, behind:Bool = true)
	{
		if (behind)
		{
			// yeet elements first & put back again later.
			remove(gf);
			remove(boyfriend);
			remove(dad);
		}
		if (is3D)
		{
			installStarfield3D(Std.int(x), Std.int(y), Std.int(width), Std.int(height), starAmount);
		}
		else
		{
			installStarfield2D(Std.int(x), Std.int(y), Std.int(width), Std.int(height), starAmount);
		}
		if (behind)
		{
			// here put back all again.
			add(gf);
			add(boyfriend);
			add(dad);
		}
	}

	// JOELwindows7: scronch Haxe script
	public function scronchHscript()
	{
		if (hscriptModchart != null)
		{
			hscriptModchart.die();
			hscriptModchart = null;
		}
		if (stageHscript != null)
		{
			stageHscript.die();
			stageHscript = null;
		}
	}

	// JOELwindows7: scronch Lua script
	public function scronchLuaScript()
	{
		#if FEATURE_LUAMODCHART
		if (luaModchart != null)
		{
			luaModchart.die();
			luaModchart = null;
		}
		if (stageScript != null)
		{
			stageScript.die();
			stageScript = null;
		}
		#end
	}

	public function scronchModcharts()
	{
		scronchLuaScript();
		scronchHscript();
	}

	// JOELwindows7: feggin renew song length because something went wrong.
	function renewSongLengths()
	{
		#if FEATURE_LUAMODCHART
		if (executeModchart && luaModchart != null)
		{
			luaModchart.setVar('songLength', songLength);
		}
		if (executeStageScript && stageScript != null)
		{
			stageScript.setVar('songLength', songLength);
		}
		#end
		if (executeModHscript && hscriptModchart != null)
		{
			hscriptModchart.setVar('songLength', songLength);
		}
		if (executeStageHscript && stageHscript != null)
		{
			stageHscript.setVar('songLength', songLength);
		}
	}

	// JOELwindows7: Psyched Botplay text fade in out
	function fadeOutBotplayText()
	{
		if (botPlayState != null)
		{
			FlxTween.tween(botPlayState, {alpha: 0}, 1, {
				ease: FlxEase.linear,
				onComplete: function(twn:FlxTween)
				{
					fadeInBotplayText();
				}
			});
		}
	}

	function fadeInBotplayText()
	{
		if (botPlayState != null)
		{
			FlxTween.tween(botPlayState, {alpha: 1}, 1, {
				ease: FlxEase.linear,
				onComplete: function(twn:FlxTween)
				{
					fadeOutBotplayText();
				}
			});
		}
	}

	// JOELwindows7: Check week Completition
	function checkWeekComplete()
	{
		// var weekRightNowIs:Int = storyWeek;
		trace("Week Complete No. " + Std.string(storyWeek));

		switch (storyWeek)
		{
			case 0:
				trace("tutorial completa");
			case 1:
				AchievementUnlocked.whichIs("anSpook");
			case 6:
				AchievementUnlocked.whichIs("tankman_in_embargo");
			default:
				trace("week completa");
		}
	}

	// JOELwindows7: check song has completed (including Botplay)
	function touchedSongComplete()
	{
		trace("Song Complete " + curSong);
		switch (curSong)
		{
			default:
				trace("an song complete");
		}
	}

	// JOELwindows7: Psyched intro after video and before dialogue chat
	function introScene()
	{
		switch (curSong)
		{
			default:
				// No cutscene intro
		}
	}

	// JOELwindows7: Psyched outro after dialogue chat & before epilogue video
	function outroScene(handoverName:String)
	{
		switch (handoverName.toLowerCase())
		{
			case 'mayday': // blacken the screen like going to Winter Horrorland but slowed and sadder
				// to contemplate in memory of those 3 taken down mods. and more.
				var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
					-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
				blackShit.scrollFactor.set();
				blackShit.alpha = 0;
				add(blackShit);
				// camHUD.alpha = 0;
				FlxTween.tween(camHUD, {alpha: 0}, 5, {
					ease: FlxEase.linear,
					onComplete: function(twn:FlxTween)
					{
					}
				});
				FlxTween.tween(blackShit, {alpha: 1}, 5, {
					ease: FlxEase.linear,
					onComplete: function(twn:FlxTween)
					{
					}
				});
			default:
		}
	}

	// JOELwindows7: manage mouse
	override function manageMouse()
	{
		super.manageMouse();

		// JOELwindows7: pause btton on screen
		if (FlxG.mouse.overlaps(pauseButton) && startedCountdown && canPause)
		{
			if (FlxG.mouse.justPressed)
			{
				if (!havePausened)
				{
					havePausened = true;
				}
			}
		}
		// JOELwindows7: check Pausability
		if (startedCountdown && canPause)
		{
			if (pauseButton != null)
			{
				pauseButton.visible = true;
			}
		}
		else
		{
			if (pauseButton != null)
			{
				pauseButton.visible = false;
			}
		}
	}
}
// u looked :O -ides
