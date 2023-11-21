/*
 * GNU General Public License, Version 3.0
 *
 * Copyright (c) 2023 Perkedel
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

package plugins.sprites;

import openfl.display.Bitmap;
import openfl.display.Sprite;
import flixel.FlxBasic;
import openfl.display.BitmapData;

@:bitmap("art/PerkedelLogo/Perkedel Logo Typeborder.png") class WatermarkLogo extends BitmapData
{
}

/**
 * A class that does nothing. Or is it?
 * used as a HaxeFlixel plugin!
 * 
 * @author JOELwindows7
 */
class Donse extends FlxBasic
{
	// inspire and yoink screenshot plugin
	private static var initialized:Bool = false; // ensure this is the only one existed
	public static var instance:FlxBasic;

	private var container:Sprite; // contain our stuffs in here!
	private var pressWatermarkSprite:Sprite; // Perkedel logo DVD corner
	private var pressWatermarkImage:Bitmap; // and the image inside it.

	override public function new()
	{
		super();
		if (initialized)
		{
			// if already exist then go away, until the next launch
			FlxG.plugins.remove(this);
			destroy();
			return;
		}
		instance = this; // add self!
		initialized = true; // okay good? let's go.
		container = new Sprite();
		// FlxG.stage.addChild(container); // wait! you don't do this.
		FlxG.addChildBelowMouse(container); // instead you put it UNDERNEATH the mouse, like is with the debugger. This should prevent the debugger from being unclickable.

		// now the rest is up to us.
		// an watermark will ya?
		pressWatermarkSprite = new Sprite();
		container.addChild(pressWatermarkSprite);

		// Oh, don't forget
		@:privateAccess openfl.Lib.application.window.onResize.add((w, h) -> {
			// window resize signals!!
			// flashBitmap.bitmapData = new BitmapData(w, h, true, 0xFFFFFFFF);
			// outlineBitmap.bitmapData = new BitmapData(Std.int(w / 5) + 10, Std.int(h / 5) + 10, true, 0xffffffff);
		});
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (watermarkInstalled)
		{
			// DVD corner will ya?
		}
	}

	var watermarkInstalled:Bool = false;

	public function installWatermark():Void
	{
		pressWatermarkImage = new Bitmap(new WatermarkLogo(0, 0));

		if (!watermarkInstalled)
		{
			pressWatermarkSprite.addChild(pressWatermarkImage);
			watermarkInstalled = true;
		}
	}

	public function removeWatermark():Void
	{
		if (watermarkInstalled)
		{
			if (pressWatermarkImage != null)
				pressWatermarkSprite.removeChild(pressWatermarkImage);
			watermarkInstalled = false;
		}
	}
}
