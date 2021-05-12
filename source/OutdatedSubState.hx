package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.app.Application;

class OutdatedSubState extends MusicBeatState
{
	public static var leftState:Bool = false;

	public static var needVer:String = "IDFK LOL";

	override function create()
	{
		super.create();
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);
		var txt:FlxText = new FlxText(0, 0, FlxG.width,
			"Kade Engine is Outdated!\n"
			+ MainMenuState.kadeEngineVer
			+ " is your current version\nwhile the most recent version is " + needVer
			+ "!\nPress Space to go to the github or ESCAPE to ignore this!!"
			+ "\nAlso if you still see this despite already updated this mod,"
			+ "\nplease tell JOELwindows7 to fetch upstream now!"
			+ "\n\nKade Engine lu udah jadul!\n"
			+ MainMenuState.kadeEngineVer
			+ " adalah versi lu saat ini\npadahal yg paling baru itu " + needVer
			+ "!\nPencet Spasi buat pergi ke github atau ESCAPE buat abaikan!!"
			+ "\nSama kalau lu masih ngeliat ini pdhl udah update mod ini,"
			+ "\ntolong bilang pak JOELwindows7 buat ambil sumber hulu segera!"
			,
			32);
		txt.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		txt.screenCenter();
		add(txt);
	}

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT)
		{
			FlxG.openURL("https://github.com/KadeDev/Kade-Engine/releases/latest");
		}
		if (controls.BACK)
		{
			leftState = true;
			FlxG.switchState(new MainMenuState());
		}
		super.update(elapsed);
	}
}
