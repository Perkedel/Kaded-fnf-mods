// JOELwindows7: yoink from https://github.com/ShadowMario/FNF-PsychEngine/blob/main/source/BGSprite.hx
// okeh idk man.
package;

import flixel.addons.ui.FlxUISprite;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

// JOELwindows7: FlxUI fy carefully

class BGSprite extends FlxUISprite
{
	private var idleAnim:String;

	public function new(image:String, x:Float = 0, y:Float = 0, ?scrollX:Float = 1, ?scrollY:Float = 1, ?animArray:Array<String> = null, ?loop:Bool = false)
	{
		super(x, y);

		if (animArray != null)
		{
			frames = Paths.getSparrowAtlas(image);
			for (i in 0...animArray.length)
			{
				var anim:String = animArray[i];
				animation.addByPrefix(anim, anim, 24, loop);
				if (idleAnim == null)
				{
					idleAnim = anim;
					animation.play(anim);
				}
			}
		}
		else
		{
			if (image != null)
			{
				loadGraphic(Paths.image(image));
			}
			active = false;
		}
		scrollFactor.set(scrollX, scrollY);
		antialiasing = FlxG.save.data.antialiasing;
	}

	public function dance(?forceplay:Bool = false)
	{
		if (idleAnim != null)
		{
			animation.play(idleAnim, forceplay);
		}
	}
}
