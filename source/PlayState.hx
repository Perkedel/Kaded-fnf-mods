package;

import Controls;
import TouchScreenControls;
import Song.Event;
import openfl.media.Sound;
#if sys
import sys.io.File;
import smTools.SMFile;
#end
import openfl.ui.KeyLocation;
import openfl.events.Event;
import haxe.EnumTools;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import Replay.Ana;
import Replay.Analysis;
import flixel.input.actions.FlxAction.FlxActionAnalog;
import DokiDoki; //JOELwindows7: the heartbeat stuff
#if cpp
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
import Song.SwagSong;
import StagechartState;
import StagechartState.SwagStage;
import StagechartState.SwagBackground;
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
#if (windows && cpp)
import Discord.DiscordClient;
#end
//JOELwindows7: hey, I changed the directive to think for other desktop OSes as well. nvm it doesnt work
#if (sys)
import Sys;
import sys.FileSystem;
#end

//JOELwindows7: use ki's filesystemer?
// import filesystem.File;
// Adds candy I/O (read/write/append) extension methods onto File
// using filesystem.FileTools;

//JOELwindows7: okay how about vegardit's filesystemer?
import hx.files.*;

using StringTools;

class PlayState extends MusicBeatState
{
	public static var instance:PlayState = null;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var customStage:SwagStage;
	public static var HEART:SwagHeart; //JOELwindows7: heartbeat spec
	public static var HEARTS:HeartList; //JOELwindows7: list of heart specs
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
	public static var songPosBar:FlxBar;

	public static var rep:Replay;
	public static var loadRep:Bool = false;
	public static var inResults:Bool = false;

	public static var noteBools:Array<Bool> = [false, false, false, false];

	var halloweenLevel:Bool = false;

	//JOELwindows7: global backgrounder. to prioritize add() in order after all variable has been filled with instances
	var bgAll:FlxTypedGroup<FlxSprite>;
	var stageFrontAll:FlxTypedGroup<FlxSprite>;
	var stageCurtainAll:FlxTypedGroup<FlxSprite>;
	var trailAll:FlxTypedGroup<FlxTrail>;

	//JOELwindows7: numbers of Missnote sfx! load from text file, how many Miss notes you had?
	var numOfMissNoteSfx:Int = 3;

	var songLength:Float = 0;
	var kadeEngineWatermark:FlxText;
	var reuploadWatermark:FlxText; //JOELwindows7: reupload & no credit protection. 
	//last resort is to have links shared in video, hard coded, hard embedded.
	//hopefully the "thiefs" got displeased lmao!

	//JOELwindows7: Doki doki dance thingie
	public var heartRate:Int = 70;
	public var minHR:Int = 70;
	public var maxHR:Int = 220;
	public var heartTierIsRightNow:Int = 0;
	public var heartTierBoundaries:Array<Int> = [90, 120, 150, 200]; // tier when bellow each number
	public var successionAdrenalAdd:Array<Int> = [4, 3, 2, 1];
	public var fearShockAdd:Array<Int> = [10, 8, 7, 5];
	public var relaxMinusPerBeat:Array<Int> = [1, 2, 4, 7];
	var slowedAlready:Bool = false;
	
	#if (windows && cpp)
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	public var vocals:FlxSound; //JOELwindows7: make public for Moddchart

	public static var isSM:Bool = false;
	#if sys
	public static var sm:SMFile;
	public static var pathToSm:String;
	#end

	public var originalX:Float;

	public static var dad:Character;
	public static var gf:Character;
	public static var boyfriend:Boyfriend;

	public var notes:FlxTypedGroup<Note>;

	private var unspawnNotes:Array<Note> = [];

	public var strumLine:FlxSprite;

	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	public static var strumLineNotes:FlxTypedGroup<FlxSprite> = null;
	public static var playerStrums:FlxTypedGroup<FlxSprite> = null;
	public static var cpuStrums:FlxTypedGroup<FlxSprite> = null;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	public var gfSpeed:Int = 1; //JOELwindows7: making public because setspeed doesnt work without it

	public var health:Float = 1; // making public because sethealth doesnt work without it

	private var combo:Int = 0;

	public static var misses:Int = 0;
	public static var campaignMisses:Int = 0;
	

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

	public var iconP1:HealthIcon; // making these public again because i may be stupid
	public var iconP2:HealthIcon; // what could go wrong?
	public var camHUD:FlxCamera;
	public var camSustains:FlxCamera;
	public var camNotes:FlxCamera;

	private var camGame:FlxCamera;
	public var cannotDie = false;

	public static var offsetTesting:Bool = false;

	public var isSMFile:Bool = false;

	var notesHitArray:Array<Date> = [];
	var currentFrames:Int = 0;
	var idleToBeat:Bool = true; // change if bf and dad would idle to the beat of the song
	var idleBeat:Int = 4; // how frequently bf and dad would play their idle animation(1 - every beat, 2 - every 2 beats and so on)

	//JOELwindows7: oh c'mon. why would not globalize both dialoguebox start and end class?
	public var doof:DialogueBox;
	public var eoof:DialogueBox;

	public var dialogue:Array<String> = ['dad:blah blah blah', 'bf:coolswag'];
	public var epilogue:Array<String> = ['dad:oh no I lose', 'bf: beep boop baaa hey!']; //JOELwindows7: same dialoguer but for after song done

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;

	var useStageScript:Bool = false; //JOELwindows7: flag to start try the stage Lua script

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;
	var songName:FlxText;
	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var fc:Bool = true;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();

	public var colorableGround:FlxSprite; //JOELwindows7: the colorable sprite thingy
	public var originalColor:FlxColor = FlxColor.WHITE; //JOELwindows7: store the original color for chroma screen and RGB lightings
	public var isChromaScreen:Bool = false; //JOELwindows7: whether this is a Chroma screen or just RGB lightings.
	//if chroma screen, then don't invisiblize, instead turn it back to original color!

	//JOELwindows7: arraying them seems won't work at all. so let's make them separateroid instead.
	public var multicolorableGround:FlxTypedGroup<FlxSprite>; //JOELwindows7: the colorable sprite thingy
	public var multiOriginalColor:Array<FlxColor> = [FlxColor.WHITE]; //JOELwindows7: store the original color for chroma screen and RGB lightings
	public var multiIsChromaScreen:Array<Bool> = [false]; //JOELwindows7: whether this is a Chroma screen or just RGB lightings.
	public var multiColorable:Array<Bool> = [false];

	var talking:Bool = true;

	public var songScore:Int = 0;

	var songScoreDef:Int = 0;
	var scoreTxt:FlxText;
	var replayTxt:FlxText;

	public static var campaignScore:Int = 0;

	public var defaultCamZoom:Float = 1.05; //JOELwindows7: what could go wrong?

	public static var daPixelZoom:Float = 6;

	public static var theFunne:Bool = true;

	var funneEffect:FlxSprite;
	var inCutscene:Bool = false;
	var usedTimeTravel:Bool = false;

	public static var repPresses:Int = 0;
	public static var repReleases:Int = 0;

	public static var timeCurrently:Float = 0;
	public static var timeCurrentlyR:Float = 0;

	// Will fire once to prevent debug spam messages and broken animations
	private var triggeredAlready:Bool = false;

	// Will decide if she's even allowed to headbang at all depending on the song
	private var allowedToHeadbang:Bool = false;

	// Per song additive offset
	public static var songOffset:Float = 0;

	// BotPlay text
	private var botPlayState:FlxText;
	// Replay shit
	private var saveNotes:Array<Dynamic> = [];
	private var saveJudge:Array<String> = [];
	private var replayAna:Analysis = new Analysis(); // replay analysis

	public static var highestCombo:Int = 0;

	private var executeModchart = false;
	private var executeStageScript = false; //JOELwindows7: for stage lua scripter
	private var executeModHscript = false; //JOELwindows7: modchart but hscript. thancc BulbyVR
	private var executeStageHscript = false;

	// Animation common suffixes
	private var dataSuffix:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
	private var dataColor:Array<String> = ['purple', 'blue', 'green', 'red'];

	public static var startTime = 0.0;

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

		if (FlxG.save.data.fpsCap > 290)
		{
			//JOELwindows7: android issue. cast lib current technic crash
			#if !mobile	
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(800);
			#end
		}

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		if (!isStoryMode)
		{
			sicks = 0;
			bads = 0;
			shits = 0;
			goods = 0;
		}
		misses = 0;

		highestCombo = 0;
		repPresses = 0;
		repReleases = 0;
		inResults = false;

		PlayStateChangeables.useDownscroll = FlxG.save.data.downscroll;
		PlayStateChangeables.safeFrames = FlxG.save.data.frames;
		PlayStateChangeables.scrollSpeed = FlxG.save.data.scrollSpeed;
		PlayStateChangeables.botPlay = FlxG.save.data.botplay;
		PlayStateChangeables.Optimize = FlxG.save.data.optimize;

		// pre lowercasing the song name (create)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
		switch (songLowercase)
		{
			case 'dad-battle':
				songLowercase = 'dadbattle';
			case 'philly-nice':
				songLowercase = 'philly';
		}

		removedVideo = false;

		var p; //JOELwindows7: the haxe-file stuff.

		#if ((windows) && sys)
		executeModchart = FileSystem.exists(Paths.lua(songLowercase + "/modchart"));
		if (isSM)
			executeModchart = FileSystem.exists(pathToSm + "/modchart.lua");
		if (executeModchart)
			PlayStateChangeables.Optimize = false;
		#elseif (windows)
		//JOELwindows7: for not sys. use vergadit's filesystemers.
		p = Path.of(Paths.lua("./" + songLowercase  + "/modchart"));
		executeModchart = p.exists();
		trace("is modchart file exist? " + Std.string(p.exists()) + " as " + p.getAbsolutePath());
		if (executeModchart)
			PlayStateChangeables.Optimize = false;
		#else
		executeModchart = false; // JOELwindows7: FORCE disable for non sys && windows targets
		executeStageScript = false; 
		#end
		#if !cpp
		executeModchart = false; // FORCE disable for non cpp targets
		executeStageScript = false; //JOELwindows7: this too
		#end
		// if(SONG.forceLuaModchart == null){
		// 	executeModchart = SONG.forceLuaModchart = false;
		// }
		trace("forced hscript exist is " + Std.string(SONG.forceLuaModchart));

		trace('Mod chart: ' + executeModchart + " - " + Paths.lua(songLowercase + "/modchart"));

		// JOELwindows7: now for the hscript
		#if !web
		p = Path.of("./" + Paths.hscript(songLowercase + "/modchart"));
		executeModHscript = p.exists() || SONG.forceHscriptModchart;
		trace("is hscript modchart file exist? " + Std.string(p.exists()) + " as " + p.getAbsolutePath());
		#else
		executeModHscript = SONG.forceHscriptModchart;
		#end
		// if(SONG.forceHscriptModchart == null){
		// 	executeModHscript = SONG.forceHscriptModchart = false;
		// }
		trace("forced hscript exist is " + Std.string(SONG.forceHscriptModchart));
		if (executeModHscript)
			PlayStateChangeables.Optimize = false;
		trace('Mod hscript chart: ' + executeModHscript + " - " + Paths.hscript(songLowercase + "/modchart"));

		//JOELwindows7: okay since none of the working Android file exist checker been found, let's just peck this
		// and do whatever the peck we want.
		executeModchart = SONG.forceLuaModchart? true : executeModchart;
		executeModHscript= SONG.forceHscriptModchart? true : executeModHscript;

		#if (windows && cpp)
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

		//JOELwindows7: load the num missnote sfx file and interpret!
		// inspire the loader from FreeplayState.hx or OH ChartingState.hx. look at those dropdowns
		// that lists characters, stages, etc.
		// yeah I know, for future use we array this.
		var initMissSfx = CoolUtil.coolTextFile(Paths.txt('data/numbersOfMissSfx'));
		numOfMissNoteSfx = Std.parseInt(initMissSfx[0]);

		//JOELwindows7: init the heartbeat system
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

		FlxCamera.defaultCameras = [camGame];
		//FlxG.cameras.setDefaultDrawTarget(camGame, true); //JOELwindows7: try the new one
		//see if it works..
		//nope. well it works, but
		// alot of semantics here has to be changed first before hand, so uh. unfortunately
		//I can't yet.

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial', 'tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		if (SONG.eventObjects == null)
			{
				SONG.eventObjects = [new Song.Event("Init BPM",0,SONG.bpm,"BPM Change")];
			}
	

		TimingStruct.clearTimings();

		var convertedStuff:Array<Song.Event> = [];

		var currentIndex = 0;
		for (i in SONG.eventObjects)
		{
			var name = Reflect.field(i,"name");
			var type = Reflect.field(i,"type");
			var pos = Reflect.field(i,"position");
			var value = Reflect.field(i,"value");

			if (type == "BPM Change")
			{
                var beat:Float = pos;

                var endBeat:Float = Math.POSITIVE_INFINITY;

                TimingStruct.addTiming(beat,value,endBeat, 0); // offset in this case = start time since we don't have a offset
				
                if (currentIndex != 0)
                {
                    var data = TimingStruct.AllTimings[currentIndex - 1];
                    data.endBeat = beat;
                    data.length = (data.endBeat - data.startBeat) / (data.bpm / 60);
					TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length;
                }

				currentIndex++;
			}
			convertedStuff.push(new Song.Event(name,pos,value,type));
		}

		SONG.eventObjects = convertedStuff;

		trace('INFORMATION ABOUT WHAT U PLAYIN WIT:\nFRAMES: ' + PlayStateChangeables.safeFrames + '\nZONE: ' + Conductor.safeZoneOffset + '\nTS: '
			+ Conductor.timeScale + '\nBotPlay : ' + PlayStateChangeables.botPlay);

		// dialogue shit
		switch (songLowercase)
		{
			case 'tutorial':
				dialogue = ["Hey you're pretty cute.", 'Use the arrow keys to keep up \nwith me singing.'];
			case 'bopeebo':
				dialogue = [
					'HEY!',
					"You think you can just sing\nwith my daughter like that?",
					"If you want to date her...",
					"You're going to have to go \nthrough ME first!"
				];
			case 'fresh':
				dialogue = ["Not too shabby boy.", ""];
			case 'dadbattle':
				dialogue = [
					"gah you think you're hot stuff?",
					"If you can beat me here...",
					"Only then I will even CONSIDER letting you\ndate my daughter!"
				];
			case 'senpai':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/senpai/senpaiDialogue'));
			case 'roses':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/roses/rosesDialogue'));
			case 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/thorns/thornsDialogue'));
			default:
				//JOELwindows7: make dialog loading things went procedural!
				#if (sys && !mobile)
				dialogue = (SONG.hasDialogueChat &&
					FileSystem.exists(Paths.txt('data/${toCompatCase(SONG.song.toLowerCase())}/${toCompatCase(SONG.song.toLowerCase())}Dialogue'))
				)? 
				CoolUtil.coolTextFile(Paths.txt('data/${toCompatCase(SONG.song.toLowerCase())}/${toCompatCase(SONG.song.toLowerCase())}Dialogue')):
				['dad: da bu tu bu da', 'bf: emptyswag']; //JOELwindows7: add nullswag when noone had.
				#else
				dialogue = (SONG.hasDialogueChat #if (!android && !web) &&
					Path.of("./" + Paths.txt('data/${toCompatCase(SONG.song.toLowerCase())}/${toCompatCase(SONG.song.toLowerCase())}Dialogue')).exists() #end
				)? 
				CoolUtil.coolTextFile(Paths.txt('data/${toCompatCase(SONG.song.toLowerCase())}/${toCompatCase(SONG.song.toLowerCase())}Dialogue')):
				['dad: da bu tu bu da', 'bf: emptyswag']; //JOELwindows7: add nullswag when noone had.
				#end
				//Okay, do for the rest above!
		}

		//JOELwinodws7: Epilogue shit
		#if (sys && !mobile)
		epilogue = (SONG.hasEpilogueChat &&
			FileSystem.exists(Paths.txt('data/${toCompatCase(SONG.song.toLowerCase())}/${toCompatCase(SONG.song.toLowerCase())}Epilogue'))
		) ? 
		CoolUtil.coolTextFile(Paths.txt('data/${toCompatCase(SONG.song.toLowerCase())}/${toCompatCase(SONG.song.toLowerCase())}Epilogue')):
		['dad: undefined defeat', 'bf:nullswag'];
		#else
		epilogue = (SONG.hasEpilogueChat #if (!android && !web) && //android & web not work
			Path.of("./" + Paths.txt('data/${toCompatCase(SONG.song.toLowerCase())}/${toCompatCase(SONG.song.toLowerCase())}Epilogue')).exists() #end
		) ? 
		CoolUtil.coolTextFile(Paths.txt('data/${toCompatCase(SONG.song.toLowerCase())}/${toCompatCase(SONG.song.toLowerCase())}Epilogue')):
		['dad: undefined defeat', 'bf:nullswag'];
		#end
		//see, as simple as that
		//NEW: conform the dash is space like in FreeplayState.hx loadings

		// defaults if no stage was found in chart
		var stageCheck:String = 'stage';

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
					if (songLowercase == 'winter-horrorland')
					{
						stageCheck = 'mallEvil';
					}
					else
					{
						stageCheck = 'mall';
					}
				case 6:
					if (songLowercase == 'thorns')
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

		if (!PlayStateChangeables.Optimize)
		{
			trace("Load da stage here ya"); //JOELwindows7: wtf happened
			if(SONG.useCustomStage)
			{
				//JOELwindows7: Here's the switchover!
				initDaCustomStage(SONG.stage);
			} else {
				switch (stageCheck)
				{
					case 'halloween':
						{
							curStage = 'spooky';
							halloweenLevel = true;

							var hallowTex = Paths.getSparrowAtlas('halloween_bg', 'week2');

							halloweenBG = new FlxSprite(-200, -100);
							halloweenBG.frames = hallowTex;
							halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
							halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
							halloweenBG.animation.play('idle');
							if(FlxG.save.data.antialiasing)
								{
									halloweenBG.antialiasing = true;
								}
							add(halloweenBG);

							isHalloween = true;
						}
					case 'philly':
						{
							curStage = 'philly';

							var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky', 'week3'));
							bg.scrollFactor.set(0.1, 0.1);
							add(bg);

							var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city', 'week3'));
							city.scrollFactor.set(0.3, 0.3);
							city.setGraphicSize(Std.int(city.width * 0.85));
							city.updateHitbox();
							add(city);

							phillyCityLights = new FlxTypedGroup<FlxSprite>();
							if (FlxG.save.data.distractions)
							{
								add(phillyCityLights);
							}

							for (i in 0...5)
							{
								var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i, 'week3'));
								light.scrollFactor.set(0.3, 0.3);
								light.visible = false;
								light.setGraphicSize(Std.int(light.width * 0.85));
								light.updateHitbox();
								if(FlxG.save.data.antialiasing)
									{
										light.antialiasing = true;
									}
								phillyCityLights.add(light);
							}

							var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain', 'week3'));
							add(streetBehind);

							phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train', 'week3'));
							if (FlxG.save.data.distractions)
							{
								add(phillyTrain);
							}

							//JOELwindows7: buddy, you forgot to put the train sound in week3 special folder
							//No wonder the train cannot come. it missing that sound.
							//remember, the trains position depends on the sound playback position!
							trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes', 'week3'));
							FlxG.sound.list.add(trainSound);
							//there, I've copied the train_passes ogg & mp3 into the week3/sounds . 
							//yay it works.

							// var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

							var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street', 'week3'));
							add(street);
						}
					case 'limo':
						{
							curStage = 'limo';
							defaultCamZoom = 0.90;

							var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset', 'week4'));
							skyBG.scrollFactor.set(0.1, 0.1);
							add(skyBG);

							var bgLimo:FlxSprite = new FlxSprite(-200, 480);
							bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo', 'week4');
							bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
							bgLimo.animation.play('drive');
							bgLimo.scrollFactor.set(0.4, 0.4);
							add(bgLimo);
							if (FlxG.save.data.distractions)
							{
								grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
								add(grpLimoDancers);

								for (i in 0...5)
								{
									var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
									dancer.scrollFactor.set(0.4, 0.4);
									grpLimoDancers.add(dancer);
								}
							}

							var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay', 'week4'));
							overlayShit.alpha = 0.5;
							// add(overlayShit);

							// var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);

							// FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);

							// overlayShit.shader = shaderBullshit;

							var limoTex = Paths.getSparrowAtlas('limo/limoDrive', 'week4');

							limo = new FlxSprite(-120, 550);
							limo.frames = limoTex;
							limo.animation.addByPrefix('drive', "Limo stage", 24);
							limo.animation.play('drive');
							if(FlxG.save.data.antialiasing)
								{
									limo.antialiasing = true;
								}

							fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol', 'week4'));
							// add(limo);
						}
					case 'mall':
						{
							curStage = 'mall';

							defaultCamZoom = 0.80;

							var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls', 'week5'));
							if(FlxG.save.data.antialiasing)
								{
									bg.antialiasing = true;
								}
							bg.scrollFactor.set(0.2, 0.2);
							bg.active = false;
							bg.setGraphicSize(Std.int(bg.width * 0.8));
							bg.updateHitbox();
							add(bg);

							upperBoppers = new FlxSprite(-240, -90);
							upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop', 'week5');
							upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
							if(FlxG.save.data.antialiasing)
								{
									upperBoppers.antialiasing = true;
								}
							upperBoppers.scrollFactor.set(0.33, 0.33);
							upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
							upperBoppers.updateHitbox();
							if (FlxG.save.data.distractions)
							{
								add(upperBoppers);
							}

							var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator', 'week5'));
							if(FlxG.save.data.antialiasing)
								{
									bgEscalator.antialiasing = true;
								}
							bgEscalator.scrollFactor.set(0.3, 0.3);
							bgEscalator.active = false;
							bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
							bgEscalator.updateHitbox();
							add(bgEscalator);

							var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree', 'week5'));
							if(FlxG.save.data.antialiasing)
								{
									tree.antialiasing = true;
								}
							tree.scrollFactor.set(0.40, 0.40);
							add(tree);

							bottomBoppers = new FlxSprite(-300, 140);
							bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop', 'week5');
							bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
							if(FlxG.save.data.antialiasing)
								{
									bottomBoppers.antialiasing = true;
								}
							bottomBoppers.scrollFactor.set(0.9, 0.9);
							bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
							bottomBoppers.updateHitbox();
							if (FlxG.save.data.distractions)
							{
								add(bottomBoppers);
							}

							var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow', 'week5'));
							fgSnow.active = false;
							if(FlxG.save.data.antialiasing)
								{
									fgSnow.antialiasing = true;
								}
							add(fgSnow);

							santa = new FlxSprite(-840, 150);
							santa.frames = Paths.getSparrowAtlas('christmas/santa', 'week5');
							santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
							if(FlxG.save.data.antialiasing)
								{
									santa.antialiasing = true;
								}
							if (FlxG.save.data.distractions)
							{
								add(santa);
							}
						}
					case 'mallEvil':
						{
							curStage = 'mallEvil';
							var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG', 'week5'));
							if(FlxG.save.data.antialiasing)
								{
									bg.antialiasing = true;
								}
							bg.scrollFactor.set(0.2, 0.2);
							bg.active = false;
							bg.setGraphicSize(Std.int(bg.width * 0.8));
							bg.updateHitbox();
							add(bg);

							var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree', 'week5'));
							if(FlxG.save.data.antialiasing)
								{
									evilTree.antialiasing = true;
								}
							evilTree.scrollFactor.set(0.2, 0.2);
							add(evilTree);

							var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow", 'week5'));
							if(FlxG.save.data.antialiasing)
								{
									evilSnow.antialiasing = true;
								}
							add(evilSnow);
						}
					case 'school':
						{
							curStage = 'school';

							// defaultCamZoom = 0.9;

							var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky', 'week6'));
							bgSky.scrollFactor.set(0.1, 0.1);
							add(bgSky);

							var repositionShit = -200;

							var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool', 'week6'));
							bgSchool.scrollFactor.set(0.6, 0.90);
							add(bgSchool);

							var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet', 'week6'));
							bgStreet.scrollFactor.set(0.95, 0.95);
							add(bgStreet);

							var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack', 'week6'));
							fgTrees.scrollFactor.set(0.9, 0.9);
							add(fgTrees);

							var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
							var treetex = Paths.getPackerAtlas('weeb/weebTrees', 'week6');
							bgTrees.frames = treetex;
							bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
							bgTrees.animation.play('treeLoop');
							bgTrees.scrollFactor.set(0.85, 0.85);
							add(bgTrees);

							var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
							treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals', 'week6');
							treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
							treeLeaves.animation.play('leaves');
							treeLeaves.scrollFactor.set(0.85, 0.85);
							add(treeLeaves);

							var widShit = Std.int(bgSky.width * 6);

							bgSky.setGraphicSize(widShit);
							bgSchool.setGraphicSize(widShit);
							bgStreet.setGraphicSize(widShit);
							bgTrees.setGraphicSize(Std.int(widShit * 1.4));
							fgTrees.setGraphicSize(Std.int(widShit * 0.8));
							treeLeaves.setGraphicSize(widShit);

							fgTrees.updateHitbox();
							bgSky.updateHitbox();
							bgSchool.updateHitbox();
							bgStreet.updateHitbox();
							bgTrees.updateHitbox();
							treeLeaves.updateHitbox();

							bgGirls = new BackgroundGirls(-100, 190);
							bgGirls.scrollFactor.set(0.9, 0.9);

							if (songLowercase == 'roses' || songLowercase == 'roses-midi')
							{
								if (FlxG.save.data.distractions)
								{
									bgGirls.getScared();
								}
							}

							bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
							bgGirls.updateHitbox();
							if (FlxG.save.data.distractions)
							{
								add(bgGirls);
							}
						}
					case 'schoolEvil':
						{
							curStage = 'schoolEvil';

							if (!PlayStateChangeables.Optimize)
							{
								var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
								var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);
							}

							var posX = 400;
							var posY = 200;

							var bg:FlxSprite = new FlxSprite(posX, posY);
							bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool', 'week6');
							bg.animation.addByPrefix('idle', 'background 2', 24);
							bg.animation.play('idle');
							bg.scrollFactor.set(0.8, 0.9);
							bg.scale.set(6, 6);
							add(bg);

							/* 
								var bg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolBG'));
								bg.scale.set(6, 6);
								// bg.setGraphicSize(Std.int(bg.width * 6));
								// bg.updateHitbox();
								add(bg);
								var fg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolFG'));
								fg.scale.set(6, 6);
								// fg.setGraphicSize(Std.int(fg.width * 6));
								// fg.updateHitbox();
								add(fg);
								wiggleShit.effectType = WiggleEffectType.DREAMY;
								wiggleShit.waveAmplitude = 0.01;
								wiggleShit.waveFrequency = 60;
								wiggleShit.waveSpeed = 0.8;
							*/

							// bg.shader = wiggleShit.shader;
							// fg.shader = wiggleShit.shader;

							/* 
								var waveSprite = new FlxEffectSprite(bg, [waveEffectBG]);
								var waveSpriteFG = new FlxEffectSprite(fg, [waveEffectFG]);
								// Using scale since setGraphicSize() doesnt work???
								waveSprite.scale.set(6, 6);
								waveSpriteFG.scale.set(6, 6);
								waveSprite.setPosition(posX, posY);
								waveSpriteFG.setPosition(posX, posY);
								waveSprite.scrollFactor.set(0.7, 0.8);
								waveSpriteFG.scrollFactor.set(0.9, 0.8);
								// waveSprite.setGraphicSize(Std.int(waveSprite.width * 6));
								// waveSprite.updateHitbox();
								// waveSpriteFG.setGraphicSize(Std.int(fg.width * 6));
								// waveSpriteFG.updateHitbox();
								add(waveSprite);
								add(waveSpriteFG);
							*/
						}
					case 'jakartaFair':
						{
							//JOELwindows7:
							/*
							Jakarta fair, ayo ke Jakarta Fair
							Ajang arena pameran dan hiburan

							ayo kita pergi kesana, rekreasi sekaligus berbelanja
							belanja terlengkap di Jakarta fair...

							ayo kita, ke Jakarta fair. ayo kita ke Jakarta fair. Kemayoran!!!
							*/
							defaultCamZoom = 0.9;
							curStage = 'jakartaFair';
							var bgActualOffset_x = -150;
							var bgActualOffset_y = -100;
							var bg:FlxSprite = new FlxSprite(bgActualOffset_x + -500, bgActualOffset_y + -100).loadGraphic(Paths.image('jakartaFair/jakartaFairBgBehindALL'));
							bg.setGraphicSize(Std.int(bg.width * 1.2),Std.int(bg.height * 1.2));
							bg.antialiasing = true;
							bg.scrollFactor.set(.9, .9);
							bg.active = false;
							add(bg);

							var stageFront:FlxSprite = new FlxSprite(-500,-100).loadGraphic(Paths.image('jakartaFair/jakartaFairBgInsideBooth'));
							stageFront.setGraphicSize(Std.int(stageFront.width * 1.2),Std.int(stageFront.height * 1.2));
							stageFront.updateHitbox();
							stageFront.antialiasing = true;
							stageFront.scrollFactor.set(1, 1);
							stageFront.active = false;
							add(stageFront);

							//Now for the colorable ceiling!
							colorableGround = new FlxSprite(-500,-100).loadGraphic(Paths.image('jakartaFair/jakartaFairBgColorableRoof'));
							colorableGround.setGraphicSize(Std.int(colorableGround.width * 1.2),Std.int((colorableGround.height * 1.2)));
							colorableGround.updateHitbox();
							colorableGround.antialiasing = true;
							colorableGround.scrollFactor.set(1,1);
							colorableGround.active = false;
							colorableGround.color.setRGB(1,1,1,0);
							add(colorableGround);
							isChromaScreen = false; //the ceiling is RGB light!
							originalColor = colorableGround.color; //store the default color!
							colorableGround.visible = false; //Hide the RGB light first before begin!

							//now back to final closest to the camera.
							var stageCurtains:FlxSprite = new FlxSprite(-500,-100).loadGraphic(Paths.image('jakartaFair/jakartaFairBgRearSpeakers'));
							stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 1.2),Std.int(stageFront.height * 1.2));
							stageCurtains.updateHitbox();
							stageCurtains.antialiasing = true;
							stageCurtains.scrollFactor.set(1.5, 1.5);
							stageCurtains.active = false;
							add(stageCurtains);
						}
					case 'qmoveph':
						{
							defaultCamZoom = 0.9;
							curStage = 'qmoveph';
							var bg:FlxSprite = new FlxSprite(-200, -100).loadGraphic(Paths.image('qmoveph/DefaultBackground'));
							bg.setGraphicSize(Std.int(bg.width *1.1), Std.int(bg.height * 1.1));
							bg.antialiasing = true;
							bg.scrollFactor.set(0.9, 0.9);
							bg.active = false;
							add(bg);
						}
					case 'cruelThesis':
						{
							//JOELwindows7: LOL Van Elektronishe with Cruel Angel Thesis lol Evangelion
							defaultCamZoom = 0.9;
							curStage = 'cruelThesis';
							var bg:FlxSprite = new FlxSprite(-200, -100).loadGraphic(Paths.image('VanElektronische/VanElektronische_corpThesis'));
							bg.setGraphicSize(Std.int(bg.width *1.2), Std.int(bg.height * 1.2));
							bg.antialiasing = true;
							bg.scrollFactor.set(0.9, 0.9);
							bg.active = false;
							add(bg);
						}
					case 'lapanganParalax':
						{
							defaultCamZoom = 0.9;
							curStage = 'lapanganParalax';
							var bg:FlxSprite = new FlxSprite(-200, -100).loadGraphic(Paths.image('lapanganParalax/Bekgron'));
							bg.setGraphicSize(Std.int(bg.width * 1.2), Std.int(bg.height * 1.2));
							bg.antialiasing = true;
							bg.scrollFactor.set(0.3, 0.3);
							bg.active = false;
							add(bg);

							var bg2:FlxSprite = new FlxSprite(-200, -150).loadGraphic(Paths.image('lapanganParalax/Betwaangron'));
							bg2.setGraphicSize(Std.int(bg2.width * 1.2), Std.int(bg2.height * 1.2));
							bg2.antialiasing = true;
							bg2.scrollFactor.set(0.5, 0.5);
							bg2.active = false;
							add(bg2);

							var bg3:FlxSprite = new FlxSprite(-200, -50).loadGraphic(Paths.image('lapanganParalax/Betweengron'));
							bg3.setGraphicSize(Std.int(bg3.width * 1.2), Std.int(bg3.height * 1.2));
							bg3.antialiasing = true;
							bg3.scrollFactor.set(0.7, 0.7);
							bg3.active = false;
							add(bg3);

							var stageFront:FlxSprite = new FlxSprite(-200, -100).loadGraphic(Paths.image('lapanganParalax/Midgron'));
							stageFront.setGraphicSize(Std.int(stageFront.width * 1.2), Std.int(stageFront.height * 1.2));
							stageFront.updateHitbox();
							stageFront.antialiasing = true;
							stageFront.scrollFactor.set(0.9, 0.9);
							stageFront.active = false;
							add(stageFront);

							var stageCurtains:FlxSprite = new FlxSprite(-200, -100).loadGraphic(Paths.image('lapanganParalax/Forgron'));
							stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 1.2), Std.int(stageCurtains.height * 1.2));
							stageCurtains.updateHitbox();
							stageCurtains.antialiasing = true;
							stageCurtains.scrollFactor.set(1.3, 1.3);
							stageCurtains.active = false;
							add(stageCurtains);
						}
					case 'blank':
						{
							defaultCamZoom = 0.5;
							curStage = 'blank';
							// JOELwindows7: Just blank. nothing.
							// chroma key color is #000000 . well, it's hard, yes, 
							// so if you need chroma key, you should green screen instead.
						}
					case 'greenscreen':
						{
							defaultCamZoom = 0.5;
							curStage = 'greenscreen';
							//JOELwindows7: turns out you can generate graphic with Make Graphic! 
							// it is even there on the FlxSprite construction wow!
							// read function of `schoolIntro`. there's a variable called `red` which is the FlxSprite of full red.
							// so, now you can chroma key full green!
							// heh what the peck man? GREEN is #008000 (dim green)!?? but LIME is #00FF00 (full green)?!? really bro?!
							// you confused me!!! the true green was supposed to be full green #00FF00 what the peck, Flixel?!
							colorableGround = new FlxSprite(-800, -500).makeGraphic(FlxG.width * 5, FlxG.height * 5, FlxColor.LIME);
							colorableGround.setGraphicSize(Std.int(colorableGround.width * 5),Std.int(colorableGround.height * 5));
							colorableGround.updateHitbox();
							colorableGround.antialiasing = true;
							colorableGround.scrollFactor.set(0.1,0.1);
							colorableGround.active = false;
							add(colorableGround);
							originalColor = colorableGround.color; //store the original color first!
							isChromaScreen = true; //The background is chroma screen
						}
					case 'bluechroma':
						{
							//JOELwindows7: same as greenscreen but blue. not to be confused with blue screen of death!
							defaultCamZoom = 0.5;
							curStage = 'bluechroma';
							colorableGround = new FlxSprite(-800, -500).makeGraphic(FlxG.width * 5, FlxG.height * 5, FlxColor.BLUE);
							colorableGround.setGraphicSize(Std.int(colorableGround.width * 5),Std.int(colorableGround.height * 5));
							colorableGround.updateHitbox();
							colorableGround.antialiasing = true;
							colorableGround.scrollFactor.set(0.1,0.1);
							colorableGround.active = false;
							add(colorableGround);
							originalColor = colorableGround.color; //store the original color first!
							isChromaScreen = true; //The background is chroma screen
						}
					case 'semple':
						{
							//JOELwindows7: Stuart Semple is multidisciplinary Bristish artist! A painter, and more.
							// He is famous for the pinkest color you've ever seen.
							// https://culturehustle.com/products/pink-50g-powdered-paint-by-stuart-semple
							// and peck Anish Kapoor.
							defaultCamZoom = 0.5;
							curStage = 'semple';
							// JOELwindows7: to me, that pinkest pink looks like magenta! at least on screen. idk how about in person
							// because no camera has the ability to capture way over Pink Semple had.
							colorableGround = new FlxSprite(-800, -500).makeGraphic(FlxG.width * 5, FlxG.height * 5, FlxColor.MAGENTA);
							colorableGround.setGraphicSize(Std.int(colorableGround.width * 5),Std.int(colorableGround.height * 5));
							colorableGround.updateHitbox();
							colorableGround.antialiasing = true;
							colorableGround.scrollFactor.set(0.1,0.1);
							colorableGround.active = false;
							add(colorableGround);
							originalColor = colorableGround.color; //store the original color first!
							isChromaScreen = true; //The background is chroma screen
						}
					case 'whitening':
						{
							//JOELwindows7: This looks familiar. oh no.
							//anyway. USE THIS SCREEN IF YOU WANT TO CHANGE COLOR with FULL RGB!
							//BEST SCREEN FOR FULL RGB COLOR!!!
							defaultCamZoom = 0.5;
							curStage = 'whitening';
							// JOELwindows7: guys, pls don't blamm me. it's nothing to do. let's assume it's purely coincidental.
							colorableGround = new FlxSprite(-800, -500).makeGraphic(FlxG.width * 5, FlxG.height * 5, FlxColor.WHITE);
							colorableGround.setGraphicSize(Std.int(colorableGround.width * 5),Std.int(colorableGround.height * 5));
							colorableGround.updateHitbox();
							colorableGround.antialiasing = true;
							colorableGround.scrollFactor.set(0.1,0.1);
							colorableGround.active = false;
							add(colorableGround);
							originalColor = colorableGround.color; //store the original color first!
							isChromaScreen = true; //The background is chroma screen
						}
					case 'kuning':
						{
							//JOELwindows7: yellow this one out
							defaultCamZoom = 0.5;
							curStage = 'kuning';
							colorableGround = new FlxSprite(-800, -500).makeGraphic(FlxG.width * 5, FlxG.height * 5, FlxColor.YELLOW);
							colorableGround.setGraphicSize(Std.int(colorableGround.width * 5),Std.int(colorableGround.height * 5));
							colorableGround.updateHitbox();
							colorableGround.antialiasing = true;
							colorableGround.scrollFactor.set(0.1,0.1);
							colorableGround.active = false;
							add(colorableGround);
							originalColor = colorableGround.color; //store the original color first!
							isChromaScreen = true; //The background is chroma screen
						}
					case 'blood':
						{
							//JOELwindows7: red screen
							defaultCamZoom = 0.5;
							curStage = 'blood';
							colorableGround = new FlxSprite(-800, -500).makeGraphic(FlxG.width * 5, FlxG.height * 5, FlxColor.RED);
							colorableGround.setGraphicSize(Std.int(colorableGround.width * 5),Std.int(colorableGround.height * 5));
							colorableGround.updateHitbox();
							colorableGround.antialiasing = true;
							colorableGround.scrollFactor.set(0.1,0.1);
							colorableGround.active = false;
							add(colorableGround);
							originalColor = colorableGround.color; //store the original color first!
							isChromaScreen = true; //The background is chroma screen
						}
					default:
						{
							defaultCamZoom = 0.9;
							curStage = 'stage';
							var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
							if(FlxG.save.data.antialiasing)
								{
									bg.antialiasing = true;
								}
							bg.scrollFactor.set(0.9, 0.9);
							bg.active = false;
							add(bg);

							var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
							stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
							stageFront.updateHitbox();
							if(FlxG.save.data.antialiasing)
								{
									stageFront.antialiasing = true;
								}
							stageFront.scrollFactor.set(0.9, 0.9);
							stageFront.active = false;
							add(stageFront);

							//JOELwindows7: reinstall stage light and this time, I added bloom yay!
							var stageLight:FlxSprite = new FlxSprite(-100, -80).loadGraphic(Paths.image('stage_light'));
							stageLight.setGraphicSize(Std.int(stageLight.width * 1), Std.int(stageLight.height * 1));
							stageLight.updateHitbox();
							stageLight.antialiasing = true;
							stageLight.scrollFactor.set(1.3,1.3);
							stageLight.active = false;

							//JOELwindows7: here's the bloom of that lighting
							colorableGround = new FlxSprite(-100, -80).loadGraphic(Paths.image('stage_light_bloom'));
							colorableGround.setGraphicSize(Std.int(colorableGround.width * 2),Std.int(colorableGround.height * 2));
							colorableGround.updateHitbox();
							colorableGround.antialiasing = true;
							colorableGround.scrollFactor.set(1.3,1.3);
							colorableGround.active = false;

							//JOELwindows7: make sure order is correct
							add(colorableGround);
							add(stageLight);
							colorableGround.visible = false; //initially off for performer safety.

							var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
							stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
							stageCurtains.updateHitbox();
							if(FlxG.save.data.antialiasing)
								{
									stageCurtains.antialiasing = true;
								}
							stageCurtains.scrollFactor.set(1.3, 1.3);
							stageCurtains.active = false;

							add(stageCurtains);
						}
				}
			}
		}
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

		var curGf:String = '';
		switch (gfCheck)
		{
			case 'gf-car':
				curGf = 'gf-car';
			case 'gf-christmas':
				curGf = 'gf-christmas';
			case 'gf-pixel':
				curGf = 'gf-pixel';
			case 'gf-ht':
				//JOELwindows7: doned the gf-ht
				curGf = 'gf-ht';
			case 'gf-covid':
				curGf = 'gf-covid';
			case 'gf-placeholder':
				curGf = 'gf-placeholder';
			default:
				curGf = 'gf';
		}

		gf = new Character(400, 130, curGf);
		gf.scrollFactor.set(0.95, 0.95);

		dad = new Character(100, 100, SONG.player2);

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf' | 'gf-covid' | 'gf-ht' | 'gf-placeholder':
				//JOELwindows7: multi same with other gf variants. the Home Theater also had left down up right as well!
				//NO, not the deviant of sacred timeline, geez calm down TVA wtf lmao!!!
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}
			case 'gf-standalone':
				//JOELwindows7: reserved for future use
				//basically gf get down from speaker and duet against player 1
				dad.y += 100;
				dad.x -= 100;
				switch(curGf){
					case 'gf':
						//remove the gf from speaker
					case 'gf-ht':
						//don't do anything and stay cool. no change.
					default:
						//do something if the GF is speaker.
				}
			case "spooky":
				dad.y += 200;
			case "monster":
				dad.y += 100;
			case 'monster-christmas':
				dad.y += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas':
				dad.x -= 500;
			case 'senpai':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
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

				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'hookx':
				// JOELwindows7:
				// I am sorry to happened. I have no idea.
				// world is bad. not worth living
				// but why give up, we got something
				// take my hand. I'll be waiting you outside
				dad.y += 100;
				dad.x -= 150;
			case 'placeholder':
				dad.y += 100;
				dad.x -= 150;
				camPos.set(dad.getGraphicMidpoint().x + 220, dad.getGraphicMidpoint().y);
			default:
				trace("Oh no! it looks like you forgot the offset position data for Player 2 " + SONG.player2);
				FlxG.log.add("Forgot offset position data for Player2 " + SONG.player2);
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);

		// JOELwindows7: REPOSITIONING PER BOYFRIEND
		switch(SONG.player1)
		{
			case 'bf':
				//No need, the stage repositionings has already based on bf itself
				// its positioning has been for bf himself
			case 'placeholder':
				boyfriend.y -= 220;
			default:
				//no repositioning
		}
		// Optional unless your character is not default bf

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;
				if (FlxG.save.data.distractions)
				{
					resetFastCar();
					add(fastCar);
				}

			case 'mall':
				boyfriend.x += 200;

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'jakartaFair':
				boyfriend.x += 250;
				dad.x -= 100;
				gf.x -= 100;
				gf.y -= 50;
			case 'qmoveph':
				boyfriend.x += 300;
				dad.x -= 200;
			case 'cruelThesis':
				boyfriend.x += 300;
				boyfriend.y += 50;
				dad.x -= 200;
				dad.y += 50;
			case 'lapanganParalax':
				boyfriend.x += 200;
				dad.x -= 100;
			case 'blank':
				boyfriend.x += 500;
				dad.x -= 400;
				gf.y -= 100;
			case 'greenscreen':
				// JOELwindows7: copy my blank above to here bellow.
				// so to further make it easier to separate somehow in the meme editing.. idk
				boyfriend.x += 500;
				dad.x -= 400;
				gf.y -= 100;
			case 'bluechroma':
				// JOELwindows7: in case you need blue chroma as well..
				boyfriend.x += 500;
				dad.x -= 400;
				gf.y -= 100;
			case 'semple':
				// JOELwindows7: Stuart Semple's Pinkest pink!!!
				// Do not play if you are any related to Anish Kapoor both DNA / blood and professional field
				// Penalty applies to all Kapoor starting from Anish Kapoor, inherits, and friends that within his idea, unless they decided
				// to betray Kapoor monopolism proprietarism so penalty terminates starting from that traitor to friends within traitor's opposition and inherits.
				// Penalties for mentioned defendants are demonetized from Dasandim UBI free Kvz program, etc.
				// anyway, so uh, we need HDR to brightestly pinkest pink.
				boyfriend.x += 500;
				dad.x -= 400;
				gf.y -= 100;
			case 'whitening':
				// JOELwindows7: don't use light mode! it will burn your eyes!
				boyfriend.x += 500;
				dad.x -= 400;
				gf.y -= 100;
			case 'kuning':
				// JOELwindows7: Yellow day!
				boyfriend.x += 500;
				dad.x -= 400;
				gf.y -= 100;
			case 'blood':
				// JOELwindows7: Red screen!
				boyfriend.x += 500;
				dad.x -= 400;
				gf.y -= 100;
			default:
				if(SONG.useCustomStage){
					repositionThingsInStage(curStage);
				} else {
					trace("Hey uh, we missing the stage offset information for stage " + curStage + " guys.");
					FlxG.log.add("Missing stage offset positioning for " + curStage);
				}
		}

		if (!PlayStateChangeables.Optimize)
		{
			add(gf);

			// Shitty layering but whatev it works LOL
			if (curStage == 'limo')
				add(limo);

			add(dad);
			add(boyfriend);
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

		doof = new DialogueBox(false, dialogue, SONG.hasDialogueChat); //JOELwindows7: make it global, pls!
		eoof = new DialogueBox(false, epilogue, SONG.hasEpilogueChat); //JOELwinodws7: epilogue box too!
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;
		eoof.scrollFactor.set(); //JOELwindows7: also set scroll factor too for epilogue box!
		eoof.finishThing = endSong; //JOELwindows7: ahh, now I get it. the callable variable is filled right here. okay! I thought..

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		if (PlayStateChangeables.useDownscroll)
			strumLine.y = FlxG.height - 165;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		cpuStrums = new FlxTypedGroup<FlxSprite>();

		generateStaticArrows(0);
		generateStaticArrows(1);

		// startCountdown();

		if (SONG.song == null)
			trace('song is null???');
		else
			trace('song looks gucci');

		generateSong(SONG.song);

		trace('generated');

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		trace("cam follow set"); //JOELwindows7: trace now

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		trace("add cam follow");

		#if !mobile
		//JOELwindows7: issue with Android version, this function crash!
		FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
		#else
		FlxG.camera.follow(camFollow, LOCKON, 0.008);
		//use Banbud's trickster .008
		//JOELwindows7: from Klavier & Verwex
		// https://github.com/KlavierGayming/FNF-Micd-Up-Mobile/blob/main/source/PlayState.hx
		/*camera lockon/follow tutorial:
		0.01 - Real fucking slow
		0.04 - Normal 60Fps speed
		0.10 - 90 Fps speed
		0.16 - Micd up speed*/
		#end
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		trace("set cam FlxG");

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		if (FlxG.save.data.songPosition) // I dont wanna talk about this code :(
		{
			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar'));
			if (PlayStateChangeables.useDownscroll)
				songPosBG.y = FlxG.height * 0.9 + 45;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);

			songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, 90000);
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
			add(songPosBar);

			var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - (SONG.song.length * 5), songPosBG.y, 0, SONG.song, 16);
			if (PlayStateChangeables.useDownscroll)
				songName.y -= 3;
			songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);
			songName.cameras = [camHUD];
		}

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		if (PlayStateChangeables.useDownscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		// healthBar
		add(healthBar);

		trace("add HP bar"); //JOELwindows7: where the heck crash source?! android

		//JOELwindows7: add reupload watermark
		//usually, YouTube mod showcase only shows gameplay
		//and there are some naughty youtubers who did not credit link in description neither comment.
		reuploadWatermark = new FlxText(
			(FlxG.width/2) - 100,(FlxG.height/2) + 50,0,
			"Download Last Funkin Moments ($0) https://github.com/Perkedel/kaded-fnf-mods,\n"
			+ "Kade Engine ($0) https://github.com/KadeDev/Kade-Engine ,\n" 
			+ "and vanilla funkin ($0) https://github.com/ninjamuffin99/Funkin\n"
			, 12);
		reuploadWatermark.setPosition((FlxG.width/2) - (reuploadWatermark.width / 2),(FlxG.height/2) + 50); 
		//Ah damn. the pivot of all Haxe Object is top left! 
		//right, let's just work this all around anyway.
		//there I got it. hopefully it's centered.
		reuploadWatermark.scrollFactor.set();
		reuploadWatermark.setFormat(
			Paths.font("vcr.ttf"), 
			12, FlxColor.WHITE, 
			CENTER, 
			FlxTextBorderStyle.OUTLINE,FlxColor.BLACK
			);
		add(reuploadWatermark);
		reuploadWatermark.visible = false;
		//follow this example, you must be protected too from those credit-less YouTubers the bastards!
		//We anchored the watermark dead center, just 50 px down abit.

		//JOELwindows7: I add watermark Perkedel Mod
		// Add Kade Engine watermark
		kadeEngineWatermark = new FlxText(4, healthBarBG.y
			+ 50, 0,
			SONG.song
			+ " - "
			+ CoolUtil.difficultyFromInt(storyDifficulty)
			+ (Main.watermarks ? " | KE " + MainMenuState.kadeEngineVer : "")
			+ (Main.perkedelMark ? " | LFM " + MainMenuState.lastFunkinMomentVer : "")
			, 16);
		kadeEngineWatermark.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		kadeEngineWatermark.scrollFactor.set();
		add(kadeEngineWatermark);

		if (PlayStateChangeables.useDownscroll)
			kadeEngineWatermark.y = FlxG.height * 0.9 + 45;

		scoreTxt = new FlxText(FlxG.width / 2 - 235, healthBarBG.y + 30, 0, "", 20); 
		//JOELwindows7: move this up a bit due to elongated texts. 
		//Y was 50px beneath health bar BG

		scoreTxt.screenCenter(X);

		originalX = scoreTxt.x;

		scoreTxt.scrollFactor.set();

		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		add(scoreTxt);

		replayTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0, "REPLAY",
			20);
		replayTxt.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		replayTxt.borderSize = 4;
		replayTxt.borderQuality = 2;
		replayTxt.scrollFactor.set();
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
		if (PlayStateChangeables.botPlay && !loadRep)
			add(botPlayState);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		//JOELwindows7: install pause button
		addPauseButton(Std.int((FlxG.width/2)-(128/2)), 80);
		trace("install pause button");

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		doof.cameras = [camHUD];
		eoof.cameras = [camHUD]; //JOELwindows7: stick the epilogue to camera
		pauseButton.cameras = [camHUD]; //JOELwindows7: stick the pause button to camera
		//touchscreenButtons.cameras = [camHUD]; //JOELwindows7: stick the touchscreen buttons to camera
		if (FlxG.save.data.songPosition)
		{
			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
		}
		kadeEngineWatermark.cameras = [camHUD];
		reuploadWatermark.cameras = [camHUD]; //JOELwindows7: stick the reupload watermark to camera
		if (loadRep)
			replayTxt.cameras = [camHUD];

		//JOELwindows7: install touchscreen buttons
		if(FlxG.save.data.useTouchScreenButtons){
			trace("Installing touchscreen buttons...");
			addTouchScreenButtons(4, false);
			trace("Installed touchscreen buttons");
			//onScreenGameplayButtons.cameras = [camHUD];
		}

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		trace('starting');

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
						//JOELwindows7: vibrate the device
						Controls.vibrate(0,2700);
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
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
					//JOELwindows7: vibrate device as it this angery
					Controls.vibrate(0, 1000);
					schoolIntro(doof);
				case 'roses-midi': //JOELwindows7: for midi version
					FlxG.sound.play(Paths.sound('ANGRY-midi'));
					//JOELwindows7: vibrate device as it this angery
					Controls.vibrate(0, 1000);
					schoolIntro(doof);
				case 'thorns' | 'thorns-midi':
					schoolIntro(doof);
				default:
					//JOELwindows7: Heuristic for using JSON chart instead
					if(SONG.hasDialogueChat){
						schoolIntro(doof);
					} else {
						trace("No School Intro info in isStoryMode for " + curSong + ". start coundown anyway");
						startCountdown();
					}
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				//JOELwindows7: also bring the fix to if not story mode, freeplay thingie
				default:
					trace("No something School Intro to do in freeplay mode for " + curSong + ". start countdown anyway");
					startCountdown();
			}
		}

		if (!loadRep)
			rep = new Replay("na");

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, releaseInput);
		super.create();
		trace("grepke super create e");

		//JOELwindows7: install debugge haxeflixeler
		//commands
		FlxG.console.registerFunction("startFakeCountdown", function(){
			startFakeCountdown();
		});
		FlxG.console.registerFunction("trainStart", function(){
			trainStart();
		});
		FlxG.console.registerFunction("trainReset", function(){
			trainReset();
		});
		FlxG.console.registerFunction("fastCarDrive", function(){
			fastCarDrive();
		});
		FlxG.console.registerFunction("resetFastCar", function(){
			resetFastCar();
		});
		FlxG.console.registerFunction("debugSeven", function(){
			haveDebugSevened = true;
		});
		FlxG.console.registerFunction("lightningStrikeShit", function(){
			lightningStrikeShit();
		});

		//JOELwindows7: why the peck with touchscreen button game crash on second run?!
		trace("finish create PlayState");
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		trace("has school intro " + Std.string(dialogueBox));
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

		//JOELwindows7: this could've been easier here.
		// pre lowercasing the song name (schoolIntro)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();

		//JOELwindows7: here pay attention for senpai songs
		if (songLowercase == 'roses' 
			|| songLowercase == 'thorns' 
			|| songLowercase == 'roses-midi' 
			|| songLowercase == 'thorns-midi'
			)
		{
			remove(black);

			if (songLowercase == 'thorns' || songLowercase == 'thorns-midi')
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

					//JOELwindows7: omg what?!?!
					if (songLowercase == 'thorns' || songLowercase == 'thorns-midi')
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
								FlxG.sound.play(
									Paths.sound(
										songLowercase == 'thorns-midi'?
										'Senpai_Dies-midi':
										'Senpai_Dies'
										), 
									1, false, null, true, function()
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
								//JOELwindows7: I hope this is asynchronous here.
								// vibrate device in this seconden
								new FlxTimer().start(2.4, function(deadTime:FlxTimer){
									if(FlxG.save.data.vibration){
										Controls.vibrate(0,2800);
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

	//JOELwindows7: schoolOutro thingy before endSong function in case
	//it had end dialogue a.k.a. Epilogue
	//inspired from above dialogue launcher School intro
	function schoolOutro(?dialogueBox:DialogueBox):Void
	{
		//first, hide these botom bars and their icosn
		//healthBar.visible = false;
		//healthBarBG.visible = false;
		iconP1.visible = false;
		iconP2.visible = false;

		//First, mute the music and vocals. like endSong.
		//also disable the pause to prevent accident pause by press enter which also moves the dialogue.
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;

		//Stop the music and vocal too
		//FlxG.sound.music.stop();
		//vocals.stop();

		//Pay attention for the pre-dialogue effect show like in Rose, senpai got mad thingy
		switch(SONG.song.toLowerCase()){
			default:
				{

				}
		}

		if(dialogueBox != null){
			inCutscene = true;
			
			//omg what?
			switch(SONG.song.toLowerCase())
			{
				default:
					add(dialogueBox);
			}
		} else endSong();

		//it looks like the finishThing variable calling means call the function who called it again. right?
		//so it then fell to the empty dialog.
	}

	var startTimer:FlxTimer;
	var fakeTimer:FlxTimer; //JOELwindows7: for fake timing stuff like fake countdown somthing
	var perfectMode:Bool = false;

	var luaWiggles:Array<WiggleEffect> = [];
	var hscriptWiggles:Array<WiggleEffect> = []; //JOELwindows7: same but hscript

	#if ((windows) && cpp)
	public static var luaModchart:ModchartState = null;
	public static var stageScript:ModchartState = null;
	#end
	//JOELwindows7: same as above but hscript.
	public static var hscriptModchart:HaxeScriptState = null;
	public static var stageHscript:HaxeScriptState = null;

	// function startCountdown(silent:Bool = false, invisible:Bool = false, reversed:Bool = false):Void
	function startCountdown():Void //unfortunately parametering doesn't work pls help pass parameter.
	{
		var silent:Bool = SONG.silentCountdown;
		var invisible:Bool = SONG.invisibleCountdown;
		var reversed:Bool = SONG.reversedCountdown;

		trace("startCountdown! Begin Funkin now");
		inCutscene = false;

		//JOELwindows7:visiblize buttons
		/*
		if(onScreenGameplayButtons != null){
			trace("visible touchscreen buttons");
			//onScreenGameplayButtons.visible = true;
			//onScreenGameplayButtons.alpha = 0;
		}
		*/
		//trace("visible touchscreen buttons");
		//showOnScreenGameplayButtons();

		trace("Generate Static arrows");
		appearStaticArrows();
		//generateStaticArrows(0);
		//generateStaticArrows(1);

		if (startTime != 0)
		{
			var toBeRemoved = [];
			for(i in 0...unspawnNotes.length)
			{
				var dunceNote:Note = unspawnNotes[i];

				if (dunceNote.strumTime - startTime <= 0)
					toBeRemoved.push(dunceNote);
				else if (dunceNote.strumTime - startTime < 3500)
				{
					notes.add(dunceNote);

					if (dunceNote.mustPress)
						dunceNote.y = (playerStrums.members[Math.floor(Math.abs(dunceNote.noteData))].y
							+ 0.45 * (startTime - dunceNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
								2)) - dunceNote.noteYOff;
					else
						dunceNote.y = (strumLineNotes.members[Math.floor(Math.abs(dunceNote.noteData))].y
							+ 0.45 * (startTime - dunceNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
								2)) - dunceNote.noteYOff;
					toBeRemoved.push(dunceNote);
				}
			}

			for(i in toBeRemoved)
				unspawnNotes.remove(i);
		}

		// pre lowercasing the song name (startCountdown)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
		switch (songLowercase)
		{
			case 'dad-battle':
				songLowercase = 'dadbattle';
			case 'philly-nice':
				songLowercase = 'philly';
		}
		#if ((windows) && cpp)
		if (executeModchart)
		{
			luaModchart = ModchartState.createModchartState();
			luaModchart.executeState('start', [songLowercase]);
		}
		if (executeStageScript && stageScript != null)
		{
			stageScript.executeState('start',[songLowercase]);
		}
		#end
		//JOELwindows7: now for the hscript init
		if(executeModHscript)
		{
			hscriptModchart = HaxeScriptState.createModchartState();
			hscriptModchart.executeState('start',[songLowercase]);
			hscriptModchart.setVar('executeModchart', executeModchart);
			hscriptModchart.setVar('executeModHscript', executeModHscript);
		}
		//JOELwindows7: tell Lua script whether hscript is running too
		#if ((windows) && cpp)
		if(executeModchart){
			luaModchart.setVar('executeModchart', executeModchart);
			luaModchart.setVar('executeModHscript', executeModHscript);
		}
		if (executeStageScript && stageScript != null){
			stageScript.setVar('executeModchart', executeModchart);
			stageScript.setVar('executeModHscript', executeModHscript);
		}
		#end

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			boyfriend.playAnim('idle');

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
			introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";
			//JOELwindows7: detect MIDI suffix
			var detectMidiSuffix:String = '-midi';
			var midiSuffix:String = "midi";
			
			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					trace(value + " - " + curStage);
					introAlts = introAssets.get(value);
					if (curStage.contains('school'))
						altSuffix = '-pixel';
				}
			}

			//JOELwindows7: scan MIDI suffix in the song name
			if(songLowercase.contains(detectMidiSuffix.trim())){
				midiSuffix = detectMidiSuffix;
			} else
				midiSuffix = "";

			switch (swagCounter)

			{
				case 0:
					//JOELwindows7:Lol! I added reverse
					if(!silent)
						FlxG.sound.play(Paths.sound((reversed?'intro1':'intro3') + altSuffix + midiSuffix), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					// if(invisible) ready.visible = false;
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					if(!silent)
						FlxG.sound.play(Paths.sound('intro2' + altSuffix + midiSuffix), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					if(invisible) set.visible = false;
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					if(!silent)
						FlxG.sound.play(Paths.sound((reversed?'intro3':'intro1') + altSuffix), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					if(invisible) go.visible = false;
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					if(!silent)
						FlxG.sound.play(Paths.sound('introGo' + altSuffix + midiSuffix), 0.6);
					//JOELwindows7: now visiblize the touchscreen buttons
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
				case 4:
					//JOELwindows7: just add trace for fun
					trace("Run the song now!");
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
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
		var key = FlxKey.toStringMap.get(Keyboard.__convertKeyCode(evt.keyCode));

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

	private function handleInput(evt:KeyboardEvent):Void
	{ // this actually handles press inputs

		if (PlayStateChangeables.botPlay || loadRep || paused)
			return;

		// first convert it from openfl to a flixel key code
		// then use FlxKey to get the key's name based off of the FlxKey dictionary
		// this makes it work for special characters

		@:privateAccess
		var key = FlxKey.toStringMap.get(Keyboard.__convertKeyCode(evt.keyCode));

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

		var dataNotes = [];
		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && daNote.noteData == data)
				dataNotes.push(daNote);
		}); // Collect notes that can be hit

		dataNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime)); // sort by the earliest note

		if (dataNotes.length != 0)
		{
			var coolNote = null;

			for (i in dataNotes)
				if (!i.isSustainNote)
				{
					coolNote = i;
					break;
				}

			if (coolNote == null) // Note is null, which means it's probably a sustain note. Update will handle this (HOPEFULLY???)
			{
				return;
			}

			if (dataNotes.length > 1) // stacked notes or really close ones
			{
				for (i in 0...dataNotes.length)
				{
					if (i == 0) // skip the first note
						continue;

					var note = dataNotes[i];

					if (!note.isSustainNote && (note.strumTime - coolNote.strumTime) < 2)
					{
						trace('found a stacked/really close note ' + (note.strumTime - coolNote.strumTime));
						// just fuckin remove it since it's a stacked note and shouldn't be there
						note.kill();
						notes.remove(note, true);
						note.destroy();
					}
				}
			}

			goodNoteHit(coolNote);
			var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
			ana.hit = true;
			ana.hitJudge = Ratings.CalculateRating(noteDiff, Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));
			ana.nearestNote = [coolNote.strumTime, coolNote.noteData, coolNote.sustainLength];
		}
		else if (!FlxG.save.data.ghost && songStarted)
		{
			noteMiss(data, null);
			ana.hit = false;
			ana.hitJudge = "shit";
			ana.nearestNote = [];
			health -= 0.10;
		}
	}

	var songStarted = false;

	function startSong():Void
	{
		//JOELwindows7: visiblize the watermark once the song has begun
		reuploadWatermark.visible = true;
		//then the Update() function above will invisibilize again
		//after 8 curBeats.

		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
		{
			#if sys
			if (!isStoryMode && isSM)
			{
				trace("Loading " + pathToSm + "/" + sm.header.MUSIC);
				var bytes = File.getBytes(pathToSm + "/" + sm.header.MUSIC);
				var sound = new Sound();
				sound.loadCompressedDataFromByteArray(bytes.getData(), bytes.length);
				FlxG.sound.playMusic(sound);
			}
			else
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
			#else
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
			#end
		}

		//FlxG.sound.music.onComplete = endSong;
		FlxG.sound.music.onComplete = checkEpilogueChat; 
		//JOELwindows7: now instead pls check the epilogue chat!
		vocals.play();

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		if (FlxG.save.data.songPosition)
		{
			remove(songPosBG);
			remove(songPosBar);
			remove(songName);

			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar'));
			if (PlayStateChangeables.useDownscroll)
				songPosBG.y = FlxG.height * 0.9 + 45;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);

			songPosBar = new FlxBar(songPosBG.x
				+ 4, songPosBG.y
				+ 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, songLength
				- 1000);
			songPosBar.numDivisions = 1000;
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
			add(songPosBar);

			var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - (SONG.song.length * 5), songPosBG.y, 0, SONG.song, 16);
			if (PlayStateChangeables.useDownscroll)
				songName.y -= 3;
			songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);

			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
			songName.cameras = [camHUD];
		}

		// Song check real quick
		switch (curSong)
		{
			case 'Bopeebo' | 'Philly Nice' | 'Blammed' | 'Cocoa' | 'Eggnog':
				allowedToHeadbang = true;
			default:
				allowedToHeadbang = SONG.allowedToHeadbang; //JOELwindows7: define by the JSON chart instead
				//use "allowedToHeadbang": true to your JSON chart (per difficulty) to enable headbangs.
		}

		if (useVideo)
			GlobalVideo.get().resume();

		#if (windows && cpp)
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
		vocals.time = startTime;
		Conductor.songPosition = startTime;
		startTime = 0;

		for(i in 0...unspawnNotes.length)
			if (unspawnNotes[i].strumTime < startTime)
				unspawnNotes.remove(unspawnNotes[i]);
	}

	var debugNum:Int = 0;

	public function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		#if sys
		if (SONG.needsVoices && !isSM)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();
		#else
		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();
		#end

		trace('loaded vocals');

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		// Per song offset check
		#if (windows && sys) //JOELwindows7: make this work if there is sys & is Windows
		// pre lowercasing the song name (generateSong)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
		switch (songLowercase)
		{
			case 'dad-battle':
				songLowercase = 'dadbattle';
			case 'philly-nice':
				songLowercase = 'philly';
		}

		var songPath = 'assets/data/' + songLowercase + '/';
		
		#if sys
		if (isSM && !isStoryMode)
			songPath = pathToSm;
		#end

		for (file in sys.FileSystem.readDirectory(songPath))
		{
			var path = haxe.io.Path.join([songPath, file]);
			if (!sys.FileSystem.isDirectory(path))
			{
				if (path.endsWith('.offset'))
				{
					trace('Found offset file: ' + path);
					songOffset = Std.parseFloat(file.substring(0, file.indexOf('.off')));
					break;
				}
				else
				{
					trace('Offset file not found. Creating one @: ' + songPath);
					sys.io.File.saveContent(songPath + songOffset + '.offset', '');
				}
			}
		}
		#end
		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped


		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] + FlxG.save.data.offset + songOffset;
				if (daStrumTime < 0)
					daStrumTime = 0;
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);

				if (!gottaHitNote && PlayStateChangeables.Optimize)
					continue;

				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				if (susLength > 0)
					swagNote.isParent = true;

				var type = 0;

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

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
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			// defaults if no noteStyle was found in chart
			var noteTypeCheck:String = 'normal';

			if (PlayStateChangeables.Optimize && player == 0)
				continue;

			if (SONG.noteStyle == null)
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

			switch (noteTypeCheck)
			{
				case 'pixel':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
					}
				case 'saubo':
					//JOELwindows7: LFM original noteskin
					babyArrow.frames = Paths.getSparrowAtlas('Saubo_NOTE_assets');
					for (j in 0...4)
					{
						babyArrow.animation.addByPrefix(dataColor[j], 'arrow' + dataSuffix[j]);	
					}

					var lowerDir:String = dataSuffix[i].toLowerCase();

					babyArrow.animation.addByPrefix('static', 'arrow' + dataSuffix[i]);
					babyArrow.animation.addByPrefix('pressed', lowerDir + ' press', 24, false);
					babyArrow.animation.addByPrefix('confirm', lowerDir + ' confirm', 24, false);

					babyArrow.x += Note.swagWidth * i;
	
					if(FlxG.save.data.antialiasing)
						{
							babyArrow.antialiasing = true;
						}
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
				default:
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
					for (j in 0...4)
					{
						babyArrow.animation.addByPrefix(dataColor[j], 'arrow' + dataSuffix[j]);	
					}

					var lowerDir:String = dataSuffix[i].toLowerCase();

					babyArrow.animation.addByPrefix('static', 'arrow' + dataSuffix[i]);
					babyArrow.animation.addByPrefix('pressed', lowerDir + ' press', 24, false);
					babyArrow.animation.addByPrefix('confirm', lowerDir + ' confirm', 24, false);

					babyArrow.x += Note.swagWidth * i;

					if(FlxG.save.data.antialiasing)
						{
							babyArrow.antialiasing = true;
						}
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			babyArrow.alpha = 0;
			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				//babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			switch (player)
			{
				case 0:
					cpuStrums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			if (PlayStateChangeables.Optimize)
				babyArrow.x -= 275;

			cpuStrums.forEach(function(spr:FlxSprite)
			{
				spr.centerOffsets(); // CPU arrows start out slightly off-center
			});

			strumLineNotes.add(babyArrow);
		}
	}

	private function appearStaticArrows():Void
	{
		strumLineNotes.forEach(function(babyArrow:FlxSprite)
		{
			if (isStoryMode)
				babyArrow.alpha = 1;
		});
	}

	//JOELwindows7: make public for modchart
	public function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			#if (windows && cpp)
			DiscordClient.changePresence("PAUSED on "
				+ SONG.song
				+ " ("
				+ storyDifficultyText
				+ ") "
				+ Ratings.GenerateLetterRank(accuracy),
				"Acc: "
				+ HelperFunctions.truncateFloat(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Misses: "
				+ misses, iconRPC);
			#end
			if (!startTimer.finished)
				startTimer.active = false;

			//JOELwindows7: inviblize buttoneings
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
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if (windows && cpp)
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
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), iconRPC);
			}
			#end

			//JOELwindows7: revisiblize touchscreen buttons
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
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();

		#if (windows && cpp)
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

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var startedFakeCounting:Bool = false; //JOELwindows7: oh fake countdown
	var canPause:Bool = true;
	var nps:Int = 0;
	var maxNPS:Int = 0;

	public static var songRate = 1.5;

	public var stopUpdate = false;
	public var removedVideo = false;

	public var currentBPM = 0;

	public var updateFrame = 0;

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end

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
	
							TimingStruct.addTiming(beat,i.value,endBeat, 0); // offset in this case = start time since we don't have a offset
							
							if (currentIndex != 0)
							{
								var data = TimingStruct.AllTimings[currentIndex - 1];
								data.endBeat = beat;
								data.length = (data.endBeat - data.startBeat) / (data.bpm / 60);
								TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length;
							}
	
							currentIndex++;
						}
					}
					updateFrame++;
			}
			else if (updateFrame != 5)
				updateFrame++;
	

			var timingSeg = TimingStruct.getTimingAtTimestamp(Conductor.songPosition);
	
			if (timingSeg != null)
			{
	
				var timingSegBpm = timingSeg.bpm;
	
				if (timingSegBpm != Conductor.bpm)
				{
					trace("BPM CHANGE to " + timingSegBpm);
					Conductor.changeBPM(timingSegBpm, false);
				}
	
			}

		var newScroll = PlayStateChangeables.scrollSpeed;

		for(i in SONG.eventObjects)
		{
			switch(i.type)
			{
				case "Scroll Speed Change":
					if (i.position < curDecimalBeat)
						newScroll = i.value;
			}
		}

		PlayStateChangeables.scrollSpeed = newScroll;
	
		if (PlayStateChangeables.botPlay && FlxG.keys.justPressed.ONE)
			camHUD.visible = !camHUD.visible;

		if (useVideo && GlobalVideo.get() != null && !stopUpdate)
		{
			if (GlobalVideo.get().ended && !removedVideo)
			{
				remove(videoSprite);
				FlxG.stage.window.onFocusOut.remove(focusOut);
				FlxG.stage.window.onFocusIn.remove(focusIn);
				removedVideo = true;
			}
		}

		#if ((windows) && cpp)
		if (executeModchart && luaModchart != null && songStarted)
		{
			luaModchart.setVar('songPos', Conductor.songPosition);
			luaModchart.setVar('hudZoom', camHUD.zoom);
			luaModchart.setVar('curBeat', HelperFunctions.truncateFloat(curDecimalBeat,3));
			luaModchart.setVar('cameraZoom', FlxG.camera.zoom);
			luaModchart.executeState('update', [elapsed]);

			for (key => value in luaModchart.luaWiggles) 
			{
				trace('wiggle le gaming');
				value.update(elapsed);
			}

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

			//JOELwindows7: okay I think this is a good place to constantly update variable
			//that must be updated. idk.
			luaModchart.setVar("originalColor", originalColor);
			luaModchart.setVar("isChromaScreen", isChromaScreen);
		}

		//JOELwindows7: for the stagescript
		if(executeStageScript && stageScript != null && songStarted){
			stageScript.setVar('songPos',Conductor.songPosition);
			stageScript.setVar('hudZoom', camHUD.zoom);
			stageScript.setVar('curBeat', HelperFunctions.truncateFloat(curDecimalBeat,3));
			stageScript.setVar('cameraZoom',FlxG.camera.zoom);
			stageScript.executeState('update', [elapsed]);

			stageScript.setVar("originalColor", originalColor);
			stageScript.setVar("isChromaScreen", isChromaScreen);
		}
		#end
		//JOELwindows7: the hscript version
		if (executeModHscript && hscriptModchart != null && songStarted){
			hscriptModchart.setVar('songPos',Conductor.songPosition);
			hscriptModchart.setVar('hudZoom', camHUD.zoom);
			hscriptModchart.setVar('curBeat', HelperFunctions.truncateFloat(curDecimalBeat,3));
			hscriptModchart.setVar('cameraZoom',FlxG.camera.zoom);
			hscriptModchart.executeState('update', [elapsed]);

			for (key => value in hscriptModchart.haxeWiggles) 
			{
				trace('wiggle le gaming');
				value.update(elapsed);
			}

			/*for (i in 0...strumLineNotes.length) {
				var member = strumLineNotes.members[i];
				member.x = hscriptModchart.getVar("strum" + i + "X", "float");
				member.y = hscriptModchart.getVar("strum" + i + "Y", "float");
				member.angle = hscriptModchart.getVar("strum" + i + "Angle", "float");
			}*/

			FlxG.camera.angle = hscriptModchart.getVar('cameraAngle', 'float');
			camHUD.angle = hscriptModchart.getVar('camHudAngle','float');

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

			//JOELwindows7: okay I think this is a good place to constantly update variable
			//that must be updated. idk.
			hscriptModchart.setVar("originalColor", originalColor);
			hscriptModchart.setVar("isChromaScreen", isChromaScreen);
		}
		//JOELwindows7: stage hscript
		if(executeStageHscript && stageHscript != null && songStarted){
			stageHscript.setVar('songPos',Conductor.songPosition);
			stageHscript.setVar('hudZoom', camHUD.zoom);
			stageHscript.setVar('curBeat', HelperFunctions.truncateFloat(curDecimalBeat,3));
			stageHscript.setVar('cameraZoom',FlxG.camera.zoom);
			stageHscript.executeState('update', [elapsed]);

			stageHscript.setVar("originalColor", originalColor);
			stageHscript.setVar("isChromaScreen", isChromaScreen);
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

		switch (curStage)
		{
			case 'philly':
				if (trainMoving && !PlayStateChangeables.Optimize)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
		}

		super.update(elapsed);

		//JOELwindows7: update heartbeat moments
		updateHeartbeat();

		if(curBeat > 8){
			//JOELwindows7: invisiblize watermark after 8 curBeat
			//to prevent view obstruction
			reuploadWatermark.visible = false;
		}

		scoreTxt.text = Ratings.CalculateRanking(
			songScore, 
			songScoreDef, 
			nps, 
			maxNPS, 
			accuracy, 
			heartRate, 
			heartTierIsRightNow
			);

		var lengthInPx = scoreTxt.textField.length * scoreTxt.frameHeight; // bad way but does more or less a better job

		scoreTxt.x = (originalX - (lengthInPx / 2)) + 335;
		
		//JOELwindows7: add luckydog7 if pressed back button on Android
		//also add mouse click pause button
		if (
			(
				controls.PAUSE || 
				havePausened 
				#if android 
				|| FlxG.android.justReleased.BACK 
				#end
				) 
			&& startedCountdown && canPause && !cannotDie
			)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				trace('GITAROO MAN EASTER EGG');
				FlxG.switchState(new GitarooPause());
			}
			else
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			havePausened = false;
		}

		if (FlxG.keys.justPressed.SEVEN || haveDebugSevened)
			//JOELwindows7: have debug sevened, for chart option in pause menu maybe
		// lol comment necklace!
		{
			if (useVideo)
			{
				GlobalVideo.get().stop();
				remove(videoSprite);
				#if sys
				FlxG.stage.window.onFocusOut.remove(focusOut);
				FlxG.stage.window.onFocusIn.remove(focusIn);
				#end
				removedVideo = true;
			}
			cannotDie = true;
			#if (windows && cpp)
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
			removeTouchScreenButtons();
			FlxG.switchState(new ChartingState());
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if ((windows) && cpp)
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			if (stageScript != null){
				stageScript.die();
				stageScript = null;
			}
			#end

			//JOELwindows7: scronch hscript
			if (hscriptModchart != null)
			{
				hscriptModchart.die();
				hscriptModchart = null;
			}
			if (stageHscript != null){
				stageHscript.die();
				stageHscript = null;
			}

			
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
				FlxG.stage.window.onFocusOut.remove(focusOut);
				FlxG.stage.window.onFocusIn.remove(focusIn);
				removedVideo = true;
			}
			removeTouchScreenButtons();
			FlxG.switchState(new AnimationDebug(SONG.player2));
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if ((windows) && cpp)
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			if (stageScript != null){
				stageScript.die();
				stageScript = null;
			}
			#end
			//JOELwindows7: scronch hscript
			if (hscriptModchart != null)
			{
				hscriptModchart.die();
				hscriptModchart = null;
			}
			if (stageHscript != null){
				stageHscript.die();
				stageHscript = null;
			}
		}

		if (FlxG.keys.justPressed.ZERO)
		{
			removeTouchScreenButtons();
			FlxG.switchState(new AnimationDebug(SONG.player1));
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if ((windows) && cpp)
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			if (stageScript != null){
				stageScript.die();
				stageScript = null;
			}
			#end
			//JOELwindows7: scronch hscript
			if (hscriptModchart != null)
			{
				hscriptModchart.die();
				hscriptModchart = null;
			}
			if (stageHscript != null){
				stageHscript.die();
				stageHscript = null;
			}
		}
		
		if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future, credit: Shadow Mario#9396
			if (!usedTimeTravel && Conductor.songPosition + 10000 < FlxG.sound.music.length) 
			{
				usedTimeTravel = true;
				FlxG.sound.music.pause();
				vocals.pause();
				Conductor.songPosition += 10000;
				notes.forEachAlive(function(daNote:Note)
				{
					if(daNote.strumTime - 500 < Conductor.songPosition) {
						daNote.active = false;
						daNote.visible = false;

					
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});
				for (i in 0...unspawnNotes.length) {
					var daNote:Note = unspawnNotes[0];
					if(daNote.strumTime - 500 >= Conductor.songPosition) {
						break;
					}
					unspawnNotes.splice(unspawnNotes.indexOf(daNote), 1);
				}

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

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;
			/*@:privateAccess
				{
					FlxG.sound.music._channel.
			}*/
			songPositionBar = Conductor.songPosition;

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
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			// Make sure Girlfriend cheers only for certain songs
			if (allowedToHeadbang)
			{
				// Don't animate GF if something else is already animating her (eg. train passing)
				if (gf.animation.curAnim.name == 'danceLeft'
					|| gf.animation.curAnim.name == 'danceRight'
					|| gf.animation.curAnim.name == 'idle')
				{
					// Per song treatment since some songs will only have the 'Hey' at certain times
					switch (curSong)
					{
						case 'Philly Nice':
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
						case 'Bopeebo':
							{
								// Where it starts || where it ends
								if (curBeat > 5 && curBeat < 130)
								{
									if (curBeat % 8 == 7)
									{
										if (!triggeredAlready)
										{
											randomizeColoring(); //JOELwindows7: change the stage light color!
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									}
									else
										triggeredAlready = false;
								}
							}
						case 'Blammed':
							{
								if (curBeat > 30 && curBeat < 190)
								{
									if (curBeat < 90 || curBeat > 128)
									{
										if (curBeat % 4 == 2)
										{
											if (!triggeredAlready)
											{
												//randomizeColoring(); //JOELwindows7: change the stage light color!
												gf.playAnim('cheer');
												triggeredAlready = true;
											}
										}
										else
											triggeredAlready = false;
									}
								}
							}
						case 'Cocoa':
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
						case 'Eggnog':
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
						case 'Rule The World':
							{
								//JOELwindows7: okay how do I supposed to cheer?
								//copy from above and adjust beat.
								//oh God. well I gotta figure this one out.
								//
								//Okay so curBeat is curStep div by 4.
								//I think if curBeat modulo 4 is 0 means every new section?
								//yes they are. so there are 0 1 2 3 in curBeat modulo 4.
								//you can granularlize it if you want like 0 1 2 3 4 5 6 7 in curBeat % 8 etc.
								if(curBeat < 16 || 
									(curBeat > 80 && curBeat < 96) || 
									(curBeat > 160 && curBeat < 192) || 
									(curBeat > 264 && curBeat < 304)
									)
								{
									if(curBeat % 4 == 0 || curBeat % 4 == 2)
									{
										if(!triggeredAlready)
											{
												randomizeColoring();
												gf.playAnim('cheer');
												triggeredAlready = true;
											}
									} else triggeredAlready = false;
								}
							}
						case 'Well Meet Again':
						{
							//JOELwindows7: cheer on the beatdrop yeay
							if(!inCutscene && curBeat < 307) // make sure do this only when not in cutscene, & song still going
								if((curBeat > 80 && curBeat < 112) ||
									(curBeat > 176 && curBeat < 208) || 
									(curBeat > 272 && curBeat < 308)
									) 
									{
										//copy from the hardcode zoom milfe
										cheerNow(4,2,true);
									}
						}
						case 'fortritri':
						{
							//JOELwindows7: silence is music lmao
							//John Cage = 4'33", haha
							if(curBeat % 4 == 0)
							{
								if(!triggeredAlready){
									randomizeColoring();
									triggeredAlready = true;
								}
							} else triggeredAlready = false;
						}
					}
				}
			}

			#if ((windows) && cpp)
			if (luaModchart != null)
				luaModchart.setVar("mustHit", PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			if (stageScript != null)
				stageScript.setVar("mustHit",PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			#end
			if (hscriptModchart != null)
				hscriptModchart.setVar("mustHit",PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			if (stageHscript != null)
				stageHscript.setVar("mustHit",PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);

			if (camFollow.x != dad.getMidpoint().x + 150 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				var offsetX = 0;
				var offsetY = 0;
				#if ((windows) && cpp)
				if (luaModchart != null)
				{
					offsetX = luaModchart.getVar("followXOffset", "float");
					offsetY = luaModchart.getVar("followYOffset", "float");
				}
				#end
				//JOELwindows7: hscript cam offsetting
				if (hscriptModchart != null)
				{
					offsetX = hscriptModchart.getVar("followXOffset", "float");
					offsetY = hscriptModchart.getVar("followYOffset", "float");
				}
				camFollow.setPosition(dad.getMidpoint().x + 150 + offsetX, dad.getMidpoint().y - 100 + offsetY);
				#if ((windows) && cpp)
				if (luaModchart != null)
					luaModchart.executeState('playerTwoTurn', []);
				if (stageScript != null)
					stageScript.executeState('playerTwoTurn',[]);
				#end
				if (hscriptModchart != null)
					hscriptModchart.executeState('playerTwoTurn', []);
				if (stageHscript != null)
					stageHscript.executeState('playerTwoTurn',[]);
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

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
			{
				var offsetX = 0;
				var offsetY = 0;
				#if ((windows) && cpp)
				if (luaModchart != null)
				{
					offsetX = luaModchart.getVar("followXOffset", "float");
					offsetY = luaModchart.getVar("followYOffset", "float");
				}
				#end
				//JOELwindows7: hscript offsete
				if (hscriptModchart != null)
				{
					offsetX = hscriptModchart.getVar("followXOffset", "float");
					offsetY = hscriptModchart.getVar("followYOffset", "float");
				}
				camFollow.setPosition(boyfriend.getMidpoint().x - 100 + offsetX, boyfriend.getMidpoint().y - 100 + offsetY);

				#if ((windows) && cpp)
				if (luaModchart != null)
					luaModchart.executeState('playerOneTurn', []);
				if (stageScript != null)
					stageScript.executeState('playerOneTurn', []);
				#end
				if (hscriptModchart != null)
					hscriptModchart.executeState('playerOneTurn', []);
				if (stageHscript != null)
					stageHscript.executeState('playerOneTurn', []);

				switch (curStage)
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
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("curBPM", Conductor.bpm);
		FlxG.watch.addQuick("Closest Note", (unspawnNotes.length != 0 ? unspawnNotes[0].strumTime - Conductor.songPosition : "No note"));

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		//JOELwindows7: add more watches too
		FlxG.watch.addQuick("shinzouRateShit", heartRate);
		FlxG.watch.addQuick("songPositionShit", Conductor.songPosition);

		if (curSong == 'Fresh')
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

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
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

				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if (windows && cpp)
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
			else
				health = 1;
		}
		if (!inCutscene && FlxG.save.data.resetButton)
		{
			if (FlxG.keys.justPressed.R)
			{
				trace("Pressed self Eik Serkat button"); //JOELwindows7: add trace about that
				boyfriend.stunned = true;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if (windows && cpp)
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

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 3500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);
				if (!dunceNote.isSustainNote)
					dunceNote.cameras = [camNotes];
				else
					dunceNote.cameras = [camSustains];

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];

			notes.forEachAlive(function(daNote:Note)
			{
				// instead of doing stupid y > FlxG.height
				// we be men and actually calculate the time :)
				if (daNote.tooLate)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				if (!daNote.modifiedByLua)
				{
					if (PlayStateChangeables.useDownscroll)
					{
						if (daNote.mustPress)
							daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
								+ 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2)) - daNote.noteYOff;
						else
							daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
								+ 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2)) - daNote.noteYOff;
						if (daNote.isSustainNote)
						{
							// Remember = minus makes notes go up, plus makes them go down
							if (daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null)
								daNote.y += daNote.prevNote.height;
							else
								daNote.y += daNote.height / 2;

							// If not in botplay, only clip sustain notes when properly hit, botplay gets to clip it everytime
							if (!PlayStateChangeables.botPlay)
							{
								if ((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit)
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
							else
							{
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
								- 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2)) + daNote.noteYOff;
						else
							daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
								- 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2)) + daNote.noteYOff;
						if (daNote.isSustainNote)
						{
							daNote.y -= daNote.height / 2;

							if (!PlayStateChangeables.botPlay)
							{
								if ((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit)
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
							else
							{
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

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					if (SONG.song != 'Tutorial')
						camZooming = true;

					var altAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim)
							altAnim = '-alt';
					}
					
					// Accessing the animation name directly to play it
					var singData:Int = Std.int(Math.abs(daNote.noteData));
					dad.playAnim('sing' + dataSuffix[singData] + altAnim, true);

					if (FlxG.save.data.cpuStrums)
					{
						cpuStrums.forEach(function(spr:FlxSprite)
						{
							if (Math.abs(daNote.noteData) == spr.ID)
							{
								spr.animation.play('confirm', true);
							}
							if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
							{
								spr.centerOffsets();
								spr.offset.x -= 13;
								spr.offset.y -= 13;
							}
							else
								spr.centerOffsets();
						});
					}

					#if ((windows) && cpp)
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

					daNote.active = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				if (daNote.mustPress && !daNote.modifiedByLua)
				{
					daNote.visible = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].visible;
					daNote.x = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote)
						daNote.modAngle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
					if (daNote.sustainActive)
						daNote.alpha = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					daNote.modAngle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
				}
				else if (!daNote.wasGoodHit && !daNote.modifiedByLua)
				{
					daNote.visible = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].visible;
					daNote.x = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote)
						daNote.modAngle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].angle;
					if (daNote.sustainActive)
						daNote.alpha = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					daNote.modAngle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].angle;
				}

				if (daNote.isSustainNote)
				{
					daNote.x += daNote.width / 2 + 20;
					if (PlayState.curStage.startsWith('school'))
						daNote.x -= 11;
				}

				// trace(daNote.y);
				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				if ((daNote.mustPress && daNote.tooLate && !PlayStateChangeables.useDownscroll || daNote.mustPress && daNote.tooLate
					&& PlayStateChangeables.useDownscroll)
					&& daNote.mustPress)
				{
					if (daNote.isSustainNote && daNote.wasGoodHit)
						{
							daNote.kill();
							notes.remove(daNote, true);
						}
						else
						{
							if (loadRep && daNote.isSustainNote)
							{
								// im tired and lazy this sucks I know i'm dumb
								if (findByTime(daNote.strumTime) != null)
									totalNotesHit += 1;
								else
								{
									if (!daNote.isSustainNote)
										health -= 0.10;
									vocals.volume = 0;
									if (theFunne && !daNote.isSustainNote)
										noteMiss(daNote.noteData, daNote);
									if (daNote.isParent)
									{
										health -= 0.20; // give a health punishment for failing a LN
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
											health -= 0.20; // give a health punishment for failing a LN
											trace("hold fell over at " + daNote.spotInLine);
											for (i in daNote.parent.children)
											{
												i.alpha = 0.3;
												i.sustainActive = false;
											}
											if (daNote.parent.wasGoodHit)
												misses++;
											updateAccuracy();
										}
									}
								}
							}
							else
							{
								if (!daNote.isSustainNote)
									health -= 0.10;
								vocals.volume = 0;
								if (theFunne && !daNote.isSustainNote)
									noteMiss(daNote.noteData, daNote);

								if (daNote.isParent)
								{
									health -= 0.20; // give a health punishment for failing a LN
									trace("hold fell over at the start");
									for (i in daNote.children)
									{
										i.alpha = 0.3;
										i.sustainActive = false;
										trace(i.alpha);
									}
								}
								else
								{
									if (!daNote.wasGoodHit
										&& daNote.isSustainNote
										&& daNote.sustainActive
										&& daNote.spotInLine != daNote.parent.children.length)
									{
										health -= 0.20; // give a health punishment for failing a LN
										trace("hold fell over at " + daNote.spotInLine);
										for (i in daNote.parent.children)
										{
											i.alpha = 0.3;
											i.sustainActive = false;
											trace(i.alpha);
										}
										if (daNote.parent.wasGoodHit)
											misses++;
										updateAccuracy();
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
			cpuStrums.forEach(function(spr:FlxSprite)
			{
				if (spr.animation.finished)
				{
					spr.animation.play('static');
					spr.centerOffsets();
				}
			});
		}

		if (!inCutscene && songStarted)
			keyShit();

		//JOELwindows7: pause btton on screen
		if(FlxG.mouse.overlaps(pauseButton) && startedCountdown && canPause){
			if(FlxG.mouse.justPressed){
				if(!havePausened){
					havePausened = true;
				}
			}
		}
		//JOELwindows7: check Pausability
		if(startedCountdown && canPause){
			if(pauseButton != null){
				pauseButton.visible = true;
			}
		} else {
			if(pauseButton != null){
				pauseButton.visible = false;
			}
		}

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
	}

	//JOELwindows7: check if the song should display epilogue chat once the song has finished.
	function checkEpilogueChat():Void
	{
		//fade and hide the touchscreen button
		removeTouchScreenButtons();
		//if song has epilogue chat then do this
		if(SONG.hasEpilogueChat && (isStoryMode)){
			schoolOutro(eoof);
		} else endSong();
	}

	function endSong():Void
	{
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
		if (useVideo)
		{
			GlobalVideo.get().stop();
			FlxG.stage.window.onFocusOut.remove(focusOut);
			FlxG.stage.window.onFocusIn.remove(focusIn);
			PlayState.instance.remove(PlayState.instance.videoSprite);
		}

		if (isStoryMode)
			campaignMisses = misses;

		if (!loadRep)
			rep.SaveReplay(saveNotes, saveJudge, replayAna);
		else
		{
			PlayStateChangeables.botPlay = false;
			PlayStateChangeables.scrollSpeed = 1;
			PlayStateChangeables.useDownscroll = false;
		}

		if (FlxG.save.data.fpsCap > 290)
		{
			trace("return the FPS cap");
			//JOELwindows7: issue with Android version. cast lib current technic crash it
			#if !mobile
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(290);
			#end
		}

		trace("unload mod chart");

		#if ((windows) && cpp)
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
		//JOELwindows7: scronch hscript
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

		trace("clearing gameplay"); //JOELwindows7: you trace

		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		FlxG.sound.music.pause();
		vocals.pause();
		if (SONG.validScore)
		{
			// adjusting the highscore song name to be compatible
			// would read original scores if we didn't change packages
			var songHighscore = StringTools.replace(PlayState.SONG.song, " ", "-");
			switch (songHighscore)
			{
				case 'Dad-Battle':
					songHighscore = 'Dadbattle';
				case 'Philly-Nice':
					songHighscore = 'Philly';
			}

			#if !switch
			Highscore.saveScore(songHighscore, Math.round(songScore), storyDifficulty);
			Highscore.saveCombo(songHighscore, Ratings.GenerateLetterRank(accuracy), storyDifficulty);
			#end
		}
		trace("saved score now!");

		if (offsetTesting)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			offsetTesting = false;
			LoadingState.loadAndSwitchState(new OptionsMenu());
			FlxG.save.data.offset = offsetTest;
		}
		else
		{
			if (isStoryMode)
			{
				campaignScore += Math.round(songScore);

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;

					paused = true;

					FlxG.sound.music.stop();
					vocals.stop();
					if (FlxG.save.data.scoreScreen)
					{
						//JOELwindows7: check epilogue and play if it has one
						openSubState(
							new ResultsScreen(
								SONG.hasEpilogueVideo, 
								SONG.hasEpilogueVideo? 
								SONG.epilogueVideoPath: 
								"null"
								));
						new FlxTimer().start(1, function(tmr:FlxTimer)
							{
								inResults = true;
							});
					}
					else
					{
						FlxG.sound.playMusic(Paths.music('freakyMenu'));
						Conductor.changeBPM(102);
						// #if !mobile
						FlxG.switchState(
							SONG.hasEpilogueVideo? 
							VideoCutscener.getThe(SONG.epilogueVideoPath, new StoryMenuState()) : 
							new StoryMenuState());
						// #else
						// FlxG.switchState(new StoryMenuState());
						// #end
						//JOELwindows7: complicated! oh MY GOD!
					}

					#if ((windows) && cpp)
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
					//JOELwindows7: scronch hscript
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

					if (SONG.validScore)
					{
						#if newgrounds
						NGio.unlockMedal(60961);
						#end
						Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
					}

					StoryMenuState.unlockNextWeek(storyWeek);
				}
				else
				{
					// adjusting the song name to be compatible
					var songFormat = StringTools.replace(PlayState.storyPlaylist[0], " ", "-");
					switch (songFormat)
					{
						case 'Dad-Battle':
							songFormat = 'Dadbattle';
						case 'Philly-Nice':
							songFormat = 'Philly';
					}

					var poop:String = Highscore.formatSong(songFormat, storyDifficulty);

					trace('LOADING NEXT SONG');
					trace(poop);

					if (StringTools.replace(PlayState.storyPlaylist[0], " ", "-").toLowerCase() == 'eggnog')
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;

						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					prevCamFollow = camFollow;

					//JOELwindows7: wait wwiat atiw! remember the epilogue path first before go to the next song!
					var hasEpilogueVideo:Bool = SONG.hasEpilogueVideo;
					var epilogueVideoPath:String = SONG.epilogueVideoPath;
					//Okay you can now change the song.

					//JOELwindows7: wait, double safety standard pls.
					PlayState.SONG = Song.loadFromJson(poop, PlayState.storyPlaylist[0]);
					//JOELwindows7: conform the story mode oid based on dash is space like StoryMenuState.hx
					// also load heartspec
					PlayState.HEARTS = DokiDoki.loadFromJson("heartBeatSpec");
					FlxG.sound.music.stop();

					//JOELwindows7: if has video, then load the video first before going to new playstate!
					// #if !mobile
					LoadingState.loadAndSwitchState(
						hasEpilogueVideo?
						(VideoCutscener.getThe(epilogueVideoPath, 
							(SONG.hasVideo ? VideoCutscener.getThe(SONG.videoPath, new PlayState()) : new PlayState() )
						))
						: (SONG.hasVideo ? VideoCutscener.getThe(SONG.videoPath, new PlayState()) : new PlayState() )
					);
					// #else //workaround since this doesn't work in Android
					// LoadingState.loadAndSwitchState(new PlayState()); //Legacy
					// #end
					//JOELwindows7: oh God, so complicated. I hope it works!
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
					FlxG.switchState(new FreeplayState());
			}
		}
	}

	var endingSong:Bool = false;

	var hits:Array<Float> = [];
	var offsetTest:Float = 0;

	var timeShown = 0;
	var currentTimingShown:FlxText = null;

	private function popUpScore(daNote:Note):Void
	{
		var noteDiff:Float = -(daNote.strumTime - Conductor.songPosition);
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

		var daRating = daNote.rating;

		switch (daRating)
		{
			case 'shit':
				score = -300;
				combo = 0;
				misses++;
				health -= 0.06;
				ss = false;
				shits++;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit -= 1;
			case 'bad':
				daRating = 'bad';
				score = 0;
				health -= 0.03;
				ss = false;
				bads++;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 0.50;
			case 'good':
				daRating = 'good';
				score = 200;
				ss = false;
				goods++;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 0.75;
			case 'sick':
				if (health < 2)
					health += 0.04;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 1;
				sicks++;
		}


		// trace('Wife accuracy loss: ' + wife + ' | Rating: ' + daRating + ' | Score: ' + score + ' | Weight: ' + (1 - wife));

		if (daRating != 'shit' || daRating != 'bad')
		{
			songScore += Math.round(score);
			songScoreDef += Math.round(ConvertScore.convertScore(noteDiff));

			/* if (combo > 60)
					daRating = 'sick';
				else if (combo > 12)
					daRating = 'good'
				else if (combo > 4)
					daRating = 'bad';
			 */

			var pixelShitPart1:String = "";
			var pixelShitPart2:String = '';

			if (curStage.startsWith('school'))
			{
				pixelShitPart1 = 'weeb/pixelUI/';
				pixelShitPart2 = '-pixel';
			}

			rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
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

			var msTiming = HelperFunctions.truncateFloat(noteDiff, 3);
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

			var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
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

			if (!curStage.startsWith('school'))
			{
				rating.setGraphicSize(Std.int(rating.width * 0.7));
				if(FlxG.save.data.antialiasing)
					{
						rating.antialiasing = true;
					}
				comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
				if(FlxG.save.data.antialiasing)
					{
						comboSpr.antialiasing = true;
					}
			}
			else
			{
				rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
				comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
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
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
				numScore.screenCenter();
				numScore.x = rating.x + (43 * daLoop) - 50;
				numScore.y = rating.y + 100;
				numScore.cameras = [camHUD];

				if (!curStage.startsWith('school'))
				{
					if(FlxG.save.data.antialiasing)
						{
							numScore.antialiasing = true;
						}
					numScore.setGraphicSize(Std.int(numScore.width * 0.5));
				}
				else
				{
					numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
				}
				numScore.updateHitbox();

				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);

				add(numScore);

				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						numScore.destroy();
					},
					startDelay: Conductor.crochet * 0.002
				});

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
		#if ((windows) && cpp)
		if (luaModchart != null)
		{
			for (i in 0...pressArray.length) {
				if (pressArray[i] == true) {
				luaModchart.executeState('keyPressed', [keynameArray[i]]);
				}
			};
			
			for (i in 0...releaseArray.length) {
				if (releaseArray[i] == true) {
				luaModchart.executeState('keyReleased', [keynameArray[i]]);
				}
			};
			
		};
		//JOELwindows7: stage script keypressings
		if (stageScript != null)
		{
			for (i in 0...pressArray.length) {
				if (pressArray[i] == true) {
				stageScript.executeState('keyPressed', [keynameArray[i]]);
				}
			};
			
			for (i in 0...releaseArray.length) {
				if (releaseArray[i] == true) {
				stageScript.executeState('keyReleased', [keynameArray[i]]);
				}
			};

			//if (FlxG.keys.pressed){stageScript.executeState('rawKeyPressed',[Std.string(FlxG.keys.pressed)]);};
		};
		#end
		//JOELwindows7: lotsa hscript
		if (hscriptModchart != null)
		{
			for (i in 0...pressArray.length) {
				if (pressArray[i] == true) {
				hscriptModchart.executeState('keyPressed', [keynameArray[i]]);
				}
			};
			
			for (i in 0...releaseArray.length) {
				if (releaseArray[i] == true) {
				hscriptModchart.executeState('keyReleased', [keynameArray[i]]);
				}
			};

			//JOELwindows7: any keypresings here
			//if (FlxG.keys.pressed){hscriptModChart.executeState('rawKeyPressed',[Std.string(FlxG.keys.pressed)]);};
		};
		//JOELwindows7: stage script keypressings
		if (stageHscript != null)
		{
			for (i in 0...pressArray.length) {
				if (pressArray[i] == true) {
				stageHscript.executeState('keyPressed', [keynameArray[i]]);
				}
			};
			
			for (i in 0...releaseArray.length) {
				if (releaseArray[i] == true) {
				stageHscript.executeState('keyReleased', [keynameArray[i]]);
				}
			};

			//if (FlxG.keys.pressed){stageHscript.executeState('rawKeyPressed',[Std.string(FlxG.keys.pressed)]);};
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
					trace(daNote.sustainActive);
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
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !directionsAccounted[daNote.noteData])
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

				var hit = [false,false,false,false];

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
							anas[coolNote.noteData].hitJudge = Ratings.CalculateRating(noteDiff, Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));
							anas[coolNote.noteData].nearestNote = [coolNote.strumTime, coolNote.noteData, coolNote.sustainLength];
							goodNoteHit(coolNote);
						}
					}
				};
				
				if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay))
				{
					if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss') && boyfriend.animation.curAnim.curFrame >= 10)
						boyfriend.playAnim('idle');
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
		notes.forEachAlive(function(daNote:Note)
		{
			if (PlayStateChangeables.useDownscroll && daNote.y > strumLine.y || !PlayStateChangeables.useDownscroll && daNote.y < strumLine.y)
			{
				// Force good note hit regardless if it's too late to hit it or not as a fail safe
				if (PlayStateChangeables.botPlay && daNote.canBeHit && daNote.mustPress || PlayStateChangeables.botPlay && daNote.tooLate && daNote.mustPress)
				{
					if (loadRep)
					{
						// trace('ReplayNote ' + tmpRepNote.strumtime + ' | ' + tmpRepNote.direction);
						var n = findByTime(daNote.strumTime);
						trace(n);
						if (n != null)
						{
							goodNoteHit(daNote);
							boyfriend.holdTimer = daNote.sustainLength;
						}
					}
					else
					{
						goodNoteHit(daNote);
						boyfriend.holdTimer = daNote.sustainLength;
					}
				}
			}
		});

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay))
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss') && boyfriend.animation.curAnim.curFrame >= 10)
				boyfriend.playAnim('idle');
		}

		playerStrums.forEach(function(spr:FlxSprite)
		{
			if (keys[spr.ID] && spr.animation.curAnim.name != 'confirm')
				spr.animation.play('pressed', false);
			if (!keys[spr.ID])
				spr.animation.play('static', false);

			if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
			else
				spr.centerOffsets();
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

	public function focusOut()
	{
		if (paused)
			return;
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.pause();
			vocals.pause();
		}

		openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
	}

	public function focusIn()
	{
		// nada
	}

	public function backgroundVideo(source:String) // for background videos
	{
		#if (cpp)
		useVideo = true;

		FlxG.stage.window.onFocusOut.add(focusOut);
		FlxG.stage.window.onFocusIn.add(focusIn);

		var ourSource:String = "assets/videos/daWeirdVid/dontDelete.webm";
		#if (!mobile)
		//WebmPlayer.SKIP_STEP_LIMIT = 90;
		//GlobalVideo.getWebm().webm.SKIP_STEP_LIMIT = 90; //JOELwindows7: for original gwebdev
		#end
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
			//health -= 0.2;
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				//JOELwindows7: add girlfriend oop & aah for combo break,
				//Just like osu!
				FlxG.sound.play(Paths.soundRandom('GF_', 1, 2), 0.5);
				trace("Yah, sayang banget padahal kan udah " + Std.string(combo) + " kombo tadi :\'( ");

				gf.playAnim('sad');
			}
			combo = 0;
			misses++;

			if (daNote != null)
			{
				if (!loadRep)
				{
					saveNotes.push([
						daNote.strumTime,
						0,
						direction,
						166 * Math.floor((PlayState.rep.replay.sf / 60) * 1000) / 166
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
					166 * Math.floor((PlayState.rep.replay.sf / 60) * 1000) / 166
				]);
				saveJudge.push("miss");
			}

			// var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition);
			// var wife:Float = EtternaFunctions.wife3(noteDiff, FlxG.save.data.etternaMode ? 1 : 1.7);

			if (FlxG.save.data.accuracyMod == 1)
				totalNotesHit -= 1;

			if (daNote != null)
			{
				if (!daNote.isSustainNote)
					songScore -= 10;
			}
			else
				songScore -= 10;
			
			if(FlxG.save.data.missSounds)
				{
					//JOELwindows7: now the numbers of miss note sfx depends on the file yay!
					FlxG.sound.play(Paths.soundRandom('missnote', 1, numOfMissNoteSfx), FlxG.random.float(0.1, 0.2));
					// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
					// FlxG.log.add('played imss note');
				}

			//JOELwindows7: vibrate the miss
			Controls.vibrate(0,50);

			// Hole switch statement replaced with a single line :)
			boyfriend.playAnim('sing' + dataSuffix[direction] + 'miss', true);

			#if ((windows) && cpp)
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
	}

	function getKeyPresses(note:Note):Int
	{
		var possibleNotes:Array<Note> = []; // copypasted but you already know that

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
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

		note.rating = Ratings.CalculateRating(noteDiff, Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));

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
			note.rating = Ratings.CalculateRating(noteDiff);

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
				popUpScore(note);
				combo += 1;
			}
			else
				totalNotesHit += 1;

			switch (note.noteData)
			{
				case 2:
					boyfriend.playAnim('singUP', true);
				case 3:
					boyfriend.playAnim('singRIGHT', true);
				case 1:
					boyfriend.playAnim('singDOWN', true);
				case 0:
					boyfriend.playAnim('singLEFT', true);
			}

			#if ((windows) && cpp)
			if (luaModchart != null)
				luaModchart.executeState('playerOneSing', [note.noteData, Conductor.songPosition]);
			if (stageScript != null)
				stageScript.executeState('playerOneSing', [note.noteData, Conductor.songPosition, curBeat, curStep]);
			#end
			if (hscriptModchart != null)
				hscriptModchart.executeState('playerOneSing', [note.noteData, Conductor.songPosition, curBeat, curStep]);
			if (stageHscript != null)
				stageHscript.executeState('playerOneSing', [note.noteData, Conductor.songPosition, curBeat, curStep]);

			if (!loadRep && note.mustPress)
			{
				var array = [note.strumTime, note.sustainLength, note.noteData, noteDiff];
				if (note.isSustainNote)
					array[1] = -1;
				saveNotes.push(array);
				saveJudge.push(note.rating);
			}

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
				}
			});

			note.kill();
			notes.remove(note, true);
			note.destroy();

			//JOELwindows7: successfully step, add adrenaline heartbeat fass
			successfullyStep();

			updateAccuracy();
		}
	}

	var fastCarCanDrive:Bool = true;

	//JOELwindows7: make public for lua modchart
	public function resetFastCar():Void
	{
		if (FlxG.save.data.distractions)
		{
			fastCar.x = -12600;
			fastCar.y = FlxG.random.int(140, 250);
			fastCar.velocity.x = 0;
			fastCarCanDrive = true;
		}
	}

	//JOELwindows7: make public for lua modchart
	public function fastCarDrive()
	{
		if (FlxG.save.data.distractions)
		{
			FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

			fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
			fastCarCanDrive = false;
			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				resetFastCar();
			});
		}
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	//JOELwindows7: make public for lua modchart
	public function trainStart():Void
	{
		if (FlxG.save.data.distractions)
		{
			trainMoving = true;
			if (!trainSound.playing)
				trainSound.play(true);
		}
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (FlxG.save.data.distractions)
		{
			if (trainSound.time >= 4700)
			{
				startedMoving = true;
				gf.playAnim('hairBlow');
			}

			if (startedMoving)
			{
				phillyTrain.x -= 400;

				if (phillyTrain.x < -2000 && !trainFinishing)
				{
					phillyTrain.x = -1150;
					trainCars -= 1;

					if (trainCars <= 0)
						trainFinishing = true;
				}

				if (phillyTrain.x < -4000 && trainFinishing)
					trainReset();
			}
		}
	}

	//JOELwindows7: make public for lua modchart
	public function trainReset():Void
	{
		if (FlxG.save.data.distractions)
		{
			trace("train passes bye train"); //JOELwindows7: trace train reset
			gf.playAnim('hairFall');
			phillyTrain.x = FlxG.width + 200;
			trainMoving = false;
			// trainSound.stop();
			// trainSound.time = 0;
			trainCars = 8;
			trainFinishing = false;
			startedMoving = false;
		}
	}

	//JOELwindows7: make public for lua modchart
	public function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);

		//JOELwindows7: shock fear Heartbeat jumps
		increaseHR(fearShockAdd[heartTierIsRightNow]);

		//JOELwindows7: vibrate controllers
		Controls.vibrate(0,100);
	}

	var danced:Bool = false;

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		#if ((windows) && cpp)
		if (executeModchart && luaModchart != null)
		{
			luaModchart.setVar('curStep', curStep);
			luaModchart.executeState('stepHit', [curStep]);
		}
		if (executeStageScript && stageScript != null){
			stageScript.setVar('curStep',curStep);
			stageScript.executeState('stepHit',[curStep]);
		}
		#end
		if (executeModHscript && hscriptModchart != null)
		{
			hscriptModchart.setVar('curStep',curStep);
			hscriptModchart.executeState('stepHit',[curStep]);
		}
		if (executeStageHscript && stageHscript != null){
			stageHscript.setVar('curStep',curStep);
			stageHscript.executeState('stepHit',[curStep]);
		}

		// yes this updates every step.
		// yes this is bad
		// but i'm doing it to update misses and accuracy
		#if (windows && cpp)
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"Acc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC, true,
			songLength
			- Conductor.songPosition);
		#end
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		//JOELwindows7: install prelowecasing here too lucky uh frogot.
		// pre lowercasing the song name (create)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
			switch (songLowercase) {
				case 'dad-battle': songLowercase = 'dadbattle';
				case 'philly-nice': songLowercase = 'philly';
			}

		super.beatHit();

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, (PlayStateChangeables.useDownscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));
		}

		#if ((windows) && cpp)
		if (executeModchart && luaModchart != null)
		{
			luaModchart.executeState('beatHit', [curBeat]);
		}
		if (executeStageScript && stageScript != null){
			//stageScript.setVar('curBeat',curBeat);
			stageScript.executeState('beatHit',[curBeat]);
		}
		#end
		//JOELwindows7: hscriptoid
		if (executeModHscript && hscriptModchart != null)
		{
			//hscriptModchart.setVar('curBeat',curBeat);
			hscriptModchart.executeState('beatHit',[curBeat]);
		}
		if (executeStageHscript && stageHscript != null){
			//stageHscript.setVar('curBeat',curBeat);
			stageHscript.executeState('beatHit',[curBeat]);
		}

		if (curSong == 'Tutorial' && dad.curCharacter == 'gf')
		{
			if (SONG.notes[Math.floor(curStep / 16)].mustHitSection)
				dad.dance();
			else
			{
				if (curBeat == 73 || curBeat % 4 == 0 || curBeat % 4 == 1)
					dad.playAnim('danceLeft', true);
				else
					dad.playAnim('danceRight', true);
			}
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			if ((SONG.notes[Math.floor(curStep / 16)].mustHitSection || !dad.animation.curAnim.name.startsWith("sing")) && dad.curCharacter != 'gf')
				if ((curBeat % idleBeat == 0 || !idleToBeat) || dad.curCharacter == "spooky")
					dad.dance(idleToBeat);
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		if (FlxG.save.data.camzoom)
		{
			// HARDCODING FOR MILF ZOOMS!
			if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;

				//JOELwindows7: add vibrations!
				Controls.vibrate(0, 150);
			}

			//JOELwindows7: HARDCODING FOR WE'LL MEET YOU AGAIN ZOOMS!
			if (curSong.toLowerCase() == 'well meet again' && FlxG.camera.zoom < 1.35 && curBeat % 4 == 2 && curBeat < 307 && !inCutscene)
			{
				//the song is we'll meet again, camera not yet zoomed, when strum is in middle of bar, less than song length, not during cutscene
				//Reminder: CurBeat = CurStep / 4
	
				if((curBeat < 52) ||
					(curBeat > 80 && curBeat < 148) ||
					(curBeat > 176 && curBeat < 212) || //shutup, just coincidence. I know, so don't talk it.
					//Oh Wiro Sableng, Oh ok, I thought. Sorry.
					(curBeat > 224 && curBeat < 240) ||
					(curBeat > 256 && curBeat < 304)  //lmao! 1024 curStep = 256 curBeat
					) 
					camZoomNow(); 
			}

			if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0 && !inCutscene && !inResults)
			{
				//JOELwindows7: only do this when not in cutscene & not in result!
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0)
		{
			gf.dance();
		}

		if (!boyfriend.animation.curAnim.name.startsWith("sing") && (curBeat % idleBeat == 0 || !idleToBeat))
		{
			boyfriend.playAnim('idle', idleToBeat);
		}

		/*if (!dad.animation.curAnim.name.startsWith("sing"))
		{
			dad.dance();
		}*/

		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
		{
			boyfriend.playAnim('hey', true);
		}

		//JOELwindows7: found pay attention to this if player 2 is gf.
		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && (dad.curCharacter == 'gf' || dad.curCharacter == 'gf-ht') && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}

		switch (curStage)
		{
			case 'school':
				if (FlxG.save.data.distractions)
				{
					bgGirls.dance();
				}

			case 'mall':
				if (FlxG.save.data.distractions)
				{
					upperBoppers.animation.play('bop', true);
					bottomBoppers.animation.play('bop', true);
					santa.animation.play('idle', true);
				}

			case 'limo':
				if (FlxG.save.data.distractions)
				{
					grpLimoDancers.forEach(function(dancer:BackgroundDancer)
					{
						dancer.dance();
					});

					if (FlxG.random.bool(10) && fastCarCanDrive)
						fastCarDrive();
				}
			case "philly":
				if (FlxG.save.data.distractions)
				{
					if (!trainMoving)
						trainCooldown += 1;

					if (curBeat % 4 == 0)
					{
						trace("change light pls"); //JOELwindows7: add trace about light change
						phillyCityLights.forEach(function(light:FlxSprite)
						{
							light.visible = false;
						});

						curLight = FlxG.random.int(0, phillyCityLights.length - 1);

						phillyCityLights.members[curLight].visible = true;
						// phillyCityLights.members[curLight].alpha = 1;
					}
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					if (FlxG.save.data.distractions)
					{
						trace("Hey look train!"); //JOELwindows7: add trace about initiate train passing
						trainCooldown = FlxG.random.int(-4, 0);
						trainStart();
					}
				}
		}

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			if (FlxG.save.data.distractions)
			{
				lightningStrikeShit();
			}
		}
		//JOELwindows7: above is not my code. but idea!
		// for Gravis Ultrasound demo, RAIN.MID. you can manually lightning strike as the beat almost drop.
	}

	var curLight:Int = 0;
	//JOELwindows7: not my code. hey, Ninja! you should've white light like I do above
	//and randomize the color. look at randomizeColoring() above!

	//JOELwindows7: make cam zoom a function pls
	public function camZoomNow(howMuchZoom:Float = .015, howMuchZoomHUD:Float = .03, maxZoom:Float = 1.35) {
		if(FlxG.camera.zoom < maxZoom)
		{
			FlxG.camera.zoom += howMuchZoom;
			camHUD.zoom += howMuchZoomHUD;
		}
	}

	//JOELwindows7: make cheer a function
	public function cheerNow(
		outOfBeatFractioning:Int = 4, 
		doItOn:Int = 0, 
		randomizeColor:Bool = false, 
		justOne:Bool = false, 
		toWhichBg:Int = 0, 
		forceIt:Bool = false){
		if(curBeat % outOfBeatFractioning == doItOn)
		{
			if(!triggeredAlready)
				{
					if(randomizeColor)
						randomizeColoring(justOne, toWhichBg);
					gf.playAnim('cheer', forceIt);
					triggeredAlready = true;
				}
		} else triggeredAlready = false;
	}

	public function heyNow(
		outOfBeatFractioning:Int = 4, 
		doItOn:Int = 0, 
		randomizeColor:Bool = false, 
		justOne:Bool = false, 
		toWhichBg:Int = 0, 
		forceIt:Bool = false
		){
		if(curBeat % outOfBeatFractioning == doItOn)
		{
			if(!triggeredAlready)
				{
					if(randomizeColor)
						randomizeColoring(justOne, toWhichBg);
					boyfriend.playAnim('hey', forceIt);
					triggeredAlready = true;
				}
		} else triggeredAlready = false;
	}

	//JOELwindows7: just cheer & hey
	public function justCheer(forceIt:Bool = false){
		gf.playAnim('cheer', forceIt);
	}

	public function justHey(forceIt:Bool = false){
		boyfriend.playAnim('hey', forceIt);
	}

	//JOELwindows7: prepare Colorable bg
	public function prepareColorableBg(useImage:Bool = false, 
		positionX:Null<Float> = -500, positionY:Null<Float> = -500, 
		?imagePath:String = '', ?animated:Bool = false,
		color:Null<FlxColor> = FlxColor.WHITE,
		width:Int = 1, height:Int = 1, 
		upscaleX:Int = 1, upscaleY:Int = 1, 
		antialiasing:Bool = true,
		scrollFactorX:Float = .5, scrollFactorY:Float = .5,
		active:Bool = false, callNow:Bool = true, ?unique:Bool = false)
	{

		colorableGround = 
			useImage?
				new FlxSprite(positionX, positionY).loadGraphic(Paths.image('jakartaFair/jakartaFairBgColorableRoof'), animated, width, height, unique):
				new FlxSprite(positionX, positionY).makeGraphic(FlxG.width * 5, FlxG.height * 5, FlxColor.LIME)
				;
		colorableGround.setGraphicSize(Std.int(colorableGround.width * upscaleX),Std.int(colorableGround.height * upscaleY));
		colorableGround.updateHitbox();
		colorableGround.antialiasing = antialiasing;
		colorableGround.scrollFactor.set(scrollFactorX,scrollFactorY);
		colorableGround.active = active;
		if(callNow)
			add(colorableGround);
		originalColor = colorableGround.color;
	}

	//JOELwindows7: randomize the color of the colorableGround
	public function randomizeColoring(justOne:Bool = false, toWhichBg:Int = 0)
	{	
		if(colorableGround != null){
			colorableGround.visible = true;
			colorableGround.color = FlxColor.fromRGBFloat(FlxG.random.float(0.0,1.0),FlxG.random.float(0.0,1.0),FlxG.random.float(0.0,1.0));
			trace("now colorable color is " + colorableGround.color.toHexString());
		}
		if(bgAll != null)
			if(justOne){
				bgAll.members[toWhichBg].visible = true;
				bgAll.members[toWhichBg].color = FlxColor.fromRGBFloat(FlxG.random.float(0.0,1.0),FlxG.random.float(0.0,1.0),FlxG.random.float(0.0,1.0));
				trace("now bg " + Std.string(bgAll.members[toWhichBg].ID) + " color is " + colorableGround.color.toHexString());
			} else
				bgAll.forEach(function(theBg:FlxSprite){
					if(multiColorable[theBg.ID])
					{
						theBg.visible = true;
						theBg.color = FlxColor.fromRGBFloat(FlxG.random.float(0.0,1.0),FlxG.random.float(0.0,1.0),FlxG.random.float(0.0,1.0));
						trace("now bg " + Std.string(theBg.ID) + " color is " + theBg.color.toHexString());
					}
				});
	}

	//JOELwindows7: copy above, but this let you choose color
	public function chooseColoringColor(color:FlxColor = FlxColor.WHITE, justOne:Bool = true, toWhichBg:Int = 0)
	{
		if(colorableGround != null){
			colorableGround.visible = true;
			colorableGround.color = color;
			trace("now colorable color is " + colorableGround.color.toHexString());
		}
		if(bgAll != null)
		{
			if(justOne)
			{
				bgAll.members[toWhichBg].visible = true;
				bgAll.members[toWhichBg].color = color;
				trace("now bg " + Std.string(bgAll.members[toWhichBg].ID) + " color is " + colorableGround.color.toHexString());
			} else {
				bgAll.forEach(function(theBg:FlxSprite){
					if(multiColorable[theBg.ID]){
						theBg.visible = true;
						theBg.color = color;
						trace("now bg " + Std.string(theBg.ID) + " color is " + theBg.color.toHexString());
					}
				});
			}
		}
	}

	//JOELwindows7: To hide coloring incase you don't need it anymore
	public function hideColoring(justOne:Bool = false, toWhichBg:Int = 0) {
		if(colorableGround != null)
			if(isChromaScreen){
				colorableGround.color = originalColor;
			} else colorableGround.visible = false;
		if(bgAll != null)
			if(justOne){
				bgAll.members[toWhichBg].color = multiOriginalColor[toWhichBg];
				if(multiIsChromaScreen[toWhichBg])
					bgAll.members[toWhichBg].visible = false;
			} else
				bgAll.forEach(function(theBg:FlxSprite){
					theBg.color = multiOriginalColor[theBg.ID];
					if(multiIsChromaScreen[theBg.ID])
						theBg.visible = false;
				});
	}

	//JOELwindows7: manage heartbeat moments
	function startHeartBeat(){
		HEARTS = DokiDoki.loadFromJson("heartBeatSpec");
		var chooseIndex = 0;
		switch(SONG.player1){
			case 'bf': chooseIndex = 0;
			case 'gf': chooseIndex = 1;
			default: chooseIndex = 0;
		}
		heartTierIsRightNow = 0;
		HEART = HEARTS.heartSpecs[chooseIndex];
		heartRate = HEART.initHR;
		minHR = HEART.minHR;
		maxHR = HEART.maxHR;
		successionAdrenalAdd = HEART.successionAdrenalAdd;
		fearShockAdd = HEART.fearShockAdd;
		relaxMinusPerBeat = HEART.relaxMinusPerBeat;
		heartTierBoundaries = HEART.heartTierBoundaries;
	}
	function updateHeartbeat(){
		//update the tier status
		if(heartRate > heartTierBoundaries[heartTierIsRightNow]){

		}

		if(curBeat % 4 == 0){
			//Relax heartbeat
			if(!slowedAlready)
			{
				increaseHR(-relaxMinusPerBeat[heartTierIsRightNow]);
				slowedAlready = true;
			}
		} else slowedAlready = false;
	}
	function successfullyStep(){
		increaseHR(successionAdrenalAdd[heartTierIsRightNow]);
	}
	function checkWhichHeartTierWent(giveHB:Int){
		// if(giveHB > heartTierBoundaries[heartTierIsRightNow] && giveHB < heartTierBoundaries[heartTierIsRightNow+1]){
		// 	heartTierIsRightNow++;
		// } else if (giveHB > heartTierBoundaries[heartTierIsRightNow+1]){

		// }

		//Hard code bcause logic brainstorm is haarde
		if (giveHB < heartTierBoundaries[0])
			heartTierIsRightNow = 0;
		else if(giveHB >= heartTierBoundaries[0] && giveHB < heartTierBoundaries[1])
			heartTierIsRightNow = 1;
		else if(giveHB >= heartTierBoundaries[1] && giveHB < heartTierBoundaries[2])
			heartTierIsRightNow = 2;
		else if(giveHB >= heartTierBoundaries[2] && giveHB < heartTierBoundaries[3])
			heartTierIsRightNow = 3;
		else if(giveHB >= heartTierBoundaries[3]){
			//uhhh, idk..
		}
	}
	public function increaseHR(forHowMuch:Int = 0){
		heartRate += forHowMuch;

		if(heartRate > maxHR){
			heartRate = maxHR;
		}
		if (heartRate < minHR){
			heartRate = minHR;
		}

		//update the tier status
		checkWhichHeartTierWent(heartRate);
	}

	//JOELwindows7: fake countdowns! also countups too!
	public function startFakeCountdown(silent:Bool = false, invisible:Bool = false, reversed:Bool = false){
		//JOELwindows7: install songLowercaser and its heurestic for specific songs bellow
		// pre lowercasing the song name (create)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
			switch (songLowercase) {
				case 'dad-battle': songLowercase = 'dadbattle';
				case 'philly-nice': songLowercase = 'philly';
			}
		
		startedFakeCounting = true;
		
		var swagCounter:Int = 0;

		fakeTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer){
			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', [
				'weeb/pixelUI/ready-pixel',
				'weeb/pixelUI/set-pixel',
				'weeb/pixelUI/date-pixel'
			]);
			introAssets.set('schoolEvil', [
				'weeb/pixelUI/ready-pixel',
				'weeb/pixelUI/set-pixel',
				'weeb/pixelUI/date-pixel'
			]);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";
			//JOELwindows7: detect MIDI suffix
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

			//JOELwindows7: scan MIDI suffix in the song name
			if(songLowercase.contains(detectMidiSuffix.trim())){
				midiSuffix = detectMidiSuffix;
			} else
				midiSuffix = "";
			
			switch(swagCounter){
				case 0:
					if(!silent)
						FlxG.sound.play(Paths.sound(reversed? 'intro1' :'intro3' + altSuffix + midiSuffix), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					if(invisible) ready.visible = false;
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					if(!silent)
						FlxG.sound.play(Paths.sound('intro2' + altSuffix + midiSuffix), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();
					
					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					if(invisible) set.visible = false;
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					if(!silent)
						FlxG.sound.play(Paths.sound(reversed? 'intro3' :'intro1' + altSuffix + midiSuffix), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					if(invisible) go.visible = false;
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					if(!silent)
						FlxG.sound.play(Paths.sound('introGo' + altSuffix + midiSuffix), 0.6);
				case 4:
					//JOELwindows7: just add trace for fun
					trace("fake count down finished");
					startedFakeCounting = false; //JOELwindows7: reset the lock
			}
			swagCounter += 1;
		}, 5);
	}

	//JOELwindows7: the compatibility conversion case
	public function toCompatCase(daString:String):String{
		return StringTools.replace(daString, " ", "-").toLowerCase();
	}

	//JOELwindows7: init stagefile
	function loadStageFile(path:String){
		customStage = StageChart.loadFromJson(path);
		if(customStage != null){
			useStageScript = customStage.useStageScript;
			isHalloween = customStage.isHalloween;
		}
	}

	function spawnStageImages(daData:SwagStage){
		if(bgAll != null){
			for(i in 0...customStage.backgroundImages.length){
				var dataBg:SwagBackground = customStage.backgroundImages[i];
				var anBgThing:FlxSprite = new FlxSprite(dataBg.position[0],dataBg.position[1]);
				multiColorable[i] = dataBg.colorable;
				trace("spawning bg " + dataBg.callName);
				if(dataBg.generateMode){
					anBgThing.makeGraphic(Std.int(dataBg.size[0]),Std.int(dataBg.size[1]),FlxColor.fromString(dataBg.initColor));
					multiIsChromaScreen[i] = true;
				} else {
					if(dataBg.isXML){
						anBgThing.frames = Paths.getSparrowAtlas("stage/" + toCompatCase(SONG.stage) + "/" + dataBg.graphic);
						anBgThing.animation.addByPrefix(dataBg.frameXMLName,dataBg.prefixXMLName,dataBg.frameRate,dataBg.mirrored);
					} else {
						anBgThing.loadGraphic(Paths.image("stages/" + toCompatCase(SONG.stage) + "/" + dataBg.graphic));
					}
					anBgThing.setGraphicSize(Std.int(anBgThing.width * dataBg.scale[0]),Std.int(anBgThing.height * dataBg.scale[1]));
					if(dataBg.colorable){
						anBgThing.color = FlxColor.fromString(dataBg.initColor);
					}
				}
				//anBgThing.setPosition(dataBg.position[0],dataBg.position[1]);
				anBgThing.active = dataBg.active;
				anBgThing.antialiasing = dataBg.antialiasing;
				anBgThing.scrollFactor.set(dataBg.scrollFactor[0],dataBg.scrollFactor[1]);
				anBgThing.ID = i;
				anBgThing.updateHitbox();
				multiOriginalColor[i] = anBgThing.color;

				bgAll.add(anBgThing);
				anBgThing.visible = dataBg.initVisible;

				if(trailAll != null){
					if(dataBg.hasTrail){
						var trailing = new FlxTrail(anBgThing, null, 4, 24, 0.3, 0.069);
						trailing.ID = i;
						trailAll.add(trailing);
					}
				}
			}
		}
	}

	//JOELwindows7: when stage is using Lua script
	function spawnStageScript(daPath:String){
		#if ((windows) && cpp)
		if(executeStageScript){
			trace('stage script: ' + executeStageScript + " - " + Paths.lua(daPath)); //JOELwindows7: check too

			stageScript = ModchartState.createModchartState(true,daPath);
			stageScript.executeState('loaded',[toCompatCase(SONG.stage)]);

			stageScript.setVar("originalColors", multiOriginalColor);
			stageScript.setVar("areChromaScreen", multiIsChromaScreen);
		}
		#end
		if(executeStageHscript){
			trace('stage script: ' + executeStageHscript + " - " + Paths.hscript(daPath)); //JOELwindows7: check too

			stageHscript = HaxeScriptState.createModchartState(true,daPath);

			stageHscript.setVar("originalColors", multiOriginalColor);
			stageHscript.setVar("areChromaScreen", multiIsChromaScreen);
		}
	}

	//JOELwindows7: core starting point for custom stage
	function initDaCustomStage(stageJsonPath:String){
		var p;
		trace("Lets init da json stage " + stageJsonPath);
		curStage = SONG.stage;
		loadStageFile("stages/" + toCompatCase(SONG.stage) + "/" + toCompatCase(SONG.stage));

		if(customStage != null)
		{
			defaultCamZoom = customStage.defaultCamZoom;
			halloweenLevel = customStage.isHalloween;
			bgAll = new FlxTypedGroup<FlxSprite>();
			add(bgAll);
			trailAll = new FlxTypedGroup<FlxTrail>();
			add(trailAll);
			#if ((windows) && sys)
			if (!PlayStateChangeables.Optimize && SONG.useCustomStage && customStage.useStageScript)
				executeStageScript = FileSystem.exists(Paths.lua("stage/" + toCompatCase(SONG.stage) + "/" + toCompatCase(SONG.stage) +"/stageScript"));
			#elseif (windows)
			if (!PlayStateChangeables.Optimize && SONG.useCustomStage && customStage.useStageScript)
			{
				#if !web
				p = Path.of(Paths.lua("stage/" + toCompatCase(SONG.stage) + "/" + toCompatCase(SONG.stage) +"/stageScript"));
				trace("Stage file checking is " + Std.string(p.exists()) + " as " + p.getAbsolutePath());
				executeStageScript = p.exists() || customStage.forceLuaModchart;
				#else
				executeStageScript = customStage.forceLuaModchart;
				#end
			}
			#else
				executeStageScript = false;
			#end
			#if !cpp
				executeStageScript = false;
			#end

			//for hscript pls
			#if !web
			p = Path.of(Paths.hscript("stage/" + toCompatCase(SONG.stage) + "/" + toCompatCase(SONG.stage) +"/stageScript"));
			if (!PlayStateChangeables.Optimize && SONG.useCustomStage && customStage.useStageScript)
				executeStageHscript = p.exists() || customStage.forceHscriptModchart;
			trace("Stage hscript file checking is " + Std.string(p.exists()) + " as " + p.getAbsolutePath());
			#else
			if (!PlayStateChangeables.Optimize && SONG.useCustomStage && customStage.useStageScript)
				executeStageHscript = customStage.forceHscriptModchart;
			#end
			trace("forced stage Hscript exist is " + Std.string(customStage.forceHscriptModchart));

			#if ((windows) && cpp)
			spawnStageScript("stages/" + toCompatCase(SONG.stage) +"/stageScript");
			if(executeStageScript || executeStageHscript){
				spawnStageScript("stages/" + toCompatCase(SONG.stage) +"/stageScript");
			}
			// if(executeStageScript || executeStageHscript){
			// 	spawnStageScript("stages/" + toCompatCase(SONG.stage) +"/stageScript");
			// } else {
			// 	spawnStageImages(customStage);
			// }
			#else
			//wtf bro, don't be racist! both must be supported man
			// if(executeStageHscript){
			// 	spawnStageScript("stages/" + toCompatCase(SONG.stage) +"/stageScript");
			// } else {
			// 	spawnStageImages(customStage);
			// }
			spawnStageImages(customStage);
			if(executeStageHscript){
				spawnStageScript("stages/" + toCompatCase(SONG.stage) +"/stageScript");
			}
			#end	
		}
	}

	//JOELwindows7: offset characters
	function repositionThingsInStage(whatStage:String){
		trace("use Custom Stage Positioners");
		if(customStage != null)
		{
			boyfriend.x += customStage.bfPosition[0];
			boyfriend.y += customStage.bfPosition[1];
			gf.x += customStage.gfPosition[0];
			gf.y += customStage.gfPosition[1];
			dad.x += customStage.dadPosition[0];
			dad.y += customStage.dadPosition[1];
		}
	}

	//JOELwindows7: Ugh, fine, I guess you are my littler pogchamp, come here.
	public function colorizeColorablebyKey(note:String, justOne:Bool, toWhichBg:Int)
	{
		switch(note){
			case "left":
				trace("set color magenta");
				chooseColoringColor(FlxColor.fromString("magenta"), justOne, toWhichBg);
			case "down":
				trace("set color cyan");
				chooseColoringColor(FlxColor.fromString("cyan"), justOne, toWhichBg);
			case "up":
				trace("set color lime");
				chooseColoringColor(FlxColor.fromString("lime"), justOne, toWhichBg);
			case "right":
				trace("set color red");
				chooseColoringColor(FlxColor.fromString("red"), justOne, toWhichBg);
			default:
		}
	}

	public function colorizeColorablebyKeyNum(note:Int, justOne:Bool, toWhichBg:Int){
		switch(note){
			case 0:
				trace("set color magenta");
				chooseColoringColor(FlxColor.fromString("magenta"), justOne, toWhichBg);
			case 1:
				trace("set color cyan");
				chooseColoringColor(FlxColor.fromString("cyan"), justOne, toWhichBg);
			case 2:
				trace("set color lime");
				chooseColoringColor(FlxColor.fromString("lime"), justOne, toWhichBg);
			case 3:
				trace("set color red");
				chooseColoringColor(FlxColor.fromString("red"), justOne, toWhichBg);
			default:
		}
	}

	//JOELwindows7: special starfielder for playstate
	public function installStarfield(
		is3D:Bool = false,
		x:Float=0, y:Float=0,
		width:Float=0, height:Float=0,
		starAmount:Int=300,
		behind:Bool = true
		){
			if(behind){
				//yeet elements first & put back again later.
				remove(gf);
				remove(boyfriend);
				remove(dad);
			}
			if(is3D){
				installStarfield3D(Std.int(x),Std.int(y),Std.int(width),Std.int(height),starAmount);
			} else {
				installStarfield2D(Std.int(x),Std.int(y),Std.int(width),Std.int(height),starAmount);
			}
			if(behind){
				//here put back all again.
				add(gf);
				add(boyfriend);
				add(dad);
			}
		}
}
