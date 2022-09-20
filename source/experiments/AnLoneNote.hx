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

class AnLoneNote extends AbstractTestMenu
{
	override function create()
	{
		super.create();
		addInfoText("Lone Note\n\n\n");
		Debug.logInfo('test note');
		var thing = new Note(0, 0, null, false, true, null, null, 0);
		// thing.x = FlxG.width / 2;
		// thing.y = FlxG.height / 2;
		thing.screenCenter();
		add(thing);
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
