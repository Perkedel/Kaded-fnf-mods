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

package ui;

import flixel.addons.transition.FlxTransitionableState;
import flixel.util.FlxColor;
import flixel.FlxState;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.Lib;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flixel.FlxG;
import flixel.FlxState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

/**
 * A splash screen for the application.
 * @author JOELwindows7
 */
class SplashScreen extends MusicBeatState
{
	// Inspire & yoink from that FlxSplash.hx!!!
	public static var nextState:FlxState = new TitleState();

	/**
	 * @since 4.8.0
	 */
	public static var muted:Bool = #if html5 true #else false #end;

	var _sprite:Sprite;
	var _gfx:Graphics;
	var _text:TextField;

	var _times:Array<Float>;
	var _colors:Array<Int>;
	var _functions:Array<Void->Void>;
	var _curPart:Int = 0;
	var _cachedBgColor:FlxColor;
	var _cachedTimestep:Bool;
	var _cachedAutoPause:Bool;

	public function new()
	{
		super();
	}

	override public function create():Void
	{
		super.create();

		transIn = FlxTransitionableState.defaultTransIn;

		// JOELwindows7: here init first!
		FlxG.autoPause = false;

		FlxG.save.bind('funkin', 'ninjamuffin99');

		PlayerSettings.init();

		KadeEngineData.initSave();

		_times = [0.041, 0.184, 0.334, 0.495, 0.636];
		_colors = [0x00b922, 0xffc132, 0xf5274e, 0x3641ff, 0x04cdfb];
		_functions = [drawGreen, drawYellow, drawRed, drawBlue, drawLightBlue];

		if (nextState != null)
			FlxG.switchState(nextState);
	}

	function drawGreen():Void
	{
		_gfx.beginFill(0x00b922);
		_gfx.moveTo(0, -37);
		_gfx.lineTo(1, -37);
		_gfx.lineTo(37, 0);
		_gfx.lineTo(37, 1);
		_gfx.lineTo(1, 37);
		_gfx.lineTo(0, 37);
		_gfx.lineTo(-37, 1);
		_gfx.lineTo(-37, 0);
		_gfx.lineTo(0, -37);
		_gfx.endFill();
	}

	function drawYellow():Void
	{
		_gfx.beginFill(0xffc132);
		_gfx.moveTo(-50, -50);
		_gfx.lineTo(-25, -50);
		_gfx.lineTo(0, -37);
		_gfx.lineTo(-37, 0);
		_gfx.lineTo(-50, -25);
		_gfx.lineTo(-50, -50);
		_gfx.endFill();
	}

	function drawRed():Void
	{
		_gfx.beginFill(0xf5274e);
		_gfx.moveTo(50, -50);
		_gfx.lineTo(25, -50);
		_gfx.lineTo(1, -37);
		_gfx.lineTo(37, 0);
		_gfx.lineTo(50, -25);
		_gfx.lineTo(50, -50);
		_gfx.endFill();
	}

	function drawBlue():Void
	{
		_gfx.beginFill(0x3641ff);
		_gfx.moveTo(-50, 50);
		_gfx.lineTo(-25, 50);
		_gfx.lineTo(0, 37);
		_gfx.lineTo(-37, 1);
		_gfx.lineTo(-50, 25);
		_gfx.lineTo(-50, 50);
		_gfx.endFill();
	}

	function drawLightBlue():Void
	{
		_gfx.beginFill(0x04cdfb);
		_gfx.moveTo(50, 50);
		_gfx.lineTo(25, 50);
		_gfx.lineTo(1, 37);
		_gfx.lineTo(37, 1);
		_gfx.lineTo(50, 25);
		_gfx.lineTo(50, 50);
		_gfx.endFill();
	}
}
