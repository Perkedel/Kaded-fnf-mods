import flixel.addons.ui.FlxUISprite;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import Section.SwagSection;
import flixel.addons.display.FlxGridOverlay;
import flixel.FlxSprite;

// JOELwindows7: use `FlxUISprite` from now on. umm, maybe nvm. this cause issues. null object reference. but keep extend, FlxUISprite.
class SectionRender extends FlxUISprite
{
	public var section:SwagSection;
	public var icon:FlxSprite;
	public var iconGf:FlxSprite; // JOELwindows7: this one shows / hides depending on gfSection checkbox situation.
	public var lastUpdated:Bool;

	public function new(x:Float, y:Float, GRID_SIZE:Int, ?Height:Int = 16)
	{
		super(x, y);

		makeGraphic(GRID_SIZE * 8, GRID_SIZE * Height, 0xffe7e6e6);

		var h = GRID_SIZE;
		if (Math.floor(h) != h)
			h = GRID_SIZE;

		if (FlxG.save.data.editorBG)
			FlxGridOverlay.overlay(this, GRID_SIZE, Std.int(h), GRID_SIZE * 8, GRID_SIZE * Height);
	}

	override function update(elapsed)
	{
	}
}
