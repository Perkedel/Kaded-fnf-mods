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

@:bitmap("art/KE_HTML5_BG.png") class DaConsoleBG extends BitmapData
{
}

/**
 * Add a background behind the FlxGame to create sensation of Console release such as Toby Fox Undertale & Deltarune on consoles
 * Install BEFORE adding the FlxGame itself!
 * 
 * @author JOELwindows7
 */
class PlayStationBackground extends Sprite
{
	// inspire and yoink screenshot plugin
	private static var initialized:Bool = false; // ensure this is the only one existed
	public static var instance:Sprite;

	private var container:Sprite; // contain our stuffs in here!
	private var consoleBGSprite:Sprite; // Perkedel logo DVD corner
	private var consoleBGBitmap:Bitmap; // and the image inside it.

	override public function new()
	{
		super();
		if (initialized)
		{
			// if already exist then go away, until the next launch

			return;
		}
		instance = this; // add self!
		initialized = true; // okay good? let's go.
		container = new Sprite();
		addChild(container); // Just sprite, so add it up!

		// pls install PlayStation bg
		consoleBGSprite = new Sprite();
		consoleBGBitmap = new Bitmap(new DaConsoleBG(0, 0));
		consoleBGSprite.addChild(consoleBGBitmap);
		container.addChild(consoleBGSprite);

		@:privateAccess openfl.Lib.application.window.onResize.add((w, h) -> {
			// window resize signals!!
			// flashBitmap.bitmapData = new BitmapData(w, h, true, 0xFFFFFFFF);
			// outlineBitmap.bitmapData = new BitmapData(Std.int(w / 5) + 10, Std.int(h / 5) + 10, true, 0xffffffff);
		});
	}
}
