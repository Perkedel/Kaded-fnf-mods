import flixel.addons.ui.FlxUISprite;
import flixel.util.FlxColor;
import flixel.FlxSprite;

// JOElwindows7: don't miss this one, I guess??
class ChartingBox extends FlxUISprite
{
	public var connectedNote:Note;
	public var connectedNoteData:Array<Dynamic>;

	public function new(x, y, originalNote:Note)
	{
		super(x, y);
		connectedNote = originalNote;

		makeGraphic(40, 40, FlxColor.fromRGB(173, 216, 230));
		alpha = 0.4;
	}
}
