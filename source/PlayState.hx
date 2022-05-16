package;

import ui.states.PrepareUnpauseSubstate;
#if EXPERIMENTAL_KEM0X_SHADERS
import DynamicShaderHandler; // JOELwindows7: kem0x mod shader https://github.com/kem0x/FNF-ModShaders
#end
#if cpp
import cpp.Stdio;
#end
import HaxeScriptState;
import const.Perkedel;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUITypedButton;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUICheckBox;
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
import flixel.addons.ui.FlxUIText;
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
// import hx.files.*;
using StringTools;
using flixel.util.FlxSpriteUtil;

class PlayState extends MusicBeatState
{
	public static var instance:PlayState = null;

	// public static var curStage:String = ''; // to be removed
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
	public static var noteskinSpriteMine:FlxAtlasFrames; // JOElwindows7: the mine, don't step on it
	public static var noteskinPixelSprite:BitmapData;
	public static var noteskinPixelSpriteEnds:BitmapData;
	public static var noteskinPixelSpriteMine:BitmapData; // JOElwindows7: the mine, don't step on it
	public static var noteskinPixelSpriteEndsMine:BitmapData; // JOElwindows7: the mine, don't step on it

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
	var kadeEngineWatermark:FlxUIText;
	var reuploadWatermark:FlxUIText; // JOELwindows7: reupload & no credit protection.

	// last resort is to have links shared in video, hard coded, hard embedded.
	// hopefully the "thiefs" got displeased lmao!
	// JOELwindows7: Doki doki dance thingie heartbeat
	// bf, dad, gf
	public var heartRate:Array<Float> = [70, 60, 80];
	public var minHR:Array<Float> = [70, 60, 80];
	public var maxHR:Array<Float> = [220, 210, 290];
	public var heartTierIsRightNow:Array<Int> = [0, 0, 0];
	public var heartTierBoundaries:Array<Array<Float>> = [[90, 120, 150, 200], [90, 120, 150, 200], [90, 120, 150, 200],]; // tier when bellow each number
	public var successionAdrenalAdd:Array<Array<Float>> = [[4, 3, 2, 1], [4, 3, 2, 1], [4, 3, 2, 1],];
	public var fearShockAdd:Array<Array<Float>> = [[10, 8, 7, 5], [10, 8, 7, 5], [10, 8, 7, 5],];
	public var relaxMinusPerBeat:Array<Array<Float>> = [[1, 2, 4, 7], [1, 2, 4, 7], [1, 2, 4, 7],];

	var slowedAlready:Array<Bool> = [false, false, false];

	#if FEATURE_DISCORD
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	public var vocals:FlxSound; // JOELwindows7: make public for Moddchart. oh wait. Kade already done that.
	public var vocals2:FlxSound; // JOELwindows7: second vocal set, for player2 if available.
	public var audiotracks:Array<FlxSound>; // JOELwindows7: screw this! let's have more of them!

	public static var isSM:Bool = false;
	#if FEATURE_STEPMANIA
	public static var sm:SMFile;
	#end
	public static var pathToSm:String; // JOELwindows7: knock this down away. It's just string so no implication.

	// also not too much memory deal though.
	// public var originalX:Float; // JOELwindows7: what is this?
	public static var dad:Character;
	public static var gf:Character;
	public static var boyfriend:Boyfriend;

	public var notes:FlxTypedGroup<Note>;

	private var unspawnNotes:Array<Note> = [];

	public var strumLine:FlxSprite;

	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	// JOELwindows7: oh the blackbars but right here
	public var realBlackbarsTop:FlxSprite;
	public var realBlackbarsBottom:FlxSprite;
	public var realBlackbarHeight:Int = 100;

	// JOELwindows7: flag to let stage or whatever override camFollow position
	private var manualCamFollowPosP1:Array<Float> = [0, 0];
	private var manualCamFollowPosP2:Array<Float> = [0, 0];

	public var laneunderlay:FlxSprite;
	public var laneunderlayOpponent:FlxSprite;

	public static var strumLineNotes:FlxTypedGroup<StaticArrow> = null;
	public static var playerStrums:FlxTypedGroup<StaticArrow> = null;
	public static var cpuStrums:FlxTypedGroup<StaticArrow> = null;
	public static var grpNoteSplashes:FlxTypedGroup<NoteSplash>; // JOELwindows7: Psyched note splash
	public static var grpNoteHitlineParticles:FlxTypedGroup<FlxSprite>; // JOELwindows7: same as note splash but simpler, to see perfect, late early you hit.

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

	public var camGame:FlxCamera; // JOELwindows7: (was private) dude whyn't work anymore after 1.7

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

	public var dialogue:Array<String> = Perkedel.NULL_DIALOGUE_CHAT; // JOELwindows7: now have moved these dummy variables to constants class.
	public var epilogue:Array<String> = Perkedel.NULL_EPILOGUE_CHAT; // JOELwindows7: same dialoguer but for after song done. this too moved.

	var useStageScript:Bool = false; // JOELwindows7: flag to start try the stage Lua script
	var attemptStageScript:Bool = false; // JOELwindows7: flag to start prepare stage script after all stuffs loaded.

	var songName:FlxText;

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
	var scoreTxtTween:FlxTween; // JOELwindows7: Psyched score zoom yeah!

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
	#if EXPERIMENTAL_KEM0X_SHADERS
	public static var animatedShaders:Map<String, DynamicShaderHandler> = new Map<String, DynamicShaderHandler>(); // kem0x mod shader

	#end
	public static var judgementWords:Array<String> = ["Misses", "Shits", "Bads", "Goods", "Sicks", "Danks", "MVPs"];

	// API stuff
	// JOELwindows7: week 7 stuff yoinked from luckydog7 android port that yoinked it
	// for test song cuz it sucks. 4 bfs :)
	private var boyfriend2:Boyfriend;
	private var pixel2:Character;

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

		if (FlxG.save.data.fpsCap > Perkedel.MAX_FPS_CAP) // JOELwindows7: was 290
		{
			// JOELwindows7: android issue. cast lib current technic crash
			#if FEATURE_DISPLAY_FPS_CHANGE
			// (cast(Lib.current.getChildAt(0), Main)).setFPSCap(800);
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
		PlayStateChangeables.legacyLuaModchartSupport = FlxG.save.data.legacyLuaScript || SONG.forceLuaModchartLegacy;

		removedVideo = false;

		#if FEATURE_LUAMODCHART
		// TODO: Refactor this to use OpenFlAssets.
		// executeModchart = FileSystem.exists(Paths.lua('songs/${PlayState.SONG.songId}/modchart'))
		executeModchart = Paths.doesTextAssetExist(Paths.lua('songs/${PlayState.SONG.songId}/modchart'))
			|| SONG.forceLuaModchart; // JOELwindows7: don't forgot force it.
		if (isSM)
			// executeModchart = FileSystem.exists(pathToSm + "/modchart.lua");
			executeModchart = Paths.doesTextAssetExist(pathToSm + "/modchart.lua");
		if (executeModchart)
			PlayStateChangeables.Optimize = false;
		#end
		#if !cpp
		executeModchart = false; // FORCE disable for non cpp targets
		executeStageScript = false; // JOELwindows7: this too
		#end
		Debug.logInfo("forced hscript exist is " + Std.string(SONG.forceLuaModchart));

		Debug.logInfo('Searching for mod chart? ($executeModchart) at ${Paths.lua('songs/${PlayState.SONG.songId}/modchart')}');

		// JOELwindows7: now for the hscript
		// JOELwindows7: new exists
		executeModHscript = Paths.doesTextAssetExist(Paths.hscript('songs/${PlayState.SONG.songId}/modchart'))
			|| SONG.forceHscriptModchart;
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
		// startHeartBeat();

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
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>(); // JOELwindows7: okey why ShadowMario or whoever
		grpNoteHitlineParticles = new FlxTypedGroup<FlxSprite>(); // JOELwindows7: okey here note hitlines. inspired from that notesplash & viking timpani game called 'Ragnarock'. Steam.
		// in the blame init that notesplash group here? Psyched
		// maybe because it's after add all those cameras?

		camHUD.zoom = PlayStateChangeables.zoom;

		FlxCamera.defaultCameras = [camGame];
		// FlxG.cameras.setDefaultDrawTarget(camGame, true); //JOELwindows7: try the new one
		// see if it works..
		// nope. well it works, but
		// alot of semantics here has to be changed first before hand, so uh. unfortunately
		// I can't yet.
		// hey bbpanzu how the peck do we supposed to make this work??!?!?

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial', '');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		Conductor.bpm = SONG.bpm;

		if (SONG.eventObjects == null)
		{
			SONG.eventObjects = [new Song.Event("Init BPM", 0, SONG.bpm, "BPM Change", 0, 0)]; // JOELwindows7: houv
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
				// JOELwindows7: moar!! yoink week 7!
				case 7:
					stageCheck = 'tanksStage' + (SONG.songId == 'ugh' || SONG.songId == 'guns' ? "" : "2");
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
				// #if debug
				// FlxG.log.warn(["Couldn't load gf: " + gfCheck + ". Loading default gf"]);
				// #end
				// JOELwindows7: pls use new way!
				Debug.logWarn("Couldn't load gf: " + gfCheck + ". Loading default gf");
				gf = new Character(400, 130, 'gf');
			}

			boyfriend = new Boyfriend(770, 450, SONG.player1);

			if (boyfriend.frames == null)
			{
				// #if debug
				// FlxG.log.warn(["Couldn't load boyfriend: " + SONG.player1 + ". Loading default boyfriend"]);
				// #end
				// JOELwindows7: pls use new way!
				Debug.logWarn("Couldn't load boyfriend: " + SONG.player1 + ". Loading default boyfriend");
				boyfriend = new Boyfriend(770, 450, 'bf');
			}

			// JOELwindows7: temp debug heartbeating print status
			// boyfriend._setDebugPrintHeart(-1, true);

			dad = new Character(100, 100, SONG.player2);

			if (dad.frames == null)
			{
				// #if debug
				// FlxG.log.warn(["Couldn't load opponent: " + SONG.player2 + ". Loading default opponent"]);
				// #end
				// JOELwindows7: pls use new way!
				Debug.logWarn("Couldn't load opponent: " + SONG.player2 + ". Loading default opponent");
				dad = new Character(100, 100, 'dad');
			}
		}

		if (!stageTesting)
			Stage = new Stage(SONG.stage);

		var positions:Map<String, Array<Int>> = Stage.positions[Stage.curStage]; // JOELwindows7: declare type also
		if (positions != null && !stageTesting)
		{
			var positionFound:Array<Bool> = [false, false, false]; // JOELwindows7: flag of each found position
			for (char => pos in positions)
				for (person in [boyfriend, gf, dad])
				{
					var count:Int = 0; // JOELwindows7: count of found bf, gf, dad
					if (person.curCharacter == char)
					{
						person.setPosition(pos[0], pos[1]);
						positionFound[count] = true; // JOELwindows7: If this found, then mark it true
					}
					count++; // JOELwindows7: count it up!
				}

			// JOELwindows7: if any of person position not found
			var counte:Int = 0; // JOELwindows7: count of not found bf, gf, dad
			for (person in [boyfriend, gf, dad])
			{
				var nullWord:String = 'NULL-';
				// nullWord += counte == 0 ? 'bf' : counte == 1 ? 'gf' : 'dad';
				nullWord += (switch (counte)
				{
					case 0:
						'bf';
					case 1:
						'gf';
					case 2:
						'dad';
					default:
						'dad';
				});
				if (positions.exists(nullWord) && !positionFound[counte])
					person.setPosition(positions[nullWord][0], positions[nullWord][1]);
				counte++;
			}
		}
		for (i in Stage.toAdd)
		{
			add(i);
		}
		if (!PlayStateChangeables.Optimize)
		{
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
			// JOELwindows7: first, build the blackbar
			buildRealBlackBars();
		}

		gf.x += gf.charPos[0];
		gf.y += gf.charPos[1];
		dad.x += dad.charPos[0];
		dad.y += dad.charPos[1];
		boyfriend.x += boyfriend.charPos[0];
		boyfriend.y += boyfriend.charPos[1];

		camPos = new FlxPoint(dad.getGraphicMidpoint().x + dad.camPos[0], dad.getGraphicMidpoint().y + dad.camPos[1]);

		// switch (dad.curCharacter)
		if (dad.replacesGF)
		{
			// case 'gf' | 'gf-covid' | 'gf-ht' | 'gf-placeholder':
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

			// case 'gf-standalone':
			// 	// JOELwindows7: reserved for future use
			// 	// basically gf get down from speaker and duet against player 1
			// 	// dad.y += 100;
			// 	// dad.x -= 100;
			// 	switch (gfCheck)
			// 	{
			// 		case 'gf':
			// 		// remove the gf from speaker
			// 		case 'gf-ht':
			// 		// don't do anything and stay cool. no change.
			// 		default:
			// 			// do something if the GF is speaker.
			// 	}
			// case 'dad':
			// 	camPos.x += 400;
			// case 'pico':
			// 	camPos.x += 600;
			// case 'senpai':
			// 	camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			// case 'senpai-angry':
			// 	camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			// case 'spirit':
			// see `dad.hasTrail` bellow
			// case 'hookx':
			// // JOELwindows7:
			// // I am sorry to happened. I have no idea.
			// // world is bad. not worth living
			// // but why give up, we got something
			// // take my hand. I'll be waiting you outside
			// // dad.y += 100;
			// // dad.x -= 150;
			// case 'placeholder':
			// 	// dad.y += 100;
			// 	// dad.x -= 150;
			// 	camPos.set(dad.getGraphicMidpoint().x + 220, dad.getGraphicMidpoint().y);
			// default:
			// 	Debug.logTrace("Oh no! it looks like you forgot the offset position data for Player 2 " + SONG.player2);
			// 	Debug.logInfo("Forgot offset position data for Player2 " + SONG.player2);
		}

		if (dad.hasTrail)
		{
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
		}

		// JOELwindows7: REPOSITIONING PER BOYFRIEND
		// switch (SONG.player1)
		// {
		// 	case 'bf':
		// 	// No need, the stage repositionings has already based on bf itself
		// 	// its positioning has been for bf himself
		// 	case 'placeholder':
		// 	// boyfriend.y -= 220;
		// 	default:
		// 		// no repositioning
		// }
		// Optional unless your character is not default bf

		Stage.update(0);
		manageHeartbeats(0); // JOELwindows7: initially update heartbeats first!

		// JOELwindows7: reposition per stage was here. now we must reposition for custom stage.
		if (SONG.useCustomStage)
		{
			Stage.repositionThingsInStage(Stage.curStage);
		}
		else
		{
		}

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
			doof = new DialogueBox(false, dialogue, SONG.hasDialogueChat, false, SONG.hasDialogueChat);
			// doof.x += 70;
			// doof.y = FlxG.height * 0.5;
			doof.scrollFactor.set();
			doof.finishThing = startCountdown;

			// JOELwindows7: new epilogue way
			eoof = new DialogueBox(false, epilogue, SONG.hasEpilogueChat, true, SONG.hasEpilogueChat);
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
			// JOELwindows7: haxe script too
			if (!FlxG.save.data.middleScroll || executeModchart || executeModHscript)
			{
				add(laneunderlayOpponent);
			}
			add(laneunderlay);
		}

		strumLineNotes = new FlxTypedGroup<StaticArrow>();
		add(strumLineNotes);
		add(grpNoteSplashes); // JOELwindows7: Psyched! now here add the group of Notesplash here this state.
		add(grpNoteHitlineParticles); // JOELwindows7: and here the group of Notehitlineparticles.

		// JOELwindows7: Psyched notesplash. Have atleast 1 splash first so that it can be recycled, idk.
		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		// JOELwindows7: as well as the hitline. 1 atleast.
		var hitline:FlxSprite = new FlxSprite(100, 100);
		grpNoteHitlineParticles.add(hitline);
		hitline.alpha = 0.0;

		playerStrums = new FlxTypedGroup<StaticArrow>();
		cpuStrums = new FlxTypedGroup<StaticArrow>();

		// noteskinPixelSprite = NoteskinHelpers.generatePixelSprite(FlxG.save.data.noteskin);
		// noteskinSprite = NoteskinHelpers.generateNoteskinSprite(FlxG.save.data.noteskin);
		// noteskinPixelSpriteEnds = NoteskinHelpers.generatePixelSprite(FlxG.save.data.noteskin, true);
		Debug.logTrace("Pls prepare Noteskin sprites");
		// JOELwindows7: folks, let's not ignore the fact some song wants to use custom noteskin rather than user option. idk man.
		// noteskinPixelSprite = NoteskinHelpers.generatePixelSprite(SONG.useCustomNoteStyle? SONG.noteStyle :FlxG.save.data.noteskin);
		noteskinPixelSprite = SONG.useCustomNoteStyle ? NoteskinHelpers.generatePixelSpriteFromSay(SONG.noteStyle, false, 0,
			SONG.loadNoteStyleOtherWayAround) : NoteskinHelpers.generatePixelSprite(FlxG.save.data.noteskin); // JOELwindows7: new try
		// noteskinPixelSprite = NoteskinHelpers.generatePixelSprite(FlxG.save.data.noteskin); // JOElwindows7: damn it! doesn't work! it's the index they ask!
		Debug.logTrace("Go the pixel mine noteskin");
		noteskinPixelSpriteMine = SONG.useCustomNoteStyle ? NoteskinHelpers.generatePixelSpriteFromSay(SONG.noteStyle, true, 2,
			SONG.loadNoteStyleOtherWayAround) : NoteskinHelpers.generatePixelSprite(FlxG.save.data.noteskin, 2); // JOELwindows7: new try
		Debug.logTrace("Go the regular noteskin");
		// noteskinSprite = SONG.useCustomNoteStyle ? Paths.getSparrowAtlas(Note.giveMeNoteSkinPath(0)) : NoteskinHelpers.generateNoteskinSprite(FlxG.save.data.noteskin);
		noteskinSprite = SONG.useCustomNoteStyle ? NoteskinHelpers.generateNoteskinSpriteFromSay(SONG.noteStyle, 0,
			SONG.loadNoteStyleOtherWayAround) : NoteskinHelpers.generateNoteskinSprite(FlxG.save.data.noteskin);
		// noteskinSprite = NoteskinHelpers.generateNoteskinSprite(FlxG.save.data.noteskin); // JOElwindows7: damn it! doesn't work! it's the index they ask!
		Debug.logTrace("Go the mine noteskin");
		// noteskinSpriteMine = SONG.useCustomNoteStyle ? Paths.getSparrowAtlas(Note.giveMeNoteSkinPath(2) +
		// 	"-mine") : NoteskinHelpers.generateNoteskinSprite(FlxG.save.data.noteskin, 2);
		noteskinSpriteMine = SONG.useCustomNoteStyle ? NoteskinHelpers.generateNoteskinSpriteFromSay(SONG.noteStyle, 2,
			SONG.loadNoteStyleOtherWayAround) : NoteskinHelpers.generateNoteskinSprite(FlxG.save.data.noteskin, 2);
		Debug.logTrace("Go the pixel hold end");
		// noteskinPixelSpriteEnds = NoteskinHelpers.generatePixelSprite(FlxG.save.data.noteskin, true);
		noteskinPixelSpriteEnds = SONG.useCustomNoteStyle ? NoteskinHelpers.generatePixelSpriteFromSay(SONG.noteStyle, true, 0,
			SONG.loadNoteStyleOtherWayAround) : NoteskinHelpers.generatePixelSprite(FlxG.save.data.noteskin, true);
		Debug.logTrace("Go the pixel hold end mine");
		noteskinPixelSpriteEndsMine = SONG.useCustomNoteStyle ? NoteskinHelpers.generatePixelSpriteFromSay(SONG.noteStyle, true, 2,
			SONG.loadNoteStyleOtherWayAround) : NoteskinHelpers.generatePixelSprite(FlxG.save.data.noteskin, true, 2);

		Debug.logTrace("Now for static arrows");
		generateStaticArrows(0);
		Debug.logTrace("and other player static arrows");
		generateStaticArrows(1);
		Debug.logTrace("Doned static arrows");

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
			// luaModchart.executeState('start', [PlayState.SONG.songId]);
			luaModchart.setVar('songLength', songLength);
			luaModchart.setVar('variables', SONG.variables);
			luaModchart.setVar('diffVariables', SONG.diffVariables);
		}
		if (executeStageScript && stageScript != null)
		{
			// stageScript.executeState('start', [PlayState.SONG.songId]);
			stageScript.setVar('songLength', songLength);
			stageScript.setVar('variables', SONG.variables);
			stageScript.setVar('diffVariables', SONG.diffVariables);
		}
		#end
		// JOELwindows7: now for the hscript init
		if (executeModHscript)
		{
			hscriptModchart = HaxeScriptState.createModchartState();
			hscriptModchart.setVar('executeModchart', executeModchart);
			hscriptModchart.setVar('executeModHscript', executeModHscript);
			hscriptModchart.setVar('executeStageHscript', executeStageHscript);
			hscriptModchart.setVar('executeStageScript', executeStageScript);
			hscriptModchart.setVar('songLength', songLength);
			hscriptModchart.setVar('variables', SONG.variables);
			hscriptModchart.setVar('diffVariables', SONG.diffVariables);
			// hscriptModchart.executeState('start', [PlayState.SONG.songId]);
		}
		if (executeStageHscript && stageHscript != null)
		{
			stageHscript.setVar('executeModchart', executeModchart);
			stageHscript.setVar('executeModHscript', executeModHscript);
			stageHscript.setVar('executeStageHscript', executeStageHscript);
			stageHscript.setVar('executeStageScript', executeStageScript);
			stageHscript.setVar('songLength', songLength);
			stageHscript.setVar('variables', SONG.variables);
			stageHscript.setVar('diffVariables', SONG.diffVariables);
			// stageHscript.executeState('start', [PlayState.SONG.songId]);
		}
		// JOELwindows7: end of hscript init

		// JOELwindows7: tell Lua script whether hscript is running too
		#if FEATURE_LUAMODCHART
		if (executeModchart)
		{
			luaModchart.setVar('executeModchart', executeModchart);
			luaModchart.setVar('executeModHscript', executeModHscript);
			luaModchart.setVar('executeStageHscript', executeStageHscript);
			luaModchart.setVar('executeStageScript', executeStageScript);
		}
		if (executeStageScript && stageScript != null)
		{
			stageScript.setVar('executeModchart', executeModchart);
			stageScript.setVar('executeModHscript', executeModHscript);
			stageScript.setVar('executeStageHscript', executeStageHscript);
			stageScript.setVar('executeStageScript', executeStageScript);
		}
		#end

		#if FEATURE_LUAMODCHART
		if (executeModchart)
		{
			new LuaCamera(camGame, "camGame").Register(ModchartState.lua);
			new LuaCamera(camHUD, "camHUD").Register(ModchartState.lua);
			new LuaCamera(camSustains, "camSustains").Register(ModchartState.lua);
			// new LuaCamera(camSustains, "camNotes").Register(ModchartState.lua);
			new LuaCamera(camNotes, "camNotes").Register(ModchartState.lua); // JOELwindows7: oops! somebody typo
			new LuaCharacter(dad, "dad").Register(ModchartState.lua);
			new LuaCharacter(gf, "gf").Register(ModchartState.lua);
			new LuaCharacter(boyfriend, "boyfriend").Register(ModchartState.lua);
		}
		#end

		// JOELwindows7: ultimately, call start to all modcharts
		executeModchartState("start", [PlayState.SONG.songId]);

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

		for (i in 0...unspawnNotes.length)
			if (unspawnNotes[i].strumTime < startTime)
				unspawnNotes.remove(unspawnNotes[i]);

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

		#if FEATURE_DISPLAY_FPS_CHANGE
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
		reuploadWatermark = new FlxUIText((FlxG.width / 2)
			- 100, (FlxG.height / 2)
			+ 50, 0,
			"Download Last Funkin Moments ($0) https://github.com/Perkedel/kaded-fnf-mods,\n"
			+ "Kade Engine ($0) https://github.com/KadeDev/Kade-Engine ,\n"
			+ "and vanilla funkin ($0) https://github.com/ninjamuffin99/Funkin\n"
			+ "Now Playing: "
			+ SONG.artist
			+ " - "
			+ SONG.songName
			+ "\n"
			+ "Song ID: "
			+ SONG.songId
			+ "\n",
			14);
		reuploadWatermark.setPosition((FlxG.width / 2) - (reuploadWatermark.width / 2), (FlxG.height / 2) - (reuploadWatermark.height / 2) + 50);
		// Ah damn. the pivot of all Haxe Object is top left!
		// right, let's just work this all around anyway.
		// there I got it. hopefully it's centered.
		reuploadWatermark.scrollFactor.set();
		reuploadWatermark.setFormat(Paths.font("UbuntuMono-R.ttf"), 14, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK); // was vcr.ttf
		reuploadWatermark.screenCenter(XY); // JOELwindows7: turns out everything solves just with this thing right here whoahow!!!
		add(reuploadWatermark);
		reuploadWatermark.visible = false;
		// follow this example, you must be protected too from those credit-less YouTubers the bastards!
		// We anchored the watermark dead center, just 50 px down abit. idk.. we centered it.

		// JOELwindows7: I add watermark Perkedel Mod
		// Add Kade Engine watermark
		kadeEngineWatermark = new FlxUIText(4, healthBarBG.y
			+ 50, 0, // SONG.songName
			SONG.songId // JOELwindows7: damn, you should've used Song ID instead. the top bar already covered the name for us!
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
		scoreTxt.text = Ratings.CalculateRanking(songScore, songScoreDef, nps, maxNPS,
			(FlxG.save.data.roundAccuracy ? FlxMath.roundDecimal(accuracy, 0) : accuracy), boyfriend.getHeartRate(0),
			boyfriend.getHeartTier(0) // JOELwindows7: this is just recently popped up.
		);
		if (!FlxG.save.data.healthBar)
			scoreTxt.y = healthBarBG.y;

		add(scoreTxt);

		judgementCounter = new FlxText(20, 0, 0, "", 20);
		// JOELwindows7: I think this should be placed on right as where your player strum is at.
		judgementCounter.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, FlxTextAlign.RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		judgementCounter.alpha = .5; // JOELwindows7: also bit opaque pls!
		judgementCounter.borderSize = 2;
		judgementCounter.borderQuality = 2;
		judgementCounter.scrollFactor.set();
		judgementCounter.cameras = [camHUD];
		judgementCounter.screenCenter(Y);
		// judgementCounter.text = 'Sicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\nMisses: ${misses}';
		// JOELwindows7: wai wait! Custom sponsor word. ... I mean judgement words.
		judgementCounter.text = '${judgementWords[4]}: ${sicks}\n${judgementWords[3]}: ${goods}\n${judgementWords[2]}: ${bads}\n${judgementWords[1]}: ${shits}\n${judgementWords[0]}: ${misses}';
		judgementCounter.setPosition(FlxG.width - judgementCounter.width - 15, 0); // JOELwindows7: hey! place it actually right side of screen!
		judgementCounter.screenCenter(Y); // JOELwindows7: do center it again just in case.
		if (FlxG.save.data.judgementCounter)
		{
			add(judgementCounter);
		}

		replayTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0, "REPLAY",
			20);
		replayTxt.setPosition((FlxG.width / 2) - 75, 130); // JOELwindows7: oh wait, Psych this up pls!
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
		botPlayState.setPosition((FlxG.width / 2) - 75, 130); // JOELwindows7: oh wait, Psych this up pls!
		botPlayState.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK); // JOELwindows7: was size 42
		botPlayState.scrollFactor.set();
		botPlayState.borderSize = 2; // JOELwindows7: was 4
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
		addPauseButton(Std.int((FlxG.width / 2) - (128 / 2)), 80 - 20); // was 80
		trace("install pause button");

		// JOELwindows7: install credit Rolls
		creditRollout = new CreditRollout();
		creditRollout.build();
		// add(creditRollout);
		add(creditRollout.textTitle);
		add(creditRollout.textName);
		add(creditRollout.textRole);

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD]; // JOELwindows7: notesplash group put in camHUD! Psychedly
		grpNoteHitlineParticles.cameras = [camHUD]; // JOELwindows7: also the hitlines
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
					// JOELwindows7: hide the lemon guy character icon!
					iconP2.changeIcon('placeholder');

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
					if (SONG.hasTankmanVideo)
					{
						tankmanIntro(Paths.video(SONG.tankmanVideoPath));
					}
					else
					{
						introScene(); // JOELwindows7: start intro cutscene!

						// new FlxTimer().start(SONG.delayBeforeStart, function(timer:FlxTimer)
						// { // JOELwindows7: also add delay before start
						// 	// for intro cutscene after video and before dialogue chat you know!
						// 	// JOELwindows7: Heuristic for using JSON chart instead
						// 	if (SONG.hasDialogueChat)
						// 	{
						// 		schoolIntro(doof);
						// 	}
						// 	else
						// 	{
						// 		new FlxTimer().start(1, function(timer)
						// 		{
						// 			startCountdown();
						// 		});
						// 	}
						// });
					}
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
		// formerly use tedious `FlxG.console.registerFunction()`
		Debug.addConsoleCommand("startFakeCountdown", function()
		{
			startFakeCountdown();
		});
		Debug.addConsoleCommand("trainStart", function()
		{
			PlayState.Stage.trainStart();
		});
		Debug.addConsoleCommand("trainReset", function()
		{
			PlayState.Stage.trainReset();
		});
		Debug.addConsoleCommand("fastCarDrive", function()
		{
			PlayState.Stage.fastCarDrive();
		});
		Debug.addConsoleCommand("resetFastCar", function()
		{
			PlayState.Stage.resetFastCar();
		});
		Debug.addConsoleCommand("debugSeven", function()
		{
			haveDebugSevened = true;
		});
		Debug.addConsoleCommand("lightningStrikeShit", function()
		{
			PlayState.Stage.lightningStrikeShit();
		});
		Debug.addConsoleCommand("justCheer", function()
		{
			justCheer();
		});
		Debug.addConsoleCommand("justHey", function()
		{
			justHey();
		});
		Debug.addConsoleCommand("justCheerHey", function()
		{
			justHey();
			justCheer();
		});

		// object debugs. also register objects for debugs
		Debug.addObject("PlayState", this);
		Debug.addObject("Stage", Stage);
		#if FEATURE_LUAMODCHART
		if (executeModchart && luaModchart != null)
			Debug.addObject("luaModchart", luaModchart);
		if (executeStageScript && stageScript != null)
			Debug.addObject("stageScript", stageScript);
		#end
		if (executeModHscript && hscriptModchart != null)
			Debug.addObject("hscriptModchart", hscriptModchart);
		if (executeStageHscript && stageHscript != null)
			Debug.addObject("stageHscript", stageHscript);

		// JOELwindows7: Now Init CustomStage scripts if had to.
		if (attemptStageScript || Stage.attemptStageScript)
		{
			Stage.spawnStageScript("stages/" + CoolUtil.toCompatCase(SONG.stage) + "/stageScript");
		}

		// JOELwindows7: show credit rollouts if the song has to do so
		if (SONG.isCreditRoll)
		{
			creditRollout.loadCreditData(Paths.creditFlashBlink(SONG.songId), SONG.creditRunsOnce);
		}

		// FlxG.autoPause = true; // JOELwindows7: because somehow the film does not return it back

		// JOELwindows7: unpop loading bar!
		_loadingBar.unPopNow();

		// JOELwindows7: why the peck with touchscreen button game crash on second run?!
		trace("finish create PlayState");
	}

	function tankmanIntroVidFinish(source:String, outro:Bool = false, handoverName:String = "", isNextSong:Bool = false, handoverDelayFirst:Float = 0,
			handoverHasEpilogueVid:Bool = false, handoverEpilogueVidPath:String = "", handoverHasTankmanEpilogueVid:Bool = false,
			handoverTankmanEpilogueVidPath:String = "")
	{
		if (outro)
		{
			// outroScene(handoverName, isNextSong, handoverDelayFirst, handoverHasEpilogueVid, handoverEpilogueVidPath, handoverHasTankmanEpilogueVid,
			// 	handoverTankmanEpilogueVidPath);

			if (isNextSong)
			{
				// JOELwindows7: here timer guys
				new FlxTimer().start(handoverDelayFirst, function(tmr:FlxTimer)
				{
					// JOELwindows7: if has video, then load the video first before going to new playstate!
					// LoadingState.loadAndSwitchState(handoverHasEpilogueVid ? (VideoCutscener.getThe(handoverEpilogueVidPath,
					// 	(SONG.hasVideo ? VideoCutscener.getThe(SONG.videoPath,
					// 		new PlayState()) : new PlayState()))) : (SONG.hasVideo ? VideoCutscener.getThe(SONG.videoPath, new PlayState()) : new PlayState()));
					switchState(handoverHasEpilogueVid ? (VideoCutscener.getThe(handoverEpilogueVidPath,
						(SONG.hasVideo ? VideoCutscener.getThe(SONG.videoPath,
							new PlayState()) : new PlayState()))) : (SONG.hasVideo ? VideoCutscener.getThe(SONG.videoPath, new PlayState()) : new PlayState()),
						true, true, true, true);
					// LoadingState.loadAndSwitchState(new PlayState()); //Legacy
					// JOELwindows7: oh God, so complicated. I hope it works! use Hex weekend switchState
					clean();
				});
			}
			else
			{
				// JOELwindows7: yep move from that function. this one is when song has ran out in the playlist.
				new FlxTimer().start(handoverDelayFirst, function(tmr:FlxTimer)
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
						// FlxG.switchState(SONG.hasEpilogueVideo ? VideoCutscener.getThe(SONG.epilogueVideoPath, new StoryMenuState()) : new StoryMenuState());
						switchState(SONG.hasEpilogueVideo ? VideoCutscener.getThe(SONG.epilogueVideoPath,
							new StoryMenuState()) : new StoryMenuState()); // JOELwindows7: use Hex Kade YinYang48 version!
						// JOELwindows7: complicated! oh MY GOD!
						clean();
					}
				});
			}
		}
		else
		{
			introScene(); // JOELwindows7: start intro cutscene!
		}
	}

	function tankmanIntro(source:String, outro:Bool = false, handoverName:String = "", isNextSong:Bool = false, handoverDelayFirst:Float = 0,
			handoverHasEpilogueVid:Bool = false, handoverEpilogueVidPath:String = "", handoverHasTankmanEpilogueVid:Bool = false,
			handoverTankmanEpilogueVidPath:String = ""):Void
	{
		// JOELwindows7: okay here video for week7. fun fact, this is how week7 vanilla video loads.
		// Essentially is a dialogue but instead it's a video FlxSprite spawned above the gameplay, replacing the dialogue.
		// steal this luckydog7's android port, it yoinked the week7 and looks fine on GameBanana even still in embargo somehow.
		// Coding is at that PlayState.hx . there are 3 week7 intro methods unprocedurally: `ughIntro`, `gunsIntro`, & `stressIntro`.

		#if (FEATURE_VLC)
		// JOELwindows7: inspire that luckydog7's webmer bellow, build the VLC version of function!
		// inspire from function backgroundVideo if the FEATURE_VLC is available!

		// var videoSpriteFirst = new FlxSprite();
		// Build own cam!
		// var ownCam = new FlxCamera();
		// FlxG.cameras.add(ownCam);
		// ownCam.bgColor.alpha = 0;
		// videoSpriteFirst.cameras = [ownCam];

		// var video = new MP4Sprite(0, 0, FlxG.width, FlxG.height);
		var video = new MP4Handler();
		// video.cameras = [ownCam];

		video.finishCallback = function()
		{
			// videoSpriteFirst.kill();
			// remove(videoSpriteFirst);
			// remove(video);
			tankmanIntroVidFinish(source, outro, handoverName, isNextSong, handoverDelayFirst, handoverHasEpilogueVid, handoverEpilogueVidPath,
				handoverHasTankmanEpilogueVid, handoverTankmanEpilogueVidPath);
		};
		// video.playMP4(source, null, videoSpriteFirst); // make the transition null so it doesn't take you out of this state
		video.playVideo(source, false, false); // make the transition null so it doesn't take you out of this state
		// videoSpriteFirst.setGraphicSize(Std.int(videoSpriteFirst.width * 1.2));
		// video.setGraphicSize(Std.int(video.width * 1.2));
		// videoSpriteFirst.updateHitbox();
		// video.updateHitbox();
		// add(videoSpriteFirst);
		// add(video);
		#elseif (FEATURE_WEBM && !FEATURE_VLC)
		var video = new VideoPlayer(source);
		video.finishCallback = () ->
		{
			remove(video);
			// startCountdown();
			tankmanIntroVidFinish(source, outro, handoverName, isNextSong, handoverDelayFirst, handoverHasEpilogueVid, handoverEpilogueVidPath,
				handoverHasTankmanEpilogueVid, handoverTankmanEpilogueVidPath);
		}
		video.ownCamera();
		video.setGraphicSize(Std.int(video.width * 2));
		video.updateHitbox();
		add(video);
		video.play();
		#end
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
								FlxG.sound.play(Paths.sound(PlayState.SONG.songId.contains('midi') ? 'Senpai_Dies-midi' : 'Senpai_Dies'), 1, false, null,
									true, function()
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
		// iconP1.visible = false;
		// iconP2.visible = false;
		// JOELwindows7: no more invisiblize the health icon because that has already layered back now.

		// First, mute the music and vocals. like endSong.
		// also disable the pause to prevent accident pause by press enter which also moves the dialogue.
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		if (vocals2 != null)
			vocals2.volume = 0; // JOELwindows7: ye

		// Stop the music and vocal too
		// FlxG.sound.music.stop();
		// vocals.stop();
		// vocals2.stop(); //JOELwindows7: ye

		// Pay attention for the pre-dialogue effect show like in Rose, senpai got mad thingy
		switch (SONG.songId.toLowerCase())
		{
			default:
				{}
		}

		if (dialogueBox != null)
		{
			inCutscene = true;

			// omg what?
			switch (SONG.songId.toLowerCase())
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
		if (vocals != null)
			vocals.stop();

		var swagCounter:Int = 0;

		musicCompleted = false; // JOELwindows7: just in case somebody out of cage. unraise the flag, until music finished.

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
			else if (swagCounter % idleBeat != 0)
			{
				if (boyfriend.isDancing && !boyfriend.animation.curAnim.name.endsWith("miss"))
					boyfriend.dance();
				if (dad.isDancing)
					dad.dance();
			}

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
						FlxG.sound.play(Paths.sound((reversed ? 'intro1' : 'intro3') + altSuffix + midiSuffix), 0.6);
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
						FlxG.sound.play(Paths.sound('intro2' + altSuffix + midiSuffix), 0.6);
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
					if (!silent) // JOELwindows7: ssshhh + reverse pls dont gone!
						FlxG.sound.play(Paths.sound((reversed ? 'intro3' : 'intro1') + altSuffix + midiSuffix), 0.6);
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
						FlxG.sound.play(Paths.sound('introGo' + altSuffix + midiSuffix), 0.6);

					// JOELwindows7: now visiblize the touchscreen buttons
					// trace("visiblize touchscreen button now");
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
		if (vocals2 != null)
			vocals2.play(); // JOELwindows7: ye

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
			// JOELwindows7: frogot to change convention lmao
			case 'bopeebo' | 'philly' | 'blammed' | 'cocoa' | 'eggnog':
				allowedToCheer = true;
			default:
				allowedToCheer = SONG.allowedToHeadbang; // JOELwindows7: define by the JSON chart instead
				// use "allowedToHeadbang": true to your JSON chart (per difficulty) to enable headbangs.
		}

		// JOELwindows7: there is VLC!
		if (useVideo && !useVLC)
			GlobalVideo.get().resume();
		else if (useVLC)
		{
			#if FEATURE_VLC
			if (vlcHandler != null)
				vlcHandler.resume();
			#end
		}

		// #if FEATURE_LUAMODCHART
		// if (executeModchart)
		// 	luaModchart.executeState("songStart", [null]);
		// // JOELwindows7: here on the other side too song started
		// if (executeStageScript)
		// 	stageScript.executeState("songStart", [null]);
		// #end
		// if (executeModHscript)
		// 	hscriptModchart.executeState('songStart', [null]);
		// if (executeStageHscript)
		// 	stageHscript.executeState('songStart', [null]);
		// JOELwindows7: better unified function!
		executeModchartState('songStart', [null]);

		#if FEATURE_DISCORD
		// Updating Discord Rich Presence (with Time Left)
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

		FlxG.sound.music.time = startTime;
		if (vocals != null)
			vocals.time = startTime;
		if (vocals2 != null)
			vocals2.time = startTime; // JOELwindows7: ye
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
			if (vocals2.playing) // JOELwindows7: oh yea
				lime.media.openal.AL.sourcef(vocals2._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
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
		{
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.songId));
		}
		else
		{
			vocals = new FlxSound();
		}
		// JOELwindows7: ye
		if (SONG.needsVoices2 && !isSM)
		{
			vocals2 = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.songId, 2));
		}
		else
		{
			vocals2 = new FlxSound(); // JOELwindows7: ye
		}
		#else
		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.songId));
		else
		{
			vocals = new FlxSound();
			vocals2 = new FlxSound(); // JOELwindows7: ye
		}
		// JOELwindows7: ye
		if (SONG.needsVoices2)
			vocals2 = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.songId, 2));
		else
		{
			vocals2 = new FlxSound(); // JOELwindows7: ye
		}
		#end

		trace('loaded vocals');

		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(vocals2);

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
				FlxG.sound.playMusic(sound, 1, false); // JOELwindows7: DO NOT PECKING FORGET TO DESTROY THE LOOP
				// Otherwise the end of the song is spasm since the end music signal does not trigger with loop ON.
			}
			else
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.songId), 1, false);
			#else
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.songId), 1, false);
			#end
		}

		Debug.logInfo("SONGeh " + Std.string(FlxG.sound.music));

		FlxG.sound.music.looped = false; // JOELwindows7: okay try to make this unloop.
		// FlxG.sound.music.onComplete = endSong;
		// FlxG.sound.music.onComplete = checkEpilogueChat; // Moved to somewhere again ; This is needed again as Kade's current one ends abruptly
		FlxG.sound.music.onComplete = function()
		{
			Debug.logTrace("Music is really complete");
			// JOELwindows7: here raise the flag!
			musicCompleted = true;
		}
		musicCompleted = false; // JOELwindows7: only after the music is finished
		// JOELwindows7: now instead pls check the epilogue chat!
		FlxG.sound.music.pause();

		if (SONG.needsVoices && !PlayState.isSM)
			FlxG.sound.cache(Paths.voices(PlayState.SONG.songId));
		if (!PlayState.isSM)
			FlxG.sound.cache(Paths.inst(PlayState.SONG.songId));

		// Song duration in a float, useful for the time left feature
		songLength = ((FlxG.sound.music.length / songMultiplier) / 1000); // JOELwindows7: pinpoint song length set

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

			// songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - (SONG.songName.length * 5), songPosBG.y - 15, 0, SONG.songName, 16);
			// JOELwindows7: Pls put artist
			songName = new FlxText(songPosBG.x
				+ (songPosBG.width / 2)
				- ((SONG.songName.length + 3 + SONG.artist.length) * 5), songPosBG.y
				- 15, 0,
				SONG.artist
				+ " - "
				+ SONG.songName, 16);
			// songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.setFormat(Paths.font("UbuntuMono-R.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,
				FlxColor.BLACK); // JOELwindows7: I want international support!
			songName.scrollFactor.set();

			// JOELwindows7: YOU SNEAKY LITTLE PUNK!!! WHY TEXT CHANGE AGAIN HERE?!??!
			songName.text = SONG.artist + " - " + SONG.songName + ' (' + FlxStringUtil.formatTime(songLength, false) + ')';
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

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, false, false, songNotes[4],
					songNotes[5]); // JOELwindows7: the note with type
				swagNote.hitsoundPath = songNotes[6]; // JOELwindows7: and the hit sound file name;

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

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true, false,
						false, songNotes[4], songNotes[5]); // JOELwindows7: here sustain note too.
					sustainNote.hitsoundPath = songNotes[6]; // JOELwindows7: and the hit sound file name as well.
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

			// JOELwindows7: PAIN IS TEMPORARY, GLORY IS FOREVER. lol Wintergatan

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
				// JOELwindows7: PAIN IS TEMPORARY, GLORY IS FOREVER. lol wintergatan
				default:
					babyArrow.frames = noteskinSprite;
					if (FlxG.save.data.traceSongChart) // JOELwindows7: this is gets bigger, the bigger Chart JSON is.
						// may cause lag! turn off to have clean Trace.
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
				// JOELwindows7: execute stage script & hscript
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
			{
				babyArrow.x -= 320;

				// JOELwindows7: interupt now! We got Psyched cpu static arrow positionings in middle scroll mode. watch this!
				if (player == 0)
				{
					babyArrow.x += 320; // JOELwindows7: hey push the position back for the CPU okay.
					if (i >= 0 && i <= 1) // JOELwindows7: here 1st two of CPU arrow
					{
						babyArrow.x += 20;
					}
					else if (i >= 2 && i <= 3) // JOELwindows7: and then rest 2 of the CPU arrow.
					{
						babyArrow.x += 600;
					}
				}
			}

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
			// JOELwindows7: semi visible CPU static arrow if middle scroll
			if (index <= 3 && FlxG.save.data.middleScroll)
				babyArrow.alpha = .5;
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
			// JOELwindows7: pause credit rollout
			if (creditRollout != null)
			{
				creditRollout.pauseRolling();
			}

			if (FlxG.sound.music.playing)
			{
				FlxG.sound.music.pause();
				if (vocals != null)
					if (vocals.playing)
						vocals.pause();
				// JOELwindows7: ye
				if (vocals2 != null)
					if (vocals2.playing)
						vocals2.pause();
			}

			#if FEATURE_DISCORD
			DiscordClient.changePresence("PAUSED on "
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

			// JOELwindows7: finally, play the Pause we've generated with SFB games Chiptone.
			// playSoundEffect("PauseOpen"); // ah damn, it overlaps in unpause because this still paused due to `paused` still here!
			// inspired from A Hat in Time, because, I like AHiT yess.
		}

		// JOELwindows7: here check if the open substate is just pause or counting down. and whatever idk.
		if (!(waitLemmePrepareUnpauseFirst || PauseSubState.goToOptions))
		{
			// should be play pause open sfx here.
			// but again, it got cut off.
		}
		else
		{
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
				PauseSubState.silencePauseBeep = true;
				openSubState(new PauseSubState());
			}
			else
				openSubState(new OptionsMenu(true));
		}
		else if (waitLemmePrepareUnpauseFirst)
		{
			// JOELwindows7: appear this substate first before play again!
			openSubState(new PrepareUnpauseSubstate());
			// The Skeleton Appears
		}
		else if (paused)
		{
			// JOELwindows7: okay make mouse invisible again
			FlxG.mouse.visible = false;

			// JOELwindows7: resume credit rollout
			if (SONG.isCreditRoll)
				if (creditRollout != null)
				{
					creditRollout.resumeRolling();
				}

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
		if (endingSong)
			return;
		vocals.stop();
		vocals2.stop(); // JOELwindows7: ye
		FlxG.sound.music.stop();

		FlxG.sound.music.play();
		vocals.play();
		vocals2.play(); // JOELwindows7: ye
		FlxG.sound.music.time = Conductor.songPosition * songMultiplier;
		vocals.time = FlxG.sound.music.time;
		vocals2.time = FlxG.sound.music.time; // JOELwindows7 ye

		@:privateAccess
		{
			// JOELwindows7: add haxedef FEATURE_AUDIO_MANIPULATE if cpp desktop?
			#if FEATURE_AUDIO_MANIPULATE
			// The __backend.handle attribute is only available on native.
			lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
			if (vocals.playing)
				lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
			if (vocals2.playing) // JOELwindows7: ye
				lime.media.openal.AL.sourcef(vocals2._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
			#end
		}

		// ballsex - etterna

		#if FEATURE_DISCORD
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
	}

	function percentageOfSong():Float
	{
		return (Conductor.songPosition / songLength) * 100;
	}

	public var paused:Bool = false;
	public var waitLemmePrepareUnpauseFirst:Bool = false; // JOELwindows7: to appear substate after unpause which counts down before actually play again.

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

		// JOELwindows7: kem0x mod shader
		#if EXPERIMENTAL_KEM0X_SHADERS
		for (shader in animatedShaders)
		{
			shader.update(elapsed);
		}
		#end

		// JOELwindows7: kemox mod shader lua thingy
		#if EXPERIMENTAL_KEM0X_SHADERS
		#if FEATURE_LUAMODCHART
		if (luaModchart != null)
		{
			for (key => value in luaModchart.luaShaders)
			{
				value.update(elapsed);
			}
		}
		if (stageScript != null)
		{
			for (key => value in stageScript.luaShaders)
			{
				value.update(elapsed);
			}
		}
		#end
		if (hscriptModchart != null)
		{
			for (key => value in hscriptModchart.luaShaders)
			{
				value.update(elapsed);
			}
		}
		if (stageHscript != null)
		{
			for (key => value in stageHscript.luaShaders)
			{
				value.update(elapsed);
			}
		}
		#end

		if (!addedBotplay && FlxG.save.data.botplay)
		{
			PlayStateChangeables.botPlay = true;
			addedBotplay = true;
			add(botPlayState);
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 14000) // was there a `* songMultiplier`
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
				// JOELwindows7: help, this is complicated. idk what's going on this here.
				if (executeModHscript)
				{
					dunceNote.luaID = currentLuaIndex;
				}

				if (executeModchart || executeModHscript) // JOELwindows7: hey, hscript too pls
				{
					// #if FEATURE_LUAMODCHART //JOELwindows7: why tho? there is also hscript too.
					if (!dunceNote.isSustainNote)
						dunceNote.cameras = [camNotes];
					else
						dunceNote.cameras = [camSustains];
					// #end
				}
				else
				{
					dunceNote.cameras = [camHUD];
				}

				unspawnNotes.remove(dunceNote);
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
			// JOELwindows7: ye
			if (vocals2.playing)
				lime.media.openal.AL.sourcef(vocals2._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
		}
		#end

		if (generatedMusic)
		{
			if (songStarted && !endingSong)
			{
				// Song ends abruptly on slow rate even with second condition being deleted,
				// and if it's deleted on songs like cocoa then it would end without finishing instrumental fully,
				// so no reason to delete it at all
				// JOELwindows7: hey don't early songLength that 100 early wtf? was 100 less, now 50 less.. idk. screw this! 0?
				// JOELwindows7: end song early was here. now deleted (nvm). rely only on Music complete.
				// as you can see, there is a something. music stop, minute second counter resets. that's not reliable to measured on here.
				// requiring this exactly passes song length, while it already reset before it be seen, causes softlock. musicComplete flag raised, but the counter goes zero??
				// see that? confusing!
				if (unspawnNotes.length == 0 && notes.length == 0) // JOELwindows7: fine here music complete
				{
					// JOELwindows7: install cartoon pipehose film strip corner dot pop up and disappear after few seconds.
					if (!hasAppearedDot)
					{
						// JOELwindows7: Yes I know, redundant, because something there!
						cartoonCornerDot();

						// JOELwindows7: reset blue ball because yey we succeed
						if (isStoryMode)
						{
							// story mode
							if (!FlxG.save.data.blueballWeek)
								GameOverSubstate.resetBlueball();
							// well only if in the story mode, gamers chose to not carry them for total week.
						}
						else
						{
							// free play
							GameOverSubstate.resetBlueball();
						}
						// Oh my God, confusing complexity! my brain could not build obfuscated if else at the moment.
					}

					if (FlxG.save.data.endSongEarly ? ((FlxG.sound.music.time / songMultiplier) > (songLength - 0)) : musicCompleted)
						// JOELwindows7: was:
						// if (unspawnNotes.length == 0 && notes.length == 0 && FlxG.sound.music.time / songMultiplier > (songLength - 100))
					{
						Debug.logTrace("we're fuckin ending the song ");

						endingSong = true;
						// JOELwindows7: it was 2, now extend to 5!!! nvm, 3! yess.
						// NO MORE! there is wait for music complete 1st!

						// new FlxTimer().start(2, function(timer)
						// {
						// 	endSong();
						// });
						checkEpilogueChat(); // JOELwindows7: you sneaky little punk!
						// you have endSong just little bit earlier in case stroffs.
					}
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
				// JOELwindows7: base this on theseEvents!
				switch (i.type)
				{
					case "Scroll Speed Change":
						if (i.position <= curDecimalBeat && !pastScrollChanges.contains(i))
						{
							pastScrollChanges.push(i);
							trace("SCROLL SPEED CHANGE to " + i.value);
							newScroll = i.value;
						}
						// JOELwindows7: PAIN IS TEMPORARY, GLORY IS FOREVER. lol wintergatan
				}
			}

			if (newScroll != 0)
				PlayStateChangeables.scrollSpeed *= newScroll;
		}

		if (PlayStateChangeables.botPlay && FlxG.keys.justPressed.ONE)
			camHUD.visible = !camHUD.visible;

		if (useVideo && GlobalVideo.get() != null && !stopUpdate)
		{
			if (GlobalVideo.get().ended && !removedVideo)
			{
				remove(videoSprite);
				#if FEATURE_VLC
				// if (vlcHandler != null)
				remove(vlcHandler);
				#end
				removedVideo = true;
			}
		}
		// // JOELwindows7: VLC version
		// if (useVLC && vlcHandler != null && !stopUpdate)
		// {
		// 	#if FEATURE_VLC
		// 	remove(vlcHandler);
		// 	#end
		// 	removedVideo = true;
		// }

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

			camNotes.zoom = camHUD.zoom;
			camNotes.x = camHUD.x;
			camNotes.y = camHUD.y;
			camNotes.angle = camHUD.angle;
			camSustains.zoom = camHUD.zoom;
			camSustains.x = camHUD.x;
			camSustains.y = camHUD.y;
			camSustains.angle = camHUD.angle;
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

		if (FlxG.keys.justPressed.NINE)
			iconP1.swapOldIcon();

		// JOELwindows7: update heartbeat moments
		// updateHeartbeat();
		manageHeartbeats(elapsed);

		if (curBeat > 8)
		{
			// JOELwindows7: invisiblize watermark after 8 curBeat
			// to prevent view obstruction
			reuploadWatermark.visible = false;
		}

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
			// JOELwindows7: only pause also if note not yet complete. skip song if all note played
			if (getAllNotePlayed())
			{
				musicCompleted = true;
				havePausened = false;
				return;
			}
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				trace('GITAROO MAN EASTER EGG');
				// FlxG.switchState(new GitarooPause());
				switchState(new GitarooPause()); // JOELwindows7: use YinYang48 Kade Hex version
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
				// JOELwindows7: VLC stop!
				#if FEATURE_VLC
				if (vlcHandler != null)
					vlcHandler.kill();
				// remove(videoSprite);
				remove(vlcHandler);
				#end
				remove(videoSprite);
				removedVideo = true;
			}
			cannotDie = true;
			removeTouchScreenButtons();

			// FlxG.switchState(new WaveformTestState());
			switchState(new WaveformTestState()); // JOELwindows7: use Kade + YinYang48 Hex yess
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

		if (FlxG.keys.justPressed.SEVEN && songStarted)
			// JOELwindows7: have debug sevened, for chart option in pause menu maybe
			// lol comment necklace!
			// THERE YOU ARE. desmo lol
		{
			songMultiplier = 1;
			if (useVideo)
			{
				GlobalVideo.get().stop();
				remove(videoSprite);
				// JOELwindows7: VLC stop!
				#if FEATURE_VLC
				if (vlcHandler != null)
					vlcHandler.kill();
				// remove(videoSprite);
				remove(vlcHandler);
				#end
				removedVideo = true;
			}
			cannotDie = true;
			removeTouchScreenButtons();

			// FlxG.switchState(new ChartingState());
			switchState(new ChartingState()); // JOELwindows7: use new Hex version
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

		var iconLerp = 0.5;
		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, iconLerp)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, iconLerp)));

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
				// JOELwindows7: VLC stop!
				#if FEATURE_VLC if (vlcHandler != null)
					vlcHandler.kill(); #end // JOELwindows7: FEAR_VLC?!??! wtf, Copilot?!?!?
				remove(videoSprite);
				removedVideo = true;
			}

			removeTouchScreenButtons();
			// FlxG.switchState(new AnimationDebug(dad.curCharacter));
			switchState(new AnimationDebug(dad.curCharacter)); // JOELwindows7: use Kade + YinYang48 Hex yess
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
					// JOELwindows7: VLC stop!
					#if FEATURE_VLC
					if (vlcHandler != null)
						vlcHandler.kill();
					#end
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
				// FlxG.switchState(new StageDebugState(Stage.curStage, gf.curCharacter, boyfriend.curCharacter, dad.curCharacter));
				switchState(new StageDebugState(Stage.curStage, gf.curCharacter, boyfriend.curCharacter,
					dad.curCharacter)); // JOELwindows7: use Kade + YinYang48 Hex yess
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
			// FlxG.switchState(new AnimationDebug(boyfriend.curCharacter));
			switchState(new AnimationDebug(boyfriend.curCharacter)); // JOELwindows7: use Kade + YinYang48 Hex yess
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
				vocals2.pause(); // JOELwindows7: ye
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
				// JOELwindows7: ye
				vocals2.time = Conductor.songPosition;
				vocals2.play();
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
			vocals2.pause(); // JOELwindows7: ye
			Conductor.songPosition = skipTo;
			Conductor.rawPosition = skipTo;

			FlxG.sound.music.time = Conductor.songPosition;
			FlxG.sound.music.play();

			vocals.time = Conductor.songPosition;
			vocals.play();
			// JOELwindows7: ye
			vocals2.time = Conductor.songPosition;
			vocals2.play();
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
			Conductor.songPosition += FlxG.elapsed * 1000; // JOELwindows7: pinpoint! times 1000 for accumulating songPosition.
			Conductor.rawPosition = FlxG.sound.music.time;

			// sync

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

				// JOELwindows7: sneaky sneaky songName thingy
				if (FlxG.save.data.songPosition)
					songName.text = SONG.artist + " - " + SONG.songName + ' (' + FlxStringUtil.formatTime((songLength - secondsTotal), false) + ')';
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
						// JOELwindows7: frogot change convention to all lmao!!
						// case 'Philly Nice':
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
								// JOELwindows7: TEMP hardcode hard code coding for Blammed Light
								// not here, use beat hit!
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

				camFollow.x += dad.camFollow[0];
				camFollow.y += dad.camFollow[1];
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
						case 'school' | 'schoolEvil':
							camFollow.x = boyfriend.getMidpoint().x - 300;
							camFollow.y = boyfriend.getMidpoint().y - 300;
					}

				camFollow.x += boyfriend.camFollow[0];
				camFollow.y += boyfriend.camFollow[1];
			}
		}

		if (camZooming)
		{
			if (FlxG.save.data.zoom < 0.8)
				FlxG.save.data.zoom = 0.8;

			if (FlxG.save.data.zoom > 1.2)
				FlxG.save.data.zoom = 1.2;

			// JOELwindows7: make sure to choose using zoom save data only if no modchart are ON.
			if (!(executeModchart || executeModHscript || executeStageScript || executeStageHscript))
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
		FlxG.watch.addQuick("shinzouRateShit", [dad.getHeartRate(-1), gf.getHeartRate(-1), boyfriend.getHeartRate(-1)]);
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

		// JOELwindows7: bruh, don't forget new convention lol
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
				vocals2.stop(); // JOELwindows7: ye
				FlxG.sound.music.stop();

				if (FlxG.save.data.InstantRespawn)
				{
					// FlxG.switchState(new PlayState());
					switchState(new PlayState()); // JOELwindows7: use hex weekend version Kade + YinYang48
				}
				else
				{
					openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				}

				// JOELwindows7: modchart gameover pls
				#if FEATURE_LUAMODCHART
				if (executeModchart && luaModchart != null)
				{
					luaModchart.setVar('inGameOver', true);
				}
				if (executeStageScript && stageScript != null)
				{
					stageScript.setVar('inGameOver', true);
				}
				#end
				// JOELwindows7: hscriptoid gameover
				if (executeModHscript && hscriptModchart != null)
				{
					hscriptModchart.setVar('inGameOver', true);
				}
				if (executeStageHscript && stageHscript != null)
				{
					stageHscript.setVar('inGameOver', true);
				}

				// JOELwindows7: whyn't stop
				vocals.stop();
				vocals2.stop(); // JOELwindows7: ye
				FlxG.sound.music.stop();

				#if FEATURE_DISCORD
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("GAME OVER -- "
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
				vocals2.stop(); // JOELwindows7: ye
				FlxG.sound.music.stop();

				if (FlxG.save.data.InstantRespawn)
				{
					// FlxG.switchState(new PlayState());
					switchState(new PlayState()); // JOELwindows7: use hex weekend version Kade + YinYang48
				}
				else
				{
					openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y, unspawnNotes, playerStrums.members));
				}

				// JOELwindows7: modchart gameover pls psychedly
				#if FEATURE_LUAMODCHART
				if (executeModchart && luaModchart != null)
				{
					luaModchart.setVar('inGameOver', true);
				}
				if (executeStageScript && stageScript != null)
				{
					stageScript.setVar('inGameOver', true);
				}
				#end
				// JOELwindows7: hscriptoid gameover
				if (executeModHscript && hscriptModchart != null)
				{
					hscriptModchart.setVar('inGameOver', true);
				}
				if (executeStageHscript && stageHscript != null)
				{
					stageHscript.setVar('inGameOver', true);
				}

				// JOELwindows7: whyn't stop
				vocals.stop();
				vocals2.stop(); // JOELwindows7: ye
				FlxG.sound.music.stop();

				#if FEATURE_DISCORD
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("GAME OVER -- "
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

					if (daNote.noteType != 2 || FlxG.random.bool(PlayStateChangeables.stupidityChances[1]))
					{ // JOELwindows7: do not step mine! player2
						// if stupidity chance is true, hit anyway.
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
								if (SONG.needsVoices2)
									vocals2.volume = 1; // JOELwindows7: ye
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
							if (SONG.needsVoices2)
								vocals2.volume = 1; // JOELwindows7 : ye
						}
						daNote.active = false;

						if (!daNote.isSustainNote)
						{
							successfullyStep(1, daNote); // JOELwindows7:successfully step for p2
						}

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
					else
					{
						// JOELwindows7: this is mine skipped
						daNote.active = false;

						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();
						});
					}

					/*
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					 */
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

				// JOELwindows7: moverd hscript & also alpha note pls
				if (!daNote.mustPress && FlxG.save.data.middleScroll && !(executeModchart || executeModHscript))
					daNote.alpha = 0.5; // JOELwindows7: was 0

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
							// trace("Sneaked past the mine whew");
						}
						if (daNote.noteType == 1 || daNote.noteType == 0)
							if (loadRep && daNote.isSustainNote)
							{
								// im tired and lazy this sucks I know i'm dumb
								if (findByTime(daNote.strumTime) != null)
									totalNotesHit += 1;
								else
								{
									vocals.volume = 0;
									// JOELwindows7: vocals2 not need vol 0
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
											misses++;
											updateAccuracy();
											health -= 0.15;
										}
									}
								}
							}
							else
							{
								vocals.volume = 0;
								// JOELwindows7: vocals2 no need vol 0
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
										misses++;
										updateAccuracy();
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

		#if debug
		// skip song
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end

		super.update(elapsed);

		// JOELwindows7: MOAR FUNCTION OF UPDATE. use wisely!
		// manageHeartbeats(elapsed); // no, it's already up there. NVM no need.
	}

	// JOELwindows7: check if the song should display epilogue chat once the song has finished.
	function checkEpilogueChat():Void
	{
		if (creditRollout != null)
			creditRollout.stopRolling();
		endingSong = true; // Just in case somekind of forgor
		songStarted = false; // try to do this?
		// startingSong = true; //Oh maybe this helps simulate like if the song is on preparation?
		finishingSong = true; // fine let's phreaking do redundancy.
		// FlxG.sound.music.stop(); // Stop the music now man.
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
			// JOELwindows7: VLC stop!
			#if FEATURE_VLC
			if (vlcHandler != null)
				vlcHandler.kill();
			PlayState.instance.remove(PlayState.instance.vlcHandler);
			#end
		}

		if (!loadRep)
		{
			if (!PlayStateChangeables.botPlay) // JOELwindows7: and don't save replay if botplay yess. waste of disk space! Terrabyte is premium!
				rep.SaveReplay(saveNotes, saveJudge, replayAna);
		}
		else
		{
			PlayStateChangeables.botPlay = false;
			PlayStateChangeables.scrollSpeed = 1 / songMultiplier;
			PlayStateChangeables.useDownscroll = false;
		}

		if (FlxG.save.data.fpsCap > Perkedel.MAX_FPS_CAP) // JOELwindows7: was 290
		{
			Debug.logTrace("return the FPS cap");
			// JOELwindows7: issue with Android version. cast lib current technic crash it
			#if FEATURE_DISPLAY_FPS_CHANGE
			// (cast(Lib.current.getChildAt(0), Main)).setFPSCap(290);
			#end
		}

		/*
			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
			{
				luaModchart.executeState("songEnd", []); // JOELwindows7: gotta call one last thing before you unload it.
				luaModchart.die();
				luaModchart = null;
			}
			if (stageScript != null)
			{
				stageScript.executeState("songEnd", []); // JOELwindows7: gotta call one last thing before you unload it.
				stageScript.die();
				stageScript = null;
			}
			#end
			if (hscriptModchart != null)
			{
				hscriptModchart.executeState("songEnd", []); // JOELwindows7: gotta call one last thing before you unload it.
			}
			if (stageHscript != null)
			{
				stageHscript.executeState("songEnd", []); // JOELwindows7: gotta call one last thing before you unload it.
			}
			scronchHscript();
		 */

		// JOELwindows7: instead just
		#if FEATURE_LUAMODCHART
		if (luaModchart != null)
		{
			luaModchart.executeState("songEnd", []); // JOELwindows7: gotta call one last thing before you unload it.
		}
		if (stageScript != null)
		{
			stageScript.executeState("songEnd", []); // JOELwindows7: gotta call one last thing before you unload it.
		}
		#end
		if (hscriptModchart != null)
		{
			hscriptModchart.executeState("songEnd", []); // JOELwindows7: gotta call one last thing before you unload it.
		}
		if (stageHscript != null)
		{
			stageHscript.executeState("songEnd", []); // JOELwindows7: gotta call one last thing before you unload it.
		}

		// JOELwindows7: stuff to end
		if (creditRollout != null)
		{
			creditRollout.stopRolling(); // end the credit roll first.
		}

		trace("clearing gameplay"); // JOELwindows7: you trace

		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals2.volume = 0; // JOELwindows7: ye
		FlxG.sound.music.stop();
		// FlxG.sound.music.stop(); // JOELwindows7: Woha do not stop music because there is delay defined in the song!
		vocals.stop(); // JOELwindows7: Woha do not stop vocal because there is delay defined in the song! nvm
		vocals2.stop(); // JOELwindows7: Woha do not stop vocal because there is delay defined in the song! nvm ye
		if (SONG.validScore)
		{
			#if !switch
			Highscore.saveScore(PlayState.SONG.songId, Math.round(songScore), storyDifficulty);
			Highscore.saveCombo(PlayState.SONG.songId, Ratings.GenerateLetterRank(accuracy), storyDifficulty);
			#end
		}

		if (offsetTesting)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			offsetTesting = false;
			// LoadingState.loadAndSwitchState(new OptionsMenu());
			switchState(new OptionsMenu(), true, true, true, true); // JOELwindows7: hex switch state lol
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
			// FlxG.switchState(new StageDebugState(Stage.curStage));
			switchState(new StageDebugState(Stage.curStage)); // JOELwindows7: hex switch state lol
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
				var lastSonginPlaylist = PlayState.storyPlaylist[0]; // raw SONG id.
				// PAIN IS TEMPORARY, GLORY IS FOREVER. lol wintergatan

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0) // when all song in this week finished
				{
					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;

					paused = true;

					// JOELwindows7: delay time before go to next song
					// var delayFirstBeforeThat:Float = SONG.delayAfterFinish;
					var delayFirstBeforeThat:Float = 0; // no more delay
					// for that eggnog light shut off thingy e.g.

					FlxG.sound.music.stop();
					vocals.stop();
					vocals2.stop(); // JOELwindows7: ye
					// JOELwindows7: here timer guys
					outroScene(lastSonginPlaylist, false, delayFirstBeforeThat, SONG.hasEpilogueVideo, SONG.epilogueVideoPath, SONG.hasEpilogueTankmanVideo,
						SONG.epilogueTankmanVideoPath);
					// outroScene(lastSonginPlaylist);
					// new FlxTimer().start(delayFirstBeforeThat, function(tmr:FlxTimer)
					// {
					// 	if (FlxG.save.data.scoreScreen)
					// 	{
					// 		if (FlxG.save.data.songPosition)
					// 		{
					// 			FlxTween.tween(songPosBar, {alpha: 0}, 1);
					// 			FlxTween.tween(bar, {alpha: 0}, 1);
					// 			FlxTween.tween(songName, {alpha: 0}, 1);
					// 		}
					// 		openSubState(new ResultsScreen(SONG.hasEpilogueVideo, SONG.hasEpilogueVideo ? SONG.epilogueVideoPath : "null"));
					// 		new FlxTimer().start(1, function(tmr:FlxTimer)
					// 		{
					// 			inResults = true;
					// 		});
					// 	}
					// 	else
					// 	{
					// 		GameplayCustomizeState.freeplayBf = 'bf';
					// 		GameplayCustomizeState.freeplayDad = 'dad';
					// 		GameplayCustomizeState.freeplayGf = 'gf';
					// 		GameplayCustomizeState.freeplayNoteStyle = 'normal';
					// 		GameplayCustomizeState.freeplayStage = 'stage';
					// 		GameplayCustomizeState.freeplaySong = 'bopeebo';
					// 		GameplayCustomizeState.freeplayWeek = 1;
					// 		FlxG.sound.playMusic(Paths.music('freakyMenu'));
					// 		Conductor.changeBPM(102);
					// 		// FlxG.switchState(new StoryMenuState());
					// 		FlxG.switchState(SONG.hasEpilogueVideo ? VideoCutscener.getThe(SONG.epilogueVideoPath,
					// 			new StoryMenuState()) : new StoryMenuState());
					// 		// JOELwindows7: complicated! oh MY GOD!
					// 		clean();
					// 	}
					// });
					// JOELwindows7: clean was here, but now inside that?!

					/*
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
					 */

					if (SONG.validScore)
					{
						// AchievementUnlocked.whichIs("anSpook"); //JOELwindows7: achievement unlocked beat week
						checkWeekComplete();
						Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
					}

					StoryMenuState.resetWeekSave(); // JOELwindows7: reset week save state
					StoryMenuState.unlockNextWeek(storyWeek);
				}
				else
				{
					StoryMenuState.saveWeek(false); // JOELwindows7: okay, save state the week pls!

					var diff:String = ["-easy", "", "-hard"][storyDifficulty];

					Debug.logInfo('PlayState: Loading next story song ${PlayState.storyPlaylist[0]}-${diff}');

					// JOELwindows7: delay time before go to next song
					// var delayFirstBeforeThat:Float = SONG.delayAfterFinish;
					var delayFirstBeforeThat:Float = 0; // no more delay
					// for that eggnog light shut off thingy e.g.

					// JOELwindows7: wait a minute sir. the song name
					// has already removed from playlist bruh!
					// this then starts on Cocoa instead of supposed eggnog!
					// if (StringTools.replace(PlayState.storyPlaylist[0], " ", "-").toLowerCase() == 'eggnog')
					if (lastSonginPlaylist == 'eggnog') // Now this should fix it I guess. Not elegant but it works.
					{
						// var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						// 	-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						// blackShit.scrollFactor.set();
						// add(blackShit);
						// camHUD.visible = false;

						// FlxG.sound.play(Paths.sound('Lights_Shut_off'));
						// JOELwindows7: moved!
					}
					// outroScene(lastSonginPlaylist);
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
					vocals.stop();
					vocals2.stop(); // JOELwindows7: ye

					// JOELwindows7: log this one in will ya?
					Debug.logTrace("Here's path for this outro " + epilogueVideoPath + "\n and next song intro " + SONG.videoPath);
					Debug.logInfo("Here's path for this outro " + epilogueVideoPath + "\n and next song intro " + SONG.videoPath);
					Debug.logTrace("and outro is enabled " + Std.string(hasEpilogueVideo) + "and next song intro enabled" + SONG.hasVideo);
					Debug.logInfo("and outro is enabled " + Std.string(hasEpilogueVideo) + "and next song intro enabled" + SONG.hasVideo);

					// JOELwindows7: here timer guys
					// new FlxTimer().start(delayFirstBeforeThat, function(tmr:FlxTimer)
					// {
					// 	// JOELwindows7: if has video, then load the video first before going to new playstate!
					// 	LoadingState.loadAndSwitchState(hasEpilogueVideo ? (VideoCutscener.getThe(epilogueVideoPath,
					// 		(SONG.hasVideo ? VideoCutscener.getThe(SONG.videoPath,
					// 			new PlayState()) : new PlayState()))) : (SONG.hasVideo ? VideoCutscener.getThe(SONG.videoPath,
					// 			new PlayState()) : new PlayState()));
					// 	// LoadingState.loadAndSwitchState(new PlayState()); //Legacy
					// 	// JOELwindows7: oh God, so complicated. I hope it works!
					// 	clean();
					// });
					outroScene(lastSonginPlaylist, true, delayFirstBeforeThat, hasEpilogueVideo, epilogueVideoPath, SONG.hasEpilogueTankmanVideo,
						SONG.epilogueTankmanVideoPath);
				}
			}
			else
			{
				Debug.logInfo('WENT BACK TO FREEPLAY??');
				// var delayFirstBeforeThat:Float = SONG.delayAfterFinish; // JOELwindows7: forgor
				var delayFirstBeforeThat:Float = 0; // JOELwindows7: no more delay.

				new FlxTimer().start(delayFirstBeforeThat, function(tmr:FlxTimer)
				{ // JOELwindows7: here this delay wow.
					paused = true;

					FlxG.sound.music.stop();
					vocals.stop();
					vocals2.stop(); // JOELwindows7: ye

					// JOELwindows7: don't forget clean modchart if haven't already
					scronchLuaScript();
					scronchHscript();

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
						// FlxG.switchState(new FreeplayState());
						switchState(new FreeplayState()); // JOELwindows7: hex switch state lol
						clean();
					}
				});
			}
		}

		// JOELwindows7: stuffening
		touchedSongComplete();
	}

	public var endingSong:Bool = false;
	public var musicCompleted:Bool = false; // JOELwindows7: sigh, I guess we got to resort on it this instead. check if music is actually completed

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
		vocals2.volume = 1; // JOELwindows7: ye
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
		var daRatingInt = Ratings.judgeNoteInt(noteDiff); // JOELwindows7: this is the rating integer

		switch (daRating)
		{
			case 'shit':
				// JOELwindows7: add da noteType effex
				// wait sir, play the sound in successfully step instead!
				if (daNote.noteType == 2) // hit mine duar
				{
					health -= 1;
					// playSoundEffect("mine-duar", 1, 'shared');
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
					health -= 1;
					// playSoundEffect("mine-duar", 1, 'shared');
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
					health -= 1;
					// playSoundEffect("mine-duar", 1, 'shared');
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
					health -= 1;
					// playSoundEffect("mine-duar", 1, 'shared');
				}
				if (daNote.noteType == 1 || daNote.noteType == 0)
				{
					if (health < 2)
						health += 0.04;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 1;
					sicks++;
				}
				// TODO: JOELwindows7: add more insane ratings!
		}

		// JOELwindows7: yoink splash notes. idk where the peck suppose we get the asset from
		// because these baa..... I mean.. whatever, did not license it royalty free / free culture compliant!!! I hate that!
		// yoink from Psych https://github.com/ShadowMario/FNF-PsychEngine/blob/main/source/PlayState.hx
		// pls draw me royalty free notesplash for me for $0! jk, don't have to. I need time alot to do that.
		// but feel free to become generous yeah!
		// if (daRating == 'sick' && !daNote.noteSplashDisabled)
		if (daRatingInt >= 3 && !daNote.noteSplashDisabled)
		{
			spawnNoteSplashOnNote(daNote, daNote.noteType, 0, daRatingInt);
		}
		spawnNoteHitlineOnNote(daNote, daNote.noteType, 0, daRatingInt);
		// C'mon, Cam (ninjamuffin)!!! finish embargo rn!!! do not finish plot twistly as a demo for the full ass!!! that's rude!

		if (songMultiplier >= 1.05)
			score = getRatesScore(songMultiplier, score);

		// trace('Wife accuracy loss: ' + wife + ' | Rating: ' + daRating + ' | Score: ' + score + ' | Weight: ' + (1 - wife));

		if ((daRating != 'shit' || daRating != 'bad')
			&& !(daNote.noteType == 2)) // JOELwindows7: do not count if note type is mine or powerup i guess.
		{
			songScore += Math.round(score);

			// JOELwindows7: Try to tween that scoreTxt up
			// Psychedly yoinked from https://github.com/ShadowMario/FNF-PsychEngine/blob/main/source/PlayState.hx
			if (FlxG.save.data.scoreTxtZoom)
			{
				if (scoreTxtTween != null)
				{
					scoreTxtTween.cancel();
				}
				scoreTxt.scale.x = 1.075;
				scoreTxt.scale.y = 1.075;
				scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
					onComplete: function(twn:FlxTween)
					{
						scoreTxtTween = null;
					}
				});
			}

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

			// TODO: JOELwindows7: marker of late & early. either of these:
			// - Tilt ranking sprite particle left & right
			// - Trapesium particle above & bellow
			rating.loadGraphic(Paths.loadImage(pixelShitPart1 + daRating + pixelShitPart2, pixelShitPart3));
			rating.screenCenter();
			rating.y -= 50;
			rating.x = coolText.x - 125;
			// JOELwindows7: I notice there is no "MISS" particles here.

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
				var directionsAccounted:Array<Bool> = [false, false, false, false]; // we don't want to do judgements for more than one presses

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
						if (daNote.noteType != 2)
						{ // JOELwindows7: do not hit mine!!! also if power up there, do not hit negative powerup!
							goodNoteHit(daNote);
							boyfriend.holdTimer = 0;
						}
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
	public var useVLC = false; // JOELwindows7 marking for it.

	public static var webmHandler:WebmHandler;

	#if FEATURE_VLC
	public var vlcHandler:MP4Sprite; // JOELwindows7: globalize VLC handler

	#end
	public var playingDathing = false;

	public var videoSprite:FlxSprite;

	public function backgroundVideo(source:String) // for background videos
	{
		#if FEATURE_VLC
		// JOELwindows7: from that BrightFyre MP4 support, outputting to FlxSprite
		// https://github.com/brightfyregit/Friday-Night-Funkin-Mp4-Video-Support#outputting-to-a-flxsprite
		useVideo = true;
		useVLC = true; // JOELwindows7: yes VLC
		#end

		var ourSource:String = "assets/videos/daWeirdVid/dontDelete.webm";

		#if FEATURE_VLC
		vlcHandler = new MP4Sprite(-470, -30);
		vlcHandler.finishCallback = onVideoSpriteFinish;
		// vlcHandler.playMP4(source, null, videoSprite); // make the transition null so it doesn't take you out of this state
		vlcHandler.playVideo(source, false, false); // make the transition null so it doesn't take you out of this state

		// videoSprite.setGraphicSize(Std.int(videoSprite.width * 1.2));
		vlcHandler.setGraphicSize(Std.int(vlcHandler.width * 1.2));

		remove(gf);
		remove(boyfriend);
		remove(dad);
		// add(videoSprite);
		add(vlcHandler);
		add(gf);
		add(boyfriend);
		add(dad);

		Debug.logInfo('poggers');

		if (!songStarted)
			vlcHandler.pause();
		else
			vlcHandler.resume();
		#elseif (FEATURE_WEBM && !FEATURE_VLC)
		useVideo = true;
		useVLC = false; // JOELwindows7: not VLC

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

		// JOELwindows7: set var of those modcharts!
		#if FEATURE_LUAMODCHART
		if (executeModchart && luaModchart != null)
		{
			luaModchart.setVar('accuracy', accuracy);
		}
		if (executeStageScript && stageScript != null)
		{
			stageScript.setVar('accuracy', accuracy);
		}
		#end
		if (executeModHscript && hscriptModchart != null)
		{
			hscriptModchart.setVar('accuracy', accuracy);
		}
		if (executeStageHscript && stageHscript != null)
		{
			stageHscript.setVar('accuracy', accuracy);
		}

		// JOELwindows7: here's where we moved. the bottom score text
		scoreTxt.text = Ratings.CalculateRanking(songScore, songScoreDef, nps, maxNPS,
			(FlxG.save.data.roundAccuracy ? FlxMath.roundDecimal(accuracy, 0) : accuracy), boyfriend.getHeartRate(0), boyfriend.getHeartTier(0));
		// JOELwindows7: wai wait! Custom sponsor word. ... I mean judgement words. here this too!
		// judgementCounter.text = 'Sicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\nMisses: ${misses}';
		judgementCounter.text = '${judgementWords[4]}: ${sicks}\n${judgementWords[3]}: ${goods}\n${judgementWords[2]}: ${bads}\n${judgementWords[1]}: ${shits}\n${judgementWords[0]}: ${misses}';
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
				// JOELwindows7: Pinpoint! if you want Pump it Up rapid combo
				// add even sustain note, this is where you consider it.
				combo += 1;
				popUpScore(note);

				// JOELwindows7: Hit sound like osu!
				// if (FlxG.save.data.hitsound)
				// {
				// 	// allow custom hitsound just like in osu! and also testables in charting state right away.
				// 	FlxG.sound.play(Paths.sound((note.hitsoundPath != null && note.hitsoundPath != "")? note.hitsoundPath : 'SNAP', 'shared'));
				// }
			}
			else
			{
				// TODO: JOELwindows7: if Pump it Up rapid combo is active, then increase combo still even if sustain note
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
				successfullyStep(0, note);
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
		if (Conductor.songPosition * songMultiplier > FlxG.sound.music.time + 25
			|| Conductor.songPosition * songMultiplier < FlxG.sound.music.time - 25)
		{
			resyncVocals();
		}

		// JOELwindows7: incoming, week 7 yoink yey! luckydog7
		// picoSpeaker and running tankmen

		if (SONG.songId.toLowerCase() == 'stress')
		{
			// RIGHT
			for (i in 0...Stage.picoStep.right.length)
			{
				if (curStep == Stage.picoStep.right[i])
				{
					gf.playAnim('shoot' + FlxG.random.int(1, 2), true);
					// var tankmanRunner:TankmenBG = new TankmenBG();
				}
			}
			// LEFT
			for (i in 0...Stage.picoStep.left.length)
			{
				if (curStep == Stage.picoStep.left[i])
				{
					gf.playAnim('shoot' + FlxG.random.int(3, 4), true);
				}
			}
			// Left tankspawn
			for (i in 0...Stage.tankStep.left.length)
			{
				if (curStep == Stage.tankStep.left[i])
				{
					var tankmanRunner:TankmenBG = new TankmenBG();
					tankmanRunner.resetShit(FlxG.random.int(630, 730) * -1, 255, true, 1, 1.5);

					Stage.tankmanRun.add(tankmanRunner);
				}
			}

			// Right spawn
			for (i in 0...Stage.tankStep.right.length)
			{
				if (curStep == Stage.tankStep.right[i])
				{
					var tankmanRunner:TankmenBG = new TankmenBG();
					tankmanRunner.resetShit(FlxG.random.int(1500, 1700) * 1, 275, false, 1, 1.5);
					Stage.tankmanRun.add(tankmanRunner);
				}
			}
		}

		if (dad.curCharacter == 'tankman' && SONG.songId == 'stress')
		{
			if (curStep == 735)
			{
				dad.addOffset("singDOWN", 45, 20);
				dad.animation.getByName('singDOWN').frames = dad.animation.getByName('prettyGoodAnim').frames;
				dad.playAnim('prettyGoodAnim', true);
			}

			if (curStep == 736 || curStep == 737)
			{
				dad.playAnim('prettyGoodAnim', true);
			}

			if (curStep == 767)
			{
				dad.addOffset("singDOWN", 98, -90);
				dad.animation.getByName('singDOWN').frames = dad.animation.getByName('oldSingDOWN').frames;
			}
		}

		if (dad.curCharacter == 'tankman' && SONG.songId == 'ugh')
		{
			if (curStep == 59 || curStep == 443 || curStep == 523 || curStep == 827)
			{
				dad.addOffset("singUP", 45, 0);

				dad.animation.getByName('singUP').frames = dad.animation.getByName('ughAnim').frames;
			}
			if (curStep == 64 || curStep == 448 || curStep == 528 || curStep == 832)
			{
				dad.addOffset("singUP", 24, 56);
				dad.animation.getByName('singUP').frames = dad.animation.getByName('oldSingUP').frames;
			}
		}
		// if (SONG.songId == 'test')
		// {
		// 	if (boyfriend.animation.curAnim.name == 'singRIGHT')
		// 	{
		// 		boyfriend2.playAnim('singLEFT', false);
		// 	}
		// 	if (boyfriend.animation.curAnim.name == 'singUP')
		// 	{
		// 		boyfriend2.playAnim('singDOWN', false);
		// 	}
		// 	if (boyfriend.animation.curAnim.name == 'singLEFT')
		// 	{
		// 		boyfriend2.playAnim('singRIGHT', false);
		// 	}
		// 	if (boyfriend.animation.curAnim.name == 'singDOWN')
		// 	{
		// 		boyfriend2.playAnim('singUP', false);
		// 	}
		// 	if (boyfriend.animation.curAnim.name == 'idle')
		// 	{
		// 		boyfriend2.playAnim('idle');
		// 	}
		// 	if (dad.animation.curAnim.name == 'idle')
		// 	{
		// 		pixel2.playAnim('idle');
		// 	}
		// 	if (dad.animation.curAnim.name == 'singDOWN')
		// 	{
		// 		pixel2.playAnim('singUP', false);
		// 	}
		// 	if (dad.animation.curAnim.name == 'singLEFT')
		// 	{
		// 		pixel2.playAnim('singRIGHT', false);
		// 	}
		// 	if (dad.animation.curAnim.name == 'singRIGHT')
		// 	{
		// 		pixel2.playAnim('singLEFT', false);
		// 	}
		// 	if (dad.animation.curAnim.name == 'singUP')
		// 	{
		// 		pixel2.playAnim('singDOWN', false);
		// 	}
		// }
		// end yoink week 7

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

		// JOELwindows7: here event object that meant to be beat hit rather than precise or section next (scroll speed change e.g.).
		// wait, how about put this in Step? this one is more precise... idk.
		if (SONG != null && SONG.eventObjects != null)
			for (i in SONG.eventObjects)
			{
				if (i.position == HelperFunctions.truncateFloat(curDecimalBeat, 3)
					|| Std.int(i.position) == curBeat) // JOELwindows7: can we do it like this instead? because the evaluation for these are essentially be the same.
				{
					// JOELwindows7: base this on theseEvents!
					switch (i.type)
					{
						// JOELwindows7: moar effeks. do not forget check position with curDecimalBeat (precise) / curBeat (exact) first!
						case "Cheer Now":
							justCheer(true);
						case "Hey Now":
							justHey(true);
						case "Cheer Hey Now":
							if (i.value == 0 || i.value == 1 || i.value > 2 || i.value < 0)
								justCheer(true);
							if (i.value == 0 || i.value == 2 || i.value > 2 || i.value < 0)
								justHey(true);
						case "Lightning Strike":
							Stage.lightningStrikeShit();
						case "Blammed Lights":
							Stage.blammedLights(Std.int(i.value));
						case "Appear Blackbar":
							// Debug.logTrace("appear blackbar");
							Stage.appearBlackBar(i.value);
						case "Disappear Blackbar":
							// Debug.logTrace("disappear blackbar");
							Stage.disappearBlackBar(i.value);

						case "Camera Zoom in":
							camZoomNow(i.value, i.value2, i.value3);
						case "Shake camera":
							FlxG.camera.shake(i.value, i.value2, function()
							{
							}, true);
							Controls.vibrate(0, i.value);

						case "HUD Zoom in":
							camZoomNow(0, i.value);
						case "Both Zoom in":
							camZoomNow(i.value, i.value);
						case "LED ON for":
						// JOELwindows7: turn LED on for how long second i.value

						case "Vibrate for":
							Controls.vibrate(0, i.value, i.value2);
					}
				}
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
			else if (curBeat % idleBeat != 0)
			{
				if (boyfriend.isDancing && !boyfriend.animation.curAnim.name.startsWith('sing'))
					boyfriend.dance(forcedToIdle, currentSection.CPUAltAnim);
				if (dad.isDancing && !dad.animation.curAnim.name.startsWith('sing'))
					dad.dance(forcedToIdle, currentSection.CPUAltAnim);
			}
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

			if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0 && !inCutscene && !inResults) // JOELwindows7: make sure not when in cutscene or result.
			{
				FlxG.camera.zoom += 0.015 / songMultiplier;
				camHUD.zoom += 0.03 / songMultiplier;
			}
		}

		// JOELwindows7: HARDCODING FOR BLAMMED LIGHT
		// JOELwindows7: TEMP hardcode hard code coding for Blammed Light
		// due to bug in HaxeScript unfortunately
		/*
			if (curSong.toLowerCase() == 'blammed')
			{
				if (curBeat >= 128 && curBeat < 192)
				{
					// ON
					if (curBeat % 4 == 0)
						Stage.blammedLights(6);
				}
				else if (curBeat == 192)
				{
					// OFF
					Stage.blammedLights(0);
				}
			}
		 */

		if (songMultiplier == 1)
		{
			iconP1.setGraphicSize(Std.int(iconP1.width + 45));
			iconP2.setGraphicSize(Std.int(iconP2.width + 45));

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

				// Some how the hey works again lmao idk how.
				// NOW IT DOESN'T!!! WTF?!??!?
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

				if (vocals2.volume != 0)
				{
					// JOELwindows7: just in case you need this too. idk.
				}
				else
				{
				}
			}

			if (PlayStateChangeables.Optimize)
			{
				if (vocals.volume == 0 && !currentSection.mustHitSection)
					vocals.volume = 1;
				// JOELwindows7: ye
				if (vocals2.volume == 0 && !currentSection.mustHitSection)
					vocals2.volume = 1;
			}

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

	/**
	 * @deprecated a newer heartbeat fetish system has been moved to inside Character
	 */
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
			trace(SONG.player1 + " heart error " + e + ": " + e.message);
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
			trace(SONG.player2 + " heart error " + e + ": " + e.message);
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
			trace(SONG.gfVersion + " heart error " + e + ": " + e.message);
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

	/**
	 * @deprecated a newer heartbeat fetish system has already moved to inside Character class.
	 */
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

	// JOELwindows7: when successfully step
	function successfullyStep(whichOne:Int = 0, ?handoverNote:Note)
	{
		// JOELwindows7: Hit sound like osu!
		if (FlxG.save.data.hitsound)
		{
			// allow custom hitsound just like in osu! and also testables in charting state right away.
			if (handoverNote != null)
			{
				// FlxG.sound.play(Paths.sound((handoverNote.hitsoundPath != null && handoverNote.hitsoundPath != "") ? handoverNote.hitsoundPath : 'SNAP',
				// 	'shared'));
				try
				{
					playSoundEffect(((handoverNote.hitsoundPath != null && handoverNote.hitsoundPath != "" && handoverNote.hitsoundPath != '0') ? handoverNote.hitsoundPath : 'SNAP'),
						1, 'shared');
					if (handoverNote.noteType == 2)
					{
						playSoundEffect("mine-duar", 1, 'shared'); // duar! you stepped on mine!
					}
				}
				catch (e)
				{
					// null object reference
				}
			}
		}

		// option only for specific player
		switch (whichOne)
		{
			case 0:
				// boyfriend.playAnim('hit', true);
				// break;
				// notesplash no needed because previous good note hit handler had it. only splash if SICK (PERFECT) and beyond.
				// boyfriend.stimulateHeart(-1, HeartStimulateType.ADRENAL);
				boyfriend.successfullyStep(-1, 1);
			case 1:
				// dad.playAnim('hit', true);
				// break;
				spawnNoteSplashOnNote(handoverNote, handoverNote.noteType, whichOne,
					Perkedel.MAX_AVAILABLE_JUDGEMENT_RATING); // yay Psyched note splash on player 2 as well!
				spawnNoteHitlineOnNote(handoverNote, handoverNote.noteType, whichOne, Perkedel.MAX_AVAILABLE_JUDGEMENT_RATING);
				// dad.stimulateHeart(-1, HeartStimulateType.ADRENAL);
				dad.successfullyStep(-1, 1);
			case 2:
				// girlfriend.playAnim('hit', true);
				// break;
				// okay I know, Copilot.
				// gf.stimulateHeart(-1, HeartStimulateType.ADRENAL);
				dad.successfullyStep(-1, 1);
			default:
		}

		// increaseHR(successionAdrenalAdd[whichOne][heartTierIsRightNow[whichOne]], whichOne);
	}

	function checkWhichHeartTierWent(giveHB:Float, whichOne:Int = 0)
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

	public function increaseHR(forHowMuch:Float = 0, whichOne:Int = 0)
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
				if (value == Stage.curStage)
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
						FlxG.sound.play(Paths.sound((reversed ? 'intro1' : 'intro3') + altSuffix + midiSuffix), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (Stage.curStage.startsWith('school'))
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

					if (Stage.curStage.startsWith('school'))
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
						FlxG.sound.play(Paths.sound((reversed ? 'intro3' : 'intro1') + altSuffix + midiSuffix), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (Stage.curStage.startsWith('school'))
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
				createToast(null, "No Tankman", "Week 7 still not released!!!");
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
			case 'ku-tetap-cinta-yesus':
				createToast(null, "Forgiven", "[REDACTED] is now eligible to access Heaven again! Welcome home.");
			default:
				trace("an song complete");
		}
	}

	// JOELwindows7: check song start
	function checkSongStartAfterTankman()
	{
		// JOELwindows7: also add delay before start
		// for intro cutscene after video and before dialogue chat you know!
		// JOELwindows7: Heuristic for using JSON chart instead
		if (SONG.hasDialogueChat)
		{
			schoolIntro(doof);
		}
		else
		{
			// inCutscene = false;
			new FlxTimer().start(1, function(timer)
			{
				startCountdown();
			});
		}
	}

	// JOELwindows7: flaggrants for Cutscene calls
	var introSceneCalled = false;
	var introDoneCalled = false;
	var outroSceneCalled = false;
	var outroDoneCalled = false;

	// JOELwindows7: Psyched intro after video and before dialogue chat
	function introScene()
	{
		introSceneCalled = true;
		inCutscene = true;
		switch (curSong)
		{
			default:
				// No cutscene intro
				decideIntroSceneDone(SONG.introCutSceneDoneManually);
		}
	}

	// JOELwindows7: decide if intro must be done manually through modchart.
	function decideIntroSceneDone(isItManually:Bool = false)
	{
		if (isItManually)
		{
			// JOELwindows7: then modchart must trigger it.
			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
			{
				luaModchart.executeState("introCutscene", []); // JOELwindows7: here intro cutscene yey!
			}
			if (stageScript != null)
			{
				stageScript.executeState("introCutscene", []); // JOELwindows7: here intro cutscene yey!
			}
			#end
			if (hscriptModchart != null)
			{
				hscriptModchart.executeState("introCutscene", []); // JOELwindows7: here intro cutscene yey!
			}
			if (stageHscript != null)
			{
				stageHscript.executeState("introCutscene", []); // JOELwindows7: here intro cutscene yey!
			}
		}
		else
		{
			introSceneIsDone();
		}
	}

	function recallIntroSceneDone()
	{
		if (!introDoneCalled)
			introSceneIsDone();
	}

	// JOELwindows7: call this for intro is done
	function introSceneIsDone()
	{
		introDoneCalled = true;
		new FlxTimer().start(SONG.delayBeforeStart, function(timer:FlxTimer)
		{
			checkSongStartAfterTankman(); // I know, this is spaghetti code. because I believe there's more somebody uses the method.
		});
	}

	// JOELwindows7: Outro Done fillout vars
	// JOELwindows7: Psyched outro after dialogue chat & before epilogue video
	function outroScene(handoverName:String, isNextSong:Bool = false, handoverDelayFirst:Float = 0, handoverHasEpilogueVid:Bool = false,
			handoverEpilogueVidPath:String = "", handoverHasTankmanEpilogueVid:Bool = false, handoverTankmanEpilogueVidPath:String = "")
	{
		outroSceneCalled = true;
		switch (handoverName.toLowerCase())
		{
			case 'mayday': // blacken the screen like going to Winter Horrorland but slowed and sadder
				// to contemplate in memory of those 3 taken down mods. and more.
				// var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
				// 	-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
				// blackShit.scrollFactor.set();
				// blackShit.alpha = 0;
				// add(blackShit);

				// JOELwindows7: better! use camera fade
				FlxG.camera.fade(FlxColor.BLACK, 5);

				// camHUD.alpha = 0;
				FlxTween.tween(camHUD, {alpha: 0}, 5, {
					ease: FlxEase.linear,
					onComplete: function(twn:FlxTween)
					{
					}
				});
				// FlxTween.tween(blackShit, {alpha: 1}, 5, {
				// 	ease: FlxEase.linear,
				// 	onComplete: function(twn:FlxTween)
				// 	{
				// 	}
				// });

				new FlxTimer().start(10, function(tmr:FlxTimer)
				{
					outroSceneIsDone(isNextSong, handoverName, handoverDelayFirst, handoverHasEpilogueVid, handoverEpilogueVidPath,
						handoverHasTankmanEpilogueVid, handoverTankmanEpilogueVidPath);
				});
			case 'eggnog':
				// JOELwindows7: right, we've migrated those here yey. add more things if necessary.
				var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
					-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
				blackShit.scrollFactor.set();
				add(blackShit);
				camHUD.visible = false;

				FlxG.sound.play(Paths.sound('Lights_Shut_off'));
				Controls.vibrate(0, 100);

				new FlxTimer().start(3, function(tmr:FlxTimer)
				{
					outroSceneIsDone(isNextSong, handoverName, handoverDelayFirst, handoverHasEpilogueVid, handoverEpilogueVidPath,
						handoverHasTankmanEpilogueVid, handoverTankmanEpilogueVidPath);
				});
			default:
				#if FEATURE_LUAMODCHART
				if (luaModchart != null)
				{
					luaModchart.executeState("outroCutscene", []); // JOELwindows7: here outro cutscene yey!
				}
				if (stageScript != null)
				{
					stageScript.executeState("outroCutscene", []); // JOELwindows7: here outro cutscene yey!
				}
				#end
				if (hscriptModchart != null)
				{
					hscriptModchart.executeState("outroCutscene", []); // JOELwindows7: here outro cutscene yey!
				}
				if (stageHscript != null)
				{
					stageHscript.executeState("outroCutscene", []); // JOELwindows7: here outro cutscene yey!
				}
				decideOutroSceneDone(isNextSong, handoverName, handoverDelayFirst, handoverHasEpilogueVid, handoverEpilogueVidPath,
					handoverHasTankmanEpilogueVid, handoverTankmanEpilogueVidPath, SONG.outroCutSceneDoneManually);
		}
	}

	// JOELwindows7: refill Fillout first, if outro scene done manually through modchart
	function decideOutroSceneDone(isNextSong:Bool = false, handoverName:String, handoverDelayFirst:Float = 0, handoverHasEpilogueVid:Bool = false,
			handoverEpilogueVidPath:String = "", handoverHasTankmanEpilogueVid:Bool = false, handoverTankmanEpilogueVidPath:String = "",
			isItManual:Bool = false)
	{
		CarryAround.__isNextSong = isNextSong;
		CarryAround.__handoverName = handoverName;
		CarryAround.__handoverDelayFirst = handoverDelayFirst;
		CarryAround.__handoverHasEpilogueVid = handoverHasEpilogueVid;
		CarryAround.__handoverEpilogueVidPath = handoverEpilogueVidPath;
		CarryAround.__handoverHasTankmanEpilogueVid = handoverHasTankmanEpilogueVid;
		CarryAround.__handoverTankmanEpilogueVidPath = handoverTankmanEpilogueVidPath;
		if (isItManual)
		{
			// then the modchart must manually done it.
		}
		else
		{
			outroSceneIsDone(isNextSong, handoverName, handoverDelayFirst, handoverHasEpilogueVid, handoverEpilogueVidPath, handoverHasTankmanEpilogueVid,
				handoverTankmanEpilogueVidPath);
		}
	}

	// JOELwindows7: here the recall for easy access.
	function recallOutroSceneDone()
	{
		if (!outroDoneCalled)
			outroSceneIsDone(CarryAround.__isNextSong, CarryAround.__handoverName, CarryAround.__handoverDelayFirst, CarryAround.__handoverHasEpilogueVid,
				CarryAround.__handoverEpilogueVidPath, CarryAround.__handoverHasTankmanEpilogueVid, CarryAround.__handoverTankmanEpilogueVidPath);
	}

	// JOELwindows7: call this when outro is done
	function outroSceneIsDone(isNextSong:Bool = false, lastSongNameInPlaylist:String = "", delayFirstBeforeThat:Float = 0, hasEpilogueVideo:Bool = false,
			epilogueVideoPath:String = "", hasEpilogueTankmanVideo:Bool = false, epilogueTankmanVideoPath:String = "")
	{
		outroDoneCalled = true;
		// JOELwindows7: 1st, clean modcharts
		scronchLuaScript();
		scronchHscript();

		if (hasEpilogueTankmanVideo)
		{
			tankmanIntro(epilogueTankmanVideoPath, true, lastSongNameInPlaylist, isNextSong, delayFirstBeforeThat, hasEpilogueVideo, epilogueVideoPath,
				hasEpilogueTankmanVideo, epilogueTankmanVideoPath);
		}
		else
		{
			if (isNextSong)
			{
				// JOELwindows7: here timer guys
				new FlxTimer().start(delayFirstBeforeThat, function(tmr:FlxTimer)
				{
					// JOELwindows7: if has video, then load the video first before going to new playstate!
					// LoadingState.loadAndSwitchState(hasEpilogueVideo ? (VideoCutscener.getThe(epilogueVideoPath,
					// 	(SONG.hasVideo ? VideoCutscener.getThe(SONG.videoPath,
					// 		new PlayState()) : new PlayState()))) : (SONG.hasVideo ? VideoCutscener.getThe(SONG.videoPath, new PlayState()) : new PlayState()));
					switchState(hasEpilogueVideo ? (VideoCutscener.getThe(epilogueVideoPath,
						(SONG.hasVideo ? VideoCutscener.getThe(SONG.videoPath,
							new PlayState()) : new PlayState()))) : (SONG.hasVideo ? VideoCutscener.getThe(SONG.videoPath, new PlayState()) : new PlayState()),
						true, true, true, true);
					// LoadingState.loadAndSwitchState(new PlayState()); //Legacy
					// JOELwindows7: oh God, so complicated. I hope it works! use Hex Weekend switchState
					clean();
				});
			}
			else
			{
				// JOELwindows7: yep move from that function. this one is when song has ran out in the playlist.
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
						// FlxG.switchState(SONG.hasEpilogueVideo ? VideoCutscener.getThe(SONG.epilogueVideoPath, new StoryMenuState()) : new StoryMenuState());
						switchState(SONG.hasEpilogueVideo ? VideoCutscener.getThe(SONG.epilogueVideoPath, new StoryMenuState()) : new StoryMenuState());
						// JOELwindows7: complicated! oh MY GOD! use Hex Weekend switchState
						clean();
					}
				});
			}
		}
	}

	/**Do something in this dialogue when started.
	 * @author JOELwindows7
	 */
	public function dialogueScene()
	{
		#if FEATURE_LUAMODCHART
		if (executeModchart && luaModchart != null)
		{
			luaModchart.executeState('dialogueStart', []);
		}
		if (executeStageScript && stageScript != null)
		{
			stageScript.executeState('dialogueStart', []);
		}
		#end
		if (executeModHscript && hscriptModchart != null)
		{
			hscriptModchart.executeState('dialogueStart', []);
		}
		if (executeStageHscript && stageHscript != null)
		{
			stageHscript.executeState('dialogueStart', []);
		}
	}

	/** Do something in this dialogue when finished.
	 * @author JOELwindows7
	 */
	public function dialogueSceneEnding()
	{
		#if FEATURE_LUAMODCHART
		if (executeModchart && luaModchart != null)
		{
			luaModchart.executeState('dialogueFinish', []);
		}
		if (executeStageScript && stageScript != null)
		{
			stageScript.executeState('dialogueFinish', []);
		}
		#end
		if (executeModHscript && hscriptModchart != null)
		{
			hscriptModchart.executeState('dialogueFinish', []);
		}
		if (executeStageHscript && stageHscript != null)
		{
			stageHscript.executeState('dialogueFinish', []);
		}
	}

	/**
	 * Do something in this dialogue when going to close
	 * @author JOELwindows7
	 */
	public function dialogueSceneClose()
	{
		#if FEATURE_LUAMODCHART
		if (executeModchart && luaModchart != null)
		{
			luaModchart.executeState('dialogueSkip', []);
		}
		if (executeStageScript && stageScript != null)
		{
			stageScript.executeState('dialogueSkip', []);
		}
		#end
		if (executeModHscript && hscriptModchart != null)
		{
			hscriptModchart.executeState('dialogueSkip', []);
		}
		if (executeStageHscript && stageHscript != null)
		{
			stageHscript.executeState('dialogueSkip', []);
		}
	}

	/**
	 * Do something in this dialogue everytime opening next dialogue
	 * @author JOELwindows7
	 */
	public function dialogueNext(index:Int)
	{
		#if FEATURE_LUAMODCHART
		if (executeModchart && luaModchart != null)
		{
			luaModchart.executeState('dialogueNext', [index]);
		}
		if (executeStageScript && stageScript != null)
		{
			stageScript.executeState('dialogueNext', [index]);
		}
		#end
		if (executeModHscript && hscriptModchart != null)
		{
			hscriptModchart.executeState('dialogueNext', [index]);
		}
		if (executeStageHscript && stageHscript != null)
		{
			stageHscript.executeState('dialogueNext', [index]);
		}
	}

	// JOELwindows7: on video sprite finish callback

	function onVideoSpriteFinish()
	{
		#if FEATURE_LUAMODCHART
		if (executeModchart && luaModchart != null)
		{
			luaModchart.executeState('onVideoSpriteFinish', []);
		}
		if (executeStageScript && stageScript != null)
		{
			stageScript.executeState('onVideoSpriteFinish', []);
		}
		#end
		if (executeModHscript && hscriptModchart != null)
		{
			hscriptModchart.executeState('onVideoSpriteFinish', []);
		}
		if (executeStageHscript && stageHscript != null)
		{
			stageHscript.executeState('onVideoSpriteFinish', []);
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

	// JOELwindows7: well the getEvent thingy like everybody that uses FlxUI value input stuff.
	override public function getEvent(name:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void
	{
		// JOELwindows7: inspire from ChartingState.hx & FlxSound demo Flixel yess.
		// https://github.com/HaxeFlixel/flixel-demos/blob/master/Features/FlxSound/source/MenuState.hx

		if (destroyed)
		{
			return;
		}

		super.getEvent(name, sender, data, params);

		if (name == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label)
			{
				default:
			}
		}
		else if (name == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			switch (wname)
			{
				case 'autoClick_delay':
					Debug.logTrace("Change Auto click delay into " + Std.string(nums.value) + "s");
					FlxG.save.data.autoClickDelay = nums.value;
					FlxG.save.flush();
				default:
			}
		}
		else if (name == FlxUITypedButton.CLICK_EVENT && (sender is FlxUIButton))
		{
			var fuib:FlxUIButton = cast sender;
			var label = fuib.label.text;
			switch (label)
			{
				default:
			}
		}
	}

	// JOELwindows7: Psyched splash note yeahow
	function spawnNoteSplashOnNote(note:Note, noteType:Int = 0, whichPlayer:Int = 0, rating:Int = 0)
	{
		if (FlxG.save.data.noteSplashes && note != null)
		{
			var strum:StaticArrow = playerStrums.members[note.noteData];
			// JOELwindows7: handle which player properly. we have strum variable to get where position for each
			// strum receptors.
			switch (whichPlayer)
			{
				case 1:
					strum = cpuStrums.members[note.noteData];
				default:
			}
			if (strum != null)
			{
				spawnNoteSplash(strum.x, strum.y, note.noteData, note, noteType, rating);
			}
		}
	}

	function spawnNoteHitlineOnNote(note:Note, noteType:Int = 0, whichPlayer:Int = 0, rating:Int = 0)
	{
		if (FlxG.save.data.noteSplashes && note != null)
		{
			var strum:StaticArrow = playerStrums.members[note.noteData];
			// JOELwindows7: handle which player properly. we have strum variable to get where position for each
			// strum receptors.
			switch (whichPlayer)
			{
				case 1:
					strum = cpuStrums.members[note.noteData];
				default:
			}
			if (strum != null)
			{
				spawnHitlineParticle(strum.x, note.y, note.noteData, note, noteType, rating);
			}
		}
	}

	// JOELwindows7: spawn note splash core Pyschedly
	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null, noteType:Int = 0, rating:Int = 0)
	{
		var skin:String = 'Arrow-splash'; // TODO: JOELwindows7: use `-duar` for mines (note type 2)
		if (PlayState.SONG.noteStyle != null && PlayState.SONG.noteStyle.length > 0 && PlayState.SONG.useCustomNoteStyle)
			skin = PlayState.SONG.noteStyle + "-splash" + (noteType == 2 ? "-duar" : "");

		// var hue:Float = ClientPrefs.arrowHSV[data % 4][0] / 360;
		// var sat:Float = ClientPrefs.arrowHSV[data % 4][1] / 100;
		// var brt:Float = ClientPrefs.arrowHSV[data % 4][2] / 100;
		// if(note != null) {
		// 	skin = note.noteSplashTexture;
		// 	hue = note.noteSplashHue;
		// 	sat = note.noteSplashSat;
		// 	brt = note.noteSplashBrt;
		// }

		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		// splash.setupNoteSplash(x, y, data, skin, hue, sat, brt, noteType);
		splash.setupNoteSplash(x, y, data, skin, 0, 0, 0, noteType);
		grpNoteSplashes.add(splash);
	}

	// JOELwindows7: spawn hitline particle like splash but it's line to determine how late, early, or perfect you hit it.
	public function spawnHitlineParticle(x:Float, y:Float, data:Int, ?note:Note = null, noteType:Int = 0, rating:Int = 0)
	{
		var hitline:FlxSprite = grpNoteHitlineParticles.recycle(FlxSprite);
		hitline.loadGraphic(Paths.loadImage((note != null ? note.hitlinePath : "HitLineParticle"), 'shared'));
		// hitline.setGraphicSize(Std.int(.5)); // why integer, HaxeFlixel?!
		hitline.scale.x = .6;
		hitline.scale.y = .6;
		hitline.updateHitbox();
		// hitline.setPosition(x-Note.swagWidth * .95,y-Note.swagHeight *.95);
		hitline.setPosition(x, y);
		// hitline.offset.set(10,10);
		hitline.alpha = 1;
		hitline.color = switch (rating)
		{
			case 0: // shit
				FlxColor.RED;
			case 1: // bad
				FlxColor.PURPLE;
			case 2: // good
				FlxColor.LIME;
			case 3: // sick
				FlxColor.YELLOW;
			case 4: // dank (Flawless)
				FlxColor.CYAN;
			case 5: // MVP (Ludicrous)
				FlxColor.BLUE; // Blue
			default:
				FlxColor.WHITE;
		};
		grpNoteHitlineParticles.add(hitline);
		FlxTween.tween(hitline, {alpha: 0}, 1, {
			ease: FlxEase.linear,
			onComplete: function(twn:FlxTween)
			{
				hitline.kill();
			}
		});
	}

	// JOELwindows7: Psyched blackbar stuff
	function buildRealBlackBars()
	{
		realBlackbarsTop = new FlxSprite(0, 0);
		realBlackbarsTop.makeGraphic(FlxG.width, realBlackbarHeight, 0xFF000000);
		realBlackbarsTop.alpha = 0;
		realBlackbarsTop.scrollFactor.set();
		realBlackbarsBottom = new FlxSprite(0, FlxG.height - realBlackbarHeight);
		realBlackbarsBottom.makeGraphic(FlxG.width, realBlackbarHeight, 0xFF000000);
		realBlackbarsBottom.alpha = 0;
		realBlackbarsBottom.scrollFactor.set();
		add(realBlackbarsTop);
		add(realBlackbarsBottom);
		realBlackbarsTop.visible = false;
		realBlackbarsBottom.visible = false;
		// disappearRealBlackBar(0.1); // Now delegate their dormant positions yeah!
		// or maybe just pecking do it?
		realBlackbarsTop.y = -realBlackbarHeight;
		realBlackbarsBottom.y = FlxG.height;
	}

	// JOELwindows7: Psyched appear blackbar
	public function appearRealBlackBar(forHowLong:Float = 2)
	{
		if (realBlackbarsTop == null || realBlackbarsBottom == null)
			return;
		realBlackbarsTop.visible = true;
		realBlackbarsBottom.visible = true;
		// realBlackbarsTop.x = -blackbarHeight;
		// realBlackbarsBottom.x = FlxG.height;
		FlxTween.color(realBlackbarsTop, forHowLong, realBlackbarsTop.color, 0xFF000000, {ease: FlxEase.linear});
		FlxTween.color(realBlackbarsBottom, forHowLong, realBlackbarsBottom.color, 0xFF000000, {ease: FlxEase.linear});
		FlxTween.tween(realBlackbarsTop, {y: 0, alpha: .8}, forHowLong, {ease: FlxEase.linear});
		FlxTween.tween(realBlackbarsBottom, {y: FlxG.height - realBlackbarHeight, alpha: .8}, forHowLong, {ease: FlxEase.linear});
	}

	// JOELwindows7: Psyched disappear blackbar
	public function disappearRealBlackBar(forHowLong:Float = 2)
	{
		if (realBlackbarsTop == null || realBlackbarsBottom == null)
			return;
		// realBlackbarsTop.x = 0;
		// realBlackbarsBottom.x = FlxG.height - blackbarHeight;
		FlxTween.tween(realBlackbarsTop, {y: -realBlackbarHeight, alpha: 0}, forHowLong, {
			ease: FlxEase.linear,
			onComplete: function(twn:FlxTween)
			{
				realBlackbarsTop.visible = false;
			}
		});
		FlxTween.tween(realBlackbarsBottom, {y: FlxG.height, alpha: 0}, forHowLong, {
			ease: FlxEase.linear,
			onComplete: function(twn:FlxTween)
			{
				realBlackbarsBottom.visible = false;
			}
		});
		FlxTween.color(realBlackbarsTop, forHowLong, realBlackbarsTop.color, 0xFF000000, {ease: FlxEase.linear});
		FlxTween.color(realBlackbarsBottom, forHowLong, realBlackbarsBottom.color, 0xFF000000, {ease: FlxEase.linear});
	}

	// JOELwindows7: I guess we have to syndicate that too instead.

	/**
	 * Psyched Blammed Lights. Initiate turn off the lights & turn on the rave lights.
	 * With this on, the background & objects darkens then followed with fade to discotic color lamps,
	 * all characters color will change to based on chosen color.
	 * Used for songs like Blammed (Psyched Engine), Stadium Rave Spongebob, 
	 * Carameldansen, finger crazy move TikTok meme, etc.
	 * @param lightsId select color of the rave lamp from 1 to 5. 0 is off & go back to normal, & 6 is random color
	 */
	public function blammedLights(lightsId:Int = 6)
	{
		if (Stage != null)
		{
			Stage.blammedLights(lightsId);
		}
	}

	// JOELwindows7: and the flag for bellow cartoon corner dot
	var hasAppearedDot:Bool = false;

	// JOELwindows7: appear this infamous dot on top right corner, found on classic pipehose cartoon.
	// It appears at the end of the episode marking ending of film strip. so to prepare End card next.

	/**
	 * Draw purple dot on top right screen. used to mark all finished notes like pipehose classic cartoon
	 * when the end of film strip is approaching.
	 */
	public function cartoonCornerDot()
	{
		// Copy from cheat sheet, section Drawing Shapes
		var lineStyle:LineStyle = {color: FlxColor.RED, thickness: 1};
		var drawStyle:DrawStyle = {smoothing: true};
		var daDot = new FlxSprite();
		daDot.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
		daDot.drawCircle(FlxG.width - 10, 140, 100, FlxColor.PURPLE, lineStyle, drawStyle);
		daDot.scrollFactor.set(); // don't forget!
		// leave daDot in camGame / default because it makes sense as this would be part of film strip.
		daDot.cameras = [camHUD]; // NOPE!!! without putting on HUD, it stays there.
		// where is draw n-gon (draw polygon easy with just Int num of vertices)?
		// the polygon requires you put vertices one by one! what the peck?!?
		if (!hasAppearedDot)
		{
			add(daDot);

			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				daDot.destroy();
			});

			hasAppearedDot = true;
		}
	}

	// TODO: RESERVED: JOELwindows7: Pushing P in nekopara does fun things. Pushing P song
	public function pushP()
	{
		// TODO: jump all characters in the game. the fun begins if the character skin has yea you know.
	}

	// JOELwindows7: execute function for each of the modchart available
	function executeModchartState(name:String, args:Array<Dynamic>)
	{
		#if FEATURE_LUAMODCHART
		if (executeModchart && luaModchart != null)
		{
			luaModchart.executeState(name, args);
			// luaModchart.executeState('methodExecutes', [name, args]);
		}
		if (executeStageScript && stageScript != null)
		{
			stageScript.executeState(name, args);
			// stageScript.executeState('methodExecutes', [name, args]);
		}
		#end
		if (executeModHscript && hscriptModchart != null)
		{
			hscriptModchart.executeState(name, args);
			// hscriptModchart.executeState('methodExecutes', [name, args]);
		}
		if (executeStageHscript && stageHscript != null)
		{
			stageHscript.executeState(name, args);
			// stageHscript.executeState('methodExecutes', [name, args]);
		}
	}

	// JOELwindows7: set one variable for each of the modchart available
	function setModchartVar(name:String, value:Dynamic)
	{
		#if FEATURE_LUAMODCHART
		if (executeModchart && luaModchart != null)
		{
			luaModchart.setVar(name, value);
			// luaModchart.executeState('variableChange', [name, value]); // already internalized
		}
		if (executeStageScript && stageScript != null)
		{
			stageScript.setVar(name, value);
			// stageScript.executeState('variableChange', [name, value]);
		}
		#end
		if (executeModHscript && hscriptModchart != null)
		{
			hscriptModchart.setVar(name, value);
			// hscriptModchart.executeState('variableChange', [name, value]);
		}
		if (executeStageHscript && stageHscript != null)
		{
			stageHscript.setVar(name, value);
			// stageHscript.executeState('variableChange', [name, value]);
		}
		// executeModchartState('variableChange',[name,value]); // don't! it can cause recursion, do it manually instead!
	}

	/**
	 * Returns true if all notes have been played.
	 * @return Bool true if all notes have been played.
	 */
	public function getAllNotePlayed():Bool
	{
		return unspawnNotes.length == 0 && notes.length == 0;
	}

	// JOELwindows7: here manually update heartbeat organs!
	function manageHeartbeats(elapsed:Float)
	{
		@:privateAccess {
			if (boyfriend != null)
			{
				boyfriend.doHeartbeats(elapsed);
			}
			if (gf != null)
			{
				gf.doHeartbeats(elapsed);
			}
			if (dad != null)
			{
				dad.doHeartbeats(elapsed);
			}
		}
	}
}

// u looked :O -ides
// JOELwindows7: Ahei, luckydog7 with Android port, on week 7 yoink, there are these at the end:
// picoshoot
typedef Ps =
{
	var right:Array<Int>;
	var left:Array<Int>;
}

// tank spawns
typedef Ts =
{
	var right:Array<Int>;
	var left:Array<Int>;
}
