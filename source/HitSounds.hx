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
		// oh man, clean everything first!
		soundArray = [];
		#if FEATURE_FILESYSTEM
		// remember, there is extension on each. so we need to remove them just like the noteskin helper
		for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/sounds/hitsounds")))
		{
			// always make sure that it's the audio file format we use!
			// web uses mp3, while rest uses ogg.
			// weird btw, that web uses mp3. patent expired already I know, but
			// why not ogg too?
			if (!i.endsWith('.${Paths.SOUND_EXT}'))
				continue;

			// okay, there is audio file named `null`, for fallback, safety, & anti crash thingy.
			// not supposed to be loaded at all.
			if (i == 'null')
				continue;
			// it's basically same as `none` which you already have.
			// btw, I just generate silence for 1 second & then export it both formats, with Audacity
			// that's it. nothing special.
			// I still couldn't decide if Audacity's move towards GPL v3 & other controvercial thingies
			// deserves, absolute hate. I cannot go anywhere if it does.
			// where do I go? Audacity is the only one we had. Adobe Audition is the worst guy.
			// where? where do we go now?
			// also SystemD (over complex & breaks UNIX philosophy of simplicity) lots of features & about reliable
			// , where do we go now?
			// nowhere.

			// then we can push it.
			soundArray.push(i.replace('.${Paths.SOUND_EXT}', ''));
		}
		#else
		soundArray = CoolUtil.coolTextFile(Paths.txt('data/hitsoundList'));
		#end
		trace('Updated list of hitsounds:\n${getSound()}');
		return getSound();
	}
}
