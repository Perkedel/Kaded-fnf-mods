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
			if (i.contains("-pixel")
				|| i.contains("-mine")
				|| i.contains("-special")
				|| i.contains("-important")
				|| i.contains("-never"))
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

	static public function generateNoteskinSprite(id:Int, typeSpecial:Int = 0) // JOELwindows7: add type of it.
	{
		#if FEATURE_FILESYSTEM
		// TODO: Make this use OpenFlAssets.

		Debug.logTrace("bruh momento id=" + Std.string(id) + " typeSpecial=" + Std.string(typeSpecial));

		var typeSuffix:String;
		switch (typeSpecial)
		{
			case 0:
				typeSuffix = "";
			case 1:
				typeSuffix = "";
			case 2:
				typeSuffix = "-mine";
			default:
				typeSuffix = "";
		}

		var path = FileSystem.absolutePath("assets/shared/images/noteskins") + "/" + getNoteskinByID(id) + typeSuffix; // JOELwindows7: watch the xml path
		var data:BitmapData = BitmapData.fromFile(path + ".png");

		return FlxAtlasFrames.fromSparrow(FlxGraphic.fromBitmapData(data), xmlData[id]);

		// return Paths.getSparrowAtlas('noteskins/' + NoteskinHelpers.getNoteskinByID(FlxG.save.data.noteskin), "shared");
		#else
		switch (typeSpecial)
		{
			case 0:
			case 1:
			case 2:
				return Paths.getSparrowAtlas('noteskins/Arrows-mine', "shared");
			default:
		}
		return Paths.getSparrowAtlas('noteskins/Arrows', "shared");
		#end
	}

	static public function generatePixelSprite(id:Int, ends:Bool = false)
	{
		#if FEATURE_FILESYSTEM
		// TODO: Make this use OpenFlAssets.

		Debug.logTrace("bruh momento id=" + Std.int(id) + " ends=" + Std.string(ends));

		var path = FileSystem.absolutePath("assets/shared/images/noteskins") + "/" + getNoteskinByID(id) + "-pixel" + (ends ? "-ends" : "");
		if (!FileSystem.exists(path + ".png"))
		{
			Debug.logTrace("getting default pixel skin");
			return BitmapData.fromFile(FileSystem.absolutePath("assets/shared/images/noteskins") + "/Arrows-pixel" + (ends ? "-ends" : "") + ".png");
		}
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
}
