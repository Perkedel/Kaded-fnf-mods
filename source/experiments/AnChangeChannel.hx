/*
 * GNU General Public License, Version 3.0
 *
 * Copyright (c) 2021 Perkedel
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package experiments;

import behavior.audio.IManipulateAudio;
import flixel.FlxG;

class AnChangeChannel extends AbstractTestMenu implements IManipulateAudio
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
		// #if FEATURE_AUDIO_MANIPULATE
		// @:privateAccess
		// {
		// 	if (FlxG.sound.music.playing)
		// 	{
		// 		lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, rate);
		// 		lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.CHANNELS, channel);
		// 	}
		// }
		// #end
		manipulateTheAudio();
		super.update(elapsed);
	}

	function manipulateTheAudio():Void
	{
		#if FEATURE_AUDIO_MANIPULATE
		@:privateAccess
		{
			// JOELwindows7: hey, there's a new advanced way of doing this with BOLO's figure outs!
			// https://github.com/BoloVEVO/Kade-Engine-Public/blob/stable/source/FreeplayState.hx
			if (FlxG.sound.music.playing)
			{
				#if web
				#if (lime >= "8.0.0" && lime_howlerjs)
				FlxG.sound.music._channel.__source.__backend.setPitch(rate);
				#else
				FlxG.sound.music._channel.__source.__backend.parent.buffer.__srcHowl.rate(rate);
				#end
				#elseif cpp
				#if (lime >= "8.0.0")
				// FlxG.sound.music._channel.__source.__backend.setPitch(rate);
				FlxG.sound.music._channel.__source.set_pitch(rate);
				#else
				lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, rate);
				lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.CHANNELS, channel);
				#end
				#end
			}
		}
		#end
	}
}
