// JOELwindows7: yoink from https://github.com/KadeDev/Hex-The-Weekend-Update/blob/main/source/MasterObjectLoader.hx
// also https://github.com/BoloVEVO/Kade-Engine-Public/blob/stable/source/MasterObjectLoader.hx
// frankenstino frankenstein
// uh, this involves sys stuff. lemme adapt this little bit.
import flixel.addons.ui.FlxUI;
#if FEATURE_MULTITHREADING
import sys.thread.Mutex;
#end
import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.FlxSprite;

/**
	From: https://github.com/KadeDev/Hex-The-Weekend-Update
	Credits: KadeDev the funni avg4k frogman 
**/
class MasterObjectLoader
{
	#if FEATURE_MULTITHREADING
	public static var mutex:Mutex;
	#end

	public static var Objects:Array<Dynamic> = [];

	// #if FEATURE_MULTITHREADING
	public static function addObject(bruh:Dynamic)
	{
		if (Std.isOfType(bruh, FlxSprite))
		{
			var sprite:FlxSprite = cast(bruh, FlxSprite);
			if (sprite.graphic == null)
				return;
		}
		if (Std.isOfType(bruh, FlxUI))
			return;
		#if FEATURE_MULTITHREADING
		mutex.acquire();
		Objects.push(bruh);
		mutex.release();
		#else
		Objects.push(bruh);
		#end
	}

	public static function removeObject(object:Dynamic)
	{
		if (Std.isOfType(object, FlxSprite))
		{
			var sprite:FlxSprite = cast(object, FlxSprite);
			if (sprite.graphic == null)
				return;
		}
		if (Std.isOfType(object, FlxUI))
			return;
		#if FEATURE_MULTITHREADING
		mutex.acquire();
		Objects.remove(object);
		mutex.release();
		#else
		Objects.remove(object);
		#end
	}

	public static function resetAssets(removeLoadingScreen:Bool = false)
	{
		Debug.logTrace("resetting Asset");
		var keep:Array<Dynamic> = [];
		#if FEATURE_MULTITHREADING
		mutex.acquire();
		#end
		var counter:Int = 0; // JOELwindows7: BOLO has counter
		for (object in Objects)
		{
			if (Std.isOfType(object, FlxSprite))
			{
				// Debug.logTrace("resetting " + Std.string(object) + " FlxSprite");
				var sprite:FlxSprite = object;
				if (sprite.ID >= 99999 && !removeLoadingScreen) // loading screen assets
				{
					keep.push(sprite);
					continue;
				}
				FlxG.bitmap.remove(sprite.graphic);
				// sprite.destroy();
				counter++; // JOELwindows7: BOLO
			}
			if (Std.isOfType(object, FlxGraphic))
			{
				// Debug.logTrace("resetting " + Std.string(object) + " FlxGraphic");
				var graph:FlxGraphic = object;
				FlxG.bitmap.remove(graph);
				// graph.destroy();
				counter++; // JOELwindows7: BOLO
			}
		}
		Debug.logTrace('Removed ${counter} objects');
		Objects = [];
		for (k in keep)
			Objects.push(k);
		#if FEATURE_MULTITHREADING
		mutex.release();
		#end
	}

	// #else
	// public static function addObject(bruh:Dynamic)
	// {
	//     Debug.logError("Add Object faile: no sys found bruh");
	// }
	// public static function removeObject(object:Dynamic)
	// {
	// 	Debug.logError("remove Object faile: no sys found bruh");
	// }
	// public static function resetAssets(removeLoadingScreen:Bool = false)
	// {
	// 	Debug.logError("reset asset faile: no sys found bruh");
	// }
	// #end
}
