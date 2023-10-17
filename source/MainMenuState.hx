package;

import flixel.tweens.misc.ColorTween;
import flixel.addons.ui.FlxUISprite;
import const.Perkedel;
import CoreState;
import GalleryAchievements;
import flixel.ui.FlxSpriteButton;
import flixel.ui.FlxButton;
import flixel.addons.display.FlxExtendedSprite;
import flixel.input.gamepad.FlxGamepad;
import Controls.KeyboardScheme;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
#if FEATURE_DISCORD
import Discord.DiscordClient;
#end
import PlayState;

using StringTools;

// JOELwindows7: add BOLO https://github.com/BoloVEVO/Kade-Engine-Public/blame/stable/source/MainMenuState.hx
// JOELwindows7: FlxUI fy!
class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;
	// JOELwindows7: which clicked & have they clicked.
	var curClicked:Int = 0;

	var menuItems:FlxTypedGroup<FlxUISprite>;

	#if !switch
	var optionShit:Array<String> = ['story mode', 'freeplay', 'donate', 'options'];
	#else
	var optionShit:Array<String> = ['story mode', 'freeplay'];
	#end

	// JOELwindows7: Main Menu color will ya? unselected returns to WHITE tint.
	var colorShit:Array<FlxColor> = [FlxColor.CYAN, FlxColor.YELLOW, FlxColor.LIME, FlxColor.MAGENTA];
	var colorTweens:Array<ColorTween>;

	var newGaming:FlxText;
	var newGaming2:FlxText;

	public static var firstStart:Bool = true;

	public static var nightly:String = "";
	public static var larutMalam:String = Perkedel.ENGINE_NIGHTLY; // JOELwindows7: Last Funkin Nightly mark

	public static var kadeEngineVer:String = "1.8.1" + nightly;
	public static var gameVer:String = "0.2.7.1";
	public static var lastFunkinMomentVer:String = Perkedel.ENGINE_VERSION + larutMalam; // JOELwindows7: last funkin moments version
	public static var yourModVer:String = "0.0.0.0"; // JOELwindows7: your own mod version

	var magenta:FlxUISprite;
	var camFollow:FlxObject;

	public static var finishedFunnyMove:Bool = false;

	public static var freakyPlaying:Bool; // JOELwindows7: Marker if the Freaky is playing da right now!

	override function create()
	{
		// JOELwindows7: an menu color tween
		colorTweens = new Array<ColorTween>();
		// for (i in 0...5){
		// 	colorTweens[i] = new ColorTween();
		// }

		// JOELwindows7: BOLO clear memory!
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		trace(0 / 2);
		clean();
		PlayState.inDaPlay = false;
		#if FEATURE_DISCORD
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		PlayState.isStoryMode = false; // JOELwindows7: BOLO. reset flag down

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;

		// JOELwindows7: cast. no nvm.
		var bg:FlxUISprite = new FlxUISprite(-100);
		bg.loadGraphic(Paths.loadImage('MenuBGAlt')); // JOELwindows7: was menuBG
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.10;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = FlxG.save.data.antialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		// JOELwindows7: cast. no nvm
		magenta = new FlxUISprite(-80);
		magenta.loadGraphic(Paths.loadImage('MenuBGDesatAlt')); // JOELwindows7: was menuDesat
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0.10;
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = FlxG.save.data.antialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxUISprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('FNF_main_menu_assets');

		// JOELwindows7: add back button
		addBackButton(10, FlxG.height + 100);
		// backButton.screenCenter(X);
		backButton.scrollFactor.set();

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxUISprite = new FlxUISprite(0, FlxG.height * 1.6);
			menuItem.frames = tex;
			// menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			// menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			// JOELwindows7: let's use menu version we yoinked from week 7 which was yoinked by luckydog7 yeah!
			menuItem.animation.addByPrefix('idle', optionShit[i] + " idle", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " selected", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = FlxG.save.data.antialiasing;
			if (firstStart)
				FlxTween.tween(menuItem, {y: 60 + (i * 160)}, 1 + (i * 0.25), {
					ease: FlxEase.expoInOut,
					onComplete: function(flxTween:FlxTween)
					{
						finishedFunnyMove = true;
						changeItem();
					}
				});
			else
			{
				menuItem.y = 60 + (i * 160);
			}
		}

		// JOELwindows7: back button swiaush
		if (firstStart)
		{
			FlxTween.tween(backButton, {y: FlxG.height - 150}, {ease: FlxEase.expoInOut});
		}
		else
		{
			backButton.y = FlxG.height - 150;
		}

		firstStart = false;

		FlxG.camera.follow(camFollow, null, 0.60 * (60 / FlxG.save.data.fpsCap));

		// JOELwindows7: hard code our download link in case reuploaded without credit no matter what sign given
		// we also covered both Kade Engine and the vanilla itself
		var reuploadWord:String = "Download Last Funkin Moments for free $0 legit on https://github.com/Perkedel/kaded-fnf-mods,\n"
			+ "original Kade Engine at https://github.com/KadeDev/Kade-Engine,\n"
			+ "and vanilla Funkin at https://github.com/ninjamuffin99/Funkin ,\n"
			+ "also FULL ASS Funkin at STEAM_URL .\n"
			+ "play vanilla Funkin at https://www.newgrounds.com/portal/view/770371\n";
		var reuploadEdgeCase:FlxText = new FlxText(5, FlxG.height - 80, 0, reuploadWord, 12);
		reuploadEdgeCase.scrollFactor.set();
		reuploadEdgeCase.setFormat("VCR OSD Mono", 12, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(reuploadEdgeCase);
		// Kade, ninja, you should do that too. follow this example!
		// also somehow at the end of the paragraph above, you must `\n` it at the very end. idk why, but that's the workaround
		// so the last line of text also shows.

		// TODO: JOELwindows7: add menu description!!! bla bla bla blbalblablb
		// var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, gameVer +  (Main.watermarks ? " FNF - " + kadeEngineVer + " Kade Engine" : "") + (Main.perkedelMark ? " Perkedel Mod v" + lastFunkinMomentVer : ""), 12);
		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, gameVer, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		if (FlxG.save.data.dfjk)
			controls.setKeyboardScheme(KeyboardScheme.Solo, true);
		else
			controls.setKeyboardScheme(KeyboardScheme.Duo(true), true);

		changeItem();

		#if gamejolt
		// Main.gjToastManager.createToast(Paths.image("art/LFMicon64.png"), "Cool and good", "Welcome to Last Funkin Moments",
		// 	false); // JOELwindows7: create GameJolt Toast here.
		#end

		super.create();
	}

	var selectedSomethin:Bool = false;

	// JOELwindows7: HOW BOLO mouse position
	// var oldPos = FlxG.mouse.getScreenPosition();

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!selectedSomethin)
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

			var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

			if (gamepad != null)
			{
				if (gamepad.justPressed.DPAD_UP)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeItem(-1);
				}
				if (gamepad.justPressed.DPAD_DOWN)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeItem(1);
				}
			}

			// JOELwindows7: attempt add mouse support kinda..
			if (FlxG.keys.justPressed.UP)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (FlxG.keys.justPressed.DOWN)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK || haveBacked)
			{
				// FlxG.switchState(new TitleState());
				switchState(new TitleState()); // JOELwindows7: use this Kade + YinYang48 Hex version

				haveBacked = false;
			}

			if (controls.ACCEPT || haveClicked)
			{
				if (optionShit[curSelected] == 'donate')
				{
					Controls.vibrate(0, 50); // JOELwindows7: give feedback!!!
					FlxG.sound.play(Paths.sound('confirmMenu')); // JOELwindows7: hey, pls don't forget the confirm sound for Kickstarter go to one also!
					// fancyOpenURL("https://ninja-muffin24.itch.io/funkin");
					fancyOpenURL(Perkedel.DONATE_BUTTON_URL); // JOELwindows7: hey, open all links there is to it.
					AchievementUnlocked.whichIs("acknowledgement");
				}
				else
				{
					// FlxG.gamepads.lastActive.vibrate(0.1); //JOELwindows7: wtf bro, no vibration????
					Controls.vibrate(0, 50); // JOELwindows7: give feedback!!!
					_loadingBar.popNow();
					_loadingBar.setInfoText("Selected " + optionShit[curSelected]);
					_loadingBar.setLoadingType(ExtraLoadingType.VAGUE);
					FlxG.mouse.visible = false;
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if (FlxG.save.data.flashing)
						FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxUISprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 1.3, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							if (FlxG.save.data.flashing)
							{
								FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
								{
									_loadingBar.unPopNow();
									goToState();
								});
							}
							else
							{
								new FlxTimer().start(1, function(tmr:FlxTimer)
								{
									_loadingBar.unPopNow();
									goToState();
								});
							}
						}
					});

					// JOELwindows7: also for the back button fade
					FlxTween.tween(backButton, {alpha: 0}, 1.3, {
						ease: FlxEase.quadOut,
						onComplete: function(twn:FlxTween)
						{
							backButton.kill();
						}
					});
				}
				// JOELwindows7: have clicked refalsing after done.
				haveClicked = false;
			}
		}

		super.update(elapsed);

		// JOELwindows7: not my code, but this one is important!
		// do this all time to center the spr every single time!
		// all I did here, is to add the mouse touch support yey
		menuItems.forEach(function(spr:FlxUISprite)
		{
			// JOELwindows7: itterate sprite menu items overlaps and click functions
			if (!selectedSomethin && FlxG.mouse.visible && finishedFunnyMove)
			{
				if (FlxG.mouse.overlaps(spr) && !FlxG.mouse.overlaps(backButton))
				{
					if (curSelected != spr.ID)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						goToItem(spr.ID);
					}
					if (FlxG.mouse.justPressed)
					{
						trace("mouse clicked on " + Std.string(curSelected) + ". " + optionShit[curSelected]);
						haveClicked = true;
					}
				}

				if (FlxG.mouse.overlaps(backButton) && !FlxG.mouse.overlaps(spr))
				{
					if (FlxG.mouse.justPressed)
					{
						if (!haveBacked)
						{
							haveBacked = true;
						}
					}
				}
			}

			spr.screenCenter(X);
		});
	}

	function goToState()
	{
		var daChoice:String = optionShit[curSelected];

		switch (daChoice)
		{
			// JOELwindows7: you must use this new stuff versionao on it!
			case 'story mode':
				// FlxG.switchState(new StoryMenuState());
				switchState(new StoryMenuState());
				trace("Story Menu Selected");
			case 'freeplay':
				// FlxG.switchState(new FreeplayState());
				switchState(new FreeplayState());

				trace("Freeplay Menu Selected");

			case 'options':
				// FlxG.switchState(new OptionsDirect());
				switchState(new OptionsDirect());
		}
	}

	// JOELwindows7: Please colorize one selected menu and return other unselected back to WHITE tint
	function colorizeMenu(huh:Int = 0)
	{
		// cancel current first
		for (i in 0...colorTweens.length)
		{
			if (colorTweens[i] != null)
			{
				colorTweens[i].cancel();
			}
		}

		// // now color this one
		// colorTweens[huh] = FlxTween.color(menuItems.members[huh], 0.5, menuItems.members[huh].color, colorShit[huh], {
		// 	onComplete: function(twn:FlxTween)
		// 	{
		// 		colorTweens[huh] = null;
		// 	}
		// });

		// // and whitens the unselected.
		// menuItems.forEach(function(spr:FlxUISprite){
		// 	if(spr.ID != huh){
		// 		colorTweens[spr.ID] = FlxTween.color(spr, 0.5, spr.color, colorShit[huh], {
		// 			onComplete: function(twn:FlxTween)
		// 			{
		// 				colorTweens[huh] = null;
		// 			}
		// 		});
		// 	}
		// });

		// wait, could've done this instead.
		menuItems.forEach(function(spr:FlxUISprite)
		{
			// var selectColor:FlxColor;
			// switch(ID){

			// }
			colorTweens[spr.ID] = FlxTween.color(spr, 0.5, spr.color, spr.ID == curSelected ? colorShit[spr.ID] : FlxColor.WHITE, {
				// colorTweens[spr.ID] = FlxTween.color(spr, 0.5, spr.color, spr.ID == curSelected ? FlxColor.GREEN : FlxColor.WHITE, {
				// colorTweens[spr.ID] = FlxTween.color(spr, 0.5, spr.color, spr.ID == curSelected ? FlxColor.GREEN : FlxColor.WHITE, {

				onComplete: function(twn:FlxTween)
				{
					colorTweens[curSelected] = null;
				}
			});
		});
	}

	function changeItem(huh:Int = 0)
	{
		if (finishedFunnyMove)
		{
			curSelected += huh;

			if (curSelected >= menuItems.length)
				curSelected = 0;
			if (curSelected < 0)
				curSelected = menuItems.length - 1;
		}
		colorizeMenu(huh); // JOELwindows7: iyeye
		menuItems.forEach(function(spr:FlxUISprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected && finishedFunnyMove)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			// spr.animation.curAnim.frameRate = 24 * (60 / FlxG.save.data.fpsCap);
			spr.animation.curAnim.frameRate = 15; // JOELwindows7: BOLO. maybe we should keep it 15 fps for these menu animation
			// all time. idk.
			// https://github.com/BoloVEVO/Kade-Engine-Public/blame/stable/source/MainMenuState.hx

			spr.updateHitbox();
		});
	}

	// JOELwindows7: go to item for hover mouse
	// copy from above but the curSelected is set value instead
	function goToItem(huh:Int = 0)
	{
		if (finishedFunnyMove)
		{
			curSelected = huh;

			if (curSelected >= menuItems.length)
				curSelected = 0;
			if (curSelected < 0)
				curSelected = menuItems.length - 1;
		}
		colorizeMenu(huh); // JOELwindows7: iyeye
		menuItems.forEach(function(spr:FlxUISprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected && finishedFunnyMove)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			// JOELwindows7: bring it here too!
			spr.animation.curAnim.frameRate = 15; // JOELwindows7: BOLO. maybe we should keep it 15 fps for these menu animation
			// all time. idk.

			spr.updateHitbox();
		});
	}
}
