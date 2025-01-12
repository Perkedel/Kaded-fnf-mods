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

import flixel.addons.ui.FlxUISprite;
import flixel.addons.ui.FlxUIText;
import flixel.FlxState;
import flixel.addons.plugin.screengrab.FlxScreenGrab;
import flixel.addons.display.FlxStarField;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.text.FlxText;

// import extension.android.*;
class AbstractTestMenu extends MusicBeatState
{
	public var infoText:FlxUIText;
	public var wouldGoBackToStateOf:FlxState = new MainMenuState();
	public var needsSpeciallyLoad:Bool = false;

	override function create()
	{
		super.create();

		// JOELwindows7: BG BG BG BG BOLO
		var bg:FlxUISprite = new FlxUISprite();
		// bg.loadGraphic(Paths.imageGraphic('MenuBGDesatAlt'));
		bg.loadGraphic(Paths.loadImage('MenuBGDesatAlt'));
		bg.scrollFactor.set();
		bg.color = 0xFF111111;
		add(bg);

		infoText = new FlxUIText();
		infoText.text = "ESCAPE = Go back\n" + "";
		infoText.size = 32;
		infoText.screenCenter(X);
		infoText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(infoText);

		addBackButton(100, FlxG.height - 128);
		addLeftButton();
		addRightButton();
		addAcceptButton();
	}

	function addInfoText(text:String)
	{
		var wext = text;
		wext = wext + "\n" + "ESCAPE = Go back\n";
		infoText.text = wext;
		infoText.y = 0;
		infoText.screenCenter(X);
	}

	override function update(elapsed)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ESCAPE || haveBacked)
		{
			// FlxG.switchState(wouldGoBackToStateOf);
			switchState(wouldGoBackToStateOf, needsSpeciallyLoad, needsSpeciallyLoad, needsSpeciallyLoad);
			haveBacked = false;
		}
		if (FlxG.keys.justPressed.ENTER || haveClicked)
		{
			haveClicked = false;
		}
		if (FlxG.keys.justPressed.V)
		{
			#if !js
			FlxScreenGrab.grab(false, false);
			#end
		}
	}

	override function manageMouse()
	{
		super.manageMouse();
		if (FlxG.mouse.overlaps(backButton))
		{
			if (FlxG.mouse.justPressed)
			{
				haveBacked = true;
			}
		}
		if (FlxG.mouse.overlaps(acceptButton))
		{
			if (FlxG.mouse.justPressed)
			{
				haveClicked = true;
			}
		}
	}
}
