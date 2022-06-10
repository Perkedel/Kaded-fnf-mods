package;

import openfl.utils.Assets as OpenFlAssets;
import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.math.FlxMath;

using hx.strings.Strings;

class HelperFunctions
{
	// JOELwindows7: Master eric enigma equivalent to `Util.hx`
	// yoink from https://github.com/EnigmaEngine/EnigmaEngine/blob/stable/source/funkin/util/Util.hx
	// JOELwindows7: this is enigma build array
	public static function buildArrayFromRange(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	public static function truncateFloat(number:Float, precision:Int):Float
	{
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round(num) / Math.pow(10, precision);
		return num;
	}

	public static function GCD(a, b)
	{
		return b == 0 ? FlxMath.absInt(a) : GCD(b, a % b);
	}

	// JOELwindows7: moar enigma functions!!!

	/**
	 * @param duration The duration in seconds
	 * @return The duration in the format "MM:SS"
	 */
	public static function durationToString(duration:Float):String
	{
		var seconds = FlxMath.roundDecimal(duration, 0) % 60;
		var secondsStr = Strings.lpad('$seconds', 2, '0');
		var minutes = FlxMath.roundDecimal(duration - seconds, 0) / 60;
		var minutesStr = FlxMath.roundDecimal(minutes, 0);
		return '$minutesStr:$secondsStr';
	}

	public static function getTypeName(input:Dynamic):String
	{
		return switch (Type.typeof(input))
		{
			case TEnum(e):
				Type.getEnumName(e);
			case TClass(c):
				Type.getClassName(c);
			case TInt:
				"int";
			case TFloat:
				"float";
			case TBool:
				"bool";
			case TObject:
				"object";
			case TFunction:
				"function";
			case TNull:
				"null";
			case TUnknown:
				"unknown";
			default:
				"";
		}
	}

	/**
	 * Utility to parse an ARGB value from the current hex value
	 * Hex string is cached on the class so that it does not need to be recalculated for every pixel.
	 */
	public static function parseARGB(alpha:Int, hexStr:String):UInt
	{
		return Std.parseInt("0x" + Strings.toHex(alpha) + hexStr);
	}

	/**
	 * Convert a hexadecimal number to a hexadecimal string.
	 */
	public static function toHexString(hex:UInt):String
	{
		var r:Int = (hex >> 16);
		var g:Int = (hex >> 8 ^ r << 8);
		var b:Int = (hex ^ (r << 16 | g << 8));

		var red:String = Strings.toHex(r);
		var green:String = Strings.toHex(g);
		var blue:String = Strings.toHex(b);

		red = (red.length < 2) ? "0" + red : red;
		green = (green.length < 2) ? "0" + green : green;
		blue = (blue.length < 2) ? "0" + blue : blue;
		return (red + green + blue).toUpperCase();
	}
}
