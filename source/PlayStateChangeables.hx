import flixel.util.FlxColor;

class PlayStateChangeables
{
	public static var useDownscroll:Bool;
	public static var safeFrames:Int;
	public static var scrollSpeed:Float;
	public static var botPlay:Bool;
	public static var Optimize:Bool;
	public static var zoom:Float;
	public static var legacyLuaModchartSupport:Bool;
	public static var stupidityChances:Array<Float> = [0, 0]; // JOELwindows7: chance for each player hit mines. 0 to 100%
	public static var songPosBarColor:FlxColor = Perkedel.SONG_POS_BAR_COLOR; // JOELwindows7: to be changed into color of the week.
	public static var songPosBarColorBg:FlxColor = FlxColor.BLACK; // JOELwindows7: and meter back color.
	public static var weekColor:FlxColor = FlxColor.YELLOW; // JOELwindows7: the obvious week color. for any reference & fallback.
}
