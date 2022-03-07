#if EXPERIMENTAL_KEM0X_SHADERS
// JOELwindows7: kem0x mod shader https://github.com/kem0x/FNF-ModShaders
package;

import flixel.util.FlxTimer;
import flixel.graphics.tile.FlxGraphicsShader; // JOELwindows7: according to luckydog7, we should not conflict flixel package!
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.Assets as OpenFlAssets;
import openfl.display.GraphicsShader;

using StringTools;

class ShaderSprite extends FlxSprite
{
	var hShader:DynamicShaderHandler;

	public function new(type:String, optimize:Bool = false, ?x:Float = 0, ?y:Float = 0)
	{
		super(x, y);

		// codism
		flipY = true;

		makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT);

		hShader = new DynamicShaderHandler(type, optimize);

		if (hShader.shader != null)
		{
			shader = hShader.shader; // JOELwindows7: then this must be casted. data type different. nvm e
		}

		antialiasing = FlxG.save.data.antialiasing;
	}
}
#end
