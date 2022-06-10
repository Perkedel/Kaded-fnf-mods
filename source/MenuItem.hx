package;

import openfl.Lib;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

class MenuItem extends FlxSpriteGroup
{
	public var targetY:Float = 0;
	public var week:FlxSprite;
	public var flashingInt:Int = 0;

	public function new(x:Float, y:Float, weekNum:Int = 0, useCustomImagePath:Bool = false, imagePath:String = "")
	{
		// JOELwindows7: now useCustomImagePath & imagePath for custom Week image due to manual assignations.
		super(x, y);
		// week = new FlxSprite().loadGraphic(Paths.loadImage('storymenu/week'+ weekNum)); // former
		week = new FlxSprite().loadGraphic(Paths.loadImage('storymenu/' + (useCustomImagePath ? imagePath : 'week' + weekNum))); // JOELwindows7: there you go
		week.antialiasing = FlxG.save.data.antialiasing;
		add(week);
	}

	private var isFlashing:Bool = false;

	public function startFlashing():Void
	{
		isFlashing = true;
	}

	// if it runs at 60fps, fake framerate will be 6
	// if it runs at 144 fps, fake framerate will be like 14, and will update the graphic every 0.016666 * 3 seconds still???
	// so it runs basically every so many seconds, not dependant on framerate??
	// I'm still learning how math works thanks whoever is reading this lol
	var fakeFramerate:Int = Math.round((1 / FlxG.elapsed) / 10);

	//JOELwindows7: oh here framerate stuff going on
	var daRefFPS:Int = 60;

	override function update(elapsed:Float)
	{
		//JOELwindows7: get the FPS
		#if FEATURE_DISPLAY_FPS_CHANGE
		daRefFPS = Std.int((cast(Lib.current.getChildAt(0), Main)).getFPS());
		#end

		super.update(elapsed);
		// y = FlxMath.lerp(y, (targetY * 120) + 480, 0.17 * (60 / FlxG.save.data.fpsCap));
		// y = FlxMath.lerp(y, (targetY * 120) + 480, 0.20); // JOELwindows7: perhaps don't rely on FPS because slower the higher FPS cap is?
		// y = FlxMath.lerp(y, (targetY * 120) + 480, 0.20 * (60 / fakeFramerate)); // JOELwindows7: Okay let's try Fake Framerate?
		y = FlxMath.lerp(y, (targetY * 120) + 480, 0.17 * (60 /daRefFPS)); // JOELwindows7: too fast! how about current FPS we had??

		if (isFlashing)
			flashingInt += 1;

		if (flashingInt % fakeFramerate >= Math.floor(fakeFramerate / 2))
			week.color = 0xFF33ffff;
		else if (FlxG.save.data.flashing)
			week.color = FlxColor.WHITE;
	}
}
