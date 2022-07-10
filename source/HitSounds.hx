#if FEATURE_FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

// JOELwindows7: yoink from https://github.com/BoloVEVO/Kade-Engine-Public/commit/6d894da2059b973d8bb11ed078d05aab34ac710f
class HitSounds
{
	public static var soundArray:Array<String> = [
		'None',
		'Quaver',
		'Osu',
		'Clap',
		'Snap', // JOElwindows7: hehe!
		'Camellia',
		'StepMania',
		'21st Century Humor',
		'Vine BOOM'
	];

	public static function getSound()
	{
		return soundArray;
	}

	public static function getSoundByID(id:Int)
	{
		return soundArray[id];
	}

	// JOELwindows7: reload the list of soundArray from list file yey
	// inspire from freeplay for cool util & noteskin helper for file read directory
	public static function init()
	{
		#if FEATURE_FILESYSTEM
		soundArray = FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/sounds/hitsounds"));
		#else
		soundArray = CoolUtil.coolTextFile(Paths.txt('data/hitsoundList'));
		#end
		trace('Updated list of hitsounds:\n${getSound()}');
		return getSound();
	}
}
