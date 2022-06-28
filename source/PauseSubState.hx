package;

import flixel.addons.ui.FlxUIText;
import flixel.addons.ui.FlxUISprite;
import flixel.input.gamepad.FlxGamepad;
import openfl.Lib;
#if FEATURE_LUAMODCHART
import llua.Lua;
#end
import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

// JOELwindows7: FlxUI fy!
class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	public static var goToOptions:Bool = false;
	public static var goBack:Bool = false;
	public static var goConfirmation:Bool = false; // JOELwindows7: here confirmation mode.
	public static var silencePauseBeep:Bool = false; // JOELwindows7: set this single trigger tripwire to true to silence pause beep.

	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Options', 'Exit to menu'];
	// JOELwindows7: Oh we got more here!
	var officeButtonMenuItems:Array<String> = ['Resume', 'Save', 'Save as', 'Options', 'Play Song', 'Exit to menu'];
	var confirmationMenuItems:Array<String> = ['Yes', 'No'];
	var resumeWeekMenuItems:Array<String> = ['Continue', 'New Game', 'Options', 'Close'];
	var curSelected:Int = 0;

	public static var playingPause:Bool = false;

	var pauseMusic:FlxSound;

	var noMusicPls:Bool = false; // JOELwindows7: enable to skip adding music.

	var perSongOffset:FlxUIText;

	var offsetChanged:Bool = false;
	var startOffset:Float = PlayState.songOffset;

	var bg:FlxUISprite;

	public static var inCharter:Bool = false; // JOELwindows7: set this for in chartener or not.
	public static var inStoryMenu:Bool = false; // JOELwindows7: maybe we should make this substate aware where state are we instead?

	public function new()
	{
		// JOELwindows7: first, check the mode.
		if (inCharter)
		{
			menuItems = officeButtonMenuItems; // JOELwindows7: for charter menu
			noMusicPls = true; // JOELwindows7: no music pls.
		}
		if (goConfirmation)
		{
			menuItems = confirmationMenuItems; // JOELwindows7: for confirmation menu
			noMusicPls = true; // JOELwindows7: no music pls.
		}
		if (inStoryMenu)
		{
			menuItems = resumeWeekMenuItems; // JOELwindows7: for story menu
			noMusicPls = true; // JOELwindows7: no music pls.
		}

		super();

		if (PlayState.instance != null) // JOELwindows7: make sure intance was ever there.
			if (PlayState.instance.useVideo && !PlayState.instance.useVLC)
			{
				menuItems.remove("Resume");
				if (GlobalVideo.get().playing)
					GlobalVideo.get().pause();
			}
			else if (PlayState.instance.useVLC)
			{
				menuItems.remove("Resume");
				#if FEATURE_VLC
				// if (PlayState.instance.vlcHandler.isPlaying)
				PlayState.instance.vlcHandler.bitmap.pause(); // JOELwindows7: YOU PECKING FORGOT!!!
				#end
			}

		// JOELwindows7: play the pause sound
		if (!(silencePauseBeep))
		{
			playSoundEffect("PauseOpen");
			// this still often cuts of. maybe we should add it just like pause music?
		}
		else
		{
			// the silence is on! no play pause sound & just do bellow
			silencePauseBeep = false; // false it again so next time you pause, it play pause sound again.
			// haha cool single trigger tripwire flag toggle!
		}

		if (FlxG.sound.music.playing)
			FlxG.sound.music.pause();

		for (i in FlxG.sound.list)
		{
			if (i.playing && i.ID != 9000)
				i.pause();
		}

		if (!playingPause)
		{
			if (!noMusicPls) // JOELwindows7: hey no music if not allowed pls!
			{
				playingPause = true;
				pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
				pauseMusic.volume = 0;
				pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
				pauseMusic.ID = 9000;
				// JOELwindows7: install to Game PEngined extensions
				Game.pauseMusic = pauseMusic;

				FlxG.sound.list.add(pauseMusic);
			}
		}
		else
		{
			for (i in FlxG.sound.list)
			{
				if (i.ID == 9000) // jankiest static variable
					pauseMusic = i;
			}
			if (noMusicPls && pauseMusic != null)
				pauseMusic.destroy(); // JOELwindows7: make sure it completely destroy for no music allowed mode.
		}

		// JOELwindows7: recast
		bg = cast new FlxUISprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxUIText = new FlxUIText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.songName;
		levelInfo.scrollFactor.set();
		// levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.setFormat(Paths.font("UbuntuMono-R.ttf"), 32); // JOELwindows7: use universal language font
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxUIText = new FlxUIText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyFromInt(PlayState.storyDifficulty).toUpperCase();
		levelDifficulty.scrollFactor.set();
		// levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.setFormat(Paths.font('UbuntuMono-R.ttf'), 32); // JOELwindows7: use universal language font
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		// JOELwindows7: show how many you failed during playing this song.
		var levelBlueballs:FlxUIText = new FlxUIText(20, 15 + (32 * 2), 0, "", 32);
		levelBlueballs.text += "Blueballed: " + Std.string(GameOverSubstate.getBlueballCounter());
		levelBlueballs.scrollFactor.set();
		// levelBlueballs.setFormat(Paths.font('vcr.ttf'), 32);
		levelBlueballs.setFormat(Paths.font('UbuntuMono-R.ttf'), 32); // JOELwindows7: use universal language font
		levelBlueballs.updateHitbox();
		add(levelBlueballs);

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;
		levelBlueballs.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		levelBlueballs.x = FlxG.width - (levelBlueballs.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(levelBlueballs, {alpha: 1, y: levelBlueballs.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);
		// perSongOffset = new FlxUIText(5, FlxG.height - 18, 0, "Hello chat", 12);
		perSongOffset = new FlxUIText(5, FlxG.height - 18, 0, "Song ID: " + PlayState.SONG.songId + " | Hello Chat",
			12); // JOELwindows7: don't empty that this!
		perSongOffset.scrollFactor.set();
		perSongOffset.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		#if FEATURE_FILESYSTEM
		add(perSongOffset);
		#end

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.scrollFactor.set(); // JOELwindows7: don't forget to zero the scrollfactor so the hover point doesn't scroll with camera it.
			// JOELwindows7: where the peck is zoom factor?!?
			songText.targetY = i;
			songText.ID = i; // JOELwindows7: ID each menu item to compare with current selected
			// songText.updateHitbox(); //JOELwindows7: not necessary, this can mess touch mouse support
			grpMenuShit.add(songText);
			trace("add menu " + Std.string(songText.ID) + ". " + songText.text); // JOELwindows7: cmon what happened
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		// JOELwindows7: button desu
		addBackButton(20, FlxG.height);
		addLeftButton(FlxG.width - 400, FlxG.height);
		addRightButton(FlxG.width - 200, FlxG.height);
		addUpButton(FlxG.width, Std.int(FlxG.height / 2) - 200);
		addAcceptButton(FlxG.width, Std.int(FlxG.height / 2));
		addDownButton(FlxG.width, Std.int(FlxG.height / 2) + 200);

		backButton.visible = false; // JOELwindows7: oops that backButton ESC not work here. choose resume instead!
		#if !desktop // JOELwindows7: hide the offset adjustment key to prevent people pressing it
		leftButton.visible = false;
		rightButton.visible = false; #end // and then crash the game because again, file writing doesn't work in Android currently

		// JOELwindows7: tweenenied.
		FlxTween.tween(backButton, {y: FlxG.height - 100}, 2, {ease: FlxEase.elasticInOut}); // JOELwindows7: also tween back button!
		FlxTween.tween(leftButton, {y: FlxG.height - 100}, 2, {ease: FlxEase.elasticInOut}); // JOELwindows7: also tween left right button
		FlxTween.tween(rightButton, {y: FlxG.height - 100}, 2, {ease: FlxEase.elasticInOut}); // JOELwindows7: yeah.
		FlxTween.tween(upButton, {x: FlxG.width - 100}, 2, {ease: FlxEase.elasticInOut});
		FlxTween.tween(acceptButton, {x: FlxG.width - 100}, 2, {ease: FlxEase.elasticInOut});
		FlxTween.tween(downButton, {x: FlxG.width - 100}, 2, {ease: FlxEase.elasticInOut});

		// JOELwindows7: temporarily assign accident volume keys to the same buttons configured. do this if you disabled accident volume keys, otherwise leave as is
		if (!FlxG.save.data.accidentVolumeKeys)
		{
			FlxG.sound.muteKeys = [FlxKey.fromString(FlxG.save.data.muteBind)];
			FlxG.sound.volumeDownKeys = [FlxKey.fromString(FlxG.save.data.volDownBind)];
			FlxG.sound.volumeUpKeys = [FlxKey.fromString(FlxG.save.data.volUpBind)];
		}
	}

	override function update(elapsed:Float)
	{
		if (pauseMusic != null)
			if (!noMusicPls) // JOELwindows7: mute if no music is allowed
			{
				if (pauseMusic.volume < 0.5)
					pauseMusic.volume += 0.01 * elapsed;
			}
			else
			{
				pauseMusic.volume = 0; // JOELwindows7: pecking make sure it sounds like no music at all!!!
			}

		super.update(elapsed);

		if (PlayState.instance != null) // JOELwindows7: be sure to make sure the instance was ever there.
			if (PlayState.instance.useVideo)
				menuItems.remove('Resume');

		for (i in FlxG.sound.list)
		{
			if (i.playing && i.ID != 9000)
				i.pause();
		}

		if (bg.alpha > 0.6)
			bg.alpha = 0.6;

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		var upPcontroller:Bool = false;
		var downPcontroller:Bool = false;
		var leftPcontroller:Bool = false;
		var rightPcontroller:Bool = false;
		var oldOffset:Float = 0;

		if (gamepad != null && KeyBinds.gamepad)
		{
			upPcontroller = gamepad.justPressed.DPAD_UP;
			downPcontroller = gamepad.justPressed.DPAD_DOWN;
			leftPcontroller = gamepad.justPressed.DPAD_LEFT;
			rightPcontroller = gamepad.justPressed.DPAD_RIGHT;
		}

		var songPath = 'assets/data/songs/${PlayState.SONG.songId}/';

		#if FEATURE_STEPMANIA
		if (PlayState.isSM && !PlayState.isStoryMode)
			songPath = PlayState.pathToSm;
		#end

		if (controls.UP_P || upPcontroller || FlxG.mouse.wheel == 1 || haveUpped) // JOELwindows7: scroll up
		{
			changeSelection(-1);
			// trace("curSelection is " + Std.string(curSelected) + ". " + menuItems[curSelected]); // JOELwindows7: trace cur selection number

			haveUpped = false;
		}
		else if (controls.DOWN_P || downPcontroller || FlxG.mouse.wheel == -1 || haveDowned) // JOELwindows7: scroll down
		{
			changeSelection(1);
			trace("curSelection is " + Std.string(curSelected) + ". " + menuItems[curSelected]);
			// trace("well that alphabet is " + grpMenuShit.members[curSelected].ID + ". " + grpMenuShit.members[curSelected].text);

			haveDowned = false;
		}

		if ((controls.ACCEPT || haveClicked) && !FlxG.keys.pressed.ALT)
		{
			FlxG.mouse.visible = false; // JOELwindows7: invisiblize after select
			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
				case "Resume":
					if (!inCharter)
					{
						FlxG.mouse.visible = false; // JOELwindows7: just in case

						// JOELwindows7: Hey! prepare unpause first! maybe do it only if not botplay?

						var checkManuallyForUnPause:Bool = ((PlayStateChangeables.botPlay || PlayState.loadRep) ? false : true);

						PlayState.instance.waitLemmePrepareUnpauseFirst = switch (Std.int(FlxG.save.data.unpausePreparation))
						{
							case 0:
								false;
							case 1:
								true;
							case 2:
								checkManuallyForUnPause;
							case _:
								true;
						};

						// JOELwindows7: play this sound effect
						playSoundEffect("PauseClose");
					}
					else
						FlxG.mouse.visible = true; // JOELwindows7: sigh, do not invisiblize mouse in charter!
					close();
				case "Save":
					// JOELwindows7: save the edit chart now.
					ChartingState.instance.justSaveNow();
					close();
				case "Save as":
					// JOELwindows7: save the edit chart as filename now.
					ChartingState.instance.saveLevel();
					close();
				case "Restart Song":
					FlxG.mouse.visible = false; // JOELwindows7: just in case
					PlayState.startTime = 0;
					// JOELwindows7: watch for VLC!
					if (PlayState.instance.useVideo && !PlayState.instance.useVLC)
					{
						GlobalVideo.get().stop();
						PlayState.instance.remove(PlayState.instance.videoSprite);
						PlayState.instance.removedVideo = true;
					}
					else if (PlayState.instance.useVLC)
					{
						#if FEATURE_VLC
						PlayState.instance.vlcHandler.kill();
						#end
						PlayState.instance.remove(PlayState.instance.videoSprite);
						PlayState.instance.removedVideo = true;
					}
					PlayState.instance.clean();
					FlxG.resetState();
					PlayState.stageTesting = false;
				case "Options":
					goToOptions = true;
					close();
				case "Play Song":
					// JOELwindows7: same as press enter in Chartener.
					ChartingState.instance.playDaSongNow();
					close();
				case "Exit to menu":
					inCharter = false; // JOELwindows7: reset the mode back to normal.
					PlayState.startTime = 0;
					// JOELwindows7: VLC is here!
					if (PlayState.instance != null)
					{
						if (PlayState.instance.useVideo && !PlayState.instance.useVLC)
						{
							GlobalVideo.get().stop();
							PlayState.instance.remove(PlayState.instance.videoSprite);
							PlayState.instance.removedVideo = true;
						}
						else if (PlayState.instance.useVLC)
						{
							#if FEATURE_VLC
							PlayState.instance.vlcHandler.kill();
							#end
							PlayState.instance.remove(PlayState.instance.videoSprite);
							PlayState.instance.removedVideo = true;
						}
						PlayState.instance.scronchModcharts(); // JOELwindows7: you must scronch both Lua modchart & stage modchart
						PlayState.instance.removeTouchScreenButtons(); // JOELwindows7: the controller destroy
					}
					if (PlayState.loadRep)
					{
						FlxG.save.data.botplay = false;
						FlxG.save.data.scrollSpeed = 1;
						FlxG.save.data.downscroll = false;
					}
					PlayState.loadRep = false;
					PlayState.stageTesting = false;
					#if FEATURE_LUAMODCHART
					// if (PlayState.luaModchart != null)
					// {
					// 	PlayState.luaModchart.die();
					// 	PlayState.luaModchart = null;
					// }
					#end

					if (FlxG.save.data.fpsCap > 340)
						(cast(Lib.current.getChildAt(0), Main)).setFPSCap(120);

					if (PlayState.instance != null)
					{
						PlayState.instance.clean();
					}

					if (PlayState.isStoryMode)
					{
						// JOELwindows7: BrightFyre! save the week so to resume later!
						StoryMenuState.saveWeek(true);

						GameplayCustomizeState.freeplayBf = 'bf';
						GameplayCustomizeState.freeplayDad = 'dad';
						GameplayCustomizeState.freeplayGf = 'gf';
						GameplayCustomizeState.freeplayNoteStyle = 'normal';
						GameplayCustomizeState.freeplayStage = 'stage';
						GameplayCustomizeState.freeplaySong = 'bopeebo';
						GameplayCustomizeState.freeplayWeek = 1;
						FlxG.switchState(new StoryMenuState());
					}
					else
						FlxG.switchState(new FreeplayState());
				case 'Continue':
					// JOELwindows7: continue week
					Debug.logTrace("Recontinue Week");
				case 'New Game':
					Debug.logTrace("Reset week progress");
					StoryMenuState.resetWeekSave();
					close();
				case 'Yes':
					// JOELwindows7: confirm yes
					Debug.logTrace("Selected Yes");
					close();
				case 'No':
					// JOELwindows7: confirm no
					Debug.logTrace("Selected No");
					close();
				case 'Close':
					close();
			}

			// JOELwindows7: additionally, be responsible to restore the current accident volume keys assignment back to
			// the configured statuses
			Main.instance.checkAccidentVolKeys();

			haveClicked = false;
		}
		else
		{
			// JOELwindows7: make mouse visible when moved.
			if (FlxG.mouse.justMoved)
			{
				// trace("mouse moved");
				FlxG.mouse.visible = true;
			}
			// JOELwindows7: detect any keypresses or any button presses
			if (FlxG.keys.justPressed.ANY)
			{
				// lmao! inspire from GameOverState.hx!
				FlxG.mouse.visible = false;
			}
			if (FlxG.gamepads.lastActive != null)
			{
				if (FlxG.gamepads.lastActive.justPressed.ANY)
				{
					FlxG.mouse.visible = false;
				}
				// peck this I'm tired! plns work lol
			}

			// JOELwindows7: accident volkeys only on this pause menu
			if (!FlxG.save.data.accidentVolumeKeys)
			{
				// if (FlxG.keys.justPressed.PLUS)
				// {
				// 	FlxG.sound.changeVolume(.1);
				// }
				// if (FlxG.keys.justPressed.MINUS)
				// {
				// 	FlxG.sound.changeVolume(-.1);
				// }
				// if (FlxG.keys.justPressed.ZERO)
				// {
				// 	FlxG.sound.toggleMuted();
				// }
			}
		}

		if (FlxG.keys.justPressed.J)
		{
			// for reference later!
			// PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxKey.J, null);
		}

		// JOELwindows7: mouse support
		if (FlxG.mouse.visible)
		{
			// do something here
			// only when mouse is visible
			grpMenuShit.forEach(function(poop:Alphabet)
			{
				if (FlxG.mouse.overlaps(poop) /*&& !FlxG.mouse.overlaps(backButton)*/
					&& !FlxG.mouse.overlaps(leftButton)
					&& !FlxG.mouse.overlaps(rightButton))
				{
					// trace("hover over " + Std.string(poop.ID)); //JOELwindows7: temp tracer
					// alright. it looks like that, the alphabet hover
					// isn't placed like it was appeared.
					// must find another way then. how?
					if (FlxG.mouse.justPressed)
					{
						trace("click a menu " + Std.string(poop.ID) + ". " + Std.string(poop.text));
						if (poop.ID == curSelected)
						{
							trace("haveClicked yes");
							haveClicked = true;
						}
						else
						{
							// go to clicked menu
							goToSelection(poop.ID);
							trace("Go to menu " + Std.string(poop.ID) + ". " + Std.string(poop.text));
						}
					}
				}

				// JOELwindows7: back button for no keyboard
				if (FlxG.mouse.overlaps(backButton) && !FlxG.mouse.overlaps(poop))
				{
					if (FlxG.mouse.justPressed)
					{
						if (!haveBacked)
						{
							haveBacked = true;
						}
					}
				}
				if (FlxG.mouse.overlaps(leftButton) && !FlxG.mouse.overlaps(poop))
				{
					if (FlxG.mouse.justPressed)
					{
						if (!haveLefted)
						{
							haveLefted = true;
						}
					}
				}
				if (FlxG.mouse.overlaps(rightButton) && !FlxG.mouse.overlaps(poop))
				{
					if (FlxG.mouse.justPressed)
					{
						if (!haveRighted)
						{
							haveRighted = true;
						}
					}
				}

				// JOELwindows7: last measure if none of the click pause menu work at all somehow.
				if (FlxG.mouse.overlaps(acceptButton) && !FlxG.mouse.overlaps(poop))
				{
					if (FlxG.mouse.justPressed)
					{
						haveClicked = true;
					}
				}
				if (FlxG.mouse.overlaps(upButton) && !FlxG.mouse.overlaps(poop))
				{
					if (FlxG.mouse.justPressed)
					{
						haveUpped = true;
					}
				}
				if (FlxG.mouse.overlaps(downButton) && !FlxG.mouse.overlaps(poop))
				{
					if (FlxG.mouse.justPressed)
					{
						haveDowned = true;
					}
				}
			});
		}
	}

	override function destroy()
	{
		if (!goToOptions && !goConfirmation) // JOELwindows7: check for other go modes
		{
			Debug.logTrace("destroying music for pauseeta");
			if (pauseMusic != null) // JOELwindows7: safety pause music
				pauseMusic.destroy();
			playingPause = false;
		}

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}

	// JOELwindows7: same as above but this one set to which menu item
	function goToSelection(change:Int)
	{
		curSelected = change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}

	// JOELwindows7: move them here!
	override function manageMouse()
	{
		super.manageMouse();
	}
}
