// JOELwindows7: yoink from https://github.com/kem0x/Nexus-Engine/blob/master/source/AttachedSprite.hx
package;

import flixel.addons.ui.FlxUISprite;
import flixel.FlxSprite;

using StringTools;

// JOELwindows7: FlxUI fy now

class AttachedSprite extends FlxUISprite
{
	public var sprTracker:FlxUISprite;
	public var xAdd:Float = 0;
	public var yAdd:Float = 0;
	public var angleAdd:Float = 0;
	public var alphaMult:Float = 1;

	public var copyAngle:Bool = true;
	public var copyAlpha:Bool = true;
	public var copyVisible:Bool = false;

	public function new(?file:String = null, ?anim:String = null, ?library:String = null, ?loop:Bool = false)
	{
		super();
		if (anim != null)
		{
			frames = Paths.getSparrowAtlas(file, library);
			animation.addByPrefix('idle', anim, 24, loop);
			animation.play('idle');
		}
		else if (file != null)
		{
			loadGraphic(Paths.image(file));
		}
		// antialiasing = ClientPrefs.globalAntialiasing;
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
		{
			setPosition(sprTracker.x + xAdd, sprTracker.y + yAdd);
			scrollFactor.set(sprTracker.scrollFactor.x, sprTracker.scrollFactor.y);

			if (copyAngle)
				angle = sprTracker.angle + angleAdd;

			if (copyAlpha)
				alpha = sprTracker.alpha * alphaMult;

			if (copyVisible)
				visible = sprTracker.visible;
		}
	}
}