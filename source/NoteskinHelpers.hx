#if FEATURE_FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end
import openfl.display.BitmapData;
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
			// these are pixel, mine do not step, special power up, important must step or ded, never step or ded. idk.
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
		noteskinArray = ["Arrows", "Circles", "Saubo"]; // JOELwindows7: lemme pecking try this. ugh so confusing!
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
		#if FEATURE_FILESYSTEM
		// TODO: Make this use OpenFlAssets.

		Debug.logTrace("bruh momento id=" + Std.string(id) + " typeSpecial=" + Std.string(typeSpecial));

		var path = FileSystem.absolutePath("assets/shared/images/noteskins")
			+ "/"
			+ getNoteskinByID(id)
			+ (otherWayAround ? "/NOTE_assets" : "")
			+ typeSuffix; // JOELwindows7: watch the xml path
		if (!FileSystem.exists(path + ".xml"))
		{
			// JOELwindows7: If not exist
			// Debug.logTrace("getting default SparrowAtlas skin");
			// return Paths.getSparrowAtlas('noteskins/Arrows', "shared");
			path = FileSystem.absolutePath("assets/shared/images/noteskins") + "/" + "Arrows" + typeSuffix;
		}
		// Debug.logInfo("now load path " + path);
		var data:BitmapData = BitmapData.fromFile(path + ".png");

		return FlxAtlasFrames.fromSparrow(FlxGraphic.fromBitmapData(data), xmlData[id]);

		// return Paths.getSparrowAtlas('noteskins/' + NoteskinHelpers.getNoteskinByID(FlxG.save.data.noteskin), "shared");
		#else
		return Paths.getSparrowAtlas('noteskins/Arrows', "shared");
		#end
	}

	// JOELwindows7: this is string version
	static public function generateNoteskinSpriteFromSay(say:String, typeSpecial:Int = 0, otherWayAround:Bool = false)
	{
		var typeSuffix:String = generateTypePostFix(typeSpecial);
		#if FEATURE_FILESYSTEM
		// TODO: Make this use OpenFlAssets.

		Debug.logTrace("bruh momento name=" + say + " typeSpecial=" + Std.string(typeSpecial));

		var path = FileSystem.absolutePath("assets/shared/images/noteskins")
			+ "/"
			+ say
			+ (otherWayAround ? "/NOTE_assets" : "")
			+ typeSuffix; // JOELwindows7: watch the xml path
		if (!FileSystem.exists(path + ".xml"))
		{
			// JOELwindows7: If not exist
			// Debug.logTrace("getting default SparrowAtlas skin");
			// return Paths.getSparrowAtlas('noteskins/Arrows', "shared");
			path = FileSystem.absolutePath("assets/shared/images/noteskins") + "/" + "Arrows" + typeSuffix;
		}
		// Debug.logInfo("now load path " + path);
		var data:BitmapData = BitmapData.fromFile(path + ".png");

		return FlxAtlasFrames.fromSparrow(FlxGraphic.fromBitmapData(data), sys.io.File.getContent(path + ".xml"));

		// return Paths.getSparrowAtlas('noteskins/' + NoteskinHelpers.getNoteskinByID(FlxG.save.data.noteskin), "shared");
		#else
		return Paths.getSparrowAtlas('noteskins/Arrows', "shared");
		#end
	}

	static public function generatePixelSprite(id:Int, ends:Bool = false, typeSpecial:Int = 0, otherWayAround:Bool = false)
	{
		var typeSuffix:String = generateTypePostFix(typeSpecial);
		#if FEATURE_FILESYSTEM
		// TODO: Make this use OpenFlAssets.

		Debug.logTrace("bruh momento id=" + Std.int(id) + " ends=" + Std.string(ends));

		var path = FileSystem.absolutePath("assets/shared/images/noteskins")
			+ "/"
			+ getNoteskinByID(id)
			+ "-pixel"
			+ (ends ? "-ends" : "")
			+ typeSuffix; // JOELwindows7: watch the png path
		if (otherWayAround)
		{
			path = FileSystem.absolutePath("assets/shared/images/noteskins")
				+ "/"
				+ getNoteskinByID(id)
				+ "/arrows"
				+ (ends ? "Ends" : "-pixels")
				+ typeSuffix; // JOELwindows7: watch the png path
		}
		if (!FileSystem.exists(path + ".png"))
		{
			Debug.logTrace("getting default pixel skin");
			return BitmapData.fromFile(FileSystem.absolutePath("assets/shared/images/noteskins") + "/Arrows-pixel" + (ends ? "-ends" : "") + ".png");
		}
		Debug.logInfo("now load path " + path);
		return BitmapData.fromFile(path + ".png");

		// return Paths.getSparrowAtlas('noteskins/' + NoteskinHelpers.getNoteskinByID(FlxG.save.data.noteskin), "shared");
		#else
		// return BitmapData.fromFile(Paths.image('noteskins/Arrows-pixel', "shared"));
		// JOELwindows7: here because Android requires Asset2File
		// return BitmapData.fromFile(#if !mobile Paths.image('noteskins/Arrows-pixel',
		// 	"shared") #else Asset2File.getPath(Paths.image('noteskins/Arrows-pixel', "shared")) #end);
		return BitmapData.fromFile(Asset2File.getPath(Paths.image('noteskins/Arrows-pixel', "shared")));
		#end
	}

	// JOELwindows7: this is string version of it.
	static public function generatePixelSpriteFromSay(say:String, ends:Bool = false, typeSpecial:Int = 0, otherWayAround:Bool = false)
	{
		var typeSuffix:String = generateTypePostFix(typeSpecial);
		#if FEATURE_FILESYSTEM
		// TODO: Make this use OpenFlAssets.

		Debug.logTrace("bruh momento name=" + say + " ends=" + Std.string(ends));
		var path = FileSystem.absolutePath("assets/shared/images/noteskins")
			+ "/"
			+ say
			+ "-pixel"
			+ (ends ? "-ends" : "")
			+ typeSuffix; // JOELwindows7: watch the png path
		if (otherWayAround)
		{
			path = FileSystem.absolutePath("assets/shared/images/noteskins")
				+ "/"
				+ say
				+ "/arrows"
				+ (ends ? "Ends" : "-pixels")
				+ typeSuffix; // JOELwindows7: watch the png path
		}
		if (!FileSystem.exists(say + ".png"))
		{
			Debug.logTrace("getting default pixel skin");
			return BitmapData.fromFile(FileSystem.absolutePath("assets/shared/images/noteskins") + "/Arrows-pixel" + (ends ? "-ends" : "") + ".png");
		}
		Debug.logInfo("now load path " + path);
		return BitmapData.fromFile(path + ".png");
		#else
		return BitmapData.fromFile(Asset2File.getPath(Paths.image('noteskins/Arrows-pixel', "shared")));
		#end
	}

	// JOELwindows7: generate type postfix for which note type yey. usual, mine, power ups?
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
