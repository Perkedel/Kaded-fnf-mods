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

package plugins.sprites;

import CoreState.ExtraLoadingType;
import flixel.util.FlxTimer;
import openfl.display.Bitmap;
import flixel.FlxG;
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.display.Sprite;
import openfl.Lib;

class LoadingBar extends Sprite
{
	var infoTextThing:TextField;

	public var bitmap:Bitmap; // JOELwindows7: just like KadeEngineFPS, to make it uh idk. Bitmap instance to that main.

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		// JOELwindows7: inspire from that KadeEngineFPS
		super();
		// JOELwindows7: steal from TentaRJ's gamejolt toast
		FlxG.signals.gameResized.add(onWindowResized);

		mouseEnabled = false;
		width = FlxG.width - 15;
        height = 250;
		this.x = x;
		this.y = y;
		buildThing();
		// JOELwindows7: Now put this as bitmap to be placed into main. Just like KadeEngineFPS.
		// bitmap = ImageOutline.renderImage(this, 1, 0x000000, 1, true);
		// (cast(Lib.current.getChildAt(0), Main)).addChild(bitmap);
	}

	function buildThing()
	{
		infoTextThing = new TextField();
		infoTextThing.selectable = false;
		infoTextThing.mouseEnabled = false;
		infoTextThing.defaultTextFormat = new TextFormat(openfl.utils.Assets.getFont("assets/fonts/vcr.ttf").fontName, 24, 0xFFFFFF);
		infoTextThing.text = "Loading...";
		infoTextThing.width += 200;
		infoTextThing.x += 15;
		addChild(infoTextThing);
	}

	// JOELwindows7: Event Handlers, take from that KadeEngineFPS too.
	@:noCompletion
	private #if !flash override #end function __enterFrame(deltaTime:Float):Void
	{
		// JOELwindows7: rest of the stuff there is to it.
		// visible = true;

		// Main.instance.removeChild(bitmap);

		// bitmap = ImageOutline.renderImage(this, 2, 0x000000, 1);

		// Main.instance.addChild(bitmap);

		// visible = false;
	}

	// JOELwindows7: more event handlers. steal from TentaRJ's gamejolt toast popup.
	public function onWindowResized(x:Int, y:Int):Void
	{
		for (i in 0...numChildren)
		{
			var child = getChildAt(i);
			child.x = Lib.current.stage.stageWidth - child.width;
		}
	}

	public function setInfoText(text:String)
	{
		infoTextThing.text = text;
		KadeEngineFPS.setLoadingText(text);
	}

	public function setPercentage(howMuch:Float)
	{
		KadeEngineFPS.setLoadingPercentage(howMuch);
	}

	public function setLoadingType(typeDo:ExtraLoadingType)
	{
		KadeEngineFPS.setLoadingType(typeDo);
	}

	public function popNow()
	{
		visible = true;
		// bitmap.visible = true;
		KadeEngineFPS.setLoadingTextVisibility(true);
	}

	public function unPopNow()
	{
		visible = false;
		// bitmap.visible = false;
		KadeEngineFPS.setLoadingTextVisibility(false);
	}

	public function delayedUnPopNow(inHowLong:Float)
	{
		new FlxTimer().start(inHowLong, function(tmr:FlxTimer)
		{
			unPopNow();
		});
	}
}
