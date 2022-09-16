#if FEATURE_FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end
import openfl.display.BitmapData;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets; // JOELwindows7: bring it in!
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxG;
import utils.Asset2File;

using StringTools;

class NoteskinHelpers
{
	public static var noteskinArray = [];
	public static var xmlData = [];

	public static function updateNoteskins()
	{
		noteskinArray = [];
		xmlData = [];
		#if FEATURE_FILESYSTEM
		var count:Int = 0;
		for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/noteskins")))
		{
			// JOELwindows7: make sure the special type are not considered different option.
			// these are pixel, mine do not step, special power up, important must step or ded, never step or ded, splash, etc. idk.
			if (i.contains("-pixel") || i.contains("-mine") || i.contains("-special") || i.contains("-important") || i.contains("-never")
				|| i.contains("-splash"))
				continue;
			if (i.endsWith(".xml"))
			{
				xmlData.push(sys.io.File.getContent(FileSystem.absolutePath("assets/shared/images/noteskins") + "/" + i));
				continue;
			}

			if (!i.endsWith(".png"))
				continue;
			noteskinArray.push(i.replace(".png", ""));
		}
		#else
		// noteskinArray = ["Arrows", "Circles", "Saubo"]; // JOELwindows7: lemme pecking try this. ugh so confusing!
		noteskinArray = CoolUtil.coolTextFile(Paths.txt('data/noteskinSettingList')); // JOElwindows7: right, let's just manual filing instead, shall we?
		#end

		return noteskinArray;
	}

	public static function getNoteskins()
	{
		return noteskinArray;
	}

	public static function getNoteskinByID(id:Int)
	{
		return noteskinArray[id];
	}

	static public function generateNoteskinSprite(id:Int, typeSpecial:Int = 0, otherWayAround:Bool = false) // JOELwindows7: add type of it.
	{
		var typeSuffix:String = generateTypePostFix(typeSpecial);
		// #if FEATURE_FILESYSTEM
		// TODO: Make this use OpenFlAssets.
		// JOELwindows7: Okay, let's do this!

		Debug.logTrace("bruh momento id=" + Std.string(id) + " typeSpecial=" + Std.string(typeSpecial));

		var path = 'noteskins/${getNoteskinByID(id)}${(otherWayAround ? "/NOTE_assets" : "")}${typeSuffix}'; // JOELwindows7: simpler
		// var path = FileSystem.absolutePath("assets/shared/images/noteskins")
		// 	+ "/"
		// 	+ getNoteskinByID(id)
		// 	+ (otherWayAround ? "/NOTE_assets" : "")
		// 	+ typeSuffix; // JOELwindows7: watch the xml path
		// // if (!FileSystem.exists(path + ".xml"))
		// // if (!OpenFlAssets.exists(path + ".xml", TEXT))
		// if (!Paths.doesTextAssetExist(path + ".xml"))
		// {
		// 	// JOELwindows7: If not exist
		// 	// Debug.logTrace("getting default SparrowAtlas skin");
		// 	// return Paths.getSparrowAtlas('noteskins/Arrows', "shared");
		// 	path = FileSystem.absolutePath("assets/shared/images/noteskins") + "/" + "Arrows" + typeSuffix;
		// }
		Debug.logInfo("now load path " + path);
		// var data:BitmapData = BitmapData.fromFile(path + ".png");

		// return FlxAtlasFrames.fromSparrow(FlxGraphic.fromBitmapData(data), xmlData[id]);

		// return Paths.getSparrowAtlas('noteskins/' + NoteskinHelpers.getNoteskinByID(FlxG.save.data.noteskin), "shared");

		// JOELwindows7: alright, this is too far. let's just simplify it
		return Paths.doesTextAssetExist(Paths.sparrowXml(path,
			"shared")) ? Paths.getSparrowAtlas(path, 'shared') : Paths.getSparrowAtlas('noteskins/Arrows$typeSuffix', "shared");
		// Oh wow that works. well uh, don't use `FileSystem` anymore, coz it's buggy, on Linux e.g.
		// here my `neofetch` btw
		/*
			```
									-`                    joelwindows7@joelwin7-rog-gl503ge 
								  .o+`                   --------------------------------- 
								 `ooo/                   OS: Arch Linux x86_64 
								`+oooo:                  Host: Strix 15 GL503GE 1.0 
							   `+oooooo:                 Kernel: 5.18.3-arch1-1 
							   -+oooooo+:                Uptime: 4 hours, 14 mins 
							 `/:-:++oooo+:               Packages: 1305 (pacman), 11 (flatpak) 
							`/++++/+++++++:              Shell: bash 5.1.16 
						   `/++++++++++++++:             Resolution: 1920x1080 
						  `/+++ooooooooooooo/`           DE: Plasma 5.24.5 
						 ./ooosssso++osssssso+`          WM: kwin 
						.oossssso-````/ossssss+`         Theme: [Plasma], Breeze [GTK2/3] 
					   -osssssso.      :ssssssso.        Icons: [Plasma], breeze-dark [GTK2/3] 
					  :osssssss/        osssso+++.       Terminal: konsole 
					 /ossssssss/        +ssssooo/-       Terminal Font: MesloLGS NF 10 
				  `/ossssso+/:-        -:/+osssso+-     CPU: Intel i7-8750H (12) @ 4.100GHz 
				 `+sso+:-`                 `.-/+oso:    GPU: Intel CoffeeLake-H GT2 [UHD Graphics 630] 
				`++:.                           `-/+/   GPU: NVIDIA GeForce GTX 1050 Ti Mobile 
				.`                                 `/   Memory: 4065MiB / 7803MiB 

																				 
																				 
			```
		 */

		// enjoy, btw.
		// #else
		// return Paths.getSparrowAtlas('noteskins/Arrows', "shared");
		// #end
	}

	// JOELwindows7: this is string version
	static public function generateNoteskinSpriteFromSay(say:String, typeSpecial:Int = 0, otherWayAround:Bool = false)
	{
		var typeSuffix:String = generateTypePostFix(typeSpecial);
		// #if FEATURE_FILESYSTEM
		// TODO: Make this use OpenFlAssets.
		// JOELwindows7: make simpler!

		Debug.logTrace("bruh momento name=" + say + " typeSpecial=" + Std.string(typeSpecial));

		var path = 'noteskins/${say}${otherWayAround ? "/NOTE_assets" : ""}${typeSuffix}'; // JOELwindows7: simpler
		// var path = FileSystem.absolutePath("assets/shared/images/noteskins")
		// 	+ "/"
		// 	+ say
		// 	+ (otherWayAround ? "/NOTE_assets" : "")
		// 	+ typeSuffix; // JOELwindows7: watch the xml path
		// if (!FileSystem.exists(path + ".xml"))
		// {
		// 	// JOELwindows7: If not exist
		// 	// Debug.logTrace("getting default SparrowAtlas skin");
		// 	// return Paths.getSparrowAtlas('noteskins/Arrows', "shared");
		// 	path = FileSystem.absolutePath("assets/shared/images/noteskins") + "/" + "Arrows" + typeSuffix;
		// }
		Debug.logInfo("now load path " + path);
		// var data:BitmapData = BitmapData.fromFile(path + ".png");

		// return FlxAtlasFrames.fromSparrow(FlxGraphic.fromBitmapData(data), sys.io.File.getContent(path + ".xml"));
		return Paths.doesTextAssetExist(Paths.sparrowXml(path,
			"shared")) ? Paths.getSparrowAtlas(path, 'shared') : Paths.getSparrowAtlas('noteskins/Arrows$typeSuffix', "shared");

		// return Paths.getSparrowAtlas('noteskins/' + NoteskinHelpers.getNoteskinByID(FlxG.save.data.noteskin), "shared");
		// #else
		// return Paths.getSparrowAtlas('noteskins/Arrows', "shared");
		// #end
	}

	static public function generatePixelSprite(id:Int, ends:Bool = false, typeSpecial:Int = 0, otherWayAround:Bool = false)
	{
		var typeSuffix:String = generateTypePostFix(typeSpecial);
		// #if FEATURE_FILESYSTEM
		// TODO: Make this use OpenFlAssets.
		// JOELwindows7: alright, let's slay these & just simplify!

		Debug.logTrace("bruh momento id=" + Std.int(id) + " ends=" + Std.string(ends));

		var path = 'noteskins/${getNoteskinByID(id)}-pixel${(ends ? "-ends" : "")}${typeSuffix}'; // JOELwindows7: simpler
		if (otherWayAround)
			path = 'noteskins/${getNoteskinByID(id)}/arrows${ends ? "Ends" : "-pixels"}${typeSuffix}';
		// var path = FileSystem.absolutePath("assets/shared/images/noteskins")
		// 	+ "/"
		// 	+ getNoteskinByID(id)
		// 	+ "-pixel"
		// 	+ (ends ? "-ends" : "")
		// 	+ typeSuffix; // JOELwindows7: watch the png path
		// if (otherWayAround)
		// {
		// 	path = FileSystem.absolutePath("assets/shared/images/noteskins")
		// 		+ "/"
		// 		+ getNoteskinByID(id)
		// 		+ "/arrows"
		// 		+ (ends ? "Ends" : "-pixels")
		// 		+ typeSuffix; // JOELwindows7: watch the png path
		// }
		// if (!FileSystem.exists(path + ".png"))
		// {
		// 	Debug.logTrace("getting default pixel skin");
		// 	return BitmapData.fromFile(FileSystem.absolutePath("assets/shared/images/noteskins") + "/Arrows-pixel" + (ends ? "-ends" : "") + ".png");
		// }
		Debug.logInfo("now load path " + path);
		// return BitmapData.fromFile(path + ".png");

		// return Paths.doesImageAssetExist(Paths.image(path,
		// 	'shared')) ? BitmapData.fromFile(Paths.image(path, 'shared')) : BitmapData.fromFile(Paths.image('noteskins/Arrows-pixel', "shared"));
		// return Paths.doesImageAssetExist(Paths.image(path,
		// 	'shared')) ? BitmapData.loadFromFile(Paths.image(path, 'shared'))
		// 	.result() : BitmapData.loadFromFile(Paths.image('noteskins/Arrows-pixel', "shared")).result();
		// return Paths.doesImageAssetExist(Paths.image(path,
		// 	'shared')) ? BitmapData.loadFromFile(Asset2File.getPath(Paths.image(path, 'shared')))
		// 	.result() : BitmapData.loadFromFile(Asset2File.getPath(Paths.image('noteskins/Arrows-pixel', "shared"))).result();
		// return Paths.getSparrowAtlas('noteskins/' + NoteskinHelpers.getNoteskinByID(FlxG.save.data.noteskin), "shared");

		// return Paths.doesImageAssetExist(Paths.image(path,
		// 'shared')) ? Paths.loadBitmap(path, 'shared') : Paths.loadBitmap('noteskins/Arrows-pixel', "shared");
		// JOELwindows7: NEW BOLO way
		return Paths.doesImageAssetExist(Paths.image(path, 'shared')) ? Paths.imageGraphic(path, 'shared') : Paths.imageGraphic('noteskins/Arrows-pixel', "shared");
		// #else
		// // return BitmapData.fromFile(Paths.image('noteskins/Arrows-pixel', "shared"));
		// // JOELwindows7:here because Android requires Asset2File
		// // return BitmapData.fromFile(#if !mobile Paths.image('noteskins/Arrows-pixel',
		// // 	"shared") #else Asset2File.getPath(Paths.image('noteskins/Arrows-pixel', "shared")) #end);
		// return BitmapData.fromFile(Asset2File.getPath(Paths.image('noteskins/Arrows-pixel$typtypeSuffix', "shared")));
		// #end
		// JOELwindows7: wtf, new way doesn't work for pixel noteskins??!?!??!?!?!??!?!?
		// only `FileSystem`er??!??!?!
	}

	// JOELwindows7: this is string version of it.
	static public function generatePixelSpriteFromSay(say:String, ends:Bool = false, typeSpecial:Int = 0, otherWayAround:Bool = false)
	{
		var typeSuffix:String = generateTypePostFix(typeSpecial);
		// #if FEATURE_FILESYSTEM
		// TODO: Make this use OpenFlAssets.
		// JOELwindows7: make simpler!

		Debug.logTrace("bruh momento name=" + say + " ends=" + Std.string(ends));
		var path = 'noteskins/${say}-pixel${ends ? "-ends" : ""}${typeSuffix}'; // JOELwindows7: simpler
		if (otherWayAround)
			path = 'noteskins/${say}/arrows${ends ? "Ends" : "-pixels"}${typeSuffix}';
		// var path = FileSystem.absolutePath("assets/shared/images/noteskins")
		// 	+ "/"
		// 	+ say
		// 	+ "-pixel"
		// 	+ (ends ? "-ends" : "")
		// 	+ typeSuffix; // JOELwindows7: watch the png path
		// if (otherWayAround)
		// {
		// 	path = FileSystem.absolutePath("assets/shared/images/noteskins")
		// 		+ "/"
		// 		+ say
		// 		+ "/arrows"
		// 		+ (ends ? "Ends" : "-pixels")
		// 		+ typeSuffix; // JOELwindows7: watch the png path
		// }
		// if (!FileSystem.exists(say + ".png"))
		// {
		// 	Debug.logTrace("getting default pixel skin");
		// 	return BitmapData.fromFile(FileSystem.absolutePath("assets/shared/images/noteskins") + "/Arrows-pixel" + (ends ? "-ends" : "") + ".png");
		// }
		Debug.logInfo("now load path " + path);
		// return BitmapData.fromFile(path + ".png");
		// return Paths.doesImageAssetExist(Paths.image(path,
		// 	'shared')) ? BitmapData.fromFile(Paths.image(path, 'shared')) : BitmapData.fromFile(Paths.image('noteskins/Arrows-pixel', "shared"));
		// return Paths.doesImageAssetExist(Paths.image(path,
		// 	'shared')) ? BitmapData.loadFromFile(Asset2File.getPath(Paths.image(path, 'shared')))
		// 	.result() : BitmapData.loadFromFile(Asset2File.getPath(Paths.image('noteskins/Arrows-pixel', "shared"))).result();

		// return Paths.doesImageAssetExist(Paths.image(path,
		// 	'shared')) ? Paths.loadBitmap(path, 'shared') : Paths.loadBitmap('noteskins/Arrows-pixel', "shared");
		// JOELwindows7: NEW BOLO way
		return Paths.doesImageAssetExist(Paths.image(path,
			'shared')) ? Paths.imageGraphic(path, 'shared') : Paths.imageGraphic('noteskins/Arrows-pixel', "shared");
		// #else
		// return BitmapData.fromFile(Asset2File.getPath(Paths.image('noteskins/Arrows-pixel$typetypeSuffix', "shared")));
		// #end
	} // JOELwindows7: generate type postfix for which note type yey. usual, mine, power ups?

	static public function generateTypePostFix(typeSpecial:Int = 0)
	{
		return switch (typeSpecial)
		{
			case 0:
				"";
			case 1:
				"";
			case 2:
				"-mine";
			case _:
				"";
		};
	}

	// JOELwindows7: I'm very hungry
	public static function giveMeNoteSkinPath(noteType:Int = 0, pixel:Bool = false, pixelEnd:Bool = false):String
	{
		return 'noteskins/'
			+ PlayState.SONG.noteStyle
			+ (PlayState.SONG.loadNoteStyleOtherWayAround ? '/' + (pixel ? (pixelEnd ? 'arrowEnds' : 'arrows-pixels') : 'NOTE_assets') : '');
		// JOELwindows7: nom so complicated!
	}

	// JOELwindows7: No! I don't want that
	static public function giveMeRealNoteSkinPath(say:String, noteType:Int = 0, pixel:Bool = false, pixelEnd:Bool = false)
	{
		// #if FEATURE_FILESYSTEM
		// return FileSystem.absolutePath("assets/shared/images/noteskins") + "/" + say + "/";
		// #else
		// return Paths.image('noteskins/' + say, "shared");
		// #end
		return Asset2File.getPath(Paths.image('noteskins/' + say, "shared"));
	}
}
