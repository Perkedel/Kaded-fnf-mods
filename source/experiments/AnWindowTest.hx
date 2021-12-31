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

import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUITypedButton;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxUIPopup;
import flixel.system.debug.Window;

class AnWindowTest extends AbstractTestMenu
{
	var windowme:Window;
	var popupo:FlxUIPopup;

	public function new()
	{
		super();
	}

	override function create()
	{
		super.create();
		addInfoText("Window\n\n");

		windowme = new Window("anWindow", null, 270, 120, true);
		// add(windowme);
		popupo = new FlxUIPopup(FlxColor.TRANSPARENT);
		// popupo.alpha = 0;
		popupo.quickSetup("Nog een popup", "Dit is een popup", ["OK", "Cancel"]);
		// popupo.btn0.onClick = function() {
		//     closeSubState();
		// }
		// add(popupo);
	}

	override function update(elapsed)
	{
		if (FlxG.keys.justPressed.ENTER || haveClicked)
		{
			// popupo.alpha = 1;
			openSubState(popupo);
			haveClicked = false;
		}
		if (FlxG.keys.justPressed.LEFT || haveLefted)
		{
			haveLefted = false;
		}
		else if (FlxG.keys.justPressed.RIGHT || haveRighted)
		{
			haveRighted = false;
		}
		else if (FlxG.keys.justPressed.UP || haveUpped)
		{
			haveUpped = false;
		}
		else if (FlxG.keys.justPressed.DOWN || haveDowned)
		{
			haveDowned = false;
		}
		else if (FlxG.keys.justPressed.R)
		{
			windowme.visible = !windowme.visible;
		}

		super.update(elapsed);
	}

	// JOELwindows7: well the getEvent thingy like everybody that uses FlxUI value input stuff.
	override public function getEvent(name:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void
	{
		// JOELwindows7: inspire from ChartingState.hx & FlxSound demo Flixel yess.
		// https://github.com/HaxeFlixel/flixel-demos/blob/master/Features/FlxSound/source/MenuState.hx

		if (destroyed)
		{
			return;
		}

		super.getEvent(name, sender, data, params);

		if (name == FlxUITypedButton.CLICK_EVENT && (sender is FlxUIButton))
		{
			var fuib:FlxUIButton = cast sender;
			var label = fuib.label.text;
			switch (label)
			{
				case "OK":
					closeSubState();
				case "Cancel":
					closeSubState();
				default:
			}
		}
		// else if (name == FlxButton.CLICK_EVENT && (sender is FlxButton))
		// {
		//     var fub:FlxButton = cast sender;
		//     var label = fub.label.text;
		//     switch (label)
		//     {
		//         case "OK":
		//             closeSubState();
		//         case "Cancel":
		//             closeSubState();
		//         default:
		//     }
		// }
	}
}
