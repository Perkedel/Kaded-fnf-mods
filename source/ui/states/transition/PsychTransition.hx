package ui.states.transition;

// JOELwindows7: Yoink from https://github.com/BoloVEVO/Kade-Engine-Public/blob/stable/source/PsychTransition.hx
// idk, just got this cool little transition substate of some sort, idk..
import flixel.util.FlxTimer;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.Transition;
import flixel.addons.transition.TransitionData;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import MusicBeatSubstate;

/**
 *
 * Transition overrides
 * @author Shadow_Mario_
 *
**/
class PsychTransition extends MusicBeatSubstate
{
	public static var finishCallback:Void->Void;

	private var leTween:FlxTween = null;

	public static var nextCamera:FlxCamera;

	var isTransIn:Bool = false;
	var transBlack:FlxSprite;
	var transGradient:FlxSprite;

	public static var wackyScreenTransitionTechnique:Bool = false; // JOELwindows7: flag to use DOOM style screen fall.

	public function new(duration:Float, isTransIn:Bool)
	{
		// if (!isTransIn)
		// 	Game.captureScreenshot();
		// TODO: get screengrab screenshot when trans in to new scene & use it as transBlack
		super();

		this.isTransIn = isTransIn;
		var width:Int = Std.int(FlxG.width);
		var height:Int = Std.int(FlxG.height);
		transGradient = FlxGradient.createGradientFlxSprite(width, height, (isTransIn ? [0x0, FlxColor.BLACK] : [FlxColor.BLACK, 0x0]));
		transGradient.scrollFactor.set();
		add(transGradient);

		// JOELwindows7: have take this screenshot pls for transIn
		var screenShotering:FlxSprite;
		if (wackyScreenTransitionTechnique)
			screenShotering = Game.lastScreenshotBitmap != null ? new FlxSprite().loadGraphic(Game.lastScreenshotBitmap.bitmapData) : new FlxSprite()
				.makeGraphic(width, height
				+ 400, FlxColor.BLACK);
		else
			screenShotering = new FlxSprite().makeGraphic(width, height + 400, FlxColor.BLACK);

		// transBlack = new FlxSprite().makeGraphic(width, height + 400, FlxColor.BLACK);
		transBlack = screenShotering;
		transBlack.scrollFactor.set();
		add(transBlack);

		transGradient.x -= (width - FlxG.width) / 2;
		transBlack.x = transGradient.x;

		if (isTransIn)
		{
			transGradient.y = wackyScreenTransitionTechnique ? -transGradient.height : transBlack.y - transBlack.height;
			FlxTween.tween(transGradient, {y: transGradient.height + 50}, duration, {
				onComplete: function(twn:FlxTween)
				{
					close();
				},
				ease: FlxEase.linear
			});
		}
		else
		{
			transGradient.y = -transGradient.height;
			if (wackyScreenTransitionTechnique)
			{
				transBlack.y = 0;
				var leTimer:FlxTimer = new FlxTimer();
				leTimer.start(duration, function(tmr:FlxTimer)
				{
					if (finishCallback != null)
					{
						finishCallback();
					}
				});
			}
			else
			{
				transBlack.y = transGradient.y - transBlack.height + 50;
				leTween = FlxTween.tween(transGradient, {y: transGradient.height + 50}, duration, {
					onComplete: function(twn:FlxTween)
					{
						if (finishCallback != null)
						{
							finishCallback();
						}
					},
					ease: FlxEase.linear
				});
			}
		}
	}

	var camStarted:Bool = false;

	override function update(elapsed:Float)
	{
		if (isTransIn)
			transBlack.y = transGradient.y + transGradient.height;
		else
		{
			if (!wackyScreenTransitionTechnique)
				transBlack.y = transGradient.y - transBlack.height;
		}

		var camList = FlxG.cameras.list;
		camera = camList[camList.length - 1];
		transBlack.cameras = [camera];
		transGradient.cameras = [camera];

		super.update(elapsed);

		if (isTransIn)
			transBlack.y = transGradient.y + transGradient.height;
		else
		{
			if (!wackyScreenTransitionTechnique)
				transBlack.y = transGradient.y - transBlack.height;
		}
	}

	override function destroy()
	{
		if (leTween != null)
		{
			finishCallback();
			leTween.cancel();
		}
		super.destroy();
	}
}
