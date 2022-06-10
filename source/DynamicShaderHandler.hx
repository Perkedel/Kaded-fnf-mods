#if EXPERIMENTAL_KEM0X_SHADERS
// JOELwindows7: kem0x mod shader https://github.com/kem0x/FNF-ModShaders
package;

import openfl.display.GraphicsShader;
import flixel.FlxG;
import flixel.graphics.tile.FlxGraphicsShader; // JOELwindows7: according to luckydog7, we should not conflict flixel package!
import openfl.utils.Assets as OpenFlAssets;

/*
	Class to handle animated shaders, calling the new consturctor is enough, 
	the update function will be automatically called by the playstate.

	Access the shader the handler with `PlayState.animatedShaders["fileName"]`

	Shaders should be placed at /shaders folder, with ".frag" extension, 
	See shaders folder for examples and guides.

	Optimize variable might help with some heavy shaders but only makes a difference on decent Intel CPUs.

	@author Kemo

	Please respect the effort but to this and credit us if used :]
 */
class DynamicShaderHandler
{
	public var shader:FlxGraphicsShader;

	private var bHasResolution:Bool = false;
	private var bHasTime:Bool = false;

	public function new(fileName:String, optimize:Bool = false)
	{
		var path = Paths.shaderFragment(fileName);

		var fragSource:String = "";

		if (Paths.doesTextAssetExist(path))
		{
			#if sys
			fragSource = sys.io.File.getContent(path);
			#else
			fragSource = OpenFlAssets.getText(path);
			#end
		}

		if (fragSource != "")
		{
			shader = new FlxGraphicsShader(fragSource, optimize);
		}

		if (shader == null)
		{
			return;
		}

		if (fragSource.indexOf("iResolution") != -1)
		{
			bHasResolution = true;
			shader.data.iResolution.value = [FlxG.width, FlxG.height];
		}

		if (fragSource.indexOf("iTime") != -1)
		{
			bHasTime = true;
			shader.data.iTime.value = [0];
		}

		PlayState.animatedShaders[fileName] = this;

		if (PlayState.instance.executeModchart)
		{
			#if FEATURE_LUAMODCHART
			if (PlayState.luaModchart != null)
			{
				PlayState.luaModchart.luaShaders[fileName] = this;
			}
			#end
		}
		// JOELwindows7: wait, there's more!
		if (PlayState.instance.executeModHscript)
		{
			if (PlayState.hscriptModchart != null)
			{
				PlayState.hscriptModchart.luaShaders[fileName] = this;
			}
		}
		if (PlayState.instance.executeStageScript)
		{
			#if FEATURE_LUAMODCHART
			if (PlayState.stageScript != null)
			{
				PlayState.stageScript.luaShaders[fileName] = this;
			}
			#end
		}
		if (PlayState.instance.executeStageHscript)
		{
			if (PlayState.stageHscript != null)
			{
				PlayState.stageHscript.luaShaders[fileName] = this;
			}
		}
	}

	public function modifyShaderProperty(property:String, value:Dynamic)
	{
		if (shader == null)
		{
			return;
		}

		if (shader.data.get(property) != null)
		{
			shader.data.get(property).value = value;
		}
	}

	private function getTime()
	{
		return shader.data.iTime.value[0];
	}

	private function setTime(value)
	{
		shader.data.iTime.value = [value];
	}

	public function update(elapsed:Float)
	{
		if (bHasTime)
		{
			setTime(getTime() + elapsed);
		}
	}
}
#end
