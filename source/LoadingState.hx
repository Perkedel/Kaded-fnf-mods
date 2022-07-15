package;

import flixel.math.FlxMath;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUISprite;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.addons.ui.FlxUIText;
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
// JOELwindows7: FlxUI fy!!!
// JOELwindows7: yoinks BOLO's https://github.com/BoloVEVO/Kade-Engine-Public/blob/stable/source/LoadingState.hx

class LoadingState extends MusicBeatState
{
	inline static var MIN_TIME = 1.0;

	var loadingText:FlxUIText; // JOELwindows7: BOLO's loading text
	var target:FlxState;
	var previously:FlxState; // JOELwindows7: to store previous state.
	var stopMusic = false;
	var callbacks:MultiCallback;

	var logo:FlxUISprite;
	var gfDance:FlxUISprite;
	var danceLeft = false;
	var bg:FlxUISprite; // JOELwindows7: I prefer that also the week7 loading background to be global too as well.

	// JOELwindows7: da loading bar pls
	// var loadingBar:ProgressBar;
	var loadBar:FlxUISprite; // JOELwindows7: luckydog7's version
	var targetShit:Float = 0; // JOELwindows7: BOLO's interpreted loading targetals.

	var selectImageNumber:Int = 0; // JOELwindows7: choose loading images

	var tooLongDidntLoadTimer:FlxTimer; // JOELwindows7: here too long didn't load timer that if runs out appears skip & cancel button.
	var deservesTooLongDidntLoad:Bool = false; // JOELwindows7: only activates when it is too long!

	function new(target:FlxState, stopMusic:Bool, ?previously:FlxState) // JOELwindows7: here previously
	{
		super();
		this.target = target;
		this.stopMusic = stopMusic;
		this.previously = previously != null ? previously : new MainMenuState(); // JOELwindows7: here previous state.
		// JOELwindows7: choose loading images randomly out of available we have
		this.selectImageNumber = FlxG.random.int(0, Perkedel.MAX_NUMBER_OF_LOADING_IMAGES - 1);

		// JOELwindows7: appear these buttons if the loading took long time!
		this.deservesTooLongDidntLoad = false;
		this.tooLongDidntLoadTimer = new FlxTimer();
	}

	override function create()
	{
		// JOELwindows7: bekgron stuff
		installStarfield3D(0, 0, FlxG.width, FlxG.height);
		// the luckydog7's reverse engineer week7 loading bg
		bg = new FlxUISprite();
		// bg.loadGraphic(Paths.image('funkay'));
		// JOELwindows7: yoink image above from https://github.com/luckydog7/Funkin-android/blob/master/assets/preload/images/funkay.png
		bg.loadGraphic(Paths.image('loading/loading_screen' + Std.string(selectImageNumber), 'shared')); // JOELwindows7: the week7 loading screen LFM edition
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
		// cast too!
		loadBar = cast new FlxUISprite(0,
			FlxG.height - 20).makeGraphic(FlxG.width, 10,
				0xffff00ff); // JOELwindows7: was -59694, now use BOLO's proper hex 0xfffffab8! nvm. use same magenta!
		loadBar.screenCenter(FlxAxes.X);
		loadBar.antialiasing = FlxG.save.data.antialiasing; // JOELwindows7: BOLO antialias the loading bar too!
		add(loadBar);

		logo = new FlxUISprite(-150, -100);
		logo.frames = Paths.getSparrowAtlas('logoBumpin');
		logo.antialiasing = FlxG.save.data.antialiasing;
		logo.animation.addByPrefix('bump', 'logo bumpin', 24);
		logo.animation.play('bump');
		logo.updateHitbox();
		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;

		gfDance = new FlxUISprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = FlxG.save.data.antialiasing;
		// add(gfDance); // JOELwindows7: sorry man, according to luckydog7 and other credible sources:
		// add(logo); // JOELwindows7: week 7 has already made new screen of it instead.

		// JOELwindows7: BOLO's loading text stuffs
		loadingText = new FlxUIText(FlxG.width * 8, FlxG.height * 0.07, 0, "Loading", 42);
		loadingText.antialiasing = false;
		loadingText.setFormat(Paths.font('pixel.otf'), 42, 0xFFFFFF, CENTER);
		loadingText.screenCenter();
		loadingText.alpha = .4; // JOELwindows7: YOU GOTTA ALPHA THIS, MAN.
		// We want to see our beautiful artworks over there.

		loadingText.x -= 425;
		loadingText.y += 125;

		// add(gfDance);
		// add(logo);
		add(loadingText);

		installBusyHourglassScreenSaver(); // JOELwindows7: another indicator making sure no hang

		FlxTransitionableState.skipNextTransOut = false; // JOELwindows7: BOLO destroy this for Psyched transitioning!

		initSongsManifest().onComplete(function(lib)
		{
			callbacks = new MultiCallback(onLoad);
			var introComplete = callbacks.add("introComplete");
			// JOELwindows7: Brother! do not forget safety!!! thancc BOLO
			if (PlayState.SONG != null)
			{
				checkLoadSong(getSongPath());
				if (PlayState.SONG.needsVoices)
					checkLoadSong(getVocalPath());
			}

			// Essential libraries (characters,notes,gameplay elements) (JOELwindows7: BOLO's said)
			// JOELwindows7: also here comes more optimize!
			checkLibrary("shared");
			if (!FlxG.save.data.optimize && FlxG.save.data.background)
			{
				if (PlayState.storyWeek > 0)
					checkLibrary("week" + PlayState.storyWeek);
				else
					checkLibrary("tutorial");
			}

			// JOELwindows7: also BOLO check if pixel
			if (GameplayCustomizeState.freeplayNoteStyle == 'pixel') // Essential library for Customize gameplay. (Very light)
				checkLibrary("week6");

			var fadeTime = 0.5;
			FlxG.camera.fade(FlxG.camera.bgColor, fadeTime, true);
			new FlxTimer().start(fadeTime + MIN_TIME, function(_) introComplete());
		});

		// JOELwindows7: and the too long timer
		tooLongDidntLoadTimer.start(Perkedel.LOADING_TOO_LONG_TIME_THRESHOLD, onTooLongDidntLoad);
	}

	function checkLoadSong(path:String)
	{
		if (path != null)
		{ // JOELwindows7: BOLO added safety!!!
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
	}

	function checkLibrary(library:String)
	{
		// trace(OpenFlAssets.hasLibrary(library));
		Debug.logInfo('$library exists? ${OpenFlAssets.hasLibrary(library)}'); // JOELwindows7: BOLO's better tellings!!!
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

		// JOELwindows7: in BOLO it's step hit with if curStep % 4 == 0 do these.
		// https://github.com/BoloVEVO/Kade-Engine-Public/blob/stable/source/LoadingState.hx
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
			// loadBar.scale.x = callbacks.getFired().length / callbacks.getUnfired().length; // JOELwindows7: was used
			// _loadingBar.setPercentage((callbacks.getFired().length / callbacks.getUnfired().length) * 100); // already onProgress

			// JOELwindows7: here new BOLO's way
			loadingText.text = 'Loading [${callbacks.length - callbacks.numRemaining}/${callbacks.length}]';
			targetShit = FlxMath.remapToRange(callbacks.numRemaining / callbacks.length, 1, 0, 0, 1);
			// loadBar.scale.x += 0.5 * (targetShit - loadBar.scale.x);
			loadBar.scale.x += (targetShit - loadBar.scale.x); // JOELwindows7: I mean, why do you halve half it?
		}

		#if debug
		if (FlxG.keys.justPressed.SPACE)
			// trace('fired: ' + callbacks.getFired() + " unfired:" + callbacks.getUnfired());
			Debug.logTrace('fired: ' + callbacks.getFired() + " unfired:" + callbacks.getUnfired()); // JOELwindows7: BOLO's better tellings!
		#end

		// JOELwindows7: too long didn't load controls
		if (deservesTooLongDidntLoad)
		{
			if (FlxG.keys.justPressed.ENTER || haveClicked)
			{
				skip();
				haveClicked = false;
			}
			if (controls.BACK || FlxG.keys.justPressed.ESCAPE || haveBacked)
			{
				cancel();
				haveBacked = false;
			}
		}
	}

	function onLoad()
	{
		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// JOELwindows7: got loaded
		_loadingBar.setInfoText("Done Loading!");
		_loadingBar.setLoadingType(ExtraLoadingType.DONE);
		_loadingBar.delayedUnPopNow(5);
		// JOELwindows7: and cancel too long didn't load
		if (tooLongDidntLoadTimer != null)
		{
			tooLongDidntLoadTimer.cancel();
			tooLongDidntLoadTimer = null;
		}

		// FlxG.switchState(target);
		// JOELwindows7: BOLO used this!
		// MusicBeatState.instance.switchState(target);
		MusicBeatState.switchStateStatic(target);
	}

	static function getSongPath()
	{
		return Paths.inst(PlayState.SONG.songId);
	}

	static function getVocalPath()
	{
		return Paths.voices(PlayState.SONG.songId);
	}

	inline static public function loadAndSwitchState(target:FlxState, stopMusic = false, ?previously:FlxState)
	{
		// FlxG.switchState(getNextState(target, stopMusic, previously));
		// JOELwindows7: use BOLO's new way!
		MusicBeatState.switchStateStatic(getNextState(target, stopMusic, previously));
	}

	static function getNextState(target:FlxState, stopMusic = false, ?previously:FlxState):FlxState // JOELwindows7: here previously
	{
		Paths.setCurrentLevel("week" + PlayState.storyWeek);
		// #if NO_PRELOAD_ALL // JOELwindows7: This should be no longer necessary even on cpp right?
		if (!PlayState.isSM)
		{ // JOELwindows7: folks, unfortunately it cannot load stepmania this way. there is different instruction!
			var loaded = isSoundLoaded(getSongPath())
				&& (!PlayState.SONG.needsVoices || isSoundLoaded(getVocalPath()))
				&& isLibraryLoaded("shared")
				&& isLibraryLoaded("week" + PlayState.storyWeek) // JOELwindows7: and BOLO's week checks!
				;

			if (!loaded)
				return new LoadingState(target, stopMusic, previously); // JOELwindows7: here previously
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

	// JOELwindows7: sometimes there's a bug or accident. like hang, or whatever, you just want to skip or go back.
	function onTooLongDidntLoad(tmr:FlxTimer)
	{
		Debug.logInfo(Perkedel.LOADING_TOO_LONG_SAY);
		addBackButton();
		addAcceptButton();
		backButton.alpha = 0;
		acceptButton.alpha = 0;
		// yoink from werror force majeur state
		var tooLongText:FlxUIText = new FlxUIText();
		tooLongText.scrollFactor.set(0, 0);
		tooLongText.setFormat(Paths.font("vcr.ttf"), 12, FlxColor.WHITE);
		tooLongText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1);
		tooLongText.text = Perkedel.LOADING_TOO_LONG_SAY;
		tooLongText.screenCenter(X);
		tooLongText.y = FlxG.height - tooLongText.height - 10;
		tooLongText.alpha = 0;
		add(tooLongText);

		FlxTween.tween(tooLongText, {alpha: 1.0}, .5);
		FlxTween.tween(backButton, {alpha: 1.0}, .5);
		FlxTween.tween(acceptButton, {alpha: 1.0}, .5);

		deservesTooLongDidntLoad = true;
	}

	public function skip()
	{
		// if (numRemaining == 0)
		// 	return;
		// for (id in unfired.keys())
		// 	fired.push(id);
		// numRemaining = 0;
		// callback();
		FlxG.switchState(target);
	}

	public function cancel()
	{
		// if (numRemaining == 0)
		// 	return;
		// numRemaining = 0;
		// callback();
		FlxG.switchState(previously);
	}

	override function manageJoypad()
	{
		super.manageJoypad();
		if (joypadLastActive != null)
		{
			if (joypadLastActive.justPressed.START)
			{
				skip();
			}
			// if (joypadLastActive.justPressed.B){
			// 	cancel();
			// }
		}
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
