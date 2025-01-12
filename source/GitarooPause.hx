package;

import flixel.addons.ui.FlxUISprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

//JOELwindows7: FlxUI fy

class GitarooPause extends MusicBeatState
{
	var replayButton:FlxUISprite;
	var cancelButton:FlxUISprite;

	var replaySelect:Bool = false;

	// JOELwindows7: has clicked the menu
	var hasClicked:Bool = false;

	public function new():Void
	{
		super();
	}

	override function create()
	{
		// make mouse visible
		FlxG.mouse.visible = true;

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		var bg:FlxUISprite = cast new FlxUISprite().loadGraphic(Paths.loadImage('pauseAlt/pauseBG'));
		bg.antialiasing = FlxG.save.data.antialiasing;
		add(bg);

		var bf:FlxUISprite = new FlxUISprite(0, 30);
		bf.frames = Paths.getSparrowAtlas('pauseAlt/bfLol');
		bf.animation.addByPrefix('lol', "funnyThing", 13);
		bf.animation.play('lol');
		bf.antialiasing = FlxG.save.data.antialiasing;
		add(bf);
		bf.screenCenter(X);

		replayButton = new FlxUISprite(FlxG.width * 0.28, FlxG.height * 0.7);
		replayButton.frames = Paths.getSparrowAtlas('pauseAlt/pauseUI');
		replayButton.animation.addByPrefix('selected', 'bluereplay', 0, false);
		replayButton.animation.appendByPrefix('selected', 'yellowreplay');
		replayButton.animation.play('selected');
		replayButton.antialiasing = FlxG.save.data.antialiasing;
		add(replayButton);

		cancelButton = new FlxUISprite(FlxG.width * 0.58, replayButton.y);
		cancelButton.frames = Paths.getSparrowAtlas('pauseAlt/pauseUI');
		cancelButton.animation.addByPrefix('selected', 'bluecancel', 0, false);
		cancelButton.animation.appendByPrefix('selected', 'cancelyellow');
		cancelButton.animation.play('selected');
		cancelButton.antialiasing = FlxG.save.data.antialiasing;
		add(cancelButton);

		changeThing();

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (controls.LEFT_P || controls.RIGHT_P)
			changeThing();

		if (controls.ACCEPT || hasClicked)
		{
			if (replaySelect)
			{
				// FlxG.switchState(new PlayState());
				switchState(new PlayState()); // JOELwindows7: hex switch state lol
			}
			else
			{
				// FlxG.switchState(new MainMenuState());
				switchState(new MainMenuState()); // JOELwindows7: hex switch state lol
			}
			hasClicked = false;
		}

		// JOELwindows7: games from scratch overlap sprite mouse click
		if (FlxG.mouse.overlaps(replayButton))
		{
			setThing(true);

			if (FlxG.mouse.justPressed)
			{
				hasClicked = true;
			}
		}
		if (FlxG.mouse.overlaps(cancelButton))
		{
			setThing(false);

			if (FlxG.mouse.justPressed)
			{
				hasClicked = true;
			}
		}

		super.update(elapsed);
	}

	function changeThing():Void
	{
		replaySelect = !replaySelect;

		if (replaySelect)
		{
			cancelButton.animation.curAnim.curFrame = 0;
			replayButton.animation.curAnim.curFrame = 1;
		}
		else
		{
			cancelButton.animation.curAnim.curFrame = 1;
			replayButton.animation.curAnim.curFrame = 0;
		}
	}

	// JOELwindows7: select manually which one.
	function setThing(intoWha:Bool = false):Void
	{
		replaySelect = intoWha;

		if (replaySelect)
		{
			cancelButton.animation.curAnim.curFrame = 0;
			replayButton.animation.curAnim.curFrame = 1;
		}
		else
		{
			cancelButton.animation.curAnim.curFrame = 1;
			replayButton.animation.curAnim.curFrame = 0;
		}
	}
}
