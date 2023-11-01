package;

import flixel.addons.ui.FlxUIBar;
import flixel.effects.FlxFlicker;
import LuaClass;
import openfl.filters.BitmapFilter;
import CoolUtil;
import behavior.audio.IManipulateAudio;
import ui.states.transition.PsychTransition;
import Shader;
import flixel.addons.ui.FlxUISprite;
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
import openfl.utils.Assets as OpenFlAssets;
#if FEATURE_DISCORD
import Discord.DiscordClient;
#end
#if FEATURE_VLC
// import VideoHandler as MP4Handler; // JOELwindows7: BrightFyre handed over hxCodec to PolybiusProxy
// import VideoSprite as MP4Sprite; // yeah.
import hxcodec.flixel.FlxVideo as MP4Handler; // JOELwindows7: BrightFyre handed over hxCodec to PolybiusProxy
import hxcodec.flixel.FlxVideoSprite as MP4Sprite; // yeah.

// import vlc.MP4Handler; // wait what??
// import vlc.MP4Sprite; // Oh, c'mon!!
#end
// JOELwindows7: use ki's filesystemer?
// import filesystem.File;
// Adds candy I/O (read/write/append) extension methods onto File
// using filesystem.FileTools;
// JOELwindows7: okay how about vegardit's filesystemer?
// import hx.files.*;
using StringTools;
using flixel.util.FlxSpriteUtil;

class PlayState extends MusicBeatState implements IManipulateAudio
{
	public static var instance:PlayState = null;

	// JOELwindows7: BOLO psyched thing & stuffs
	public var variables:Map<String, Dynamic> = new Map<String, Dynamic>(); // psych again -saw

	public static var tweenManager:FlxTweenManager;
	public static var timerManager:FlxTimerManager;

	// JOELwindows7: also do you have Flicker manager here pls?
	// public static var flickerManager:FlxFlickerManager; // aw shuck, they don't have it.
	// end of that
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

	// JOELwindows7: everything here make it FlxUISprite!
	public static var songPosBG:FlxUISprite;

	public var visibleCombos:Array<FlxUISprite> = [];

	public var addedBotplay:Bool = false;

	public var visibleNotes:Array<Note> = [];

	public static var tempoBar:FlxUIText; // JOELwindows7: the tempo meter like on Yamaha Keyboard
	public static var songPosBar:FlxBar; // song length bar meter; JOELwindows7: I just labeled it.
	public static var metronomeBar:FlxUIText; // JOELwindows7: the metronome meter like on Yamaha Keyboard

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
	var bgAll:FlxTypedGroup<FlxUISprite>;
	var stageFrontAll:FlxTypedGroup<FlxUISprite>;
	var stageCurtainAll:FlxTypedGroup<FlxUISprite>;
	var trailAll:FlxTypedGroup<FlxTrail>;

	// JOELwindows7: numbers of Missnote sfx! load from text file, how many Miss notes you had?
	var numOfMissNoteSfx:Int = 3;

	var songLength:Float = 0;
	var songLengthMs:Float = 0; // JOELwindows7: miliseconds too pls bruh!
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
	var iconRPCBefore:String = ""; // JOELwindows7: BOLO rpc icon holder
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

	public var unspawnNotes:Array<Note> = []; // JOELwindows7: was private. BOLO Publicize!

	public var strumLine:FlxUISprite;

	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	// JOELwindows7: oh the blackbars but right here
	public var realBlackbarsTop:FlxUISprite;
	public var realBlackbarsBottom:FlxUISprite;
	public var realBlackbarHeight:Int = 100;

	// JOELwindows7: flag to let stage or whatever override camFollow position
	private var manualCamFollowPosP1:Array<Float> = [0, 0];
	private var manualCamFollowPosP2:Array<Float> = [0, 0];

	public var laneunderlay:FlxUISprite;
	public var laneunderlayOpponent:FlxUISprite;

	public static var strumLineNotes:FlxTypedGroup<StaticArrow> = null;
	public static var playerStrums:FlxTypedGroup<StaticArrow> = null;
	public static var cpuStrums:FlxTypedGroup<StaticArrow> = null;
	public static var grpNoteSplashes:FlxTypedGroup<NoteSplash>; // JOELwindows7: Psyched note splash
	public static var grpNoteHitlineParticles:FlxTypedGroup<FlxUISprite>; // JOELwindows7: same as note splash but simpler, to see perfect, late early you hit.

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
	public var shownAccuracy:Float = 0; // JOELwindows7: BOLO's shown accuracy thingy

	private var accuracyDefault:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalNotesHitDefault:Float = 0;
	private var totalPlayed:Int = 0;
	private var ss:Bool = false;

	private var healthBarBG:FlxUISprite;
	private var healthBar:FlxBar;
	private var songPositionBar:Float = 0;
	private var songPositionBarMs:Float = 0; // JOELwindows7: idk, maybe this could be useful?

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;
	private var finishingSong:Bool = false; // JOELwindows7: here make redundant flag to make sure the song doesn't run alone

	// even the song has been done.
	public var iconP1:HealthIcon; // making these public again because i may be stupid
	public var iconP2:HealthIcon; // what could go wrong?
	public var iconPlayers:FlxTypedGroup<HealthIcon>; // JOELwindows7: okeh, player icons array for later, idk.
	public var camHUD:FlxCamera;

	private var camWatermark:FlxCamera; // JOELwindows7: Special private camera for anti-without-credit! intentionally minimal & subtle to make people did not notice first.

	public var camSustains:FlxCamera;
	public var camNotes:FlxCamera;
	public var camGame:FlxCamera; // JOELwindows7: (was private) dude whyn't work anymore after 1.7
	// JOELwindows7: There are more BOLO cameras to be handled!!!
	public var mainCam:FlxCamera;
	public var camStrums:FlxCamera;
	public var mainCamShaders:Array<ShaderEffect> = [];
	public var camHUDShaders:Array<ShaderEffect> = [];
	public var camGameShaders:Array<ShaderEffect> = [];
	public var camNotesShaders:Array<ShaderEffect> = [];
	public var camSustainsShaders:Array<ShaderEffect> = [];
	public var camStrumsShaders:Array<ShaderEffect> = [];
	public var shaderUpdates:Array<Float->Void> = []; // JOELwindows7: BOLO also has shader too!

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

	var songName:FlxUIText; // JOELwindows7: use FlxUIText from now on.

	var spin:Float; // JOELwindows7: BOLO spin value

	var altSuffix:String = "";

	public var currentSection:SwagSection;

	var fc:Bool = true;

	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;

	public static var currentSong = "noneYet";

	public var songScore:Int = 0;
	public var shownSongScore:Int = 0; // JOELwindows7: BOLO for display song score

	// JOELwindows7: everything here must use `FlxUIText`!!!
	var songScoreDef:Int = 0;
	var scoreTxt:FlxUIText;
	var judgementCounter:FlxUIText;
	var replayTxt:FlxUIText;
	var scoreTxtTween:FlxTween; // JOELwindows7: Psyched score zoom yeah!

	var needSkip:Bool = false;
	var skipActive:Bool = false;
	var skipText:FlxUIText;
	var skipTo:Float;

	var accText:FlxUIText; // JOELwindows7: BOLO's accuracy watermark

	public static var campaignScore:Int = 0;

	var newLerp:Float = 0; // JOELwindows7: BOLO new lerp!

	public static var theFunne:Bool = true;

	var funneEffect:FlxUISprite;
	var inCutscene:Bool = false;
	var inCinematic:Bool = false; // JOELwindows7: BOLO's inCinematic flag
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
	private var botPlayState:FlxUIText;
	// Replay shit
	private var saveNotes:Array<Dynamic> = [];
	private var saveJudge:Array<String> = [];
	private var replayAna:Analysis = new Analysis(); // replay analysis

	public static var highestCombo:Int = 0;

	public var executeModchart = false;
	public var executeStageScript = false; // JOELwindows7: for stage lua scripter
	public var executeModHscript = false; // JOELwindows7: modchart but hscript. thancc BulbyVR
	public var executeStageHscript = false; // JOELwindows7: stage haxe script yeaha
	public var sourceModchart = false; // JOELwindows7: idk why BOLO have this.

	// Animation common suffixes
	private var dataSuffix:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
	private var dataColor:Array<String> = ['purple', 'blue', 'green', 'red'];

	public static var startTime = 0.0;

	// JOELwindows7: other stuffs
	public static var creditRollout:CreditRollout; // Credit fade rolls
	#if EXPERIMENTAL_KEM0X_SHADERS
	public static var animatedShaders:Map<String, DynamicShaderHandler> = new Map<String, DynamicShaderHandler>(); // kem0x mod shader

	#end
	// public static var judgementWords:Array<String> = ["Misses", "Shits", "Bads", "Goods", "Sicks", "Danks", "MVPs"];
	public static var judgementWords:Array<String> = ["Misses", "Shits", "Bads", "Goods", "Sicks", "Danks", "MVPs"]; // JOELwindows7: Languaged! nvm don't do it here, do it below!

	// JOELwindows7: Korean Pop Kpop TV Show lyric text. song is line by line
	public var lyricers:FlxUIText;
	public var lyricExists:Bool;
	public var lyricLines:Array<String> = ['a::b', 'c::d', 'e::f'];

	public static var lyricing:Array<Array<String>> = [["a", "b"], ["c", "d"]];

	// API stuff
	// JOELwindows7: INCOMING BOLO & friend's stuffs!!!
	// https://github.com/BoloVEVO/Kade-Engine-Public/blob/stable/source/PlayState.hx
	// WTF WHERE IS IT?
	// MAKING DEEZ PUBLIC TO MAKE COMPLEX ACCURACY WORK
	public var msTiming:Float;

	public var updatedAcc:Bool = false;

	// SONG MULTIPLIER STUFF
	var speedChanged:Bool = false;

	// public var previousRate:Float = songMultiplier; // already defined bellow!
	// Scroll Speed changes multiplier
	public var scrollMult:Float = 1.0;

	public var songFixedName:String = SONG.songName;

	// SCROLL SPEED
	public var scrollSpeed(default, set):Float = 1.0; // already defined in PlayStateChangeables
	public var scrollTween:FlxTween;

	// VARS FOR LUA DUE TO FUCKING BUGGED BOOLS
	public var LuaDownscroll:Bool = FlxG.save.data.downscroll;
	public var LuaMidscroll:Bool = FlxG.save.data.middleScroll;
	public var zoomAllowed:Bool = FlxG.save.data.camzoom;
	public var LuaColours:Bool = FlxG.save.data.colour;
	public var LuaStepMania:Bool = FlxG.save.data.stepMania;
	public var LuaOpponent:Bool = FlxG.save.data.opponent;

	// Cheatin
	public static var usedBot:Bool = false;

	public static var wentToChartEditor:Bool = false;

	// Fake crochet for Sustain Notes
	public var fakeCrochet:Float = 0;

	public static var fakeNoteStepCrochet:Float;

	// Precache List for some stuff (Like frames, sounds and that kinda of shit) // Yoinked from Psych Engine.
	public var precacheList:Map<String, String> = new Map<String, String>();

	var camLerp = #if !html5 0.04 * (30 / (cast(Lib.current.getChildAt(0), Main))
		.getFPS()) * songMultiplier; #else 0.09 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()) * songMultiplier; #end

	public function createTween(Object:Dynamic, Values:Dynamic, Duration:Float, ?Options:TweenOptions):FlxTween
	{
		var tween:FlxTween = tweenManager.tween(Object, Values, Duration, Options);
		tween.manager = tweenManager;
		return tween;
	}

	public function createTweenNum(FromValue:Float, ToValue:Float, Duration:Float = 1, ?Options:TweenOptions, ?TweenFunction:Float->Void):FlxTween
	{
		var tween:FlxTween = tweenManager.num(FromValue, ToValue, Duration, Options, TweenFunction);
		tween.manager = tweenManager;
		return tween;
	}

	public function createTimer(Time:Float = 1, ?OnComplete:FlxTimer->Void, Loops:Int = 1):FlxTimer
	{
		var timer:FlxTimer = new FlxTimer();
		timer.manager = timerManager;
		return timer.start(Time, OnComplete, Loops);
	}

	// JOELwindows7: Okay how about you have flicker too?
	public function createFlicker(Object:FlxObject, Duration:Float = 1, Interval:Float = 0.04, EndVisibility:Bool = true, ForceRestart:Bool = true,
			?CompletionCallback:FlxFlicker->Void, ?ProgressCallback:FlxFlicker->Void):FlxFlicker
	{
		var flicker:FlxFlicker = FlxFlicker.flicker(Object, Duration, Interval, EndVisibility, ForceRestart, CompletionCallback, ProgressCallback);
		// NO FLICKER MANAGER
		return flicker;
	}

	// end BOLO lotsa stuff
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
		Paths.clearStoredMemory(); // JOELwindows7: BOLO clear memory!
		FlxG.mouse.visible = false;
		instance = this;

		// JOELwindows7: BOLO instantiate managers
		tweenManager = new FlxTweenManager();
		timerManager = new FlxTimerManager();

		// grab variables here too or else its gonna break stuff later on
		GameplayCustomizeState.freeplayBf = SONG.player1;
		GameplayCustomizeState.freeplayDad = SONG.player2;
		GameplayCustomizeState.freeplayGf = SONG.gfVersion;
		GameplayCustomizeState.freeplayNoteStyle = SONG.noteStyle;
		GameplayCustomizeState.freeplayStage = SONG.stage;
		GameplayCustomizeState.freeplaySong = SONG.songId;
		GameplayCustomizeState.freeplayWeek = storyWeek;

		// JOELwindows7: Prepare the Kpop Lyric first!
		lyricing = new Array<Array<String>>();
		Debug.logTrace('Trying Lyric pls ${('songs/${PlayState.SONG.songId}/lyrics.txt')}');
		try
		{
			var rawLyric = isSM ? Paths.getKpopLyric('${pathToSm}') : Paths.getKpopLyric('songs/${PlayState.SONG.songId}');
			Debug.logTrace('RAW Lyric file looks like:\n============================\n${rawLyric}\n=============================\nyeah');
			// lyricLines = CoolUtil.coolTextFile(('songs/${PlayState.SONG.songId}/lyrics.txt'));
			lyricLines = CoolUtil.coolStringFile(rawLyric);
			if (lyricLines != null)
			{
				Debug.logTrace('Lyrics here! Was querying ' + ('songs/' + SONG.songName));
				for (i in 0...lyricLines.length)
				{
					Debug.logTrace('Lyric Line ${i}: ${lyricLines[i]}');
					lyricing[i] = lyricLines[i].split(Perkedel.SEPARATOR_LYRIC);
				}
				lyricExists = true;
			}
			else
			{
				Debug.logTrace('No Lyric Available! Was querying ' + ('songs/${PlayState.SONG.songId}/lyrics.txt'));
				lyricing = [["", ""], ["", ""]];
				lyricExists = false;
			}
		}
		catch (e)
		{
			Debug.logTrace('No Lyric Available! Was querying ' + ('songs/${PlayState.SONG.songId}/lyrics.txt'));
			lyricing = [["", ""], ["", ""]];
			lyricExists = false;
		}

		inDaPlay = true; // JOELwindows7: over here!

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

		// inDaPlay = true; // JOELwindows7: move to earliest

		if (currentSong != SONG.songName)
		{
			currentSong = SONG.songName;
			Main.dumpCache();
			Paths.clearStoredMemory(); // JOELwindows7: & BOLO Clear memory again!
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
		// PlayStateChangeables.scrollSpeed = FlxG.save.data.scrollSpeed * songMultiplier;
		scrollSpeed = FlxG.save.data.scrollSpeed * songMultiplier;
		PlayStateChangeables.botPlay = FlxG.save.data.botplay;
		PlayStateChangeables.optimize = FlxG.save.data.optimize;
		PlayStateChangeables.zoom = FlxG.save.data.zoom;
		PlayStateChangeables.legacyLuaModchartSupport = FlxG.save.data.legacyLuaScript || SONG.forceLuaModchartLegacy;

		// JOELwindows7: & BOLO scroll speeder
		if (FlxG.save.data.scrollSpeed == 1)
			// PlayStateChangeables.scrollSpeed = SONG.speed * songMultiplier;
			scrollSpeed = SONG.speed * songMultiplier;
		else
			// PlayStateChangeables.scrollSpeed = FlxG.save.data.scrollSpeed * songMultiplier;
			scrollSpeed = FlxG.save.data.scrollSpeed * songMultiplier;

		// JOELwindows7: also BOLO modifiers!
		if (!isStoryMode)
		{
			PlayStateChangeables.modchart = FlxG.save.data.modcharts;
			// PlayStateChangeables.botPlay = FlxG.save.data.botplay; // NO, peck you!
			PlayStateChangeables.opponentMode = FlxG.save.data.opponent;
			PlayStateChangeables.mirrorMode = FlxG.save.data.mirror;
			PlayStateChangeables.holds = FlxG.save.data.sustains;
			PlayStateChangeables.healthDrain = FlxG.save.data.hdrain;
			PlayStateChangeables.healthGain = FlxG.save.data.hgain;
			PlayStateChangeables.healthLoss = FlxG.save.data.hloss;
			PlayStateChangeables.practiceMode = FlxG.save.data.practice;
			PlayStateChangeables.skillIssue = FlxG.save.data.noMisses;
		}
		else
		{
			PlayStateChangeables.modchart = true;
			// PlayStateChangeables.botPlay = false; // Not to mention!
			PlayStateChangeables.opponentMode = false;
			PlayStateChangeables.mirrorMode = false;
			PlayStateChangeables.holds = true;
			PlayStateChangeables.healthDrain = false;
			PlayStateChangeables.healthGain = 1;
			PlayStateChangeables.healthLoss = 1;
			PlayStateChangeables.practiceMode = false;
			PlayStateChangeables.skillIssue = false;
		}

		removedVideo = false;

		// JOELwindows7: BOLO clear memory all again when optimize
		if (FlxG.save.data.optimize)
		{
			Paths.clearStoredMemory();
		}

		// JOELwindows7: now BOLO has modchart switch!
		#if FEATURE_LUAMODCHART
		// DONE: Refactor this to use OpenFlAssets.
		// executeModchart = FileSystem.exists(Paths.lua('songs/${PlayState.SONG.songId}/modchart'))
		executeModchart = (Paths.doesTextAssetExist(Paths.lua('songs/${PlayState.SONG.songId}/modchart')) || SONG.forceLuaModchart)
			&& PlayStateChangeables.modchart; // JOELwindows7: don't forgot force it.
		if (isSM)
			// executeModchart = FileSystem.exists(pathToSm + "/modchart.lua");
			executeModchart = (Paths.doesTextAssetExist(pathToSm + "/modchart.lua")) && PlayStateChangeables.modchart;
		// if (executeModchart)
		// 	PlayStateChangeables.optimize = false; // JOELwindows7: BOLO no longer disable this if there is modchart or what uh.
		#end
		#if !cpp
		executeModchart = false; // FORCE disable for non cpp targets
		executeStageScript = false; // JOELwindows7: this too
		#end
		Debug.logInfo("forced luascript exist is " + Std.string(SONG.forceLuaModchart));

		Debug.logInfo('Searching for mod chart? ($executeModchart) at ${Paths.lua('songs/${PlayState.SONG.songId}/modchart')}');

		// JOELwindows7: now for the hscript
		// JOELwindows7: new exists
		executeModHscript = (Paths.doesTextAssetExist(Paths.hscript('songs/${PlayState.SONG.songId}/modchart'))
			|| SONG.forceHscriptModchart)
			&& PlayStateChangeables.modchart;
		// trace("forced hscript exist is " + Std.string(SONG.forceHscriptModchart));
		// if (executeModHscript)
		// 	PlayStateChangeables.optimize = false; // this too. BOLO no longer disable optimize just because modchart.
		// trace('Mod hscript chart: ' + executeModHscript + " - " + Paths.hscript('songs/${PlayState.SONG.songId}/modchart');

		// JOELwindows7: having modchart no longer reset song multiplier! BOLO yess.
		// if (executeModchart || executeModHscript)
		// 	songMultiplier = 1;

		#if FEATURE_DISCORD
		// Making difficulty text for Discord Rich Presence.
		storyDifficultyText = CoolUtil.difficultyFromInt(storyDifficulty);

		// iconRPC = SONG.player2;
		// JOELwindows7: Don't forger! BOLO set icon based on opponent mode
		if (!PlayStateChangeables.opponentMode)
			iconRPCBefore = SONG.player2;
		else
			iconRPCBefore = SONG.player1;

		// JOELwindows7: BOLO have it this
		// To avoid having duplicate images in Discord assets
		// switch (iconRPC)
		switch (iconRPCBefore)
		{
			case 'senpai-angry':
				// iconRPC = 'senpai';
				iconRPCBefore = 'senpai';
			case 'monster-christmas':
				// iconRPC = 'monster';
				iconRPCBefore = 'senpai';
			case 'mom-car':
				// iconRPC = 'mom';
				iconRPCBefore = 'senpai';
		}
		iconRPC = iconRPCBefore; // JOELwindows7: now set it! idk why BOLO do this?

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

		// JOELwindows7: BOLO set detailness of Discord RPC. and more stuffs!
		// Updating Discord Rich Presence.
		if (FlxG.save.data.discordMode != 0)
			DiscordClient.changePresence(detailsText + " " + SONG.songName + " (" + storyDifficultyText + " " + songMultiplier + "x" + ") "
				+ Ratings.GenerateLetterRank(accuracy),
				"\nAcc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: "
				+ misses, iconRPC);
		else
			DiscordClient.changePresence("Playing " + SONG.songName + " (" + storyDifficultyText + " " + songMultiplier + "x" + ") ", "", iconRPC);
		#end

		// JOELwindows7: load the num missnote sfx file and interpret!
		// inspire the loader from FreeplayState.hx or OH ChartingState.hx. look at those dropdowns
		// that lists characters, stages, etc.
		// yeah I know, for future use we array this.
		var initMissSfx = CoolUtil.coolTextFile(Paths.txt('data/numbersOfMissSfx'));
		numOfMissNoteSfx = Std.parseInt(initMissSfx[0]);

		// JOELwindows7: init the heartbeat system
		// startHeartBeat();

		// JOELwindows7: build funny
		buildFunneehThingie();

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		// camGame.width = 2000; // JOELwindows7: What if I enwidened it?
		// camGame.height = 2000; // JOELwindows7: and stretch it?
		// camGame.viewMarginLeft = 3000; // JOELwindows7: don't know will this work?
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camWatermark = new FlxCamera(); // JOELwindows7: anti-without-credit
		camWatermark.bgColor.alpha = 0; // JOELwindows7: anti-without-credit yey
		camSustains = new FlxCamera();
		camSustains.height = 1300; // JOELwindows7: BOLO sets cam sustains height so high!
		camSustains.bgColor.alpha = 0;
		camNotes = new FlxCamera();
		camNotes.height = 1300; // JOELwindows7: BOLO sets cam notes height so high too as well!
		camNotes.bgColor.alpha = 0;
		// JOELwindows7: of course also, BOLO cameras!!!
		mainCam = new FlxCamera();
		mainCam.bgColor.alpha = 0;
		camStrums = new FlxCamera();
		camStrums.height = 1300;
		camStrums.bgColor.alpha = 0;

		// FlxG.cameras.add(camGame, true); // JOELwindows7: okay we discovered new things here. also add BOLO things!
		FlxG.cameras.reset(camGame); // Game Camera (where stage and characters are)
		FlxG.cameras.add(camHUD); // HUD Camera (Health Bar, scoreTxt, etc)
		FlxG.cameras.add(camStrums); // StrumLine Camera
		FlxG.cameras.add(camSustains); // Long Notes camera
		FlxG.cameras.add(camNotes); // Single Notes camera
		FlxG.cameras.add(mainCam); // Main Camera
		FlxG.cameras.add(camWatermark); // Watermark Camera
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>(); // JOELwindows7: okey why ShadowMario or whoever
		grpNoteHitlineParticles = new FlxTypedGroup<FlxUISprite>(); // JOELwindows7: okey here note hitlines. inspired from that notesplash & viking timpani game called 'Ragnarock'. Steam.
		// in the blame init that notesplash group here? Psyched
		// maybe because it's after add all those cameras?

		camHUD.zoom = PlayStateChangeables.zoom;
		// JOELwindows7: & syncronize the zoom like BOLO did
		camNotes.zoom = camHUD.zoom;
		camSustains.zoom = camHUD.zoom;
		camStrums.zoom = camHUD.zoom;

		FlxCamera.defaultCameras = [camGame];
		// FlxG.cameras.setDefaultDrawTarget(camGame, false); // JOELwindows7: try the new one
		// see if it works..
		// nope. well it works, but
		// alot of semantics here has to be changed first before hand, so uh. unfortunately
		// I can't yet.
		// hey bbpanzu how the peck do we supposed to make this work??!?!?

		// JOELwindows7: BOLO set transition for Psyched to main cam
		PsychTransition.nextCamera = mainCam;

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial', '');

		// JOELwindows7: BOLO's hardcoded songnamer
		switch (SONG.songId)
		{
			case 'tutorial':
				songFixedName = "Tutorial";
				sourceModchart = true;
			case 'bopeebo':
				songFixedName = "Bopeebo";

			case 'fresh':
				songFixedName = "Fresh!";

			case 'dadbattle':
				songFixedName = "Dad Battle";

			case "spookeez":
				songFixedName = "Spookeez!";

			case "south":
				songFixedName = "South";

			case "monster":
				songFixedName = "Monster...";

			case "pico":
				songFixedName = "Pico";

			case "philly":
				songFixedName = "Philly Noice";

			case "blammed":
				songFixedName = "Blammed";

			case "high":
				songFixedName = "High!";

			case "cocoa":
				songFixedName = "Cocoa";

			case "eggnog":
				songFixedName = "EGGnog";

			case "winter horroland":
				songFixedName = "Winter Horroland...";

			case "senpai":
				songFixedName = "Senpai!"; // Cringe lol

			case "roses":
				songFixedName = "Roses...";

			case "thorns":
				songFixedName = "Thorns!";

			case "ugh":
				songFixedName = "Ugh!";

			case "guns":
				songFixedName = "Guns!";

			case "stress":
				songFixedName = "Stress";
		}

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
			inCutscene = true; // JOELwindows7: oh man! forgot this! thancc BOLO
		}

		// JOELwinodws7: Epilogue shit (sorry, that profanity wasn't mine, it was ninja's semantic)
		if (Paths.doesTextAssetExist(Paths.txt('data/songs/${PlayState.SONG.songId}/epilogue')))
		{
			epilogue = CoolUtil.coolTextFile(Paths.txt('data/songs/${PlayState.SONG.songId}/epilogue'));
			inCutscene = true; // JOELwindows7: oh man! forgot this! thancc BOLO
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

		if (!stageTesting || !PlayStateChangeables.optimize) // JOELwindows7: BOLO or if not optimize. originally based on save data. but let's just.. this.
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

		var positions:Map<String, Array<Float>> = Stage.positions[Stage.curStage]; // JOELwindows7: declare type also
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

		// JOELwindows7: BOLO's tankman stress
		if (!PlayStateChangeables.optimize && FlxG.save.data.distractions && FlxG.save.data.background)
		{
			if (SONG.songId == 'stress')
			{
				switch (gf.curCharacter)
				{
					case 'pico-speaker':
						Character.loadMappedAnims();
				}
			}
		}

		if (!PlayStateChangeables.optimize)
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

		// JOELwindows7: BOLO's hardcode camPos midpoint
		switch (Stage.curStage)
		{
			case 'halloween':
				camPos = new FlxPoint(gf.getMidpoint().x + dad.camPos[0], gf.getMidpoint().y + dad.camPos[1]);
			case 'tank' | 'tankStage' | 'tankStage2':
				if (SONG.player2 == 'tankman')
					camPos = new FlxPoint(436.5, 534.5);
			case 'stage':
				if (dad.replacesGF)
					camPos = new FlxPoint(dad.getGraphicMidpoint().x + dad.camPos[0] - 200, dad.getGraphicMidpoint().y + dad.camPos[1]);
			case 'mallEvil':
				camPos = new FlxPoint(boyfriend.getMidpoint().x - 100 + boyfriend.camPos[0], boyfriend.getMidpoint().y - 100 + boyfriend.camPos[1]);
			default:
				camPos = new FlxPoint(dad.getGraphicMidpoint().x + dad.camPos[0], dad.getGraphicMidpoint().y + dad.camPos[1]);
		}

		// switch (dad.curCharacter)
		if (dad.replacesGF)
		{
			// case 'gf' | 'gf-covid' | 'gf-ht' | 'gf-placeholder':
			// JOELwindows7: multi same with other gf variants. the Home Theater also had left down up right as well!
			// NO, not the deviant of sacred timeline (*Variant*), geez calm down TVA wtf lmao!!!
			if (!stageTesting)
				dad.setPosition(gf.x, gf.y);
			gf.visible = false;
			// JOELwindows7: gf tween in no longer just for story mode! BOLO yess.
			// if (isStoryMode)
			// {
			camPos.x += 600;
			tweenCamIn();
			// }

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
				if (!PlayStateChangeables.optimize)
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

		if (!PlayStateChangeables.optimize && FlxG.save.data.background) // JOELwindows7: BOLO bg check
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

		// JOELwindows7: BOLO removes this check
		// if (!isStoryMode && songMultiplier == 1)
		// {
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
						if (!PlayStateChangeables.optimize)
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
					var timing = ((!playerTurn && !PlayStateChangeables.optimize) ? firstNoteTime : TimingStruct.getTimeFromBeat(TimingStruct.getBeatFromTime(firstNoteTime)
						- 4));
					if (timing > 5000)
					{
						needSkip = true;
						skipTo = timing - 1000;
					}
				}
			}
		}
		// }

		Conductor.songPosition = -5000;
		Conductor.rawPosition = Conductor.songPosition;

		// JOELwindows7: Really bruh!
		strumLine = new FlxUISprite(0, 50);
		strumLine.makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		if (PlayStateChangeables.useDownscroll)
			strumLine.y = FlxG.height - 165;

		laneunderlayOpponent = new FlxUISprite(0, 0);
		laneunderlayOpponent.makeGraphic(110 * 4 + 50, FlxG.height * 2);
		laneunderlayOpponent.alpha = FlxG.save.data.laneTransparency;
		laneunderlayOpponent.color = FlxColor.BLACK;
		laneunderlayOpponent.scrollFactor.set();

		laneunderlay = new FlxUISprite(0, 0);
		laneunderlay.makeGraphic(110 * 4 + 50, FlxG.height * 2);
		laneunderlay.alpha = FlxG.save.data.laneTransparency;
		laneunderlay.color = FlxColor.BLACK;
		laneunderlay.scrollFactor.set();

		// JOELwindows7: no need, but this just in case. BOLO invisibilize lane underlay
		/*
			if ((storyPlaylist.length >= 3 && inCutscene) || inCinematic)
			{
				laneunderlayOpponent.alpha = 0;
				laneunderlay.alpha = 0;
			}
		 */

		if (FlxG.save.data.laneUnderlay && !PlayStateChangeables.optimize)
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
		var hitline:FlxUISprite = new FlxUISprite(100, 100);
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

		// JOELwindows7: Hold, there's advanced BOLO's opponent mode check
		if (!FlxG.save.data.middleScroll || (((executeModchart || executeModHscript) || sourceModchart) && PlayStateChangeables.modchart))
		{
			trace('TREKNOQ');
			Debug.logTrace("Now for static arrows");
			generateStaticArrows(0);
			Debug.logTrace("and other player static arrows");
			generateStaticArrows(1);
			Debug.logTrace("Doned static arrows");
		}
		else
		{
			trace('TRUUUG');
			if (#if FEATURE_LUAMODCHART !(executeModchart || executeModHscript) #else !(sourceModchart || executeModHscript) #end
				|| !PlayStateChangeables.modchart)
			{
				if (!PlayStateChangeables.opponentMode)
					generateStaticArrows(1);
				else
					generateStaticArrows(0);
			}
		}
		// temp error
		// generateStaticArrows(0);
		// generateStaticArrows(1);
		// end temp error
		setVisibleStaticArrows(false, true, true); // JOELwindows7: make it invisible so let the count down do it instead.

		// JOELwindows7: PSST! BOLO's CPU strum modification
		if (sourceModchart && PlayStateChangeables.modchart)
		{
			if (FlxG.save.data.middleScroll)
			{
				if (PlayStateChangeables.opponentMode)
				{
					for (i in 0...cpuStrums.members.length)
						cpuStrums.members[i].x += 900;
				}
				else
				{
					for (i in 0...cpuStrums.members.length)
						cpuStrums.members[i].x -= 900;
				}
			}
		}

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
			luaModchart.setVar('songLengthMs', songLengthMs);
			luaModchart.setVar('songVariables', SONG.variables); // JOELwindows7: now variables are playstate variables.
			luaModchart.setVar('diffVariables', SONG.diffVariables);
			luaModchart.setVar('variables', variables);

			// JOELwindows7: for compatibility reason just in case, I'm going to syndicate things
			// for(thing in SONG.variables){
			// 	variables.set()
			// }
			// so hard.
		}
		if (executeStageScript && stageScript != null)
		{
			// stageScript.executeState('start', [PlayState.SONG.songId]);
			stageScript.setVar('songLength', songLength);
			stageScript.setVar('songLengthMs', songLengthMs);
			stageScript.setVar('songVariables', SONG.variables);
			stageScript.setVar('diffVariables', SONG.diffVariables);
			stageScript.setVar('variables', variables);
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
			hscriptModchart.setVar('songLengthMs', songLengthMs);
			hscriptModchart.setVar('songVariables', SONG.variables); // JOELwindows7: now variables are playstate variables.
			hscriptModchart.setVar('diffVariables', SONG.diffVariables);
			hscriptModchart.setVar('variables', variables);
			// hscriptModchart.executeState('start', [PlayState.SONG.songId]);
		}
		if (executeStageHscript && stageHscript != null)
		{
			stageHscript.setVar('executeModchart', executeModchart);
			stageHscript.setVar('executeModHscript', executeModHscript);
			stageHscript.setVar('executeStageHscript', executeStageHscript);
			stageHscript.setVar('executeStageScript', executeStageScript);
			stageHscript.setVar('songLength', songLength);
			stageHscript.setVar('songLengthMs', songLengthMs);
			stageHscript.setVar('songVariables', SONG.variables);
			stageHscript.setVar('diffVariables', SONG.diffVariables);
			hscriptModchart.setVar('variables', variables);
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

			// JOELwindows7: register interp to this here!
			@:privateAccess {
				if (hscriptModchart != null)
					ModchartState.haxeInterp = hscriptModchart.interp;
			}
		}
		if (executeStageScript && stageScript != null)
		{
			stageScript.setVar('executeModchart', executeModchart);
			stageScript.setVar('executeModHscript', executeModHscript);
			stageScript.setVar('executeStageHscript', executeStageHscript);
			stageScript.setVar('executeStageScript', executeStageScript);

			// JOELwindows7: register interp to this here!
			@:privateAccess {
				if (hscriptModchart != null)
					ModchartState.haxeInterp = hscriptModchart.interp;
			}
		}
		#end

		#if FEATURE_LUAMODCHART
		if (executeModchart || executeStageScript)
		{
			new LuaCamera(camGame, "camGame").Register(ModchartState.lua);
			new LuaCamera(camHUD, "camHUD").Register(ModchartState.lua);
			new LuaCamera(mainCam, "mainCam").Register(ModchartState.lua); // JOELwindows7: BOLO's main cam
			new LuaCamera(camStrums, "camStrums").Register(ModchartState.lua); // JOELwindows7: BOLO's sustain cam
			new LuaCamera(camSustains, "camSustains").Register(ModchartState.lua);
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
		// 		FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
		#else
		// 		FlxG.camera.follow(camFollow, LOCKON, 0.008);
		// use Banbud's trickster .008
		// JOELwindows7: from Klavier & Verwex
		// https://github.com/KlavierGayming/FNF-Micd-Up-Mobile/blob/main/source/PlayState.hx
		/*camera lockon/follow tutorial:
			0.01 - Real fucking slow
			0.04 - Normal 60Fps speed
			0.10 - 90 Fps speed
			0.16 - Micd up speed */
		#end
		// JOELwindows7: hey, there's brand new BOLO's camera lerp based follow instead.
		FlxG.camera.follow(camFollow, LOCKON, camLerp);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = Stage.camZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		// JOELwindows7: This sucks!! the extenderin did not return the same type.
		healthBarBG = cast new FlxUISprite(0, FlxG.height * 0.9).loadGraphic(Paths.loadImage('healthBar'));
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

		// JOELwindows7: BOLO's accuracy mode text say. pls FireTongue them
		// var accMode:String = "None";
		var accMode:String = CoolUtil.getText("$GAMEPLAY_ACCURACY_MODE_OPTION_NONE");
		if (FlxG.save.data.accuracyMod == 0)
			// accMode = "Accurate";
			accMode = CoolUtil.getText("$GAMEPLAY_ACCURACY_MODE_OPTION_ACCURATE");
		else if (FlxG.save.data.accuracyMod == 1)
			// accMode = "Complex";
			accMode = CoolUtil.getText("$GAMEPLAY_ACCURACY_MODE_OPTION_COMPLEX");

		// JOELwindows7: add reupload watermark
		// usually, YouTube mod showcase only shows gameplay
		// and there are some naughty youtubers who did not credit link in description neither comment.
		reuploadWatermark = new FlxUIText((FlxG.width / 2)
			- 100, (FlxG.height / 2)
			+ 50, 0,
			"Download Last Funkin Moments ($0) https://github.com/Perkedel/kaded-fnf-mods,\n"
			+ "Kade Engine ($0) https://github.com/KadeDev/Kade-Engine ,\n"
			+ "and vanilla funkin demo ($0) https://github.com/ninjamuffin99/Funkin ,\n"
			+ "and vanilla funkin FULL-ASS ($???) STEAM_URL\n"
			+ "Now Playing: "
			+ SONG.artist
			+ " - "
			+ SONG.songName
			+ "\n"
			+ "Song ID: "
			+ SONG.songId
			+ "\n"
			+ 'Difficulty: ${CoolUtil.difficultyFromInt(storyDifficulty)}',
			14);
		reuploadWatermark.setPosition((FlxG.width / 2) - (reuploadWatermark.width / 2), (FlxG.height / 2) - (reuploadWatermark.height / 2) + 50);
		// Ah damn. the pivot of all Haxe Object is top left!
		// right, let's just work this all around anyway.
		// there I got it. hopefully it's centered.
		reuploadWatermark.scrollFactor.set();
		reuploadWatermark.setFormat(Paths.font("UbuntuMono-R-NF.ttf"), 14, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK); // was vcr.ttf
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
			+ " - " // + CoolUtil.difficultyFromInt(storyDifficulty) // + (Main.watermarks ? " | KE " + MainMenuState.kadeEngineVer : "")
			+
			CoolUtil.difficultyWordFromInt(storyDifficulty) // + (Main.watermarks ? " | KE " + MainMenuState.kadeEngineVer : "") // JOELwindows7: And I there worded it.
				// + (Main.perkedelMark ? " | LFM " + MainMenuState.lastFunkinMomentVer : "")
			, 16);
		kadeEngineWatermark.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		kadeEngineWatermark.scrollFactor.set();
		add(kadeEngineWatermark);

		if (PlayStateChangeables.useDownscroll)
			kadeEngineWatermark.y = FlxG.height * 0.9 + 45;

		// JOELwindows7: BOLO's accurac watermark?!!?!?
		// https://github.com/BoloVEVO/Kade-Engine-Public/blame/stable/source/PlayState.hx
		// ACCURACY WATERMARK
		// accText = new FlxUIText(4, FlxG.height * 0.9 + 45 - 20, 0, "Accuracy Mode: " + accMode, 16);
		accText = new FlxUIText(4, FlxG.height * 0.9 + 45 - 20, 0, CoolUtil.getText("$GAMEPLAY_ACCURACY_MODE") + ": " + accMode,
			16); // JOELwindows7: FireTongue
		accText.scrollFactor.set();
		accText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		accText.cameras = [camHUD];
		add(accText);

		// DONE: JOELwindows7: This maybe can be the Korean pop tv show lyric bottom left corner?
		lyricers = new FlxUIText(100, FlxG.height - 150, 0, " \n ", 20);
		lyricers.setFormat(Paths.font("Ubuntu-R-NF.ttf"), 14, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		lyricers.scrollFactor.set();
		add(lyricers);
		lyricers.visible = FlxG.save.data.kpopLyrics;

		scoreTxt = new FlxUIText(FlxG.width / 2 - 235, healthBarBG.y + 50, 0, "", 20);
		// JOELwindows7: move this up a bit due to elongated texts.
		// Y was 50px beneath health bar BG
		// oh this had Kaded already?
		// TODO: make new FlxUIText dedicated for EKG ECG
		scoreTxt.screenCenter(X);
		scoreTxt.scrollFactor.set();
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.text = Ratings.CalculateRanking(songScore, songScoreDef, nps, maxNPS,
			(FlxG.save.data.roundAccuracy ? FlxMath.roundDecimal(accuracy, 0) : accuracy), boyfriend.getHeartRate(0),
			boyfriend.getHeartTier(0) // JOELwindows7: this is just recently popped up.
		);
		if (!FlxG.save.data.healthBar)
			scoreTxt.y = healthBarBG.y;
		// JOELwindows7: BOLO said HTML5 antialiasing NO!
		#if html5
		scoreTxt.antialiasing = false;
		#end
		add(scoreTxt);

		// JOELwindows7: Languaging JudgmementWord
		// judgementWords = ["Misses", "Shits", "Bads", "Goods", "Sicks", "Danks", "MVPs"];
		judgementWords = [
			CoolUtil.getText("$GAMEPLAY_JUDGEMENT_COUNTING_MISS"),
			CoolUtil.getText("$GAMEPLAY_JUDGEMENT_COUNTING_ALMOST"),
			CoolUtil.getText("$GAMEPLAY_JUDGEMENT_COUNTING_BAD"),
			CoolUtil.getText("$GAMEPLAY_JUDGEMENT_COUNTING_GOOD"),
			CoolUtil.getText("$GAMEPLAY_JUDGEMENT_COUNTING_PERFECT"),
			CoolUtil.getText("$GAMEPLAY_JUDGEMENT_COUNTING_FLAWLESS"),
			CoolUtil.getText("$GAMEPLAY_JUDGEMENT_COUNTING_LUDICROUS")
		];

		judgementCounter = new FlxUIText(20, 0, 0, "", 20);
		// JOELwindows7: I think this should be placed on right as where your player strum is at.
		judgementCounter.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, FlxTextAlign.RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		judgementCounter.alpha = .5; // JOELwindows7: also bit opaque pls!
		judgementCounter.borderSize = 2;
		judgementCounter.borderQuality = 2;
		judgementCounter.scrollFactor.set();
		judgementCounter.cameras = [camHUD];
		judgementCounter.screenCenter(Y);
		// judgementCounter.text = 'Sicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\nMisses: ${misses}';
		// JOELwindows7: wai wait! Custom sponsor word. ... I mean judgement words. also other things, idk..
		// judgementCounter.text = 'Combo: ${combo}\nMax Combo: ${highestCombo}\n\n${judgementWords[4]}: ${sicks}\n${judgementWords[3]}: ${goods}\n${judgementWords[2]}: ${bads}\n${judgementWords[1]}: ${shits}\n${judgementWords[0]}: ${misses}';
		judgementCounter.text = '${CoolUtil.getText("$GAMEPLAY_HUD_TEXT_COMBO")}: ${combo}\n${CoolUtil.getText("$GAMEPLAY_HUD_TEXT_MAXCOMBO")}: ${highestCombo}\n\n${judgementWords[4]}: ${sicks}\n${judgementWords[3]}: ${goods}\n${judgementWords[2]}: ${bads}\n${judgementWords[1]}: ${shits}\n${judgementWords[0]}: ${misses}';
		judgementCounter.setPosition(FlxG.width - judgementCounter.width - 15, 0); // JOELwindows7: hey! place it actually right side of screen!
		judgementCounter.screenCenter(Y); // JOELwindows7: do center it again just in case.
		if (FlxG.save.data.judgementCounter)
		{
			add(judgementCounter);
		}

		replayTxt = new FlxUIText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0,
			CoolUtil.getText("$GAMEPLAY_BLINK_TEXT_REPLAY"), 20); // JOELwindows7: "REPLAY"
		replayTxt.text = CoolUtil.getText("$GAMEPLAY_BLINK_TEXT_REPLAY");
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
		botPlayState = new FlxUIText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0,
			CoolUtil.getText("$GAMEPLAY_BLINK_TEXT_BOTPLAY"), 20); // JOELwindows7: "BOTPLAY",
		botPlayState.text = CoolUtil.getText("$GAMEPLAY_BLINK_TEXT_BOTPLAY");
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

		iconPlayers = new FlxTypedGroup<HealthIcon>(); // JOELwindows7: here player icon.

		iconP1 = new HealthIcon(boyfriend.curCharacter, true, boyfriend.forceIcon);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		iconPlayers.add(iconP1);

		iconP2 = new HealthIcon(dad.curCharacter, false, dad.forceIcon);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		iconPlayers.add(iconP2);

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

		strumLineNotes.cameras = [camStrums]; // JOELwindows7: was camHUD. BOLO new camStrums
		grpNoteSplashes.cameras = [camStrums]; // JOELwindows7: notesplash group put in camHUD! Psychedly. okay how about camStrums?
		grpNoteHitlineParticles.cameras = [camStrums]; // JOELwindows7: also the hitlines
		notes.cameras = [camNotes]; // JOELwindows7: was camHUD, now camNotes
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
		reuploadWatermark.cameras = [camWatermark]; // JOELwindows7: stick the reupload watermark to camera
		lyricers.cameras = [camHUD]; // JOELwindows7: stick Kpop Lyric to the camera
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

		// JOELwindows7: wait, check BOLO!
		if (!PlayStateChangeables.optimize)
		{
			dad.dance();
			boyfriend.dance();
			gf.dance();
		}

		cacheCountdown(); // JOELwindows7: BOLO has Cache countdown?

		if (isStoryMode)
		{
			// JOELwindows7: This portion is going to be angle grinded!
			/*
				switch (StringTools.replace(curSong, " ", "-").toLowerCase())
				{
					case "winter-horrorland":
						// JOELwindows7: You gotta be kidding me. why did not you override all functions to it returns as same type as the extended?!?!?
						var blackScreen:FlxUISprite = cast new FlxUISprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
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
					// JOELwindows7: BOLO do this!
					case 'ugh', 'guns', 'stress':
						if (!PlayStateChangeables.optimize && FlxG.save.data.background)
							tankIntro();
						else
						{
							// removeStaticArrows();
							setVisibleStaticArrows(false, true);
							// #if FEATURE_MP4VIDEOS
							// startVideo('cutscenes/${SONG.songId}_cutscene');
							// #else
							// startCountdown();
							// #end

							// JOELwindows7: Um, but I do it like this..
							tankmanIntro(SONG.tankmanVideoPath); // yeah.
						}
					default:
						if (SONG.hasTankmanVideo)
						{
							// tankmanIntro(Paths.video(SONG.tankmanVideoPath));
							tankmanIntro(SONG.tankmanVideoPath); // do not path anymore I guess
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
			 */

			// end angle grinded. PAIN IS TEMPORARY, GLORY IS FOREVER lol wintergatan
			// just do this instead!
			if (SONG.hasTankmanVideo)
			{
				tankmanIntro(SONG.tankmanVideoPath); // do not path anymore I guess
			}
			else
				introScene();
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

		// JOELwindows7: BOLO precache missnote sounds!
		for (i in 1...numOfMissNoteSfx)
		{
			precacheList.set('missnote${i}', 'sound');
		}

		// JOELwindows7: BOLO precache bf holding gf
		if (!FlxG.save.data.optimize)
		{
			if (boyfriend.curCharacter == 'bf-holding-gf')
				precacheList.set('tankman/bfHoldingGF-DEAD', 'frame');
		}

		if (!loadRep)
			rep = new Replay("na");

		trace("an KEYES");

		// This allow arrow key to be detected by flixel. See https://github.com/HaxeFlixel/flixel/issues/2190
		FlxG.keys.preventDefaultKeys = []; // JOELwindows7: wait, put the android back button there!
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, releaseInput);
		// super.create(); // JOELwindows7: BOLO instead do it after additional stuffs bellow

		trace("grepke super create e");

		// JOELwindows7: BOLO destroy everything in optimize
		// AFTER EVERYTHING LOAD DESTROY EVERYTHING TO SAVE MEMORY IN OPTIMIZED MOD
		if (FlxG.save.data.optimize)
		{
			boyfriend.kill();
			gf.destroy();
			dad.kill();
			boyfriend.destroy();
			gf.destroy();
			dad.destroy();
			for (i in Stage.toAdd)
			{
				remove(i, true);
				i.kill();
				i.destroy();
			}
		}

		// JOELwindows7: & wait, Stage again? BOLO
		if (!FlxG.save.data.background)
		{
			for (i in Stage.toAdd)
			{
				remove(i, true);
				i.kill();
				i.destroy();
			}
		}

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
		// TODO: JOELwindows7: add debug function connect steth character & disconnect steth too as well.

		super.create(); // JOELwindows7: BOLO moved it here.

		// JOELwindows7: There's still more BOLO!!!
		trace('BOLO more stuffs');

		// JOELwindows7: BOLO tank stage check
		if (FlxG.save.data.distractions && FlxG.save.data.background && !PlayStateChangeables.optimize)
		{
			if (gfCheck == 'pico-speaker' && Stage.curStage == 'tank')
			{
				if (FlxG.save.data.distractions)
				{
					var firstTank:TankmenBG = new TankmenBG(20, 500, true);
					firstTank.resetShit(20, 600, true);
					firstTank.strumTime = 10;
					if (Stage.swagBacks['tankmanRun'] != null)
					{
						Stage.swagBacks['tankmanRun'].add(firstTank);

						for (i in 0...TankmenBG.animationNotes.length)
						{
							if (FlxG.random.bool(16))
							{
								var tankBih = Stage.swagBacks['tankmanRun'].recycle(TankmenBG);
								tankBih.strumTime = TankmenBG.animationNotes[i].strumTime;
								tankBih.resetShit(20, 200 + FlxG.random.int(50, 100), TankmenBG.animationNotes[i].noteData < 2); // JOELwindows7: x 500
								// JOELwindows7: oh wow, that fixed it. don't 500, 20 like above instead.
								// also maybe don't tankspeed too fast.
								Stage.swagBacks['tankmanRun'].add(tankBih);
							}
						}
					}
				}
			}
		}

		// JOELwindows7: add funny
		addFuneehThingie();

		// JOELwindows7: idk BOLO. Immediately raise tankIntroEnd flag if not in story mode (a.k.a. Freeplay)
		if (!isStoryMode)
			tankIntroEnd = true;

		// JOELwindows7: BOLO precache pause song & alphabets
		precacheList.set('alphabet', 'frame');
		precacheList.set('breakfast', 'music');

		// JOELwindows7: BOLO hitsound cacher
		if (FlxG.save.data.hitSound != 0)
			precacheList.set("hitsounds/" + HitSounds.getSoundByID(FlxG.save.data.hitSoundSelect).toLowerCase(), 'sound');

		cachePopUpScore(); // JOELwindows7: BOLO cache popup score

		// JOELwindows7: BOLO *holy grail* of precache interpretations.
		// scour everything in that precacheList & then trigger loading each & everyone of them!
		// https://github.com/BoloVEVO/Kade-Engine-Public/blame/stable/source/PlayState.hx#L1459
		for (key => type in precacheList)
		{
			switch (type)
			{
				#if !debug
				case 'image':
					Paths.image(key);
				case 'frame':
					Paths.getSparrowAtlas(key);
				case 'atlasFrame':
					AtlasFrameMaker.construct(key);
				case 'sound':
					Paths.sound(key);
				case 'music':
					Paths.music(key);
				#end
			}
		}

		trace('One last, last modchartoid thingies');
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

		// JOELwindows7: BOLO clear unused memory one last time
		Paths.clearUnusedMemory();

		// JOELwindows7: BOLO set the next camera to mainCam in Psyched transition!
		PsychTransition.nextCamera = mainCam;

		// JOELwindows7: why the peck with touchscreen button game crash on second run?!
		trace("finish create PlayState");
	}

	// JOELwindows7: BOLO remove static arrow thingy?!?!?
	// remove static arrow from the gameplay with optional whether want to destroy afterward.
	function removeStaticArrows(?destroy:Bool = false)
	{
		playerStrums.forEach(function(babyArrow:StaticArrow)
		{
			playerStrums.remove(babyArrow);
			if (destroy)
				babyArrow.destroy();
		});
		cpuStrums.forEach(function(babyArrow:StaticArrow)
		{
			cpuStrums.remove(babyArrow);
			if (destroy)
				babyArrow.destroy();
		});
		strumLineNotes.forEach(function(babyArrow:StaticArrow)
		{
			strumLineNotes.remove(babyArrow);
			if (destroy)
				babyArrow.destroy();
		});

		// JOELwindows7: perform misc extra init checks
		extraInitCheck();
	}

	// JOELwindows7: & readd everything
	function readdStaticArrows()
	{
	}

	// JOELwindows7: I got an idea. flag prev variable so you don't have to respectacular what it had right now.
	var wereVisibleStaticArrows:Bool = false; // so only change if the toggle set to is different.

	public var doNotHideStaticArrowsOnFinish:Bool = false; // for modchart to set. turn on to prevent autohide upon all note finished.

	// JOELwindows7: You know what, why not hide arrows instead? with optional no spectacular
	function setVisibleStaticArrows(visible:Bool = true, noSpectacular:Bool = false, forceSet:Bool = false)
	{
		var index:Int = 0;
		if (wereVisibleStaticArrows != visible || forceSet)
		{
			playerStrums.forEach(function(babyArrow:StaticArrow)
			{
				// if visible, then reshow spectacular appearance!
				// copy from generate static arrow tweene
				if (!noSpectacular)
				{
					if (visible)
					{
						babyArrow.visible = visible;
						// JOELwindows7: execute stage script & hscript
						// if (!FlxG.save.data.middleScroll || (executeModchart || executeModHscript))
						// {
						babyArrow.y -= 10;
						babyArrow.alpha = 0;
						createTween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {
							ease: FlxEase.circOut,
							startDelay: 0.5 + (0.2 * index),
							onComplete: function(twn:FlxTween)
							{
								babyArrow.resetPosToCheckpoint();
							}
						}); // JOELwindows7: managed BOLO tween.
						// }
					}
					else
					{
						createTween(babyArrow, {y: babyArrow.y - 10, alpha: 0}, 1, {
							ease: FlxEase.circOut,
							startDelay: 0.5 + (0.2 * index),
							onComplete: function(twn:FlxTween)
							{
								babyArrow.y += 10;
								// babyArrow.alpha = 1;
								babyArrow.visible = visible;
							}
						}); // JOELwindows7: managed BOLO tween.
					}
				}
				else
				{
					babyArrow.alpha = visible ? 1 : 0; // JOELwindows7: ye
					babyArrow.visible = visible;
					babyArrow.resetPosToCheckpoint();
				}
				index++;
			});
			index = 0;
			cpuStrums.forEach(function(babyArrow:StaticArrow)
			{
				// if visible, then reshow spectacular appearance!
				// copy from generate static arrow tweene
				if (!noSpectacular)
				{
					if (visible)
					{
						babyArrow.visible = visible;
						// JOELwindows7: execute stage script & hscript
						// if (!FlxG.save.data.middleScroll || (executeModchart || executeModHscript))
						// {
						babyArrow.y -= 10;
						babyArrow.alpha = 0;
						createTween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {
							ease: FlxEase.circOut,
							startDelay: 0.5 + (0.2 * index),
							onComplete: function(twn:FlxTween)
							{
								babyArrow.resetPosToCheckpoint();
							}
						}); // JOELwindows7: managed BOLO tween.
						// }
					}
					else
					{
						createTween(babyArrow, {y: babyArrow.y - 10, alpha: 0}, 1, {
							ease: FlxEase.circOut,
							startDelay: 0.5 + (0.2 * index),
							onComplete: function(twn:FlxTween)
							{
								babyArrow.y += 10;
								// babyArrow.alpha = 1;
								babyArrow.visible = visible;
							}
						}); // JOELwindows7: managed BOLO tween.
					}
				}
				else
				{
					babyArrow.alpha = visible ? 1 : 0; // JOELwindows7: ye
					babyArrow.visible = visible;
					babyArrow.resetPosToCheckpoint();
				}
				index++;
			});
			/*
				strumLineNotes.forEach(function(babyArrow:StaticArrow)
				{
					babyArrow.visible = visible;

					// if visible, then reshow spectacular appearance!
					// copy from generate static arrow tweene
					babyArrow.y -= 10;
					babyArrow.alpha = 0;
					// JOELwindows7: execute stage script & hscript
					if (!FlxG.save.data.middleScroll || (executeModchart || executeModHscript))
						createTween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1,
							{ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)}); // JOELwindows7: managed BOLO tween.
				});
			 */
		}
		wereVisibleStaticArrows = visible;
	}

	// JOELwindows7: BOLO's add shader to cameras!!!
	public function addShaderToCamera(camera:String, effect:ShaderEffect)
	{
		switch (camera.toLowerCase())
		{
			case 'camhud' | 'hud':
				camHUDShaders.push(effect);
				var newCamEffects:Array<BitmapFilter> = [];
				for (i in camHUDShaders)
					newCamEffects.push(new ShaderFilter(i.shader));
				camHUD.setFilters(newCamEffects);
			case 'camgame' | 'game':
				camGameShaders.push(effect);
				var newCamEffects:Array<BitmapFilter> = [];
				for (i in camGameShaders)
					newCamEffects.push(new ShaderFilter(i.shader));
				camGame.setFilters(newCamEffects);
			case 'cammain' | 'main':
				mainCamShaders.push(effect);
				var newCamEffects:Array<BitmapFilter> = [];
				for (i in mainCamShaders)
					newCamEffects.push(new ShaderFilter(i.shader));
				mainCam.setFilters(newCamEffects);
			case 'camnotes' | 'notes':
				camNotesShaders.push(effect);
				var newCamEffects:Array<BitmapFilter> = [];
				for (i in camNotesShaders)
					newCamEffects.push(new ShaderFilter(i.shader));
				camNotes.setFilters(newCamEffects);
			case 'camsustains' | 'sustains':
				camSustainsShaders.push(effect);
				var newCamEffects:Array<BitmapFilter> = [];
				for (i in camSustainsShaders)
					newCamEffects.push(new ShaderFilter(i.shader));
				camSustains.setFilters(newCamEffects);
			case 'camstrums' | 'strums':
				camStrumsShaders.push(effect);
				var newCamEffects:Array<BitmapFilter> = [];
				for (i in camStrumsShaders)
					newCamEffects.push(new ShaderFilter(i.shader));
				camStrums.setFilters(newCamEffects);
		}
	}

	// JOELwindows7: also the removal for it. BOLO yess.
	public function clearShaderFromCamera(camera:String)
	{
		switch (camera.toLowerCase())
		{
			case 'camhud' | 'hud':
				camHUDShaders = [];
				var newCamEffects:Array<BitmapFilter> = [];
				camHUD.setFilters(newCamEffects);
			case 'camgame' | 'game':
				camGameShaders = [];
				var newCamEffects:Array<BitmapFilter> = [];
				camGame.setFilters(newCamEffects);
			case 'cammain' | 'main':
				mainCamShaders = [];
				var newCamEffects:Array<BitmapFilter> = [];
				mainCam.setFilters(newCamEffects);
			case 'camnotes' | 'notes':
				camNotesShaders = [];
				var newCamEffects:Array<BitmapFilter> = [];
				camNotes.setFilters(newCamEffects);
			case 'camsustains' | 'sustains':
				camSustainsShaders = [];
				var newCamEffects:Array<BitmapFilter> = [];
				camSustains.setFilters(newCamEffects);
			case 'camstrums' | 'strums':
				camStrumsShaders = [];
				var newCamEffects:Array<BitmapFilter> = [];
				camStrums.setFilters(newCamEffects);
		}
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
							FlxTween.tween(tempoBar, {alpha: 0}, 1); // JOELwindows7: here tempo bar
							FlxTween.tween(metronomeBar, {alpha: 0}, 1); // JOELwindows7: & metronome bar
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
						// FlxG.sound.playMusic(Paths.music('freakyMenu'));
						// Conductor.changeBPM(102);
						PsychTransition.nextCamera = mainCam;
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
		_tankmanVideoActive = false;
		// _tankmanVideoIsOutro = false;
	}

	// JOELwindows7: flags for tankman Intro Outro
	var _tankmanVideoActive:Bool = false;
	var _tankmanVideoIsOutro:Bool = false;
	var _tankmanVideoSlaguotin:Bool = false;
	var _tankmanVideoSound:FlxSound;
	var _tankmanVideoUseSound = true;
	var _tankmanVideoSoundMultiplier:Float = 1;
	var _tankmanVideoSoundPrevMultiplier:Float = 1;
	var _tankmanVideoFrames:Int = 0;
	var _tankmanVideoDoShit:Bool = false;
	var _tankmanVideoDictionary:Dynamic = {
		source: 'null',
		outro: false,
		handoverName: '',
		isNextSong: false,
		handoverDelayFirst: 0,
		handoverHasEpilogueVid: false,
		handoverEpilogueVidPath: '',
		handoverHasTankmanEpilogueVid: false,
		handoverTankmanEpilogueVidPath: '',
	};

	function tankmanIntro(source:String, outro:Bool = false, handoverName:String = "", isNextSong:Bool = false, handoverDelayFirst:Float = 0,
			handoverHasEpilogueVid:Bool = false, handoverEpilogueVidPath:String = "", handoverHasTankmanEpilogueVid:Bool = false,
			handoverTankmanEpilogueVidPath:String = ""):Void
	{
		// JOELwindows7: okay here video for week7. fun fact, this is how week7 vanilla video loads.
		// Essentially is a dialogue but instead it's a video FlxSprite spawned above the gameplay, replacing the dialogue.
		// steal this luckydog7's android port, it yoinked the week7 and looks fine on GameBanana even still in embargo somehow.
		// Coding is at that PlayState.hx . there are 3 week7 intro methods unprocedurally: `ughIntro`, `gunsIntro`, & `stressIntro`.
		_tankmanVideoActive = true;
		_tankmanVideoSlaguotin = true;
		_tankmanVideoIsOutro = outro;
		_tankmanVideoDictionary = {
			source: source,
			outro: outro,
			handoverName: handoverName,
			isNextSong: isNextSong,
			handoverDelayFirst: handoverDelayFirst,
			handoverHasEpilogueVid: handoverHasEpilogueVid,
			handoverEpilogueVidPath: handoverEpilogueVidPath,
			handoverHasTankmanEpilogueVid: handoverHasTankmanEpilogueVid,
			handoverTankmanEpilogueVidPath: handoverTankmanEpilogueVidPath,
		};
		// cancel breakpoint
		if (FlxG.save.data.disableVideoCutscener)
		{
			Debug.logInfo("Video cutscener disabled");
			tankmanIntroVidFinish(source, outro, handoverName, isNextSong, handoverDelayFirst, handoverHasEpilogueVid, handoverEpilogueVidPath,
				handoverHasTankmanEpilogueVid, handoverTankmanEpilogueVidPath);
			return;
		}
		#if (FEATURE_VLC)
		trace("Prep da VLC");
		// JOELwindows7: inspire that luckydog7's webmer bellow, build the VLC version of function!
		// inspire from function backgroundVideo if the FEATURE_VLC is available!

		// var videoSpriteFirst = new FlxUISprite();
		// Build own cam!
		// var ownCam = new FlxCamera();
		// FlxG.cameras.add(ownCam);
		// ownCam.bgColor.alpha = 0;
		// videoSpriteFirst.cameras = [ownCam];

		// var video = new MP4Sprite(0, 0, FlxG.width, FlxG.height);
		var video = new MP4Handler();
		// video.cameras = [ownCam];

		// video.finishCallback = function()
		// {
		// 	trace("vid Finish");
		// 	// videoSpriteFirst.kill();
		// 	// remove(videoSpriteFirst);
		// 	// remove(video);
		// 	tankmanIntroVidFinish(source, outro, handoverName, isNextSong, handoverDelayFirst, handoverHasEpilogueVid, handoverEpilogueVidPath,
		// 		handoverHasTankmanEpilogueVid, handoverTankmanEpilogueVidPath);
		// };
		video.onEndReached.add(function()
		{
			trace("vid Finish");
			// videoSpriteFirst.kill();
			// remove(videoSpriteFirst);
			// remove(video);
			tankmanIntroVidFinish(source, outro, handoverName, isNextSong, handoverDelayFirst, handoverHasEpilogueVid, handoverEpilogueVidPath,
				handoverHasTankmanEpilogueVid, handoverTankmanEpilogueVidPath);
		});
		trace('time to play that ${Paths.video(source)} video');
		// video.playMP4(source, null, videoSpriteFirst); // make the transition null so it doesn't take you out of this state
		// video.playVideo(Paths.video(source), false, true); // make the transition null so it doesn't take you out of this state
		video.play(Paths.video(source), false); // make the transition null so it doesn't take you out of this state
		// videoSpriteFirst.setGraphicSize(Std.int(videoSpriteFirst.width * 1.2));
		// video.setGraphicSize(Std.int(video.width * 1.2));
		// videoSpriteFirst.updateHitbox();
		// video.updateHitbox();
		// add(videoSpriteFirst);
		// add(video);
		#elseif (FEATURE_WEBM_NATIVE && !FEATURE_VLC && !FEATURE_WEBM_JS)
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
		#elseif (FEATURE_WEBM_JS && !FEATURE_WEBM_NATIVE && !FEATURE_VLC)
		var ourSource:String = "assets/videos/daWeirdVid/dontDelete.webm";

		// WebmPlayer.SKIP_STEP_LIMIT = 90;
		// var str1:String = "TANKMAN WEBM SHIT";
		// webmHandler = new WebmHandler();
		// webmHandler.source(ourSource);
		// webmHandler.makePlayer();
		// webmHandler.webm.name = str1;

		if (GlobalVideo.get() != null)
		{
			_tankmanVideoDoShit = false;
			trace("check vidSound exist");
			if (GlobalVideo.isWebm)
			{
				_tankmanVideoFrames = VideoState.frameCountUtil(source);

				// JOELwindows7: i pecking don't understand why it doesn't work at all
				// in Android
				if ( // #if !mobile
					Assets.exists(source.replace(".webm", ".ogg"), MUSIC) || Assets.exists(source.replace(".webm", ".ogg"), SOUND) // #else
						// true
						// #end
				)
				{
					_tankmanVideoUseSound = true;
					_tankmanVideoSound = FlxG.sound.play(source.replace(".webm", ".ogg"));
				}
			}
			trace("checked vidSound exists.");

			// GlobalVideo.setWebm(webmHandler);

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

			// var data = webmHandler.webm.bitmapData;

			// videoSprite = new FlxUISprite(0, 0).loadGraphic(data);

			// videoSprite.setGraphicSize(Std.int(videoSprite.width * 1.2));
			// videoSprite.cameras = [camHUD];
			// videoSprite.scrollFactor.set();

			// add(videoSprite);
			_tankmanVideoDoShit = true;
		}
		else
		{
			Debug.logError('Global Video werror missing?! NULL');
			tankmanIntroVidFinish(source, outro, handoverName, isNextSong, handoverDelayFirst, handoverHasEpilogueVid, handoverEpilogueVidPath,
				handoverHasTankmanEpilogueVid, handoverTankmanEpilogueVidPath);
		}
		#else
		trace('Tankman Video unsupported, yahh... ');
		tankmanIntroVidFinish(source, outro, handoverName, isNextSong, handoverDelayFirst, handoverHasEpilogueVid, handoverEpilogueVidPath,
			handoverHasTankmanEpilogueVid, handoverTankmanEpilogueVidPath);
		#end
	}

	// JOELwindows7: this causes us to make tankman intro dictionary version
	function tankmanIntroDictionary(theDictionary:Dynamic)
	{
		tankmanIntro(theDictionary.source, theDictionary.outro, theDictionary.handoverName, theDictionary.isNextSong, theDictionary.handoverDelayFirst,
			theDictionary.handoverHasEpilogueVid, theDictionary.handoverEpilogueVidPath, theDictionary.handoverHasTankmanEpilogueVid,
			theDictionary.handoverTankmanEpilogueVidPath);
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		// JOELwindows7: hey, hide the thing first!
		setVisibleStaticArrows(false, true, true);
		// JOELwindows7: WHAT?! `makeGraphic` is not overridden!!! hence it returns to regular `FlxSprite` of itself instead of `FlxUISprite`!!!
		// trace("has school intro " + Std.string(dialogueBox));
		var black:FlxUISprite = cast new FlxUISprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxUISprite = cast new FlxUISprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxUISprite = new FlxUISprite();
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
						// new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						createTimer(0.3, function(swagTimer:FlxTimer) // JOELwindows7: BOLO's managed create timer here!
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

	// JOELwindows7: BOLO setter Scroll speed
	function set_scrollSpeed(value:Float):Float // STOLEN FROM PSYCH ENGINE ONLY SPRITE SCALING PART.
	{
		speedChanged = true;
		if (generatedMusic)
		{
			var ratio:Float = value / PlayStateChangeables.scrollSpeed;
			for (note in notes)
			{
				if (note.animation.curAnim != null)
					if (note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
					{
						note.scale.y *= ratio;
						note.updateHitbox();
					}
			}
			for (note in unspawnNotes)
			{
				if (note.animation.curAnim != null)
					if (note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
					{
						note.scale.y *= ratio;
						note.updateHitbox();
					}
			}
		}
		PlayStateChangeables.scrollSpeed = value;
		scrollSpeed = value;
		return value;
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

		// JOELwindows7: Looks like we've got BOLO complicated incutscene checks here.
		/*
			if (inCinematic || inCutscene)
			{
				createTween(laneunderlay, {alpha: FlxG.save.data.laneTransparency}, 0.75, {ease: FlxEase.bounceOut});
				if (!FlxG.save.data.middleScroll || executeModchart || sourceModchart)
				{
					createTween(laneunderlayOpponent, {alpha: FlxG.save.data.laneTransparency}, 0.75, {ease: FlxEase.bounceOut});
					generateStaticArrows(0);
					generateStaticArrows(1);
				}
				else
				{
					// JOELwindows7: we have haxe script too
					if (#if FEATURE_LUAMODCHART !(executeModchart || executeModHscript)
						|| !sourceModchart #else !executeModHscript
						|| !sourceModchart #end)
					{
						if (!PlayStateChangeables.opponentMode)
							generateStaticArrows(1);
						else
							generateStaticArrows(0);
					}
				}

				if (sourceModchart && PlayStateChangeables.modchart)
				{
					if (FlxG.save.data.middleScroll)
					{
						if (PlayStateChangeables.opponentMode)
						{
							for (i in 4...strumLineNotes.members.length)
								strumLineNotes.members[i].x += 900;
						}
						else
						{
							for (i in 0...strumLineNotes.members.length - 4)
								strumLineNotes.members[i].x -= 900;
						}
					}
				}
			}
		 */

		inCinematic = false;
		inCutscene = false;

		// trace("startCountdown! Begin Funkin now");
		// inCutscene = false; // JOELwindows7: already covered above

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
		// appearStaticArrows(); // JOELwindows7: BOLO removed this.
		setVisibleStaticArrows(true);
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

		// startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		startTimer = createTimer((Conductor.crochet / 1000), function(tmr:FlxTimer) // JOELwindows7: BOLO's managed create timer
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
					// JOELwindows7: idk if this gonna work.
					var ready:FlxUISprite = cast new FlxUISprite().loadGraphic(Paths.loadImage(introAlts[0], week6Bullshit));
					ready.scrollFactor.set();
					ready.scale.set(0.7, 0.7); // JOELwindows7: BOLO shrink this little bit
					ready.cameras = [camHUD]; // JOELwindows7: BOLO put this on camHUD
					ready.updateHitbox();

					if (SONG.noteStyle == 'pixel')
						ready.setGraphicSize(Std.int(ready.width * CoolUtil.daPixelZoom));

					ready.screenCenter();
					add(ready);
					if (invisible)
						ready.visible = false; // JOELwindows7: infisipel
					// FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
					createTween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, { // JOELwindows7: BOLO's managed tweener
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					if (!silent) // JOELwindows7: Silencio Bruno!
						FlxG.sound.play(Paths.sound('intro2' + altSuffix + midiSuffix), 0.6);
				case 2:
					// JOELwindows7: we'll see
					var set:FlxUISprite = cast new FlxUISprite().loadGraphic(Paths.loadImage(introAlts[1], week6Bullshit));
					set.scrollFactor.set();
					// JOELwindows7: do the BOLO same
					set.scale.set(0.7, 0.7);
					set.cameras = [camHUD];
					if (SONG.noteStyle == 'pixel')
						set.setGraphicSize(Std.int(set.width * CoolUtil.daPixelZoom));

					set.screenCenter();
					add(set);
					if (invisible)
						set.visible = false; // JOELwindows7: inbizibel
					// FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
					createTween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, { // JOELwindows7: BOLO's managed tweener
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					if (!silent) // JOELwindows7: ssshhh + reverse pls dont gone!
						FlxG.sound.play(Paths.sound((reversed ? 'intro3' : 'intro1') + altSuffix + midiSuffix), 0.6);
				case 3:
					// JOELwindows7: idk if this decision is good.. idk...
					var go:FlxUISprite = cast new FlxUISprite().loadGraphic(Paths.loadImage(introAlts[2], week6Bullshit));
					go.scrollFactor.set();
					// JOELwindows7: do the same BOLO
					go.scale.set(0.7, 0.7);
					go.cameras = [camHUD];
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

		// trace("notes able to hit for " + key.toString() + " " + dataNotes.length); //JOELwindows7: BOLO disable because this is noisy

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

			// JOELwindows7: BOLO's opponent mode!
			if (!PlayStateChangeables.opponentMode)
				boyfriend.holdTimer = 0;
			else
				dad.holdTimer = 0;
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
			// health -= 0.20;
			// JOELwindows7: BOLO's ghost tapping opponent mode
			if (!PlayStateChangeables.opponentMode)
				health -= 0.04 * PlayStateChangeables.healthLoss;
			else
				health += 0.04 * PlayStateChangeables.healthLoss;
		}
	}

	public var songStarted = false;

	public var doAnything = false;

	public static var songMultiplier = 1.0;

	public var bar:FlxUISprite;

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

		/*
			#if FEATURE_STEPMANIA
			if (!isStoryMode && isSM)
			{
				// trace("Loading " + pathToSm + "/" + sm.header.MUSIC);
				var bytes = File.getBytes(pathToSm + "/" + sm.header.MUSIC);
				var sound = new Sound();
				sound.loadCompressedDataFromByteArray(bytes.getData(), bytes.length);
				FlxG.sound.playMusic(sound, 1, false); // JOELwindows7: DO NOT PECKING FORGET TO DESTROY THE LOOP
				// Otherwise the end of the song is spasm since the end music signal does not trigger with loop ON.
			}
			else
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.songId), 1, false);
			#else
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.songId), 1, false); // JOELwindows7: idk why, BOLO..
			#end
		 */
		FlxG.sound.music.play();
		vocals.play();
		if (vocals2 != null)
			vocals2.play(); // JOELwindows7: ye

		songLength = ((FlxG.sound.music.length / songMultiplier) / 1000); // JOELwindows7: BOLO refresh song length one last time!
		songLengthMs = (FlxG.sound.music.length / songMultiplier); // JOELwindows7: brehp

		// have them all dance when the song starts
		if (!PlayStateChangeables.optimize) // JOELwindows7: BOLO check optimize
		{
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
		}

		// JOELwindows7: there is VLC!
		if (useVideo && !useVLC)
			GlobalVideo.get().resume();
		else if (useVLC)
		{
			#if FEATURE_VLC
			if (vlcHandler != null)
			{
				vlcHandler.bitmap.resume(); // JOELwindows7: FORGOTR!!!! ok fixed
			}
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

		// JOELwindows7: SAFETY FIRST!!! thancc BOLO. I remember to vocal safety, but BOLO also the music too!
		if (FlxG.sound.music != null)
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
		// #if FEATURE_AUDIO_MANIPULATE
		// @:privateAccess
		// {
		// 	lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
		// 	if (vocals.playing)
		// 		lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
		// 	if (vocals2.playing) // JOELwindows7: oh yea
		// 		lime.media.openal.AL.sourcef(vocals2._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
		// }
		// #end
		manipulateTheAudio();
		trace("pitched inst and vocals to " + songMultiplier);

		for (i in 0...unspawnNotes.length)
			if (unspawnNotes[i].strumTime < startTime)
				unspawnNotes.remove(unspawnNotes[i]);

		// JOELwindows7: BOLO visiblize songehoid position
		if (FlxG.save.data.songPosition)
		{
			createTween(songName, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
			createTween(songPosBar, {alpha: 0.85}, 0.5, {ease: FlxEase.circOut});
			createTween(bar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
			// JOELwindows7: and now these
			createTween(tempoBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
			createTween(metronomeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		}

		if (needSkip)
		{
			skipActive = true;
			skipText = new FlxUIText(healthBarBG.x + 80, healthBarBG.y - 110, 500);
			// skipText.text = "Press Space to Skip Intro";
			skipText.text = CoolUtil.getText("$GAMEPLAY_PRESS_SPACE_TO_SKIP_INTRO"); // JOELwindows7: FireTongue ey
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

		// JOELwindows7: BOLO add the song file to the list
		FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.songId)));

		// JOELwindows7: BOLO skill issue
		if (PlayStateChangeables.skillIssue)
		{
			var redVignette:FlxSprite = new FlxUISprite().loadGraphic(Paths.image('nomisses_vignette', 'shared'));
			redVignette.screenCenter();
			redVignette.cameras = [mainCam];
			add(redVignette);
		}

		trace('loaded vocals');

		// if (!isSM)
		// {
		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(vocals2);
		// }

		if (!paused)
		{
			// trace("Geh Generate song");
			#if FEATURE_STEPMANIA
			if (!isStoryMode && isSM)
			{
				// JOELwindows7: OpenFlAssets does not work since these file are not embedded / compiled which data bits are
				trace("Loading " + pathToSm + "/" + sm.header.MUSIC);
				// var bytes = File.getBytes(pathToSm + "/" + sm.header.MUSIC);
				// var bytes = OpenFlAssets.getBytes(pathToSm + "/" + sm.header.MUSIC); // JOELwindows7: will you please use OpenFlAssets instead?
				var bytes = FNFAssets.getBytes(pathToSm + "/" + sm.header.MUSIC); // JOELwindows7: hey FNF Assets BulbyVR pls!
				var sound = new Sound();
				sound.loadCompressedDataFromByteArray(bytes.getData(), bytes.length);
				// sound.loadCompressedDataFromByteArray(bytes, bytes.length); // JOELwindows7: pls yes?
				FlxG.sound.playMusic(sound, 1, false); // JOELwindows7: DO NOT PECKING FORGET TO DESTROY THE LOOP
				// Otherwise the end of the song is spasm since the end music signal does not trigger with loop ON.
			}
			// JOELwindows7: BOLO disables these
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
		songLengthMs = (FlxG.sound.music.length / songMultiplier); // JOELwindows7: okay, milisecond version..

		Conductor.crochet = ((60 / (SONG.bpm) * 1000));
		Conductor.stepCrochet = Conductor.crochet / 4;

		// JOELwindows7: BOLO recount timingSeg
		var timingSeg = TimingStruct.getTimingAtBeat(curDecimalBeat);
		if (timingSeg != null)
		{
			fakeCrochet = ((60 / (timingSeg.bpm) * 1000)) / songMultiplier;

			// Loading pico shoot anims SONG json fucks the sustains crochet, to fix it only we need to power songMultiplier to 2.
			if (!PlayStateChangeables.optimize && FlxG.save.data.background && FlxG.save.data.distractions)
				if (SONG.songId == 'stress' && gf.curCharacter == 'pico-speaker')
					fakeCrochet = ((60 / (timingSeg.bpm) * 1000)) / Math.pow(songMultiplier, 2);

			fakeNoteStepCrochet = fakeCrochet / 4;
		}

		if (FlxG.save.data.songPosition)
		{
			Debug.logInfo("Install Song Position bar!");
			// JOELwindows7: bruh
			songPosBG = new FlxUISprite(0, 10);
			songPosBG.loadGraphic(Paths.loadImage('healthBar'));
			if (PlayStateChangeables.useDownscroll)
				songPosBG.y = FlxG.height * 0.9 + 35;
			songPosBG.screenCenter(X);
			songPosBG.alpha = 0; // JOELwindows7: Inviblize first
			songPosBG.scrollFactor.set();

			// JOELwindows7: okay, process colors inline!
			// if (SONG.selectionColor != null)
			// {
			// 	PlayStateChangeables.songPosBarColor = FlxColor.fromString(SONG.selectionColor);
			// 	PlayStateChangeables.songPosBarColorBg = FlxColor.fromRGBFloat(PlayStateChangeables.songPosBarColor.brightness,
			// 		PlayStateChangeables.songPosBarColor.brightness, PlayStateChangeables.songPosBarColor.brightness);
			// }
			// else
			// {
			PlayStateChangeables.songPosBarColor = PlayStateChangeables.weekColor;
			PlayStateChangeables.songPosBarColorBg = FlxColor.fromRGBFloat(PlayStateChangeables.weekColor.brightness,
				PlayStateChangeables.weekColor.brightness, PlayStateChangeables.weekColor.brightness)
				.getComplementHarmony();
			// prevent bar color from being alpha < 1. background bar is okay alpha < 1, I guess...
			PlayStateChangeables.songPosBarColor.alphaFloat = 1;
			// }

			// JOELwindows7: in case the color becomes null
			// if (PlayStateChangeables.songPosBarColor == null)
			// {
			// 	PlayStateChangeables.songPosBarColor == Perkedel.SONG_POS_BAR_COLOR;
			// 	PlayStateChangeables.songPosBarColorBg == FlxColor.BLACK;
			// }

			// JOELwindows7: BUG!!! The meter bar is not precise & pixelated! say you have decimal float point. 12.5 is treated as 12 or 13 somehow.
			// UGH!!!!
			// was refer `songPositionBar` min 0 max `songLength`. now use ms version of it!
			// oh try FlxUIBar instead of FlxBar, sir.
			songPosBar = new FlxUIBar(640 - (Std.int(songPosBG.width - 100) / 2), songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 100),
				Std.int(songPosBG.height + 6), this, 'songPositionBarMs', 0, songLengthMs);
			songPosBar.scrollFactor.set();
			// songPosBar.createFilledBar(FlxColor.BLACK, FlxColor.fromRGB(0, 255, 128));
			songPosBar.createFilledBar(PlayStateChangeables.songPosBarColorBg, PlayStateChangeables.songPosBarColor); // JOELwindows7: here with custom color!
			songPosBar.alpha = 0; // JOELwindows7: inviblize first
			add(songPosBar);

			// JOELwindows7: idk anymore
			bar = cast new FlxUISprite(songPosBar.x,
				songPosBar.y).makeGraphic(Math.floor(songPosBar.width), Math.floor(songPosBar.height), FlxColor.TRANSPARENT);
			bar.alpha = 0; // JOELwindows7: inviblize first
			add(bar);

			FlxSpriteUtil.drawRect(bar, 0, 0, songPosBar.width, songPosBar.height, FlxColor.TRANSPARENT, {thickness: 4, color: FlxColor.BLACK});

			songPosBG.width = songPosBar.width;

			// songName = new FlxUIText(songPosBG.x + (songPosBG.width / 2) - (SONG.songName.length * 5), songPosBG.y - 15, 0, SONG.songName, 16);
			// JOELwindows7: Pls put artist
			songName = new FlxUIText(songPosBG.x
				+ (songPosBG.width / 2)
				- ((SONG.songName.length + 3 + SONG.artist.length) * 5), songPosBG.y
				- 15, 0,
				SONG.artist
				+ " - "
				+ SONG.songName, 16);
			// songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.setFormat(Paths.font("UbuntuMono-R-NF.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,
				FlxColor.BLACK); // JOELwindows7: I want international support!
			songName.scrollFactor.set();
			// JOELwindows7: YOU SNEAKY LITTLE PUNK!!! WHY TEXT CHANGE AGAIN HERE?!??! hey how about milisecond?
			songName.text = SONG.artist + " - " + SONG.songName + ' (' + FlxStringUtil.formatTime(songLength, true) + ')';
			songName.y = songPosBG.y + (songPosBG.height / 3);
			songName.alpha = 0; // JOELwindows7: invisibilize first.
			songName.screenCenter(X); // JOELwindows7: you know what? let's just screen center it and call it the day.
			add(songName);

			songName.screenCenter(X);

			// JOELwindows7: here tempo bar
			tempoBar = new FlxUIText(songPosBar.x - 50, songPosBar.y, 0, 'TEMPO: ${SONG.bpm} BPM', 16);
			tempoBar.setFormat(Paths.font("UbuntuMono-R-NF.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			tempoBar.scrollFactor.set();
			tempoBar.text = 'TEMPO: ${SONG.bpm} BPM';
			tempoBar.x = songPosBG.x - tempoBar.width - 2;
			tempoBar.y = songPosBG.y + (songPosBG.height / 3);
			tempoBar.alpha = 0;
			add(tempoBar);

			// JOELwindows7: here metronome bar
			metronomeBar = new FlxUIText(songPosBar.x + songPosBar.width + 10, songPosBar.y, 0, 'MEASURES: Oooo 0/0 | BEAT: ${curBeat} | STEP: ${curStep}', 16);
			metronomeBar.setFormat(Paths.font("UbuntuMono-R-NF.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			metronomeBar.scrollFactor.set();
			// metronomeBar.text = 'MEASURES: ${Ratings.judgeMetronome(curBeat, 4)} ${Std.int(curBeat / 4)}/${SONG.notes.length - 1} | BEAT: ${curBeat} | STEP: ${curStep}';
			metronomeBar.applyMarkup('MEASURES: ${Ratings.judgeMetronome(curBeat, 4, true)} ${Std.int(curBeat / 4)}/${SONG.notes.length - 1} | BEAT: ${curBeat} | STEP: ${curStep}',
				Perkedel.METRONOME_FORMAT_BINDINGS);
			metronomeBar.y = songPosBG.y + (songPosBG.height / 3);
			metronomeBar.alpha = 0;
			add(metronomeBar);

			songPosBG.cameras = [camHUD];
			bar.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
			songName.cameras = [camHUD];
			tempoBar.cameras = [camHUD]; // JOELwindows7: heff
			metronomeBar.cameras = [camHUD]; // JOELwindows7: tee
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
				var daStrumTime:Float = (songNotes[0] - FlxG.save.data.offset - songOffset) / songMultiplier; // JOELwindows7: BOLO offsetting
				if (daStrumTime < 0)
					daStrumTime = 0;
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection; // JOELwindows7: BOLO must hit section. was always true.

				// JOELwindows7: was && must hit section. now BOLO is opponent mode & the must hit moved to inside.
				if (songNotes[1] > 3 && !PlayStateChangeables.opponentMode) // was must hit
					gottaHitNote = !section.mustHitSection;
				else if (songNotes[1] < 4 && PlayStateChangeables.opponentMode) // was must hit not
					gottaHitNote = !section.mustHitSection;

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, false, false, songNotes[4],
					songNotes[5]); // JOELwindows7: the note with type
				swagNote.hitsoundUseIt = songNotes[8]; // JOELwindows7: byevte
				swagNote.hitsoundPath = songNotes[6]; // JOELwindows7: and the hit sound file name;

				// JOELwindows7: incoming BOLO advanced complicated skip to next itteration thingy
				// if (!gottaHitNote && PlayStateChangeables.optimize)
				if ((!gottaHitNote && FlxG.save.data.middleScroll && PlayStateChangeables.optimize && !PlayStateChangeables.opponentMode
					&& !PlayStateChangeables.healthDrain)
					|| (!gottaHitNote && FlxG.save.data.middleScroll && PlayStateChangeables.optimize && PlayStateChangeables.opponentMode
						&& !PlayStateChangeables.healthDrain))
					continue;

				// JOELwindows7: BOLO advanced hold enable / disable modifier
				// swagNote.sustainLength = TimingStruct.getTimeFromBeat((TimingStruct.getBeatFromTime(songNotes[2] / songMultiplier)));
				if (PlayStateChangeables.holds)
				{
					swagNote.sustainLength = TimingStruct.getTimeFromBeat((TimingStruct.getBeatFromTime(songNotes[2] / songMultiplier)));
				}
				else
				{
					swagNote.sustainLength = 0;
				}
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				swagNote.isAlt = songNotes[3]
					|| ((section.altAnim || section.CPUAltAnim) && !gottaHitNote)
					|| (section.playerAltAnim && gottaHitNote) // JOELwindows7: There's stil more from BOLO!
					|| (PlayStateChangeables.opponentMode && gottaHitNote && (section.altAnim || section.CPUAltAnim))
					|| (PlayStateChangeables.opponentMode && !gottaHitNote && section.playerAltAnim);

				if (susLength > 0)
					swagNote.isParent = true;

				var type = 0;

				// JOELwindows7: Improved BOLO flooring sustain
				var floorSus:Int = Math.floor(susLength);
				if (floorSus > 0)
				{
					// for (susNote in 0...Math.floor(susLength))
					for (susNote in 0...floorSus + 1) // JOELwindows7: & yeah this too BOLO
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true,
							false, false, songNotes[4], songNotes[5]); // JOELwindows7: here sustain note too.
						sustainNote.hitsoundUseIt = songNotes[8]; // JOElwindows7: e koh
						sustainNote.hitsoundPath = songNotes[6]; // JOELwindows7: and the hit sound file name as well.
						sustainNote.scrollFactor.set();
						unspawnNotes.push(sustainNote);
						sustainNote.isAlt = songNotes[3]
							|| ((section.altAnim || section.CPUAltAnim) && !gottaHitNote)
							|| (section.playerAltAnim && gottaHitNote) // JOELwindows7: & the BOLO's more check
							|| (PlayStateChangeables.opponentMode && gottaHitNote && (section.altAnim || section.CPUAltAnim))
							|| (PlayStateChangeables.opponentMode && !gottaHitNote && section.playerAltAnim) // JOELwindows7: LIMI
						;

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

	private function generateStaticArrows(player:Int, ?tween:Bool = true):Void // JOELwindows7: BOLO add.
		// you can now optionally disable tween strum bar fancy entrance!
	{
		for (i in 0...4) // JOELwindows7: this max number affects how powerful Shaggy is?
		{
			// FlxG.log.add(i);
			var babyArrow:StaticArrow = new StaticArrow(-10, strumLine.y);

			// defaults if no noteStyle was found in chart
			var noteTypeCheck:String = 'normal';

			// JOELwindows7:BOLO remove disable CPU strum on optimize
			/*
				if (PlayStateChangeables.optimize && player == 0)
					continue;
			 */

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

			if (storyPlaylist.length < PlayStateChangeables.howManySongThisWeek) // JOELwindows7: BOLO. Change to 4 if your week has more than 3 songs.
				// thancc but I just rather count this automatically instead.
				babyArrow.alpha = 1;
			if (!isStoryMode
				|| storyPlaylist.length >= PlayStateChangeables.howManySongThisWeek
				|| SONG.songId == 'tutorial'
				|| tankIntroEnd)
				// JOELwindows7: BOLO. For default each week has 3 songs. So only in the first song will do the tween, in the others the strums already appeared.
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				// JOELwindows7: execute stage script & hscript
				if (!FlxG.save.data.middleScroll || (executeModchart || executeModHscript) || player == 1)
					createTween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1,
						{ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)}); // JOELwindows7: managed BOLO tween.

				wereVisibleStaticArrows = true;
			}

			babyArrow.ID = i;

			// JOELwindows7: BOLO opponent mode advanced check!
			switch (player)
			{
				case 0: // CPU dad
					if (!PlayStateChangeables.opponentMode)
					{
						babyArrow.x += 20; // was 20
						cpuStrums.add(babyArrow);
					}
					else
					{
						// JOELwindows7: & this is the one that's new. if we are in opponent mode yess!!! BOLO
						babyArrow.x += 20;
						playerStrums.add(babyArrow);
					}
				case 1: // Player bf
					if (!PlayStateChangeables.opponentMode)
					{
						babyArrow.x -= 5; // JOELwindows7: vice versa!!! BOLO yeye
						playerStrums.add(babyArrow);
					}
					else
					{
						// JOELwindows7: vice versa. yeah.
						babyArrow.x -= 20;
						cpuStrums.add(babyArrow);
					}
			}

			babyArrow.playAnim('static');
			babyArrow.x += 110; // JOELwindows7: BOLO push right a bit 98.5 . was 110
			babyArrow.x += ((FlxG.width / 2) * player);

			// JOELwindows7: filtere Haxe script. also BOLO new stuffs!!!
			// if (PlayStateChangeables.optimize || (FlxG.save.data.middleScroll && !(executeModchart || executeModHscript)))
			if (FlxG.save.data.middleScroll && (!(executeModchart || executeModHscript) || !sourceModchart))
			{
				if (!PlayStateChangeables.opponentMode)
					babyArrow.x -= 303.5; // JOELwindows7: was 320. BOLO 303.5
				// JOELwindows7: & BOLO
				else
					babyArrow.x += 311.5;

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
			else
			{
				// babyArrow.x += 311.5;

				// JOELwindows7: repeat for opponent mode
				/*
					if (player == 1)
					{
						babyArrow.x += 320; // JOELwindows7: hey push the position back for the CPU okay.
						if (i >= 4 && i <= 5) // JOELwindows7: here 1st two of CPU arrow
						{
							babyArrow.x += 20; // TODO: optimize pls
						}
						else if (i >= 6 && i <= 7) // JOELwindows7: and then rest 2 of the CPU arrow.
						{
							babyArrow.x += 600; // TODO: optimize pls
						}
					}
				 */
			}

			cpuStrums.forEach(function(spr:FlxUISprite)
			{
				spr.centerOffsets(); // CPU arrows start out slightly off-center
			});

			babyArrow.setCheckpointPosition(); // JOELwindows7: & finally check oid!
			strumLineNotes.add(babyArrow);
		}
	}

	// JOELwindows7: BOLO! do not comment this function!!!
	private function appearStaticArrows():Void
	{
		setVisibleStaticArrows(true, true);
		var index = 0;
		strumLineNotes.forEach(function(babyArrow:FlxUISprite)
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
		createTween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut}); // JOELwindows7: BOLO managed tweener
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
			}
			// JOELwindows7: BOLO outseparate irond!
			if (vocals != null)
				if (vocals.playing)
					vocals.pause();
			// JOELwindows7: ye
			if (vocals2 != null)
				if (vocals2.playing)
					vocals2.pause();

			// JOELwindows7: BOLO deactivate Lua tween receptor
			#if FEATURE_LUAMODCHART
			if (LuaReceptor.receptorTween != null)
				LuaReceptor.receptorTween.active = false;
			#end

			// JOELwindows7: as well as scrollTween itself
			if (scrollTween != null)
				scrollTween.active = false;

			#if FEATURE_DISCORD
			// JOELwindows7: BOLO's advanced discord mode
			if (!endingSong)
			{
				if (FlxG.save.data.discordMode != 0)
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
				else
					DiscordClient.changePresence("PAUSED on " + SONG.songName + " (" + storyDifficultyText + " " + songMultiplier + "x" + ") ", "", iconRPC);
			}
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
			Game.stopPauseMusic(); // JOELwindows7: Eehe
			// JOELwindows7: BOLO resumes video. pls bring that our function here!
			#if FEATURE_VLC
			if (useVLC && vlcHandler != null)
				vlcHandler.bitmap.resume();
			#elseif (FEATURE_WEBM && !FEATURE_VLC)
			if (useVideo && webmHandler != null)
				webmHandler.resume();
			#end

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

			// JOELwindows7: BOLO reactivate lua tweener
			#if FEAUTURE_LUAMODCHART
			if (LuaReceptor.receptorTween != null)
				LuaReceptor.receptorTween.active = true;
			#end
			// JOELwindows7: & scroll tween too
			if (scrollTween != null)
				scrollTween.active = true;

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if FEATURE_DISCORD
			// if (startTimer.finished)
			if (FlxG.save.data.discordMode != 0) // JOELwindows7: BOLO discord mode
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

		// JOELwindows7: pls install BOLO manipulate audio!
		/*
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
		 */
		if (FlxG.sound.music.playing)
			manipulateTheAudio(); // JOELwindows7: there you go! BOLO manipulate audio!

		// ballsex - etterna

		// JOELwindows7: BOLO remove this. okay honestly why this here??
		/*
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
		 */
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
		if (!PlayStateChangeables.optimize)
			Stage.update(elapsed);

		// JOELwindows7: BOLO tween & timer manager updates
		if (!paused || outroSceneCalled)
		{
			tweenManager.update(elapsed);
			timerManager.update(elapsed);
		}

		// JOELwindows7: BOLO lerper
		newLerp = #if !html5 0.04 * (30 / (cast(Lib.current.getChildAt(0), Main))
			.getFPS()) * songMultiplier; #else 0.09 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()) * songMultiplier; #end
		if (tankIntroEnd)
		{
			if (newLerp != camLerp)
			{
				camLerp = newLerp;
				FlxG.camera.follow(camFollow, LOCKON, camLerp);
			}
		}

		// JOELwindows7: BOLO shown score & accuracy
		shownSongScore = Math.floor(FlxMath.lerp(shownSongScore, songScore, CoolUtil.boundTo(Main.adjustFPS(0.1), 0, 1)));
		shownAccuracy = FlxMath.lerp(shownAccuracy, accuracy, CoolUtil.boundTo(Main.adjustFPS(0.1), 0, 1));

		// JOELwindows7: & its overout preventer
		if (Math.abs(shownAccuracy - accuracy) <= 0)
			shownAccuracy = accuracy;

		if (Math.abs(shownSongScore - songScore) <= 100)
			shownSongScore = songScore;

		// JOELwindows7: BOLO Score lerp
		if (FlxG.save.data.lerpScore)
			updateScoreText();

		// JOELwindows7: BOLO resyncVocals
		if (generatedMusic && !paused && songStarted && songMultiplier < 1)
		{
			if (Conductor.songPosition * songMultiplier >= FlxG.sound.music.time + 25
				|| Conductor.songPosition * songMultiplier <= FlxG.sound.music.time - 25)
			{
				resyncVocals();
			}
		}

		// JOELwindows7: BOLO practice mode
		if (health <= 0 && PlayStateChangeables.practiceMode)
			health = 0;
		else if (health >= 2 && PlayStateChangeables.practiceMode)
			health = 2;

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

		// JOELwindows7: BOLO! wtf?! allow botplay on story mode too, GEEZ!!! lol
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
					// JOELwindows7: BOLO store this new LuaNote to a variable properly
					var n = new LuaNote(dunceNote, currentLuaIndex);
					n.Register(ModchartState.lua);
					ModchartState.shownNotes.push(n);
					dunceNote.LuaNote = n;
					dunceNote.luaID = currentLuaIndex;
				}
				#end
				// JOELwindows7: help, this is complicated. idk what's going on this here.
				if (executeModHscript)
				{
					dunceNote.luaID = currentLuaIndex;
				}

				// JOELwindows7: BOLO keeps notes on its cameras!
				// if (executeModchart || executeModHscript) // JOELwindows7: hey, hscript too pls
				// {
				// #if FEATURE_LUAMODCHART //JOELwindows7: why tho? there is also hscript too.
				/*
					if (!dunceNote.isSustainNote)
						dunceNote.cameras = [camNotes];
					else
						dunceNote.cameras = [camSustains];
				 */
				// #end
				// }
				// else
				// {
				//	dunceNote.cameras = [camHUD];
				// }
				// JOELwindows7: You know what, get the new BOLO's simpler one.
				dunceNote.cameras = [camNotes];
				if (dunceNote.isSustainNote)
					dunceNote.cameras = [camSustains];
				// much better, yess.

				unspawnNotes.remove(dunceNote);
				currentLuaIndex++;
			}
		}

		// JOELwindows7: audio manipulate haxedef
		/*
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
		 */
		// JOELwindows7: BOLO's additional message:
		// Pull request that support new pitch shifting functions for New Dev Lime version: https://github.com/openfl/lime/pull/1510
		// YOOO WTF PULLED BY NINJAMUFFIN?? WEEK 8 LEAK???
		manipulateTheAudio(); // JOELwindows7: here's BOLO better one.

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

						// JOELwindows7: & spectacularly hide the static arrow pls yess!!!
						if (!doNotHideStaticArrowsOnFinish)
							if ((isStoryMode && storyPlaylist.length <= 1) || !isStoryMode)
								// okeh only autohide when this is the last song in week
								// or freeplay
								setVisibleStaticArrows(false);

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

					// JOELwindows7: Here BOLO's song end checks
					// if (FlxG.save.data.endSongEarly ? ((FlxG.sound.music.time / songMultiplier) > (songLength - 0)) : musicCompleted)
					// if (FlxG.save.data.endSongEarly ? ((FlxG.sound.music.length / songMultiplier) - Conductor.songPosition <= 0) : musicCompleted)
					if (((FlxG.sound.music.length / songMultiplier) - Conductor.songPosition <= 0) || musicCompleted)
						// WELL THAT WAS EASY
						// JOELwindows7: was:
						// if (unspawnNotes.length == 0 && notes.length == 0 && FlxG.sound.music.time / songMultiplier > (songLength - 100))
					{
						Debug.logTrace("we're fuckin ending the song ");

						// JOELwindows7: BOLO fades the song positioner
						if (FlxG.save.data.songPosition)
						{
							createTween(accText, {alpha: 0}, 1, {ease: FlxEase.circIn});
							createTween(judgementCounter, {alpha: 0}, 1, {ease: FlxEase.circIn});
							createTween(scoreTxt, {alpha: 0}, 1, {ease: FlxEase.circIn});
							createTween(kadeEngineWatermark, {alpha: 0}, 1, {ease: FlxEase.circIn});
							createTween(songName, {alpha: 0}, 1, {ease: FlxEase.circIn});
							createTween(songPosBar, {alpha: 0}, 1, {ease: FlxEase.circIn});
							createTween(bar, {alpha: 0}, 1, {ease: FlxEase.circIn});
						}

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
						var step = (((60 / data.bpm) * 1000) / songMultiplier) / 4; // JOELwindows7: BOLO not forget per songMultiplier yess.
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
					// trace("BPM CHANGE to " + timingSegBpm);
					Debug.logInfo("BPM CHANGE to " + timingSegBpm); // JOELwindows7: ey BOLO wouldn't this be noisy also on Release & Final build?
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
			{
				// scrollSpeed *= newScroll; // JOELwindows7: BOLO's adds
				// PlayStateChangeables.scrollSpeed *= newScroll;
				scrollSpeed *= newScroll;
			}
		}

		if (PlayStateChangeables.botPlay && FlxG.keys.justPressed.ONE)
			camHUD.visible = !camHUD.visible;

		if (useVideo && GlobalVideo.get() != null && !stopUpdate)
		{
			if (GlobalVideo.get().ended && !removedVideo)
			{
				/*
					remove(videoSprite);
					#if FEATURE_VLC
					// if (vlcHandler != null)
					remove(vlcHandler);
					#end
				 */
				#if (FEATURE_WEBM && !FEATURE_VLC)
				if (videoSprite != null)
					remove(videoSprite);
				removedVideo = true;
				#end
			}
		}
		// JOELwindows7: VLC version
		#if FEATURE_VLC
		if (useVLC && vlcHandler != null && !stopUpdate)
		{
			if (vlcHandlerHasFinished && !removedVideo)
			{
				#if FEATURE_VLC
				remove(vlcHandler);
				#end
				removedVideo = true;
			}
		}
		#else
		// removedVideo = true;
		#end

		#if FEATURE_LUAMODCHART
		if (executeModchart && luaModchart != null && songStarted)
		{
			luaModchart.setVar('zoomAllowed', FlxG.save.data.camzoom); // JOELwindows7: BOLO allow zoom check
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
				scoreTxt.visible = updatedAcc; // JOELwindows7: was always true, now BOLO based on updatedAcc
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
			// JOELwindows7: new cams!
			camStrums.zoom = camHUD.zoom;
			camStrums.x = camHUD.x;
			camStrums.y = camHUD.y;
			camStrums.angle = camHUD.angle;
		}

		// JOELwindows7: for the stagescript
		if (executeStageScript && stageScript != null && songStarted)
		{
			stageScript.setVar('zoomAllowed', FlxG.save.data.camzoom); // JOELwindows7: BOLO allow zoom check
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
			hscriptModchart.setVar('zoomAllowed', FlxG.save.data.camzoom); // JOELwindows7: BOLO allow zoom check
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
				scoreTxt.visible = updatedAcc; // JOELwindows7: was always true, now BOLO based on updatedAcc
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
			// JOELwindows7: new cams!
			camStrums.zoom = camHUD.zoom;
			camStrums.x = camHUD.x;
			camStrums.y = camHUD.y;
			camStrums.angle = camHUD.angle;
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
				PsychTransition.nextCamera = mainCam; // JOELwindows7: BOLO added Shadow Mario Psyched transition.
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
			// songMultiplier = 1; // JOELwindows7: BOLO disable this anymore.
			immediatelyRemoveVideo(); // JOELwindows7: remove video bg useVideo useVLC
			cannotDie = true;
			removeTouchScreenButtons();
			PsychTransition.nextCamera = mainCam; // JOELwindows7: BOLO added Shadow Mario Psyched transition.
			// FlxG.switchState(new WaveformTestState());
			switchState(new WaveformTestState()); // JOELwindows7: use Kade + YinYang48 Hex yess
			clean();
			PlayState.stageTesting = false;
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			/*
				#if FEATURE_LUAMODCHART
				if (luaModchart != null)
				{
					luaModchart.die();
					luaModchart = null;
				}
				#end
			 */
			scronchModcharts(); // JOELwindows7: do this immediately from now on.
		}

		if (FlxG.keys.justPressed.SEVEN && songStarted)
			// JOELwindows7: have debug sevened, for chart option in pause menu maybe
			// lol comment necklace!
			// THERE YOU ARE. desmo lol
		{
			// JOELwindows7: BOLO stuff here & my understanding.
			wentToChartEditor = true;
			if (PlayStateChangeables.mirrorMode)
				PlayStateChangeables.mirrorMode = !PlayStateChangeables.mirrorMode;
			executeModchart = false;
			executeModHscript = false;
			executeStageScript = false;
			executeStageHscript = false;

			// songMultiplier = 1;
			immediatelyRemoveVideo(); // JOELwindows7: remove video bg useVideo useVLC
			cannotDie = true;
			removeTouchScreenButtons();

			PsychTransition.nextCamera = mainCam; // JOELwindows7: BOLO added Shadow Mario Psyched transition.
			// FlxG.switchState(new ChartingState());
			switchState(new ChartingState()); // JOELwindows7: use new Hex version
			clean();
			PlayState.stageTesting = false;
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
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
			scronchModcharts(); // JOELwindows7: do this immediately from now on.
			haveDebugSevened = false;
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		// JOELwindows7: use new BOLO iconLerp
		// var iconLerp = 0.5;
		var iconLerp = CoolUtil.boundTo(1 - (elapsed * 35 * songMultiplier), 0, 1);
		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, iconLerp)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, iconLerp)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		// JOELwindows7: BOLO healthbar thingy!!!
		if (healthBar.percent < 20)
		{
			iconP1.animation.curAnim.curFrame = 1;
			#if FEATURE_DISCORD // JOELwindows7: Here BOLO change icon based on this health status!
			if (PlayStateChangeables.opponentMode)
				iconRPC = boyfriend.curCharacter + "-dead";
			#end
		}
		else
			iconP1.animation.curAnim.curFrame = 0;

		// JOELwindows7: also this BOLO thingggg
		if (healthBar.percent > 80)
		{
			iconP2.animation.curAnim.curFrame = 1;
			#if FEATURE_DISCORD // JOELwindows7: a yea
			if (!PlayStateChangeables.opponentMode)
				iconRPC = iconRPCBefore + "-dead";
			#end
		}
		else
		{
			iconP2.animation.curAnim.curFrame = 0;
			#if FEATURE_DISCORD // JOELwindows7: woo yeah!
			iconRPC = iconRPCBefore;
			#end
		}

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		#if debug
		if (FlxG.keys.justPressed.SIX)
		{
			immediatelyRemoveVideo(); // JOELwindows7: remove video bg useVideo useVLC

			removeTouchScreenButtons();
			// FlxG.switchState(new AnimationDebug(dad.curCharacter));
			PsychTransition.nextCamera = mainCam; // JOELwindows7: BOLO added Shadow Mario Psyched transition.
			switchState(new AnimationDebug(dad.curCharacter)); // JOELwindows7: use Kade + YinYang48 Hex yess
			clean();
			PlayState.stageTesting = false;
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			// DONE: JOELwindows7: destructively revamp this. wrap these into a function. there's one, use it now!
			scronchModcharts(); // JOELwindows7: do this immediately from now on.
		}

		if (!PlayStateChangeables.optimize)
			if (FlxG.keys.justPressed.EIGHT && songStarted)
			{
				removeTouchScreenButtons();
				paused = true;
				immediatelyRemoveVideo(); // JOELwindows7: remove video bg useVideo useVLC
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
				PsychTransition.nextCamera = mainCam; // JOELwindows7: okay basically it.
				// FlxG.switchState(new StageDebugState(Stage.curStage, gf.curCharacter, boyfriend.curCharacter, dad.curCharacter));
				switchState(new StageDebugState(Stage.curStage, gf.curCharacter, boyfriend.curCharacter,
					dad.curCharacter)); // JOELwindows7: use Kade + YinYang48 Hex yess
				clean();
				FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
				FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
				scronchModcharts(); // JOELwindows7: do this immediately from now on.
			}

		if (FlxG.keys.justPressed.ZERO)
		{
			removeTouchScreenButtons();
			PsychTransition.nextCamera = mainCam; // JOELwindows7: okay basically it.
			// FlxG.switchState(new AnimationDebug(boyfriend.curCharacter));
			switchState(new AnimationDebug(boyfriend.curCharacter)); // JOELwindows7: use Kade + YinYang48 Hex yess
			clean();
			PlayState.stageTesting = false;
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			scronchModcharts(); // JOELwindows7: do this immediately from now on.
		}

		// JOELwindows7: additionally, BOLO has animation debug for gf!
		if (FlxG.keys.justPressed.THREE)
		{
			removeTouchScreenButtons();
			PsychTransition.nextCamera = mainCam; // JOELwindows7: okay basically it.
			// FlxG.switchState(new AnimationDebug(boyfriend.curCharacter));
			switchState(new AnimationDebug(gf.curCharacter)); // JOELwindows7: use Kade + YinYang48 Hex yess
			clean();
			PlayState.stageTesting = false;
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			scronchModcharts(); // JOELwindows7: do this immediately from now on.
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
						daNote.alive = false; // JOELwindows7: BOLO unalive daNote!
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
				createTimer(0.5, function(tmr:FlxTimer) // JOELwindows7: BOLO managed timer
				{
					usedTimeTravel = false;
				});
			}
		}
		#end

		if (skipActive && Conductor.songPosition >= skipTo)
		{
			// remove(skipText);
			// JOELwindows7: BOLO's more elaborate skip text fade that Kade forgot bruh
			createTween(skipText, {alpha: 0}, 0.2, {
				onComplete: function(tw)
				{
					remove(skipText);
				}
			}); // yeah should've been here too when let go. like when press space.
			skipActive = false;
		}

		if (FlxG.keys.justPressed.SPACE && skipActive)
		{
			// JOELwindows7: add osu! skip button confirm sound
			playSoundEffect(Paths.sound('confirmMenu'));

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
			createTween(skipText, {alpha: 0}, 0.2, { // JOELwindows7: BOLO managed tweeny
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
			songPositionBarMs = (Conductor.songPosition - songLength); // JOELwindows7: milisecond

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

				// JOELwindows7: bruh! milisecond pls!
				var milisecondsTotal:Int = Math.floor((curTime - songLengthMs));
				if (milisecondsTotal < 0)
					milisecondsTotal = 0;

				// JOELwindows7: on second thought I'd just
				var secondsTotalPrecise:Float = ((curTime - songLength) / 1000);
				if (secondsTotalPrecise < 0)
					secondsTotalPrecise = 0;

				// JOELwindows7: sneaky sneaky songName thingy. HEY milisecond, damn it why not ms!?!??!
				// was `(songLength - secondsTotal)`, now use ms!
				// nvm `(songLengthMs - milisecondsTotal)`. just use the same but no floor.
				if (FlxG.save.data.songPosition)
				{
					songName.text = SONG.artist + " - " + SONG.songName + ' (' + FlxStringUtil.formatTime((songLength - secondsTotalPrecise), true) + ')';
					tempoBar.text = 'TEMPO: ${Conductor.bpm} BPM';
					// metronomeBar.text = 'MEASURES: ${Ratings.judgeMetronome(curBeat, 4)} ${Std.int(curBeat / 4)}/${SONG.notes.length - 1} | BEAT: ${curBeat} | STEP: ${curStep}';
					metronomeBar.applyMarkup('MEASURES: ${Ratings.judgeMetronome(curBeat, 4, true)} ${Std.int(curBeat / 4)}/${SONG.notes.length - 1} | BEAT: ${curBeat} | STEP: ${curStep}',
						Perkedel.METRONOME_FORMAT_BINDINGS);
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		// JOELwindows7: BOLO custom week 7 thingy
		// Custom Animations are alt sing animations for each note. So mirror mode fucks it playing the wrong animation.
		switch (SONG.songId)
		{
			case 'ugh':
				if (PlayStateChangeables.mirrorMode)
				{
					notes.forEachAlive(function(note:Note)
					{
						if (dad.animation.curAnim.name == 'singDOWN-alt')
						{
							dad.playAnim('singUP-alt');
						}
					});
				}
			case 'stress':
				if (PlayStateChangeables.mirrorMode)
					notes.forEachAlive(function(note:Note)
					{
						if (dad.animation.curAnim.name == 'singUP-alt')
						{
							dad.playAnim('singDOWN-alt');
						}
					});
		}

		// JOELwindows7: BOLO custom tutorial modchart addition thingy. if no modchart support then fine lemme do this myself.
		#if !FEATURE_LUAMODCHART
		if (sourceModchart && PlayStateChangeables.modchart)
		{
			if (SONG.songId == 'tutorial')
			{
				var currentBeat = Conductor.songPosition / Conductor.crochet;

				if (curStep >= Math.round(400 * songMultiplier))
				{
					for (i in 0...playerStrums.length)
					{
						if (!paused)
						{
							cpuStrums.members[i].x += (1.1 * Math.pow(songMultiplier, 2)) * Math.sin((currentBeat + i * 0.25) * Math.PI);
							cpuStrums.members[i].y += (1.1 * Math.pow(songMultiplier, 2)) * Math.cos((currentBeat + i * 0.25) * Math.PI);
							playerStrums.members[i].x += (1.1 * Math.pow(songMultiplier, 2)) * Math.sin((currentBeat + i * 0.25) * Math.PI);
							playerStrums.members[i].y += (1.1 * Math.pow(songMultiplier, 2)) * Math.cos((currentBeat + i * 0.25) * Math.PI);
						}
					}
				}
			}
		}
		#end

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
						// it appears BOLO uses more precise curStep instead for checking where are we at right now.
						// case 'Philly Nice':
						case 'philly':
							{
								// General duration of the song
								// if (curBeat < 250)
								if (curStep < Math.round(1000 * songMultiplier)) // JOELwindows7: use BOLO's songMiltiplier based!
								{
									// Beats to skip or to stop GF from cheering
									// if (curBeat != 184 && curBeat != 216)
									if (curStep != Math.round(736 * songMultiplier)
										&& curStep != Math.round(864 * songMultiplier)) // JOELwindows7: BOLO ye
									{
										// if (curBeat % 16 == 8)
										if (curStep % Math.round(64 * songMultiplier) == Math.round(32 * songMultiplier)) // JOELwindows7: BOLO ye
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
								// if (curBeat > 5 && curBeat < 130)
								if (curStep > Math.round(20 * songMultiplier)
									&& curStep < Math.round(520 * songMultiplier)) // JOELwindows7 BOLO ye
								{
									// if (curBeat % 8 == 7)
									if (curStep % Math.round(32 * songMultiplier) == Math.round(28 * songMultiplier)) // JOELwindows7: BOLO ye
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
								// JOELwindows7: BOLO ye
								// if (curBeat > 30 && curBeat < 190)
								if (curStep > Math.round(120 * songMultiplier) && curStep < Math.round(760 * songMultiplier))
								{
									// if (curBeat < 90 || curBeat > 128)
									if (curStep < Math.round(360 * songMultiplier) || curStep > Math.round(512 * songMultiplier))
									{
										// if (curBeat % 4 == 2)
										if (curStep % Math.round(16 * songMultiplier) == Math.round(8 * songMultiplier))
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
								// JOELwindows7: yeah BOLO.
								// if (curBeat < 170)
								if (curStep < Math.round(680 * songMultiplier))
								{
									// if (curBeat < 65 || curBeat > 130 && curBeat < 145)
									if (curStep < Math.round(260 * songMultiplier)
										|| curStep > Math.round(520 * songMultiplier)
										&& curStep < Math.round(580 * songMultiplier))
									{
										// if (curBeat % 16 == 15)
										if (curStep % Math.round(64 * songMultiplier) == Math.round(60 * songMultiplier))
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
								// JOELwindows7: Yeah BOLO
								// if (curBeat > 10 && curBeat != 111 && curBeat < 220)
								if (curStep > Math.round(40 * songMultiplier)
									&& curStep != Math.round(444 * songMultiplier)
									&& curStep < Math.round(880 * songMultiplier))
								{
									// if (curBeat % 8 == 7)
									if (curStep % Math.round(32 * songMultiplier) == Math.round(28 * songMultiplier))
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
								// if (curBeat < 16 || (curBeat > 80 && curBeat < 96) || (curBeat > 160 && curBeat < 192) || (curBeat > 264 && curBeat < 304))
								if (getStepCompare(64, LESSER) || getStepBetween(320, 284) || getStepBetween(640, 768) || getStepBetween(1056, 1216))
								{
									// if (curBeat % 4 == 0 || curBeat % 4 == 2)
									// if (curStep % Math.round(16 * songMultiplier) == 0
									// 	|| curStep % Math.round(16 * songMultiplier) == Math.round(8 * songMultiplier))
									if (getStepModulo(16, 0) || getStepModulo(16, 8))
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
								// if (!inCutscene && curBeat < 307) // make sure do this only when not in cutscene, & song still going
								if (!inCutscene && getStepCompare(1228, LESSER))
									// if ((curBeat > 80 && curBeat < 112) || (curBeat > 176 && curBeat < 208) || (curBeat > 272 && curBeat < 308))
									if (getStepBetween(320, 448) || getStepBetween(704, 832) || getStepBetween(1088, 1232))
									{
										// copy from the hardcode zoom milfe
										cheerNow(4, 2, true);
									}
							}
						case 'fortritri':
							{
								// JOELwindows7: silence is music lmao
								// John Cage = 4'33", haha
								// if (curBeat % 4 == 0)
								if (getStepModulo(16, 0))
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
				// dad turn
				turnChanges(true); // JOELwindows7: yey
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
					// JOELwindows7: yeah cam position dad. PLAYER 2 TURN CAMERA SET POSITION
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

				// JOELwindows7: BOLO if lua no modchart support
				#if !FEATURE_LUAMODCHART
				if (SONG.songId == 'tutorial')
					tweenCamZoom(true);
				#end

				camFollow.x += dad.camFollow[0];
				camFollow.y += dad.camFollow[1];
			}

			if (currentSection.mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
			{
				// bf turn
				turnChanges(true); // JOELwindows7: yey
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
					// JOELwindows7: yeah cam position bf. PLAYER 1 TURN CAMERA SET POSITION
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

				// JOELwindows7: BOLO if no lua modchart support
				#if !FEATURE_LUAMODCHART
				if (SONG.songId == 'tutorial')
					tweenCamZoom(false);
				#end

				if (!PlayStateChangeables.optimize)
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
				camStrums.zoom = camHUD.zoom; // JOELwindows7: BOLO
			}
			else
			{
				FlxG.camera.zoom = FlxMath.lerp(Stage.camZoom, FlxG.camera.zoom, 0.95);
				camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);

				camNotes.zoom = camHUD.zoom;
				camSustains.zoom = camHUD.zoom;
				camStrums.zoom = camHUD.zoom; // JOELwindows7: BOLO
			}
		}

		FlxG.watch.addQuick("curBPM", Conductor.bpm);
		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// JOELwindows7: add more watches too
		FlxG.watch.addQuick("shinzouRateShit", [dad.getHeartRate(-1), gf.getHeartRate(-1), boyfriend.getHeartRate(-1)]);
		FlxG.watch.addQuick("songPositionShit", Conductor.songPosition);
		FlxG.watch.addQuick("songPositionBarShit", songPositionBar);
		FlxG.watch.addQuick("songPositionBarMsShit", songPositionBarMs);
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

		// if (health <= 0 && !cannotDie)
		// JOELwindows7: BOLO hp check
		if ((health <= 0 && !cannotDie && !PlayStateChangeables.practiceMode && !PlayStateChangeables.opponentMode)
			|| (health > 2 && !cannotDie && !PlayStateChangeables.practiceMode && PlayStateChangeables.opponentMode))
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

				// JOELwindows7: more BOLO check. optimize also insta respawns you.
				if (FlxG.save.data.InstantRespawn || PlayStateChangeables.optimize || PlayStateChangeables.opponentMode)
				{
					// JOELwindows7: okay. how about you add little fail effect sound here? idk..
					// FlxG.sound.music.stop();
					// uh, turns out it's more complicated. I gotta syndicate functions first then.

					PsychTransition.nextCamera = mainCam; // JOELwindows7: transition don't forget!
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

				// JOELwindows7: BOLO bro discord
				#if FEATURE_DISCORD
				// Game Over doesn't get his own variable because it's only used here
				if (FlxG.save.data.discordMode != 0)
				{
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
				}
				else
				{
					DiscordClient.changePresence("GAME OVER -- " + "\nPlaying " + SONG.songName + " (" + storyDifficultyText + " " + songMultiplier + "x"
						+ ") ", "", iconRPC);
				}
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

				if (FlxG.save.data.InstantRespawn || PlayStateChangeables.optimize || PlayStateChangeables.opponentMode)
				{
					PsychTransition.nextCamera = mainCam; // JOELwindows7: transition don't forget!
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

				// JOELwindows7: BOLO bro discord
				#if FEATURE_DISCORD
				// Game Over doesn't get his own variable because it's only used here
				if (FlxG.save.data.discordMode != 0)
				{
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
				}
				else
				{
					DiscordClient.changePresence("GAME OVER -- " + "\nPlaying " + SONG.songName + " (" + storyDifficultyText + " " + songMultiplier + "x"
						+ ") ", "", iconRPC);
				}
				#end

				// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			}
		}

		// JOELwindow7: getin ye BOLO
		if (generatedMusic && !(inCutscene || inCinematic))
		{
			var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
			// var stepHeight = (0.45 * Conductor.stepCrochet * FlxMath.roundDecimal(PlayState.SONG.speed, 2));
			// JOELwindows7: BOLO yo
			var stepHeight = (0.45 * fakeNoteStepCrochet * FlxMath.roundDecimal((PlayState.SONG.speed * Math.pow(PlayState.songMultiplier, 2)), 2));

			notes.forEachAlive(function(daNote:Note)
			{
				// instead of doing stupid y > FlxG.height
				// we be men and actually calculate the time :)

				// JOELwindows7: BOLO weird note killer!
				if (daNote.noteData == -1)
				{
					Debug.logWarn('Weird Note detected! Note Data = "${daNote.rawNoteData}" is not valid, deleting...');
					daNote.kill();
					daNote.alive = false;
					notes.remove(daNote, true);
					daNote.destroy();
				}

				// JOELwindows7: and BOLO strumY
				var strumY = playerStrums.members[daNote.noteData].y;

				// JOELwindows7: check must press
				if (!daNote.mustPress)
					strumY = strumLineNotes.members[daNote.noteData].y;

				// JOELwindows7: & origin here.
				var origin = strumY + Note.swagWidth / 2;
				// JOELwindows7: continue rest.
				if (!daNote.modifiedByLua)
				{
					if (PlayStateChangeables.useDownscroll)
					{
						/*
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
						 */
						// JOELwindows7: & so BOLO already has newer system for that note y positionalizier
						daNote.y = (strumY
							+
							// 0.45 * ((Conductor.songPosition - daNote.strumTime) / songMultiplier) * (FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
							0.45 * ((Conductor.songPosition - daNote.strumTime) / songMultiplier) * (FlxMath.roundDecimal(scrollSpeed == 1 ? SONG.speed : scrollSpeed,
								2)))
							- daNote.noteYOff;
						// and there you go. more still comes here bellow!!!
						if (daNote.isSustainNote)
						{
							// JOELwindows7: Here's BOLO drastic edit here. and the message,
							// // Jesus Christ my head and it's still broken this shit FUCK.
							var bpmRatio = (SONG.bpm / 100);

							// daNote.y -= daNote.height - stepHeight;
							// JOELwindows7: BOLO incorporate bpmRatio to this now.
							daNote.y -= daNote.height - (1.5 * stepHeight / SONG.speed * bpmRatio);

							// If not in botplay, only clip sustain notes when properly hit, botplay gets to clip it everytime
							if ((daNote.sustainActive || !daNote.mustPress) && songStarted)
							{
								if ((PlayStateChangeables.botPlay
									|| !daNote.mustPress
									|| daNote.wasGoodHit
									|| holdArray[Math.floor(Math.abs(daNote.noteData))])
									&& daNote.y
									- daNote.offset.y * daNote.scale.y // + daNote.height >= (strumLine.y + Note.swagWidth / 2))
									+ daNote.height >= (origin)) // JOELwindows7: use above BOLO's origin already measured.
								{
									// Clip to strumline
									var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
									/*
										swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
											+ Note.swagWidth / 2
											- daNote.y) / daNote.scale.y;
									 */
									// JOELwindows7: New BOLO's swagRect height pls
									swagRect.height = (origin - daNote.y) / daNote.scale.y;
									swagRect.y = daNote.frameHeight - swagRect.height;

									daNote.clipRect = swagRect;
								}
							}
						}
					}
					else
					{
						// JOELwindows7: & so on. BOLO
						/*
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
						 */
						daNote.y = (strumY // - 0.45 * ((Conductor.songPosition - daNote.strumTime) / songMultiplier) * (FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
							- 0.45 * ((Conductor.songPosition - daNote.strumTime) / songMultiplier) * (FlxMath.roundDecimal(scrollSpeed == 1 ? SONG.speed : scrollSpeed,
								2)))
							+ daNote.noteYOff;
						if (daNote.isSustainNote)
						{
							if ((PlayStateChangeables.botPlay
								|| !daNote.mustPress
								|| daNote.wasGoodHit
								|| holdArray[Math.floor(Math.abs(daNote.noteData))]) // && daNote.y + daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2))
								&& daNote.y
								+ daNote.offset.y * daNote.scale.y <= (origin)) // JOELwindows7: again, BOLO's above origin
							{
								// Clip to strumline
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								/*
									swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
										+ Note.swagWidth / 2
										- daNote.y) / daNote.scale.y;
								 */
								// JOELwindows7: new BOLO swagRect y position pls
								swagRect.y = (origin - daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;

								daNote.clipRect = swagRect;
							}
						}
					}
				}

				// JOELwindows7: Confustaron

				if (!daNote.mustPress && Conductor.songPosition >= daNote.strumTime)
				{
					if (SONG.songId != 'tutorial' && !PlayStateChangeables.optimize)
						camZooming = FlxG.save.data.camzoom; // JOELwindows7: was always true, now is BOLO's based on camzoom option.

					var altAnim:String = "";
					var curSection:Int = Math.floor((curStep / 16)); // JOELwindows7: grab curSection pls. BOLO

					if (daNote.isAlt)
					{
						altAnim = '-alt';
						trace("YOO WTF THIS IS AN ALT NOTE????");
					}

					// JOELwindows7: BOLO discord RPC
					#if FEATURE_DISCORD
					if (FlxG.save.data.discordMode == 1)
						DiscordClient.changePresence(SONG.songName
							+ " ("
							+ storyDifficultyText
							+ " "
							+ songMultiplier
							+ "x"
							+ ") " // + Ratings.GenerateComboRank(accuracy) + " " + Ratings.GenerateLetterRank(accuracy),
							+ Ratings.GenerateLetterRank(accuracy),
							"\nScr: "
							+ songScore
							+ " ("
							+ HelperFunctions.truncateFloat(accuracy, 2)
							+ "%)"
							+ " | Misses: "
							+ misses, iconRPC);
					#end

					// JOELwindows7: BOLO's health draineh
					if (PlayStateChangeables.healthDrain)
					{
						if (!daNote.isSustainNote)
							updateScoreText();
						if (!daNote.isSustainNote)
						{
							if (!PlayStateChangeables.opponentMode)
							{
								health -= .04 * PlayStateChangeables.healthLoss;
								if (health <= 0.01)
								{
									health = 0.01;
								}
							}
							else
							{
								health += .04 * PlayStateChangeables.healthLoss;
								if (health >= 2)
									health = 2;
							}
						}
						else
						{
							if (!PlayStateChangeables.opponentMode)
							{
								health -= .02 * PlayStateChangeables.healthLoss;
								if (health <= 0.01)
								{
									health = 0.01;
								}
							}
							else
							{
								health += .02 * PlayStateChangeables.healthLoss;
								if (health >= 2)
									health = 2;
							}
						}
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
								// dad.playAnim('sing' + dataSuffix[singData] + altAnim, true);
								// JOELwindows7: we got BOLO opponent mode now so pls check based on these pls
								if (!PlayStateChangeables.optimize)
								{
									if (PlayStateChangeables.opponentMode)
										boyfriend.playAnim('sing' + dataSuffix[singData] + altAnim, true);
									else
										dad.playAnim('sing' + dataSuffix[singData] + altAnim, true);
								}

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
									luaModchart.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition, curBeat, curStep]);
								if (stageScript != null)
									stageScript.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition, curBeat, curStep]);
								#end
								if (hscriptModchart != null)
									hscriptModchart.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition, curBeat, curStep]);
								if (stageHscript != null)
									stageHscript.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition, curBeat, curStep]);
								// JOELwindows7: welp, gotta do this then! PLAYER TWO 2
								executeModchartState('characterSing', [
									!PlayStateChangeables.opponentMode ? 1 : 0,
									1,
									Math.abs(daNote.noteData),
									Conductor.songPosition,
									curBeat,
									curStep
								]);

								// dad.holdTimer = 0;
								// JOELwindows7: BOLO opponent hold timer
								if (!PlayStateChangeables.opponentMode)
									dad.holdTimer = 0;
								else
									boyfriend.holdTimer = 0;

								if (SONG.needsVoices)
									vocals.volume = 1;
								if (SONG.needsVoices2)
									vocals2.volume = 1; // JOELwindows7: ye
							}
						}
						else
						{
							var singData:Int = Std.int(Math.abs(daNote.noteData));
							// dad.playAnim('sing' + dataSuffix[singData] + altAnim, true);
							// JOELwindows7: BOLO new opponent mode play anim check
							if (!PlayStateChangeables.optimize)
							{
								if (PlayStateChangeables.opponentMode)
									boyfriend.playAnim('sing' + dataSuffix[singData] + altAnim, true);
								else
									dad.playAnim('sing' + dataSuffix[singData] + altAnim, true);
							}

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

							// JOELwindows7: now BOLO changes the player sing which here! ORIGINALLY `playerTwoSing`
							#if FEATURE_LUAMODCHART
							if (luaModchart != null)
								if (!PlayStateChangeables.opponentMode)
									luaModchart.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition, curBeat, curStep]);
								else
									luaModchart.executeState('playerOneSing', [Math.abs(daNote.noteData), Conductor.songPosition, curBeat, curStep]);
							if (stageScript != null)
								if (!PlayStateChangeables.opponentMode)
									stageScript.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition, curBeat, curStep]);
								else
									stageScript.executeState('playerOneSing', [Math.abs(daNote.noteData), Conductor.songPosition, curBeat, curStep]);
							#end
							if (hscriptModchart != null)
								if (!PlayStateChangeables.opponentMode)
									hscriptModchart.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition, curBeat, curStep]);
								else
									hscriptModchart.executeState('playerOneSing', [Math.abs(daNote.noteData), Conductor.songPosition, curBeat, curStep]);
							if (stageHscript != null)
								if (!PlayStateChangeables.opponentMode)
									stageHscript.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition, curBeat, curStep]);
								else
									stageHscript.executeState('playerOneSing', [Math.abs(daNote.noteData), Conductor.songPosition, curBeat, curStep]);
							// JOELwindows7: welp, gotta do this then! PLAYER TWO 2
							executeModchartState('characterSing', [
								!PlayStateChangeables.opponentMode ? 1 : 0,
								1,
								Math.abs(daNote.noteData),
								Conductor.songPosition,
								curBeat,
								curStep
							]);

							// dad.holdTimer = 0;
							// JOELwindows7: BOLO hold timer opponent mode!!!!!!!!!!!!!
							if (!PlayStateChangeables.opponentMode)
								dad.holdTimer = 0;
							else
								boyfriend.holdTimer = 0;

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
					// daNote.visible = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].visible; // JOELwindows7: BOLO disable
					daNote.x = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote)
						daNote.modAngle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].modAngle;
					if (daNote.sustainActive)
					{
						if ((executeModchart || executeModHscript) && daNote.isParent) // JOELwindows7: BOLO's only if is parent
							daNote.alpha = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					}
					daNote.modAngle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].modAngle;
				}
				else if (!daNote.wasGoodHit && !daNote.modifiedByLua)
				{
					// daNote.visible = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].visible; // JOELwindows7: BOLO disable
					daNote.x = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote)
						daNote.modAngle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].modAngle;
					if (daNote.sustainActive)
					{
						if ((executeModchart || executeModHscript) && daNote.isParent) // JOELwindows7: BOLO's only if is parent
							daNote.alpha = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					}
					daNote.modAngle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].modAngle;
				}

				// JOELwindows7: Position x whether opponent mode pls. BOLO
				if (PlayStateChangeables.opponentMode
					&& !daNote.mustPress
					&& !FlxG.save.data.middleScroll
					|| (PlayStateChangeables.opponentMode && !daNote.mustPress && FlxG.save.data.middleScroll && executeModchart))
				{
					daNote.x = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData)) + 4].x;
				}

				// JOELwindows7: moverd hscript & also alpha note pls. BOLO add!
				if (!daNote.mustPress
					&& FlxG.save.data.middleScroll
					&& !(executeModchart || executeModHscript || sourceModchart)
					&& !PlayStateChangeables.opponentMode)
					daNote.alpha = 0.5; // JOELwindows7: was 0
				else if (!daNote.mustPress
					&& FlxG.save.data.middleScroll
					&& !(executeModchart || executeModHscript || sourceModchart)
					&& PlayStateChangeables.opponentMode)
					daNote.alpha = 0.5;

				if (daNote.isSustainNote)
				{
					// daNote.x += daNote.width / 2 + 20;
					// JOELwindows7: BOLO comprehensive note x opponent
					if (daNote.mustPress)
					{
						daNote.x += daNote.width / 2 + 18.5;
					}
					else
					{
						if (!FlxG.save.data.middleScroll || executeModchart || sourceModchart)
							if (!PlayStateChangeables.opponentMode)
								daNote.x = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].x + 36.5;
							else
								daNote.x = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData)) + 4].x + 36.5;
					}
					// JOELwindows7: event this. BOLO
					if (SONG.noteStyle == 'pixel')
					{
						// daNote.x -= 11;
						if (daNote.mustPress)
							daNote.x -= 9;
						else
							daNote.x -= 6;
					}
				}

				// trace(daNote.y);
				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				// JOELwindows7: BOLO
				// if (Conductor.songPosition > ((350 * songMultiplier) / (PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed))
				if (Conductor.songPosition > ((350 * songMultiplier) / (scrollSpeed == 1 ? SONG.speed : scrollSpeed)) + daNote.strumTime)
				{
					if (daNote.isSustainNote && daNote.wasGoodHit && Conductor.songPosition >= daNote.strumTime)
					{
						daNote.kill();
						notes.remove(daNote, true);
						daNote.alive = false; // JOELwindows7: BOLO unalive this note.
						daNote.destroy();
					}
					// JOELwindows7: was else. now with BOLO, no longer else
					/*else*/
					if ((daNote.mustPress && !PlayStateChangeables.useDownscroll || daNote.mustPress && PlayStateChangeables.useDownscroll)
						&& daNote.mustPress
						&& daNote.strumTime / songMultiplier - Conductor.songPosition / songMultiplier < -(166 * Conductor.timeScale)
						&& songStarted)
					{
						if (daNote.isSustainNote && daNote.wasGoodHit)
						{
							daNote.kill();
							daNote.alive = false; // JOELwindows7: BOLO unalive this note!
							notes.remove(daNote, true);
							daNote.destroy(); // JOELwindows7: don't forget destroy. BOLO ye
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
										/*
											if (theFunne && !daNote.isSustainNote)
											{
												noteMiss(daNote.noteData, daNote);
											}
										 */
										if (daNote.isParent)
										{
											// health -= 0.15; // give a health punishment for failing a LN // JOELwindows7: BOLO disable. because
											trace("hold fell over at the start");
											for (i in daNote.children)
											{
												i.alpha = 0.3;
												i.sustainActive = false;
											}
											noteMiss(daNote.noteData, daNote); // JOELwindows7: BOLO now get this.
										}
										else
										{
											if (!daNote.wasGoodHit
												&& daNote.isSustainNote
												&& daNote.sustainActive
												&& daNote.spotInLine < daNote.parent.children.length) // JOELwindows7: do not `!=`. use `<` like BOLO did!
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
													// misses++;
													totalNotesHit -= 1;
												}
												updateAccuracy();
												noteMiss(daNote.noteData, daNote); // JOELwindows7: nvm. this seems all note miss here. ah whatever.
											}
											else if (!daNote.wasGoodHit && !daNote.isSustainNote)
											{
												noteMiss(daNote.noteData, daNote); // JOELwindows7: coz afterall we need 2B
												// precisely correct which moment here idk.
												// misses++;
												// updateAccuracy();
												// health -= 0.15;
												// JOELwindows7: BOLO opponent mode! BOLO's is .04 times health loss value. rawly is .15.
												if (!PlayStateChangeables.opponentMode)
													// JOELwindows7: was .04 all
													health -= 0.04 * PlayStateChangeables.healthLoss;
												else
													health += 0.04 * PlayStateChangeables.healthLoss;
											}
										}
									}
								}
								else
								{
									// JOELwindows7: pinpoin COCAL
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
										{
											// noteMiss(daNote.noteData, daNote);
											// JOElwindows7: BOLO miss funneh hp inflict
											if (!PlayStateChangeables.opponentMode)
												health -= 0.04 * PlayStateChangeables.healthLoss;
											else
												health += 0.04 * PlayStateChangeables.healthLoss;
										}
									}

									if (daNote.isParent && daNote.visible)
									{
										health -= 0.15; // give a health punishment for failing a LN
										// trace("hold fell over at the start");
										Debug.logTrace("User released key while playing a sustain at: START");
										for (i in daNote.children)
										{
											i.alpha = 0.3;
											i.sustainActive = false;
										}
										noteMiss(daNote.noteData, daNote); // JOELwindows7: BOLO
									}
									else
									{
										if (!daNote.wasGoodHit
											&& daNote.isSustainNote
											&& daNote.sustainActive
											&& daNote.spotInLine != daNote.parent.children.length)
										{
											// health -= 0.05; // give a health punishment for failing a LN
											// trace("hold fell over at " + daNote.spotInLine);
											Debug.logTrace("User released key while playing a sustain at: " + daNote.spotInLine);
											for (i in daNote.parent.children)
											{
												i.alpha = 0.3;
												i.sustainActive = false;
												// JOELwindows7: BOLO hp inflict. was .04
												if (!PlayStateChangeables.opponentMode)
													health -= (0.08 * PlayStateChangeables.healthLoss) / daNote.parent.children.length;
												else
													health += (0.08 * PlayStateChangeables.healthLoss) / daNote.parent.children.length;
											}
											if (daNote.parent.wasGoodHit)
											{
												// misses++;
												totalNotesHit -= 1;
											}
											noteMiss(daNote.noteData, daNote); // JOELwindows7: BOLO
											// updateAccuracy();
										}
										else if (!daNote.wasGoodHit && !daNote.isSustainNote)
										{
											// misses++;
											// JOELwindows7: and BOLO
											noteMiss(daNote.noteData, daNote);
											// updateAccuracy();
											// health -= 0.15; // JOELwindows7: BOLO says
											// "I forgot replay is broken. So it's not necessary to uncommment deez."
										}
									}
								}
						}

						// JOELwindows7: with additional BOLO
						daNote.active = false; // here
						daNote.visible = false;
						daNote.kill();
						notes.remove(daNote, true);
						daNote.alive = false; // here,
						daNote.destroy(); // and boom.
					}
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

		// JOELwindows7: BOLO shader update
		for (i in shaderUpdates)
			i(elapsed);

		// JOELwindows7: MOAR FUNCTION OF UPDATE. use wisely!
		// manageHeartbeats(elapsed); // no, it's already up there. NVM no need.
		manageWebmer(elapsed);
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
		camZooming = false; // JOELwindows7: BOLO do stop cam zooming.
		endingSong = true;
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
		/*
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
		 */
		immediatelyRemoveVideo(); // JOELwindows7: use this instead!

		if (!loadRep)
		{
			if (!PlayStateChangeables.botPlay) // JOELwindows7: and don't save replay if botplay yess. waste of disk space! Terrabyte is premium!
				rep.SaveReplay(saveNotes, saveJudge, replayAna);
		}
		else
		{
			PlayStateChangeables.botPlay = false;
			// PlayStateChangeables.scrollSpeed = 1 / songMultiplier;
			scrollSpeed = 1 / songMultiplier;
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
			// JOELwindows7: BOLO
			if (ModchartState.haxeInterp != null)
				ModchartState.haxeInterp = null;
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

		// JOELwindows7: INCOMING BOLO'S SUPER MEGA CONDITION POOPS. cAOCAS
		var superMegaConditionShit:Bool = Ratings.timingWindows[3] == 45
			&& Ratings.timingWindows[2] == 90
			&& Ratings.timingWindows[1] == 135
			&& Ratings.timingWindows[0] == 160
			&& (!PlayStateChangeables.botPlay || !PlayState.usedBot)
			&& !FlxG.save.data.practice
			&& PlayStateChangeables.holds
			&& !PlayState.wentToChartEditor
			&& HelperFunctions.truncateFloat(PlayStateChangeables.healthGain, 2) <= 1
			&& HelperFunctions.truncateFloat(PlayStateChangeables.healthLoss, 2) >= 1;

		if (SONG.validScore && superMegaConditionShit) // JOELwindows7: & install it.
		{
			// #if !switch // JOELwindows7: no longer kill by switch
			Highscore.saveScore(PlayState.SONG.songId, Math.round(songScore), storyDifficulty);
			Highscore.saveCombo(PlayState.SONG.songId, Ratings.GenerateLetterRank(accuracy), storyDifficulty);
			// JOELwindows7: BOLO more
			Highscore.saveAcc(PlayState.SONG.songId, HelperFunctions.truncateFloat(accuracy, 2), storyDifficulty);
			Highscore.saveLetter(PlayState.SONG.songId, Ratings.GenerateJustLetterRank(accuracy), storyDifficulty);
			// #end
		}

		if (offsetTesting)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			offsetTesting = false;
			PsychTransition.nextCamera = mainCam; // JOElwindows7: don't forgeton BOLO.
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
			PsychTransition.nextCamera = mainCam; // JOELwindows7: don't forget man. BOLO
			// FlxG.switchState(new StageDebugState(Stage.curStage));
			switchState(new StageDebugState(Stage.curStage)); // JOELwindows7: hex switch state lol
		}
		else
		{
			// JOELwindows7: idk why. BOLO
			#if FEAUTURE_DISCORD
			if (FlxG.save.data.scoreScreen)
			{
				if (FlxG.save.data.discordMode != 0)
					DiscordClient.changePresence('RESULTS SCREEN -- ' + SONG.song + " (" + storyDifficultyText + " " + songMultiplier + "x" + ") "
						+ Ratings.GenerateComboRank(accuracy) + " " + Ratings.GenerateLetterRank(accuracy),
						"\nScr: " + songScore + " ("
						+ HelperFunctions.truncateFloat(accuracy, 2) + "%)" + " | Misses: " + misses, iconRPC);
				else
					DiscordClient.changePresence('RESULTS SCREEN -- ' + SONG.song + " (" + storyDifficultyText + " " + songMultiplier + "x" + ") ", iconRPC);
			}
			#end
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
					// JOELwindows7: pinpoin CAOCAS
					// new FlxTimer().start(delayFirstBeforeThat, function(tmr:FlxTimer)
					// {
					// 	if (FlxG.save.data.scoreScreen)
					// 	{
					//		paused = true;
					// 		if (FlxG.save.data.songPosition)
					// 		{
					// 			FlxTween.tween(songPosBar, {alpha: 0}, 1);
					// 			FlxTween.tween(bar, {alpha: 0}, 1);
					// 			FlxTween.tween(songName, {alpha: 0}, 1);
					//			FlxTween.tween(tempoBar, {alpha: 0}, 1); // JOELwindows7: here tempo bar
					//			FlxTween.tween(metronomeBar, {alpha: 0}, 1); // JOELwindows7: & metronome bar
					// 		}
					// 		openSubState(new ResultsScreen(SONG.hasEpilogueVideo, SONG.hasEpilogueVideo ? SONG.epilogueVideoPath : "null"));
					// 		createTimer(1, function(tmr:FlxTimer) // JOELwindows7: Managed BOLO timer
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
					//		PsychTransition.nextCamera = mainCam; // JOELwindows7: BOLO
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
						// var blackShit:FlxUISprite = new FlxUISprite(-FlxG.width * FlxG.camera.zoom,
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

					// JOELwindows7: BOLO Psyched trans in next camera
					if (FlxTransitionableState.skipNextTransIn)
					{
						PsychTransition.nextCamera = null;
					}

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
					// Debug.logTrace('Here\'s path for this outro $epilogueVideoPath\n and next song intro ${SONG.videoPath}');
					Debug.logInfo('Here\'s path for this outro $epilogueVideoPath\n and next song intro ${SONG.videoPath}');
					// Debug.logTrace('and outro is enabled ${Std.string(hasEpilogueVideo)} and next song intro enabled ${SONG.hasVideo}');
					Debug.logInfo('and outro is enabled ${Std.string(hasEpilogueVideo)} and next song intro enabled ${SONG.hasVideo}');

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

				// createTimer(delayFirstBeforeThat, function(tmr:FlxTimer) // JOELwindows7: BOLO managed timer
				// { // JOELwindows7: here this delay wow.
				paused = true;

				FlxG.sound.music.stop();
				vocals.stop();
				vocals2.stop(); // JOELwindows7: ye

				// JOELwindows7: don't forget clean modchart if haven't already
				scronchLuaScript();
				scronchHscript();

				if (FlxG.save.data.scoreScreen)
				{
					paused = true; // JOELwindows7: BOLO make sure again.
					openSubState(new ResultsScreen());
					createTimer(1, function(tmr:FlxTimer) // JOELwindows7: BOLO managed timer
					{
						inResults = true;
					});
				}
				else
				{
					PsychTransition.nextCamera = mainCam; // JOELwindows7: BOLO
					// FlxG.switchState(new FreeplayState());
					Conductor.changeBPM(102); // JOELwindows7: change tempo to this??
					switchState(new FreeplayState()); // JOELwindows7: hex switch state lol
					clean();
				}
				// });
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
	var currentTimingShown:FlxUIText = null;

	// JOELwindows7: pinpoin HUACADOS

	private function popUpScore(daNote:Note):Void
	{
		var noteDiff:Float;
		if (daNote != null)
			noteDiff = -(daNote.strumTime - Conductor.songPosition);
		else
			noteDiff = Conductor.safeZoneOffset; // Assumed SHIT if no note was given
		var noteDiffAbs = Math.abs(noteDiff); // JOELwindows7: BOLO's note diff absolute value!!!

		// JOELwindows7: BOLO if not sustain????
		// TODO: enableable wife score just like Pump it up??
		var wife:Float = 0;
		if (!daNote.isSustainNote)
			wife = EtternaFunctions.wife3(-noteDiff, Conductor.timeScale);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;
		vocals2.volume = 1; // JOELwindows7: ye
		var placement:String = Std.string(combo);

		var coolText:FlxUIText = new FlxUIText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		coolText.y -= 350;
		coolText.cameras = [camHUD];
		//

		var rating:FlxUISprite = new FlxUISprite();
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
					if (!PlayStateChangeables.opponentMode)
						health -= 1;
					else
						health += 1;
					// playSoundEffect("mine-duar", 1, 'shared'); // no need, I guess..
				}
				if (daNote.noteType == 1 || daNote.noteType == 0)
				{
					score = -300;
					combo = 0;
					misses++;
					// health -= 0.1;
					// JOELwindows7: BOLO health hp
					if (!PlayStateChangeables.opponentMode)
					{
						health -= 0.2 * PlayStateChangeables.healthLoss;
						if (PlayStateChangeables.skillIssue)
							health = 0;
					}
					else
					{
						health += 0.2 * PlayStateChangeables.healthLoss;
						if (PlayStateChangeables.skillIssue)
							health = 2.1;
					}
					ss = false;
					shits++;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit -= 1;
				}
			case 'bad':
				if (daNote.noteType == 2)
				{
					if (!PlayStateChangeables.opponentMode)
						health -= 1;
					else
						health += 1;
					// playSoundEffect("mine-duar", 1, 'shared'); // there's already being hitsound
				}
				if (daNote.noteType == 1 || daNote.noteType == 0)
				{
					daRating = 'bad';
					score = 0;
					// health -= 0.06;
					// JOELwindows7: BOLO hp
					if (!PlayStateChangeables.opponentMode)
						health -= 0.06 * PlayStateChangeables.healthLoss;
					else
						health += 0.06 * PlayStateChangeables.healthLoss;
					ss = false;
					bads++;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 0.50;
				}
			case 'good':
				if (daNote.noteType == 2)
				{
					if (!PlayStateChangeables.opponentMode)
						health -= 1;
					else
						health += 1;
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
					if (!PlayStateChangeables.opponentMode)
						health -= 1;
					else
						health += 1;
					// playSoundEffect("mine-duar", 1, 'shared');
				}
				if (daNote.noteType == 1 || daNote.noteType == 0)
				{
					score = 350; // JOELwindows7: okee BOLO
					// if (health < 2)
					// 	health += 0.04;
					// JOELwindows7: BOLO advanced hp
					if (!PlayStateChangeables.opponentMode && health < 2)
					{
						health += 0.04 * PlayStateChangeables.healthGain;
					}
					else if (PlayStateChangeables.opponentMode && health > 0)
					{
						health -= 0.04 * PlayStateChangeables.healthGain;
					}
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
		spawnNoteHitlineOnNote(daNote, daNote.noteType, 0, daRatingInt); // JOELwindows7: Ragnarock hitline lol! lmao!!
		// C'mon, Cam (ninjamuffin)!!! finish embargo rn!!! do not finish plot twistly as a demo for the full ass!!! that's rude!
		// oh, embargo done??

		// JOELwindows7: also here's BOLO notesplash in case you need it idk
		/*
			if (daRating == 'sick')
			{
				NoteSplashesSpawn(daNote);
			}
		 */

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
			var pixelShitPart3:String = 'shared'; // JOELwindows7: BOLO
			var pixelShitPart4:String = null;

			if (SONG.noteStyle == 'pixel')
			{
				pixelShitPart1 = 'weeb/pixelUI/';
				pixelShitPart2 = '-pixel';
				pixelShitPart3 = 'week6';
				pixelShitPart4 = 'week6';
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

			// var msTiming = HelperFunctions.truncateFloat(noteDiff / songMultiplier, 3);
			msTiming = HelperFunctions.truncateFloat(noteDiffAbs, 3); // JOELwindows7: note dif abs?! SUSOTU
			if (PlayStateChangeables.botPlay && !loadRep)
				msTiming = 0;

			if (loadRep)
				msTiming = HelperFunctions.truncateFloat(findByTime(daNote.strumTime)[3], 3);

			if (currentTimingShown != null)
				remove(currentTimingShown);

			currentTimingShown = new FlxUIText(0, 0, 0, "0ms");
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

			// JOELwindows7: idk man.
			var comboSpr:FlxUISprite = new FlxUISprite();
			// comboSpr.loadGraphic(Paths.loadImage(pixelShitPart1 + 'combo' + pixelShitPart2, pixelShitPart3));
			comboSpr.loadGraphic(Paths.imageGraphic(pixelShitPart1 + 'combo' + pixelShitPart2, pixelShitPart3));
			comboSpr.screenCenter();
			comboSpr.x = rating.x - 84; // JOELwindows7: was +0. now with BOLO -84.
			comboSpr.y = rating.y + 145; // JOELwindows7: was +100. now with BOLO +145.
			comboSpr.acceleration.y = 600;
			comboSpr.velocity.y -= 150;
			// JOELwindows7: BOLO add it now.
			if (FlxG.save.data.showCombo)
				if ((!PlayStateChangeables.botPlay || loadRep) && combo >= 5)
					add(comboSpr);

			currentTimingShown.screenCenter();
			currentTimingShown.x = comboSpr.x + 225; // JOELwindows7: was +100. now is BOLO +255
			// JOELwindows7: INTERUPT BOLO
			if (SONG.noteStyle == 'pixel')
			{
				currentTimingShown.x -= 15;
				currentTimingShown.y -= 15;
				comboSpr.x += 5.5;
				comboSpr.y += 29.5;
			}
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
				comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.6)); // JOELwindows7: was times 0.7. now is BOLO times 0.6
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
				// JOELwindows7: okeh. drastic measures.
				var numScore:FlxUISprite = new FlxUISprite();
				// numScore.loadGraphic(Paths.loadImage(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2, pixelShitPart3));
				numScore.loadGraphic(Paths.imageGraphic(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2, pixelShitPart4));
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
				if (combo >= 5) // JOELwindows7: BOLO's only if more than 5 combo
					add(numScore);

				visibleCombos.push(numScore);

				createTween(numScore, {alpha: 0}, 0.2, { // JOELwindows7: BOLO managed tween
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

			createTween(rating, {alpha: 0}, 0.2, { // JOELwindows7: BOLO managed tween
				startDelay: Conductor.crochet * 0.001,
				onUpdate: function(tween:FlxTween)
				{
					if (currentTimingShown != null)
						currentTimingShown.alpha -= 0.02;
					timeShown++;
				}
			});

			createTween(comboSpr, {alpha: 0}, 0.2, { // JOELwindows7: BOLO managed tween
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

		// JOELwindows7: BOLO keypress hitsound
		/*
			if (FlxG.save.data.hitSound != 0 && pressArray.contains(true))
			{
				var daHitSound:FlxSound = new FlxSound().loadEmbedded(Paths.sound('hitsounds/${HitSounds.getSoundByID(FlxG.save.data.hitSoundSelect).toLowerCase()}',
					'shared'));
				daHitSound.volume = FlxG.save.data.hitVolume;
				daHitSound.play();
			}
		 */

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
				// JOELwindows7: BOLO opponent mode hold timer pls
				if (!PlayStateChangeables.opponentMode)
					boyfriend.holdTimer = 0;
				else
					dad.holdTimer = 0;

				var possibleNotes:Array<Note> = []; // notes that can be hit
				var directionList:Array<Int> = []; // directions that can be hit
				var dumbNotes:Array<Note> = []; // notes to kill later
				var directionsAccounted:Array<Bool> = [false, false, false, false]; // we don't want to do judgements for more than one presses

				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit
						&& daNote.mustPress
						&& !daNote.wasGoodHit
						&& !directionsAccounted[daNote.noteData]
						&& !daNote.tooLate)
						// JOELwindows7: BOLO. & if not too late!!
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

				if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001
					&& (!holdArray.contains(true) || PlayStateChangeables.botPlay)
					&& !PlayStateChangeables.opponentMode)
					// JOELwindows7: BOLO's & if not opponent mode
				{
					if (boyfriend.animation.curAnim.name.startsWith('sing')
						&& !boyfriend.animation.curAnim.name.endsWith('miss')
						&& !PlayStateChangeables.optimize)
						// JOELiwndows7: BOLO's & if not optimize
						boyfriend.dance();
				}

				// JOELwindows7: BOLO opponent dance check!
				if (PlayStateChangeables.opponentMode)
				{
					if (!holdArray.contains(true) || PlayStateChangeables.botPlay)
					{
						if (!PlayStateChangeables.optimize
							&& dad.animation.curAnim.name.startsWith('sing')
							&& dad.animation.curAnim.finished
							&& !dad.animation.curAnim.name.endsWith('miss'))
						{
							dad.dance();
						}
					}
				}
				else
				{
					if (!PlayStateChangeables.optimize
						&& dad.animation.curAnim.name.startsWith('sing')
						&& dad.animation.curAnim.finished
						&& !dad.animation.curAnim.name.endsWith('miss'))
					{
						dad.dance();
					}
				}

				/*else*/
				if (!FlxG.save.data.ghost) // JOELwindows7: BOLO remove else
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
							// JOELwindows7: BOLO good note hit hold timer
							if (!PlayStateChangeables.opponentMode)
								boyfriend.holdTimer = 0;
							else
								dad.holdTimer = 0;
						}
					}
					else
					{
						if (daNote.noteType != 2)
						{ // JOELwindows7: do not hit mine!!! also if power up there, do not hit negative powerup!
							goodNoteHit(daNote);
							// JOELwindows7: BOLO good note hit hold timer
							if (!PlayStateChangeables.opponentMode)
								boyfriend.holdTimer = 0;
							else
								dad.holdTimer = 0;
						}
					}
				}
			});

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay))
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing')
				&& !boyfriend.animation.curAnim.name.endsWith('miss')
				&& (boyfriend.animation.curAnim.curFrame >= 10 || boyfriend.animation.curAnim.finished)
				&& !PlayStateChangeables.optimize // JOELwindows7: BOLO's & if not optimize
			)
				boyfriend.dance();
		}

		// JOELwindows7: BOLO opponent mode dance
		if (PlayStateChangeables.opponentMode)
		{
			if (!PlayStateChangeables.optimize)
			{
				if (!holdArray.contains(true) || PlayStateChangeables.botPlay)
				{
					if (dad.animation.curAnim.name.startsWith('sing')
						&& dad.animation.curAnim.finished
						&& !dad.animation.curAnim.name.endsWith('miss'))
					{
						dad.dance();
					}
				}
			}
		}
		else
		{
			if (!PlayStateChangeables.optimize
				&& dad.animation.curAnim.name.startsWith('sing')
				&& dad.animation.curAnim.finished
				&& !dad.animation.curAnim.name.endsWith('miss'))
			{
				dad.dance();
			}
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
	public var vlcHandlerHasFinished:Bool = false; // JOELwindows7: flag to be lifted by vlcHandler when video finish.
	public var playingDathing = false;
	public var videoSprite:FlxUISprite;

	public function backgroundVideo(source:String) // for background videos
	{
		if (FlxG.save.data.disableVideoCutscener)
		{
			Debug.logInfo('Video Cutscener disabled. No BG video');
			return;
		}

		var ourSource:String = "assets/videos/daWeirdVid/dontDelete.webm";

		#if FEATURE_VLC
		// JOELwindows7: from that BrightFyre MP4 support, outputting to FlxSprite
		// https://github.com/brightfyregit/Friday-Night-Funkin-Mp4-Video-Support#outputting-to-a-flxsprite
		useVideo = true;
		useVLC = true; // JOELwindows7: yes VLC
		vlcHandler = new MP4Sprite(-470, -30);
		// vlcHandler = new MP4Sprite();
		// vlcHandler.finishCallback = onVideoSpriteFinish;
		vlcHandler.bitmap.onEndReached.add(onVideoSpriteFinish);
		vlcHandlerHasFinished = false; // JOELwindows7: reset flag yeahoid
		// vlcHandler.playMP4(source, null, videoSprite); // make the transition null so it doesn't take you out of this state
		// vlcHandler.playVideo(source, false, false); // make the transition null so it doesn't take you out of this state
		vlcHandler.play(source, false); // make the transition null so it doesn't take you out of this state

		// videoSprite.setGraphicSize(Std.int(videoSprite.width * 1.2));
		// vlcHandler.setGraphicSize(Std.int(vlcHandler.width * 1.2)); // aaaaaaaaaaaaaaaaaaaaaa

		remove(gf);
		remove(boyfriend);
		remove(dad);
		// add(videoSprite);
		add(vlcHandler);
		add(gf);
		add(boyfriend);
		add(dad);

		Debug.logInfo('poggers');

		// JOELwindows7: wtf, you still forgot these?!?!?!?
		if (!songStarted)
			vlcHandler.bitmap.pause();
		else
			vlcHandler.bitmap.resume();
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

		videoSprite = new FlxUISprite(-470, -30);
		videoSprite.loadGraphic(data);

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
			// vocals.volume = 0; // JOELwindows7: BOLO
			// JOELwindows7: BOLO skill issue
			if (PlayStateChangeables.skillIssue)
				if (!PlayStateChangeables.opponentMode)
					health = 0;
				else
					health = 2.1;
			// health -= 0.2;
			if (combo > 5 && gf.animOffsets.exists('sad') && !PlayStateChangeables.opponentMode) // JOELwindows7: BOLO said only if not in opponent
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
						// -(166 * Math.floor((PlayState.rep.replay.sf / 60) * 1000) / 166)
						- (Ratings.timingWindows[0] * Math.floor((PlayState.rep.replay.sf / 60) * 1000) / Ratings.timingWindows[0]) // JOELwindows7: BOLO
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
					// -(166 * Math.floor((PlayState.rep.replay.sf / 60) * 1000) / 166)
					- (Ratings.timingWindows[0] * Math.floor((PlayState.rep.replay.sf / 60) * 1000) / Ratings.timingWindows[0])
				]);
				saveJudge.push("miss");
			}

			// var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition);
			// var wife:Float = EtternaFunctions.wife3(noteDiff, FlxG.save.data.etternaMode ? 1 : 1.7);

			totalNotesHit -= .5; // JOELwindows7: was 1. now add .5 . BOLO

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
			// boyfriend.playAnim('sing' + dataSuffix[direction] + 'miss', true);
			if (!PlayStateChangeables.optimize)
			{
				// JOELwindows7: BOLO opponent mode check check
				if (!PlayStateChangeables.opponentMode)
					boyfriend.playAnim('sing' + dataSuffix[direction] + 'miss', true);
				else if (PlayStateChangeables.opponentMode && dad.animOffsets.exists('sing' + dataSuffix[direction] + 'miss'))
					dad.playAnim('sing' + dataSuffix[direction] + 'miss', true);
			}

			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
				luaModchart.executeState('playerOneMiss', [direction, Conductor.songPosition, curBeat, curStep]);
			if (stageScript != null)
				stageScript.executeState('playerOneMiss', [direction, Conductor.songPosition, curBeat, curStep]);
			#end
			if (hscriptModchart != null)
				hscriptModchart.executeState('playerOneMiss', [direction, Conductor.songPosition, curBeat, curStep]);
			if (stageHscript != null)
				stageHscript.executeState('playerOneMiss', [direction, Conductor.songPosition, curBeat, curStep]);
			executeModchartState('characterMiss', [
				!PlayStateChangeables.opponentMode ? 0 : 1,
				0,
				direction,
				Conductor.songPosition,
				curBeat,
				curStep
			]);

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
		updatedAcc = true; // JOELwindows7: BOLO updated accuracy pls.
		scoreTxt.visible = true; // JOELwindows7: BOLO make score text visible pls

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

		// JOELwindows7: here's where we moved. the bottom score text. with BOLO if not lerp score text pls
		if (!FlxG.save.data.lerpScore)
			scoreTxt.text = Ratings.CalculateRanking(songScore, songScoreDef, nps, maxNPS,
				(FlxG.save.data.roundAccuracy ? FlxMath.roundDecimal(accuracy, 0) : accuracy), boyfriend.getHeartRate(0), boyfriend.getHeartTier(0));
		// JOELwindows7: wai wait! Custom sponsor word. ... I mean judgement words. here this too! also more idk.
		// judgementCounter.text = 'Sicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\nMisses: ${misses}';
		// judgementCounter.text = 'Combo: ${combo}\nMax Combo: ${highestCombo}\n\n${judgementWords[4]}: ${sicks}\n${judgementWords[3]}: ${goods}\n${judgementWords[2]}: ${bads}\n${judgementWords[1]}: ${shits}\n${judgementWords[0]}: ${misses}';
		judgementCounter.text = '${getText("$GAMEPLAY_HUD_TEXT_COMBO")}: ${combo}\n${getText("$GAMEPLAY_HUD_TEXT_MAXCOMBO")}: ${highestCombo}\n\n${judgementWords[4]}: ${sicks}\n${judgementWords[3]}: ${goods}\n${judgementWords[2]}: ${bads}\n${judgementWords[1]}: ${shits}\n${judgementWords[0]}: ${misses}';
		judgementCounter.setPosition(FlxG.width - judgementCounter.width - 15, 0); // JOELwindows7: don't forget readjust everytime.
		judgementCounter.screenCenter(Y); // JOELwindows7: yeah
	}

	// JOELwindows7: BOLO update score text like osu! TOTUSCA
	function updateScoreText()
	{
		scoreTxt.text = Ratings.CalculateRanking(shownSongScore, songScoreDef, nps, maxNPS,
			(FlxG.save.data.roundAccuracy ? FlxMath.roundDecimal(shownAccuracy, 0) : shownAccuracy), boyfriend.getHeartRate(0), boyfriend.getHeartTier(0));
	}

	function getKeyPresses(note:Note):Int
	{
		var possibleNotes:Array<Note> = []; // copypasted but you already know that

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate) // JOELwindows7: & is not too late. BOLO
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
		// JOELwindows7: BOLO. allow zoom if opponent
		if (PlayStateChangeables.opponentMode)
			camZooming = FlxG.save.data.camzoom;

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
				// JOELwindows7: BOLO enable sustain hit
				/* Enable Sustains to be hit. 
					//This is to prevent hitting sustains if you hold a strum before the note is coming without hitting the note parent. 
					(I really hope I made me understand lol.) */
				if (note.isParent)
					for (i in note.children)
						i.sustainActive = true;
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

			// JOELwindows7: BOLO opponent sing anim
			if (!FlxG.save.data.optimize)
			{
				if (PlayStateChangeables.opponentMode)
					dad.playAnim('sing' + dataSuffix[note.noteData] + altAnim, true);
				else
					boyfriend.playAnim('sing' + dataSuffix[note.noteData] + altAnim, true);
			}

			// JOELwindows7: BOLO megamind
			/*
				———————————No HP regen?———————————
				⠀⣞⢽⢪⢣⢣⢣⢫⡺⡵⣝⡮⣗⢷⢽⢽⢽⣮⡷⡽⣜⣜⢮⢺⣜⢷⢽⢝⡽⣝
				⠸⡸⠜⠕⠕⠁⢁⢇⢏⢽⢺⣪⡳⡝⣎⣏⢯⢞⡿⣟⣷⣳⢯⡷⣽⢽⢯⣳⣫⠇
				⠀⠀⢀⢀⢄⢬⢪⡪⡎⣆⡈⠚⠜⠕⠇⠗⠝⢕⢯⢫⣞⣯⣿⣻⡽⣏⢗⣗⠏⠀
				⠀⠪⡪⡪⣪⢪⢺⢸⢢⢓⢆⢤⢀⠀⠀⠀⠀⠈⢊⢞⡾⣿⡯⣏⢮⠷⠁⠀⠀
				⠀⠀⠀⠈⠊⠆⡃⠕⢕⢇⢇⢇⢇⢇⢏⢎⢎⢆⢄⠀⢑⣽⣿⢝⠲⠉⠀⠀⠀⠀
				⠀⠀⠀⠀⠀⡿⠂⠠⠀⡇⢇⠕⢈⣀⠀⠁⠡⠣⡣⡫⣂⣿⠯⢪⠰⠂⠀⠀⠀⠀
				⠀⠀⠀⠀⡦⡙⡂⢀⢤⢣⠣⡈⣾⡃⠠⠄⠀⡄⢱⣌⣶⢏⢊⠂⠀⠀⠀⠀⠀⠀
				⠀⠀⠀⠀⢝⡲⣜⡮⡏⢎⢌⢂⠙⠢⠐⢀⢘⢵⣽⣿⡿⠁⠁⠀⠀⠀⠀⠀⠀⠀
				⠀⠀⠀⠀⠨⣺⡺⡕⡕⡱⡑⡆⡕⡅⡕⡜⡼⢽⡻⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
				⠀⠀⠀⠀⣼⣳⣫⣾⣵⣗⡵⡱⡡⢣⢑⢕⢜⢕⡝⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
				⠀⠀⠀⣴⣿⣾⣿⣿⣿⡿⡽⡑⢌⠪⡢⡣⣣⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
				⠀⠀⠀⡟⡾⣿⢿⢿⢵⣽⣾⣼⣘⢸⢸⣞⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
				⠀⠀⠀⠀⠁⠇⠡⠩⡫⢿⣝⡻⡮⣒⢽⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
				—————————————————————————————
				Just kidding lol
			 */

			// JOELwindows7: BOLO sustaione add HP. GOUTA
			if (note.isSustainNote)
				if (!PlayStateChangeables.opponentMode && health <= 2)
					health += 0.02 * PlayStateChangeables.healthGain;
				else if (health > 0)
					health -= 0.02 * PlayStateChangeables.healthGain;

			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
				luaModchart.executeState('playerOneSing', [note.noteData, Conductor.songPosition, curBeat, curStep]);
			if (stageScript != null)
				stageScript.executeState('playerOneSing', [note.noteData, Conductor.songPosition, curBeat, curStep]);
			#end
			if (hscriptModchart != null)
				hscriptModchart.executeState('playerOneSing', [note.noteData, Conductor.songPosition, curBeat, curStep]);
			if (stageHscript != null)
				stageHscript.executeState('playerOneSing', [note.noteData, Conductor.songPosition, curBeat, curStep]);
			// JOELwindows7: absoluton.
			executeModchartState('characterSing', [
				!PlayStateChangeables.opponentMode ? 0 : 1,
				0,
				note.noteData,
				Conductor.songPosition,
				curBeat,
				curStep
			]);

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
			{
				updateScoreText(); // JOELwindows7: BOLO yo update score text yea. osu!
				updateAccuracy();
			}
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
		// JOELwindows7: BOLO make sure music time check is absolute!
		if (Conductor.songPosition * songMultiplier > Math.abs(FlxG.sound.music.time + 25)
			|| Conductor.songPosition * songMultiplier < Math.abs(FlxG.sound.music.time - 25))
		{
			resyncVocals();
		}

		// JOELwindows7: incoming, week 7 yoink yey! luckydog7
		// picoSpeaker and running tankmen

		if (SONG.songId == 'stress-legacy')
		{
			if (Stage.picoStep != null && Stage.tankStep != null)
			{ // JOELwindows7: make sure null safety. the songId changed before loading next song looks like.
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
						// JOELwindows7: hey, there's a better way! use Recycle!
						var tankmanRunner:TankmenBG = new TankmenBG();
						// var tankmanRunner:TankmenBG = Stage.tankmanRun.recycle(TankmenBG.new);
						tankmanRunner.resetShit(FlxG.random.int(630, 730) * -1, 255, true, 1, 1.5);
						Stage.tankmanRun.add(tankmanRunner);
					}
				}

				// Right spawn
				for (i in 0...Stage.tankStep.right.length)
				{
					if (curStep == Stage.tankStep.right[i])
					{
						var tankmanRunner:TankmenBG = new TankmenBG(); // JOELwindows7: hey, you better recycle this. check this out!
						// var tankmanRunner:TankmenBG = Stage.tankmanRun.recycle(TankmenBG.new);
						tankmanRunner.resetShit(FlxG.random.int(1500, 1700) * 1, 275, false, 1, 1.5);
						Stage.tankmanRun.add(tankmanRunner);
					}
				}
			}
		}

		if (dad.curCharacter == 'tankman-legacy' && SONG.songId == 'stress-legacy')
		{
			if (curStep == 735)
			{
				dad.addOffset("singDOWN", 45, 20);
				dad.animation.getByName('singDOWN').frames = dad.animation.getByName('prettyGoodAnim').frames;
				dad.animation.getByName('singDOWN-alt').frames = dad.animation.getByName('prettyGoodAnim').frames; // alright, somebody pls explain.
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
				dad.animation.getByName('singDOWN-alt').frames = dad.animation.getByName('oldSingDOWN').frames;
			}
		}

		// JOELwindows7: we still need kludge for BOLO anyway. I know, can just insert event but uh.. afraid there'd be an update to the
		// beatmap or whatever.
		if (dad.curCharacter == 'tankman' && SONG.songId == 'stress')
		{
			if (tankKludgeText != null)
			{
				if (curStep == 735)
				{
					// add(tankKludgeText);
					tankKludgeText.y = 350;
					tankKludgeText.reset(FlxG.width / 2, 180);
					tankKludgeText.alpha = 1;
					tankKludgeText.text = 'Heh!...';
					tankKludgeText.screenCenter(X);
					createTimer(1.8, function(tmr:FlxTimer)
					{
						tankKludgeText.text = 'Pretty good!';
						tankKludgeText.screenCenter(X);
					});
				}
				if (curStep == 767)
				{
					createTween(tankKludgeText, {alpha: 0}, 1, {
						ease: FlxEase.quadInOut,
						onComplete: function(twn:FlxTween)
						{
							tankKludgeText.kill();
							// remove(tankKludgeText);
						}
					});
				}
			}
		}

		if (dad.curCharacter == 'tankman-legacy' && SONG.songId == 'ugh-legacy')
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

		// JOELwindows7: how about add some comical `UGH` balloon? lol!
		if (dad.curCharacter == 'tankman' && SONG.songId == 'ugh')
		{
			if (ughImage != null)
			{
				if (curStep == 59 || curStep == 443 || curStep == 523 || curStep == 827)
				{
					ughImage.alpha = 1;
					createTween(ughImage, {alpha: 0}, 1.5);
				}
				if (curStep == 64 || curStep == 448 || curStep == 528 || curStep == 832)
				{
				}
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

		// JOELwindows7: BOLO canceled INTERLOPE scroll speed pulse effect
		// INTERLOPE SCROLL SPEED PULSE EFFECT SHIT (TESTING PURPOSES) --Credits to Hazard
		// Also check out tutorial modchart.lua that has this same tween but better :3
		/*if (curStep % Math.floor(4 * songMultiplier) == 0)
			{
				var scrollSpeedShit:Float = scrollSpeed;
				scrollSpeed /= scrollSpeed;
				scrollTween = createTween(this, {scrollSpeed: scrollSpeedShit}, 0.25 / songMultiplier, {
					ease: FlxEase.sineOut,
					onComplete: function(twn:FlxTween)
					{
						scrollTween = null;
					}
				});
		}*/

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

		// JOELwindows7: right here, BOLO moved the HARDCODING effect actions like tutorial ayy & others to here.
		// so idk, this something todo or not, idk..

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

		// JOELwindows7: pinpoin DORMIGkgang
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
		// JOELwindows7: bruh, you forgot this
		setModchartVar('curBeat', [curBeat]);

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

		// JOELwindows7: HARDCODING FOR BBPANZU SKY, see that PlayState
		if (Stage.curStage == "theShift")
		{
			if (Stage.shiftbg != null)
				Stage.shiftbg.animation.play("bop");
		}
		if (Stage.curStage == "theManifest")
		{
			if (Stage.shiftbg != null)
				Stage.shiftbg.animation.play("bop");
			if (Stage.floor != null)
				Stage.floor.animation.play("bop");
		}
		// Song orders for vs. Sky: Wife Forever, Sky, Manifest

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
			// JOELwindows7: BOLO wraparound optimize
			if (!PlayStateChangeables.optimize)
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
					if (curBeat == 7 || curBeat == 23 || curBeat == 39 || curBeat == 55 || curBeat == 71 || curBeat == 87 || curBeat == 103
						|| curBeat == 119 || curBeat == 135 || curBeat == 151 || curBeat == 167 || curBeat == 183)
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
			}

			// JOELwindows7: daLyric boi
			if (lyricExists)
			{
				try
				{
					// lyricers.text = lyricing[curSection][0] + "\n" + lyricing[curSection][1];
					var filterLyric:Array<String> = [
						CoolUtil.getText(lyricing[Std.int(Math.floor(curBeat / 4))][0] != null ? lyricing[Std.int(Math.floor(curBeat / 4))][0] : '',
							'subtitle'),
						CoolUtil.getText(lyricing[Std.int(Math.floor(curBeat / 4))][1] != null ? lyricing[Std.int(Math.floor(curBeat / 4))][1] : '',
							'subtitle'),
					];
					// lyricers.text = lyricing[Std.int(Math.floor(curBeat / 4))][0] + "\n" + lyricing[Std.int(Math.floor(curBeat / 4))][1];
					lyricers.text = '${filterLyric[0]}\n${filterLyric[1]}';
				}
				catch (e)
				{
					lyricers.text = '\n';
				}
				// lyricers.scrollFactor.set();
				repositionLyric();
			}

			if (PlayStateChangeables.optimize)
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
	// JOELwindows7: BOLO's stuffs zoids
	// update setting. TOGEDI
	public function updateSettings():Void
	{
		scoreTxt.y = healthBarBG.y;
		if (FlxG.save.data.colour)
			healthBar.createFilledBar(dad.barColor, boyfriend.barColor);
		else
			healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		healthBar.updateBar();
		laneunderlay.alpha = FlxG.save.data.laneTransparency;
		if (!FlxG.save.data.middleScroll)
			laneunderlayOpponent.alpha = FlxG.save.data.laneTransparency;

		if (!isStoryMode)
			PlayStateChangeables.botPlay = FlxG.save.data.botplay;

		iconP1.kill();
		iconP2.kill();
		healthBar.kill();
		healthBarBG.kill();
		remove(healthBar);
		remove(iconP1);
		remove(iconP2);
		remove(healthBarBG);

		judgementCounter.kill();
		remove(judgementCounter);

		if (FlxG.save.data.judgementCounter)
		{
			judgementCounter.revive();
			add(judgementCounter);
		}

		if (songStarted)
		{
			songName.kill();
			songPosBar.kill();
			bar.kill();
			tempoBar.kill(); // JOELwindows7: yog
			metronomeBar.kill(); // JOELwindows7: yeg
			remove(bar);
			remove(songName);
			remove(songPosBar);
			remove(tempoBar); // JOELwindows7: keag
			remove(metronomeBar); // JOELwindows7: keig
			songName.visible = FlxG.save.data.songPosition;
			songPosBar.visible = FlxG.save.data.songPosition;
			bar.visible = FlxG.save.data.songPosition;
			tempoBar.visible = FlxG.save.data.songPosition; // JOELwindows7: kug
			metronomeBar.visible = FlxG.save.data.songPosition; // JOELwindows7: kig
			if (FlxG.save.data.songPosition)
			{
				songName.revive();
				songPosBar.revive();
				bar.revive();
				tempoBar.revive(); // JOELwindows7: gork
				metronomeBar.revive(); // JOELwindows7: gerk
				add(songPosBar);
				add(songName);
				add(bar);
				add(tempoBar); // JOELwindows7: oghz
				add(metronomeBar); // JOELwindows7: ughz
				songName.alpha = 1;
				songPosBar.alpha = 0.85;
				bar.alpha = 1;
				tempoBar.alpha = 1; // JOELwindows7: huh
				metronomeBar.alpha = 1; // JOELwindows7: heh
			}
		}

		if (!isStoryMode)
		{
			botPlayState.kill();
			remove(botPlayState);
			if (PlayStateChangeables.botPlay)
			{
				usedBot = true;
				botPlayState.revive();
				add(botPlayState);
			}
		}

		if (FlxG.save.data.healthBar)
		{
			healthBarBG.revive();
			healthBar.revive();
			iconP1.revive();
			iconP2.revive();
			add(healthBarBG);
			add(healthBar);
			add(iconP1);
			add(iconP2);
			scoreTxt.y = healthBarBG.y + 50;
		}
	}

	// change scroll speed
	public function changeScrollSpeed(mult:Float, time:Float, ease):Void
	{
		var newSpeed = PlayStateChangeables.scrollSpeed * mult;
		if (time <= 0)
		{
			// PlayStateChangeables.scrollSpeed *= newSpeed;
			scrollSpeed *= newSpeed;
		}
		else
		{
			scrollTween = createTween(this, {scrollSpeed: newSpeed}, time, {
				// scrollTween = createTweenNum(PlayStateChangeables.scrollSpeed, newSpeed, time, {
				ease: ease,
				onComplete: function(twn:FlxTween)
				{
					scrollTween = null;
				}
			});
			scrollMult = mult;
		}
	}

	// JOELwindows7: BOLO tankIntro
	public var tankIntroEnd:Bool = false;

	var tankKludgeText:FlxUIText; // & the sub text too. that's mine.
	var ughImage:FlxUISprite; // oh yess, also the `UGH` image lol!
	var distortoMusic:FlxSound; // & this distorto sound thingy.
	var curTankTime:Float; // position bar for cutscener. this adds by elapsed update when inCutscene or inCinematic is on. idk

	// JOELwindows7: on 2nd thought, why not just build the initializers at here instead?
	function buildFunneehThingie()
	{
		// JOELwindows7: Kludge subtitle, sorry, it's kludge, I'll make proper sub bottom later.
		tankKludgeText = new FlxUIText(FlxG.width / 2, FlxG.height - 120, 500, '\n', 24); // JOELwindows7: install a text!
		tankKludgeText.size = 24;
		tankKludgeText.setFormat(Paths.font("UbuntuMono-R-NF.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		tankKludgeText.screenCenter(X);
		tankKludgeText.scrollFactor.set();

		// ughImage = new FlxUISprite(dad.x + dad.width + 10, dad.y - 8); // we're placing on top. dad wasn't there yet.
		// better position later at last or else we'll Null Object Reference
		ughImage = new FlxUISprite();
		ughImage.loadGraphic(Paths.image('Ugh-tankman', 'week7'));
		ughImage.alpha = 0;
		ughImage.antialiasing = FlxG.save.data.antialiasing;

		// place this on the top before images were created!
		// wait though, there is dad positionalizing
	}

	function addFuneehThingie()
	{
		ughImage.setPosition(dad.x + dad.width - 150, dad.y - 8);
		add(tankKludgeText);
		add(ughImage);
		// place this on the last after all images created!
	}

	// JOELwindows7: BOLO comprehensive week 7 tankIntro!!!
	function tankIntro()
	{
		// TODO: JOELwindows7: use time stamp point system rather than create time. the stamp point is based
		// on the current cutscene audio in which animation element triggers at certain position of the audio
		// just the rhythm game part of this!
		// e.g. when the position reaches this second, then launch this animation etc etc.
		// but no wait. uh.. there is position bar, audio syncs to it, & the animation too.
		// if there's lag, the audio repositions to it & making sure no desync.
		inCinematic = true; // JOELwindows7: screw this. you should've set only when needed.
		inCutscene = true;
		dad.visible = false;

		precacheList.set('DISTORTO', 'music');
		var tankManEnd:Void->Void = function()
		{
			createTween(tankKludgeText, {alpha: 0}, 1, {
				ease: FlxEase.quadInOut,
				onComplete: function(twn:FlxTween)
				{
					tankKludgeText.text = '';
					tankKludgeText.kill();
				}
			});
			if (distortoMusic != null)
			{
				distortoMusic.fadeOut(1, 0, function(twn:FlxTween)
				{
					distortoMusic.stop();
					distortoMusic.kill();
					FlxG.sound.list.remove(distortoMusic);
				});
			}
			tankIntroEnd = true;
			var timeForStuff:Float = Conductor.crochet / 1000 * 5;
			createTween(FlxG.camera, {zoom: Stage.camZoom}, timeForStuff, {ease: FlxEase.quadInOut});
			// startCountdown();
			introSceneIsDone(); // JOELwindows7: let's try my heurestic, idk instead.
			camStrums.visible = true;
			camHUD.visible = true;
			dad.visible = true;

			var cutSceneStuff:Array<FlxSprite> = [Stage.swagBacks['tankman']];
			if (SONG.songId == 'stress')
			{
				cutSceneStuff.push(Stage.swagBacks['bfCutscene']);
				cutSceneStuff.push(Stage.swagBacks['gfCutscene']);
			}
			for (char in cutSceneStuff)
			{
				char.kill();
				remove(char);
				char.destroy();
			}
			Paths.clearUnusedMemory();
		}

		switch (SONG.songId)
		{
			case 'ugh':
				// TODO: JOELwindows7: Bahasa Indonesia sub
				/*
					Wah wah wah, lihat ada siapa nih disini?
					BIP!
					Harusnya kuBUNUH lo.
					Tapi tahu ah bosen mau ngapain nih,
					Ayo lihat seberapa jagonya lu.
				 */

				// removeStaticArrows();
				setVisibleStaticArrows(false, true);
				camHUD.visible = false;
				precacheList.set('wellWellWell', 'sound');
				precacheList.set('killYou', 'sound');
				precacheList.set('bfBeep', 'sound');
				var WellWellWell:FlxSound = new FlxSound().loadEmbedded(Paths.sound('wellWellWell', 'week7'));

				FlxG.sound.list.add(WellWellWell);

				// JOELwindows: NEVER USE MUSIC!!! MAKE IT AS SOUND EFFECT!!!
				// FlxG.sound.playMusic(Paths.music('DISTORTO', 'week7'));
				// FlxG.sound.music.fadeIn();
				distortoMusic = new FlxSound().loadEmbedded(Paths.music('DISTORTO', 'week7'), true);
				FlxG.sound.list.add(distortoMusic);
				distortoMusic.fadeIn();
				Stage.swagBacks['tankman'].animation.addByPrefix('wellWell', 'TANK TALK 1 P1', 24, false);
				Stage.swagBacks['tankman'].animation.addByPrefix('killYou', 'TANK TALK 1 P2', 24, false);
				Stage.swagBacks['tankman'].animation.play('wellWell', true);
				FlxG.camera.zoom *= 1.2;
				camFollow.x = 436.5;
				camFollow.y = 534.5;

				// Well well well, what do we got here?
				createTimer(0.1, function(tmr:FlxTimer)
				{
					WellWellWell.play(true);

					tankKludgeText.text = "[Tankman Captain] Well well well, what do we got here?";
					tankKludgeText.screenCenter(X);
				});

				// Move camera to BF
				createTimer(3, function(tmr:FlxTimer)
				{
					camFollow.x += 400;
					camFollow.y += 60;
					// Beep!
					createTimer(1.5, function(tmr:FlxTimer)
					{
						boyfriend.playAnim('singUP', true);
						FlxG.sound.play(Paths.sound('bfBeep'));

						tankKludgeText.text = '[Boyfriend] BEEP!';
						tankKludgeText.screenCenter(X);
					});

					// Move camera to Tankman
					createTimer(3, function(tmr:FlxTimer)
					{
						camFollow.x = 436.5;
						camFollow.y = 534.5;
						boyfriend.dance();
						Stage.swagBacks['tankman'].animation.play('killYou', true);
						FlxG.sound.play(Paths.sound('killYou'));

						tankKludgeText.text = '[Tankman Captain] We should just KILL YOU but...';
						tankKludgeText.screenCenter(X);
						createTimer(2, function(tmr:FlxTimer)
						{
							tankKludgeText.text = 'what the hell, it\'s been a boring day...';
							tankKludgeText.screenCenter(X);
							createTimer(2, function(tmr:FlxTimer)
							{
								tankKludgeText.text = 'let\'s see what you\'ve got!';
								tankKludgeText.screenCenter(X);
							});
						});

						// We should just kill you but... what the hell, it's been a boring day... let's see what you've got!
						createTimer(6.1, function(tmr:FlxTimer)
						{
							tankManEnd();
						});
					});
				});

			case 'guns':
				// TODO: JOELwindows7: Bahasa Indonesia sub
				/*
					Heh, luamayan anggunnya
					bagi seorang cowok yang lagi nembak seorang
					cewek remaja JELEK MEMBOSANKAN
					yang makai daster emaknya,
					Haah! wkwkwkwkwkwkwk...
				 */

				precacheList.set('tankSong2', 'sound');
				// JOELwindows7: YOU!! do not use music!!!
				// FlxG.sound.playMusic(Paths.music('DISTORTO', 'week7'), 0, false);
				// FlxG.sound.music.fadeIn();
				distortoMusic = new FlxSound().loadEmbedded(Paths.music('DISTORTO', 'week7'), true);
				distortoMusic.volume = 0;
				FlxG.sound.list.add(distortoMusic);
				distortoMusic.fadeIn();

				var tightBars:FlxSound = new FlxSound().loadEmbedded(Paths.sound('tankSong2', 'week7'));
				FlxG.sound.list.add(tightBars);

				laneunderlayOpponent.alpha = FlxG.save.data.laneTransparency;
				laneunderlay.alpha = FlxG.save.data.laneTransparency;

				createTimer(0.01, function(tmr:FlxTimer)
				{
					tightBars.play(true);
					tankKludgeText.text = '[Tankman Captain] Heh, pretty tight bars'; // `nanggung amat`
					tankKludgeText.screenCenter(X);
					createTimer(2, function(tmr:FlxTimer)
					{
						tankKludgeText.text = 'for a little dude simping over an..';
						tankKludgeText.screenCenter(X);
					});
				});

				createTimer(0.5, function(tmr:FlxTimer)
				{
					createTween(camStrums, {alpha: 0}, 1.5, {ease: FlxEase.quadInOut});
					createTween(camHUD, {alpha: 0}, 1.5, {
						ease: FlxEase.quadInOut,
						onComplete: function(twn:FlxTween)
						{
							camHUD.visible = false;
							camHUD.alpha = 1;
							camStrums.visible = false;
							camStrums.alpha = 1;
							// removeStaticArrows();
							setVisibleStaticArrows(false, true);
							laneunderlayOpponent.alpha = 0;
							laneunderlay.alpha = 0;
						}
					});
				});

				Stage.swagBacks['tankman'].animation.addByPrefix('tightBars', 'TANK TALK 2', 24, false);
				Stage.swagBacks['tankman'].animation.play('tightBars', true);
				boyfriend.animation.curAnim.finish();

				createTimer(1, function(tmr:FlxTimer)
				{
					camFollow.x = 436.5;
					camFollow.y = 534.5;
				});

				createTimer(4, function(tmr:FlxTimer)
				{
					camFollow.y -= 150;
					camFollow.x += 100;
				});
				createTimer(1, function(tmr:FlxTimer)
				{
					createTween(FlxG.camera, {zoom: Stage.camZoom * 1.2}, 3, {ease: FlxEase.quadInOut});

					createTween(FlxG.camera, {zoom: Stage.camZoom * 1.2 * 1.2}, 0.5, {ease: FlxEase.quadInOut, startDelay: 3});
					createTween(FlxG.camera, {zoom: Stage.camZoom * 1.2}, 1, {ease: FlxEase.quadInOut, startDelay: 3.5});
				});

				createTimer(4, function(tmr:FlxTimer)
				{
					gf.playAnim('sad', true);
					gf.animation.finishCallback = function(name:String)
					{
						gf.playAnim('sad', true);
					};
					// JOELwindows7: btw, bf was also supposed to play anim angery upset for
					// tankman mocked his gf. idk. but the original cutscene seems to have
					// forgotten that. a mistakes, hopefully!
					tankKludgeText.text = '[Tankman Captain] UGLY BORING little teenager\n[Girfriend] (Cry hard)!!...';
					tankKludgeText.screenCenter(X);
					createTimer(2, function(tmr:FlxTimer)
					{
						tankKludgeText.text = 'that wears her mom\'s clothes,';
						tankKludgeText.screenCenter(X);
						createTimer(2, function(tmr:FlxTimer)
						{
							tankKludgeText.text = 'Haah! XD......';
							tankKludgeText.screenCenter(X);
						});
					});
				});

				createTimer(11.6, function(tmr:FlxTimer)
				{
					camFollow.x = 440;
					camFollow.y = 534.5;
					tankManEnd();

					gf.dance();
					gf.animation.finishCallback = null;
				});

			case 'stress':
				// TODO: JOELwindows7: Bahasa Indonesia sub
				/*
					Astaga... Jirr... Anjir...
					Baiklah lu dasar tai.
					Tapi ini PERANG! & dalam perang,
					ORANG GUGUR!!
					Pasukan, bersiaplah untuk menembak!
					Sorry gk ada prom buat lu tahun ini, HAHAA!!

					Nah lihat siapa ini
					si pacarmu yg tau banci apalah & pemarah itu
					cuman ada satu cara menghadapi ini.
					ayo LAWAN, lu TEMPEK sekalian!
					AWOKWOWKWKWKWKWKW, para tempek sekalian.
				 */

				Stage.swagBacks['tankman'].setPosition(-77, 307);
				laneunderlayOpponent.alpha = FlxG.save.data.laneTransparency;
				laneunderlay.alpha = FlxG.save.data.laneTransparency;
				precacheList.set('stressCutscene${FlxG.save.data.naughtiness ? '' : 'CensorEdit'}', 'sound');

				precacheList.set('cutscenes/stress2', 'frame');

				// JOELwindows7: still lag again on my Linux, let's keep trigger loading for all anyway.
				// #if html5
				Paths.getSparrowAtlas('cutscenes/stress2', 'week7');
				// #end

				createTimer(0.5, function(tmr:FlxTimer)
				{
					createTween(camStrums, {alpha: 0}, 1.5, {ease: FlxEase.quadInOut});
					createTween(camHUD, {alpha: 0}, 1.5, {
						ease: FlxEase.quadInOut,
						onComplete: function(twn:FlxTween)
						{
							camHUD.visible = false;
							camHUD.alpha = 1;
							camStrums.visible = false;
							camStrums.alpha = 1;
							// removeStaticArrows();
							setVisibleStaticArrows(false, true);
							laneunderlayOpponent.alpha = 0;
							laneunderlay.alpha = 0;
						}
					});
				});

				gf.visible = false;
				boyfriend.visible = false;
				createTimer(1, function(tmr:FlxTimer)
				{
					camFollow.x = 436.5;
					camFollow.y = 534.5;
					createTween(FlxG.camera, {zoom: 0.9 * 1.2}, 1, {ease: FlxEase.quadInOut});
				});

				Stage.swagBacks['bfCutscene'].animation.finishCallback = function(name:String)
				{
					Stage.swagBacks['bfCutscene'].animation.play('idle');
				}

				Stage.swagBacks['dummyGf'].animation.finishCallback = function(name:String)
				{
					Stage.swagBacks['dummyGf'].animation.play('idle');
				}

				var cutsceneSnd:FlxSound = new FlxSound().loadEmbedded(Paths.sound('stressCutscene${FlxG.save.data.naughtiness ? '' : 'CensorEdit'}'));
				FlxG.sound.list.add(cutsceneSnd);

				Stage.swagBacks['tankman'].animation.addByPrefix('godEffingDamnIt', 'TANK TALK 3', 24, false);
				Stage.swagBacks['tankman'].animation.play('godEffingDamnIt', true);

				createTimer(0.01, function(tmr:FlxTimer) // Fixes sync????
				{
					cutsceneSnd.play(true);
					tankKludgeText.text = '[Tankman Captain] God.. eFfing ${FlxG.save.data.naughtiness ? '(FUCKING)' : ''}.. Damnit.., tsk!';
					tankKludgeText.screenCenter(X);
					createTimer(3, function(tmr:FlxTimer)
					{
						tankKludgeText.text = 'Well played, you little ${FlxG.save.data.naughtiness ? 'shit' : '8888'}..';
						tankKludgeText.screenCenter(X);
						createTimer(2.5, function(tmr:FlxTimer)
						{
							tankKludgeText.text = 'but this is WAR, & in a war,';
							tankKludgeText.screenCenter(X);
							createTimer(2, function(tmr:FlxTimer)
							{
								tankKludgeText.text = 'PEOPLE DIE!!';
								createTimer(1.7, function(tmr:FlxTimer)
								{
									tankKludgeText.text = 'Command,\nget ready to fire! (right hand signal soldiers on speaker)';
									tankKludgeText.screenCenter(X);
									createTimer(2.1, function(tmr:FlxTimer)
									{
										tankKludgeText.text = 'Sorry no prom for you this year, HAHAHAA!\n(two soldiers on speaker about to shoot girlfriend)';
										tankKludgeText.screenCenter(X);
									});
								});
							});
						});
					});
				});

				createTimer(14.2, function(tmr:FlxTimer)
				{
					Stage.swagBacks['bfCutscene'].animation.finishCallback = null;
					Stage.swagBacks['dummyGf'].animation.finishCallback = null;
				});

				createTimer(15.2, function(tmr:FlxTimer)
				{
					tankKludgeText.text = '';
					tankKludgeText.screenCenter(X);
					createTween(camFollow, {x: 650, y: 300}, 1, {ease: FlxEase.sineOut});
					createTween(FlxG.camera, {zoom: 0.9 * 1.2 * 1.2}, 2.25, {ease: FlxEase.quadInOut});
					createTimer(2.3, function(tmr:FlxTimer)
					{
						camFollow.x = 630;
						camFollow.y = 425;
						FlxG.camera.zoom = 0.9;
					});

					Stage.swagBacks['dummyGf'].visible = false;
					Stage.swagBacks['gfCutscene'].visible = true;
					Stage.swagBacks['gfCutscene'].animation.play('dieBitch', true);
					createTimer(2.3, function(tmr:FlxTimer)
					{
						Controls.vibrate(0, 1300, 0, 65535, 65535); // JOELwindows7: vibrate da controller
					});
					Stage.swagBacks['gfCutscene'].animation.finishCallback = function(name:String)
					{
						if (name == 'dieBitch') // Next part
						{
							Stage.swagBacks['gfCutscene'].animation.play('getRektLmao', true);
							Stage.swagBacks['gfCutscene'].offset.set(224, 445);
							// tankKludgeText.text = '[Pico] (shoot right soldier & kick Girlfriend off to bring her to Boyfriend)!!!';
							tankKludgeText.text = '(Girlfriend\'s eyes charging glowing up)';
							tankKludgeText.screenCenter(X);
						}
						else
						{
							Stage.swagBacks['gfCutscene'].visible = false;
							Stage.swagBacks['picoCutscene'].visible = true;
							Stage.swagBacks['picoCutscene'].animation.play('anim', true);
							Controls.vibrate(0, 90); // JOELwindows7: bang! pico shoots tankmen!
							createTimer(.01, function(tmr:FlxTimer)
							{
								tankKludgeText.text = '[Pico] (shot right soldier while kicking Girlfriend bringing her onto Boyfriend then point gun to left soldier)';
								tankKludgeText.screenCenter(X);
							});
							createTimer(.97, function(tmr:FlxTimer)
							{
								tankKludgeText.text = '[Left soldier] WHAAAAA!!!!';
								tankKludgeText.screenCenter(X);
							});
							// JOELwindows7: & then the other
							createTimer(1.3, function(tmr:FlxTimer)
							{
								Controls.vibrate(0, 95);
								tankKludgeText.text = '[Pico] (BANG)!!\n[Left soldier] (eik serkat!)';
								tankKludgeText.screenCenter(X);
							});

							boyfriend.visible = true;
							Stage.swagBacks['bfCutscene'].visible = false;
							boyfriend.playAnim('bfCatch', true);
							boyfriend.animation.finishCallback = function(name:String)
							{
								if (name != 'idle')
								{
									boyfriend.playAnim('idle', true);
									boyfriend.animation.curAnim.finish(); // Instantly goes to last frame
								}
							};

							Stage.swagBacks['picoCutscene'].animation.finishCallback = function(name:String)
							{
								Stage.swagBacks['picoCutscene'].visible = false;
								gf.visible = true;
								Stage.swagBacks['picoCutscene'].animation.finishCallback = null;
							};
							Stage.swagBacks['gfCutscene'].animation.finishCallback = null;
						}
					};
				});

				createTimer(19.5, function(tmr:FlxTimer)
				{
					trace('ah look who it is');
					Stage.swagBacks['tankman'].frames = Paths.getSparrowAtlas('cutscenes/stress2', 'week7');
					Stage.swagBacks['tankman'].animation.addByPrefix('lookWhoItIs', 'TANK TALK 3', 24, false);
					Stage.swagBacks['tankman'].animation.play('lookWhoItIs', true);
					Stage.swagBacks['tankman'].x += 90;
					Stage.swagBacks['tankman'].y += 6;
					tankKludgeText.text = '[Tankman Captain] Aah, look who it is,';
					tankKludgeText.screenCenter(X);
					trace('affa');
					createTimer(2.4, function(tmr:FlxTimer)
					{
						tankKludgeText.text = 'your sexually-ambiguous-angry-little-friend';
						tankKludgeText.screenCenter(X);
						createTimer(2.8, function(tmr:FlxTimer)
						{
							tankKludgeText.text = 'Don\'t you have a school to shoot up?';
							tankKludgeText.screenCenter(X);
							createTimer(2.9, function(tmr:FlxTimer)
							{
								tankKludgeText.text = 'there\'s one way to settle this.';
								tankKludgeText.screenCenter(X);
								createTimer(2.4, function(tmr:FlxTimer)
								{
									tankKludgeText.text = 'let\'s ROCK, you little ${FlxG.save.data.naughtiness ? 'CUNT' : '8888'}!';
									tankKludgeText.screenCenter(X);
								});
							});
						});
					});
					// JOELwindows7: This stress cutscene right here spikes the memory alot!

					createTimer(0.5, function(tmr:FlxTimer)
					{
						camFollow.x = 436.5;
						camFollow.y = 534.5;
					});
				});

				createTimer(31.2, function(tmr:FlxTimer)
				{
					boyfriend.playAnim('singUPmiss', true);
					boyfriend.animation.finishCallback = function(name:String)
					{
						if (name == 'singUPmiss')
						{
							boyfriend.playAnim('idle', true);
							boyfriend.animation.curAnim.finish(); // Instantly goes to last frame
						}
					};
					FlxG.camera.follow(camFollow, LOCKON, 1);

					tankKludgeText.text = '(Boyfriend & Girlfriend went bruh moment)\n[Tankman] XD!!!!!';
					tankKludgeText.screenCenter(X);

					camFollow.setPosition(1100, 625);
					FlxG.camera.zoom = 1.3;

					createTimer(1, function(tmr:FlxTimer)
					{
						FlxG.camera.zoom = 0.9;
						camFollow.setPosition(440, 534.5);

						tankKludgeText.text = '..you little ${FlxG.save.data.naughtiness ? 'cunts' : '88888'}.';
						tankKludgeText.screenCenter(X);
					});
				});
				createTimer(35.5, function(tmr:FlxTimer)
				{
					tankManEnd();
					boyfriend.animation.finishCallback = null;
				});
		}
	}

	// LUA MODCHART TO SOURCE FOR HTML5 TUTORIAL MODCHART :)
	// #if !cpp
	function elasticCamZoom()
	{
		var camGroup:Array<FlxCamera> = [camHUD, camNotes, camSustains, camStrums];
		for (camShit in camGroup)
		{
			camShit.zoom += 0.06;
			createTween(camShit, {zoom: camShit.zoom - 0.06}, 0.5 / songMultiplier, {
				ease: FlxEase.elasticOut
			});
		}

		FlxG.camera.zoom += 0.06;

		createTweenNum(FlxG.camera.zoom, FlxG.camera.zoom - 0.06, 0.5 / songMultiplier, {ease: FlxEase.elasticOut}, updateCamZoom.bind(FlxG.camera));
	}

	function receptorTween()
	{
		for (i in 0...strumLineNotes.length)
		{
			createTween(strumLineNotes.members[i], {modAngle: strumLineNotes.members[i].modAngle + 360}, 0.5 / songMultiplier,
				{ease: FlxEase.smootherStepInOut});
		}
	}

	function updateCamZoom(camGame:FlxCamera, upZoom:Float)
	{
		camGame.zoom = upZoom;
	}

	function speedBounce()
	{
		// var scrollSpeedShit:Float = PlayStateChangeables.scrollSpeed;
		var scrollSpeedShit:Float = scrollSpeed;
		// PlayStateChangeables.scrollSpeed /= PlayStateChangeables.scrollSpeed;
		scrollSpeed /= scrollSpeed;
		changeScrollSpeed(scrollSpeedShit, 0.35 / songMultiplier, FlxEase.sineOut);
	}

	var isTweeningThisShit:Bool = false;

	function tweenCamZoom(isDad:Bool)
	{
		if (isDad)
			createTweenNum(FlxG.camera.zoom, FlxG.camera.zoom + 0.3, (Conductor.stepCrochet * 4 / 1000) / songMultiplier, {
				ease: FlxEase.smootherStepInOut,
			}, updateCamZoom.bind(FlxG.camera));
		else
			createTweenNum(FlxG.camera.zoom, FlxG.camera.zoom - 0.3, (Conductor.stepCrochet * 4 / 1000) / songMultiplier, {
				ease: FlxEase.smootherStepInOut,
			}, updateCamZoom.bind(FlxG.camera));
	}

	// #end
	// https://github.com/ShadowMario/FNF-PsychEngine/pull/9015
	// Seems like a good pull request. Credits: Raltyro.
	// JOELwindows7: okay, more modchart specialties!
	// change icon
	public function changePlayerIcon(which:Int = 0, intoChar:String)
	{
		switch (which)
		{
			case -1:
				// all of them!
				changePlayerIcon(0, intoChar);
				changePlayerIcon(1, intoChar);
				changePlayerIcon(3, intoChar);
			case 0:
				// bf
				if (iconP1 != null)
					iconP1.changeIcon(intoChar);
			case 1:
				// dad
				if (iconP2 != null)
					iconP2.changeIcon(intoChar);
			case 3:
			// gf
			// no such yet.
			default:
				// idk
		}
	}

	// reset icon
	public function resetPlayerIcon(which:Int = -1)
	{
		switch (which)
		{
			case -1:
				// all of them!
				resetPlayerIcon(0);
				resetPlayerIcon(1);
				resetPlayerIcon(3);
			case 0:
				// bf
				if (iconP1 != null)
					iconP1.resetIcon();
			case 1:
				// dad
				if (iconP2 != null)
					iconP2.resetIcon();
			case 3:
			// gf
			// no such yet.
			default:
				// idk
		}
	}

	// end specialties

	private function cachePopUpScore()
	{
		var pixelShitPart1:String = '';
		var pixelShitPart2:String = '';
		var pixelShitPart3:String = null;
		if (SONG.noteStyle == 'pixel')
		{
			pixelShitPart1 = 'weeb/pixelUI/';
			pixelShitPart2 = '-pixel';
			pixelShitPart3 = 'week6';
		}

		Paths.image(pixelShitPart1 + "sick" + pixelShitPart2, pixelShitPart3);
		Paths.image(pixelShitPart1 + "good" + pixelShitPart2, pixelShitPart3);
		Paths.image(pixelShitPart1 + "bad" + pixelShitPart2, pixelShitPart3);
		Paths.image(pixelShitPart1 + "shit" + pixelShitPart2, pixelShitPart3);
		Paths.image(pixelShitPart1 + "combo" + pixelShitPart2, pixelShitPart3);

		for (i in 0...10)
		{
			Paths.image(pixelShitPart1 + 'num' + i + pixelShitPart2, pixelShitPart3);
		}
	}

	function cacheCountdown()
	{
		var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
		introAssets.set('default', ['ready', 'set', 'go']);
		introAssets.set('pixel', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

		var week6Bullshit = null;
		var introAlts:Array<String> = introAssets.get('default');
		if (SONG.noteStyle == 'pixel')
		{
			introAlts = introAssets.get('pixel');
			week6Bullshit = 'week6';
		}

		for (asset in introAlts)
			Paths.image(asset, week6Bullshit);

		var things:Array<String> = ['intro3', 'intro2', 'intro1', 'introGo'];
		for (precaching in things)
			Paths.sound(precaching + altSuffix);
	}

	function startAndEnd()
	{
		if (endingSong)
			endSong();
		else
			startCountdown();
	}

	// end BOLO's stuffs zoids
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
					// JOELwindows7: Okay, let's try to equip BOLO's way of Hitsound choice & volume.
					playSoundEffect(((handoverNote.hitsoundPath != null && handoverNote.hitsoundPath != "" && handoverNote.hitsoundPath != '0'
						&& handoverNote.hitsoundUseIt) ? // JOELwindows7: yeah.
						handoverNote.hitsoundPath : 'hitsounds/${HitSounds.getSoundByID(FlxG.save.data.hitSoundSelect).toLowerCase()}'),
						FlxG.save.data.hitVolume, 'shared');
					if (handoverNote.noteType == 2)
					{
						playSoundEffect("mine-duar", FlxG.save.data.hitVolume, 'shared'); // duar! you stepped on mine!
					}
				}
				catch (e)
				{
					// null object reference
				}
			}
		}
		else
		{
			// still sound the mine if note type is 2 (mine) idk
			if (handoverNote != null)
			{
				try
				{
					if (handoverNote.noteType == 2)
					{
						playSoundEffect("mine-duar", FlxG.save.data.hitVolume, 'shared'); // duar! you stepped on mine!
					}
				}
				catch (e)
				{
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
					// JOELwindows7: mrebem
					var ready:FlxUISprite = cast new FlxUISprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (Stage.curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * CoolUtil.daPixelZoom));

					ready.screenCenter();
					add(ready);
					if (invisible)
						ready.visible = false;
					createTween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					if (!silent)
						FlxG.sound.play(Paths.sound('intro2' + altSuffix + midiSuffix), 0.6);
				case 2:
					// JOELwindows7: hmm this seems only add stuffs doesn't so much to do. but eh!
					var set:FlxUISprite = cast new FlxUISprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (Stage.curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * CoolUtil.daPixelZoom));

					set.screenCenter();
					add(set);
					if (invisible)
						set.visible = false;
					createTween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					if (!silent)
						FlxG.sound.play(Paths.sound((reversed ? 'intro3' : 'intro1') + altSuffix + midiSuffix), 0.6);
				case 3:
					// JOELwindows7: crogom
					var go:FlxUISprite = cast new FlxUISprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (Stage.curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * CoolUtil.daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					if (invisible)
						go.visible = false;
					createTween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
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
			if (camGame != null)
				starfield3D.cameras = [camGame];
		}
		else
		{
			installStarfield2D(Std.int(x), Std.int(y), Std.int(width), Std.int(height), starAmount);
			if (camGame != null)
				starfield2D.cameras = [camGame];
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
		// JOELwindows7: BOLO's also destroy haxe interp there.
		if (ModchartState.haxeInterp != null)
			ModchartState.haxeInterp = null;
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

		// miliseconds too pls!!!
		setModchartVar('songLengthMs', songLengthMs);
	}

	// JOELwindows7: Psyched Botplay text fade in out
	function fadeOutBotplayText()
	{
		if (botPlayState != null)
		{
			createTween(botPlayState, {alpha: 0}, 1, {
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
			createTween(botPlayState, {alpha: 1}, 1, {
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
				createToast(null, "No Tankman", "Week 7 still not released!!!\nEdit: Asset released");
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
				// createToast(null, "Forgiven", "[REDACTED] is now eligible to access Heaven again! Welcome home."); // this was Sarvente
				createToast(null, "Forgiven", "Sarvente (+ others) are now eligible to access Heaven again! Welcome home."); // SPILL THE BEAN!!!
			default:
				trace("an song complete");
		}
	}

	// JOELwindows7: check song start
	function checkSongStartAfterTankman()
	{
		// JOELwindows7: also add delay before start (nvm)
		// for intro cutscene after video and before dialogue chat you know!
		// JOELwindows7: Heuristic for using JSON chart instead
		if (SONG.hasDialogueChat)
		{
			schoolIntro(doof);
		}
		else
		{
			// inCutscene = false;
			// createTimer(1, function(timer)
			// {
			startCountdown();
			// });
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
		if (!introSceneCalled)
		{
			introSceneCalled = true;
			inCutscene = true;
			switch (curSong)
			{
				// JOELwindows7: Well, let's just copy everything from original to here. look, winter horrorland is cutscene!
				case "winter-horrorland":
					// JOELwindows7: You gotta be kidding me. why did not you override all functions to it returns as same type as the extended?!?!?
					var blackScreen:FlxUISprite = cast new FlxUISprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;
					camStrums.visible = false;
					// JOELwindows7: hide the lemon guy character icon!
					iconP2.changeIcon('placeholder');

					createTimer(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						// JOELwindows7: vibrate the device
						Controls.vibrate(0, 2700);
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						createTimer(1, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							createTween(FlxG.camera, {zoom: Stage.camZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									// startCountdown();
									introSceneIsDone(); // JOELwindows7: try my heurestic instead?
									// JOELwindows7: move the tringy here. BOLO
									camHUD.visible = true;
									camStrums.visible = true;
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
				// JOELwindows7: BOLO do this!
				case 'ugh', 'guns', 'stress':
					if (!PlayStateChangeables.optimize && FlxG.save.data.background)
						tankIntro();
					else
					{
						// removeStaticArrows();
						setVisibleStaticArrows(false, true);
						// #if FEATURE_MP4VIDEOS
						// startVideo('cutscenes/${SONG.songId}_cutscene');
						// #else
						// startCountdown();
						// #end

						// JOELwindows7: Um, but I do it like this..
						tankmanIntro(SONG.tankmanVideoPath); // yeah.
					}
				default:
					// No cutscene intro
					decideIntroSceneDone(SONG.introCutSceneDoneManually);
			}
		}
		else
		{
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
		// createTimer(SONG.delayBeforeStart, function(timer:FlxTimer)
		// {
		checkSongStartAfterTankman(); // I know, this is spaghetti code. because I believe there's more somebody uses the method.
		// });
	}

	// JOELwindows7: Outro Done fillout vars
	// JOELwindows7: Psyched outro after dialogue chat & before epilogue video
	function outroScene(handoverName:String, isNextSong:Bool = false, handoverDelayFirst:Float = 0, handoverHasEpilogueVid:Bool = false,
			handoverEpilogueVidPath:String = "", handoverHasTankmanEpilogueVid:Bool = false, handoverTankmanEpilogueVidPath:String = "")
	{
		if (!outroSceneCalled)
		{
			outroSceneCalled = true;

			// JOELwindows7: move modchart calls here
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

			// then to usual outro cutscene.
			switch (handoverName.toLowerCase())
			{
				case 'mayday': // blacken the screen like going to Winter Horrorland but slowed and sadder
					// to contemplate in memory of those 3 taken down mods. and more.
					// var blackShit:FlxUISprite = new FlxUISprite(-FlxG.width * FlxG.camera.zoom,
					// 	-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					// blackShit.scrollFactor.set();
					// blackShit.alpha = 0;
					// add(blackShit);

					// JOELwindows7: better! use camera fade
					FlxG.camera.fade(FlxColor.BLACK, 5);

					// JOELwindows7: now don't forget to hide the static arrow
					setVisibleStaticArrows(false);

					// camHUD.alpha = 0;
					createTween(camHUD, {alpha: 0}, 5, {
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
					Debug.logInfo('Contemplate for 10 Second');
					var contemplateCount:Float = 10;
					createTimer(1, function(tmr:FlxTimer)
					{
						Debug.logInfo('Contemplating ${contemplateCount}');
						contemplateCount--;
					}, 10);
					createTimer(10, function(tmr:FlxTimer)
					{
						// outroSceneIsDone(isNextSong, handoverName, handoverDelayFirst, handoverHasEpilogueVid, handoverEpilogueVidPath,handoverHasTankmanEpilogueVid, handoverTankmanEpilogueVidPath);
						decideOutroSceneDone(isNextSong, handoverName, handoverDelayFirst, handoverHasEpilogueVid, handoverEpilogueVidPath,
							handoverHasTankmanEpilogueVid, handoverTankmanEpilogueVidPath);
					});
				case 'eggnog':
					// JOELwindows7: right, we've migrated those here yey. add more things if necessary.
					// Oh yeah, also I cast, hopefully safe because this just adds insignificant things. idk..
					var blackShit:FlxUISprite = cast new FlxUISprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					setVisibleStaticArrows(false, true, true); // forcened.

					FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					Controls.vibrate(0, 100);

					createTimer(3, function(tmr:FlxTimer)
					{
						// outroSceneIsDone(isNextSong, handoverName, handoverDelayFirst, handoverHasEpilogueVid, handoverEpilogueVidPath,handoverHasTankmanEpilogueVid, handoverTankmanEpilogueVidPath);
						decideOutroSceneDone(isNextSong, handoverName, handoverDelayFirst, handoverHasEpilogueVid, handoverEpilogueVidPath,
							handoverHasTankmanEpilogueVid, handoverTankmanEpilogueVidPath);
					});
				case 'sky':
					// da bbpanzu sky `theManifestCutscene`
					createTimer(1, function(e:FlxTimer)
					{
						dad.playAnim('manifest');
						FlxG.sound.play(Paths.sound("skyManifest", 'shared'));
						createTween(FlxG.camera, {zoom: 1.2}, 1, {ease: FlxEase.quadInOut});

						createTimer(1, function(e:FlxTimer)
						{
							if (Stage.shiftbg != null)
							{
								Stage.shiftbg.scrollFactor.set(1, 1);
								Stage.shiftbg.animation.play('manifest');
							}
							createTween(FlxG.camera, {zoom: 1}, 0.3, {ease: FlxEase.quadInOut});
							FlxG.camera.shake(0.05, 5);
							Controls.vibrate(0, 5000);
						});
						createTimer(2, function(e:FlxTimer)
						{
							FlxG.camera.fade(FlxColor.WHITE, 2, false);
							createTween(FlxG.camera, {zoom: 1.1}, 2, {ease: FlxEase.quadInOut});
						});
						createTimer(4.5, function(e:FlxTimer)
						{
							FlxG.camera.fade(FlxColor.BLACK, 0.1, false);
						});
						createTimer(5, function(e:FlxTimer)
						{
							// LoadingState.loadAndSwitchState(new PlayState());
							// outroSceneIsDone(isNextSong, handoverName, handoverDelayFirst, handoverHasEpilogueVid, handoverEpilogueVidPath, handoverHasTankmanEpilogueVid, handoverTankmanEpilogueVidPath);
							decideOutroSceneDone(isNextSong, handoverName, handoverDelayFirst, handoverHasEpilogueVid, handoverEpilogueVidPath,
								handoverHasTankmanEpilogueVid, handoverTankmanEpilogueVidPath);
						});
					});
				case 'manifest':
					// JOELwindows7: bbpanzu's vs. Sky. ending here is based on how accurate you play.
					// also see ending state
					// https://github.com/Perkedel/bb-fnf-mods/blob/GitHackeh/source_sky/EndingState.hx
					FlxG.camera.fade(FlxColor.BLACK, .8);

					// camHUD.alpha = 0;
					createTween(camHUD, {alpha: 0}, .8, {
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween)
						{
						}
					});
					var whichEndingImage:FlxUISprite = new FlxUISprite(0, 0);
					var endingSound:FlxSound;
					if (accuracy >= 70)
					{
						whichEndingImage.loadGraphic(Paths.image("sky/ending0002"));
						// FlxG.sound.playMusic(Paths.music("skyGoodEnding",'shared'),1,false);
						endingSound = new FlxSound().loadEmbedded(Paths.music("skyGoodEnding", 'shared'), false);
					}
					else
					{
						if (FlxG.random.bool(70))
						{
							whichEndingImage.loadGraphic(Paths.image("sky/ending0001"));
							// FlxG.sound.playMusic(Paths.music("skyBadEnding",'shared'),1,false);
							endingSound = new FlxSound().loadEmbedded(Paths.music("skyBadEnding", 'shared'), false);
						}
						else
						{
							whichEndingImage.loadGraphic(Paths.image("sky/ending0003"));
							// FlxG.sound.playMusic(Paths.music("skyPeanutEnding",'shared'), 1, false);
							endingSound = new FlxSound().loadEmbedded(Paths.music("skyPeanutEnding", 'shared'), false);
						}
					}
					add(whichEndingImage);
					FlxG.sound.list.add(endingSound);
					endingSound.play();
					createTimer(8, function(e:FlxTimer)
					{
						// FlxG.sound.music.stop();
						endingSound.stop();
						// outroSceneIsDone(isNextSong, handoverName, handoverDelayFirst, handoverHasEpilogueVid, handoverEpilogueVidPath,handoverHasTankmanEpilogueVid, handoverTankmanEpilogueVidPath);
						decideOutroSceneDone(isNextSong, handoverName, handoverDelayFirst, handoverHasEpilogueVid, handoverEpilogueVidPath,
							handoverHasTankmanEpilogueVid, handoverTankmanEpilogueVidPath);
					});
				default:
					decideOutroSceneDone(isNextSong, handoverName, handoverDelayFirst, handoverHasEpilogueVid, handoverEpilogueVidPath,
						handoverHasTankmanEpilogueVid, handoverTankmanEpilogueVidPath, SONG.outroCutSceneDoneManually);
			}
		}
		else
		{
			decideOutroSceneDone(isNextSong, handoverName, handoverDelayFirst, handoverHasEpilogueVid, handoverEpilogueVidPath, handoverHasTankmanEpilogueVid,
				handoverTankmanEpilogueVidPath, SONG.outroCutSceneDoneManually);
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
							// JOELwindows7: also invisiblize / hide these
							FlxTween.tween(tempoBar, {alpha: 0}, 1);
							FlxTween.tween(metronomeBar, {alpha: 0}, 1);
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
						// FlxG.sound.playMusic(Paths.music('freakyMenu'));
						// Conductor.changeBPM(102);
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
		vlcHandlerHasFinished = true;
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

	// JOELwindows7: my hitline like Ragnarock game VR
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
		var skin:String = '${FlxG.save.data.noteskin}-splash${(noteType == 2 ? "-duar" : "")}'; // DONE: JOELwindows7: use `-duar` for mines (note type 2) ; Arrow-splash
		if (PlayState.SONG != null) // JOELwindows7: make sure not null
			if (PlayState.SONG.noteStyle != null && PlayState.SONG.noteStyle.length > 0 && PlayState.SONG.useCustomNoteStyle)
				skin = PlayState.SONG.noteStyle
					+ (PlayState.SONG.noteStyle.contains("pixel") ? "-pixel" : "")
					+ "-splash"
					+ (noteType == 2 ? "-duar" : "");

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

	var debugHitlineLastX:Float;
	var debugHitlineLastY:Float;

	// JOELwindows7: spawn hitline particle like splash but it's line to determine how late, early, or perfect you hit it.
	public function spawnHitlineParticle(x:Float, y:Float, data:Int, ?note:Note = null, noteType:Int = 0, rating:Int = 0)
	{
		var hitline:FlxUISprite = grpNoteHitlineParticles.recycle(FlxUISprite);
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

	// JOELwindows7: BOLO note splash
	public function NoteSplashesSpawn(daNote:Note):Void
	{
		var sploosh:FlxUISprite = new FlxUISprite(playerStrums.members[daNote.noteData].x + 10.5, playerStrums.members[daNote.noteData].y - 20);
		sploosh.antialiasing = FlxG.save.data.antialiasing;
		if (FlxG.save.data.noteSplashes)
		{
			switch (SONG.noteStyle)
			{
				case 'pixel':
					var tex:flixel.graphics.frames.FlxAtlasFrames = Paths.getSparrowAtlas('weeb/pixelUI/noteSplashes-pixels', 'week6');
					sploosh.frames = tex;
					sploosh.animation.addByPrefix('splash 0 0', 'note splash 1 purple', 24, false);
					sploosh.animation.addByPrefix('splash 0 1', 'note splash 1  blue', 24, false);
					sploosh.animation.addByPrefix('splash 0 2', 'note splash 1 green', 24, false);
					sploosh.animation.addByPrefix('splash 0 3', 'note splash 1 red', 24, false);
					sploosh.animation.addByPrefix('splash 1 0', 'note splash 2 purple', 24, false);
					sploosh.animation.addByPrefix('splash 1 1', 'note splash 2 blue', 24, false);
					sploosh.animation.addByPrefix('splash 1 2', 'note splash 2 green', 24, false);
					sploosh.animation.addByPrefix('splash 1 3', 'note splash 2 red', 24, false);

					add(sploosh);
					sploosh.cameras = [camStrums];
					sploosh.animation.play('splash ' + FlxG.random.int(0, 1) + " " + daNote.noteData);
					sploosh.alpha = 0.6;
					sploosh.offset.x += 90;
					sploosh.offset.y += 80;
					sploosh.animation.finishCallback = function(name) sploosh.kill();

					sploosh.update(0);
				default:
					var tex:flixel.graphics.frames.FlxAtlasFrames = Paths.getSparrowAtlas('noteSplashes', 'shared');
					sploosh.frames = tex;

					sploosh.animation.addByPrefix('splash 0 0', 'note splash 1 purple', 24, false);
					sploosh.animation.addByPrefix('splash 0 1', 'note splash 1  blue', 24, false);
					sploosh.animation.addByPrefix('splash 0 2', 'note splash 1 green', 24, false);
					sploosh.animation.addByPrefix('splash 0 3', 'note splash 1 red', 24, false);
					sploosh.animation.addByPrefix('splash 1 0', 'note splash 2 purple', 24, false);
					sploosh.animation.addByPrefix('splash 1 1', 'note splash 2 blue', 24, false);
					sploosh.animation.addByPrefix('splash 1 2', 'note splash 2 green', 24, false);
					sploosh.animation.addByPrefix('splash 1 3', 'note splash 2 red', 24, false);

					add(sploosh);
					sploosh.cameras = [camStrums];
					sploosh.animation.play('splash ' + FlxG.random.int(0, 1) + " " + daNote.noteData);
					sploosh.alpha = 0.6;
					sploosh.offset.x += 90;
					sploosh.offset.y += 80; // lets stick to eight not nine
					sploosh.animation.finishCallback = function(name) sploosh.kill();

					sploosh.update(0);
			}
		}
	}

	// JOELwindows7: Psyched blackbar stuff
	function buildRealBlackBars()
	{
		realBlackbarsTop = new FlxUISprite(0, 0);
		realBlackbarsTop.makeGraphic(FlxG.width, realBlackbarHeight, 0xFF000000);
		realBlackbarsTop.alpha = 0;
		realBlackbarsTop.scrollFactor.set();
		realBlackbarsBottom = new FlxUISprite(0, FlxG.height - realBlackbarHeight);
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
		var daDot = new FlxUISprite();
		daDot.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
		daDot.drawCircle(FlxG.width - 10, 140, 100, FlxColor.PURPLE, lineStyle, drawStyle);
		daDot.scrollFactor.set(); // don't forget!
		// leave daDot in camGame / default because it makes sense as this would be part of film strip.
		daDot.cameras = [camHUD]; // NOPE!!! without putting on HUD, it stays there.
		// where is draw n-gon (draw polygon easy with just Int num of vertices)?
		// the polygon requires you put vertices one by one! what the peck?!?
		// don't forget antialias!
		daDot.antialiasing = FlxG.save.data.antialiasing;
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
	public function executeModchartState(name:String, args:Array<Dynamic>)
	{
		// maybe don't public. ask the user to @privateAccess instead?
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
	public function setModchartVar(name:String, value:Dynamic)
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

	// JOELwindows7: for tankman intro outro webm js
	function manageWebmer(handoverElapsed:Float = 0)
	{
		if (GlobalVideo.get() != null)
		{
			// steal from video state
			if (_tankmanVideoActive)
			{
				if (_tankmanVideoUseSound)
				{
					var wasFuckingHit = GlobalVideo.get().webm.wasHitOnce;
					_tankmanVideoSoundMultiplier = GlobalVideo.get().webm.renderedCount / _tankmanVideoFrames;

					if (_tankmanVideoSoundMultiplier > 1)
					{
						_tankmanVideoSoundMultiplier = 1;
					}
					if (_tankmanVideoSoundMultiplier < 0)
					{
						_tankmanVideoSoundMultiplier = 0;
					}
					if (_tankmanVideoDoShit)
					{
						var compareShit:Float = 50;
						if (_tankmanVideoSound.time >= (_tankmanVideoSound.length * _tankmanVideoSoundMultiplier) + compareShit || _tankmanVideoSound.time <= (_tankmanVideoSound.length * _tankmanVideoSoundMultiplier)
							- compareShit)
							_tankmanVideoSound.time = _tankmanVideoSound.length * _tankmanVideoSoundMultiplier;
					}
					if (wasFuckingHit)
					{
						if (_tankmanVideoSoundMultiplier == 0)
						{
							if (_tankmanVideoSoundPrevMultiplier != 0)
							{
								_tankmanVideoSound.pause();
								_tankmanVideoSound.time = 0;
							}
						}
						else
						{
							if (_tankmanVideoSoundPrevMultiplier == 0)
							{
								_tankmanVideoSound.resume();
								_tankmanVideoSound.time = _tankmanVideoSound.length * _tankmanVideoSoundMultiplier;
							}
						}
						_tankmanVideoSoundPrevMultiplier = _tankmanVideoSoundMultiplier;
					}
				}

				GlobalVideo.get().update(handoverElapsed);

				if (controls.RESET)
				{
					GlobalVideo.get().restart();
				}

				if (FlxG.keys.justPressed.P || FlxG.mouse.justPressed) // JOELwindows7: click to pause/unpause
				{
					// txt.text = pauseText;
					trace("PRESSED PAUSE");
					GlobalVideo.get().togglePause();
					if (GlobalVideo.get().paused)
					{
						GlobalVideo.get().alpha();
					}
					else
					{
						GlobalVideo.get().unalpha();
						// txt.text = defaultText;
					}
				}

				if (controls.ACCEPT || GlobalVideo.get().ended || GlobalVideo.get().stopped)
				{
					GlobalVideo.get().hide();
					GlobalVideo.get().stop();
				}

				if (controls.ACCEPT || GlobalVideo.get().ended)
				{
					if (_tankmanVideoSlaguotin)
					{
						if (_tankmanVideoActive)
						{
							tankmanIntroDictionary(_tankmanVideoDictionary);
							if (_tankmanVideoIsOutro)
							{
							}
							else
							{
							}
						}
						_tankmanVideoSlaguotin = false;
					}
				}

				if (GlobalVideo.get().played || GlobalVideo.get().restarted)
				{
					GlobalVideo.get().show();
				}
			}

			GlobalVideo.get().restarted = false;
			GlobalVideo.get().played = false;
			GlobalVideo.get().stopped = false;
			GlobalVideo.get().ended = false;
		}
	}

	// JOELwindows7: Okay, here's the new hack audio with BOLO's figure outs!
	function manipulateTheAudio():Void
	{
		#if FEATURE_AUDIO_MANIPULATE
		@:privateAccess
		{
			// JOELwindows7: hey, there's a new advanced way of doing this with BOLO's figure outs!
			// https://github.com/BoloVEVO/Kade-Engine-Public/blob/stable/source/FreeplayState.hx
			// https://github.com/BoloVEVO/Kade-Engine-Public/blame/stable/source/PlayState.hx#L2614
			// add safety too pls!
			// hmm, perhaps it should be really nested. confirm really if it's not null FIRST,
			// if not null, then yess evaluate in it.
			#if cpp
			#if (lime >= "8.0.0")
			if (FlxG.sound.music != null)
				if (FlxG.sound.music.playing)
					FlxG.sound.music._channel.__source.__backend.setPitch(songMultiplier);
			if (vocals != null)
				if (vocals.playing)
					vocals._channel.__source.__backend.setPitch(songMultiplier);
			if (vocals2 != null)
				if (vocals2.playing)
					vocals2._channel.__source.__backend.setPitch(songMultiplier);
			#else
			if (FlxG.sound.music != null)
				if (FlxG.sound.music.playing)
					lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
			if (vocals != null)
				if (vocals.playing)
					lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
			if (vocals2 != null)
				if (vocals2.playing)
					lime.media.openal.AL.sourcef(vocals2._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
			#end
			#elseif web
			#if (lime >= "8.0.0" && lime_howlerjs)
			if (FlxG.sound.music != null)
				if (FlxG.sound.music.playing)
					FlxG.sound.music._channel.__source.__backend.setPitch(songMultiplier);
			if (vocals != null)
				if (vocals.playing)
					vocals._channel.__source.__backend.setPitch(songMultiplier);
			if (vocals2 != null)
				if (vocals2.playing)
					vocals2._channel.__source.__backend.setPitch(songMultiplier);
			#else
			if (FlxG.sound.music != null)
				if (FlxG.sound.music.playing)
					FlxG.sound.music._channel.__source.__backend.parent.buffer.__srcHowl.rate(songMultiplier);
			if (vocals != null)
				if (vocals.playing)
					vocals._channel.__source.__backend.parent.buffer.__srcHowl.rate(songMultiplier);
			if (vocals2 != null)
				if (vocals2.playing)
					vocals2._channel.__source.__backend.parent.buffer.__srcHowl.rate(songMultiplier);
			#end
			#end
		}
		#end
	}

	// JOELwindows7: Here new destroy background video
	function immediatelyRemoveVideo()
	{
		if (useVideo)
		{
			GlobalVideo.get().stop();
			if (videoSprite != null)
			{
				videoSprite.kill();
				remove(videoSprite);
			}
			removedVideo = true;
		}
		if (useVLC)
		{
			// JOELwindows7: VLC stop!
			#if FEATURE_VLC
			if (vlcHandler != null)
			{
				vlcHandler.kill();
				remove(vlcHandler);
			}
			#end
			removedVideo = true;
		}
	}

	// JOELwindows7: Step compare syndication pls
	function getStepCompare(stepWhich:Int, compareType:CompareTypes):Bool
	{
		return CoolUtil.stepCompare(curStep, stepWhich, songMultiplier, compareType);
	}

	// JOELwindows7: Oh, he needs int version
	function getStepCompareInt(stepWhich:Int, compareType:Int):Bool
	{
		return CoolUtil.stepCompareInt(curStep, stepWhich, songMultiplier, compareType);
	}

	function getStepCompareStr(stepWhich:Int, compareType:String):Bool
	{
		return CoolUtil.stepCompareStr(curStep, stepWhich, songMultiplier, compareType);
	}

	// JOELwindows7: Syndicate also the between pls
	function getStepBetween(stepLeft:Int, stepRight:Int, withEquals:Bool = false, leftEquals:Bool = true, rightEquals:Bool = true):Bool
	{
		return CoolUtil.stepBetween(curStep, stepLeft, stepRight, songMultiplier, withEquals, leftEquals, rightEquals);
	}

	// JOELwindows7: the modulo too!!
	function getStepModulo(stepWhich:Int, equalsWhat:Float = 0):Bool
	{
		return CoolUtil.stepModulo(curStep, stepWhich, songMultiplier, equalsWhat);
	}

	// JOELwindows7: Reposition Lyric
	function repositionLyric(delta:Float = 0)
	{
		if (lyricExists)
		{
			try
			{
				// IDEA: Lerp??
				lyricers.x = switch (FlxG.save.data.kpopLyricsPosition)
				{
					case 0:
						(100);
					case 1:
						(FlxG.width / 2
							- (Math.max(lyricing[Std.int(Math.floor(curBeat / 4))][0].length, lyricing[Std.int(Math.floor(curBeat / 4))][1].length) * 10) / 2);
					case 2:
						(FlxG.width
							- 100
							- (Math.max(lyricing[Std.int(Math.floor(curBeat / 4))][0].length, lyricing[Std.int(Math.floor(curBeat / 4))][1].length) * 10));
					case _:
						(100);
				};
			}
			catch (e)
			{
			}
			if (SONG.isCreditRoll)
			{
				// push it back up a bit
				lyricers.y = FlxG.height - 300;
			}
			lyricers.setFormat(Paths.font("Ubuntu-R-NF.ttf"), 14, FlxColor.WHITE, switch (FlxG.save.data.kpopLyricsPosition)
			{
				case 0:
					FlxTextAlign.LEFT;
				case 1:
					FlxTextAlign.CENTER;
				case 2:
					FlxTextAlign.RIGHT;
				case _:
					FlxTextAlign.LEFT;
			}, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			lyricers.scrollFactor.set();
		}
	}

	// JOELwindows7: BOLO cleanups
	public function funniKill()
	{
		while (notes.length > 0)
		{
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}

		if (!PlayStateChangeables.optimize && FlxG.save.data.distractions)
		{
			while (Character.animationNotes.length > 0)
			{
				Character.animationNotes.pop();
				Character.animationNotes = [];
			}
		}

		unspawnNotes = [];
		notes.clear();
	}

	// JOELwindows7: BOLO precacher!
	// Precache List for some stuff (Like frames, sounds and that kinda of shit)

	public function precacheThing(target:String, type:String, ?library:String = null)
	{
		switch (type)
		{
			case 'image':
				Paths.image(target, library);
			case 'sound':
				Paths.sound(target, library);
			case 'music':
				Paths.music(target, library);
		}
	}

	var wasBf:Bool = false;

	function turnChanges(isBf:Bool = false)
	{
		if (isBf)
		{
			if (!wasBf)
			{
				// square underlay to right
				wasBf = true;
			}
		}
		else
		{
			if (wasBf)
			{
				// square underlay to left
				wasBf = false;
			}
		}
	}

	// JOELwindows7: some other checks
	function extraInitCheck()
	{
		// JOELwindows7: BPM decimaled
		// https://github.com/Perkedel/Kaded-fnf-mods/issues/42
		// https://api.haxeflixel.com/flixel/math/FlxMath.html#getDecimals
		if (SONG.bpm % 1 != 0 || FlxMath.getDecimals(SONG.bpm) > 0)
		{
			// https://stackoverflow.com/a/2304062/9079640
			Debug.logWarn('PlayState DECIMAL TEMPO: Your Init Tempo (${SONG.bpm}) is decimal!! This may cause messed up rhythms. Ensure your BPM is whole number unless your music is itself decimal tempo\n
			btw, who the peck would use Decimal Tempo in a music huh?!\nMaybe you should instead times 10 it couple times over until it no longers decimal, just saying.. like if 150.5 to 1505 something2\n
			woi dengerin tempo lu itu koma-koma-an!! kok pake acara koma-koma-an segala sih, pusing tau!
			');
			Main.gjToastManager.createToast(null, 'Decimal Tempo', 'Your init tempo is ${SONG.bpm}, which is decimal!\nEnsure it\'s whole number.');

			// although this may cause problems still, since this code framework might has no double precisison and could cause whole `20` to be `20.0000759832475` something2.
			// if only there is function like `isWhole()`;
			// var teston = Math.
		}
	}
} // u looked :O -ides

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
