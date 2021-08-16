package;

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

class OptionCategory
{
	private var _options:Array<Option> = new Array<Option>();
	public final function getOptions():Array<Option>
	{
		return _options;
	}

	public final function addOption(opt:Option)
	{
		_options.push(opt);
	}

	
	public final function removeOption(opt:Option)
	{
		_options.remove(opt);
	}

	private var _name:String = "New Category";
	public final function getName() {
		return _name;
	}

	public function new (catName:String, options:Array<Option>)
	{
		_name = catName;
		_options = options;
	}
}

class Option
{
	public function new()
	{
		display = updateDisplay();
	}
	private var description:String = "";
	private var display:String;
	private var acceptValues:Bool = false;
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

	public function getValue():String { return throw "stub!"; };
	
	// Returns whether the label is to be updated.
	public function press():Bool { return throw "stub!"; }
	private function updateDisplay():String { return throw "stub!"; }
	public function left():Bool { return throw "stub!"; }
	public function right():Bool { return throw "stub!"; }
}



class DFJKOption extends Option
{
	private var controls:Controls;

	public function new(controls:Controls)
	{
		super();
		this.controls = controls;
	}

	public override function press():Bool
	{
		OptionsMenu.instance.openSubState(new KeyBindMenu());
		return false;
	}

	private override function updateDisplay():String
	{
		return "Key Bindings";
	}
}

class CpuStrums extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.cpuStrums = !FlxG.save.data.cpuStrums;
		
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return  FlxG.save.data.cpuStrums ? "Light CPU Strums" : "CPU Strums stay static";
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
		return  FlxG.save.data.cacheImages ? "Preload Characters" : "Do not Preload Characters";
	}

}

class EditorRes extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.editorBG = !FlxG.save.data.editorBG;
		
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return  FlxG.save.data.editorBG ? "Show Editor Grid" : "Do not Show Editor Grid";
	}

}

class DownscrollOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.downscroll = !FlxG.save.data.downscroll;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return FlxG.save.data.downscroll ? "Downscroll" : "Upscroll";
	}
}

class GhostTapOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.ghost = !FlxG.save.data.ghost;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return FlxG.save.data.ghost ? "Ghost Tapping" : "No Ghost Tapping";
	}
}

class AccuracyOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.accuracyDisplay = !FlxG.save.data.accuracyDisplay;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Accuracy " + (!FlxG.save.data.accuracyDisplay ? "off" : "on");
	}
}

class SongPositionOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.songPosition = !FlxG.save.data.songPosition;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Song Position " + (!FlxG.save.data.songPosition ? "off" : "on");
	}
}

class DistractionsAndEffectsOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.distractions = !FlxG.save.data.distractions;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Distractions " + (!FlxG.save.data.distractions ? "off" : "on");
	}
}

class StepManiaOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.stepMania = !FlxG.save.data.stepMania;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Colors by quantization " + (!FlxG.save.data.stepMania ? "off" : "on");
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
		return "Reset Button " + (!FlxG.save.data.resetButton ? "off" : "on");
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
		return "Instant Respawn " + (!FlxG.save.data.InstantRespawn ? "off" : "on");
	}
}

class FlashingLightsOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.flashing = !FlxG.save.data.flashing;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Flashing Lights " + (!FlxG.save.data.flashing ? "off" : "on");
	}
}

class AntialiasingOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.antialiasing = !FlxG.save.data.antialiasing;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Antialiasing " + (!FlxG.save.data.antialiasing ? "off" : "on");
	}
}

class MissSoundsOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.missSounds = !FlxG.save.data.missSounds;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Miss Sounds " + (!FlxG.save.data.missSounds ? "off" : "on");
	}
}

class ShowInput extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.inputShow = !FlxG.save.data.inputShow;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return (FlxG.save.data.inputShow ? "Extended Score Info" : "Minimalized Info");
	}
}


class Judgement extends Option
{
	

	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}
	
	public override function press():Bool
	{
		return true;
	}

	private override function updateDisplay():String
	{
		return "Safe Frames";
	}

	override function left():Bool {

		if (Conductor.safeFrames == 1)
			return false;

		Conductor.safeFrames -= 1;
		FlxG.save.data.frames = Conductor.safeFrames;

		Conductor.recalculateTimings();
		return false;
	}

	override function getValue():String {
		return "Safe Frames: " + Conductor.safeFrames +
		" - SIK: " + HelperFunctions.truncateFloat(45 * Conductor.timeScale, 0) +
		"ms GD: " + HelperFunctions.truncateFloat(90 * Conductor.timeScale, 0) +
		"ms BD: " + HelperFunctions.truncateFloat(135 * Conductor.timeScale, 0) + 
		"ms SHT: " + HelperFunctions.truncateFloat(166 * Conductor.timeScale, 0) +
		"ms TOTAL: " + HelperFunctions.truncateFloat(Conductor.safeZoneOffset,0) + "ms";
	}

	override function right():Bool {

		if (Conductor.safeFrames == 20)
			return false;

		Conductor.safeFrames += 1;
		FlxG.save.data.frames = Conductor.safeFrames;

		Conductor.recalculateTimings();
		return true;
	}
}

class FPSOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.fps = !FlxG.save.data.fps;
		(cast (Lib.current.getChildAt(0), Main)).toggleFPS(FlxG.save.data.fps);
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "FPS Counter " + (!FlxG.save.data.fps ? "off" : "on");
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
		return (FlxG.save.data.scoreScreen ? "Show Score Screen" : "No Score Screen");
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
		return "FPS Cap";
	}
	
	override function right():Bool {
		if (FlxG.save.data.fpsCap >= 290)
		{
			FlxG.save.data.fpsCap = 290;
			(cast (Lib.current.getChildAt(0), Main)).setFPSCap(290);
		}
		else
			FlxG.save.data.fpsCap = FlxG.save.data.fpsCap + 10;
		(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);

		return true;
	}

	override function left():Bool {
		if (FlxG.save.data.fpsCap > 290)
			FlxG.save.data.fpsCap = 290;
		else if (FlxG.save.data.fpsCap < 60)
			FlxG.save.data.fpsCap = Application.current.window.displayMode.refreshRate;
		else
			FlxG.save.data.fpsCap = FlxG.save.data.fpsCap - 10;
		(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
		return true;
	}

	override function getValue():String
	{
		return "Current FPS Cap: " + FlxG.save.data.fpsCap + 
		(FlxG.save.data.fpsCap == Application.current.window.displayMode.refreshRate ? "Hz (Refresh Rate)" : "");
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
		return "Scroll Speed";
	}

	override function right():Bool {
		FlxG.save.data.scrollSpeed += 0.1;

		if (FlxG.save.data.scrollSpeed < 1)
			FlxG.save.data.scrollSpeed = 1;

		if (FlxG.save.data.scrollSpeed > 4)
			FlxG.save.data.scrollSpeed = 4;
		return true;
	}

	override function getValue():String {
		return "Current Scroll Speed: " + HelperFunctions.truncateFloat(FlxG.save.data.scrollSpeed,1);
	}

	override function left():Bool {
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

	public override function press():Bool
	{
		FlxG.save.data.fpsRain = !FlxG.save.data.fpsRain;
		(cast (Lib.current.getChildAt(0), Main)).changeFPSColor(FlxColor.WHITE);
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "FPS Rainbow " + (!FlxG.save.data.fpsRain ? "off" : "on");
	}
}

class Optimization extends Option
{
	public function new(desc:String)
		{
			super();
			description = desc;
		}
	
		public override function press():Bool
		{
			FlxG.save.data.optimize = !FlxG.save.data.optimize;
			display = updateDisplay();
			return true;
		}
	
		private override function updateDisplay():String
		{
			return "Optimization " + (FlxG.save.data.optimize ? "ON" : "OFF");
		}
}

class NPSDisplayOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.npsDisplay = !FlxG.save.data.npsDisplay;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "NPS Display " + (!FlxG.save.data.npsDisplay ? "off" : "on");
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
		FlxG.switchState(new LoadReplayState());
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
		description = desc;
	}
	
	public override function press():Bool
	{
		FlxG.save.data.accuracyMod = FlxG.save.data.accuracyMod == 1 ? 0 : 1;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Accuracy Mode: " + (FlxG.save.data.accuracyMod == 0 ? "Accurate" : "Complex");
	}
}

class CustomizeGameplay extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
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
		description = desc;
	}

	public override function press():Bool
	{
		Main.watermarks = !Main.watermarks;
		FlxG.save.data.watermark = Main.watermarks;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Watermarks " + (Main.watermarks ? "on" : "off");
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
		var poop:String = Highscore.formatSong("Tutorial", 1);

		PlayState.SONG = Song.loadFromJson(poop, "Tutorial");
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
class BotPlay extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	
	public override function press():Bool
	{
		FlxG.save.data.botplay = !FlxG.save.data.botplay;
		trace('BotPlay : ' + FlxG.save.data.botplay);
		display = updateDisplay();
		return true;
	}
	
	private override function updateDisplay():String
		return "BotPlay " + (FlxG.save.data.botplay ? "on" : "off");
}

class CamZoomOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.camzoom = !FlxG.save.data.camzoom;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Camera Zoom " + (!FlxG.save.data.camzoom ? "off" : "on");
	}
}

class LockWeeksOption extends Option
{
	var confirm:Bool = false;

	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		if(!confirm)
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
		description = desc;
	}
	public override function press():Bool
	{
		if(!confirm)
		{
			confirm = true;
			display = updateDisplay();
			return true;
		}
		FlxG.save.data.songScores = null;
		for(key in Highscore.songScores.keys())
		{
			Highscore.songScores[key] = 0;
		}
		FlxG.save.data.songCombos = null;
		for(key in Highscore.songCombos.keys())
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
		description = desc;
	}
	public override function press():Bool
	{
		if(!confirm)
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

//JOELwindows7: for future use in case it is necessary
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

//JOELwindows7: idk, that on the original game newgrounds week 7
//it had this. apparently this doesn't do anything yet.
class NaughtinessOption extends Option {
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
		return "Naughtiness " + (FlxG.save.data.naughtiness ? "on" : "off");
}

//JOELwindows7: export setting data to JSON
class ExportSaveToJson extends Option{
	var _file:FileReference;
	//copy over form ChartingState.hx, where JSON file is saved at.

	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.flush();

		//JOELwindows7: make save JSON pretty
		// https://haxe.org/manual/std-Json-encoding.html
		var data:String = Json.stringify(FlxG.save.data,"\t");

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
		//JOELwindows7: trace the success
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
		//JOELwindows7: trace cancel
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
		//JOELwindows7: also trace the error
		trace("Weror! problem saving backup data");
		FlxG.sound.play(Paths.sound('cancelMenu'));
	}
}

//JOELwindows7: also the import JSON save BACKUP
class ImportSaveFromJSON extends Option {
	var _file:FileReference;
	//copy over form ChartingState.hx, where JSON file is saved at.

	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
		{
			FlxG.save.flush();
	
			//JOELwindows7: make save JSON pretty
			// https://haxe.org/manual/std-Json-encoding.html
			var data;
	
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onLoadComplete);
			_file.addEventListener(Event.CANCEL, onLoadCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);

			if(_file.browse([new FileFilter("JSON file", "json")])){
				_file.load();
				data = Json.parse(cast _file.data);

				//FlxG.save.data = data;
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
			//JOELwindows7: trace the success
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
			//JOELwindows7: trace cancel
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
			//JOELwindows7: also trace the error
			trace("Weror! problem loading backup data");
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}
}

//JOELwindows7: pls don't forget full screen mode!
//Rediscovered press F in title state to toggle full screen?!?!
class FullScreenOption extends Option{
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

//JOELwindows7: copy paste the toggle from above to here
class OdyseemarkOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
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
		return "Odysee Watermarks " + (Main.odyseeMark ? "on" : "off");
	}
}

//JOELwindows7: again do the same. change the purpose option target yeay
class PerkedelmarkOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
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
		return "Perkedel Watermarks " + (Main.perkedelMark ? "on" : "off");
	}
}

//JOELwindows7: okay. we got to think ahead. there will be many watermarkers so we need to scroll choose the left right.
//here we go!
class ChooseWatermark extends Option
{
	//JOELwindows7: copy from Scroll speed option!
	public function new(desc:String)
		{
			super();
			description = desc;
			acceptValues = true;
		}

		//Hey, add your watermark id here
		var availableWatermark =[
			'odysee',
			'pekedel',
		];

		//Then add the path where it goes
		var watermarkPath =[

		];
	
		public override function press():Bool
		{
			return false;
		}
	
		private override function updateDisplay():String
		{
			return "Chosen Watermark " + Main.chosenMark;
		}
	
		override function right():Bool {
			Main.chosenMarkNum ++;
			Main.chosenMark = availableWatermark[Main.chosenMarkNum];
			display = updateDisplay();
			return true;
		}
	
		override function left():Bool {
			Main.chosenMarkNum --;
			Main.chosenMark = availableWatermark[Main.chosenMarkNum];
			display = updateDisplay();
			return true;
		}
}

//JOELwindows7: Cardiophille options! enable heartbeat fetish features
class CardiophileOption extends Option{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	
	public override function press():Bool
	{
		FlxG.save.data.cardiophile = !FlxG.save.data.cardiophile;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Cardiophile " + (FlxG.save.data.cardiophile ? "ON" : "OFF");
	}
}

//JOELwindows7: touchscreen buttons options
class UseTouchScreenButtons extends Option{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.useTouchScreenButtons = !FlxG.save.data.useTouchScreenButtons;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return (FlxG.save.data.useTouchScreenButtons ? "Use Touch Screen Buttons" : "No Touch Screen Buttons");
	}
}

class SelectTouchScreenButtons extends Option{
	var max=1;

	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool{
		return false;
	}

	override function right():Bool{
		changeModes(1);
		display = updateDisplay();
		return true;
	}

	override function left():Bool{
		changeModes(-1);
		display = updateDisplay();
		return true;
	}

	function changeModes(number:Int = 0, isMoveTo:Bool = false) {
		var cur:Int = Std.int(FlxG.save.data.selectTouchScreenButtons);
		if(isMoveTo){
			cur = number;
		} else {
			cur += number;
		}
		if(cur>max)
			cur = 0;
		else if(cur<0)
			cur = max;
		FlxG.save.data.selectTouchScreenButtons = cur;

		display = updateDisplay();
	}

	function sayTheThing():String{
		switch(Std.int(FlxG.save.data.selectTouchScreenButtons)){
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

	override function getValue():String {
		return "Current Touchscreen Button: " + sayTheThing();
	}

	private override function updateDisplay():String
	{		
		return ("Touchscreen button type " + sayTheThing());
	}
}

class VibrationOption extends Option{

	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.vibration = !FlxG.save.data.vibration;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{		
		return "Vibration " + (FlxG.save.data.vibration ? "ON" : "OFF");
	}
}

//JOELwindows7: view achievements unlocked. 
//inspired from that 69420 runner (N word version) ninjamuffin99 made before.
class GalleryOption extends Option{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		//OptionsMenu.instance.openSubState(new KeyBindMenu()); //open substate.
		//FlxG.switchState(new LoadReplayState()); //or open new state.
		return false;
	}

	private override function updateDisplay():String
	{
		return "Gallery Achievements";
	}
}

//JOELwindows7: adjust volume
class AdjustVolumeOption extends Option{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool{
		display = updateDisplay();
		return true;
	}

	override function right():Bool{
		FlxG.sound.changeVolume(.1);
		display = updateDisplay();
		return true;
	}

	override function left():Bool{
		FlxG.sound.changeVolume(-.1);
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		// https://github.com/ninjamuffin99/SHOOM/blob/master/source/PlayState.hx
		// lmao shoooooooooooooooooooooooooooooooooooooooooooooooooom
		var shoomSays:String="SH";
		var remains:Int = 10;
		for(i in 0...(Std.int(FlxG.sound.volume*10))){
			shoomSays += 'O';
			remains--;
		}
		shoomSays += 'M';
		if(remains < 0) remains = 0;
		for(i in 0...(remains)){
			shoomSays += 'U';
		}
		return "Volume " + shoomSays;
	}

	override function getValue():String {
		return "Volume: " + Std.string(FlxG.sound.volume);
	}
}

//JOELwindows7: attempt the surround sound test using Lime audio source.
class SurroundTestOption extends Option{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		//OptionsMenu.instance.openSubState(new KeyBindMenu()); //open substate.
		//FlxG.switchState(new LoadReplayState()); //or open new state.
		FlxG.switchState(new LimeAudioBufferTester());
		return false;
	}

	private override function updateDisplay():String
	{
		return "Surround Test";
	}
}

//JOELwindows7: quick way testing Webmer
class AnVideoCutscenerTestOption extends Option{
	public function new(desc:String)
		{
			super();
			description = desc;
		}
	
		public override function press():Bool
		{
			//OptionsMenu.instance.openSubState(new KeyBindMenu()); //open substate.
			//FlxG.switchState(new LoadReplayState()); //or open new state.
			FlxG.switchState(new AnWebmer());
			return false;
		}
	
		private override function updateDisplay():String
		{
			return "Video Cutscener Test";
		}
}

//JOELwindows7: quick way testing Starfield
class AnStarfieldTestOption extends Option{
	public function new(desc:String)
		{
			super();
			description = desc;
		}
	
		public override function press():Bool
		{
			//OptionsMenu.instance.openSubState(new KeyBindMenu()); //open substate.
			//FlxG.switchState(new LoadReplayState()); //or open new state.
			FlxG.switchState(new AnStarfielde());
			return false;
		}
	
		private override function updateDisplay():String
		{
			return "Starfield Test";
		}
}

//JOELwindows7: quick way testing default bekgrond
class AnDefaultBekgronTestOption extends Option{
	public function new(desc:String)
		{
			super();
			description = desc;
		}
	
		public override function press():Bool
		{
			//OptionsMenu.instance.openSubState(new KeyBindMenu()); //open substate.
			//FlxG.switchState(new LoadReplayState()); //or open new state.
			FlxG.switchState(new AnDefaultBekgronde());
			return false;
		}
	
		private override function updateDisplay():String
		{
			return "Default Background Test";
		}
}

//JOELwindows7: quick way testing MIDI
class AnMIDITestOption extends Option{
	public function new(desc:String)
		{
			super();
			description = desc;
		}
	
		public override function press():Bool
		{
			//OptionsMenu.instance.openSubState(new KeyBindMenu()); //open substate.
			//FlxG.switchState(new LoadReplayState()); //or open new state.
			FlxG.switchState(new AnMIDIyeay());
			return false;
		}
	
		private override function updateDisplay():String
		{
			return "MIDI Test";
		}
}

//JOELwindows7: Force all weeks to unlock
class PreUnlockAllWeeksOption extends Option{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.preUnlocked = !FlxG.save.data.preUnlocked;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{		
		return "All Weeks " + (FlxG.save.data.preUnlocked ? "PreUnlocked" : "Lock Progress");
	}
}

//JOELwindows7: Vibration had delay. offset it this
class VibrationOffsetOption extends Option{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool{
		display = updateDisplay();
		return true;
	}

	override function right():Bool{
		FlxG.save.data.vibrationOffset += .01;
		display = updateDisplay();
		return true;
	}

	override function left():Bool{
		FlxG.save.data.vibrationOffset -= .01;
		if(FlxG.save.data.vibrationOffset < 0.0)
			FlxG.save.data.vibrationOfset = 0.0;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Vibration Offset";
	}

	override function getValue():String {
		return "Vibration Offset: " + Std.string(FlxG.save.data.vibrationOffset);
	}
}

class OutOfSegsWarningOption extends Option{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.outOfSegsWarning = !FlxG.save.data.outOfSegsWarning;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{		
		return "Out of segs " + (FlxG.save.data.outOfSegsWarning ? "Printed" : "SSSSHHHH");
	}
}

class PrintSongChartContentOption extends Option{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.traceSongChart = !FlxG.save.data.traceSongChart;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{		
		return "Song Chart Content " + (FlxG.save.data.traceSongChart ? "Printed" : "SSSSHHHH");
	}
}
