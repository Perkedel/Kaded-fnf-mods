#if sys
package;

import lime.app.Application;
#if windows
import Discord.DiscordClient;
#end
import openfl.display.BitmapData;
import openfl.utils.Assets;
import flixel.ui.FlxBar;
import haxe.Exception;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
#if cpp
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

using StringTools;

class Caching extends MusicBeatState
{
	var toBeDone = 0;
	var done = 0;

	var loaded = false;

	var text:FlxText;
	var kadeLogo:FlxSprite;
	var lFMLogo:FlxSprite; //JOELwindows7: LFM logo

	var bar:FlxBar; //JOELwindows7: globalize the loading bar.

	public static var bitmapData:Map<String,FlxGraphic>;

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

		FlxG.mouse.visible = false;

		FlxG.worldBounds.set(0,0);

		bitmapData = new Map<String,FlxGraphic>();

		text = new FlxText(FlxG.width / 2, FlxG.height / 2 + 300,0,"Loading...");
		text.size = 34;
		text.alignment = FlxTextAlign.CENTER;
		text.alpha = 0;

		//JOELwindows7: LFM logo
        lFMLogo = new FlxSprite(FlxG.width / 2, (FlxG.height / 2)+270).loadGraphic(Paths.image('art/LFMicon128'));
        lFMLogo.x -= lFMLogo.width / 2;
        lFMLogo.y -= lFMLogo.height / 2;
        lFMLogo.alpha = 0;

		kadeLogo = new FlxSprite(FlxG.width / 2, FlxG.height / 2).loadGraphic(Paths.image('KadeEngineLogo'));
		kadeLogo.x -= kadeLogo.width / 2;
		kadeLogo.y -= kadeLogo.height / 2 + 100;
		text.y -= kadeLogo.height / 2 - 125;
		text.x -= 170;
		kadeLogo.setGraphicSize(Std.int(kadeLogo.width * 0.6));
		if(FlxG.save.data.antialiasing != null)
			kadeLogo.antialiasing = FlxG.save.data.antialiasing;
		else
			kadeLogo.antialiasing = true;
		
		kadeLogo.alpha = 0;

		FlxGraphic.defaultPersist = FlxG.save.data.cacheImages;

		#if cpp
		if (FlxG.save.data.cacheImages)
		{
			trace("caching images...");

			for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/characters")))
			{
				if (!i.endsWith(".png"))
					continue;
				images.push(i);
			}
		}

		trace("caching music...");

		for (i in FileSystem.readDirectory(FileSystem.absolutePath(
			#if !mobile
			"assets/songs"
			#else
			Asset2File.getPath("assets/songs")
			#end
			)))
		{
			music.push(i);
		}
		#end

		toBeDone = Lambda.count(images) + Lambda.count(music);

		//JOELwindows7: globalize loading bar
		bar = new FlxBar(10,FlxG.height - 100,FlxBarFillDirection.LEFT_TO_RIGHT,FlxG.width,40,this,"done",0,toBeDone);
		bar.color = FlxColor.PURPLE;

		//JOELwindows7:bekgrond stuffer
		installStarfield3D(0,0,FlxG.width,FlxG.height);
		starfield3D.alpha = 0;

		add(bar);
		bar.color = FlxColor.PURPLE; //JOELwindows7: try again after adding this time?

		add(kadeLogo);
		add(lFMLogo);
		add(text);

		installBusyHourglassScreenSaver(); //JOELwindows7: for loading animation hourglass

		trace('starting caching..');
		
		#if cpp
		// update thread

		sys.thread.Thread.create(() -> {
			while(!loaded)
			{
				if (toBeDone != 0 && done != toBeDone)
					{
						var alpha = HelperFunctions.truncateFloat(done / toBeDone * 100,2) / 100;
						starfield3D.alpha = alpha;
						kadeLogo.alpha = alpha;
						lFMLogo.alpha = alpha;
						text.alpha = alpha;
						text.text = "Loading... (" + done + "/" + toBeDone + ")";
						//bar.value = done; //JOELwindows7: workaround since not showing up
					}
			}
		
		});

		// cache thread

		sys.thread.Thread.create(() -> {
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
		trace("LOADING: " + toBeDone + " OBJECTS.");

		for (i in images)
		{
			var replaced = i.replace(".png","");
			var data:BitmapData = BitmapData.fromFile("assets/shared/images/characters/" + i);
			trace('id ' + replaced + ' file - assets/shared/images/characters/' + i + ' ${data.width}');
			var graph = FlxGraphic.fromBitmapData(data);
			graph.persist = true;
			graph.destroyOnNoUse = false;
			bitmapData.set(replaced,graph);
			done++;
		}

		for (i in music)
		{
			FlxG.sound.cache(Paths.inst(i));
			FlxG.sound.cache(Paths.voices(i));
			trace("cached " + i);
			done++;
		}


		trace("Finished caching...");

		loaded = true;

		trace(Assets.cache.hasBitmapData('GF_assets'));

		FlxG.switchState(new TitleState());
	}

}
#end