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

package experiments;

import flixel.addons.ui.FlxUISprite;

class AnLoneNote extends AbstractTestMenu
{
	override function create()
	{
		super.create();
		addInfoText("Lone Note\n\n\nHow does your chosen Noteskin looks like.");
		Debug.logInfo('test note');
		for (h in -1...5)
		{
			for (i in 0...4)
			{
				var thing = new Note(0, i, null, false, true, null, null, h);
				// var thing = new FlxUISprite();
				// thing.frames = NoteskinHelpers.generateNoteskinSprite(FlxG.save.data.noteskin, 0);
				// thing.x = FlxG.width / 2;
				// thing.y = FlxG.height / 2;
				// thing.screenCenter();
				// thing.screenCenter(Y);
				thing.y = (75 + 100 * h); // / (FlxG.height);
				thing.x = (75 + 100 * i); // / (FlxG.width);
				add(thing);
			}
		}
		Debug.logInfo('test receptor');
		for (i in 0...3)
		{
			var thing = new Note(0, i, null, false, true, null, null, 0);
			var thing = new FlxUISprite();
			// thing.frames = NoteskinHelpers.generateNoteskinSprite(FlxG.save.data.noteskin, 0);
			// thing.x = FlxG.width / 2;
			// thing.y = FlxG.height / 2;
			// thing.screenCenter();
			// thing.screenCenter(Y);
			// thing.y = (25 + 10 * h) / (FlxG.height);
			// thing.x = (50 + 25 * i) / (FlxG.width);
			// add(thing);
		}

		Debug.logInfo('ayy');
	}

	override function update(elapsed)
	{
		super.update(elapsed);
		if (FlxG.keys.justPressed.ENTER || haveClicked)
		{
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
	}
}
