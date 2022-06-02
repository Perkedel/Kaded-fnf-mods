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
package ui.states.debug;

import flixel.util.FlxColor;
import haxe.Exception;
import clipboard.Clipboard;
import flixel.text.FlxText;

// CrashHandler class
class WerrorForceMajeurState extends CoreState
{
	// inspired from ddlc mod and old minecraft crash handler
	// can someone explain to me why some people use external exes for crash handlers? it's fucking dumb
	var exception:Exception;
	var gf:Character;

	public function new(exc:Exception)
	{
		super();

		exception = exc;
	}

	override function create()
	{
		trace(exception);

		super.create();

		// var bg = new Background(FlxColor.fromString("#696969"));
		// bg.scrollFactor.set(0, 0);
		// add(bg);

		var bottomText = new FlxText(0, 0, 0, "C to copy exception | ESC to send to menu");
		bottomText.scrollFactor.set(0, 0);
		bottomText.setFormat(Paths.font("vcr.ttf"), 12, FlxColor.WHITE);
		bottomText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1);
		bottomText.screenCenter(X);
		bottomText.y = FlxG.height - bottomText.height - 10;
		add(bottomText);

		var exceptionText = new FlxText();
		exceptionText.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE);
		exceptionText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1);
		exceptionText.text = "Game has encountered a Exception!";
		exceptionText.color = FlxColor.RED;
		exceptionText.screenCenter(X);
		exceptionText.y += 20;
		// add(exceptionText);

		var crashShit = new FlxText();
		crashShit.setFormat(Paths.font("vcr.ttf"), 15, FlxColor.WHITE);
		crashShit.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1);
		crashShit.text = exception.details();
		crashShit.screenCenter(X);
		crashShit.y += exceptionText.y + exceptionText.height + 20;
		add(crashShit);

		gf = new Character(0, 0, "gf", false);
		gf.scrollFactor.set(0, 0);
		gf.animation.play("sad");
		add(gf);

		gf.setGraphicSize(Std.int(gf.frameWidth * 0.3));
		gf.updateHitbox();
		gf.x = FlxG.width - gf.width;
		gf.y = FlxG.height - gf.height;

		setSectionTitle('WERROR: ${exception.toString()}');

		addBackButton(); // JOELwindows7: back button pls.
		// addLeftButton(Std.int(bottomText.x + bottomText.width + 10), FlxG.height - 100);
		// addAcceptButton(Std.int(gf.x - 300), FlxG.height - 100);
		// addAcceptButton(Std.int(leftButton.x + leftButton.width + 100), FlxG.height - 100);
		// addRightButton(Std.int(acceptButton.x + acceptButton.width + 100), FlxG.height - 100);
		addRightButton(Std.int(gf.x - 300), FlxG.height - 100);
		addAcceptButton(Std.int(rightButton.x - 300), FlxG.height - 100);
		addLeftButton(Std.int(acceptButton.x - 300), FlxG.height - 100);
		addUpButton();
		addDownButton();
	}

	override function update(elapsed)
	{
		if (FlxG.keys.justPressed.C || haveClicked)
		{
			Clipboard.set(exception.details());
			haveClicked = false; // JOELwindows7: press OK button.
		}

		if (controls.BACK || FlxG.keys.justPressed.ESCAPE || haveBacked)
		{
			FlxG.switchState(new MainMenuState());
			Game.resetCrashWire(); // JOELwindows7: restore tripwire.
			haveBacked = false; // JOELwindows7: pressed back reset wire
		}

		if (FlxG.mouse.wheel == -1 || haveDowned)
		{
			if (FlxG.keys.pressed.CONTROL)
				FlxG.camera.zoom += 0.02;
			if (FlxG.keys.pressed.SHIFT)
				FlxG.camera.scroll.x += 20;
			if (!FlxG.keys.pressed.SHIFT && !FlxG.keys.pressed.CONTROL)
				FlxG.camera.scroll.y += 20;
			haveDowned = false;
		}
		if (FlxG.mouse.wheel == 1 || haveUpped)
		{
			if (FlxG.keys.pressed.CONTROL)
				FlxG.camera.zoom -= 0.02;
			if (FlxG.keys.pressed.SHIFT)
			{
				if (FlxG.camera.scroll.x > 0)
					FlxG.camera.scroll.x -= 20;
			}
			if (!FlxG.keys.pressed.SHIFT && !FlxG.keys.pressed.CONTROL)
			{
				if (FlxG.camera.scroll.y > 0)
					FlxG.camera.scroll.y -= 20;
			}
			haveUpped = false;
		}
		// JOELwindows7: more buttonez
		if (haveLefted)
		{
			if (FlxG.camera.scroll.x > 0)
				FlxG.camera.scroll.x -= 20;
			haveLefted = false;
		}
		if (haveRighted)
		{
			FlxG.camera.scroll.x += 20;
			haveRighted = false;
		}
	}

	// JOELwindows7: joypadding
	override function manageJoypad()
	{
		super.manageJoypad();
		if (joypadLastActive != null)
		{
			if (joypadLastActive.justPressed.DPAD_UP)
			{
			}
			if (joypadLastActive.justPressed.DPAD_DOWN)
			{
			}
			if (joypadLastActive.justPressed.DPAD_LEFT)
			{
			}
			if (joypadLastActive.justPressed.DPAD_RIGHT)
			{
			}
			if (joypadLastActive.justPressed.A)
			{
				Clipboard.set(exception.details());
			}
			if (joypadLastActive.pressed.RIGHT_STICK_DIGITAL_UP)
			{
				if (FlxG.camera.scroll.y > 0)
					FlxG.camera.scroll.y -= 20;
			}
			if (joypadLastActive.pressed.RIGHT_STICK_DIGITAL_DOWN)
			{
				FlxG.camera.scroll.y += 20;
			}
			if (joypadLastActive.pressed.RIGHT_STICK_DIGITAL_LEFT)
			{
				if (FlxG.camera.scroll.x > 0)
					FlxG.camera.scroll.x -= 20;
			}
			if (joypadLastActive.pressed.RIGHT_STICK_DIGITAL_RIGHT)
			{
				FlxG.camera.scroll.x += 20;
			}
		}
	}
}
