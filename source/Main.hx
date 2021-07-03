package;

#if !debug
import com.player03.android6.Permissions;
#end
#if cpp
import webm.WebmPlayer;
#end
import openfl.display.BlendMode;
import openfl.text.TextFormat;
import openfl.display.Application;
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

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 120; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	public static var watermarks = true; // Whether to put Kade Engine liteartly anywhere
	public static var odyseeMark = true; // Whether to put Odysee mark literally anywhere
	public static var perkedelMark = true; // Whether to put Perkedel Technologies literally anywhere
	public static var chosenMark:String = 'odysee'; //Whether to put chosen watermark litterally anywhere
	public static var chosenMarkNum:Int = 0;
	//JOELwindows7: Please no demonic reference about Mark of what the peck!

	//JOELwindows7: the Android Permission pls help
	//public static var androidPermissioner:Permission

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{

		// quick checks 

		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		//JOELwindows7: pecking ask permission on Android 6 and forth
		#if (android && !debug)
		var askPermNum:Int = 0;
		var timeoutPermNum:Int = 10;
		while(!Permissions.hasPermission(Permissions.WRITE_EXTERNAL_STORAGE) ||
			 !Permissions.hasPermission(Permissions.READ_EXTERNAL_STORAGE)){
			Permissions.requestPermissions([
				Permissions.WRITE_EXTERNAL_STORAGE,
				Permissions.READ_EXTERNAL_STORAGE,
			]);

			//count how many attempts. if after timeout num still not work, peck this poop
			//I gave up!
			trace("Num of Attempt ask permissions: " + Std.string(askPermNum));
			askPermNum++;
			if(askPermNum > timeoutPermNum) break;
		}
		#end
		//wtf, it doesn't work if Debug situation?! I don't get it!

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

		#if (cpp && sys && !mobile) //JOELwindows7: remember! it doesn't work in Android!
		initialState = Caching;
		game = new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen);
		#else
		game = new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen);
		#end
		//JOELwindows7: nope, Caching still crashes in Android.
		addChild(game);

		//GrowtopiaFli's Video Cutscener
		//The code https://github.com/GrowtopiaFli/openfl-haxeflixel-video-code/
		//added by JOELwindows7
		//use this video from bbpanzu https://www.youtube.com/watch?v=2B7dqNB6GcE
		//to figure out how supposed it be.
		var ourSource:String = "assets/videos/DO NOT DELETE OR GAME WILL CRASH/dontDelete.webm";
		
		#if web
		var str1:String = "HTML CRAP";
		var vHandler = new VideoHandler();
		vHandler.init1();
		vHandler.video.name = str1;
		addChild(vHandler.video);
		vHandler.init2();
		GlobalVideo.setVid(vHandler);
		vHandler.source(ourSource);
		#elseif (desktop && cpp)
		var str1:String = "WEBM SHIT"; 
		var webmHandle = new WebmHandler();
		webmHandle.source(ourSource);
		webmHandle.makePlayer();
		webmHandle.webm.name = str1;
		addChild(webmHandle.webm);
		GlobalVideo.setWebm(webmHandle);
		#end
		//end GrowtopiaFli Video Cutscener

		#if !mobile
		fpsCounter = new FPS(10, 3, 0xFFFFFF);
		addChild(fpsCounter);
		toggleFPS(FlxG.save.data.fps);

		#end

		//JOELwindows7: GameBanana seems notorious.
		//let's just hide everything that "trashworthy" / "blammworthy"
		//if we're not in Odysee.
		//sorry guys, I've used ninja's inspiration (timed exclusive on newgrounds).
		//pls don't cancel me, I beg you!
		#if odysee
		trace("We are in Odysee");
		#else
		trace("We are not in Odysee. are we? or forgot Odysee define compile.. idk");
		#end

		//JOELwindows7: steal the mods (including ND without permission)
		#if thief
		trace("IT'S YOINK TIME");
		#else
		trace("no yoink time.");
		#end
	}

	var game:FlxGame;

	var fpsCounter:FPS;

	public function toggleFPS(fpsEnabled:Bool):Void {
		fpsCounter.visible = fpsEnabled;
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
}
