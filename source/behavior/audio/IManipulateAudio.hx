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

package behavior.audio;

/**
	Interface to remind you to add something that manipulates the audio.
	e.g. in `FreePlayState.hx` here the code sample.
	basically, this is to trigger manipulation of the audio pitch & stuffs.
	recommended to do this every update, well `update(elapsed:Float)` function thingy. idk..
	```haxe
	// JOELwindows7: Okay, here's the new hack audio with BOLO's figure outs!
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
				FlxG.sound.music._channel.__source.__backend.setPitch(rate);
				#else
				lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, rate);
				#end
				#end
			}
		}
		#end
	}
	```
	@see https://github.com/BoloVEVO/Kade-Engine-Public/blob/stable/source/FreeplayState.hx
	@author JOELwindows7
**/
interface IManipulateAudio
{
	private function manipulateTheAudio():Void;
}
