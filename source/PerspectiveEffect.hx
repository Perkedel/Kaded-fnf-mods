// JOELwindows7: yoink from https://github.com/kem0x/Nexus-Engine/blob/master/source/PrespectiveEffect.hx
package;

import Options.AccuracyDOption;
import flixel.FlxG;
import flixel.system.FlxAssets.FlxShader;

class PrespectiveEffect
{
	public var shader:PrespectiveShader;
	public var pitch:Float = 0;
	public var yaw:Float = 0;
	public var roll:Float = 0;

	public function new():Void
	{
		shader = new PrespectiveShader();
		shader.data.iTime.value = [0];
		shader.data.iPitch.value = [0];
		shader.data.iYaw.value = [0];
		shader.data.iRoll.value = [0];
		shader.data.iResolution.value = [FlxG.width, FlxG.height];
	}

	private function getTime()
	{
		return shader.data.iTime.value[0];
	}

	private function setTime(value)
	{
		shader.data.iTime.value = [value];
	}

	public function setPitch(value)
	{
		shader.data.iPitch.value = [value];
	}

	private function getPitch()
	{
		return shader.data.iPitch.value[0];
	}

	public function setYaw(value)
	{
		shader.data.iYaw.value = [value];
	}

	private function getYaw()
	{
		return shader.data.iYaw.value[0];
	}

	public function setRoll(value)
	{
		shader.data.iRoll.value = [value];
	}

	private function getRoll()
	{
		return shader.data.iRoll.value[0];
	}

	public function update(elapsed:Float):Void
	{
		setTime(getTime() + elapsed);

		if (getPitch() != pitch)
		{
			setPitch(pitch);
		}

		if (getYaw() != yaw)
		{
			setYaw(yaw);
		}

		if (getRoll() != roll)
		{
			setRoll(roll);
		}
	}
}

/*class PrespectiveShader extends FlxShader
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
	void main()
	{
		vec2 fragCoord = openfl_TextureCoordv * iResolution;
		vec2 uv = fragCoord / iResolution.xy;
		float coeff = -0.7;
		
		uv.x -= 0.5f;
		uv.x /= (1.0 - uv.y * coeff);
		uv.y /= (1.0 - uv.y * coeff);
	   
		gl_FragColor = texture(bitmap, uv);
		
	}
	')
	public function new()
	{
		super();
	}
	}
 */
class PrespectiveShader extends FlxShader
{
	@:glFragmentSource('
    
    uniform vec2 iResolution;
    uniform float iTime;
    uniform float iPitch;
    uniform float iYaw;
    uniform float iRoll;

	varying float openfl_Alphav;
    varying vec4 openfl_ColorMultiplierv;
    varying vec4 openfl_ColorOffsetv;
    varying vec2 openfl_TextureCoordv;

    uniform bool openfl_HasColorTransform;
    uniform vec2 openfl_TextureSize;
    uniform sampler2D bitmap;

    uniform bool hasTransform;
    uniform bool hasColorTransform;

    float plane( in vec3 norm, in vec3 po, in vec3 ro, in vec3 rd ) {
        float de = dot(norm, rd);
        de = sign(de)*max( abs(de), 0.001);
        return dot(norm, po-ro)/de;
    }

    vec2 raytraceTexturedQuad(in vec3 rayOrigin, in vec3 rayDirection, in vec3 quadCenter, in vec3 quadRotation, in vec2 quadDimensions) {
        //Rotations ------------------
        float a = sin(quadRotation.x); float b = cos(quadRotation.x); 
        float c = sin(quadRotation.y); float d = cos(quadRotation.y); 
        float e = sin(quadRotation.z); float f = cos(quadRotation.z); 
        float ac = a*c;   float bc = b*c;
        
        mat3 RotationMatrix  = 
                mat3(	  d*f,      d*e,  -c,
                    ac*f-b*e, ac*e+b*f, a*d,
                    bc*f+a*e, bc*e-a*f, b*d );
        //--------------------------------------
        
        vec3 right = RotationMatrix * vec3(quadDimensions.x, 0.0, 0.0);
        vec3 up = RotationMatrix * vec3(0, quadDimensions.y, 0);
        vec3 normal = cross(right, up);
        normal /= length(normal);
        
        //Find the plane hit point in space
        vec3 pos = (rayDirection * plane(normal, quadCenter, rayOrigin, rayDirection)) - quadCenter;
        
        //Find the texture UV by projecting the hit point along the plane dirs
        return vec2(dot(pos, right) / dot(right, right),
                    dot(pos, up)    / dot(up,    up)) + 0.5;
    }

    void main()
    {
        vec2 fragCoord = openfl_TextureCoordv * iResolution;

        // Screen UV goes from 0 - 1 along each axis
        vec2 screenUV = fragCoord / iResolution.xy;
        vec2 p = (2.0 * screenUV) - 1.0;
        float screenAspect = iResolution.x / iResolution.y;
        p.x *= screenAspect;

        // Normalized Ray Dir
        vec3 dir = vec3(p.x, p.y, 1.0);
        dir /= length(dir);

        // Define the plane
        vec3 planePosition = vec3(0.0, 0.0, 0.5);

        vec3 planeRotation = vec3(iPitch, iYaw, iRoll);
        vec2 planeDimension = vec2(-screenAspect, 1.0);

        vec2 uv = raytraceTexturedQuad(vec3(0), dir, planePosition, planeRotation, planeDimension);

        // If we hit the rectangle, sample the texture
        if (abs(uv.x - 0.5) < 0.5 && abs(uv.y - 0.5) < 0.5)
        {
            //Flip X
            uv = vec2(1.0 - uv.x, uv.y);
            gl_FragColor = texture2D(bitmap, uv);
        }
    }
    ')
	public function new()
	{
		super();
	}
}
