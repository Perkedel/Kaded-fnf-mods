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

// import behavior.audio.IManipulateAudio;
class AnNapoleonSaying extends AbstractTestMenu
{
	override function create()
	{
		super.create();
		addInfoText("Napolen Dialog Test\n\nENTER = Reset Napoleon\nUP or DOWN =");
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
			try
			{
				installSaying('Our unfinished plan has been leaked and now the enemy knows it all!!', 50, FlxG.height - 300);
			}
			catch (e)
			{
				Debug.logError('Napoleon faile: ${e}\n${e.details()}');
			}
		}
		else if (FlxG.keys.justPressed.UP || haveUpped)
		{
		}
		else if (FlxG.keys.justPressed.DOWN || haveDowned)
		{
		}
		else if (FlxG.keys.justPressed.R)
		{
		}

		// JOELwindows7: there you are, there's nothing we can do
	}
}
