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

// yoink from https://github.com/Paidyy/Funkin-PEngine/blob/main/source/Main.hx
package;

import ui.states.debug.WerrorForceMajeurState;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.VarTween;
import flixel.system.FlxSound;
import flixel.FlxGame;

// Core of all things
class Game extends FlxGame
{
	public static var pauseMusic:FlxSound;
	public static var pauseMusicTween:VarTween;

	override public function update()
	{
		if (pauseMusic != null)
		{
			if (pauseMusic.playing)
			{
				pauseMusicTween.active = true;
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
				Debug.displayAlert('Fatal WError: ${exc.message}', 'The game has crashed. Oh peck!!!\n\n ${exc.message}:\n${exc.details()}');
				FlxG.switchState(new WerrorForceMajeurState(exc));
			}
		}
	}

	public static function playPauseMusic()
	{
		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
		pauseMusic.ID = 9000; // JOELwindows7: don't forget ID it like usual original Kade.
		FlxG.sound.list.add(pauseMusic);

		pauseMusicTween = FlxTween.tween(pauseMusic, {volume: 0.9}, 15);
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
		}
	}
}
