import flixel.addons.ui.FlxUISprite;
import flixel.util.FlxColor;
import openfl.display.Sprite;
import flixel.FlxSprite;

// JOELwindows7: hey, you gotta be do this!

/**
 * designed to draw a Open FL Sprite as a FlxSprite (to allow layering and auto sizing for haxe flixel cameras)
 * Custom made for Kade Engine
 */
class OFLSprite extends FlxUISprite
{
	public var flSprite:Sprite;

	public function new(x, y, width, height, Sprite:Sprite)
	{
		super(x, y);

		makeGraphic(width, height, FlxColor.TRANSPARENT);

		flSprite = Sprite;

		pixels.draw(flSprite);
	}

	private var _frameCount:Int = 0;

	override function update(elapsed:Float)
	{
		if (_frameCount != 2)
		{
			pixels.draw(flSprite);
			_frameCount++;
		}
	}

	public function updateDisplay()
	{
		pixels.draw(flSprite);
	}
}
