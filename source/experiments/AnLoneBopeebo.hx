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

class AnLoneBopeebo extends AbstractTestMenu implements IManipulateAudio
{
	var rate:Float = 1;
	var channel:Float = 0;

	override function create()
	{
		super.create();
		addInfoText("Bopeebo Inst Test\n\nENTER = Play Bopeebo from Song folder\nUP or DOWN = Change Rate");
		// var thing = new Note(0, 0, null, false);
		// thing.x = FlxG.width / 2;
		// thing.y = FlxG.height / 2;
		// add(thing);
	}

	override function update(elapsed)
	{
		super.update(elapsed);
		if (FlxG.keys.justPressed.ENTER || haveClicked)
		{
			Conductor.changeBPM(100);
			FlxG.sound.playMusic(Paths.inst("bopeebo"), 1, false);
			haveClicked = false;
			MainMenuState.freakyPlaying = false;
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
		manipulateTheAudio();
	}

	function manipulateTheAudio()
	{
		#if FEATURE_AUDIO_MANIPULATE
		@:privateAccess
		{
			#if (flixel >= "5.4.0")
			if (FlxG.sound.music != null)
				if (FlxG.sound.music.playing)
					FlxG.sound.music.set_pitch(rate);
			#else
			// if (FlxG.sound.music.playing)
			// {
			// 	lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, rate);
			// 	// lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.CHANNELS, channel);
			// }
			#if cpp
			#if (lime >= "8.0.0")
			if (FlxG.sound.music != null)
				if (FlxG.sound.music.playing)
					FlxG.sound.music._channel.__source.__backend.setPitch(rate);
			// FlxG.sound.music._channel.__source.set_pitch(rate);
			#else
			if (FlxG.sound.music != null)
				if (FlxG.sound.music.playing)
					lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, rate);
			#end
			#elseif web
			#if (lime >= "8.0.0" && lime_howlerjs)
			if (FlxG.sound.music != null)
				if (FlxG.sound.music.playing)
					FlxG.sound.music._channel.__source.__backend.setPitch(rate);
			#else
			if (FlxG.sound.music != null)
				if (FlxG.sound.music.playing)
					FlxG.sound.music._channel.__source.__backend.parent.buffer.__srcHowl.rate(rate);
			#end
			#end
			#end
		}
		#end
	}
}
