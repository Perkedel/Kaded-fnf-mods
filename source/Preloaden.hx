// JOELwindows7: same as Caching.hx, but for JavaScript (i.e. HTML5)
package;

import openfl.text.TextField;
import flixel.ui.FlxBar;
import flixel.system.FlxBasePreloader;
import openfl.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.Lib;
import flixel.FlxG;
import flixel.util.*;
import flixel.system.FlxAssets;

// @:bitmap("art/preloaderArt.png") class LogoImage extends BitmapData { }
// @:bitmap("art/LaunchImage.png") class LogoImage extends BitmapData { } //JOELwindows7: use this LFM launch image
// JOELwindows7: load up here boys & girls!
@:bitmap("assets/preload/images/KadeEngineLogo.png") class KadeEngineLogo extends BitmapData
{
}

@:bitmap("art/LFMicon128.png") class LFMIcon extends BitmapData
{
}

/**
 * Preloader for JavaScript version. similar as Caching.hx, but HTML5.
 */
class Preloaden extends FlxBasePreloader
{
	public function new(MinDisplayTime:Float = 3, ?AllowedURLs:Array<String>)
	{
		super(MinDisplayTime, AllowedURLs);
	}

	var buffer:Sprite;
	var logo:Sprite;
	var icon:Sprite;
	var bar:Bitmap;
	var text:TextField;

	override function create():Void
	{
		buffer = new Sprite();
		buffer.scaleX = buffer.scaleY = 2;
		addChild(buffer);
		this._width = Std.int(Lib.current.stage.stageWidth / buffer.scaleX);
		this._height = Std.int(Lib.current.stage.stageHeight / buffer.scaleY);

		var ratio:Float = this._width / 2560; // This allows us to scale assets depending on the size of the screen.
		var ratiu:Float = this._height / 8 * .04;

		logo = new Sprite();
		logo.addChild(new Bitmap(new KadeEngineLogo(0, 0))); // Sets the graphic of the sprite to a Bitmap object, which uses our embedded BitmapData class.
		logo.scaleX = logo.scaleY = ratio;
		logo.x = ((this._width - logo.width) / 2);
		logo.y = ((this._height - logo.height) / 2) - 50;
		buffer.addChild(logo); // Adds the graphic to the NMEPreloader's buffer.

		icon = new Sprite();
		icon.addChild(new Bitmap(new LFMIcon(0, 0)));
		icon.scaleX = icon.scaleY = ratio;
		icon.x = ((this._width - icon.width) / 2);
		icon.y = ((this._height - icon.height) / 2) + 100;
		buffer.addChild(icon);

		// bar = new FlxBar(10,this._height - 100,FlxBarFillDirection.LEFT_TO_RIGHT,this._width,40);
		// bar.color = FlxColor.PURPLE;
		bar = new Bitmap(new BitmapData(1, 7, false, 0x800080));
		bar.x = 4;
		bar.y = this._height - 11;
		buffer.addChild(bar);

		text = new TextField();
		text.defaultTextFormat = new TextFormat(FlxAssets.FONT_DEFAULT, 18, 0x5f6aff);
		text.embedFonts = true;
		text.selectable = false;
		text.multiline = false;
		text.width = 200;
		text.x = ((this._width / 2)) - 60;
		text.y = (this._height / 2) + 50;
		buffer.addChild(text);

		super.create();
	}

	override function destroy()
	{
		if (buffer != null)
		{
			removeChild(buffer);
		}
		buffer = null;
		logo = null;
		icon = null;
		bar = null;
		text = null;

		super.destroy();
	}

	override function update(Percent:Float):Void
	{
		// bar.value = Percent*100;
		bar.scaleX = Percent * (this._width - 8);
		logo.alpha = Percent;
		icon.alpha = Percent;
		text.alpha = Percent;
		text.text = "Loading " + Std.int(Percent * 100) + "%\n"; // idk wtf why it clipped
		// If it stop loading, refresh again!\n

		super.update(Percent);
	}

	// override function onUpdate(bytesLoaded:Int, bytseTotal:Int){
	//     //Size is not accurate in chrome.
	//     #if web
	//     #else
	//         super.onUpdate(bytesLoaded, bytseTotal);
	//     #end
	// }
}
