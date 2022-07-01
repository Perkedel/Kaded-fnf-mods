import CoreState;
#if openfl
import openfl.system.System;
#end
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import flixel.FlxG;
import haxe.Timer;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;
#if gl_stats
import openfl.display._internal.stats.Context3DStats;
import openfl.display._internal.stats.DrawCallContext;
#end
#if flash
import openfl.Lib;
#end

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class KadeEngineFPS extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;

	public static var extraInfo:String; // JOELwindows7: extra text to be placed underneath.
	public static var extraLoadingText:String; // JOELwindows7: loading text to be placed underneath.
	public static var extraLoadingBar:String; // JOELwindows7: loading bar to be placed underneath. fancy SHOOM loading bar.
	public static var extraLoadingPercentage:Float; // JOELwindows7: loading percentage to be placed underneath.
	public static var extraLoadingType:ExtraLoadingType = ExtraLoadingType.NONE; // JOELwindows7: loading type to be placed underneath.
	static var _vague_space_left:Int = 0; // JOELwindows7: vague space left to be placed underneath.
	static var _vague_space_right:Int = 10; // JOELwindows7: vague space right to be placed underneath.
	static var _vague_goToLeft:Bool = false; // JOELwindows7: vague direction to be placed underneath.
	public static var extraLoadingSpinner:String = "-"; // JOELwindows7: loading spinner to be placed underneath.
	public static var extraLoadingSpinnerIndex:Int = 0; // JOELwindows7: loading spinner index to be placed underneath. `-`,`\`,`|`,`/`
	public static var showLoadingText:Bool; // JOELwindows7: visibility of loading text

	public var memoryUsage:Float;
	public var imInDanger:Bool = false; // JOELwindows7: flag whether memory is low or FPS too low
	// JOELwindows7: kay, you know what? why not just detail which one that went wrong?
	public var memoryUsageTooHigh:Bool = false;
	public var fpsTooLow:Bool = false;

	public var bitmap:Bitmap;

	@:noCompletion private var cacheCount:Int;
	@:noCompletion private var currentTime:Float;
	@:noCompletion private var times:Array<Float>;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat(openfl.utils.Assets.getFont("assets/fonts/vcr.ttf").fontName, 14, color);
		text = "FPS: ";
		width += 200;

		cacheCount = 0;
		currentTime = 0;
		times = [];

		#if flash
		addEventListener(Event.ENTER_FRAME, function(e)
		{
			var time = Lib.getTimer();
			__enterFrame(time - currentTime);
		});
		#end
	}

	var array:Array<FlxColor> = [
		FlxColor.fromRGB(148, 0, 211),
		FlxColor.fromRGB(75, 0, 130),
		FlxColor.fromRGB(0, 0, 255),
		FlxColor.fromRGB(0, 255, 0),
		FlxColor.fromRGB(255, 255, 0),
		FlxColor.fromRGB(255, 127, 0),
		FlxColor.fromRGB(255, 0, 0)
	];

	var skippedFrames = 0;

	public static var currentColor = 0;

	// JOELwindows7: set loading text
	public static function setLoadingText(text:String):Void
	{
		extraLoadingText = text;
	}

	// JOELwindows7: set loading percentage
	public static function setLoadingPercentage(percentage:Float):Void
	{
		extraLoadingPercentage = percentage;
	}

	// JOELwindows7: set loading type
	public static function setLoadingType(type:ExtraLoadingType):Void
	{
		extraLoadingType = type;
	}

	// JOELwindows7: set visibility of loading text
	public static function setLoadingTextVisibility(visible:Bool):Void
	{
		showLoadingText = visible;
	}

	// JOELwindows7 enable/disable loading text
	public static function toggleLoadingText():Void
	{
		showLoadingText = !showLoadingText;
	}

	// Event Handlers
	@:noCompletion
	private #if !flash override #end function __enterFrame(deltaTime:Float):Void
	{
		// JOELwindows7: clear extra info text beforehand
		extraInfo = "";
		if (extraLoadingPercentage > 100)
			extraLoadingPercentage = 100;
		if (extraLoadingPercentage < 0)
			extraLoadingPercentage = 0;

		// JOELwindows7: show loading text
		if (showLoadingText)
		{
			if (extraLoadingSpinnerIndex > 3)
				extraLoadingSpinnerIndex = 0;
			switch (extraLoadingSpinnerIndex)
			{
				case 0:
					extraLoadingSpinner = "-";
				case 1:
					extraLoadingSpinner = "\\";
				case 2:
					extraLoadingSpinner = "|";
				case 3:
					extraLoadingSpinner = "/";
			}
			if (extraLoadingType == ExtraLoadingType.GOING || extraLoadingType == ExtraLoadingType.VAGUE)
				extraLoadingSpinnerIndex++;
			switch (extraLoadingType)
			{
				case ExtraLoadingType.NONE:
					extraLoadingBar = "[            ]";
				case ExtraLoadingType.VAGUE:
					// extraLoadingBar = "[" + String.fromCharCode(0x2588) + "           ]";
					extraLoadingBar = "[SH";
					for (i in 0...Std.int(_vague_space_left / 10))
					{
						extraLoadingBar += "o";
					}
					extraLoadingBar += "O";
					if (_vague_goToLeft)
					{
						_vague_space_left -= 1;
						_vague_space_right += 1;
						if (_vague_space_left <= 0)
						{
							_vague_goToLeft = false;
						}
					}
					else
					{
						_vague_space_left += 1;
						_vague_space_right -= 1;
						if (_vague_space_right <= 0)
						{
							_vague_goToLeft = true;
						}
					}
					for (i in 0...Std.int(_vague_space_right / 10))
					{
						extraLoadingBar += "o";
					}
					extraLoadingBar += "M]";
				case ExtraLoadingType.GOING:
					extraLoadingBar = "[SH";
					var leftHowMuch:Int = 10;
					for (i in 0...Std.int(extraLoadingPercentage / 10))
					{
						extraLoadingBar += "O";
						leftHowMuch--;
					}
					for (i in 0...leftHowMuch)
					{
						extraLoadingBar += "_";
					}
					extraLoadingBar += "M]";
				case ExtraLoadingType.DONE:
					extraLoadingBar = "[COOL & GOOD!]";
				default:
			}
			extraInfo += extraLoadingText + "\n" + extraLoadingSpinner + " " + extraLoadingBar + "\n";
		}
		else
		{
			extraInfo += "";
		}

		if (MusicBeatState.initSave)
			if (FlxG.save.data.fpsRain)
			{
				if (currentColor >= array.length)
					currentColor = 0;
				currentColor = Math.round(FlxMath.lerp(0, array.length, skippedFrames / (FlxG.save.data.fpsCap / 3)));
				(cast(Lib.current.getChildAt(0), Main)).changeFPSColor(array[currentColor]);
				currentColor++;
				skippedFrames++;
				if (skippedFrames > (FlxG.save.data.fpsCap / 3))
					skippedFrames = 0;
			}
			else
			{
				// JOELwindows7: the color signifies danger Psychedly then.
				if (imInDanger)
				{
					// textColor = FlxColor.fromRGB(255, 0, 0);
					// textColor = FlxColor.RED;
					(cast(Lib.current.getChildAt(0), Main)).changeFPSColor(FlxColor.RED);
				}
				else
				{
					// textColor = FlxColor.fromRGB(255, 255, 255);
					// textColor = FlxColor.WHITE;
					(cast(Lib.current.getChildAt(0), Main)).changeFPSColor(FlxColor.WHITE);
				}
			}

		currentTime += deltaTime;
		times.push(currentTime);

		while (times[0] < currentTime - 1000)
		{
			times.shift();
		}

		var currentCount = times.length;
		currentFPS = Math.round((currentCount + cacheCount) / 2);

		if (currentCount != cacheCount /*&& visible*/)
		{
			// JOELwindows7: here comes the Psyched memory RAM megas!
			// https://github.com/ShadowMario/FNF-PsychEngine/blob/main/source/openfl/display/FPS.hx
			// var memoryMegas:Float = 0; // already globalized!

			/*
				text = (FlxG.save.data.fps ? "FPS: "
					+ currentFPS
					+ (Main.watermarks ? "\nKE " + "v" + MainMenuState.kadeEngineVer : "") 
					// JOELwindows7: time to add our watermark yey
					+ (Main.perkedelMark ? "\nLFM " + MainMenuState.lastFunkinMomentVer : "")
					: //JOELwindows7: if no show FPS
					(Main.watermarks ? "KE " + "v" + MainMenuState.kadeEngineVer : "")
					//JOELwindows7: time to add our watermark yey
					+ (Main.perkedelMark ? "\nLFM " + MainMenuState.lastFunkinMomentVer : "")
					);
			 */
			// JOELwindows7: Kade, STOP! this kind of comparison is cringe! why not do it like this:
			text = (FlxG.save.data.fps ? "FPS: " + currentFPS + "\n" : "");
			#if openfl
			// JOELwindows7: get RAM usage Psychedly.
			memoryUsage = Math.abs(FlxMath.roundDecimal(System.totalMemory / 1000000, 1));
			text += (FlxG.save.data.memoryDisplay ? 'Memory: $memoryUsage MB\n' : ""); // JOELwindows7: get the BOLO memory display option!
			// here's BOLO's implementation https://github.com/BoloVEVO/Kade-Engine-Public/blob/stable/source/KadeEngineFPS.hx
			#end
			text += (Main.watermarks ? "KE " + "v" + MainMenuState.kadeEngineVer + "\n" : "");
			text += (Main.perkedelMark ? "LFM v" + MainMenuState.lastFunkinMomentVer + "\n" : "");
			// JOELwindows7: OH COOL!! GREAT IDEA, BOLO. Debug mode indicator, yess!!!
			text += (#if debug "DEBUG MODE" #else "" #end);
			text += extraInfo; // JOELwindows7: see, not that hard. I know it's not perfect but should shorten it this.
			// remember to have \n at the beginning of the line at available if case.
			// No, at the end of line at available if case. + "\n" one.

			// JOELwindows7: psyched check danger status
			// JOELwindows7: Okay, on second thought you know what? let's just tell which one is in danger.
			memoryUsageTooHigh = memoryUsage > 3000;
			fpsTooLow = currentFPS <= 60;
			// if (memoryUsage > 3000 || currentFPS <= FlxG.save.data.fpsCap / 2)
			if (memoryUsageTooHigh || fpsTooLow) // JOELwindows7: no uuuh, Why half of the fps cap? perhaps, panic only if uh..
				// you just have FPS lower than what considerable as lag usually? idk I guess...
			{
				imInDanger = true;
			}
			else
			{
				imInDanger = false;
			}

			#if (gl_stats && !disable_cffi && (!html5 || !canvas))
			text += "\ntotalDC: " + Context3DStats.totalDrawCalls();

			text += "\nstageDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE);
			text += "\nstage3DDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE3D);
			#end
			// JOELwindows7: make sure there's a newline at the end of the line due to bug last line ommited here.
			text += "\n";
		}

		if (FlxG.save.data.fpsBorder)
		{
			visible = true;
			Main.instance.removeChild(bitmap);

			bitmap = ImageOutline.renderImage(this, 2, 0x000000, 1);

			Main.instance.addChild(bitmap);
			visible = false;
		}
		else
		{
			visible = true;
			if (Main.instance.contains(bitmap))
				Main.instance.removeChild(bitmap);
		}

		cacheCount = currentCount;
	}
}
