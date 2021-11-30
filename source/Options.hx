package;

import GalleryAchievements;
#if gamejolt
import GameJolt;
#end
import experiments.AnMIDIyeay;
import experiments.AnWebmer;
import experiments.LimeAudioBufferTester;
import experiments.*;
import openfl.net.FileFilter;
import haxe.Json;
import openfl.net.FileReference;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import lime.app.Application;
import lime.system.DisplayMode;
import flixel.util.FlxColor;
import Controls.KeyboardScheme;
import flixel.FlxG;
import openfl.display.FPS;
import openfl.Lib;

using StringTools;

class Option
{
	public function new()
	{
		display = updateDisplay();
	}

	private var description:String = "";
	private var display:String;
	private var acceptValues:Bool = false;

	public var acceptType:Bool = false;

	public var waitingType:Bool = false;

	public final function getDisplay():String
	{
		return display;
	}

	public final function getAccept():Bool
	{
		return acceptValues;
	}

	public final function getDescription():String
	{
		return description;
	}

	public function getValue():String
	{
		return updateDisplay();
	};

	public function onType(text:String)
	{
	}

	// Returns whether the label is to be updated.
	public function press():Bool
	{
		return true;
	}

	private function updateDisplay():String
	{
		return "";
	}

	public function left():Bool
	{
		return false;
	}

	public function right():Bool
	{
		return false;
	}
}

class DFJKOption extends Option
{
	public function new()
	{
		super();
		description = "Edit your keybindings";
	}

	public override function press():Bool
	{
		OptionsMenu.instance.selectedCatIndex = 6; // JOELwindows7: was 4. really, why order number?!
		OptionsMenu.instance.switchCat(OptionsMenu.instance.options[6], false); // JOELwindows7: don't forget this too
		return false;
	}

	private override function updateDisplay():String
	{
		return "Edit Keybindings";
	}
}

class UpKeybind extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptType = true;
	}

	public override function onType(text:String)
	{
		if (waitingType)
		{
			FlxG.save.data.upBind = text;
			waitingType = false;
		}
	}

	public override function press()
	{
		Debug.logTrace("keybind change");
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String
	{
		return "UP: " + (waitingType ? "> " + FlxG.save.data.upBind + " <" : FlxG.save.data.upBind) + "";
	}
}

class DownKeybind extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptType = true;
	}

	public override function onType(text:String)
	{
		if (waitingType)
		{
			FlxG.save.data.downBind = text;
			waitingType = false;
		}
	}

	public override function press()
	{
		Debug.logTrace("keybind change");
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String
	{
		return "DOWN: " + (waitingType ? "> " + FlxG.save.data.downBind + " <" : FlxG.save.data.downBind) + "";
	}
}

class RightKeybind extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptType = true;
	}

	public override function onType(text:String)
	{
		if (waitingType)
		{
			FlxG.save.data.rightBind = text;
			waitingType = false;
		}
	}

	public override function press()
	{
		Debug.logTrace("keybind change");
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String
	{
		return "RIGHT: " + (waitingType ? "> " + FlxG.save.data.rightBind + " <" : FlxG.save.data.rightBind) + "";
	}
}

class LeftKeybind extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptType = true;
	}

	public override function onType(text:String)
	{
		if (waitingType)
		{
			FlxG.save.data.leftBind = text;
			waitingType = false;
		}
	}

	public override function press()
	{
		Debug.logTrace("keybind change");
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String
	{
		return "LEFT: " + (waitingType ? "> " + FlxG.save.data.leftBind + " <" : FlxG.save.data.leftBind) + "";
	}
}

class PauseKeybind extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptType = true;
	}

	public override function onType(text:String)
	{
		if (waitingType)
		{
			FlxG.save.data.pauseBind = text;
			waitingType = false;
		}
	}

	public override function press()
	{
		Debug.logTrace("keybind change");
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String
	{
		return "PAUSE: " + (waitingType ? "> " + FlxG.save.data.pauseBind + " <" : FlxG.save.data.pauseBind) + "";
	}
}

class ResetBind extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptType = true;
	}

	public override function onType(text:String)
	{
		if (waitingType)
		{
			FlxG.save.data.resetBind = text;
			waitingType = false;
		}
	}

	public override function press()
	{
		Debug.logTrace("keybind change");
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String
	{
		return "RESET: " + (waitingType ? "> " + FlxG.save.data.resetBind + " <" : FlxG.save.data.resetBind) + "";
	}
}

class MuteBind extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptType = true;
	}

	public override function onType(text:String)
	{
		if (waitingType)
		{
			FlxG.save.data.muteBind = text;
			waitingType = false;
		}
	}

	public override function press()
	{
		Debug.logTrace("keybind change");
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String
	{
		return "VOLUME MUTE: " + (waitingType ? "> " + FlxG.save.data.muteBind + " <" : FlxG.save.data.muteBind) + "";
	}
}

class VolUpBind extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptType = true;
	}

	public override function onType(text:String)
	{
		if (waitingType)
		{
			FlxG.save.data.volUpBind = text;
			waitingType = false;
		}
	}

	public override function press()
	{
		Debug.logTrace("keybind change");
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String
	{
		return "VOLUME UP: " + (waitingType ? "> " + FlxG.save.data.volUpBind + " <" : FlxG.save.data.volUpBind) + "";
	}
}

class VolDownBind extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptType = true;
	}

	public override function onType(text:String)
	{
		if (waitingType)
		{
			FlxG.save.data.volDownBind = text;
			waitingType = false;
		}
	}

	public override function press()
	{
		Debug.logTrace("keybind change");
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String
	{
		return "VOLUME DOWN: " + (waitingType ? "> " + FlxG.save.data.volDownBind + " <" : FlxG.save.data.volDownBind) + "";
	}
}

class FullscreenBind extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptType = true;
	}

	public override function onType(text:String)
	{
		if (waitingType)
		{
			FlxG.save.data.fullscreenBind = text;
			waitingType = false;
		}
	}

	public override function press()
	{
		Debug.logTrace("keybind change");
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String
	{
		return "FULLSCREEN:  " + (waitingType ? "> " + FlxG.save.data.fullscreenBind + " <" : FlxG.save.data.fullscreenBind) + "";
	}
}

class SickMSOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc + " (Press R to reset)";
		acceptType = true;
	}

	public override function left():Bool
	{
		FlxG.save.data.sickMs--;
		if (FlxG.save.data.sickMs < 0)
			FlxG.save.data.sickMs = 0;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		FlxG.save.data.sickMs++;
		display = updateDisplay();
		return true;
	}

	public override function onType(char:String)
	{
		if (char.toLowerCase() == "r")
			FlxG.save.data.sickMs = 45;
	}

	private override function updateDisplay():String
	{
		return "SICK: < " + FlxG.save.data.sickMs + " ms >";
	}
}

class GoodMsOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc + " (Press R to reset)";
		acceptType = true;
	}

	public override function left():Bool
	{
		FlxG.save.data.goodMs--;
		if (FlxG.save.data.goodMs < 0)
			FlxG.save.data.goodMs = 0;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		FlxG.save.data.goodMs++;
		display = updateDisplay();
		return true;
	}

	public override function onType(char:String)
	{
		if (char.toLowerCase() == "r")
			FlxG.save.data.goodMs = 90;
	}

	private override function updateDisplay():String
	{
		return "GOOD: < " + FlxG.save.data.goodMs + " ms >";
	}
}

class BadMsOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc + " (Press R to reset)";
		acceptType = true;
	}

	public override function left():Bool
	{
		FlxG.save.data.badMs--;
		if (FlxG.save.data.badMs < 0)
			FlxG.save.data.badMs = 0;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		FlxG.save.data.badMs++;
		display = updateDisplay();
		return true;
	}

	public override function onType(char:String)
	{
		if (char.toLowerCase() == "r")
			FlxG.save.data.badMs = 135;
	}

	private override function updateDisplay():String
	{
		return "BAD: < " + FlxG.save.data.badMs + " ms >";
	}
}

class ShitMsOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc + " (Press R to reset)";
		acceptType = true;
	}

	public override function left():Bool
	{
		FlxG.save.data.shitMs--;
		if (FlxG.save.data.shitMs < 0)
			FlxG.save.data.shitMs = 0;
		display = updateDisplay();
		return true;
	}

	public override function onType(char:String)
	{
		if (char.toLowerCase() == "r")
			FlxG.save.data.shitMs = 160;
	}

	public override function right():Bool
	{
		FlxG.save.data.shitMs++;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "SHIT: < " + FlxG.save.data.shitMs + " ms >";
	}
}

class CpuStrums extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		FlxG.save.data.cpuStrums = !FlxG.save.data.cpuStrums;

		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		return "CPU Strums: < " + (FlxG.save.data.cpuStrums ? "Light up" : "Stay static") + " >";
	}
}

class GraphicLoading extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.cacheImages = !FlxG.save.data.cacheImages;

		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "";
	}
}

class EditorRes extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		FlxG.save.data.editorBG = !FlxG.save.data.editorBG;

		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Editor Grid: < " + (FlxG.save.data.editorBG ? "Shown" : "Hidden") + " >";
	}
}

class DownscrollOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			description = "This option cannot be toggled in the pause menu.";
		else
			description = desc;
	}

	public override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.downscroll = !FlxG.save.data.downscroll;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Scroll: < " + (FlxG.save.data.downscroll ? "Downscroll" : "Upscroll") + " >";
	}
}

class GhostTapOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		FlxG.save.data.ghost = !FlxG.save.data.ghost;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Ghost Tapping: < " + (FlxG.save.data.ghost ? "Enabled" : "Disabled") + " >";
	}
}

class AccuracyOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			description = "This option cannot be toggled in the pause menu.";
		else
			description = desc;
	}

	public override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.accuracyDisplay = !FlxG.save.data.accuracyDisplay;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Accuracy Display < " + (!FlxG.save.data.accuracyDisplay ? "off" : "on") + " >";
	}
}

class SongPositionOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			description = "This option cannot be toggled in the pause menu.";
		else
			description = desc;
	}

	public override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.songPosition = !FlxG.save.data.songPosition;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	public override function getValue():String
	{
		return "Song Position Bar: < " + (!FlxG.save.data.songPosition ? "off" : "on") + " >";
	}
}

class DistractionsAndEffectsOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			description = "This option cannot be toggled in the pause menu.";
		else
			description = desc;
	}

	public override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.distractions = !FlxG.save.data.distractions;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Distractions: < " + (!FlxG.save.data.distractions ? "off" : "on") + " >";
	}
}

class Colour extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			description = "This option cannot be toggled in the pause menu.";
		else
			description = desc;
	}

	public override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.colour = !FlxG.save.data.colour;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Colored HP Bars: < " + (FlxG.save.data.colour ? "Enabled" : "Disabled") + " >";
	}
}

class StepManiaOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			description = "This option cannot be toggled in the pause menu.";
		else
			description = desc;
	}

	public override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.stepMania = !FlxG.save.data.stepMania;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Color Quantization: < " + (!FlxG.save.data.stepMania ? "off" : "on") + " >";
	}
}

class ResetButtonOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.resetButton = !FlxG.save.data.resetButton;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Reset Button: < " + (!FlxG.save.data.resetButton ? "off" : "on") + " >";
	}
}

class InstantRespawn extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.InstantRespawn = !FlxG.save.data.InstantRespawn;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Instant Respawn: < " + (!FlxG.save.data.InstantRespawn ? "off" : "on") + " >";
	}
}

class FlashingLightsOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			description = "This option cannot be toggled in the pause menu.";
		else
			description = desc;
	}

	public override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.flashing = !FlxG.save.data.flashing;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Flashing Lights: < " + (!FlxG.save.data.flashing ? "off" : "on") + " >";
	}
}

class AntialiasingOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			description = "This option cannot be toggled in the pause menu.";
		else
			description = desc;
	}

	public override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.antialiasing = !FlxG.save.data.antialiasing;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Antialiasing: < " + (!FlxG.save.data.antialiasing ? "off" : "on") + " >";
	}
}

class MissSoundsOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			description = "This option cannot be toggled in the pause menu.";
		else
			description = desc;
	}

	public override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.missSounds = !FlxG.save.data.missSounds;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Miss Sounds: < " + (!FlxG.save.data.missSounds ? "off" : "on") + " >";
	}
}

class ShowInput extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		FlxG.save.data.inputShow = !FlxG.save.data.inputShow;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Score Screen Debug: < " + (FlxG.save.data.inputShow ? "Enabled" : "Disabled") + " >";
	}
}

class Judgement extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			description = "This option cannot be toggled in the pause menu.";
		else
			description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		OptionsMenu.instance.selectedCatIndex = 7; // JOELwindows7: was 5. don't use order!!!!
		OptionsMenu.instance.switchCat(OptionsMenu.instance.options[7], false); // JOELwindows7: don't forget this too
		return true;
	}

	private override function updateDisplay():String
	{
		return "Edit Judgements";
	}
}

class FPSOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		FlxG.save.data.fps = !FlxG.save.data.fps;
		(cast(Lib.current.getChildAt(0), Main)).toggleFPS(FlxG.save.data.fps);
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		return "FPS Counter: < " + (!FlxG.save.data.fps ? "off" : "on") + " >";
	}
}

class ScoreScreen extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.scoreScreen = !FlxG.save.data.scoreScreen;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Score Screen: < " + (FlxG.save.data.scoreScreen ? "Enabled" : "Disabled") + " >";
	}
}

class FPSCapOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		return false;
	}

	private override function updateDisplay():String
	{
		return "FPS Cap: < " + FlxG.save.data.fpsCap + " >";
	}

	override function right():Bool
	{
		if (FlxG.save.data.fpsCap >= 290)
		{
			FlxG.save.data.fpsCap = 290;
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(290);
		}
		else
			FlxG.save.data.fpsCap = FlxG.save.data.fpsCap + 10;
		(cast(Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);

		return true;
	}

	override function left():Bool
	{
		if (FlxG.save.data.fpsCap > 290)
			FlxG.save.data.fpsCap = 290;
		else if (FlxG.save.data.fpsCap < 60)
			FlxG.save.data.fpsCap = Application.current.window.displayMode.refreshRate;
		else
			FlxG.save.data.fpsCap = FlxG.save.data.fpsCap - 10;
				(cast(Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
		return true;
	}

	override function getValue():String
	{
		return updateDisplay();
	}
}

class ScrollSpeedOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		return false;
	}

	private override function updateDisplay():String
	{
		return "Scroll Speed: < " + HelperFunctions.truncateFloat(FlxG.save.data.scrollSpeed, 1) + " >";
	}

	override function right():Bool
	{
		FlxG.save.data.scrollSpeed += 0.1;

		if (FlxG.save.data.scrollSpeed < 1)
			FlxG.save.data.scrollSpeed = 1;

		if (FlxG.save.data.scrollSpeed > 4)
			FlxG.save.data.scrollSpeed = 4;
		return true;
	}

	override function getValue():String
	{
		return "Scroll Speed: < " + HelperFunctions.truncateFloat(FlxG.save.data.scrollSpeed, 1) + " >";
	}

	override function left():Bool
	{
		FlxG.save.data.scrollSpeed -= 0.1;

		if (FlxG.save.data.scrollSpeed < 1)
			FlxG.save.data.scrollSpeed = 1;

		if (FlxG.save.data.scrollSpeed > 4)
			FlxG.save.data.scrollSpeed = 4;

		return true;
	}
}

class RainbowFPSOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		FlxG.save.data.fpsRain = !FlxG.save.data.fpsRain;
		(cast(Lib.current.getChildAt(0), Main)).changeFPSColor(FlxColor.WHITE);
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		return "FPS Rainbow: < " + (!FlxG.save.data.fpsRain ? "off" : "on") + " >";
	}
}

class NPSDisplayOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		FlxG.save.data.npsDisplay = !FlxG.save.data.npsDisplay;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		return "NPS Display: < " + (!FlxG.save.data.npsDisplay ? "off" : "on") + " >";
	}
}

class ReplayOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		trace("switch");
		OptionsMenu.switchState(new LoadReplayState()); // JOELwindows7: hey, check if you are in game before hand!
		return false;
	}

	private override function updateDisplay():String
	{
		return "Load replays";
	}
}

class AccuracyDOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			description = "This option cannot be toggled in the pause menu.";
		else
			description = desc;
	}

	public override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.accuracyMod = FlxG.save.data.accuracyMod == 1 ? 0 : 1;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Accuracy Mode: < " + (FlxG.save.data.accuracyMod == 0 ? "Accurate" : "Complex") + " >";
	}
}

class CustomizeGameplay extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			description = "This option cannot be toggled in the pause menu.";
		else
			description = desc;
	}

	public override function press():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		trace("switch");
		FlxG.switchState(new GameplayCustomizeState());
		return false;
	}

	private override function updateDisplay():String
	{
		return "Customize Gameplay";
	}
}

class WatermarkOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			description = "This option cannot be toggled in the pause menu.";
		else
			description = desc;
	}

	public override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		Main.watermarks = !Main.watermarks;
		FlxG.save.data.watermark = Main.watermarks;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Watermarks: < " + (Main.watermarks ? "on" : "off") + " >";
	}
}

class OffsetMenu extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		trace("switch");

		PlayState.SONG = Song.loadFromJson('tutorial', '');
		PlayState.isStoryMode = false;
		PlayState.storyDifficulty = 0;
		PlayState.storyWeek = 0;
		PlayState.offsetTesting = true;
		trace('CUR WEEK' + PlayState.storyWeek);
		LoadingState.loadAndSwitchState(new PlayState());
		return false;
	}

	private override function updateDisplay():String
	{
		return "Time your offset";
	}
}

class OffsetThing extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			description = "This option cannot be toggled in the pause menu.";
		else
			description = desc;
	}

	public override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.offset--;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.offset++;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Note offset: < " + HelperFunctions.truncateFloat(FlxG.save.data.offset, 0) + " >";
	}

	public override function getValue():String
	{
		return "Note offset: < " + HelperFunctions.truncateFloat(FlxG.save.data.offset, 0) + " >";
	}
}

class BotPlay extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		FlxG.save.data.botplay = !FlxG.save.data.botplay;
		trace('BotPlay : ' + FlxG.save.data.botplay);
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
		return "BotPlay: < " + (FlxG.save.data.botplay ? "on" : "off") + " >";
}

class CamZoomOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			description = "This option cannot be toggled in the pause menu.";
		else
			description = desc;
	}

	public override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.camzoom = !FlxG.save.data.camzoom;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Camera Zoom: < " + (!FlxG.save.data.camzoom ? "off" : "on") + " >";
	}
}

class JudgementCounter extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			description = "This option cannot be toggled in the pause menu.";
		else
			description = desc;
	}

	public override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.judgementCounter = !FlxG.save.data.judgementCounter;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Judgement Counter: < " + (FlxG.save.data.judgementCounter ? "Enabled" : "Disabled") + " >";
	}
}

class MiddleScrollOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			description = "This option cannot be toggled in the pause menu.";
		else
			description = desc;
	}

	public override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.middleScroll = !FlxG.save.data.middleScroll;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Middle Scroll: < " + (FlxG.save.data.middleScroll ? "Enabled" : "Disabled") + " >";
	}
}

class NoteskinOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			description = "This option cannot be toggled in the pause menu.";
		else
			description = desc;
	}

	public override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.noteskin--;
		if (FlxG.save.data.noteskin < 0)
			FlxG.save.data.noteskin = NoteskinHelpers.getNoteskins().length - 1;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.noteskin++;
		if (FlxG.save.data.noteskin > NoteskinHelpers.getNoteskins().length - 1)
			FlxG.save.data.noteskin = 0;
		display = updateDisplay();
		return true;
	}

	public override function getValue():String
	{
		return "Current Noteskin: < " + NoteskinHelpers.getNoteskinByID(FlxG.save.data.noteskin) + " >";
	}
}

class HealthBarOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			description = "This option cannot be toggled in the pause menu.";
		else
			description = desc;
	}

	public override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.healthBar = !FlxG.save.data.healthBar;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Health Bar: < " + (FlxG.save.data.healthBar ? "Enabled" : "Disabled") + " >";
	}
}

class LaneUnderlayOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			description = "This option cannot be toggled in the pause menu.";
		else
			description = desc;
		acceptValues = true;
	}

	private override function updateDisplay():String
	{
		return "Lane Transparceny: < " + HelperFunctions.truncateFloat(FlxG.save.data.laneTransparency, 1) + " >";
	}

	override function right():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.laneTransparency += 0.1;

		if (FlxG.save.data.laneTransparency > 1)
			FlxG.save.data.laneTransparency = 1;
		return true;
	}

	override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.laneTransparency -= 0.1;

		if (FlxG.save.data.laneTransparency < 0)
			FlxG.save.data.laneTransparency = 0;

		return true;
	}
}

class DebugMode extends Option
{
	public function new(desc:String)
	{
		description = desc;
		super();
	}

	public override function press():Bool
	{
		FlxG.switchState(new AnimationDebug());
		return false;
	}

	private override function updateDisplay():String
	{
		return "Animation Debug";
	}
}

class LockWeeksOption extends Option
{
	var confirm:Bool = false;

	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			description = "This option cannot be toggled in the pause menu.";
		else
			description = desc;
	}

	public override function press():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		if (!confirm)
		{
			confirm = true;
			display = updateDisplay();
			return true;
		}
		FlxG.save.data.weekUnlocked = 1;
		StoryMenuState.weekUnlocked = [true, true];
		confirm = false;
		trace('Weeks Locked');
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return confirm ? "Confirm Story Reset" : "Reset Story Progress";
	}
}

class ResetScoreOption extends Option
{
	var confirm:Bool = false;

	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			description = "This option cannot be toggled in the pause menu.";
		else
			description = desc;
	}

	public override function press():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		if (!confirm)
		{
			confirm = true;
			display = updateDisplay();
			return true;
		}
		FlxG.save.data.songScores = null;
		for (key in Highscore.songScores.keys())
		{
			Highscore.songScores[key] = 0;
		}
		FlxG.save.data.songCombos = null;
		for (key in Highscore.songCombos.keys())
		{
			Highscore.songCombos[key] = '';
		}
		confirm = false;
		trace('Highscores Wiped');
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return confirm ? "Confirm Score Reset" : "Reset Score";
	}
}

class ResetSettings extends Option
{
	var confirm:Bool = false;

	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			description = "This option cannot be toggled in the pause menu.";
		else
			description = desc;
	}

	public override function press():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		if (!confirm)
		{
			confirm = true;
			display = updateDisplay();
			return true;
		}
		FlxG.save.data.weekUnlocked = null;
		FlxG.save.data.newInput = null;
		FlxG.save.data.downscroll = null;
		FlxG.save.data.antialiasing = null;
		FlxG.save.data.missSounds = null;
		FlxG.save.data.dfjk = null;
		FlxG.save.data.accuracyDisplay = null;
		FlxG.save.data.offset = null;
		FlxG.save.data.songPosition = null;
		FlxG.save.data.fps = null;
		FlxG.save.data.changedHit = null;
		FlxG.save.data.fpsRain = null;
		FlxG.save.data.fpsCap = null;
		FlxG.save.data.scrollSpeed = null;
		FlxG.save.data.npsDisplay = null;
		FlxG.save.data.frames = null;
		FlxG.save.data.accuracyMod = null;
		FlxG.save.data.watermark = null;
		FlxG.save.data.ghost = null;
		FlxG.save.data.distractions = null;
		FlxG.save.data.colour = null;
		FlxG.save.data.stepMania = null;
		FlxG.save.data.flashing = null;
		FlxG.save.data.resetButton = null;
		FlxG.save.data.botplay = null;
		FlxG.save.data.cpuStrums = null;
		FlxG.save.data.strumline = null;
		FlxG.save.data.customStrumLine = null;
		FlxG.save.data.camzoom = null;
		FlxG.save.data.scoreScreen = null;
		FlxG.save.data.inputShow = null;
		FlxG.save.data.optimize = null;
		FlxG.save.data.cacheImages = null;
		FlxG.save.data.editor = null;
		FlxG.save.data.laneTransparency = 0;

		KadeEngineData.initSave();
		confirm = false;
		trace('All settings have been reset');
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return confirm ? "Confirm Settings Reset" : "Reset Settings";
	}
}

// JOELwindows7: for future use in case it is necessary
class NoMidClickOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.noMidClick = !FlxG.save.data.noMidClick;
		trace('No Middle Click : ' + FlxG.save.data.noMidClick);
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
		return "No Middle click " + (FlxG.save.data.noMidClick ? "on" : "off");
}

// JOELwindows7: idk, that on the original game newgrounds week 7
// it had this. apparently this doesn't do anything yet.
class NaughtinessOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.naughtiness = !FlxG.save.data.naughtiness;
		trace('Naughtiness : ' + FlxG.save.data.naughtiness);
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
		return "Naughtiness < " + (FlxG.save.data.naughtiness ? "on" : "off") + " >";
}

// JOELwindows7: export setting data to JSON
class ExportSaveToJson extends Option
{
	var _file:FileReference;

	// copy over form ChartingState.hx, where JSON file is saved at.

	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.flush();

		// JOELwindows7: make save JSON pretty
		// https://haxe.org/manual/std-Json-encoding.html
		var data:String = Json.stringify(FlxG.save.data, "\t");

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), "FunkinSettings" + ".json");
		}

		return true;
	}

	private override function updateDisplay():String
		return "Export save data to JSON (BETA)";

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved BACKUP DATA.");
		// JOELwindows7: trace the success
		trace("Yay data backup saved! cool and good");
		FlxG.sound.play(Paths.sound("saveSuccess"));
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		// JOELwindows7: trace cancel
		trace("nvm! save canceled");
		FlxG.sound.play(Paths.sound('cancelMenu'));
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving backup data");
		// JOELwindows7: also trace the error
		trace("Weror! problem saving backup data");
		FlxG.sound.play(Paths.sound('cancelMenu'));
	}
}

// JOELwindows7: also the import JSON save BACKUP
class ImportSaveFromJSON extends Option
{
	var _file:FileReference;

	// copy over form ChartingState.hx, where JSON file is saved at.

	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.flush();

		// JOELwindows7: make save JSON pretty
		// https://haxe.org/manual/std-Json-encoding.html
		var data;

		_file = new FileReference();
		_file.addEventListener(Event.COMPLETE, onLoadComplete);
		_file.addEventListener(Event.CANCEL, onLoadCancel);
		_file.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);

		if (_file.browse([new FileFilter("JSON file", "json")]))
		{
			_file.load();
			data = Json.parse(cast _file.data);

			// FlxG.save.data = data;
		}

		return true;
	}

	private override function updateDisplay():String
		return "Import save data from JSON";

	function onLoadComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file = null;
		FlxG.log.notice("Successfully loaded BACKUP DATA.");
		// JOELwindows7: trace the success
		trace("Yay data backup saved! cool and good");
		// FlxG.sound.play(Paths.sound("saveSuccess"));
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onLoadCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file = null;
		// JOELwindows7: trace cancel
		trace("nvm! load canceled");
		FlxG.sound.play(Paths.sound('cancelMenu'));
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onLoadError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file = null;
		FlxG.log.error("Problem loading backup data");
		// JOELwindows7: also trace the error
		trace("Weror! problem loading backup data");
		FlxG.sound.play(Paths.sound('cancelMenu'));
	}
}

// JOELwindows7: pls don't forget full screen mode!
// Rediscovered press F in title state to toggle full screen?!?!
class FullScreenOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.fullscreen = !FlxG.fullscreen;
		trace("fullscreen is now " + Std.string(FlxG.fullscreen));
		FlxG.save.data.fullscreen = FlxG.fullscreen;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Screen mode " + (FlxG.fullscreen ? "Fullscreen" : "Windowed");
	}
}

// JOELwindows7: copy paste the toggle from above to here
class OdyseemarkOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		press(); // same as press
		return true;
	}

	public override function right():Bool
	{
		left(); // same as left
		return true;
	}

	public override function press():Bool
	{
		Main.odyseeMark = !Main.odyseeMark;
		FlxG.save.data.odyseeMark = Main.odyseeMark;
		trace("Odysee watermark: " + FlxG.save.data.odyseeMark);
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Odysee Watermarks < " + (Main.odyseeMark ? "on" : "off") + " >";
	}
}

// JOELwindows7: again do the same. change the purpose option target yeay
class PerkedelmarkOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		press(); // same as press
		return true;
	}

	public override function right():Bool
	{
		left(); // same as left
		return true;
	}

	public override function press():Bool
	{
		Main.perkedelMark = !Main.perkedelMark;
		FlxG.save.data.perkedelMark = Main.perkedelMark;
		trace("Perkedel watermark: " + FlxG.save.data.perkedelMark);
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Perkedel Watermarks < " + (Main.perkedelMark ? "on" : "off") + " >";
	}
}

// JOELwindows7: okay. we got to think ahead. there will be many watermarkers so we need to scroll choose the left right.
// here we go!
class ChooseWatermark extends Option
{
	// JOELwindows7: copy from Scroll speed option!
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}

	// Hey, add your watermark id here
	var availableWatermark = ['odysee', 'pekedel',];

	// Then add the path where it goes
	var watermarkPath = [];

	public override function press():Bool
	{
		return false;
	}

	private override function updateDisplay():String
	{
		return "Chosen Watermark " + Main.chosenMark;
	}

	override function right():Bool
	{
		Main.chosenMarkNum++;
		Main.chosenMark = availableWatermark[Main.chosenMarkNum];
		display = updateDisplay();
		return true;
	}

	override function left():Bool
	{
		Main.chosenMarkNum--;
		Main.chosenMark = availableWatermark[Main.chosenMarkNum];
		display = updateDisplay();
		return true;
	}
}

// JOELwindows7: Cardiophille options! enable heartbeat fetish features
class CardiophileOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		press(); // same as press
		return true;
	}

	public override function right():Bool
	{
		left(); // same as left
		return true;
	}

	// sentient GitHub Copilot

	public override function press():Bool
	{
		FlxG.save.data.cardiophile = !FlxG.save.data.cardiophile;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Cardiophile < " + (FlxG.save.data.cardiophile ? "on" : "off") + " >";
	}
}

// JOELwindows7: touchscreen buttons options
class UseTouchScreenButtons extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		press(); // same as press
		return true;
	}

	public override function right():Bool
	{
		left(); // same as left
		return true;
	}

	public override function press():Bool
	{
		FlxG.save.data.useTouchScreenButtons = !FlxG.save.data.useTouchScreenButtons;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		// return (FlxG.save.data.useTouchScreenButtons ? "Use Touch Screen Buttons" : "No Touch Screen Buttons");
		return "Touch Screen Buttons < " + (FlxG.save.data.useTouchScreenButtons ? "ON" : "OFF") + " >";
	}
}

class SelectTouchScreenButtons extends Option
{
	var max = 1;

	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		return false;
	}

	override function right():Bool
	{
		changeModes(1);
		display = updateDisplay();
		return true;
	}

	override function left():Bool
	{
		changeModes(-1);
		display = updateDisplay();
		return true;
	}

	function changeModes(number:Int = 0, isMoveTo:Bool = false)
	{
		var cur:Int = Std.int(FlxG.save.data.selectTouchScreenButtons);
		if (isMoveTo)
		{
			cur = number;
		}
		else
		{
			cur += number;
		}
		if (cur > max)
			cur = 0;
		else if (cur < 0)
			cur = max;
		FlxG.save.data.selectTouchScreenButtons = cur;

		display = updateDisplay();
	}

	function sayTheThing():String
	{
		switch (Std.int(FlxG.save.data.selectTouchScreenButtons))
		{
			case 0:
				return "OFF";
			case 1:
				return "Hitbox";
			case 2:
				return "Virtual Pad Left";
			case 3:
				return "Virtual Pad Right";
			case 4:
				return "Virtual Pad Both";
			case 5:
				return "Virtual Pad Custom";
			default:
				return "???";
		}
	}

	override function getValue():String
	{
		// return "Current Touchscreen Button: " + sayTheThing();
		return updateDisplay();
	}

	private override function updateDisplay():String
	{
		return ("Touchscreen button type < " + sayTheThing() + " >");
	}
}

class VibrationOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		press(); // same as press
		return true;
	}

	public override function right():Bool
	{
		left(); // same as left
		return true;
	}

	public override function press():Bool
	{
		FlxG.save.data.vibration = !FlxG.save.data.vibration;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Vibration < " + (FlxG.save.data.vibration ? "ON" : "OFF") + " >";
	}
}

// JOELwindows7: view achievements unlocked.
// inspired from that 69420 runner (N word version) ninjamuffin99 made before.
class GalleryOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		// OptionsMenu.instance.openSubState(new KeyBindMenu()); //open substate.
		// FlxG.switchState(new LoadReplayState()); //or open new state.
		return false;
	}

	private override function updateDisplay():String
	{
		return "Gallery Achievements";
	}
}

// JOELwindows7: adjust volume
class AdjustVolumeOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		display = updateDisplay();
		return true;
	}

	override function right():Bool
	{
		FlxG.sound.changeVolume(.1);
		display = updateDisplay();
		return true;
	}

	override function left():Bool
	{
		FlxG.sound.changeVolume(-.1);
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		// achievements for it
		AchievementUnlocked.whichIs("no_more_accident_volkeys");

		// https://github.com/ninjamuffin99/SHOOM/blob/master/source/PlayState.hx
		// lmao shoooooooooooooooooooooooooooooooooooooooooooooooooom
		var shoomSays:String = "SH";
		var remains:Int = 10;
		for (i in 0...(Std.int(FlxG.sound.volume * 10)))
		{
			shoomSays += 'O';
			remains--;
		}
		shoomSays += 'M';
		if (remains < 0)
			remains = 0;
		if (remains <= 0)
			AchievementUnlocked.whichIs("anBeethoven");
		for (i in 0...(remains))
		{
			shoomSays += ' '; // was `U` before. now space supported so yeah.
		}
		return "Volume < " + shoomSays + " (" + Std.string(Std.int(FlxG.sound.volume * 100)) + "%)" + " >";
	}

	override function getValue():String
	{
		// return "Volume: " + Std.string(FlxG.sound.volume * 100) + "%";
		return updateDisplay();
	}
}

// JOELwindows7: attempt the surround sound test using Lime audio source.
class SurroundTestOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			description = "This option cannot be toggled in the pause menu.";
		else
			description = desc;
	}

	public override function press():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		// OptionsMenu.instance.openSubState(new KeyBindMenu()); //open substate.
		// FlxG.switchState(new LoadReplayState()); //or open new state.
		OptionsMenu.switchState(new LimeAudioBufferTester());
		return true;
	}

	private override function updateDisplay():String
	{
		return "Surround Test";
	}
}

// JOELwindows7: quick way testing Webmer
class AnVideoCutscenerTestOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			description = "This option cannot be toggled in the pause menu.";
		else
			description = desc;
	}

	public override function press():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		// OptionsMenu.instance.openSubState(new KeyBindMenu()); //open substate.
		// FlxG.switchState(new LoadReplayState()); //or open new state.
		OptionsMenu.switchState(new AnWebmer());
		return true;
	}

	private override function updateDisplay():String
	{
		return "Video Cutscener Test";
	}
}

// JOELwindows7: quick way testing Starfield
class AnStarfieldTestOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			description = "This option cannot be toggled in the pause menu.";
		else
			description = desc;
	}

	public override function press():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		// OptionsMenu.instance.openSubState(new KeyBindMenu()); //open substate.
		// FlxG.switchState(new LoadReplayState()); //or open new state.
		OptionsMenu.switchState(new AnStarfielde());
		return true;
	}

	private override function updateDisplay():String
	{
		return "Starfield Test";
	}
}

// JOELwindows7: quick way testing default bekgrond
class AnDefaultBekgronTestOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			description = "This option cannot be toggled in the pause menu.";
		else
			description = desc;
	}

	public override function press():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		// OptionsMenu.instance.openSubState(new KeyBindMenu()); //open substate.
		// FlxG.switchState(new LoadReplayState()); //or open new state.
		OptionsMenu.switchState(new AnDefaultBekgronde());
		return true;
	}

	private override function updateDisplay():String
	{
		return "Default Background Test";
	}
}

// JOELwindows7: quick way testing MIDI
class AnMIDITestOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			description = "This option cannot be toggled in the pause menu.";
		else
			description = desc;
	}

	public override function press():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		// OptionsMenu.instance.openSubState(new KeyBindMenu()); //open substate.
		// FlxG.switchState(new LoadReplayState()); //or open new state.
		// FlxG.switchState(new AnMIDIyeay());
		return true;
	}

	private override function updateDisplay():String
	{
		return "MIDI Test";
	}
}

// JOELwindows7: Force all weeks to unlock
class PreUnlockAllWeeksOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		press(); // same as press
		return false;
	}

	public override function right():Bool
	{
		press(); // same as press
		return false;
	}

	public override function press():Bool
	{
		FlxG.save.data.preUnlocked = !FlxG.save.data.preUnlocked;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "All Weeks < " + (FlxG.save.data.preUnlocked ? "PreUnlocked" : "Lock Progress") + " >";
	}
}

// JOELwindows7: Vibration had delay. offset it this
class VibrationOffsetOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		display = updateDisplay();
		return true;
	}

	override function right():Bool
	{
		FlxG.save.data.vibrationOffset += .01;
		display = updateDisplay();
		return true;
	}

	override function left():Bool
	{
		FlxG.save.data.vibrationOffset -= .01;
		if (FlxG.save.data.vibrationOffset < 0.0)
			FlxG.save.data.vibrationOfset = 0.0;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Vibration Offset < " + Std.string(FlxG.save.data.vibrationOffset) + " >";
	}

	override function getValue():String
	{
		// return "Vibration Offset: " + Std.string(FlxG.save.data.vibrationOffset);
		return updateDisplay();
	}
}

class OutOfSegsWarningOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		press(); // same as press
		return false;
	}

	public override function right():Bool
	{
		press(); // same as press
		return false;
	}

	public override function press():Bool
	{
		FlxG.save.data.outOfSegsWarning = !FlxG.save.data.outOfSegsWarning;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Out of segs < " + (FlxG.save.data.outOfSegsWarning ? "Printed" : "SSSSHHHH" + " >");
	}
}

// JOELwindows7: Print chart contents option while play
class PrintSongChartContentOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		press(); // same as press
		return false;
	}

	public override function right():Bool
	{
		press(); // same as press
		return false;
	}

	public override function press():Bool
	{
		FlxG.save.data.traceSongChart = !FlxG.save.data.traceSongChart;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Song Chart Content < " + (FlxG.save.data.traceSongChart ? "Printed" : "SSSSHHHH") + " >";
	}
}

// JOELwindows7: GameJolt login TentaRJ
class LogGameJoltIn extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			description = "This option cannot be toggled in the pause menu.";
		else
			description = desc;
	}

	public override function press():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		#if gamejolt
		OptionsMenu.switchState(new GameJoltLogin());
		#end
		return true;
	}

	private override function updateDisplay():String
	{
		#if gamejolt
		return GameJoltAPI.getStatus() ? "GJ " + GameJoltAPI.getUserInfo(true) : "GameJolt Login";
		#else
		return "GameJolt not supported";
		#end
	}

	override function getValue():String
	{
		// return "GameJolt is: " + (GameJoltAPI.getStatus() ? GameJoltAPI.getUserInfo(true) : "[logged out]");
		return updateDisplay();
	}
}
