package;

import LuaClass;
import flixel.addons.ui.FlxUISprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

// JOELwindows7: change the object to FlxUISprite, idk.
class StaticArrow extends FlxUISprite
{
	// JOELwindows7: BOLO lua object reference
	// https://github.com/BoloVEVO/Kade-Engine-Public/blob/stable/source/StaticArrow.hx
	#if FEATURE_LUAMODCHART
	public var luaObject:LuaReceptor;
	#end
	public var modifiedByLua:Bool = false;
	public var modAngle:Float = 0; // The angle set by modcharts
	public var totalOverride:Bool = false; // JOELwindows7: enable to disable special parametering & leave its original parametering.
	public var localAngle:Float = 0; // The angle to be edited inside here

	public function new(xx:Float, yy:Float)
	{
		x = xx;
		y = yy;
		super(x, y);
		updateHitbox();
	}

	override function update(elapsed:Float)
	{
		if (!totalOverride)
		{ // JOELwindows7: here total overrider.
			if (!modifiedByLua)
				angle = localAngle + modAngle;
			else
				angle = modAngle;
		}
		super.update(elapsed);

		if (FlxG.keys.justPressed.THREE)
		{
			localAngle += 10;
		}
	}

	public function playAnim(AnimName:String, ?force:Bool = false):Void
	{
		animation.play(AnimName, force);

		if (!AnimName.startsWith('dirCon'))
		{
			localAngle = 0;
		}
		updateHitbox();
		offset.set(frameWidth / 2, frameHeight / 2);

		offset.x -= 54;
		offset.y -= 56;

		angle = localAngle + modAngle;
	}
}
