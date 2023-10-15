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

import flixel.addons.ui.FlxUIText;
import flixel.util.FlxColor;
import haxe.Exception;
#if FEATURE_CLIPBOARD
import clipboard.Clipboard;
#end
import flixel.text.FlxText;
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
#if sys
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
#end
import lime.app.Application;

// CrashHandler class
class WerrorForceMajeurState extends CoreState
{
	// inspired from ddlc mod and old minecraft crash handler
	// can someone explain to me why some people use external exes for crash handlers? it's fucking dumb
	// JOELwindows7: change to FlxUI things
	var exception:Exception;
	var gf:Character;

	public function new(exc:Exception)
	{
		super();

		exception = exc;

		// JOELwindows7: finally, write the error log like BOLO had here
		writeErrorLog(exception, 'SEMI-FATAL WhewCaught WError', 'SemiCaught');
	}

	override function create()
	{
		trace(exception);

		super.create();

		// var bg = new Background(FlxColor.fromString("#696969"));
		// bg.scrollFactor.set(0, 0);
		// add(bg);

		// TODO: add gameover 8 bit sound

		var bottomText = new FlxUIText(0, 0, 0, "C to copy exception | ESC to send to menu");
		bottomText.scrollFactor.set(0, 0);
		bottomText.setFormat(Paths.font("vcr.ttf"), 12, FlxColor.WHITE);
		bottomText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1);
		bottomText.screenCenter(X);
		bottomText.y = FlxG.height - bottomText.height - 10;
		add(bottomText);

		var exceptionText = new FlxUIText();
		exceptionText.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE);
		exceptionText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1);
		exceptionText.text = "Game has encountered a Exception!";
		exceptionText.color = FlxColor.RED;
		exceptionText.screenCenter(X);
		exceptionText.y += 20;
		// add(exceptionText);

		var crashShit = new FlxUIText();
		crashShit.setFormat(Paths.font("vcr.ttf"), 15, FlxColor.WHITE);
		crashShit.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1);
		crashShit.text = exception.details();
		crashShit.screenCenter(X);
		crashShit.y += exceptionText.y + exceptionText.height + 20;
		add(crashShit);

		gf = new Character(0, 0, "gf", false);
		gf.scrollFactor.set(0, 0);
		// gf.animation.play("sad");
		gf.playAnim('sad', true); // JOELwindows7: bruh! there's looper
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
		addRightButton(Std.int(gf.x - 150), FlxG.height - 100);
		addAcceptButton(Std.int(rightButton.x - 150), FlxG.height - 100);
		addLeftButton(Std.int(acceptButton.x - 150), FlxG.height - 100);
		addUpButton();
		addDownButton();
	}

	override function update(elapsed)
	{
		if (FlxG.keys.justPressed.C || haveClicked)
		{
			#if FEATURE_CLIPBOARD
			Clipboard.set(exception.details());
			#end
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
				#if FEATURE_CLIPBOARD
				Clipboard.set(exception.details());
				#end
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

	// Copy from BOLO's onCrash
	public static function writeErrorLog(exc:Exception, errorTitle:String = 'FATAL UnCaught WError', errorDiffFileName:String = 'Uncaught',
			withWindowAlert:Bool = true)
	{
		var errMsg:String = "";
		var errHdr:String = ""; // da header
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();
		var firmwareName:String = Perkedel.ENGINE_ID;

		dateNow = StringTools.replace(dateNow, " ", "_");
		dateNow = StringTools.replace(dateNow, ":", "-");
		// firmwareName = StringTools.replace(firmwareName, "-", "");

		// path = "./crash/" + "KadeEngine_" + dateNow + "_SemiCaught.txt";
		path = './crash/${firmwareName}_${dateNow}_${errorDiffFileName}.txt';

		#if sys
		path = '${Sys.getCwd()}/crash/${firmwareName}_${dateNow}_${errorDiffFileName}.txt';
		#end

		path = Path.normalize(path);

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					#if sys
					Sys.println(stackItem);
					#else
					trace(stackItem);
					#end
			}
		}

		errHdr += '```\n' + '${Perkedel.CRASH_TEXT_BANNER}' + '\n```\n';
		errMsg += '# ${errorTitle}: `$exc`\n'
			+ '\n```\n'
			+ '${exc.details()}'
			+ '\n```\n'
			+ '# Firmware name & version:\n'
			+ '${Perkedel.ENGINE_NAME} v${Perkedel.ENGINE_VERSION}\n\n'
			+ '# Please report this error to our Github page:\n ${Perkedel.ENGINE_BUGREPORT_URL}\n\n> Crash Handler written by: Paidyy, sqirra-rng';

		try
		{
			var checkCrashFolderPath:String;
			#if sys
			checkCrashFolderPath = '${Sys.getCwd()}crash/';
			#else
			checkCrashFolderPath = './crash';
			#end
			checkCrashFolderPath = Path.normalize(checkCrashFolderPath);

			#if FEATURE_FILESYSTEM
			// if (!FileSystem.exists("./crash/"))
			// 	FileSystem.createDirectory("./crash/");
			if (!FileSystem.exists(checkCrashFolderPath))
				FileSystem.createDirectory(checkCrashFolderPath);

			File.saveContent(path, errHdr + errMsg + "\n");
			#end

			#if sys
			Sys.println('===============');
			Sys.println(errHdr + errMsg);
			Sys.println('===============');
			Sys.println("Crash dump saved in " + Path.normalize(path));
			#else
			trace(errHdr + errMsg);
			trace('error');
			#end
		}
		catch (e)
		{
			#if sys
			Sys.println('AAAAAAAAAAAAAARGH!!! PECK NECK!!! FILE WRITING PECKING FAILED!!! when wanted to write to ${path}\n\n$e:\n\ne${e.details()}');
			Sys.println('Anyway pls detail!:\n===============');
			Sys.println(errHdr + errMsg);
			Sys.println('================\nThere, clipboard pls');
			#else
			trace('AAAAAAAAAAAAAARGH!!! PECK NECK!!! FILE WRITING PECKING FAILED!!! when wanted to write to ${path}\n\n$e:\n\ne${e.details()}');
			trace('Anyway pls detail!:\n===============');
			trace(errHdr + errMsg);
			trace('================\nThere, clipboard pls');
			#end
		}
		if (withWindowAlert)
			Application.current.window.alert(errMsg, "Error!");
	}
}
