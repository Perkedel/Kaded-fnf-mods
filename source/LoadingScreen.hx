// JOELwindows7: yoink from https://github.com/KadeDev/Hex-The-Weekend-Update/blob/main/source/LoadingScreen.hx
// Kade you should not leave us too as well, wtf bro?!
// luckily I excels coding & yoinking. what if not?! everybody else.
// sorry, YinYang48, we were having a bad era right now.
import flixel.util.FlxColor;
import flixel.ui.FlxBar;
#if FEATURE_MULTITHREADING
import sys.thread.Mutex;
#end
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxState;

class LoadingScreen extends MusicBeatState
{
	var target:FlxState; // JOELwindows7: must be universal for all kinds of States, right?
	#if FEATURE_MULTITHREADING
	var loadMutex:Mutex;
	#end

	var bar:FlxBar;

	public static var progress:Int = 0;

	public var localProg:Int = 0;

	var loadingSong:Bool = false;

	public function new(_target:FlxState, song:Bool = false)
	{
		target = _target;
		Debug.logTrace("bruhg");
		#if FEATURE_MULTITHREADING
		loadMutex = new Mutex();
		#end
		loadingSong = song;
		super();
	}

	var startLoad:Bool = false;

	var bg:FlxSprite;

	override function create()
	{
		Debug.logTrace("bruhg loading screen Kade + YinYang48 Hex");
		// JOELwindows7: bekgron stuff
		installStarfield3D(0, 0, FlxG.width, FlxG.height);

		// JOELwindows7: loading stuffs
		_loadingBar.setLoadingType(ExtraLoadingType.GOING);
		_loadingBar.setInfoText("Loading Next State...");
		_loadingBar.popNow();

		Main.dumpCache();
		progress = 0;
		bg = new FlxSprite(0, 0).loadGraphic(Paths.image('loading/loading_screen', 'shared'));
		bg.antialiasing = FlxG.save.data.antialiasing;
		bg.scrollFactor.set();
		bg.updateHitbox();
		bg.ID = 999999;
		add(bg);

		bar = new FlxBar(24, 684, FlxBarFillDirection.LEFT_TO_RIGHT, 1224, 12, this, "localProg", 0, 100);
		bar.createFilledBar(FlxColor.TRANSPARENT, FlxColor.fromRGB(255, 22, 210));
		bar.scrollFactor.set();
		add(bar);

		Debug.logTrace("lets do some loading " + bar);

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (!startLoad)
		{
			startLoad = true;
			#if FEATURE_MULTITHREADING
			sys.thread.Thread.create(() ->
			{
				loadMutex.acquire();
				Debug.logTrace("reset da assets");
				MasterObjectLoader.resetAssets();
				target.load();
				target.loadedCompletely = true;
				Debug.logTrace("we done lets gtfo " + target);
				switchState(target, false, true);
				loadMutex.release();
			});
			#else
			Debug.logInfo("\n\n\n\nWAIT, there is no sys?!??!?!\n\nbruh! why no sys lol!?\n\n\n\n");
			Debug.logTrace("reset da assets");
			MasterObjectLoader.resetAssets();
			target.load();
			target.loadedCompletely = true;
			Debug.logTrace("we done lets gtfo " + target);
			switchState(target, false, true);
			#end
		}
		localProg = progress;
		_loadingBar.setPercentage(localProg);
		super.update(elapsed);
	}
}
