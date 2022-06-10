import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxG;
import flixel.FlxSprite;

class OptionsDirect extends MusicBeatState
{
	public static var instance:OptionsDirect; // JOELwindows7: seriously. why so complicated, why can't auto detect class???!

	override function create()
	{
		instance = this; // JOELwindows7: idk what supposed to do?

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = true;

		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage("settingBg")); // JOELwindows7: Now I have drawn the bg for it. was menuDesat
		// menuBG.color = 0xFFea71fd; // JOELwindows7: comment too! this change color to purple.
		// menuBG.setGraphicSize(Std.int(menuBG.width * 1.1)); // JOELwindows7: commented! this one zooms in that!
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = FlxG.save.data.antialiasing;
		add(menuBG);

		openSubState(new OptionsMenu());
	}
}
