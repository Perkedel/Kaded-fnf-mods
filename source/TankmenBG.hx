package;

import flixel.addons.ui.FlxUISprite;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import Paths;
import Song;
import Conductor;
import Math;
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import openfl.utils.AssetType;
import lime.graphics.Image;
import flixel.graphics.FlxGraphic;
import openfl.utils.AssetManifest;
import openfl.utils.AssetLibrary;
import flixel.system.FlxAssets;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import lime.utils.Assets;
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import openfl.utils.AssetType;
import lime.graphics.Image;
import flixel.graphics.FlxGraphic;
import openfl.utils.AssetManifest;
import openfl.utils.AssetLibrary;
#if cpp
import Sys;
import sys.FileSystem;
#end

using StringTools;

// JOELwindows7: FlxUI fy!
class TankmenBG extends FlxUISprite
{
	public static var animationNotes:Array<Dynamic> = []; // JOELwindows7: animation note BOLO

	public var tankSpeed:Float = 0.7 * 1000;

	private var endingOffset:Float; // JOELwindows7: BOLO's here

	public var goingRight:Bool = false;

	public var strumTime:Float; // JOELwindows7: & there BOLO

	// https://github.com/BoloVEVO/Kade-Engine-Public/blob/stable/source/TankmenBG.hx
	var runAnimPlayedTimes:Int = 0;
	var runAnimPlayedTimesMax:Int = 1;

	//JOELwindows7: choose which implementation between luckydog7's yoink or BOLO's yoink
	var useDifferentImplementation:Bool = false;

	override public function new()
	{
		super();
		frames = Paths.getSparrowAtlas("tankmanKilled1");
		antialiasing = FlxG.save.data.antialiasing; // JOELwindows7: Don't forget antialiasing!!! BOLO yeah
		// JOELwindows7: BOLO's add frameh by song multiplier
		animation.addByPrefix('run', 'tankman running', Std.int(24 * PlayState.songMultiplier), true);
		animation.addByPrefix('shot', 'John Shot ' + FlxG.random.int(1, 2), Std.int(24 * PlayState.songMultiplier), false);
		// JOELwindows7: size 0 by 0 errors in this my FNF mod.
		animation.play("run");
		animation.curAnim.curFrame = FlxG.random.int(0, animation.curAnim.frames.length - 1); // JOELwindows7: idk, BOLO has randomizer!

		updateHitbox();
		setGraphicSize(Std.int(width * 0.8));
		updateHitbox();
	}

	public function resetShit(xPos:Float, yPos:Float, right:Bool, ?stepsMax:Int, ?speedModifier:Float = 1)
	{
		x = xPos;
		y = yPos;
		reset(xPos, yPos); // JOELwindows7: you must reset so Tankman running goes active again.
		goingRight = right;
		endingOffset = FlxG.random.float(50, 200); // JOELwindows7: BOLO's endding offset
		if (stepsMax == null)
		{
			stepsMax = 1;
		}
		if (speedModifier == null)
		{
			speedModifier = 1;
		}
		runAnimPlayedTimesMax = stepsMax;

		var newSpeedModifier:Float = speedModifier * 2;

		tankSpeed = FlxG.random.float(0.6, 1) * 170;
		if (goingRight)
		{
			velocity.x = tankSpeed * newSpeedModifier;
			if (animation.curAnim.name == "shot")
			{
				offset.x = 300;
				velocity.x = 0;
			}
		}
		else
		{
			velocity.x = tankSpeed * (newSpeedModifier * -1);
			if (animation.curAnim.name == "shot")
			{
				velocity.x = 0;
			}
		}

		flipX = goingRight; // JOELwindows7: BOLO had flipX thingy!
	}

	override public function update(elapsed:Float)
	{
		if(!useDifferentImplementation){
			// JOELwindows7: Buddy, what was that code bellow? lemme fix it
			if (goingRight)
			{
				if (animation.curAnim.name == "shot")
				{
					offset.x = 400;
					velocity.x = 10;
				}
				flipX = true;
			}
			else
			{
				flipX = false;
				if (animation.curAnim.name == "shot")
				{
					offset.x = 0;
					velocity.x = 10;
				}
			}

			if (animation.curAnim.name == "run" && animation.curAnim.finished == true && runAnimPlayedTimes < runAnimPlayedTimesMax)
			{
				animation.play("run", true);

				runAnimPlayedTimes++;
			}

			if (animation.curAnim.name == "run" && animation.curAnim.finished == true && runAnimPlayedTimes >= runAnimPlayedTimesMax)
			{
				animation.play("shot", true);

				runAnimPlayedTimes = 0;
			}
			if (animation.curAnim.name == "shot" && animation.curAnim.curFrame >= animation.curAnim.frames.length - 1)
			{
				// destroy(); // JOELwindows7: do not destroy! it will null object reference!
				kill(); // nvm. the recycled tankman kept killed, not alive anymore.
			}
		} else {

			// JOELwindows7: New BOLO tankmen updatoid
			visible = (x > -0.5 * FlxG.width && x < 1.2 * FlxG.width);

			if (animation.curAnim.name == "run")
			{
				var speed:Float = (Conductor.songPosition - strumTime) * tankSpeed * PlayState.songMultiplier;
				if (goingRight)
					x = (0.02 * FlxG.width - endingOffset) + speed;
				else
					x = (0.74 * FlxG.width + endingOffset) - speed;
			}
			else if (animation.curAnim.finished)
			{
				kill();
			}

			if (Conductor.songPosition > strumTime)
			{
				animation.play('shot');
				if (goingRight)
				{
					offset.x = 300;
					offset.y = 200;
				}
			}
		}

		super.update(elapsed);
	}
}
