package;

import flixel.util.FlxAxes;
import CoreState;
import lime.app.Promise;
import lime.app.Future;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;
import openfl.utils.Assets as OpenFlAssets;
import lime.utils.Assets as LimeAssets;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
import haxe.io.Path;

// import haxe.ui.components.Progress as ProgressBar; // JOELwindows7: a little help here?

class LoadingState extends MusicBeatState
{
	inline static var MIN_TIME = 1.0;

	var target:FlxState;
	var stopMusic = false;
	var callbacks:MultiCallback;

	var logo:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft = false;
	var bg:FlxSprite; // JOELwindows7: I prefer that also the week7 loading background to be global too as well.

	// JOELwindows7: da loading bar pls
	// var loadingBar:ProgressBar;
	var loadBar:FlxSprite; // JOELwindows7: luckydog7's version

	function new(target:FlxState, stopMusic:Bool)
	{
		super();
		this.target = target;
		this.stopMusic = stopMusic;
	}

	override function create()
	{
		// JOELwindows7: bekgron stuff
		installStarfield3D(0, 0, FlxG.width, FlxG.height);
		// the luckydog7's reverse engineer week7 loading bg
		bg = new FlxSprite();
		// bg.loadGraphic(Paths.image('funkay'));
		bg.loadGraphic(Paths.image('loading/loading_screen', 'shared')); // JOELwindows7: the week7 loading screen LFM edition
		bg.setGraphicSize(FlxG.width);
		bg.updateHitbox();
		bg.antialiasing = FlxG.save.data.antialiasing; // JOELwindows7: must set antialiasing based on setting right now!
		add(bg);
		bg.scrollFactor.set();
		bg.screenCenter();

		// JOELwindows7: loading stuffs
		_loadingBar.setLoadingType(ExtraLoadingType.GOING);
		_loadingBar.setInfoText("Loading Next State...");
		_loadingBar.popNow();

		// JOELwindows7: oh also luckydog7's reverse engineering I think loading bar & stuff?
		// https://github.com/luckydog7/Funkin-android/blob/master/source/LoadingState.hx
		loadBar = new FlxSprite(0, FlxG.height - 20).makeGraphic(FlxG.width, 10, -59694);
		loadBar.screenCenter(FlxAxes.X);
		add(loadBar);

		logo = new FlxSprite(-150, -100);
		logo.frames = Paths.getSparrowAtlas('logoBumpin');
		logo.antialiasing = FlxG.save.data.antialiasing;
		logo.animation.addByPrefix('bump', 'logo bumpin', 24);
		logo.animation.play('bump');
		logo.updateHitbox();
		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;

		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = FlxG.save.data.antialiasing;
		// add(gfDance); // JOELwindows7: sorry man, according to luckydog7 and other credible sources:
		// add(logo); // JOELwindows7: week 7 has already made new screen of it instead.

		installBusyHourglassScreenSaver(); // JOELwindows7: another indicator making sure no hang

		initSongsManifest().onComplete(function(lib)
		{
			callbacks = new MultiCallback(onLoad);
			var introComplete = callbacks.add("introComplete");
			checkLoadSong(getSongPath());
			if (PlayState.SONG.needsVoices)
				checkLoadSong(getVocalPath());
			checkLibrary("shared");
			if (PlayState.storyWeek > 0)
				checkLibrary("week" + PlayState.storyWeek);
			else
				checkLibrary("tutorial");

			var fadeTime = 0.5;
			FlxG.camera.fade(FlxG.camera.bgColor, fadeTime, true);
			new FlxTimer().start(fadeTime + MIN_TIME, function(_) introComplete());
		});
	}

	function checkLoadSong(path:String)
	{
		if (!OpenFlAssets.cache.hasSound(path))
		{
			var library = OpenFlAssets.getLibrary("songs");
			final symbolPath = path.split(":").pop();
			// @:privateAccess
			// library.types.set(symbolPath, SOUND);
			// @:privateAccess
			// library.pathGroups.set(symbolPath, [library.__cacheBreak(symbolPath)]);
			var callback = callbacks.add("song:" + path);
			OpenFlAssets.loadSound(path).onComplete(function(_)
			{
				callback();
			});
		}
	}

	function checkLibrary(library:String)
	{
		trace(OpenFlAssets.hasLibrary(library));
		if (OpenFlAssets.getLibrary(library) == null)
		{
			@:privateAccess
			if (!LimeAssets.libraryPaths.exists(library))
				throw "Missing library: " + library;

			var callback = callbacks.add("library:" + library);
			OpenFlAssets.loadLibrary(library).onComplete(function(_)
			{
				callback();
			});
		}
	}

	override function beatHit()
	{
		super.beatHit();

		logo.animation.play('bump');
		danceLeft = !danceLeft;

		if (danceLeft)
			gfDance.animation.play('danceRight');
		else
			gfDance.animation.play('danceLeft');
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		// JOELwindows7: and to see loading progress here. luckydog7 thing
		if (callbacks != null)
		{
			loadBar.scale.x = callbacks.getFired().length / callbacks.getUnfired().length;
			// _loadingBar.setPercentage((callbacks.getFired().length / callbacks.getUnfired().length)*100);
		}

		#if debug
		if (FlxG.keys.justPressed.SPACE)
			trace('fired: ' + callbacks.getFired() + " unfired:" + callbacks.getUnfired());
		#end
	}

	function onLoad()
	{
		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// JOELwindows7: got loaded
		_loadingBar.setInfoText("Done Loading!");
		_loadingBar.setLoadingType(ExtraLoadingType.DONE);
		_loadingBar.delayedUnPopNow(5);

		FlxG.switchState(target);
	}

	static function getSongPath()
	{
		return Paths.inst(PlayState.SONG.songId);
	}

	static function getVocalPath()
	{
		return Paths.voices(PlayState.SONG.songId);
	}

	inline static public function loadAndSwitchState(target:FlxState, stopMusic = false)
	{
		FlxG.switchState(getNextState(target, stopMusic));
	}

	static function getNextState(target:FlxState, stopMusic = false):FlxState
	{
		Paths.setCurrentLevel("week" + PlayState.storyWeek);
		// #if NO_PRELOAD_ALL // JOELwindows7: This should be no longer necessary even on cpp right?
		if (!PlayState.isSM)
		{ // JOELwindows7: folks, unfortunately it cannot load stepmania this way. there is different instruction!
			var loaded = isSoundLoaded(getSongPath())
				&& (!PlayState.SONG.needsVoices || isSoundLoaded(getVocalPath()))
				&& isLibraryLoaded("shared");

			if (!loaded)
				return new LoadingState(target, stopMusic);
		}
		// #end
		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();

		return target;
		// return switchState(target,true,true,true); //JOELwindows7: idk man.
	}

	// #if NO_PRELOAD_ALL //JOELwindows7: comment this! open it up to all!
	static function isSoundLoaded(path:String):Bool
	{
		return OpenFlAssets.cache.hasSound(path);
	}

	static function isLibraryLoaded(library:String):Bool
	{
		return OpenFlAssets.getLibrary(library) != null;
	}

	// #end

	override function destroy()
	{
		super.destroy();

		callbacks = null;
	}

	static function initSongsManifest()
	{
		// TODO: Hey, wait, does this break ModCore?

		var id = "songs";
		var promise = new Promise<AssetLibrary>();

		var library = OpenFlAssets.getLibrary(id);

		if (library != null)
		{
			return Future.withValue(library);
		}

		var path = id;
		var rootPath = null;

		@:privateAccess
		var libraryPaths = LimeAssets.libraryPaths;
		if (libraryPaths.exists(id))
		{
			path = libraryPaths[id];
			rootPath = Path.directory(path);
		}
		else
		{
			if (StringTools.endsWith(path, ".bundle"))
			{
				rootPath = path;
				path += "/library.json";
			}
			else
			{
				rootPath = Path.directory(path);
			}
			@:privateAccess
			path = LimeAssets.__cacheBreak(path);
		}

		AssetManifest.loadFromFile(path, rootPath)
			.onComplete(function(manifest)
			{
				if (manifest == null)
				{
					promise.error("Cannot parse asset manifest for library \"" + id + "\"");
					return;
				}

				var library = AssetLibrary.fromManifest(manifest);

				if (library == null)
				{
					promise.error("Cannot open library \"" + id + "\"");
				}
				else
				{
					@:privateAccess
					LimeAssets.libraries.set(id, library);
					library.onChange.add(LimeAssets.onChange.dispatch);
					promise.completeWith(Future.withValue(library));
				}
			})
			.onError(function(_)
			{
				promise.error("There is no asset library with an ID of \"" + id + "\"");
			})
			.onProgress(function(progress, total)
			{
				// JOELwindows7: whoah you can onProgress?!??!?!
				promise.progress(progress, total);
				Main.loadingBar.setPercentage((progress / total) * 100);
			});

		return promise.future;
	}
}

class MultiCallback
{
	public var callback:Void->Void;
	public var logId:String = null;
	public var length(default, null) = 0;
	public var numRemaining(default, null) = 0;

	var unfired = new Map<String, Void->Void>();
	var fired = new Array<String>();

	public function new(callback:Void->Void, logId:String = null)
	{
		this.callback = callback;
		this.logId = logId;
	}

	public function add(id = "untitled")
	{
		id = '$length:$id';
		length++;
		numRemaining++;
		var func:Void->Void = null;
		func = function()
		{
			if (unfired.exists(id))
			{
				unfired.remove(id);
				fired.push(id);
				numRemaining--;

				if (logId != null)
					log('fired $id, $numRemaining remaining');

				if (numRemaining == 0)
				{
					if (logId != null)
						log('all callbacks fired');
					callback();
				}
			}
			else
				log('already fired $id');
		}
		unfired[id] = func;
		return func;
	}

	inline function log(msg):Void
	{
		if (logId != null)
			trace('$logId: $msg');
	}

	public function getFired()
		return fired.copy();

	public function getUnfired()
		return [for (id in unfired.keys()) id];
}
