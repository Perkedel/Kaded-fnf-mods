// JOELwindows7: Psyched note splash lmao
// yoink from https://github.com/ShadowMario/FNF-PsychEngine/blob/main/source/NoteSplash.hx
// pls FlxUI fy
package;

import flixel.addons.ui.FlxUISprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class NoteSplash extends FlxUISprite
{
	// public var colorSwap:ColorSwap = null;
	private var idleAnim:String;
	private var textureLoaded:String = null;
	private var noteTypeIs:Int = 0; // JOELwindows7: know the note type!

	public function new(x:Float = 0, y:Float = 0, ?note:Int = 0)
	{
		super(x, y);

		var skin:String = 'Arrows-splash';
		if (PlayState.SONG.noteStyle != null && PlayState.SONG.noteStyle.length > 0 && PlayState.SONG.useCustomNoteStyle)
			skin = PlayState.SONG.noteStyle + (PlayState.SONG.noteStyle.contains("pixel") ? "-pixel" : "") + "-splash";

		loadAnims(skin);

		// colorSwap = new ColorSwap();
		// shader = colorSwap.shader;

		setupNoteSplash(x, y, note);
		antialiasing = FlxG.save.data.antialiasing;
	}

	public function setupNoteSplash(x:Float, y:Float, note:Int = 0, texture:String = null, hueColor:Float = 0, satColor:Float = 0, brtColor:Float = 0,
			noteType:Int = 0)
	{
		noteTypeIs = noteType;
		setPosition(x - Note.swagWidth * 0.95, y - Note.swagWidth);
		alpha = 0.6;

		if (texture == null)
		{
			texture = 'Arrows-splash';
			if (PlayState.SONG.noteStyle != null && PlayState.SONG.noteStyle.length > 0)
				texture = PlayState.SONG.noteStyle
					+ (PlayState.SONG.noteStyle.contains("pixel") ? "-pixel" : "")
					+ "-splash"
					+ (noteTypeIs == 2 ? "-duar" : "");
		}

		antialiasing = FlxG.save.data.antialiasing && !texture.contains("pixel"); // JOELwindows7: decide antialiasing!

		if (textureLoaded != texture)
		{
			loadAnims(texture);
		}
		// colorSwap.hue = hueColor;
		// colorSwap.saturation = satColor;
		// colorSwap.brightness = brtColor;
		offset.set(10, 10);

		var animNum:Int = FlxG.random.int(1, 2);
		animation.play('note' + note + '-' + animNum, true);
		if (animation.curAnim != null)
			animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
	}

	public function bruteForceSetupNoteSplash(x:Float, y:Float, note:Int = 0, texture:String = null, hueColor:Float = 0, satColor:Float = 0,
			brtColor:Float = 0)
	{
		setPosition(x - Note.swagWidth * 0.95, y - Note.swagWidth);
		alpha = 0.6;

		if (texture == null)
		{
			texture = 'Arrow-splash';
		}

		antialiasing = FlxG.save.data.antialiasing && !texture.contains("pixel"); // JOELwindows7: decide antialiasing!

		if (textureLoaded != texture)
		{
			loadAnims(texture);
		}
		// colorSwap.hue = hueColor;
		// colorSwap.saturation = satColor;
		// colorSwap.brightness = brtColor;
		offset.set(10, 10);

		var animNum:Int = FlxG.random.int(1, 2);
		animation.play('note' + note + '-' + animNum, true);
		if (animation.curAnim != null)
			animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
	}

	function loadAnims(skin:String)
	{
		// JOELwindows7: now with pixel!
		frames = Paths.doesTextAssetExist(Paths.sparrowXml("noteskins/" + skin,
			"shared")) ? Paths.getSparrowAtlas("noteskins/" + skin) : Paths.getSparrowAtlas("noteskins/"
				+ ("Arrows" + (PlayState.SONG.noteStyle.contains("pixel") ? "-pixel" : "") + "-splash" + (noteTypeIs == 2 ? "-duar" : "")));
		for (i in 1...3)
		{
			animation.addByPrefix("note1-" + i, "note splash blue " + i, 24, false);
			animation.addByPrefix("note2-" + i, "note splash green " + i, 24, false);
			animation.addByPrefix("note0-" + i, "note splash purple " + i, 24, false);
			animation.addByPrefix("note3-" + i, "note splash red " + i, 24, false);
		}
	}

	override function update(elapsed:Float)
	{
		if (animation.curAnim != null)
			if (animation.curAnim.finished)
				kill();

		super.update(elapsed);
	}
}
