package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;

class OutdatedSubState extends MusicBeatState
{
	public static var leftState:Bool = false;
	public static var tinggalkanState:Bool = false;

	public static var needVer:String = "IDFK LOL";
	public static var needVerLast:String = "ENTAHLAH WKWKWK"; //JOELwindows7: last funkin moment need ver
	public static var currChanges:String = "dk";
	public static var perubahanApaSaja:String = "tau";
	public static var whichAreaOutdated:Int = 0; //JOELwindows7: which fork is outdated?
	/*
		0. Kade Engine
		1. Last Funkin Moment
		2. Your mod here
	*/
	
	private var bgColors:Array<String> = [
		'#314d7f',
		'#4e7093',
		'#70526e',
		'#594465'
	];
	private var colorRotation:Int = 1;

	override function create()
	{
		super.create();
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('week54prototype', 'shared'));
		bg.scale.x *= 1.55;
		bg.scale.y *= 1.55;
		bg.screenCenter();
		add(bg);
		
		var kadeLogo:FlxSprite = new FlxSprite(FlxG.width, 0).loadGraphic(Paths.image('KadeEngineLogo'));
		kadeLogo.scale.y = 0.3;
		kadeLogo.scale.x = 0.3;
		kadeLogo.x -= kadeLogo.frameHeight;
		kadeLogo.y -= 180;
		kadeLogo.alpha = 0.8;
		add(kadeLogo);
		
		var txt:FlxText = new FlxText(0, 0, FlxG.width,
			"Your Kade Engine is outdated!\nYou are on "
			+ MainMenuState.kadeEngineVer
			+ "\nwhile the most recent version is " + needVer + "."
			+ "\n\nWhat's new:\n\n"
			+ currChanges
			+ "\n& more changes and bugfixes in the full changelog"
			+ "\n\nPress Space to view the full changelog and update\nor ESCAPE to ignore this",
			32);
		
		txt.setFormat("VCR OSD Mono", 32, FlxColor.fromRGB(200, 200, 200), CENTER);
		txt.borderColor = FlxColor.BLACK;
		txt.borderSize = 3;
		txt.borderStyle = FlxTextBorderStyle.OUTLINE;
		txt.screenCenter();
		add(txt);

		var teks:FlxText = new FlxText(0, 0, FlxG.width,
			"Your Last Funkin Moment is outdated!\nYou are on "
			+ MainMenuState.lastFunkinMomentVer
			+ "\nwhile the most recent version is " + needVerLast + "."
			+ "\n\nWhat's new:\n\n"
			+ perubahanApaSaja
			+ "\n& more changes and bugfixes in the full changelog"
			+ "\n\nPress Space to view the full changelog and update\nor ESCAPE to ignore this", 
			32);
		teks.setFormat("VCR OSD Mono", 32, FlxColor.fromRGB(200, 200, 200), CENTER);
		teks.borderColor = FlxColor.BLACK;
		teks.borderSize = 3;
		teks.borderStyle = FlxTextBorderStyle.OUTLINE;
		teks.screenCenter();
		add(teks);

		txt.visible = false;
		teks.visible = false;

		switch(whichAreaOutdated){
			case 0:
				txt.visible = true;
			case 1:
				teks.visible = true;
			case 2:
				trace("visible teks your mod");
			default:
				trace("what the");
		}

		FlxTween.color(bg, 2, bg.color, FlxColor.fromString(bgColors[colorRotation]));
		FlxTween.angle(kadeLogo, kadeLogo.angle, -10, 2, {ease: FlxEase.quartInOut});
		
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			FlxTween.color(bg, 2, bg.color, FlxColor.fromString(bgColors[colorRotation]));
			if(colorRotation < (bgColors.length - 1)) colorRotation++;
			else colorRotation = 0;
		}, 0);
		
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			if(kadeLogo.angle == -10) FlxTween.angle(kadeLogo, kadeLogo.angle, 10, 2, {ease: FlxEase.quartInOut});
			else FlxTween.angle(kadeLogo, kadeLogo.angle, -10, 2, {ease: FlxEase.quartInOut});
		}, 0);
		
		new FlxTimer().start(0.8, function(tmr:FlxTimer)
		{
			if(kadeLogo.alpha == 0.8) FlxTween.tween(kadeLogo, {alpha: 1}, 0.8, {ease: FlxEase.quartInOut});
			else FlxTween.tween(kadeLogo, {alpha: 0.8}, 0.8, {ease: FlxEase.quartInOut});
		}, 0);
	}

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT)
		{
			fancyOpenURL("https://kadedev.github.io/Kade-Engine/changelogs/changelog-" + needVer);
		}
		if (controls.BACK)
		{
			switch(whichAreaOutdated){

				case 0:
					leftState = true;
				case 1:
					tinggalkanState = true;
				case 2:
					trace("your mod");
				default:
					trace("wait what?");
			}
			FlxG.switchState(new MainMenuState());
		}
		super.update(elapsed);
	}
}
