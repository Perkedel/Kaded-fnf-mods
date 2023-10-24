package;

// JOELwindows7: YOINK FROM https://github.com/BoloVEVO/Kade-Engine-Public/blob/stable/source/Modifiers.hx
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
import FreeplaySubState;

// Used Options.hx code template to make this. Go to FreeplaySubState.hx to see the menu code :D
class Modifier
{
	public function new()
	{
		display = updateDisplay();
	}

	private var description:String = "";

	private var display:String;
	private var acceptValues:Bool = false;

	public static var valuechanged:Bool = false;

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

class Sustains extends Modifier
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		FlxG.save.data.sustains = !FlxG.save.data.sustains;

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
		return "Hold Notes: < " + (FlxG.save.data.sustains ? "on" : "off") + " >";
	}
}

class NoMissesMode extends Modifier
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		FlxG.save.data.noMisses = !FlxG.save.data.noMisses;

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
		return "No Misses mode: < " + (FlxG.save.data.noMisses ? "on" : "off") + " >";
	}
}

class Modchart extends Modifier
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		FlxG.save.data.modcharts = !FlxG.save.data.modcharts;

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
		return "Song Modchart: < " + (FlxG.save.data.modcharts ? "on" : "off") + " >";
	}
}

class OpponentMode extends Modifier
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		FlxG.save.data.opponent = !FlxG.save.data.opponent;

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
		return "Opponent Mode: < " + (FlxG.save.data.opponent ? "on" : "off") + " >";
	}
}

class HealthDrain extends Modifier
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		FlxG.save.data.hdrain = !FlxG.save.data.hdrain;

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
		return "Health Drain: < " + (FlxG.save.data.hdrain ? "on" : "off") + " >";
	}
}

class HealthGain extends Modifier
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function right():Bool
	{
		FlxG.save.data.hgain += 0.1;

		if (FlxG.save.data.hgain < 0)
			FlxG.save.data.hgain = 0;

		if (FlxG.save.data.hgain > 3)
			FlxG.save.data.hgain = 3;
		return true;
	}

	public override function left():Bool
	{
		FlxG.save.data.hgain -= 0.1;

		if (FlxG.save.data.hgain < 0)
			FlxG.save.data.hgain = 0;

		if (FlxG.save.data.hgain > 3)
			FlxG.save.data.hgain = 3;
		return true;
	}

	override function getValue():String
	{
		return "HP Gain Multiplier: < " + HelperFunctions.truncateFloat(FlxG.save.data.hgain, 1) + "x >";
	}

	private override function updateDisplay():String
	{
		return "HP Gain Multiplier: < " + HelperFunctions.truncateFloat(FlxG.save.data.hgain, 1) + "x >";
	}
}

class HealthLoss extends Modifier
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function right():Bool
	{
		FlxG.save.data.hloss += 0.1;

		if (FlxG.save.data.hloss < 0)
			FlxG.save.data.hloss = 0;

		if (FlxG.save.data.hloss > 3)
			FlxG.save.data.hloss = 3;
		return true;
	}

	public override function left():Bool
	{
		FlxG.save.data.hloss -= 0.1;

		if (FlxG.save.data.hloss < 0)
			FlxG.save.data.hloss = 0;

		if (FlxG.save.data.hloss > 3)
			FlxG.save.data.hloss = 3;
		return true;
	}

	override function getValue():String
	{
		return "HP Loss Multiplier: < " + HelperFunctions.truncateFloat(FlxG.save.data.hloss, 1) + "x >";
	}

	private override function updateDisplay():String
	{
		return "HP Loss Multiplier: < " + HelperFunctions.truncateFloat(FlxG.save.data.hloss, 1) + "x >";
	}
}

class Practice extends Modifier
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		FlxG.save.data.practice = !FlxG.save.data.practice;

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
		return "Practice Mode: < " + (FlxG.save.data.practice ? "on" : "off") + " >";
	}
}

class Mirror extends Modifier
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function left():Bool
	{
		FlxG.save.data.mirror = !FlxG.save.data.mirror;

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
		return "Mirror mode: < " + (FlxG.save.data.mirror ? "on" : "off") + " >";
	}
}

// JOELwindows7: Hey, give me noteskin!
class NoteskinModifier extends Modifier
{
	public function new(desc:String)
	{
		super();
		// if (OptionsMenu.isInPause)
		// 	description = "This option cannot be toggled in the pause menu.";
		// else
		// 	description = desc;
		// requiresRestartSong = true; // JOELwindows7: just tell you just have to restart it yess.

		// JOELwindows7: c'mon let them change it. this noteskin index save data loads only on create.
		// if (requiresRestartSong)
		// 	description = Perkedel.OPTION_SAY_NEED_RESTART_SONG + desc;
		// else
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
		// OptionsMenu.markRestartSong(); // JOELwindows7: mark restart song required.
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
		// OptionsMenu.markRestartSong(); // JOELwindows7: mark restart song required.
		return true;
	}

	public override function getValue():String
	{
		return "Noteskin: < " + NoteskinHelpers.getNoteskinByID(FlxG.save.data.noteskin) + " >";
	}
}

// JOELwindows7: and botplay!
class BotPlayModifier extends Modifier
{
	public function new(desc:String)
	{
		super();
		// if (OptionsMenu.isInPause)
		// 	// description = "This option cannot be toggled in the pause menu.";
		// 	// description = Perkedel.OPTION_SAY_CANNOT_ACCESS_IN_PAUSE + desc; // JOELwindows7: here with new const for it.
		// 	description = Perkedel.OPTION_SAY_NEED_RESTART_SONG + desc; // JOELwindows7: here with new const for it.
		// else
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
