package;

import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxObject;

	var stageSuffix:String = "";
	var midiSuffix:String = '-midi';
	var detectMidiSuffix:String = "";
	var memeSuffix = "-meme";
	var detectMemeSuffix = "";

	var camGame:FlxCamera; // JOELwindows7: in case adding camera ruins the default null camera
	var camHUD:FlxCamera; // JOELwindows7: for that arrow collapsing.

	var workaroundDidStopCurrentMusic:Bool = false;

	public function new(x:Float, y:Float, ?handoverUnspawnNotes:Array<Note>, ?handoverStaticArrow:Array<StaticArrow>)
	{
		// JOELwindows7: debug slag! stop voice & sound again!
		if (PlayState.instance != null && PlayState.instance.vocals != null)
			PlayState.instance.vocals.stop();
		FlxG.sound.music.stop();

		// JOELwindows7: install the handover arrows too as well for cool osu! arrows collapsing.
		var daStage = PlayState.Stage.curStage;
		var daBf:String = '';
		var daSong:String = PlayState.SONG.songId; // damn, I couldn't access that. I change the publicity to public man! JOELwindows7: use Song ID.
		switch (PlayState.boyfriend.curCharacter)
		{
			case 'bf-pixel':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			case 'bf-covid':
				// JOELwindows7: the bf masker torns too aswell!
				daBf = 'bf-covid';
			case 'hookx':
				daBf = 'hookx';
			case 'placeholder':
				daBf = 'placeholder';
			default:
				daBf = 'bf';
		}

		// JOELwindows7: check if the song is midi version
		if (StringTools.endsWith(PlayState.SONG.songId, midiSuffix))
		{
			detectMidiSuffix = "-midi";
		}
		else
		{
			detectMidiSuffix = "";
		}

		// JOELwindows7: checks depending on song
		switch (daSong.toLowerCase())
		{
			case 'tutorial':
				{
					// Noob failure lmao
					FlxG.sound.play(Paths.soundRandom('GF_', 1, 2));
					trace("WHAT? failure in Tutorial? XD hahahhahaha wtf person?!");
				}
			case 'blammed':
				{
					trace("haha lol you blammed!");
					FlxG.sound.play(Paths.sound('carCrash0'));
				}
			default:
				{}
		}

		super();

		// JOELwindows7: install cameras
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxCamera.defaultCameras = [camGame];

		Conductor.songPosition = 0;

		bf = new Boyfriend(x, y, daBf);
		add(bf);

		camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

		// JOELwindows7: add collapse notes arrows
		Debug.logTrace("fake arrow");
		if (handoverUnspawnNotes != null)
		{
			for (i in 0...(handoverUnspawnNotes.length > 50 ? 50 : handoverUnspawnNotes.length))
			{
				if (handoverUnspawnNotes[i].mustPress)
				{
					// var imageArrow = new FlxSprite(handoverUnspawnNotes[i].x, handoverUnspawnNotes[i].y, handoverUnspawnNotes[i].graphic);
					var imageArrow = handoverUnspawnNotes[i];
					imageArrow.totalOverride = true; // Must be on, don't let update parameter holds the original angle supposed to be.
					// imageArrow.animation.play(imageArrow.dataColor[imageArrow.noteData] + 'Scroll');
					imageArrow.cameras = [camHUD];
					add(imageArrow);
					imageArrow.velocity.x = FlxG.random.float(-100, 100);
					imageArrow.velocity.y = FlxG.random.float(-100, 100);
					imageArrow.angularVelocity = FlxG.random.float(-180, 180);
					imageArrow.acceleration.y = 200;
					// handoverUnspawnNotes[i].cameras = [camHUD];
					// add(handoverUnspawnNotes[i]);
					// handoverUnspawnNotes[i].velocity.x = FlxG.random.float(-10, 10);
					// handoverUnspawnNotes[i].velocity.y = FlxG.random.float(-10, 10);
					// handoverUnspawnNotes[i].angularVelocity = FlxG.random.float(-2000, 2000);
					// handoverUnspawnNotes[i].acceleration.y = 200;
				}
			}
		}
		Debug.logTrace("fake static arrow");
		if (handoverStaticArrow != null)
		{
			for (i in 0...handoverStaticArrow.length)
			{
				// var imageStaticArrow = new FlxSprite(handoverStaticArrow[i].x, handoverStaticArrow[i].y, handoverStaticArrow[i].graphic);
				var imageStaticArrow = handoverStaticArrow[i];
				imageStaticArrow.totalOverride = true; // this must be on to disable enforcement (update) by external parameters.
				imageStaticArrow.playAnim('static');
				imageStaticArrow.cameras = [camHUD];
				add(imageStaticArrow);
				imageStaticArrow.velocity.x = FlxG.random.float(-100, 100);
				imageStaticArrow.velocity.y = FlxG.random.float(-100, 100);
				imageStaticArrow.angularVelocity = FlxG.random.float(-180, 180);
				imageStaticArrow.acceleration.y = 200;
				// handoverStaticArrow[i].cameras = [camHUD];
				// add(handoverStaticArrow[i]);
				// handoverStaticArrow[i].velocity.x = FlxG.random.float(-10, 10);
				// handoverStaticArrow[i].velocity.y = FlxG.random.float(-10, 10);
				// handoverStaticArrow[i].angularVelocity = FlxG.random.float(-2000, 2000);
				// handoverStaticArrow[i].acceleration.y = 200;
			}
		}

		// JOELwindows7: add custom gameover sounds
		// JOELwindows7: also play the masker tear if daBf is covid version
		// checks depending on character to play additional sound
		switch (daBf.toLowerCase())
		{
			case 'hookx':
				{
					FlxG.sound.play(Paths.sound('fnf_loss_sfx-BSoD'));
				}
			case 'bf-covid':
				{
					FlxG.sound.play(Paths.sound('paperTear' + Std.string(FlxG.random.int(1, 8))));
					FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix + detectMemeSuffix + detectMidiSuffix));
				}
			default:
				{
					FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix + detectMemeSuffix + detectMidiSuffix));
				}
		}
		Conductor.changeBPM(100);
		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');

		// JOELwindows7: vibrate controller
		Controls.vibrate(0, 200);

		// JOELwindows7: back button to surrender
		addBackButton(20, FlxG.height + 30);
		backButton.scrollFactor.set();
		backButton.alpha = 0;
		// FlxTween.tween(backButton,{y:FlxG.height - 100},2,{ease: FlxEase.elasticInOut}); //JOELwindows7: also tween back button!

		// JOELwindows7: make mouse cursor visible
		FlxG.mouse.visible = true;
	}

	var startVibin:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		// JOELwindows7: add mouse press
		if (controls.ACCEPT || haveClicked)
		{
			endBullshit();

			haveClicked = false; // JOELwindows7: the mouse support improvement
		}

		if (FlxG.save.data.InstantRespawn)
		{
			// LoadingState.loadAndSwitchState(new PlayState());
			PlayState.instance.switchState(new PlayState(), true, true, true, true); // JOELwindows7: Hex weekend switchstate pls
		}

		if (controls.BACK || haveBacked)
		{
			FlxG.sound.music.stop();

			if (PlayState.isStoryMode)
			{
				GameplayCustomizeState.freeplayBf = 'bf';
				GameplayCustomizeState.freeplayDad = 'dad';
				GameplayCustomizeState.freeplayGf = 'gf';
				GameplayCustomizeState.freeplayNoteStyle = 'normal';
				GameplayCustomizeState.freeplayStage = 'stage';
				GameplayCustomizeState.freeplaySong = 'bopeebo';
				GameplayCustomizeState.freeplayWeek = 1;
				// FlxG.switchState(new StoryMenuState());
				PlayState.instance.switchState(new StoryMenuState()); // JOELwindows7: Hex weekend switchstate pls
			}
			else
				// FlxG.switchState(new FreeplayState());
				PlayState.instance.switchState(new FreeplayState()); // JOELwindows7: Hex weekend switchstate pls
			PlayState.loadRep = false;
			PlayState.stageTesting = false;
			haveBacked = false;
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
			FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix + detectMemeSuffix + detectMidiSuffix));
			startVibin = true;
			FlxTween.tween(backButton, {y: FlxG.height - 100, alpha: 1}, 2, {ease: FlxEase.elasticInOut}); // JOELwindows7: also tween back button!
		}
		else
		{
			// JOELwindows7: okeh there is some weird bug glith this Flixel is
			if (!workaroundDidStopCurrentMusic)
			{
				if (PlayState.instance != null && PlayState.instance.vocals != null)
					PlayState.instance.vocals.stop();
				FlxG.sound.music.stop();
				workaroundDidStopCurrentMusic = true;
			}
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}

		// JOELwindows7: you must click bf to accept
		if (FlxG.mouse.overlaps(bf))
		{
			if (FlxG.mouse.justPressed)
			{
				haveClicked = true;
			}
		}
		else if (FlxG.mouse.overlaps(backButton))
		{
			if (FlxG.mouse.justPressed)
			{
				haveBacked = true;
			}
		}
	}

	override function beatHit()
	{
		super.beatHit();

		if (startVibin && !isEnding)
		{
			bf.playAnim('deathLoop', true);
		}
		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		var daStage = PlayState.curStage;
		var daBf:String = '';
		var daSong:String = PlayState.SONG.songId;

		if (!isEnding)
		{
			PlayState.startTime = 0;
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			// JOELwindows7: yess! the MIDI version detection.
			FlxG.sound.play(Paths.music('gameOverEnd' + stageSuffix + detectMemeSuffix + detectMidiSuffix));

			// JOELwindows7: vibrate it
			Controls.vibrate(0, 50);

			// JOELwindows7: context detections scheme like above first loss
			switch (daBf)
			{
				default:
					{}
			}

			switch (daSong.toLowerCase())
			{
				default:
					{}
			}

			switch (daStage)
			{
				default:
					{}
			}

			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					// LoadingState.loadAndSwitchState(new PlayState());
					PlayState.instance.switchState(new PlayState()); // JOELwindows7: hex switch state lol
					PlayState.stageTesting = false;
				});
			});
		}
	}
}
