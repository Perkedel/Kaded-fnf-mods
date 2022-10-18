package;

import flixel.addons.ui.FlxUIText;
#if FEATURE_FILESYSTEM
import flixel.addons.ui.FlxUISprite;
import lime.app.Application;
#if FEATURE_DISCORD
import Discord.DiscordClient;
#end
import openfl.display.BitmapData;
import openfl.utils.Assets as OpenFlAssets;
import flixel.ui.FlxBar;
import haxe.Exception;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
#if FEATURE_FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import utils.Asset2File;
import flixel.input.keyboard.FlxKey;

using StringTools;

// JOELwindows7: Still, FlxUI fy this... idk
class Caching extends MusicBeatState
{
	var toBeDone = 0;
	var done = 0;

	var loaded = false;

	var text:FlxUIText;
	var kadeLogo:FlxUISprite;
	var lFMLogo:FlxUISprite; // JOELwindows7: LFM logo

	var bar:FlxBar; // JOELwindows7: globalize the loading bar.

	public static var bitmapData:Map<String, FlxGraphic>;

	// public static var rawBitmapData:Map<String, BitmapData>; // JOELwindows7: I said, the raw bitmap data!
	var images = [];
	var music = [];
	var charts = [];

	override function create()
	{
		FlxG.save.bind('funkin', 'ninjamuffin99');

		PlayerSettings.init();

		trace("initing save data");
		KadeEngineData.initSave();
		trace("Save data inited");

		// It doesn't reupdate the list before u restart rn lmao
		NoteskinHelpers.updateNoteskins();

		FlxG.sound.muteKeys = [FlxKey.fromString(FlxG.save.data.muteBind)];
		FlxG.sound.volumeDownKeys = [FlxKey.fromString(FlxG.save.data.volDownBind)];
		FlxG.sound.volumeUpKeys = [FlxKey.fromString(FlxG.save.data.volUpBind)];

		FlxG.mouse.visible = false;

		FlxG.worldBounds.set(0, 0);

		bitmapData = new Map<String, FlxGraphic>();
		// rawBitmapData = new Map<String, BitmapData>();

		text = new FlxUIText(FlxG.width / 2, FlxG.height / 2 + 300, 0, "Loading...");
		text.size = 34;
		text.alignment = FlxTextAlign.CENTER;
		text.alpha = 0;

		// JOELwindows7: LFM logo. & cast all these too
		lFMLogo = cast new FlxUISprite(FlxG.width / 2, (FlxG.height / 2) + 270).loadGraphic(Paths.image('art/LFMicon128'));
		lFMLogo.x -= lFMLogo.width / 2;
		lFMLogo.y -= lFMLogo.height / 2;
		lFMLogo.alpha = 0;

		kadeLogo = cast new FlxUISprite(FlxG.width / 2, FlxG.height / 2).loadGraphic(Paths.loadImage('KadeEngineLogo'));
		kadeLogo.x -= kadeLogo.width / 2;
		kadeLogo.y -= kadeLogo.height / 2 + 100;
		text.y -= kadeLogo.height / 2 - 125;
		text.x -= 170;
		kadeLogo.setGraphicSize(Std.int(kadeLogo.width * 0.6));
		if (FlxG.save.data.antialiasing != null)
			kadeLogo.antialiasing = FlxG.save.data.antialiasing;
		else
			kadeLogo.antialiasing = true;

		kadeLogo.alpha = 0;

		FlxGraphic.defaultPersist = FlxG.save.data.cacheImages;

		#if FEATURE_FILESYSTEM
		if (FlxG.save.data.cacheImages)
		{
			Debug.logTrace("caching images...");

			// TODO: Refactor this to use OpenFlAssets.
			for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/characters")))
			{
				if (!i.endsWith(".png"))
					continue;
				images.push(i);
			}

			for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/noteskins")))
			{
				if (!i.endsWith(".png"))
					continue;
				images.push(i);
			}
		}

		Debug.logTrace("caching music...");

		// for (i in FileSystem.readDirectory(FileSystem.absolutePath(
		// 	#if !mobile
		// 	"assets/songs"
		// 	#else
		// 	Asset2File.getPath("assets/songs")
		// 	#end
		// 	)))
		// {
		// 	music.push(i);
		// }
		// TODO: Get the song list from OpenFlAssets.
		music = Paths.listSongsToCache();
		#end

		toBeDone = Lambda.count(images) + Lambda.count(music);

		// JOELwindows7: globalize loading bar
		bar = new FlxBar(10, FlxG.height - 50, FlxBarFillDirection.LEFT_TO_RIGHT, FlxG.width, 40, null, "done", 0, toBeDone);
		bar.color = FlxColor.PURPLE;

		// JOELwindows7:bekgrond stuffer
		installStarfield3D(0, 0, FlxG.width, FlxG.height);
		starfield3D.alpha = 0;

		add(bar);
		bar.color = FlxColor.PURPLE; // JOELwindows7: try again after adding this time?

		add(kadeLogo);
		add(lFMLogo);
		add(text);

		installBusyHourglassScreenSaver(); // JOELwindows7: for loading animation hourglass

		trace('starting caching..');

		#if FEATURE_MULTITHREADING
		// update thread

		sys.thread.Thread.create(() ->
		{
			while (!loaded)
			{
				if (toBeDone != 0 && done != toBeDone)
				{
					var alpha = HelperFunctions.truncateFloat(done / toBeDone * 100, 2) / 100;
					starfield3D.alpha = alpha; // JOELwindows7: Haxe starfield walker
					kadeLogo.alpha = alpha;
					lFMLogo.alpha = alpha; // JOELwindows7: that logo
					text.alpha = alpha;
					text.text = "Loading... (" + done + "/" + toBeDone + ")";
					// bar.value = done; //JOELwindows7: workaround since not showing up
				}
			}
		});

		// cache thread
		sys.thread.Thread.create(() ->
		{
			cache();
		});
		#end

		super.create();
	}

	var calledDone = false;

	override function update(elapsed)
	{
		super.update(elapsed);
	}

	function cache()
	{
		#if FEATURE_FILESYSTEM
		trace("LOADING: " + toBeDone + " OBJECTS.");

		for (i in images)
		{
			var replaced = i.replace(".png", "");

			// var data:BitmapData = BitmapData.fromFile("assets/shared/images/characters/" + i);
			var imagePath = Paths.image('characters/$i', 'shared');
			Debug.logTrace('Caching character graphic $i ($imagePath)...');
			var data = OpenFlAssets.getBitmapData(imagePath);
			var graph = FlxGraphic.fromBitmapData(data);
			graph.persist = true;
			graph.destroyOnNoUse = false;
			bitmapData.set(replaced, graph);
			done++;
		}

		for (i in music)
		{
			var inst = Paths.inst(i);
			if (Paths.doesSoundAssetExist(inst))
			{
				FlxG.sound.cache(inst);
			}

			var voices = Paths.voices(i);
			if (Paths.doesSoundAssetExist(voices))
			{
				FlxG.sound.cache(voices);
			}

			done++;
		}

		Debug.logTrace("Finished caching...");

		loaded = true;

		trace(OpenFlAssets.cache.hasBitmapData('GF_assets'));
		#end
		FlxG.switchState(new TitleState());
	}
}
#end
