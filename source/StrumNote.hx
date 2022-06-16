// JOELwindows7: yoink from https://github.com/kem0x/Nexus-Engine/blob/master/source/StrumNote.hx
// what is this for? OH, it's for test okeh.
// FlxUI fy this pls.
package;

import flixel.addons.ui.FlxUISprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class StrumNote extends FlxUISprite
{
	public var resetAnim:Float = 0;

	private var noteData:Int = 0;

	public var direction:Float = 30; // plan on doing scroll directions soon -bb

	private var player:Int;

	public var texture(default, set):String = null;

	private function set_texture(value:String):String
	{
		if (texture != value)
		{
			texture = value;
			reloadNote();
		}
		return value;
	}

	public function new(x:Float, y:Float, leData:Int, player:Int)
	{
		noteData = leData;
		this.player = player;
		this.noteData = leData;
		super(x, y);

		// var skin:String = 'NOTE_assets';
		var skin:String = PlayState.SONG.useCustomNoteStyle ? ('noteskins/' + PlayState.SONG.noteStyle) : FlxG.save.data.noteskin;
		texture = skin; // Load texture and anims

		scrollFactor.set();
	}

	public function reloadNote()
	{
		var lastAnim:String = null;
		if (animation.curAnim != null)
			lastAnim = animation.curAnim.name;

		frames = Paths.getSparrowAtlas(texture);
		animation.addByPrefix('green', 'arrowUP');
		animation.addByPrefix('blue', 'arrowDOWN');
		animation.addByPrefix('purple', 'arrowLEFT');
		animation.addByPrefix('red', 'arrowRIGHT');

		antialiasing = true;
		setGraphicSize(Std.int(width * 0.7));

		switch (Math.abs(noteData))
		{
			case 0:
				animation.addByPrefix('static', 'arrowLEFT');
				animation.addByPrefix('pressed', 'left press', 24, false);
				animation.addByPrefix('confirm', 'left confirm', 24, false);
			case 1:
				animation.addByPrefix('static', 'arrowDOWN');
				animation.addByPrefix('pressed', 'down press', 24, false);
				animation.addByPrefix('confirm', 'down confirm', 24, false);
			case 2:
				animation.addByPrefix('static', 'arrowUP');
				animation.addByPrefix('pressed', 'up press', 24, false);
				animation.addByPrefix('confirm', 'up confirm', 24, false);
			case 3:
				animation.addByPrefix('static', 'arrowRIGHT');
				animation.addByPrefix('pressed', 'right press', 24, false);
				animation.addByPrefix('confirm', 'right confirm', 24, false);
		}
		updateHitbox();

		if (lastAnim != null)
		{
			playAnim(lastAnim, true);
		}
	}

	public function postAddedToGroup()
	{
		playAnim('static');
		x += Note.swagWidth * noteData;
		x += 50;
		x += ((FlxG.width / 2) * player);
		ID = noteData;
	}

	override function update(elapsed:Float)
	{
		if (resetAnim > 0)
		{
			resetAnim -= elapsed;
			if (resetAnim <= 0)
			{
				playAnim('static');
				resetAnim = 0;
			}
		}

		if (animation.curAnim != null && animation.curAnim.name == 'confirm')
		{
			centerOrigin();
		}

		super.update(elapsed);
	}

	public function playAnim(anim:String, ?force:Bool = false)
	{
		animation.play(anim, force);
		centerOffsets();
		centerOrigin();

		if (animation.curAnim != null && animation.curAnim.name == 'confirm')
		{
			centerOrigin();
		}
	}
}
