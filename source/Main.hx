package;

import GameJolt;
import flixel.addons.plugin.screengrab.FlxScreenGrab;
import flixel.input.keyboard.FlxKey;
// import grig.midi.MidiOut;
// import grig.midi.MidiIn;
import flixel.util.FlxTimer;
#if !debug
import com.player03.android6.Permissions;
#end
#if FEATURE_WEBM_NATIVE
import webm.WebmPlayer;
#end
import openfl.display.Bitmap;
import lime.app.Application;
#if FEATURE_DISCORD
import Discord.DiscordClient;
#end
import openfl.display.BlendMode;
import openfl.text.TextFormat;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import lime.system.JNI;
import plugins.systems.ScanPlatform;

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 120; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	public static var bitmapFPS:Bitmap;

	public static var instance:Main;

	public static var watermarks = true; // Whether to put Kade Engine literally anywhere
	public static var odyseeMark = true; // Whether to put Odysee mark literally anywhere
	public static var perkedelMark = true; // Whether to put Perkedel Technologies literally anywhere
	public static var chosenMark:String = 'odysee'; // Whether to put chosen watermark litterally anywhere
	public static var chosenMarkNum:Int = 0;

	#if gamejolt
	public static var gjToastManager:GJToastManager; // JOELwindows7: TentaRJ Gamejolter now has Toast yey! FORMATTER STOP PECK THIS UP FEMALE DOG!!!

	#end
	// JOELwindows7: Please no demonic reference about Mark of what the peck!
	/*
		// public static var midiIn:MidiIn; //JOELwindows7: Grig MIDI in
		// public static var midiOut:MidiOut; //JOELwindows7: Grig MIDI out
	 */
	// You can pretty much ignore everything from here on - your code should go in your states.
	public static function main():Void
	{
		// quick checks

		Lib.current.addChild(new Main());
	}

	public function new()
	{
		instance = this;

		super();

		// JOELwindows7: Grig midi pls
		// trace("MIDI out APIs:\n" + MidiOut.getApis());
		// midiIn = new MidiIn(grig.midi.Api.Unspecified);
		// midiOut = new MidiOut(grig.midi.Api.Unspecified);

		// JOELwindows7: pecking ask permission on Android 6 and forth
		#if (android && !debug)
		var askPermNum:Int = 0;
		var timeoutPermNum:Int = 10;
		while (!Permissions.hasPermission(Permissions.WRITE_EXTERNAL_STORAGE)
			|| !Permissions.hasPermission(Permissions.READ_EXTERNAL_STORAGE))
		{
			Permissions.requestPermissions([Permissions.WRITE_EXTERNAL_STORAGE, Permissions.READ_EXTERNAL_STORAGE,]);

			// count how many attempts. if after timeout num still not work, peck this poop
			// I gave up!
			trace("Num of Attempt ask permissions: " + Std.string(askPermNum));
			askPermNum++;
			if (askPermNum > timeoutPermNum)
				break;
		}
		#end
		// wtf, it doesn't work if Debug situation?! I don't get it!

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	public static var webmHandler:WebmHandler;

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		#if !cpp
		framerate = 60;
		#end

		// JOELwindows7: install the toast for GameJolter
		#if gamejolt
		gjToastManager = new GJToastManager();
		#end

		// JOELwindows7: Friggin Screen Grab functions
		// inspired from https://gamebanana.com/mods/55620 (FNF but it's LOVE lua)
		// it had screenshoter so why not?
		//
		#if !js
		FlxScreenGrab.defineHotKeys([FlxKey.PRINTSCREEN, FlxKey.F6], true, false);
		#end

		// GrowtopiaFli's Video Cutscener
		// The code https://github.com/GrowtopiaFli/openfl-haxeflixel-video-code/
		// added by JOELwindows7
		// use this video from bbpanzu https://www.youtube.com/watch?v=2B7dqNB6GcE
		// to figure out how supposed it be.
		var ourSource:String = "assets/videos/DO NOT DELETE OR GAME WILL CRASH/dontDelete.webm";

		// JOELwindows7: an check whether isWebm or not
		#if FEATURE_WEBM_JS
		trace("vid isWeb");
		GlobalVideo.isWebm = false;
		#elseif FEATURE_WEBM_NATIVE
		trace("vid isNative");
		GlobalVideo.isWebm = true;
		#end
		trace("is GlobalVideo a webm? " + Std.string(GlobalVideo.isWebm));
		// https://github.com/Raltyro/VideoState.hx-Kade-Engine-1.5-Patch

		#if FEATURE_WEBM_JS
		trace("Video Cutscener is built-in Browser's");
		var str1:String = "HTML CRAP";
		var vHandler = new VideoHandler();
		vHandler.init1();
		vHandler.video.name = str1;
		addChild(vHandler.video);
		vHandler.init2();
		GlobalVideo.setVid(vHandler);
		vHandler.source(ourSource);
		#elseif FEATURE_WEBM_NATIVE
		trace("Video Cutscener is external webm player");
		var str1:String = "WEBM SHIT";
		var webmHandle = new WebmHandler();
		webmHandle.source(ourSource);
		webmHandle.makePlayer();
		trace("new WebmHandler make player");
		webmHandle.webm.name = str1;
		addChild(webmHandle.webm);
		GlobalVideo.setWebm(webmHandle);
		#end
		// end GrowtopiaFli Video Cutscener

		// Run this first so we can see logs.
		Debug.onInitProgram();

		// Gotta run this before any assets get loaded.
		ModCore.initialize();

		trace("init FPS counter");
		#if !mobile
		fpsCounter = new KadeEngineFPS(10, 3, 0xFFFFFF);
		bitmapFPS = ImageOutline.renderImage(fpsCounter, 1, 0x000000, true);
		bitmapFPS.smoothing = true;
		#end

		// #if FEATURE_THREADING
		// initialState = Caching; //JOELwindows7: remember! it doesn't work in Android! make sure !mobile first
		// trace("Go to caching first");
		// #else
		// trace("Just straight to the game anyway");
		// #end
		// trace("put game");

		game = new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen);
		addChild(game);

		#if !mobile
		addChild(fpsCounter);
		new FlxTimer().start(1, function(timer:FlxTimer)
		{
			toggleFPS(FlxG.save.data.fps);
		});
		#end
		// JOELwindows7: finally, have a GameJolt toast
		#if gamejolt
		addChild(gjToastManager); // Needs to be added after the game. that's how stack workss
		gjToastManager.createToast(Paths.image("art/LFMicon128"), "Cool and good", "Welcome to Last Funkin Moments", false);
		#end

		// JOELwindows7: GameBanana seems notorious.
		// let's just hide everything that "trashworthy" / "blammworthy"
		// if we're not in Odysee.
		// sorry guys, I've used ninja's inspiration (timed exclusive on newgrounds).
		// pls don't cancel me, I beg you!
		#if odysee
		trace("We are in Odysee");
		#else
		trace("We are not in Odysee. are we? or forgot Odysee define compile.. idk");
		#end

		// JOELwindows7: steal the mods (including ND without permission)
		#if thief
		trace("IT'S YOINK TIME");
		#else
		trace("no yoink time.");
		#end

		// JOELwindows7: stop the accidentally press numpad 0 during arrow key on keyboard
		// destroyAccidentVolKeys();

		// JOELwindows7: mini scanners for platform detections
		ScanPlatform.getPlatform();

		// Finish up loading debug tools.
		Debug.onGameStart();
	}

	var game:FlxGame;

	var fpsCounter:KadeEngineFPS;

	// taken from forever engine, cuz optimization very pog.
	// thank you shubs :)
	public static function dumpCache()
	{
		///* SPECIAL THANKS TO HAYA
		@:privateAccess
		for (key in FlxG.bitmap._cache.keys())
		{
			var obj = FlxG.bitmap._cache.get(key);
			if (obj != null)
			{
				Assets.cache.removeBitmapData(key);
				FlxG.bitmap._cache.remove(key);
				obj.destroy();
			}
		}
		Assets.cache.clear("songs");
		// */
	}

	public function toggleFPS(fpsEnabled:Bool):Void
	{
	}

	public function changeFPSColor(color:FlxColor)
	{
		fpsCounter.textColor = color;
	}

	public function setFPSCap(cap:Float)
	{
		openfl.Lib.current.stage.frameRate = cap;
	}

	public function getFPSCap():Float
	{
		return openfl.Lib.current.stage.frameRate;
	}

	public function getFPS():Float
	{
		return fpsCounter.currentFPS;
	}

	// JOELwindows7: Pusholl! Disable vol keys pls! it annoys me!!!
	public function destroyAccidentVolKeys()
	{
		FlxG.sound.volumeUpKeys = null;
		FlxG.sound.volumeDownKeys = null;
		FlxG.sound.muteKeys = null;
	}

	// JOELwindows7: mini platform scanner
}
// JOELwindows7: Oh my God. extremely complicated since 1.7 changes here yeauw.
/**
 * A lot of stuffs has been moved into its own dedicated area.
 * I hope this works here.
 * 
 * See, why modding FNF is insanely hard? because yeah. everything change, goes all the way out of understanding.
 * you will need to relearn the new stuff again. If you wish to stay in current situation, 
 * it'll even be whole sufferings and torture to adapt to this brand new world.
 * 
 * I wish me & you gamers don't have to face this every single time. All we have to do should've been like
 * just build the song, stage data, character data, modcharts and stuffs and call it a day. Not like you must
 * download source code and hardcodely add stuffs in it, or make your own filed compile-less loading yourself just to get
 * away with it.
 * 
 * You know, Kade cases here, is already a big trouble. I hope it's not Kade and friends' fault. And I do believe so.
 * e.g. PlayState.hx is notorious for conflict entirely according to since when I was
 * started forking it this. Options.hx too! wtf?!?!?! I don't get it! it's merely change this, but Git somehow interpret it
 * like everything changes, can't compare at all. What? is it because entire file reupload through GitHub? Oh pls don't!
 * use your locally cloned and push from that computer instead. Or is it? I believe GitHub should be smart, and even already is
 * the file is changed manually through GitHub or uploaded overwrite manually through GitHub. compare what's different
 * and here's the commit result. part of this change, not all these change.
 * 
 * You know why FNF was here in the first place? wait **what the peck was that question?** pull it back!
 * There may be something trouble or lacks in Stepmania or Etterna. And it seems that there is new thing compared.
 * which are stage scenery, characters, and stuffs. You see, common rhythm game bg are just images. Well, osu! has sophisticated
 * stage bg (storyboard) too but unfortunately it's RAW and just that, and also different programming language.
 * FNF on the other hand had these built in, for all songs. it's core principle for the stage bg. You even can storyboard with all familiar Lua & Haxe script.
 * not that bizzare programming language (although you can do that if you'd like, just like bbpanzu's)
 * 
 * Some thesis examiner would still not understand, especially those stans, ugh get the peck rid of them!
 * But here we are. With all lives given in it instead of just a plain image or video. with versus on all songs.
 * it's unique! I believe... that Versus mode in DDR isn't the same we were FNFing about. We are talking about
 * Co-Op but it's versus instead. not just Double or what. 2 player, 4 had this and the other had other 4. not 4 arrows go to both player, no!
 * 
 * Hey we are almost talking personal stuff here. Hold your mouth pls! We do not want our mission contract here be compromised
 * and got trashed because of the real intention of this LFM here. 
 * We still have more weeks every month until the Full Ass. And this meantime we must tell messages to gamers
 * about today's situation in this FNF mod communities.
 * 
 * So I wanted to make one here out again. I've been concepting this since days of Stepmania. Game mode selection is hard sessioned. I hate that.
 * I want it also dynamic like rest of the parameter in a session. if you want to switch to PIU you don't need to restart session first.
 * Just choose in the song selection menu that's it. and heck the arrow collumn and be added or removed on demand later in the game when there is the command in
 * the rhythm data. VOEZ go brrrrrrrrr!!!! VOEZ with collumns templates. each collumns has assigned keypress which.
 * Collumn can be 1D, 2D osu-like saber, 3D, 4D, ah whatever you get the idea. most importantly, like Stepmania loadings. also
 * with characters and sceneries inspired from it this FNF.
 */
