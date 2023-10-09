/*
 * GNU General Public License, Version 3.0
 *
 * Copyright (c) 2022 Perkedel
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

// JOELwindows7: yoink from https://github.com/Paidyy/Funkin-PEngine/blob/main/source/Main.hx
// WARNING: original license from that fork unchanged, assume parent's: Apache-2.0. only change I made is GNU GPL v3, pls help! I am not legal expert, it's too complicated & too political!!!
// btw, coding has been oversaturated with politics for the license part of it. license itself is politic, idk.. coz it has view! side a b c d e f g
package;

import ui.states.debug.WerrorForceMajeurState;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.VarTween;
import flixel.system.FlxSound;
import flixel.FlxGame;
#if air
import flash.desktop.NativeApplication;
#end
#if ((js && html5) || electron)
import js.html.Element;
import js.Browser;
#end
#if sys
import sys.io.Process;
#end

// Core of all things
class Game extends FlxGame
{
	public static var pauseMusic:FlxSound;
	public static var pauseMusicTween:VarTween;
	public static var pauseFadingOut:Bool = false;

	static var hasCrashed:Bool = false;

	override public function update()
	{
		if (pauseMusic != null)
		{
			if (pauseMusic.playing)
			{
				// if (pauseMusicTween != null) // JOELwindows7: don't forget the safety!!!
				// 	pauseMusicTween.active = true;
				if (pauseFadingOut)
				{
					if (pauseMusic.volume > 0)
						pauseMusic.volume -= .5 * FlxG.elapsed;
					else
					{
						stopPauseMusic();
					}
				}
				else
				{
					if (pauseMusic.volume < 0.5)
						pauseMusic.volume += 0.01 * FlxG.elapsed;
				}
			}
		}

		if (!Perkedel.ENGINE_CORE_HANDLE_CRASH)
		{
			super.update();
		}
		else
		{
			try
			{
				super.update();
			}
			catch (exc)
			{
				// JOELwindows7: first, here things to do with crash.
				if (!hasCrashed)
				{
					hasCrashed = true; // redundancy to make sure it indeed tripped & doesn't loop before these finished.
					Debug.displayAlert('Fatal WError: ${exc.message}', 'The game has crashed. Oh peck!!!\n\n ${exc.message}:\n${exc.details()}');
					Debug.logError('Fatal Werror: ${exc.message}\n${exc.details()}');
					stopPauseMusic();

					// JOELwindows7: it's notify send time!
					try
					{
						#if linux
						Sys.command('/usr/bin/notify-send', [
							'-u critical',
							'-t 0',
							'-a \'${Perkedel.ENGINE_NAME} v${Perkedel.ENGINE_VERSION}\'',
							'Fatal WError: ${exc.message}',
							'The game has crashed. Oh peck!!!\n\n${exc.details()}'
						]);
						#elseif web
						// use https://www.w3schools.com/js/js_popup.asp
						Browser.alert('Fatal WError: ${exc.message}\n\nThe game has crashed. Oh peck!!!\n\n ${exc.message}:\n${exc.details()}');
						#else
						Debug.logTrace('no notification command available, sadd');
						#end

						// To Windows:
						// - https://stackoverflow.com/questions/47115811/how-to-keep-powershell-notification-in-action-center/47123275#47123275
						// - https://superuser.com/a/1523925/1036816
						// - https://stackoverflow.com/questions/39535937/what-is-the-notify-send-equivalent-for-windows
					}
					catch (wer)
					{
						Debug.logTrace('& I can\'t even send notification wtf?! ${wer.message}\n${wer.details()}');
					}

					FlxG.switchState(new WerrorForceMajeurState(exc));
					hasCrashed = true;
				}
			}
		}
	}

	public static function playPauseMusic()
	{
		pauseFadingOut = false;
		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		Debug.logInfo('Volume 0');
		pauseMusic.volume = 0;
		Debug.logInfo('Volume 0 done');
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
		pauseMusic.ID = 9000; // JOELwindows7: don't forget ID it like usual original Kade.
		FlxG.sound.list.add(pauseMusic);

		// pauseMusicTween = FlxTween.tween(pauseMusic, {volume: 0.9}, 15);
		Debug.logInfo('Pause Music Now Playing');
	}

	public static function stopPauseMusic()
	{
		if (pauseMusicTween != null)
		{
			pauseMusicTween.cancel();
		}
		if (pauseMusic != null)
		{
			pauseMusic.stop();
			// pauseMusic.destroy();
		}
	}

	public static function fadePauseMusic()
	{
		Debug.logTrace('Fade Unpause music now');
		if (pauseMusicTween != null)
		{
			pauseMusicTween.cancel();
		}
		if (pauseMusic != null)
		{
			// pauseMusicTween = FlxTween.tween(pauseMusic, {volume: 0}, 1, {
			// 	onComplete: function(twn:FlxTween)
			// 	{
			// 		stopPauseMusic();
			// 	}
			// });
			pauseFadingOut = true;
		}
	}

	// JOELwindows7: reset tripwire
	public static function resetCrashWire()
	{
		hasCrashed = false;
	}
}
