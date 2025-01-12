package ui;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.addons.ui.FlxUISprite;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.addons.ui.FlxUIText;
import flixel.FlxState;

// JOELwindows7: to mark deprecated for when Full Ass released
class DeprecatedState extends CoreState
{
	public static var nextState:FlxState = new SplashScreen();

	// public static var deprecationLevelings:Array<Array<String>> = new Array<Array<String>>();
	public static final deprecationLevelings:Array<Array<String>> = [
		[
			'AWAITING PRODUCT',
			"FULL ASS has not been announced yet",
			"We are awaiting FULL ASS to be appeared on Steam.\nPlease visit\nSTEAM_URL\n& wishlist the game as soon as it appeared.\nWe encourage all gamers to buy it,\nbecause once FULL ASS releases, this mod will soon be deprecated &\nall contents of ours will be ported there.\nIf you'd like to download our legacy stuffs,\nthey will be available at Admiral Zumi's Odysee later.\n(DM Subject = `DOWNLOAD_LFM_LEGACY`)\nThank you."
		],
		[
			'DEPRECATION IN PROGRESS',
			"Last Funkin Moment will be deprecated soon. Thancc for playing.",
			"The FULL ASS Steam page has been appeared on Steam.\nPlease visit\nSTEAM_URL\n& wishlist the game instead.\nWe encourage all gamers to buy it as soon as possible,\nbecause this mod will soon be deprecated &\nall contents of ours will be ported there.\nIf you'd like to download our legacy stuffs,\nthey are available at Admiral Zumi's Odysee.\n(DM Subject = `DOWNLOAD_LFM_LEGACY`)\nThank you."
		],
		[
			'DEPRECATED',
			"Last Funkin Moment has been Deprecated. Thancc for playing.",
			"The FULL ASS has been released (along with the mod suport).\nPlease visit\nSTEAM_URL\n& purchase the game instead.\nThis mod has been deprecated & all contents of ours will be\nported there.\nIf you'd like to download our legacy stuffs,\nthey are available at Admiral Zumi's Odysee.\n(DM Subject = `DOWNLOAD_LFM_LEGACY`)\nThank you."
		],
	];
	public static var deprecationLevelSelect:Int = Perkedel.OBSOLESENCE_MODE; // Yes, please look at Perkedel constant Obsolesence mode.

	override function create()
	{
		super.create();

		// Work around object ghost bug as the default transparent bg leaves mark.
		var antiGhost = new FlxUISprite();
		antiGhost.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		antiGhost.scrollFactor.set();
		add(antiGhost);

		// YOINK ForceMajeur
		var bottomText = new FlxUIText(0, 0, 0, "ENTER to visit FULL ASS Steam | ESC to start mod anyways");
		bottomText.scrollFactor.set(0, 0);
		bottomText.setFormat(Paths.font("vcr.ttf"), 12, FlxColor.WHITE);
		bottomText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1);
		bottomText.screenCenter(X);
		bottomText.y = FlxG.height - bottomText.height - 10;
		add(bottomText);

		var exceptionText = new FlxUIText();
		exceptionText.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE);
		exceptionText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1);
		exceptionText.text = deprecationLevelings[Perkedel.OBSOLESENCE_MODE][1] + '\n\n${Perkedel.STAY_LONGER_VOUCHER}';
		exceptionText.color = FlxColor.RED;
		exceptionText.screenCenter(X);
		exceptionText.y += 24;
		// add(exceptionText);

		var crashShit = new FlxUIText();
		crashShit.setFormat(Paths.font("vcr.ttf"), 15, FlxColor.WHITE, CENTER);
		crashShit.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1);
		crashShit.text = deprecationLevelings[Perkedel.OBSOLESENCE_MODE][2];
		crashShit.screenCenter(XY);
		// crashShit.y += exceptionText.y + exceptionText.height + 20;
		add(crashShit);

		// yoink logo from our outdated substate! including swing too!
		var lfmLogo:FlxUISprite = cast new FlxUISprite(FlxG.width, 0).loadGraphic(Paths.loadImage('art/LFMicon256'));
		lfmLogo.scale.y = .5;
		lfmLogo.scale.x = .5;
		lfmLogo.x -= lfmLogo.frameHeight;
		lfmLogo.y -= 0;
		lfmLogo.alpha = .8;
		lfmLogo.antialiasing = FlxG.save.data.antialiasing;
		add(lfmLogo);
		FlxTween.angle(lfmLogo, lfmLogo.angle, -10, 2, {ease: FlxEase.quartInOut});

		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			// JOELwindows7: the LFM logo swing too
			if (lfmLogo.angle == -10)
				FlxTween.angle(lfmLogo, lfmLogo.angle, 10, 2, {ease: FlxEase.quartInOut});
			else
				FlxTween.angle(lfmLogo, lfmLogo.angle, -10, 2, {ease: FlxEase.quartInOut});
		}, 0);

		setSectionTitle(deprecationLevelings[Perkedel.OBSOLESENCE_MODE][0]);

		addBackButton(); // JOELwindows7: back button pls.
		// addLeftButton(Std.int(bottomText.x + bottomText.width + 10), FlxG.height - 100);
		// addAcceptButton(Std.int(gf.x - 300), FlxG.height - 100);
		// addAcceptButton(Std.int(leftButton.x + leftButton.width + 100), FlxG.height - 100);
		// addRightButton(Std.int(acceptButton.x + acceptButton.width + 100), FlxG.height - 100);
		addRightButton(FlxG.width - 95, FlxG.height - 100);
		addAcceptButton(Std.int(rightButton.x - 150), FlxG.height - 100);
		addLeftButton(Std.int(acceptButton.x - 150), FlxG.height - 100);
		addUpButton();
		addDownButton();

		playSoundEffect('beep', 1);
	}

	override function update(elapsed)
	{
		if (FlxG.gamepads.anyJustPressed(A) || FlxG.keys.justPressed.ENTER || haveClicked)
		{
			// fancyOpenURL(Perkedel.DONATE_BUTTON_URL); // DONE: pls steam URL if there is.
			fancyOpenURL(Perkedel.OFFICIAL_WEBSITE_BUTTON_URL); // I think this should suffice
			haveClicked = false; // JOELwindows7: press OK button.
		}

		if (FlxG.gamepads.anyJustPressed(B) || FlxG.keys.justPressed.ESCAPE || haveBacked)
		{
			FlxG.switchState(nextState);
			Game.resetCrashWire(); // JOELwindows7: restore tripwire.
			haveBacked = false; // JOELwindows7: pressed back reset wire
		}

		if (FlxG.mouse.wheel == -1 || haveDowned)
		{
			if (FlxG.keys.pressed.CONTROL)
				FlxG.camera.zoom += 0.02;
			if (FlxG.keys.pressed.SHIFT)
				FlxG.camera.scroll.x += 20;
			if (!FlxG.keys.pressed.SHIFT && !FlxG.keys.pressed.CONTROL)
				FlxG.camera.scroll.y += 20;
			haveDowned = false;
		}
		if (FlxG.mouse.wheel == 1 || haveUpped)
		{
			if (FlxG.keys.pressed.CONTROL)
				FlxG.camera.zoom -= 0.02;
			if (FlxG.keys.pressed.SHIFT)
			{
				if (FlxG.camera.scroll.x > 0)
					FlxG.camera.scroll.x -= 20;
			}
			if (!FlxG.keys.pressed.SHIFT && !FlxG.keys.pressed.CONTROL)
			{
				if (FlxG.camera.scroll.y > 0)
					FlxG.camera.scroll.y -= 20;
			}
			haveUpped = false;
		}
		// JOELwindows7: more buttonez
		if (haveLefted)
		{
			if (FlxG.camera.scroll.x > 0)
				FlxG.camera.scroll.x -= 20;
			haveLefted = false;
		}
		if (haveRighted)
		{
			FlxG.camera.scroll.x += 20;
			haveRighted = false;
		}
	}

	override function manageJoypad()
	{
		super.manageJoypad();
		if (joypadLastActive != null)
		{
			if (joypadLastActive.justPressed.DPAD_UP)
			{
			}
			if (joypadLastActive.justPressed.DPAD_DOWN)
			{
			}
			if (joypadLastActive.justPressed.DPAD_LEFT)
			{
			}
			if (joypadLastActive.justPressed.DPAD_RIGHT)
			{
			}
			if (joypadLastActive.justPressed.A)
			{
			}
			if (joypadLastActive.pressed.RIGHT_STICK_DIGITAL_UP)
			{
				if (FlxG.camera.scroll.y > 0)
					FlxG.camera.scroll.y -= 20;
			}
			if (joypadLastActive.pressed.RIGHT_STICK_DIGITAL_DOWN)
			{
				FlxG.camera.scroll.y += 20;
			}
			if (joypadLastActive.pressed.RIGHT_STICK_DIGITAL_LEFT)
			{
				if (FlxG.camera.scroll.x > 0)
					FlxG.camera.scroll.x -= 20;
			}
			if (joypadLastActive.pressed.RIGHT_STICK_DIGITAL_RIGHT)
			{
				FlxG.camera.scroll.x += 20;
			}
		}
	}
}
