package;

import flixel.addons.ui.FlxUISprite;
import flixel.addons.ui.FlxUIText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;

// JOELwindows7: FlxUI fy this!
class OutdatedSubState extends MusicBeatState
{
	public static var leftState:Bool = false;
	public static var tinggalkanState:Bool = false; // JOELwindows7: left state LFM outdated flag

	public static var needVer:String = "IDFK_LOL";
	public static var needVerLast:String = "ENTAHLAH_WKWKWK"; // JOELwindows7: last funkin moment need ver
	public static var currChanges:String = "dk";
	public static var perubahanApaSaja:String = "tau"; // JOELwindows7: LFM currChanges
	public static var whichAreaOutdated:Int = 0; // JOELwindows7: which fork is outdated?

	/*
		0. Kade Engine
		1. Last Funkin Moment
		2. Your mod here
	 */
	private var bgColors:Array<String> = ['#314d7f', '#4e7093', '#70526e', '#594465'];
	private var colorRotation:Int = 1;

	override function create()
	{
		trace('Welcome to outdated or leaked');
		// super.create();
		// JOELwindows7: put bekgrondes yesh
		installStarfield2D(0, 0, FlxG.width, FlxG.height);
		installDefaultBekgron();
		defaultBekgron.visible = false;

		// JOELwindows7: caste
		var bg:FlxUISprite = cast new FlxUISprite().loadGraphic(Paths.loadImage('week54prototype', 'shared'));
		bg.scale.x *= 1.55;
		bg.scale.y *= 1.55;
		bg.screenCenter();
		bg.antialiasing = FlxG.save.data.antialiasing;
		add(bg);

		var kadeLogo:FlxUISprite = cast new FlxUISprite(FlxG.width, 0).loadGraphic(Paths.loadImage('KadeEngineLogo'));
		kadeLogo.scale.y = 0.3;
		kadeLogo.scale.x = 0.3;
		kadeLogo.x -= kadeLogo.frameHeight;
		kadeLogo.y -= 180;
		kadeLogo.alpha = 0.8;
		kadeLogo.antialiasing = FlxG.save.data.antialiasing;
		add(kadeLogo);
		kadeLogo.visible = false; // JOELwindows7: wait check which case first

		// JOELwindows7: our LFM logo here pls
		var lfmLogo:FlxUISprite = cast new FlxUISprite(FlxG.width, 0).loadGraphic(Paths.loadImage('art/LFMicon256'));
		lfmLogo.scale.y = .5;
		lfmLogo.scale.x = .5;
		lfmLogo.x -= lfmLogo.frameHeight;
		lfmLogo.y -= 0;
		lfmLogo.alpha = .8;
		lfmLogo.antialiasing = FlxG.save.data.antialiasing;
		add(lfmLogo);
		lfmLogo.visible = false; // JOELwindows7: wait check which case first

		var txt:FlxUIText = new FlxUIText(0, 0, FlxG.width,
			"Your Kade Engine is outdated!\nYou are on "
			+ MainMenuState.kadeEngineVer
			+ "\nwhile the most recent version is "
			+ needVer
			+ "."
			+ "\n\nWhat's new:\n\n"
			+ currChanges
			+ "\n& more changes and bugfixes in the full changelog"
			+ "\n\nPress Space to view the full changelog and update\nor ESCAPE to ignore this"
			+ "\n (Ask parent's / guardian's permission first!)",
			32);

		if (MainMenuState.nightly != "")
			txt.text = "You are on\n"
				+ MainMenuState.kadeEngineVer
				+ "\nWhich is a PRE-RELEASE BUILD!"
				+ "\n\nReport all bugs to the author of the pre-release.\nSpace/Escape ignores this.";

		txt.setFormat("VCR OSD Mono", 32, FlxColor.fromRGB(200, 200, 200), CENTER);
		txt.borderColor = FlxColor.BLACK;
		txt.borderSize = 3;
		txt.borderStyle = FlxTextBorderStyle.OUTLINE;
		txt.screenCenter();
		add(txt);

		// JOELwindows7: now for LFM
		var teks:FlxUIText = new FlxUIText(0, 0, FlxG.width,
			"Your Last Funkin Moment is outdated!\nYou are on "
			+ MainMenuState.lastFunkinMomentVer
			+ "\nwhile the most recent version is "
			+ needVerLast
			+ "."
			+ "\n\nWhat's new:\n\n"
			+ perubahanApaSaja
			+ "\n& more changes and bugfixes in the full changelog"
			+ "\n\nPress Space to view the full changelog and update\nor ESCAPE to ignore this"
			+ "\n (Ask parent's / guardian's permission first!)",
			32);

		if (MainMenuState.larutMalam != "")
			teks.text = "You are on\n"
				+ MainMenuState.lastFunkinMomentVer
				+ "\nWhich is beyond the main version than: "
				+ needVerLast
				+ '\n\nReport all bugs to the bug report place at: \n${Perkedel.ENGINE_BUGREPORT_URL}'
				+ '\n\nPress Space to visit the bug report place and report bugs\nor ESCAPE to ignore this'
				+
				'\nAnd remember folks, only Perkedel Technologies will be fine with software leaks like this.\nDO NOT leak other people\'s project UNLESS they are also CONFIRMED fine with it, people!';

		teks.setFormat("VCR OSD Mono", 32, FlxColor.fromRGB(200, 200, 200), CENTER);
		teks.borderColor = FlxColor.BLACK;
		teks.borderSize = 3;
		teks.borderStyle = FlxTextBorderStyle.OUTLINE;
		teks.screenCenter();
		add(teks);

		var mitsake:FlxUIText = new FlxUIText(0, 0, FlxG.width,
			"Your Last Funkin Moment is outdated!\nYou are on "
			+ "wait a minute.\n"
			+ "who told you to go here?\n"
			+ "Oh, you have mod of a mod of a mod outdated?\n"
			+ "well, buddy, we have no idea what you're talking about. sorry.\n"
			+ "we only know if Kade Engine or Last Funkin Moments outdated.\n"
			+ "well if you are not sure, check the Odysee page, GameJolt, or GameBanana\n"
			+ "page of your mod and compare if there's something new and updated there.\n"
			+ "thancc."
			+ "\n (Ask parent's / guardian's permission first!)",
			32);
		mitsake.setFormat("VCR OSD Mono", 32, FlxColor.fromRGB(200, 200, 200), CENTER);
		mitsake.borderColor = FlxColor.BLACK;
		mitsake.borderSize = 3;
		mitsake.borderStyle = FlxTextBorderStyle.OUTLINE;
		mitsake.screenCenter();
		add(mitsake);

		txt.visible = false;
		teks.visible = false;
		mitsake.visible = false;

		// JOELwindows7: scan which one is outdated
		switch (whichAreaOutdated)
		{
			case 0: // Kade Engine
				kadeLogo.visible = true;
				txt.visible = true;
			case 1: // Last Funkin Moment
				lfmLogo.visible = true;
				teks.visible = true;
				defaultBekgron.visible = true;
			case 2: // Your mod
				mitsake.visible = false;
				trace("visible teks your mod");
			default: // wtf
				mitsake.visible = false;
				trace("what the");
		}

		FlxTween.color(bg, 2, bg.color, FlxColor.fromString(bgColors[colorRotation]));
		FlxTween.angle(kadeLogo, kadeLogo.angle, -10, 2, {ease: FlxEase.quartInOut});
		// JOELwindows7: also do that for LFM logo
		FlxTween.angle(lfmLogo, lfmLogo.angle, -10, 2, {ease: FlxEase.quartInOut});

		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			FlxTween.color(bg, 2, bg.color, FlxColor.fromString(bgColors[colorRotation]));
			if (colorRotation < (bgColors.length - 1))
				colorRotation++;
			else
				colorRotation = 0;
		}, 0);

		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			if (kadeLogo.angle == -10)
				FlxTween.angle(kadeLogo, kadeLogo.angle, 10, 2, {ease: FlxEase.quartInOut});
			else
				FlxTween.angle(kadeLogo, kadeLogo.angle, -10, 2, {ease: FlxEase.quartInOut});

			// JOELwindows7: the LFM logo swing too
			if (lfmLogo.angle == -10)
				FlxTween.angle(lfmLogo, lfmLogo.angle, 10, 2, {ease: FlxEase.quartInOut});
			else
				FlxTween.angle(lfmLogo, lfmLogo.angle, -10, 2, {ease: FlxEase.quartInOut});
		}, 0);

		new FlxTimer().start(0.8, function(tmr:FlxTimer)
		{
			if (kadeLogo.alpha == 0.8)
				FlxTween.tween(kadeLogo, {alpha: 1}, 0.8, {ease: FlxEase.quartInOut});
			else
				FlxTween.tween(kadeLogo, {alpha: 0.8}, 0.8, {ease: FlxEase.quartInOut});

			// JOELwindows7: the LFM logo breathe the alpha too
			if (lfmLogo.alpha == 0.8)
				FlxTween.tween(lfmLogo, {alpha: 1}, 0.8, {ease: FlxEase.quartInOut});
			else
				FlxTween.tween(lfmLogo, {alpha: 0.8}, 0.8, {ease: FlxEase.quartInOut});
		}, 0);

		addBackButton();
		addAcceptButton();
		super.create(); // JOELwindows7: maybe do it last?
	}

	override function update(elapsed:Float)
	{
		if ((controls.ACCEPT || haveClicked) && MainMenuState.nightly == "" && MainMenuState.larutMalam == "")
		{
			// JOELwindows7: accepted, go to which area should be updated. don't forget mouse!
			switch (whichAreaOutdated)
			{
				case 0:
					fancyOpenURL("https://kadedev.github.io/Kade-Engine/changelogs/changelog-" + needVer);
				case 1:
					fancyOpenURL(Perkedel.ENGINE_CHANGELOG_PREFIX_URL + needVerLast);
				default:
					fancyOpenURL("https://kadedev.github.io/Kade-Engine/changelogs/changelog-" + needVer);
			}

			haveClicked = false;
		}
		else if (controls.ACCEPT || haveClicked)
		{
			// JOELwindows7: accepted, go to which area is nightly
			switch (whichAreaOutdated)
			{
				case 0: // Kade Engine
					leftState = true;
				case 1: // Last Funkin Moment
					fancyOpenURL(Perkedel.ENGINE_BUGREPORT_URL);
					tinggalkanState = true;
				case 2: // Your mod
					trace("your mod");
				default: // wtf
					trace("wait what?");
			}
			FlxG.switchState(new MainMenuState());

			haveClicked = false;
		}
		if (controls.BACK || haveBacked)
		{
			switch (whichAreaOutdated)
			{
				case 0: // Kade Engine
					leftState = true;
				case 1: // Last Funkin Moment
					tinggalkanState = true;
				case 2: // Your mod
					trace("your mod");
				default: // wtf
					trace("wait what?");
			}
			FlxG.switchState(new MainMenuState());

			haveBacked = false;
		}
		super.update(elapsed);
	}

	override function manageMouse()
	{
		if (FlxG.mouse.overlaps(backButton))
		{
			if (FlxG.mouse.justPressed)
			{
				if (!haveBacked)
					haveBacked = true;
			}
		}
		if (FlxG.mouse.overlaps(acceptButton))
		{
			if (FlxG.mouse.justPressed)
			{
				if (!haveClicked)
					haveClicked = true;
			}
		}
		super.manageMouse();
	}
}
