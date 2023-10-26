package;

import firetongue.FireTongue;
import ui.states.transition.PsychTransition;
import utils.Initializations;
import ui.states.modding.ModMenuState;
import ui.GameJoltGateway;
import GalleryAchievements;
#if gamejolt
import GameJolt;
#end
import experiments.AnMIDIyeay;
import experiments.AnWebmer;
import experiments.AnChangeChannel;
import experiments.LimeAudioBufferTester;
import experiments.*;
import openfl.net.FileFilter;
import haxe.Json;
import tjson.TJSON;
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
#if FEATURE_DISCORD
import Discord.DiscordClient;
#end
import flixel.input.gamepad.FlxGamepad;
import const.Perkedel;

using StringTools;

class Option
{
	public function new()
	{
		display = updateDisplay();
		// JOELwindows7: install the value to those variables yea
		// this.cannotInPause = cantInPause;
		// this.requiresRestartSong = needsRestartSong;
	}

	var gamepad:FlxGamepad = FlxG.gamepads.lastActive; // JOELwindows7: BOLO

	// JOELwindows7: incoming! Master Eric Enigma!
	// yoink from https://github.com/EnigmaEngine/EnigmaEngine/blob/stable/source/funkin/behavior/options/Options.hx

	/**
	 * The name of this option in the options menu.
	 */
	public var name(default, null):String = "";

	/**
	 * The long-form description of this option, shown at the bottom of the screen.
	 */
	public var description(default, null):String = "";

	/**
	 * Reset all user preferences to their default values.
	 */
	// public static function resetPreferences()
	// {
	// 	FlxG.save.data.preferences = getDefaultPreferences();
	// }
	private var display:String;

	private var acceptValues:Bool = false;

	public static var valuechanged:Bool = false; // JOELwindows7: BOLO flag for value just changed

	public var acceptType:Bool = false;

	public var waitingType:Bool = false;

	// JOELwindows7: special marker
	public var cannotInPause:Bool = false; // mark this option inaccessible in pause menu

	public var requiresRestartSong:Bool = false; // mark this option, changing will require you to restart song to apply.

	// JOELwindows7: Oh! got an idea! how about this?
	function varCannotInPause():Bool
	{
		return false;
	}

	function varRequiresRestartSong():Bool
	{
		return false;
	}

	// yeah! now you can override these above wow yay!

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

	// JOELwindows7: get & set is not overriden?!

	public function onType(text:String)
	{
	}

	// Returns whether the label is to be updated.
	public function press():Bool
	{
		if (requiresRestartSong)
			OptionsMenu.markRestartSong();
		return true;
	}

	private function updateDisplay():String
	{
		return "";
	}

	public function left():Bool
	{
		if (requiresRestartSong)
			OptionsMenu.markRestartSong();
		return false;
	}

	public function right():Bool
	{
		if (requiresRestartSong)
			OptionsMenu.markRestartSong();
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
			// JOELwindows7: BOLO now has Gamepad binder too, so all these keybind will have these too as well.
			// FlxG.save.data.upBind = text;
			if (gamepad != null)
				FlxG.save.data.gpupBind = text;
			else
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
			// JOELwindows7: BOLOfy
			// FlxG.save.data.downBind = text;
			if (gamepad != null)
				FlxG.save.data.gpdownBind = text;
			else
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
			// JOELwindows7: BOLOfy
			// FlxG.save.data.rightBind = text;
			if (gamepad != null)
				FlxG.save.data.gprightBind = text;
			else
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
			// JOELwindows7: BOLOfy
			// FlxG.save.data.leftBind = text;
			if (gamepad != null)
				FlxG.save.data.gplefttBind = text;
			else
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
			// JOELwindows7: BOLOfy. Pause keybind too aswell!!!!!
			// FlxG.save.data.pauseBind = text;
			if (gamepad != null)
				FlxG.save.data.gppauseBind = text;
			else
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
			// JOELwindows7: BOLOfy
			// FlxG.save.data.resetBind = text;
			if (gamepad != null)
				FlxG.save.data.gpresetBind = text;
			else
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

class RoundAccuracy extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		FlxG.save.data.roundAccuracy = !FlxG.save.data.roundAccuracy;

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
		return "Round Accuracy: < " + (FlxG.save.data.roundAccuracy ? "on" : "off") + " >";
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
			// description = "This option cannot be toggled in the pause menu.";
			// description = Perkedel.OPTION_SAY_CANNOT_ACCESS_IN_PAUSE + desc; // JOELwindows7: here with new const for it.
			description = Perkedel.OPTION_SAY_NEED_RESTART_SONG + desc;
		else
			description = desc;
	}

	public override function left():Bool
	{
		// JOELwindows7: BOLO destroy limiter
		// if (OptionsMenu.isInPause)
		// 	return false;
		OptionsMenu.markRestartSong();
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
		// if (OptionsMenu.isInPause)
		// 	// description = "This option cannot be toggled in the pause menu.";
		// 	description = Perkedel.OPTION_SAY_CANNOT_ACCESS_IN_PAUSE + desc; // JOELwindows7: here with new const for it.
		// else
		description = desc;
	}

	public override function left():Bool
	{
		// if (OptionsMenu.isInPause)
		// 	return false;
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
		// if (OptionsMenu.isInPause)
		// 	// description = "This option cannot be toggled in the pause menu.";
		// 	description = Perkedel.OPTION_SAY_CANNOT_ACCESS_IN_PAUSE + desc; // JOELwindows7: here with new const for it.
		// else
		description = desc;
	}

	public override function left():Bool
	{
		// if (OptionsMenu.isInPause)
		// 	return false;
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
			// description = "This option cannot be toggled in the pause menu.";
			description = Perkedel.OPTION_SAY_CANNOT_ACCESS_IN_PAUSE + desc; // JOELwindows7: here with new const for it.
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
		// if (OptionsMenu.isInPause)
		// 	// description = "This option cannot be toggled in the pause menu.";
		// 	description = Perkedel.OPTION_SAY_CANNOT_ACCESS_IN_PAUSE + desc; // JOELwindows7: here with new const for it.
		// else
		description = desc;
	}

	public override function left():Bool
	{
		// if (OptionsMenu.isInPause)
		// 	return false;
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
			// description = "This option cannot be toggled in the pause menu.";
			// description = Perkedel.OPTION_SAY_CANNOT_ACCESS_IN_PAUSE + desc; // JOELwindows7: here with new const for it.
			description = Perkedel.OPTION_SAY_NEED_RESTART_SONG + desc; // JOELwindows7: here with new const for it.
		else
			description = desc;
	}

	public override function left():Bool
	{
		// if (OptionsMenu.isInPause)
		// 	return false;
		OptionsMenu.markRestartSong();
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

	// JOELwindows7: BRUH, this is selection, not enter! BOLO fix
	public override function left():Bool
	{
		FlxG.save.data.InstantRespawn = !FlxG.save.data.InstantRespawn;
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
		return "Instant Respawn: < " + (!FlxG.save.data.InstantRespawn ? "off" : "on") + " >";
	}
}

class FlashingLightsOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			// description = "This option cannot be toggled in the pause menu.";
			// description = Perkedel.OPTION_SAY_CANNOT_ACCESS_IN_PAUSE + desc; // JOELwindows7: here with new const for it.
			description = Perkedel.OPTION_SAY_NEED_RESTART_SONG + desc; // JOELwindows7: here with new const for it.
		else
			description = desc;
	}

	public override function left():Bool
	{
		// if (OptionsMenu.isInPause)
		// 	return false;
		OptionsMenu.markRestartSong();
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
	// JOELwindows7: here's Master Eric enigma thingy!
	public static final DEFAULT:Bool = true;

	public static inline function get():Null<Bool>
	{
		if (FlxG.save.data == null)
			return DEFAULT;
		return FlxG.save.data.antialiasing;
	}

	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			// description = "This option cannot be toggled in the pause menu.";
			// description = Perkedel.OPTION_SAY_CANNOT_ACCESS_IN_PAUSE + desc; // JOELwindows7: here with new const for it.
			description = Perkedel.OPTION_SAY_REQUIRES_RESTART + desc; // JOELwindows7: here with new const for it.
		else
			description = desc;
	}

	public override function left():Bool
	{
		// if (OptionsMenu.isInPause)
		// 	return false;
		OptionsMenu.markRestartSong();
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
			// description = "This option cannot be toggled in the pause menu.";
			// description = Perkedel.OPTION_SAY_CANNOT_ACCESS_IN_PAUSE + desc; // JOELwindows7: here with new const for it.
			description = Perkedel.OPTION_SAY_NEED_RESTART_SONG + desc; // JOELwindows7: here with new const for it.
		else
			description = desc;
	}

	public override function left():Bool
	{
		// JOELwindows7: basically BOLO let some of these option changeable now, just restart song required.
		// if (OptionsMenu.isInPause)
		// 	return false;
		OptionsMenu.markRestartSong();
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
			// description = "This option cannot be toggled in the pause menu.";
			// description = Perkedel.OPTION_SAY_CANNOT_ACCESS_IN_PAUSE + desc; // JOELwindows7: here with new const for it.
			description = Perkedel.OPTION_SAY_NEED_RESTART_SONG + desc; // JOELwindows7: here with new const for it.
		else
			description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		// if (OptionsMenu.isInPause)
		// 	return false;
		OptionsMenu.markRestartSong();
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
		// JOELwindows7: BOLO prevent change in HTML5
		// #if html5
		// return false;
		// #end
		if (FlxG.save.data.fpsCap >= Perkedel.MAX_FPS_CAP) // JOELwindows7: was 290
		{
			FlxG.save.data.fpsCap = Perkedel.MAX_FPS_CAP; // JOELwindows7: yeah.
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(Perkedel.MAX_FPS_CAP); // JOELwindows7: crazy fps go brrrrr
		}
		else
			FlxG.save.data.fpsCap = FlxG.save.data.fpsCap + 10;
		(cast(Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);

		return true;
	}

	override function left():Bool
	{
		// JOELwindows7: BOLO prevent change in HTML5
		// #if html5
		// return false;
		// #end
		if (FlxG.save.data.fpsCap > Perkedel.MAX_FPS_CAP) // JOELwindows7: was 290
			FlxG.save.data.fpsCap = Perkedel.MAX_FPS_CAP; // JOELwindows7: yeye
		else if (FlxG.save.data.fpsCap < Perkedel.MIN_FPS_CAP) // JOELwindows7: was 60
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

		if (FlxG.save.data.scrollSpeed > Perkedel.MAX_SCROLL_SPEED) // JOELwindows7: BOLO. was 4
			FlxG.save.data.scrollSpeed = Perkedel.MAX_SCROLL_SPEED;
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

		if (FlxG.save.data.scrollSpeed > Perkedel.MAX_SCROLL_SPEED) // JOELwindows7: BOLO. was 4
			FlxG.save.data.scrollSpeed = Perkedel.MAX_SCROLL_SPEED;

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
		if (OptionsMenu.isInPause)
			// description = "This option cannot be toggled in the pause menu.";
			description = Perkedel.OPTION_SAY_CANNOT_ACCESS_IN_PAUSE + desc; // JOELwindows7: here with new const for it.
		else
			description = desc;
	}

	public override function press():Bool
	{
		trace("switch");
		// FlxG.switchState(new LoadReplayState());
		OptionsMenu.goToState(new LoadReplayState()); // JOELwindows7: hey, check if you are in game before hand!
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
			// description = "This option cannot be toggled in the pause menu.";
			description = Perkedel.OPTION_SAY_CANNOT_ACCESS_IN_PAUSE + desc; // JOELwindows7: here with new const for it.
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
			// description = "This option cannot be toggled in the pause menu.";
			description = Perkedel.OPTION_SAY_CANNOT_ACCESS_IN_PAUSE + desc; // JOELwindows7: here with new const for it.
		else
			description = desc;
	}

	public override function press():Bool
	{
		// if (OptionsMenu.isInPause)
		// 	return false;
		trace("switch");
		// FlxG.switchState(new GameplayCustomizeState());
		OptionsMenu.goToState(new GameplayCustomizeState()); // JOELwindows7: hey, check if you are in game before hand!
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
		// if (OptionsMenu.isInPause)
		// 	// description = "This option cannot be toggled in the pause menu.";
		// 	description = Perkedel.OPTION_SAY_CANNOT_ACCESS_IN_PAUSE + desc; // JOELwindows7: here with new const for it.
		// else
		description = desc;
	}

	public override function left():Bool
	{
		// if (OptionsMenu.isInPause)
		// 	return false;
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
		if (OptionsMenu.isInPause)
			// description = "This option cannot be toggled in the pause menu.";
			description = Perkedel.OPTION_SAY_CANNOT_ACCESS_IN_PAUSE + desc; // JOELwindows7: here with new const for it.
		else
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
		// LoadingState.loadAndSwitchState(new PlayState());
		OptionsMenu.goToState(new PlayState()); // JOELwindows7: hey, check if you are in game before hand!
		return false;
	}

	private override function updateDisplay():String
	{
		return "Time your offset";
	}
}

class BorderFps extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		FlxG.save.data.fpsBorder = !FlxG.save.data.fpsBorder;
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
		return "FPS Border: < " + (!FlxG.save.data.fpsBorder ? "off" : "on") + " >";
	}
}

class DisplayMemory extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		FlxG.save.data.memoryDisplay = !FlxG.save.data.memoryDisplay;
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
		return "Memory Display: < " + (!FlxG.save.data.memoryDisplay ? "off" : "on") + " >";
	}
}

class OffsetThing extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			// description = "This option cannot be toggled in the pause menu.";
			// description = Perkedel.OPTION_SAY_CANNOT_ACCESS_IN_PAUSE + desc; // JOELwindows7: here with new const for it.
			description = Perkedel.OPTION_SAY_NEED_RESTART_SONG + desc; // JOELwindows7: here with new const for it.
		else
			description = desc;
	}

	public override function left():Bool
	{
		// if (OptionsMenu.isInPause)
		// 	return false;
		OptionsMenu.markRestartSong();
		FlxG.save.data.offset--;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		// if (OptionsMenu.isInPause)
		// 	return false;
		OptionsMenu.markRestartSong();
		FlxG.save.data.offset++;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		// was Note offset
		return "Visual offset: < " + HelperFunctions.truncateFloat(FlxG.save.data.offset, 0) + " >";
	}

	public override function getValue():String
	{
		return "Visual offset: < " + HelperFunctions.truncateFloat(FlxG.save.data.offset, 0) + " >";
	}
}

class BotPlay extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			// description = "This option cannot be toggled in the pause menu.";
			// description = Perkedel.OPTION_SAY_CANNOT_ACCESS_IN_PAUSE + desc; // JOELwindows7: here with new const for it.
			description = Perkedel.OPTION_SAY_NEED_RESTART_SONG + desc; // JOELwindows7: here with new const for it.
		else
			description = desc;
	}

	public override function left():Bool
	{
		// OptionsMenu.markRestartSong();
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
			// description = "This option cannot be toggled in the pause menu.";
			// description = Perkedel.OPTION_SAY_CANNOT_ACCESS_IN_PAUSE + desc; // JOELwindows7: here with new const for it.
			description = Perkedel.OPTION_SAY_NEED_RESTART_SONG + desc; // JOELwindows7: here with new const for it.
		else
			description = desc;
	}

	public override function left():Bool
	{
		// if (OptionsMenu.isInPause)
		// 	return false;
		OptionsMenu.markRestartSong();
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
		// if (OptionsMenu.isInPause)
		// 	// description = "This option cannot be toggled in the pause menu.";
		// 	description = Perkedel.OPTION_SAY_CANNOT_ACCESS_IN_PAUSE + desc; // JOELwindows7: here with new const for it.
		// else
		description = desc;
	}

	public override function left():Bool
	{
		// if (OptionsMenu.isInPause)
		// 	return false;
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
			// description = "This option cannot be toggled in the pause menu.";
			// description = Perkedel.OPTION_SAY_CANNOT_ACCESS_IN_PAUSE + desc; // JOELwindows7: here with new const for it.
			description = Perkedel.OPTION_SAY_NEED_RESTART_SONG + desc; // JOELwindows7: here with new const for it.
		else
			description = desc;
	}

	public override function left():Bool
	{
		// if (OptionsMenu.isInPause)
		// 	return false;
		OptionsMenu.markRestartSong();
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

class RotateSpritesOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			// description = "This option cannot be toggled in the pause menu.";
			// description = Perkedel.OPTION_SAY_CANNOT_ACCESS_IN_PAUSE + desc; // JOELwindows7: here with new const for it.
			description = Perkedel.OPTION_SAY_NEED_RESTART_SONG + desc; // JOELwindows7: here with new const for it.
		else
			description = desc;
	}

	public override function left():Bool
	{
		// if (OptionsMenu.isInPause)
		// 	return false;
		OptionsMenu.markRestartSong();
		FlxG.save.data.rotateSprites = !FlxG.save.data.rotateSprites;
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
		return "Rotate Sprites: < " + (FlxG.save.data.rotateSprites ? "Enabled" : "Disabled") + " >";
	}
}

class NoteskinOption extends Option
{
	public function new(desc:String)
	{
		super();
		// if (OptionsMenu.isInPause)
		// 	description = "This option cannot be toggled in the pause menu.";
		// else
		// 	description = desc;
		requiresRestartSong = true; // JOELwindows7: just tell you just have to restart it yess.

		// JOELwindows7: c'mon let them change it. this noteskin index save data loads only on create.
		if (requiresRestartSong)
			description = Perkedel.OPTION_SAY_NEED_RESTART_SONG + desc;
		else
			description = desc;

		// JOELwindows7: I got it. you want to apply noteskin right now no restart. It's heavy. you need to tell n number of notes +
		// strum notes + hold bar to change image. BUT, maybe later. why not, I guess.
	}

	public override function left():Bool
	{
		// if (OptionsMenu.isInPause)
		// 	return false;
		FlxG.save.data.noteskin--;
		if (FlxG.save.data.noteskin < 0)
			FlxG.save.data.noteskin = NoteskinHelpers.getNoteskins().length - 1;
		display = updateDisplay();
		OptionsMenu.markRestartSong(); // JOELwindows7: mark restart song required.
		return true;
	}

	public override function right():Bool
	{
		// if (OptionsMenu.isInPause)
		// 	return false;
		FlxG.save.data.noteskin++;
		if (FlxG.save.data.noteskin > NoteskinHelpers.getNoteskins().length - 1)
			FlxG.save.data.noteskin = 0;
		display = updateDisplay();
		OptionsMenu.markRestartSong(); // JOELwindows7: mark restart song required.
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
			// description = "This option cannot be toggled in the pause menu.";
			description = Perkedel.OPTION_SAY_CANNOT_ACCESS_IN_PAUSE + desc; // JOELwindows7: here with new const for it.
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
		// if (OptionsMenu.isInPause)
		// 	description = "This option cannot be toggled in the pause menu.";
		// else
		// 	description = desc;
		acceptValues = true;

		requiresRestartSong = true; // JOELwindows7: just tell you just have to restart it yess.

		// JOELwindows7: c'mon let them change it. this noteskin index save data loads only on create.
		if (requiresRestartSong)
			description = Perkedel.OPTION_SAY_NEED_RESTART_SONG + desc;
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
		// if (OptionsMenu.isInPause)
		// 	return false;
		FlxG.save.data.laneTransparency += 0.1;

		if (FlxG.save.data.laneTransparency > 1)
			FlxG.save.data.laneTransparency = 1;
		OptionsMenu.markRestartSong(); // JOELwindows7: mark restart song required.
		return true;
	}

	override function left():Bool
	{
		// if (OptionsMenu.isInPause)
		// 	return false;
		FlxG.save.data.laneTransparency -= 0.1;

		if (FlxG.save.data.laneTransparency < 0)
			FlxG.save.data.laneTransparency = 0;
		OptionsMenu.markRestartSong(); // JOELwindows7: mark restart song required.
		return true;
	}
}

class DebugMode extends Option
{
	public function new(desc:String)
	{
		// description = desc;
		// JOELwindows7: cannot access to there during gameplay pause.
		// if (OptionsMenu.isInPause)
		// 	description = Perkedel.OPTION_SAY_CANNOT_ACCESS_IN_PAUSE + desc;
		// else
		description = desc;
		super();
	}

	public override function press():Bool
	{
		// FlxG.switchState(new AnimationDebug()); // JOELwindows7: now you can. idk.
		// JOELwindows7: whoa easy baby! we're in gameplay!
		OptionsMenu.goToState(new AnimationDebug(), true, true, false, true);
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
			// description = "This option cannot be toggled in the pause menu.";
			description = Perkedel.OPTION_SAY_CANNOT_ACCESS_IN_PAUSE + desc; // JOELwindows7: here with new const for it.
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
			// description = "This option cannot be toggled in the pause menu.";
			description = Perkedel.OPTION_SAY_CANNOT_ACCESS_IN_PAUSE + desc; // JOELwindows7: here with new const for it.
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
		// JOELwindows7: & BOLO
		FlxG.save.data.songAcc = null;
		for (key in Highscore.songAcc.keys())
		{
			Highscore.songAcc[key] = 0.00;
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
			// description = "This option cannot be toggled in the pause menu.";
			description = Perkedel.OPTION_SAY_CANNOT_ACCESS_IN_PAUSE + desc; // JOELwindows7: here with new const for it.
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
		FlxG.save.data.roundAccuracy = null;
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
		// JOELwindows7: whoah you forgot this. thancc BOLO
		FlxG.save.data.middleScroll = null;
		FlxG.save.data.InstantRespawn = null;
		FlxG.save.data.memoryDisplay = null;
		// end forgot this.
		// JOELwindows7: oh man! don't forget my new setting data!
		FlxG.save.data.accidentVolumeKeys = null;
		FlxG.save.data.fullscreen = false;
		FlxG.save.data.odyseeMark = null;
		FlxG.save.data.perkedelMark = null;
		FlxG.save.data.naughtiness = null;
		FlxG.save.data.cardiophile = null;
		FlxG.save.data.useTouchScreenButtons = null;
		FlxG.save.data.selectTouchScreenButtons = null;
		FlxG.save.data.vibration = null;
		FlxG.save.data.preUnlocked = null;
		FlxG.save.data.vibrationOffset = 0.18;
		FlxG.save.data.outOfSegsWarning = null;
		FlxG.save.data.traceSongChart = null;
		FlxG.save.data.annoyingWarns = null;
		FlxG.save.data.legacyLuaScript = null;
		FlxG.save.data.modData = new Map<String, Dynamic>();
		FlxG.save.data.autoClick = null;
		FlxG.save.data.autoClickDelay = 2;
		FlxG.save.data.freeplayThreadedLoading = null;
		FlxG.save.data.endSongEarly = null;
		FlxG.save.data.scoreTxtZoom = null;
		FlxG.save.data.noteSplashes = null;
		FlxG.save.data.cpuSplash = null;
		FlxG.save.data.forceStepmania = null;
		FlxG.save.data.unpausePreparation = 1;
		FlxG.save.data.lerpScore = null;
		FlxG.save.data.hitsound = null;
		FlxG.save.data.hitVolume = null;
		// FlxG.save.data.leftAWeek = null;
		// FlxG.save.data.leftStoryWeek = 0;
		// FlxG.save.data.leftWeekSongAt = '';
		// FlxG.save.data.leftFullPlaylistCurrently = [];
		// FlxG.save.data.leftCampaignScore = 0;
		// FlxG.save.data.leftCampaignMisses = 0;
		FlxG.save.data.blueballWeek = null;
		FlxG.save.data.disableVideoCutscener = null;
		// JOELwindows7: MORE BOLO RESETS
		FlxG.save.data.strumHit = null;
		FlxG.save.data.volume = null;
		FlxG.save.data.mute = null;
		FlxG.save.data.showCombo = null;
		FlxG.save.data.showComboNum = null;
		// end BOLO RESET

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
// EDIT: NOW IT DOES!! I CAN USE THIS E.G. TO CENSOR STRESS CUTSCENE IF THIS IS OFF,
// you naive angel christian syndrome people sacred but 🤓!
class NaughtinessOption extends Option
{
	public function new(desc:String)
	{
		super();
		// JOELwindows7: add some insult if this is OFF, & vice versa the appreciation if ON.
		description = desc + ' (${FlxG.save.data.naughtiness ? 'ON! PEOPLE OF CULTURE, BASED, CHAD' : 'OFF! NAIVE ANGEL, SACRED BUT, VIRGIN'})';
	}

	public override function press():Bool
	{
		FlxG.save.data.naughtiness = !FlxG.save.data.naughtiness;
		trace('Naughtiness : ' + FlxG.save.data.naughtiness);
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		// JOELwindows7: reference bayonetta lmao
		// https://twitter.com/GoNintendoTweet/status/1547222159503802373?s=20&t=GYvuOZJtG5qDylL4os06Uw
		// https://gonintendo.com/contents/6337-bayonetta-3-will-include-a-special-mode-to-censor-lewd-scenes-so-you-can-play-in-the
		// https://www.youtube.com/watch?v=aACdP5sNW94 rev says desu
		return 'Naughtiness < ${(FlxG.save.data.naughtiness ? 'on' : 'off (Hah! Naive Angel, you sacred but!)')} >';
	}
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
		FlxG.sound.play(Paths.sound(' cancelMenu '));
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
		FlxG.sound.play(Paths.sound(' cancelMenu '));
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
			// data = Json.parse(cast _file.data);
			data = TJSON.parse(cast _file.data); // JOELwindows7: use the new TJSON library

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
		FlxG.sound.play(Paths.sound(' cancelMenu '));
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
		FlxG.sound.play(Paths.sound(' cancelMenu '));
	}
}

// JOELwindows7: pls don' t forget full screen mode! // Rediscovered press F in title state to toggle full screen?!?!
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
		return "Screen mode < " + (FlxG.fullscreen ? "Fullscreen" : "Windowed") + " >";
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
		// FlxG.save.data.masterVolume = FlxG.sound.volume;
		return true;
	}

	override function right():Bool
	{
		FlxG.sound.changeVolume(.1);
		// FlxG.save.data.masterVolume = FlxG.sound.volume;
		display = updateDisplay();
		return true;
	}

	override function left():Bool
	{
		FlxG.sound.changeVolume(-.1);
		// FlxG.save.data.masterVolume = FlxG.sound.volume;
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
		FlxG.save.data.masterVolume = FlxG.sound.volume;
		return "Volume < " + shoomSays + " (" + Std.string(Std.int(FlxG.sound.volume * 100)) + "%)" + " >";
	}

	override function getValue():String
	{
		// return "Volume: " + Std.string(FlxG.sound.volume * 100) + "%";
		return updateDisplay();
	}
}

// JOELwindows7: option to disable / enable accident volume keys assignation
class AccidentVolumeKeysOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.accidentVolumeKeys = !FlxG.save.data.accidentVolumeKeys;
		display = updateDisplay();

		// apply immediately! copy from Kade's title state vol key assigner.
		Main.instance.checkAccidentVolKeys();
		return true;
	}

	public override function left():Bool
	{
		press(); // same as press
		return true;
	}

	public override function right():Bool
	{
		press(); // same as press
		return true;
	}

	private override function updateDisplay():String
	{
		return "Accident volume keys < " + (FlxG.save.data.accidentVolumeKeys ? "Enabled" : "Disabled") + " >";
	}
}

// JOELwindows7: attempt the surround sound test using Lime audio source.
class SurroundTestOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			// description = "This option cannot be toggled in the pause menu.";
			description = Perkedel.OPTION_SAY_CANNOT_ACCESS_IN_PAUSE + desc; // JOELwindows7: here with new const for it.
		else
			description = desc;
	}

	public override function press():Bool
	{
		// OptionsMenu.instance.openSubState(new KeyBindMenu()); //open substate.
		// FlxG.switchState(new LoadReplayState()); //or open new state.
		OptionsMenu.goToState(new LimeAudioBufferTester());
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
			// description = "This option cannot be toggled in the pause menu.";
			description = Perkedel.OPTION_SAY_CANNOT_ACCESS_IN_PAUSE + desc; // JOELwindows7: here with new const for it.
		else
			description = desc;
	}

	public override function press():Bool
	{
		// OptionsMenu.instance.openSubState(new KeyBindMenu()); //open substate.
		// FlxG.switchState(new LoadReplayState()); //or open new state.
		OptionsMenu.goToState(new AnWebmer());
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
			// description = "This option cannot be toggled in the pause menu.";
			description = Perkedel.OPTION_SAY_CANNOT_ACCESS_IN_PAUSE + desc; // JOELwindows7: here with new const for it.
		else
			description = desc;
	}

	public override function press():Bool
	{
		// OptionsMenu.instance.openSubState(new KeyBindMenu()); //open substate.
		// FlxG.switchState(new LoadReplayState()); //or open new state.
		OptionsMenu.goToState(new AnStarfielde());
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
			// description = "This option cannot be toggled in the pause menu.";
			description = Perkedel.OPTION_SAY_CANNOT_ACCESS_IN_PAUSE + desc; // JOELwindows7: here with new const for it.
		else
			description = desc;
	}

	public override function press():Bool
	{
		// OptionsMenu.instance.openSubState(new KeyBindMenu()); //open substate.
		// FlxG.switchState(new LoadReplayState()); //or open new state.
		OptionsMenu.goToState(new AnDefaultBekgronde());
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
			// description = "This option cannot be toggled in the pause menu.";
			description = Perkedel.OPTION_SAY_CANNOT_ACCESS_IN_PAUSE + desc; // JOELwindows7: here with new const for it.
		else
			description = desc;
	}

	public override function press():Bool
	{
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

// JOELwindows7: quick way testing music play
class AnLoneBopeeboOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			// description = "This option cannot be toggled in the pause menu.";
			description = Perkedel.OPTION_SAY_CANNOT_ACCESS_IN_PAUSE + desc; // JOELwindows7: here with new const for it.
		else
			description = desc;
	}

	public override function press():Bool
	{
		OptionsMenu.goToState(new AnLoneBopeebo()); // open substate.
		// FlxG.switchState(new LoadReplayState()); //or open new state.
		// FlxG.switchState(new AnMIDIyeay());
		return true;
	}

	private override function updateDisplay():String
	{
		return "Test Bopeebo";
	}
}

// JOELwindows7: lonenote pls
class AnLoneNoteOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			// description = "This option cannot be toggled in the pause menu.";
			description = Perkedel.OPTION_SAY_CANNOT_ACCESS_IN_PAUSE + desc; // JOELwindows7: here with new const for it.
		else
			description = desc;
	}

	public override function press():Bool
	{
		OptionsMenu.goToState(new AnLoneNote()); // open substate.
		// FlxG.switchState(new LoadReplayState()); //or open new state.
		// FlxG.switchState(new AnMIDIyeay());
		return true;
	}

	private override function updateDisplay():String
	{
		return "Test Noteskin";
	}
}

// JOELwindows7: quick way testing change channel
class AnChangeChannelOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			// description = "This option cannot be toggled in the pause menu.";
			description = Perkedel.OPTION_SAY_CANNOT_ACCESS_IN_PAUSE + desc; // JOELwindows7: here with new const for it.
		else
			description = desc;
	}

	public override function press():Bool
	{
		// OptionsMenu.instance.openSubState(new KeyBindMenu()); //open substate.
		// FlxG.switchState(new LoadReplayState()); //or open new state.
		OptionsMenu.goToState(new AnChangeChannel());
		return true;
	}

	private override function updateDisplay():String
	{
		return "Change Channel Test";
	}
}

class AnMiniWindowOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			// description = "This option cannot be toggled in the pause menu.";
			description = Perkedel.OPTION_SAY_CANNOT_ACCESS_IN_PAUSE + desc; // JOELwindows7: here with new const for it.
		else
			description = desc;
	}

	public override function press():Bool
	{
		// OptionsMenu.instance.openSubState(new KeyBindMenu()); //open substate.
		// FlxG.switchState(new LoadReplayState()); //or open new state.
		OptionsMenu.goToState(new AnWindowTest());
		return true;
	}

	private override function updateDisplay():String
	{
		return "Mini Window Test";
	}
}

// JOELwindows7: kem0x test
class AnKem0xTestStateOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			// description = "This option cannot be toggled in the pause menu.";
			description = Perkedel.OPTION_SAY_CANNOT_ACCESS_IN_PAUSE + desc; // JOELwindows7: here with new const for it.
		else
			description = desc;
	}

	public override function press():Bool
	{
		// OptionsMenu.instance.openSubState(new KeyBindMenu()); //open substate.
		// FlxG.switchState(new LoadReplayState()); //or open new state.
		OptionsMenu.goToState(new AnKem0xTestState());
		return true;
	}

	private override function updateDisplay():String
	{
		return "Kem0x Test";
	}
}

// JOELwindows7: Waveform test state!
class AnWaveformTestStateOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			// description = "This option cannot be toggled in the pause menu.";
			description = Perkedel.OPTION_SAY_CANNOT_ACCESS_IN_PAUSE + desc; // JOELwindows7: here with new const for it.
		else
			description = desc;
	}

	public override function press():Bool
	{
		// OptionsMenu.instance.openSubState(new KeyBindMenu()); //open substate.
		// FlxG.switchState(new LoadReplayState()); //or open new state.
		OptionsMenu.goToState(new WaveformTestState());
		return true;
	}

	private override function updateDisplay():String
	{
		return "Waveform Test";
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

// JOELwindows7: Print annoying Debug Warn message that often happens. (Warn & Error pops debugger up)
class PrintAnnoyingDebugWarnOption extends Option
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
		FlxG.save.data.annoyingWarns = !FlxG.save.data.annoyingWarns;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Debug Warns < " + (FlxG.save.data.annoyingWarns ? "Printed" : "SSSSHHHH") + " >";
	}
}

// JOELwindows7: GameJolt login TentaRJ
class LogGameJoltIn extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			// description = "This option cannot be toggled in the pause menu.";
			description = Perkedel.OPTION_SAY_CANNOT_ACCESS_IN_PAUSE + desc; // JOELwindows7: here with new const for it.
		else
			description = desc;
	}

	public override function press():Bool
	{
		#if gamejolt
		// OptionsMenu.goToState(new GameJoltLogin());
		GameJoltGateway.getOut = false;
		OptionsMenu.goToState(new GameJoltGateway(new MainMenuState()));
		// OptionsMenu.instance.openSubState(GameJoltLogin()); // wait, it's now substate?!?!??!?!?
		return true;
		#else
		// Main.gjToastManager.createToast(null, "GameJolt not supported", "Sorry, your platform does not support GameJolt.");
		return false;
		#end
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

// JOELwindows7: Legacy Lua Modchart enable option
class LuaLegacyModchartOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		requiresRestartSong = true;
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
		OptionsMenu.markRestartSong(); // JOELwindows7: what if without calling super() this doesn't called then?
		FlxG.save.data.legacyLuaScript = !FlxG.save.data.legacyLuaScript;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Legacy Lua Modchart Compatibility < " + (FlxG.save.data.legacyLuaScript ? "ON" : "OFF") + " >";
	}
}

// JOELwindows7: autoclick checkbox in option menu for convenience
class AutoClickEnabledOption extends Option
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
		FlxG.save.data.autoClick = !FlxG.save.data.autoClick;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Dialogue AutoClick < " + (FlxG.save.data.autoClick ? "ON" : "OFF") + " >";
	}
}

// JOELwindows7: autoclick delay stepper in option menu for convenience
class AutoClickDelayOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		FlxG.save.data.autoClickDelay -= .05;
		if (FlxG.save.data.autoClickDelay < 1.0)
			FlxG.save.data.autoClickDelay = 1.0;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		FlxG.save.data.autoClickDelay += .05;
		if (FlxG.save.data.autoClickDelay > 5.0)
			FlxG.save.data.autoClickDelay = 5.0;
		display = updateDisplay();
		return true;
	}

	public override function press():Bool
	{
		return false;
	}

	private override function updateDisplay():String
	{
		return "Dialogue AutoClick Delay < " + Std.string(FlxG.save.data.autoClickDelay) + " > seconds";
	}
}

// JOELwindows7: toggle freeplay threaded loading
class FreeplayThreadedOption extends Option
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
		FlxG.save.data.freeplayThreadedLoading = !FlxG.save.data.freeplayThreadedLoading;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Freeplay Threaded Loading < " + (FlxG.save.data.freeplayThreadedLoading ? "ON" : "OFF") + " >";
	}
}

// JOELwindows7: whether or not end song early or wait until music complete
class EndSongEarlyOption extends Option
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
		FlxG.save.data.endSongEarly = !FlxG.save.data.endSongEarly;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "End Song Early < " + (FlxG.save.data.endSongEarly ? "ON" : "OFF") + " >";
	}
}

// JOELwindows7: toggle whether to enable or disable scoreTxtZoom
class ScoreTxtZoomOption extends Option
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
		FlxG.save.data.scoreTxtZoom = !FlxG.save.data.scoreTxtZoom;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Score Text Zoom < " + (FlxG.save.data.scoreTxtZoom ? "ON" : "OFF") + " >";
	}
}

// JOELwindows7: enable/disable note splash. in BOLO it's `NoteCock` like it's cumming
class NoteSplashOption extends Option
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
		FlxG.save.data.noteSplashes = !FlxG.save.data.noteSplashes;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Note Splash < " + (FlxG.save.data.noteSplashes ? "MOIST ON" : "DRIED OFF") + " >";
	}
}

// JOELwindows7: force stepmania quantization no matter what. did you know, it's OFF when there is modchart? yeah!
class ForceStepmaniaOption extends Option
{
	// this is maybe because in case of rerotation craze of arrow idk.
	// toggle `forceStepmania` ON or OFF
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
		FlxG.save.data.forceStepmania = !FlxG.save.data.forceStepmania;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Force Quantization < " + (FlxG.save.data.forceStepmania ? "ON" : "OFF") + " >";
	}
}

// JOELwindows7: unpause preparation countdown. toggle to have countdown preparation after unpause.
class UnpausePreparationOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		// press(); // same as press
		FlxG.save.data.unpausePreparation--;
		if (FlxG.save.data.unpausePreparation < 0)
			FlxG.save.data.unpausePreparation = 2;
		display = updateDisplay();
		return false;
	}

	public override function right():Bool
	{
		// press(); // same as press
		FlxG.save.data.unpausePreparation++;
		if (FlxG.save.data.unpausePreparation > 2)
			FlxG.save.data.unpausePreparation = 0;
		display = updateDisplay();
		return false;
	}

	public override function press():Bool
	{
		// FlxG.save.data.unpausePreparation = !FlxG.save.data.unpausePreparation;
		right();
		// display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Unpause Preparation < " + (switch (Std.int(FlxG.save.data.unpausePreparation))
		{
			case 0:
				"OFF";
			case 1:
				"Always";
			case 2:
				"Manual Only"; // this only allow unpause prep if not botplay or replay
			case _:
				"???";
		}) + " >";
	}
}

// JOELwindows7: Toggle hitsound in gameplay ON / OFF
class HitsoundOption extends Option
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
		FlxG.save.data.hitsound = !FlxG.save.data.hitsound;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Hitsound < " + (FlxG.save.data.hitsound ? "ON" : "OFF") + " >";
	}
}

// JOELwindows7: BOLO select hitsound
// https://github.com/BoloVEVO/Kade-Engine-Public/blob/stable/source/Options.hx
class HitsoundSelect extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		FlxG.save.data.hitSoundSelect--;
		if (FlxG.save.data.hitSoundSelect < 0)
			FlxG.save.data.hitSoundSelect = HitSounds.getSound().length - 1;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		FlxG.save.data.hitSoundSelect++;
		if (FlxG.save.data.hitSoundSelect > HitSounds.getSound().length - 1)
			FlxG.save.data.hitSoundSelect = 0;
		display = updateDisplay();
		return true;
	}

	public override function press():Bool
	{
		// JOELwindows7: PRESS ENTER / A / X / LONCAT TO PREVIEW!!!
		FlxG.sound.play(Paths.sound('hitsounds/${HitSounds.getSoundByID(FlxG.save.data.hitSoundSelect).toLowerCase()}', 'shared'), FlxG.save.data.hitVolume);
		return true;
	}

	public override function getValue():String
	{
		return "Hitsound Style: < " + HitSounds.getSoundByID(FlxG.save.data.hitSoundSelect) + " >";
	}
}

// JOELwindows7: BOLO hitsound when
class HitSoundMode extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		FlxG.save.data.strumHit = !FlxG.save.data.strumHit;

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
		return "Hitsound Mode: < " + (FlxG.save.data.strumHit ? "On Key Hit" : "On Note Hit") + " >";
	}
}

// JOELwindows7: BOLO had something called hitsound volume now
class HitSoundVolume extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;

		acceptValues = true;
	}

	public override function press():Bool
	{
		// JOELwindows7: PRESS ENTER / A / X / LONCAT TO PREVIEW!!!
		FlxG.sound.play(Paths.sound('hitsounds/${HitSounds.getSoundByID(FlxG.save.data.hitSoundSelect).toLowerCase()}', 'shared'));
		return true;
	}

	private override function updateDisplay():String
	{
		// JOELwindows7: hey, here's fancier one instead
		// https://github.com/ninjamuffin99/SHOOM/blob/master/source/PlayState.hx
		// lmao shoooooooooooooooooooooooooooooooooooooooooooooooooom
		var shoomSays:String = "SH";
		var remains:Int = 10;
		for (i in 0...(Std.int(FlxG.save.data.hitVolume * 10)))
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
		// FlxG.sound.play(Paths.sound('hitsounds/${HitSounds.getSoundByID(FlxG.save.data.hitSoundSelect).toLowerCase()}', 'shared'), FlxG.save.data.hitVolume);
		return "Hitsound Volume < " + shoomSays + " (" + Std.string(Std.int(FlxG.save.data.hitVolume * 100)) + "%)" + " >";
		// return "Hitsound Volume: < " + HelperFunctions.truncateFloat(FlxG.save.data.hitVolume, 1) + " >";
	}

	override function right():Bool
	{
		FlxG.save.data.hitVolume += 0.1;

		if (FlxG.save.data.hitVolume < 0)
			FlxG.save.data.hitVolume = 0;

		if (FlxG.save.data.hitVolume > 1)
			FlxG.save.data.hitVolume = 1;

		FlxG.sound.play(Paths.sound('hitsounds/${HitSounds.getSoundByID(FlxG.save.data.hitSoundSelect).toLowerCase()}', 'shared'), FlxG.save.data.hitVolume);
		return true;
	}

	override function getValue():String
	{
		// return "Hitsound Volume: < " + HelperFunctions.truncateFloat(FlxG.save.data.hitVolume, 1) + " >";
		return updateDisplay();
	}

	override function left():Bool
	{
		FlxG.save.data.hitVolume -= 0.1;

		if (FlxG.save.data.hitVolume < 0)
			FlxG.save.data.hitVolume = 0;

		if (FlxG.save.data.hitVolume > 1)
			FlxG.save.data.hitVolume = 1;

		FlxG.sound.play(Paths.sound('hitsounds/${HitSounds.getSoundByID(FlxG.save.data.hitSoundSelect).toLowerCase()}', 'shared'), FlxG.save.data.hitVolume);
		return true;
	}
}

// JOELwindows7: CPU notesplash! inspire from flash CPU strum, and this enable / disable `cpuSplash`. requires `noteSplash` to be ON.
class CpuSplashOption extends Option
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
		FlxG.save.data.cpuSplash = !FlxG.save.data.cpuSplash;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "CPU Splash < " + (FlxG.save.data.cpuSplash ? "MOIST ON" : "DRIED OFF") + " >";
	}
}

// JOELwindows7: Whether or not the blueball carries in total a week or just each song
class BlueballWeekOption extends Option
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
		FlxG.save.data.blueballWeek = !FlxG.save.data.blueballWeek;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Blueball count carries for < " + (FlxG.save.data.blueballWeek ? "Week Total" : "Per song only") + " >";
	}
}

class ModConfigurationsOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		// press(); // same as press
		return false;
	}

	public override function right():Bool
	{
		// press(); // same as press
		return false;
	}

	public override function press():Bool
	{
		#if FEATURE_MODCORE
		// FlxG.state = new ModConfigurationsState();
		ModMenuState.fromOptionMenu = !OptionsMenu.isInPause;
		OptionsMenu.goToState(new ModMenuState());
		return true;
		#else
		Main.gjToastManager.createToast(null, "Modcore not supported", "Sorry, your platform does not support modding.");
		return false;
		#end
	}

	private override function updateDisplay():String
	{
		#if FEATURE_MODCORE
		return "Mod Configurations";
		#else
		return "Modcore not supported";
		#end
	}
}

// JOELwindows7: disable video for those who crash. such as Linux some reason idk help pls help
class WorkaroundNoVideoOption extends Option
{
	public function new(desc:String = "Disable Video Cutscener to workaround crash when trying to start loading video or whatever")
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
		FlxG.save.data.disableVideoCutscener = !FlxG.save.data.disableVideoCutscener;
		display = updateDisplay();
		OptionsMenu.markRestartSong(); // JOELwindows7: mark restart song required.
		return true;
	}

	private override function updateDisplay():String
	{
		return '${Perkedel.VIDEO_DISABLED_OPTION_NAME} < Video ${FlxG.save.data.disableVideoCutscener ? "Disabled" : "Enabled"}>';
	}
}

// JOELwindows7: Lyric!
class KpopLyricsOption extends Option
{
	public function new(desc:String = "Should the song lyrics be displayed")
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
		FlxG.save.data.kpopLyrics = !FlxG.save.data.kpopLyrics;
		display = updateDisplay();
		// OptionsMenu.markRestartSong(); // JOELwindows7: mark restart song required.
		return true;
	}

	private override function updateDisplay():String
	{
		return '${Perkedel.LYRIC_ENABLED_OPTION_NAME} < Lyrics ${FlxG.save.data.kpopLyrics ? "Enabled" : "Disabled"}>';
	}
}

// JOELwindows7: Doom fall melt screen attempt
class DoomMeltOption extends Option
{
	public function new(desc:String = "Doom Melt Screen")
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
		FlxG.save.data.doomTransition = !FlxG.save.data.doomTransition;
		display = updateDisplay();
		// OptionsMenu.markRestartSong(); // JOELwindows7: mark restart song required.
		return true;
	}

	private override function updateDisplay():String
	{
		PsychTransition.wackyScreenTransitionTechnique = FlxG.save.data.doomTransition;
		return '${OptionsMenu.getTextOf("$OPTIONS_DOOM_MELT")} < ${FlxG.save.data.doomTransition ? "Enabled" : "Disabled"}>';
	}
}

// JOELwindows7: Kade Music option
class KadeMusicOption extends Option
{
	public function new(desc:String = "Kade Engine main menu music")
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		FlxG.save.data.kadeMusic--;
		if (FlxG.save.data.kadeMusic < 0)
			FlxG.save.data.kadeMusic = Perkedel.MAIN_MENU_MUSICS.length - 1;
		return press(); // same as press
		// return false;
	}

	public override function right():Bool
	{
		FlxG.save.data.kadeMusic++;
		if (FlxG.save.data.kadeMusic > Perkedel.MAIN_MENU_MUSICS.length - 1)
			FlxG.save.data.kadeMusic = 0;
		return press(); // same as press
		// return false;
	}

	public override function press():Bool
	{
		if (!(OptionsMenu.isInPause || PlayState.inDaPlay))
		{
			CoolUtil.playMainMenuSong(1, true);
		}
		// FlxG.save.data.kadeMusic = !FlxG.save.data.kadeMusic;
		display = updateDisplay();
		// OptionsMenu.markRestartSong(); // JOELwindows7: mark restart song required.
		return true;
	}

	private override function updateDisplay():String
	{
		return '${OptionsMenu.getTextOf("$OPTIONS_KADE_MUSIC")} < ${OptionsMenu.getTextOf('$$OPTIONS_KADE_MUSIC_OPT_${Std.int(FlxG.save.data.kadeMusic)}')} >';
		// return '${OptionsMenu.getTextOf("$OPTIONS_KADE_MUSIC")} < ${OptionsMenu.getTextOf("$OPTIONS_KADE_MUSIC_OPT_" + Std.string(FlxG.save.data.kadeMusic))} >';
	}
}

// JOELwindows7: Lyrics Position
class KpopLyricsPositionOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		// press(); // same as press
		FlxG.save.data.kpopLyricsPosition--;
		if (FlxG.save.data.kpopLyricsPosition < 0)
			FlxG.save.data.kpopLyricsPosition = 2;
		display = updateDisplay();
		return false;
	}

	public override function right():Bool
	{
		// press(); // same as press
		FlxG.save.data.kpopLyricsPosition++;
		if (FlxG.save.data.kpopLyricsPosition > 2)
			FlxG.save.data.kpopLyricsPosition = 0;
		display = updateDisplay();
		return false;
	}

	public override function press():Bool
	{
		// FlxG.save.data.unpausePreparation = !FlxG.save.data.unpausePreparation;
		right();
		// display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return '${Perkedel.LYRIC_POSITION_OPTION_NAME} < ' + (switch (Std.int(FlxG.save.data.kpopLyricsPosition))
		{
			case 0:
				"Left";
			case 1:
				"Center";
			case 2:
				"Right";
			case _:
				"???";
		}) + ' >';
	}
}

// JOELwindows7: Log Level selector
class LogLevelSelectorOption extends Option{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		var catchWhatIndex:Int = DebugLogWriter.LOG_LEVELS.indexOf(FlxG.save.data.debugLogLevel);
		// press(); // same as press
		catchWhatIndex--;
		if (catchWhatIndex < 0)
			catchWhatIndex = DebugLogWriter.LOG_LEVELS.length - 1;
		FlxG.save.data.debugLogLevel = DebugLogWriter.LOG_LEVELS[catchWhatIndex];
		display = updateDisplay();
		return false;
	}

	public override function right():Bool
	{
		var catchWhatIndex:Int = DebugLogWriter.LOG_LEVELS.indexOf(FlxG.save.data.debugLogLevel);
		// press(); // same as press
		catchWhatIndex++;
		if (catchWhatIndex > DebugLogWriter.LOG_LEVELS.length - 1)
			catchWhatIndex = 0;
		FlxG.save.data.debugLogLevel = DebugLogWriter.LOG_LEVELS[catchWhatIndex];
		display = updateDisplay();
		return false;
	}

	public override function press():Bool
	{
		// FlxG.save.data.unpausePreparation = !FlxG.save.data.unpausePreparation;
		right();
		// display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return '${CoolUtil.getText('$$OPTIONS_LOG_LEVEL')} < ${FlxG.save.data.debugLogLevel} >';
	}
}

// JOELwindows7: Language selector!!!
class LanguageSelectorOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		// press(); // same as press
		FlxG.save.data.languageSelect--;
		if (FlxG.save.data.languageSelect < 0)
			FlxG.save.data.languageSelect = Perkedel.LANGUAGES_AVAILABLE.length - 1;
		FlxG.save.data.languageID = Perkedel.LANGUAGES_AVAILABLE[FlxG.save.data.languageSelect][0];
		display = updateDisplay();
		return false;
	}

	public override function right():Bool
	{
		// press(); // same as press
		FlxG.save.data.languageSelect++;
		if (FlxG.save.data.languageSelect > Perkedel.LANGUAGES_AVAILABLE.length - 1)
			FlxG.save.data.languageSelect = 0;
		FlxG.save.data.languageID = Perkedel.LANGUAGES_AVAILABLE[FlxG.save.data.languageSelect][0];
		display = updateDisplay();
		return false;
	}

	public override function press():Bool
	{
		// FlxG.save.data.unpausePreparation = !FlxG.save.data.unpausePreparation;
		// right();
		FlxG.save.data.languageID = Perkedel.LANGUAGES_AVAILABLE[FlxG.save.data.languageSelect][0];
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		Initializations.refreshLanguage();

		return // '${OptionsMenu.getTextOf("$OPTIONS_SELECT_LANGUAGE")} < [${Perkedel.LANGUAGES_AVAILABLE[FlxG.save.data.languageSelect][0]}] ${Perkedel.LANGUAGES_AVAILABLE[FlxG.save.data.languageSelect][1]} >';
			// '${CoolUtil.getIndexString(IndexString.TheWordLanguage)} (LANG) < [${Perkedel.LANGUAGES_AVAILABLE[FlxG.save.data.languageSelect][0]}] ${CoolUtil.getIndexString(IndexString.LanguageNative)} (${CoolUtil.getIndexString(IndexString.Language)}) >';
			// '${CoolUtil.getIndexString(IndexString.TheWordLanguage)} (LANG) < [${Perkedel.LANGUAGES_AVAILABLE[FlxG.save.data.languageSelect][0]}] ${CoolUtil.getIndexString(IndexString.Language)} >';
			'${CoolUtil.getIndexString(IndexString.TheWordLanguage)} (LANG) < [${Perkedel.LANGUAGES_AVAILABLE[FlxG.save.data.languageSelect][0]}] ${CoolUtil.getIndexString(IndexString.Language)} (${CoolUtil.getIndexString(IndexString.Region)})>';
		// '${CoolUtil.getIndexString(IndexString.TheWordLanguage)} (LANG) < [${Perkedel.LANGUAGES_AVAILABLE[FlxG.save.data.languageSelect][0]}] ${CoolUtil.getIndexString(IndexString.LanguageBilingual)}>';
	}
}

// JOELwindows7: BOLO's reset modifier!!!
class ResetModifiersOption extends Option
{
	var confirm:Bool = false;

	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			// description = "This option cannot be toggled in the pause menu.";
			description = Perkedel.OPTION_SAY_CANNOT_ACCESS_IN_PAUSE + desc // JOELwindows7: here with new const for it.
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

		KadeEngineData.resetModifiers();
		confirm = false;
		trace('Modifiers went brrrr');
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return confirm ? "Confirm Modifiers reset" : "Reset Modifiers";
	}
}

// JOELwindows7: we didn't realize the optimize option is gone! thancc BOLO for restoring it
class OptimizeOption extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			// description = "This option cannot be toggled in the pause menu."
			description = Perkedel.OPTION_SAY_CANNOT_ACCESS_IN_PAUSE + desc // JOELwindows7: here with new const for it.
		else
			description = desc;
		requiresRestartSong = true; // JOELwindows7: just tell you just have to restart it yess.
		// requiresRestartSong = true; // JOELwindows7: just tell you just have to restart it yess.
		// OptionsMenu.markRestartSong();
		// acceptValues = true;
	}

	public override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.save.data.optimize = !FlxG.save.data.optimize;
		display = updateDisplay();
		OptionsMenu.markRestartSong();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Optimization: < " + (FlxG.save.data.optimize ? "Enabled" : "Disabled") + " >";
	}
}

// JOELwindows7: BOLO's background enable / disable
class Background extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			// description = "This option cannot be toggled in the pause menu."
			description = Perkedel.OPTION_SAY_CANNOT_ACCESS_IN_PAUSE + desc // JOELwindows7: here with new const for it.
		else
			description = desc;
		requiresRestartSong = true; // JOELwindows7: just tell you just have to restart it yess.
		// OptionsMenu.markRestartSong();
		// acceptValues = true;
	}

	public override function left():Bool
	{
		if (OptionsMenu.isInPause || FlxG.save.data.optimize)
			return false;
		FlxG.save.data.background = !FlxG.save.data.background;
		display = updateDisplay();
		OptionsMenu.markRestartSong();
		return true;
	}

	public override function right():Bool
	{
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Background Stage: < " + (FlxG.save.data.background ? "Enabled" : "Disabled") + " >";
	}
}

// JOELwindows7: BOLO discord detail option
#if FEATURE_DISCORD
class DiscordOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		FlxG.save.data.discordMode--;
		if (FlxG.save.data.discordMode < 0)
			FlxG.save.data.discordMode = DiscordClient.getRCPmode().length - 1;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		FlxG.save.data.discordMode++;
		if (FlxG.save.data.discordMode > DiscordClient.getRCPmode().length - 1)
			FlxG.save.data.discordMode = 0;
		display = updateDisplay();
		return true;
	}

	public override function getValue():String
	{
		return "Discord RCP mode: < " + DiscordClient.getRCPmodeByID(FlxG.save.data.discordMode) + " >";
	}
}
#end

// JOELwindows7: BOLO score smoothing
class ScoreSmoothing extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		FlxG.save.data.lerpScore = !FlxG.save.data.lerpScore;

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
		return "Smooth Score PopUp: < " + (FlxG.save.data.lerpScore ? "on" : "off") + " >";
	}
}

// JOELwindows7: BOLO autosave chart!!!!!!!
class AutoSaveChart extends Option
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

		FlxG.save.data.autoSaveChart = !FlxG.save.data.autoSaveChart;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		left();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Auto Saving Chart: < " + (!FlxG.save.data.autoSaveChart ? "off" : "on") + " >";
	}
}

// JOELwindows7: BOLO GPU render NEW
class GPURendering extends Option
{
	public function new(desc:String)
	{
		super();
		if (OptionsMenu.isInPause)
			description = "This option cannot be toggled in the pause menu.";
		else
			description = desc;

		#if html5
		description = "This option is handled automaticly by browser.";
		#end
	}

	public override function left():Bool
	{
		#if !html5
		if (OptionsMenu.isInPause)
			return false;

		FlxG.save.data.gpuRender = !FlxG.save.data.gpuRender;
		display = updateDisplay();
		return true;
		#else
		return false;
		#end
	}

	public override function right():Bool
	{
		#if !html5
		if (OptionsMenu.isInPause)
			return false;
		left();
		return true;
		#else
		return false;
		#end
	}

	private override function updateDisplay():String
	{
		#if !html5
		return "GPU Rendering: < " + (!FlxG.save.data.gpuRender ? "off" : "on") + " >";
		#else
		return "GPU Rendering: < " + "Auto" + " >";
		#end
	}
}

// JOELwindows7: BOLO Shader
class Shader extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		if (OptionsMenu.isInPause)
			return false;

		FlxG.save.data.shaders = !FlxG.save.data.shaders;

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
		return "Shaders: < " + (FlxG.save.data.shaders ? "On" : "Off") + " >";
	}
}
