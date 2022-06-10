package experiments;

// JOELwindows7: yoink from https://github.com/kem0x/Nexus-Engine/blob/master/source/TestState.hx
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.util.FlxCollision;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileReference;

using StringTools;

// Used for tween testing
class AnKem0xTestState extends AbstractTestMenu
{
	var strumLineNotes:FlxTypedGroup<StrumNote>;
	var strumLine:FlxSprite;

	public function new()
	{
		super();
	}

	override function create()
	{
		strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(112 * 4), 4);

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		for (i in 0...4)
		{
			var note:StrumNote = new StrumNote(112 * (i + 1), strumLine.y, i % 4, 0);
			note.updateHitbox();
			note.playAnim('static', true);
			strumLineNotes.add(note);
			note.scrollFactor.set(1, 1);
		}

		add(strumLineNotes);

		var strums = strumLineNotes.members;

		FlxG.sound.playMusic(Paths.inst("bloom"), 1, false);

		new FlxTimer().start(174 /*BPM*/ / 60, function(tmr:FlxTimer)
		{
			// Drop left
			FlxTween.tween(strums[0], {y: strums[0].y + 70, angle: 45}, 0.3, {ease: FlxEase.sineInOut, type: BACKWARD});
			FlxTween.tween(strums[1], {y: strums[1].y + 70, angle: 45}, 0.3, {ease: FlxEase.sineInOut, type: BACKWARD});
			FlxTween.tween(strums[2], {angle: 45}, 0.3, {ease: FlxEase.sineInOut, type: BACKWARD});
			FlxTween.tween(strums[3], {y: strums[1].y - 30, angle: 45}, 0.3, {ease: FlxEase.sineInOut, type: BACKWARD});

			// Drop right
			FlxTween.tween(strums[3], {y: strums[0].y + 70, angle: 45}, 0.3, {ease: FlxEase.sineInOut, type: BACKWARD, startDelay: 0.4});
			FlxTween.tween(strums[2], {y: strums[1].y + 70, angle: 45}, 0.3, {ease: FlxEase.sineInOut, type: BACKWARD, startDelay: 0.4});
			FlxTween.tween(strums[1], {angle: 45}, 0.3, {ease: FlxEase.sineInOut, type: BACKWARD, startDelay: 0.4});
			FlxTween.tween(strums[0], {y: strums[1].y - 30, angle: 45}, 0.3, {ease: FlxEase.sineInOut, type: BACKWARD, startDelay: 0.4});
		}, 0);

		super.create(); // JOELwindows7: make sure call its parent's to have buttons too.
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
