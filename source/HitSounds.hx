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
}
