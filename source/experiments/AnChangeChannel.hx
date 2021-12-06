package experiments;

import flixel.FlxG;

class AnChangeChannel extends AbstractTestMenu
{
	var rate:Float = 1;
	var channel:Float = 0;

	public function new()
	{
		super();
	}

	override function create()
	{
		super.create();
		addInfoText("Change Channel Test\n\nLEFT or RIGHT = Switch Channel\nUP or DOWN = Change Rate\nR = reset");
	}

	override function update(elapsed)
	{
		if (FlxG.keys.justPressed.LEFT || haveLefted)
		{
			channel--;
			if (channel < 0)
				channel = 8;
			haveLefted = false;
		}
		else if (FlxG.keys.justPressed.RIGHT || haveRighted)
		{
			channel++;
			if (channel > 8)
				channel = 0;
			haveRighted = false;
		}
		else if (FlxG.keys.justPressed.UP || haveUpped)
		{
			rate += 0.1;

			if (rate > 3)
				rate = 3;
			haveUpped = false;
		}
		else if (FlxG.keys.justPressed.DOWN || haveDowned)
		{
			rate -= 0.1;

			if (rate < 0)
				rate = 0;
			haveDowned = false;
		}
		else if (FlxG.keys.justPressed.R)
		{
			rate = 1;
			channel = 0;
		}

		// JOELwindows7: there you are, audio manipulate lol
		#if FEATURE_AUDIO_MANIPULATE
		@:privateAccess
		{
			if (FlxG.sound.music.playing)
			{
				lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, rate);
				lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.CHANNELS, channel);
			}
		}
		#end
		super.update(elapsed);
	}
}
