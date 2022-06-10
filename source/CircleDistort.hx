// JOELwindows7: yoink from https://github.com/kem0x/Nexus-Engine/blob/master/source/CircleDistort.hx
package;

import flixel.FlxObject;
import flixel.FlxG;
import flixel.system.FlxAssets.FlxShader;

class CircleEffect
{
	public var shader:CircleShader;

	public function new():Void
	{
		shader = new CircleShader();
		shader.data.iResolution.value = [FlxG.width, FlxG.height];
		shader.data.iTime.value = [0];
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
		setTime(getTime() + elapsed);
	}
}

class CircleShader extends FlxShader
{
	@:glFragmentSource('
    
    uniform vec2 iResolution;
    uniform float iTime;

    varying float openfl_Alphav;
    varying vec4 openfl_ColorMultiplierv;
    varying vec4 openfl_ColorOffsetv;
    varying vec2 openfl_TextureCoordv;

    uniform bool openfl_HasColorTransform;
    uniform vec2 openfl_TextureSize;
    uniform sampler2D bitmap;

    uniform bool hasTransform;
    uniform bool hasColorTransform;

    const float RADIUS	= 200.0;
    const float BLUR	= 500.0;
    const float SPEED   = 2.0;

    void main()
    {
        vec2 fragCoord = openfl_TextureCoordv * iResolution;

        vec2 uv = fragCoord.xy / iResolution.xy;
        vec4 pic = texture2D(bitmap, vec2(uv.x, uv.y));
        
        vec2 center = iResolution.xy / 2.0;
        float d = distance(fragCoord.xy, center);
        float intensity = max((d - RADIUS) / (2.0 + BLUR * (1.0 + sin(iTime*SPEED))), 0.0);

        gl_FragColor = vec4(intensity + pic.r, intensity + pic.g, intensity + pic.b, 0.2);
    }
    ')
	public function new()
	{
		super();
	}
}