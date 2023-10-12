package;

import flixel.addons.ui.FlxUIButton;
import lime.ui.Haptic;
import flixel.util.FlxTimer;
import openfl.Lib;
import ui.FlxVirtualPad;
import flixel.ui.FlxButton;
import flixel.input.gamepad.FlxGamepad;
import flixel.FlxG;
import flixel.input.FlxInput;
import flixel.input.actions.FlxAction;
import flixel.input.actions.FlxActionInput;
import flixel.input.actions.FlxActionInputDigital;
import flixel.input.actions.FlxActionManager;
import flixel.input.actions.FlxActionSet;
import flixel.input.gamepad.FlxGamepadButton;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
// import haxe.hardware.Hardware;
#if windows
// JOELwindows7: Xinput now yeah
// import com.furusystems.openfl.input.xinput.*;
// import com.furusystems.openfl.input.*;
#end
#if android
import Hardware;
#end

#if (haxe >= "4.0.0")
enum abstract Action(String) to String from String
{
	var UP = "up";
	var LEFT = "left";
	var RIGHT = "right";
	var DOWN = "down";
	var UP_P = "up-press";
	var LEFT_P = "left-press";
	var RIGHT_P = "right-press";
	var DOWN_P = "down-press";
	var UP_R = "up-release";
	var LEFT_R = "left-release";
	var RIGHT_R = "right-release";
	var DOWN_R = "down-release";
	var ACCEPT = "accept";
	var BACK = "back";
	var PAUSE = "pause";
	var RESET = "reset";
	var CHEAT = "cheat";
}
#else
@:enum
abstract Action(String) to String from String
{
	var UP = "up";
	var LEFT = "left";
	var RIGHT = "right";
	var DOWN = "down";
	var UP_P = "up-press";
	var LEFT_P = "left-press";
	var RIGHT_P = "right-press";
	var DOWN_P = "down-press";
	var UP_R = "up-release";
	var LEFT_R = "left-release";
	var RIGHT_R = "right-release";
	var DOWN_R = "down-release";
	var ACCEPT = "accept";
	var BACK = "back";
	var PAUSE = "pause";
	var RESET = "reset";
	var CHEAT = "cheat";
}
#end

enum Device
{
	Keys;
	Gamepad(id:Int);
}

/**
 * Since, in many cases multiple actions should use similar keys, we don't want the
 * rebinding UI to list every action. ActionBinders are what the user percieves as
 * an input so, for instance, they can't set jump-press and jump-release to different keys.
 */
enum Control
{
	UP;
	LEFT;
	RIGHT;
	DOWN;
	RESET;
	ACCEPT;
	BACK;
	PAUSE;
	CHEAT;
}

enum KeyboardScheme
{
	Solo;
	Duo(first:Bool);
	None;
	Custom;
}

/**
 * A list of actions that a player would invoke via some input device.
 * Uses FlxActions to funnel various inputs to a single action.
 */
class Controls extends FlxActionSet
{
	var _up = new FlxActionDigital(Action.UP);
	var _left = new FlxActionDigital(Action.LEFT);
	var _right = new FlxActionDigital(Action.RIGHT);
	var _down = new FlxActionDigital(Action.DOWN);
	var _upP = new FlxActionDigital(Action.UP_P);
	var _leftP = new FlxActionDigital(Action.LEFT_P);
	var _rightP = new FlxActionDigital(Action.RIGHT_P);
	var _downP = new FlxActionDigital(Action.DOWN_P);
	var _upR = new FlxActionDigital(Action.UP_R);
	var _leftR = new FlxActionDigital(Action.LEFT_R);
	var _rightR = new FlxActionDigital(Action.RIGHT_R);
	var _downR = new FlxActionDigital(Action.DOWN_R);
	var _accept = new FlxActionDigital(Action.ACCEPT);
	var _back = new FlxActionDigital(Action.BACK);
	var _pause = new FlxActionDigital(Action.PAUSE);
	var _reset = new FlxActionDigital(Action.RESET);
	var _cheat = new FlxActionDigital(Action.CHEAT);

	#if (haxe >= "4.0.0")
	var byName:Map<String, FlxActionDigital> = [];
	#else
	var byName:Map<String, FlxActionDigital> = new Map<String, FlxActionDigital>();
	#end

	public var gamepadsAdded:Array<Int> = [];
	public var keyboardScheme = KeyboardScheme.None;

	// JOELwindows7:Xinput thingy pls
	// https://github.com/furusystems/openfl-xinput
	#if windows
	// var controller:Map<Int,XBox360Controller>;
	#end
	public var UP(get, never):Bool;

	inline function get_UP()
		return _up.check();

	public var LEFT(get, never):Bool;

	inline function get_LEFT()
		return _left.check();

	public var RIGHT(get, never):Bool;

	inline function get_RIGHT()
		return _right.check();

	public var DOWN(get, never):Bool;

	inline function get_DOWN()
		return _down.check();

	public var UP_P(get, never):Bool;

	inline function get_UP_P()
		return _upP.check();

	public var LEFT_P(get, never):Bool;

	inline function get_LEFT_P()
		return _leftP.check();

	public var RIGHT_P(get, never):Bool;

	inline function get_RIGHT_P()
		return _rightP.check();

	public var DOWN_P(get, never):Bool;

	inline function get_DOWN_P()
		return _downP.check();

	public var UP_R(get, never):Bool;

	inline function get_UP_R()
		return _upR.check();

	public var LEFT_R(get, never):Bool;

	inline function get_LEFT_R()
		return _leftR.check();

	public var RIGHT_R(get, never):Bool;

	inline function get_RIGHT_R()
		return _rightR.check();

	public var DOWN_R(get, never):Bool;

	inline function get_DOWN_R()
		return _downR.check();

	public var ACCEPT(get, never):Bool;

	inline function get_ACCEPT()
		return _accept.check();

	public var BACK(get, never):Bool;

	inline function get_BACK()
		return _back.check();

	public var PAUSE(get, never):Bool;

	inline function get_PAUSE()
		return _pause.check();

	public var RESET(get, never):Bool;

	inline function get_RESET()
		return _reset.check();

	public var CHEAT(get, never):Bool;

	inline function get_CHEAT()
		return _cheat.check();

	#if (haxe >= "4.0.0")
	public function new(name, scheme = None)
	{
		// JOELwindows7: Xinput API stuff
		#if windows
		// controller = new Map<Int,XBox360Controller>();
		// controller.set(0,new XBox360Controller(0));
		#end

		mappedinputs = new Map<FlxActionDigital, FlxActionInput>();
		super(name);

		add(_up);
		add(_left);
		add(_right);
		add(_down);
		add(_upP);
		add(_leftP);
		add(_rightP);
		add(_downP);
		add(_upR);
		add(_leftR);
		add(_rightR);
		add(_downR);
		add(_accept);
		add(_back);
		add(_pause);
		add(_reset);
		add(_cheat);

		for (action in digitalActions)
			byName[action.name] = action;

		setKeyboardScheme(scheme, false);
	}
	#else
	public function new(name, scheme:KeyboardScheme = null)
	{
		super(name);

		add(_up);
		add(_left);
		add(_right);
		add(_down);
		add(_upP);
		add(_leftP);
		add(_rightP);
		add(_downP);
		add(_upR);
		add(_leftR);
		add(_rightR);
		add(_downR);
		add(_accept);
		add(_back);
		add(_pause);
		add(_reset);
		add(_cheat);

		for (action in digitalActions)
			byName[action.name] = action;

		if (scheme == null)
			scheme = None;
		setKeyboardScheme(scheme, false);
	}
	#end

	// JOELwindows7: read function bellow
	public var trackedinputs:Array<FlxActionInput> = [];

	// JOELwindows7: map the inputer
	public var mappedinputs:Map<FlxActionDigital, FlxActionInput>;

	/**
	 * JOELwindows7: attempted to install things touchscreen.
	 * add the Button for that onscreen gameplay buttons.
	 * inspire it from https://github.com/luckydog7/Funkin-android/blob/master/source/Controls.hx
	 * @param action the action
	 * @param thing the button
	 * @param state the state of that button
	 */
	public function installActionButtonings(action:FlxActionDigital, thing:FlxUIButton, state:FlxInputState)
	{
		// trace("install action buttonings " + Std.string(action) + " " + Std.string(thing) + " " + Std.string(state));
		var input = new FlxActionInputDigitalIFlxInput(thing, state);
		trackedinputs.push(input);

		action.add(input);
		mappedinputs.set(action, input);
		// trace("add the " + mappedinputs.toString() + " a " + Std.string(action) + " in " + Std.string(state));
	}

	public function uninstallActionButtonings(action:FlxActionDigital, thing:FlxUIButton, state:FlxInputState)
	{
		// trace("uninstall action buttonings " + Std.string(action) + " " + Std.string(thing) + " " + Std.string(state));
		// var input = new FlxActionInputDigitalIFlxInput(thing, state);

		// trace("remove the " + mappedinputs.toString() + " a " + Std.string(action) + " in " + Std.string(state));
		action.remove(mappedinputs.get(action));
	}

	public function deleteActionButtonings(action:FlxActionDigital, inputOfIt:FlxActionInput)
	{
		action.remove(inputOfIt);
	}

	/**
	 * JOELwindows7: okeh set action buttonings, Hitbox version
	 * https://github.com/luckydog7/Funkin-android/blob/master/source/Controls.hx
	 * @param handoverTouchscreenButtons give the instance of Hitbox
	 * @param howManyButtons How many are the buttons? is this DDR, or Shaggy time again?
	 */
	public function installTouchScreenGameplays(handoverTouchscreenButtons:TouchScreenControls, howManyButtons:Int = 4)
	{
		// trace("install the bind for hitbox");
		inline forEachBound(Control.UP, (action, state) -> installActionButtonings(action, handoverTouchscreenButtons.buttonLeft, state));
		inline forEachBound(Control.DOWN, (action, state) -> installActionButtonings(action, handoverTouchscreenButtons.buttonDown, state));
		inline forEachBound(Control.LEFT, (action, state) -> installActionButtonings(action, handoverTouchscreenButtons.buttonUp, state));
		inline forEachBound(Control.RIGHT, (action, state) -> installActionButtonings(action, handoverTouchscreenButtons.buttonRight, state));

		/*
			inline forEachBound(Control.UP, (action, state) -> installActionButtonings(action, handoverTouchscreenButtons.daButtoners.members[0], state));
			inline forEachBound(Control.DOWN, (action, state) -> installActionButtonings(action, handoverTouchscreenButtons.daButtoners.members[1], state));
			inline forEachBound(Control.LEFT, (action, state) -> installActionButtonings(action, handoverTouchscreenButtons.daButtoners.members[2], state));
			inline forEachBound(Control.RIGHT, (action, state) -> installActionButtonings(action, handoverTouchscreenButtons.daButtoners.members[3], state));
		 */

		// trace("You have now mapped inputs " + mappedinputs.toString());
	}

	public function uninstallTouchScreenGameplays(handoverTouchscreenButtons:TouchScreenControls, howManyButtons:Int = 4)
	{
		// trace("You were having mapped inputs " + mappedinputs.toString());
		inline forEachBound(Control.UP, (action, state) -> uninstallActionButtonings(action, handoverTouchscreenButtons.buttonLeft, state));
		inline forEachBound(Control.DOWN, (action, state) -> uninstallActionButtonings(action, handoverTouchscreenButtons.buttonDown, state));
		inline forEachBound(Control.LEFT, (action, state) -> uninstallActionButtonings(action, handoverTouchscreenButtons.buttonUp, state));
		inline forEachBound(Control.RIGHT, (action, state) -> uninstallActionButtonings(action, handoverTouchscreenButtons.buttonRight, state));
	}

	//

	/**
	 * JOELwindows7: yeah this one too
	 * https://github.com/luckydog7/Funkin-android/blob/master/source/Controls.hx
	 * @param virtualPad hand the virtualpad instance
	 * @param DPad Which Dpad type you'd like to have?
	 * @param Action Which Action button do you want? A, B, X, Y? or C?
	 */
	public function setVirtualPad(virtualPad:FlxVirtualPad, ?DPad:FlxDPadMode, ?Action:FlxActionMode, ?isGameplay:Bool = false)
	{
		trace("install bind for FlxVirtualPad " + Std.string(virtualPad) + " " + Std.string(DPad) + " " + Std.string(Action));
		// Safety feature of it the handover optional variable value isn't given.
		if (DPad == null)
			DPad = NONE;
		if (Action == null)
			Action = NONE;

		// Now onto the action!
		trace("install DPAD touch " + Std.string(DPad));
		switch (DPad)
		{
			case UP_DOWN:
				inline forEachBound(Control.UP, (action, state) -> installActionButtonings(action, cast virtualPad.buttonUp, state));
				inline forEachBound(Control.DOWN, (action, state) -> installActionButtonings(action, cast virtualPad.buttonDown, state));
			case LEFT_RIGHT:
				inline forEachBound(Control.LEFT, (action, state) -> installActionButtonings(action, cast virtualPad.buttonLeft, state));
				inline forEachBound(Control.RIGHT, (action, state) -> installActionButtonings(action, cast virtualPad.buttonRight, state));
			case UP_LEFT_RIGHT:
				inline forEachBound(Control.UP, (action, state) -> installActionButtonings(action, cast virtualPad.buttonUp, state));
				inline forEachBound(Control.LEFT, (action, state) -> installActionButtonings(action, cast virtualPad.buttonLeft, state));
				inline forEachBound(Control.RIGHT, (action, state) -> installActionButtonings(action, cast virtualPad.buttonRight, state));
			case FULL | RIGHT_FULL:
				// We don't have RIGHT_FULL here by default, it was from luckydog7's mod of the FlxVirtualPad library itself.
				trace("inlined assignations");
				inline forEachBound(Control.UP, (action, state) -> installActionButtonings(action, cast virtualPad.buttonUp, state));
				inline forEachBound(Control.DOWN, (action, state) -> installActionButtonings(action, cast virtualPad.buttonDown, state));
				inline forEachBound(Control.LEFT, (action, state) -> installActionButtonings(action, cast virtualPad.buttonLeft, state));
				inline forEachBound(Control.RIGHT, (action, state) -> installActionButtonings(action, cast virtualPad.buttonRight, state));
			case NONE:
				trace("No DPAD");
		}

		trace("install Action touch " + Std.string(Action));
		switch (Action)
		{
			case A:
				inline forEachBound(Control.ACCEPT, (action, state) -> installActionButtonings(action, cast virtualPad.buttonA, state));
			case A_B:
				inline forEachBound(Control.ACCEPT, (action, state) -> installActionButtonings(action, cast virtualPad.buttonA, state));
				inline forEachBound(Control.BACK, (action, state) -> installActionButtonings(action, cast virtualPad.buttonB, state));
			case A_B_C:
				inline forEachBound(Control.ACCEPT, (action, state) -> installActionButtonings(action, cast virtualPad.buttonA, state));
				inline forEachBound(Control.BACK, (action, state) -> installActionButtonings(action, cast virtualPad.buttonB, state));
			case A_B_X_Y:
				if (isGameplay)
				{
					inline forEachBound(Control.UP, (action, state) -> installActionButtonings(action, cast virtualPad.buttonY, state));
					inline forEachBound(Control.DOWN, (action, state) -> installActionButtonings(action, cast virtualPad.buttonA, state));
					inline forEachBound(Control.LEFT, (action, state) -> installActionButtonings(action, cast virtualPad.buttonX, state));
					inline forEachBound(Control.RIGHT, (action, state) -> installActionButtonings(action, cast virtualPad.buttonB, state));
				}
				else
				{
					inline forEachBound(Control.ACCEPT, (action, state) -> installActionButtonings(action, cast virtualPad.buttonA, state));
					inline forEachBound(Control.BACK, (action, state) -> installActionButtonings(action, cast virtualPad.buttonB, state));
				}
			case NONE:
				trace("No Action button");
		}

		trace("You have now mapped inputs " + mappedinputs.toString());
	}

	public function unsetVirtualPad(virtualPad:FlxVirtualPad, ?DPad:FlxDPadMode, ?Action:FlxActionMode, ?isGameplay:Bool = false)
	{
		trace("uninstall bind for FlxVirtualPad " + Std.string(virtualPad) + " " + Std.string(DPad) + " " + Std.string(Action));
		// Safety feature of it the handover optional variable value isn't given.
		if (DPad == null)
			DPad = NONE;
		if (Action == null)
			Action = NONE;
		trace("You were having mapped inputs " + mappedinputs.toString());

		// Now onto the action!
		trace("uninstall DPAD touch " + Std.string(DPad));
		switch (DPad)
		{
			case UP_DOWN:
				inline forEachBound(Control.UP, (action, state) -> uninstallActionButtonings(action, cast virtualPad.buttonUp, state));
				inline forEachBound(Control.DOWN, (action, state) -> uninstallActionButtonings(action, cast virtualPad.buttonDown, state));
			case LEFT_RIGHT:
				inline forEachBound(Control.LEFT, (action, state) -> uninstallActionButtonings(action, cast virtualPad.buttonLeft, state));
				inline forEachBound(Control.RIGHT, (action, state) -> uninstallActionButtonings(action, cast virtualPad.buttonRight, state));
			case UP_LEFT_RIGHT:
				inline forEachBound(Control.UP, (action, state) -> uninstallActionButtonings(action, cast virtualPad.buttonUp, state));
				inline forEachBound(Control.LEFT, (action, state) -> uninstallActionButtonings(action, cast virtualPad.buttonLeft, state));
				inline forEachBound(Control.RIGHT, (action, state) -> uninstallActionButtonings(action, cast virtualPad.buttonRight, state));
			case FULL | RIGHT_FULL:
				// We don't have RIGHT_FULL here by default, it was from luckydog7's mod of the FlxVirtualPad library itself.
				trace("inlined unassignations");
				inline forEachBound(Control.UP, (action, state) -> uninstallActionButtonings(action, cast virtualPad.buttonUp, state));
				inline forEachBound(Control.DOWN, (action, state) -> uninstallActionButtonings(action, cast virtualPad.buttonDown, state));
				inline forEachBound(Control.LEFT, (action, state) -> uninstallActionButtonings(action, cast virtualPad.buttonLeft, state));
				inline forEachBound(Control.RIGHT, (action, state) -> uninstallActionButtonings(action, cast virtualPad.buttonRight, state));
			case NONE:
				trace("No DPAD");
		}

		trace("uninstall Action touch " + Std.string(Action));
		switch (Action)
		{
			case A:
				inline forEachBound(Control.ACCEPT, (action, state) -> uninstallActionButtonings(action, cast virtualPad.buttonA, state));
			case A_B:
				inline forEachBound(Control.ACCEPT, (action, state) -> uninstallActionButtonings(action, cast virtualPad.buttonA, state));
				inline forEachBound(Control.BACK, (action, state) -> uninstallActionButtonings(action, cast virtualPad.buttonB, state));
			case A_B_C:
				inline forEachBound(Control.ACCEPT, (action, state) -> uninstallActionButtonings(action, cast virtualPad.buttonA, state));
				inline forEachBound(Control.BACK, (action, state) -> uninstallActionButtonings(action, cast virtualPad.buttonB, state));
			case A_B_X_Y:
				if (isGameplay)
				{
					inline forEachBound(Control.UP, (action, state) -> uninstallActionButtonings(action, cast virtualPad.buttonX, state));
					inline forEachBound(Control.DOWN, (action, state) -> uninstallActionButtonings(action, cast virtualPad.buttonY, state));
					inline forEachBound(Control.LEFT, (action, state) -> uninstallActionButtonings(action, cast virtualPad.buttonB, state));
					inline forEachBound(Control.RIGHT, (action, state) -> uninstallActionButtonings(action, cast virtualPad.buttonA, state));
				}
				else
				{
					inline forEachBound(Control.ACCEPT, (action, state) -> uninstallActionButtonings(action, cast virtualPad.buttonA, state));
					inline forEachBound(Control.BACK, (action, state) -> uninstallActionButtonings(action, cast virtualPad.buttonB, state));
				}
			case NONE:
				trace("No Action button");
		}
	}

	/**
	 * remove Flx virtual pad Input
	 * yoink from https://github.com/luckydog7/trickster/blob/master/source/Controls.hx
	 * @author JOELwindows7
	 * @param Tinputs 
	 */
	public function removeFlxInput(Tinputs)
	{
		for (action in this.digitalActions)
		{
			var i = action.inputs.length;

			while (i-- > 0)
			{
				var input = action.inputs[i];
				/*if (input.device == IFLXINPUT_OBJECT)
					action.remove(input); */

				var x = Tinputs.length;
				while (x-- > 0)
					if (Tinputs[x] == input)
						action.remove(input);
			}
		}
	}

	/**
	 * Vibrate Controller or Device for the time
	 * @param duration how long is vibration in milisecond
	 * @param player which gamepad it should vibrates
	 */
	public static function vibrate(player:Int = 0, duration:Float = 100, period:Float = 0, strengthLeft:Float = 0, strengthRight:Float = 0)
	{
		// JOELwindows7: yess vibration go BRRR
		if (FlxG.save.data.vibration)
		{
			new FlxTimer().start(FlxG.save.data.vibrationOffset, function(timer:FlxTimer)
			{
				Haptic.vibrate(Std.int(period), Std.int(duration)); // uh, lime got better implementation lol
			});

			#if android
			// Hardware.vibrate(Std.int(duration));
			#end

			rumble(player, strengthLeft, strengthRight);
			new FlxTimer().start(duration, function(timer:FlxTimer)
			{
				rumble(player, 0, 0); // stop after it reaches the duration.
			});
		}
	}

	/**
	 * Set Rumble of the Gamepad at the specified parameter.
	 * it will stay at that set value until set again to another one.
	 * @param player which player
	 * @param strengthLeft left vibrator (coarse) strength, 0 - 65535
	 * @param stregthRight right vibrator (fine) strength, 0 - 65535
	 */
	public static function rumble(player:Int = 0, strengthLeft:Float = 0, strengthRight:Float = 0)
	{
		#if (windows && sys)
		// if(
		// 	(cast (Lib.current.getChildAt(0), Controls)).controller != null &&
		// 	(cast (Lib.current.getChildAt(0), Controls)).controller.get(player).isConnected()
		// 	){
		// 		(cast (Lib.current.getChildAt(0), Controls)).controller.get(player).vibrationLeft = Std.int(strengthLeft);
		// 		(cast (Lib.current.getChildAt(0), Controls)).controller.get(player).vibrationRight = Std.int(strengthRight);
		// }
		#end

		#if EXPERIMENTAL_OPENFL_XINPUT
		if (Main.xboxControllers[player].isConnected)
			Main.xboxControllers[player].vibrationLeft = Std.int(strengthLeft);
		Main.xboxControllers[player].vibrationRight = Std.int(strengthRight);
		#end
	}

	override function update()
	{
		super.update();
	}

	// inline
	public function checkByName(name:Action):Bool
	{
		#if debug
		if (!byName.exists(name))
			throw 'Invalid name: $name';
		#end
		return byName[name].check();
	}

	public function getDialogueName(action:FlxActionDigital):String
	{
		var input = action.inputs[0];
		return switch input.device
		{
			case KEYBOARD: return '[${(input.inputID : FlxKey)}]';
			case GAMEPAD: return '(${(input.inputID : FlxGamepadInputID)})';
			case device: throw 'unhandled device: $device';
		}
	}

	public function getDialogueNameFromToken(token:String):String
	{
		return getDialogueName(getActionFromControl(Control.createByName(token.toUpperCase())));
	}

	function getActionFromControl(control:Control):FlxActionDigital
	{
		return switch (control)
		{
			case UP: _up;
			case DOWN: _down;
			case LEFT: _left;
			case RIGHT: _right;
			case ACCEPT: _accept;
			case BACK: _back;
			case PAUSE: _pause;
			case RESET: _reset;
			case CHEAT: _cheat;
		}
	}

	static function init():Void
	{
		var actions = new FlxActionManager();
		FlxG.inputs.add(actions);
	}

	/**
	 * Calls a function passing each action bound by the specified control
	 * @param control
	 * @param func
	 * @return ->Void)
	 */
	function forEachBound(control:Control, func:FlxActionDigital->FlxInputState->Void)
	{
		// trace("Check for each bound " + Std.string(control) + " " + Std.string(func));
		switch (control)
		{
			case UP:
				func(_up, PRESSED);
				func(_upP, JUST_PRESSED);
				func(_upR, JUST_RELEASED);
			case LEFT:
				func(_left, PRESSED);
				func(_leftP, JUST_PRESSED);
				func(_leftR, JUST_RELEASED);
			case RIGHT:
				func(_right, PRESSED);
				func(_rightP, JUST_PRESSED);
				func(_rightR, JUST_RELEASED);
			case DOWN:
				func(_down, PRESSED);
				func(_downP, JUST_PRESSED);
				func(_downR, JUST_RELEASED);
			case ACCEPT:
				func(_accept, JUST_PRESSED);
			case BACK:
				func(_back, JUST_PRESSED);
			case PAUSE:
				func(_pause, JUST_PRESSED);
			case RESET:
				func(_reset, JUST_PRESSED);
			case CHEAT:
				func(_cheat, JUST_PRESSED);
		}
	}

	public function replaceBinding(control:Control, device:Device, ?toAdd:Int, ?toRemove:Int)
	{
		if (toAdd == toRemove)
			return;

		switch (device)
		{
			case Keys:
				if (toRemove != null)
					unbindKeys(control, [toRemove]);
				if (toAdd != null)
					bindKeys(control, [toAdd]);

			case Gamepad(id):
				if (toRemove != null)
					unbindButtons(control, id, [toRemove]);
				if (toAdd != null)
					bindButtons(control, id, [toAdd]);
		}
	}

	public function copyFrom(controls:Controls, ?device:Device)
	{
		#if (haxe >= "4.0.0")
		for (name => action in controls.byName)
		{
			for (input in action.inputs)
			{
				if (device == null || isDevice(input, device))
					byName[name].add(cast input);
			}
		}
		#else
		for (name in controls.byName.keys())
		{
			var action = controls.byName[name];
			for (input in action.inputs)
			{
				if (device == null || isDevice(input, device))
					byName[name].add(cast input);
			}
		}
		#end

		switch (device)
		{
			case null:
				// add all
				#if (haxe >= "4.0.0")
				for (gamepad in controls.gamepadsAdded)
					if (!gamepadsAdded.contains(gamepad))
						gamepadsAdded.push(gamepad);
				#else
				for (gamepad in controls.gamepadsAdded)
					if (gamepadsAdded.indexOf(gamepad) == -1)
						gamepadsAdded.push(gamepad);
				#end

				mergeKeyboardScheme(controls.keyboardScheme);

			case Gamepad(id):
				gamepadsAdded.push(id);
			case Keys:
				mergeKeyboardScheme(controls.keyboardScheme);
		}
	}

	inline public function copyTo(controls:Controls, ?device:Device)
	{
		controls.copyFrom(this, device);
	}

	function mergeKeyboardScheme(scheme:KeyboardScheme):Void
	{
		if (scheme != None)
		{
			switch (keyboardScheme)
			{
				case None:
					keyboardScheme = scheme;
				default:
					keyboardScheme = Custom;
			}
		}
	}

	/**
	 * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
	 * If binder is a literal you can inline this
	 */
	public function bindKeys(control:Control, keys:Array<FlxKey>)
	{
		#if (haxe >= "4.0.0")
		inline forEachBound(control, (action, state) -> addKeys(action, keys, state));
		#else
		forEachBound(control, function(action, state) addKeys(action, keys, state));
		#end
	}

	/**
	 * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
	 * If binder is a literal you can inline this
	 */
	public function unbindKeys(control:Control, keys:Array<FlxKey>)
	{
		#if (haxe >= "4.0.0")
		inline forEachBound(control, (action, _) -> removeKeys(action, keys));
		#else
		forEachBound(control, function(action, _) removeKeys(action, keys));
		#end
	}

	inline static function addKeys(action:FlxActionDigital, keys:Array<FlxKey>, state:FlxInputState)
	{
		for (key in keys)
			action.addKey(key, state);
	}

	static function removeKeys(action:FlxActionDigital, keys:Array<FlxKey>)
	{
		var i = action.inputs.length;
		while (i-- > 0)
		{
			var input = action.inputs[i];
			if (input.device == KEYBOARD && keys.indexOf(cast input.inputID) != -1)
				action.remove(input);
		}
	}

	public function setKeyboardScheme(scheme:KeyboardScheme, reset = true)
	{
		#if web
		trace('Set the Keyboard Scheme ${scheme} with reset of ${reset}');
		#end
		loadKeyBinds();
		/*if (reset)
				removeKeyboard();

			keyboardScheme = scheme;

			#if (haxe >= "4.0.0")
			switch (scheme)
			{
				case Solo:
					inline bindKeys(Control.UP, [FlxKey.fromString("W"), FlxKey.UP]);
					inline bindKeys(Control.DOWN, [FlxKey.fromString("S"), FlxKey.DOWN]);
					inline bindKeys(Control.LEFT, [FlxKey.fromString("A"), FlxKey.LEFT]);
					inline bindKeys(Control.RIGHT, [FlxKey.fromString("D"), FlxKey.RIGHT]);
					inline bindKeys(Control.ACCEPT, [Z, SPACE, ENTER]);
					inline bindKeys(Control.BACK, [BACKSPACE, ESCAPE]);
					inline bindKeys(Control.PAUSE, [P, ENTER, ESCAPE]);
					inline bindKeys(Control.RESET, [FlxKey.fromString("R")]);
				case Duo(true):
					inline bindKeys(Control.UP, [W, K]);
					inline bindKeys(Control.DOWN, [S, J]);
					inline bindKeys(Control.LEFT, [A, H]);
					inline bindKeys(Control.RIGHT, [D, L]);
					inline bindKeys(Control.ACCEPT, [Z]);
					inline bindKeys(Control.BACK, [X]);
					inline bindKeys(Control.PAUSE, [ONE]);
					inline bindKeys(Control.RESET, [R]);
				case Duo(false):
					inline bindKeys(Control.UP, [FlxKey.UP]);
					inline bindKeys(Control.DOWN, [FlxKey.DOWN]);
					inline bindKeys(Control.LEFT, [FlxKey.LEFT]);
					inline bindKeys(Control.RIGHT, [FlxKey.RIGHT]);
					inline bindKeys(Control.ACCEPT, [O]);
					inline bindKeys(Control.BACK, [P]);
					inline bindKeys(Control.PAUSE, [ENTER]);
					inline bindKeys(Control.RESET, [BACKSPACE]);
				case None: // nothing
				case Custom: // nothing
			}
			#else
			switch (scheme)
			{
				case Solo:
					bindKeys(Control.UP, [W, K, FlxKey.UP]);
					bindKeys(Control.DOWN, [S, J, FlxKey.DOWN]);
					bindKeys(Control.LEFT, [A, H, FlxKey.LEFT]);
					bindKeys(Control.RIGHT, [D, L, FlxKey.RIGHT]);
					bindKeys(Control.ACCEPT, [Z, SPACE, ENTER]);
					bindKeys(Control.BACK, [BACKSPACE, ESCAPE]);
					bindKeys(Control.PAUSE, [P, ENTER, ESCAPE]);
					bindKeys(Control.RESET, [R]);
				case Duo(true):
					bindKeys(Control.UP, [W, K]);
					bindKeys(Control.DOWN, [S, J]);
					bindKeys(Control.LEFT, [A, H]);
					bindKeys(Control.RIGHT, [D, L]);
					bindKeys(Control.ACCEPT, [Z]);
					bindKeys(Control.BACK, [X]);
					bindKeys(Control.PAUSE, [ONE]);
					bindKeys(Control.RESET, [R]);
				case Duo(false):
					bindKeys(Control.UP, [FlxKey.UP]);
					bindKeys(Control.DOWN, [FlxKey.DOWN]);
					bindKeys(Control.LEFT, [FlxKey.LEFT]);
					bindKeys(Control.RIGHT, [FlxKey.RIGHT]);
					bindKeys(Control.ACCEPT, [O]);
					bindKeys(Control.BACK, [P]);
					bindKeys(Control.PAUSE, [ENTER]);
					bindKeys(Control.RESET, [BACKSPACE]);
				case None: // nothing
				case Custom: // nothing
			}
			#end */
	}

	public function loadKeyBinds()
	{
		#if web
		trace('Load Key Binds');
		// trace(FlxKey.fromString(FlxG.save.data.upBind));
		#end

		removeKeyboard();

		#if web
		trace('Keyboard removed');
		#end
		if (gamepadsAdded.length != 0)
			removeGamepad();
		#if web
		trace('Gamepad removed');
		#end

		KeyBinds.keyCheck();
		#if web
		trace('Checked the keybind');
		#end

		var buttons = new Map<Control, Array<FlxGamepadInputID>>();

		#if web
		trace('Gamepadding the keybind');
		#end

		if (KeyBinds.gamepad)
		{
			buttons.set(Control.UP, [FlxGamepadInputID.fromString(FlxG.save.data.upBind)]);
			buttons.set(Control.LEFT, [FlxGamepadInputID.fromString(FlxG.save.data.leftBind)]);
			buttons.set(Control.DOWN, [FlxGamepadInputID.fromString(FlxG.save.data.downBind)]);
			buttons.set(Control.RIGHT, [FlxGamepadInputID.fromString(FlxG.save.data.rightBind)]);
			buttons.set(Control.ACCEPT, [FlxGamepadInputID.A]);
			buttons.set(Control.BACK, [FlxGamepadInputID.B]);
			buttons.set(Control.PAUSE, [FlxGamepadInputID.fromString(FlxG.save.data.pauseBind)]);

			addGamepad(0, buttons);
			#if web
			trace('Add Gamepad p1 the buttons');
			#end
		}

		#if web
		trace('Rebinding new keys');
		#end

		inline bindKeys(Control.UP, [FlxKey.fromString(FlxG.save.data.upBind), FlxKey.UP]);
		inline bindKeys(Control.DOWN, [FlxKey.fromString(FlxG.save.data.downBind), FlxKey.DOWN]);
		inline bindKeys(Control.LEFT, [FlxKey.fromString(FlxG.save.data.leftBind), FlxKey.LEFT]);
		inline bindKeys(Control.RIGHT, [FlxKey.fromString(FlxG.save.data.rightBind), FlxKey.RIGHT]);
		inline bindKeys(Control.ACCEPT, [Z, SPACE, ENTER]);
		inline bindKeys(Control.BACK, [BACKSPACE, ESCAPE]);
		inline bindKeys(Control.PAUSE, [FlxKey.fromString(FlxG.save.data.pauseBind)]);
		inline bindKeys(Control.RESET, [FlxKey.fromString(FlxG.save.data.resetBind)]);

		#if web
		trace('Assign Volume keys');
		#end

		#if !web
		FlxG.sound.muteKeys = [FlxKey.fromString(FlxG.save.data.muteBind)];
		// #if web
		// trace('yea');
		// #end
		FlxG.sound.volumeDownKeys = [FlxKey.fromString(FlxG.save.data.volDownBind)];
		// #if web
		// trace('ooo');
		// #end
		FlxG.sound.volumeUpKeys = [FlxKey.fromString(FlxG.save.data.volUpBind)];
		#end

		#if web
		trace('Done Loading Keybinds');
		#end
	}

	function removeKeyboard()
	{
		#if web
		trace('Okay, let\'s remove keyboard first');
		#end
		for (action in this.digitalActions)
		{
			#if web
			trace('Removing Digital Keyboard Action of ${action}');
			#end
			var i = action.inputs.length;
			while (i-- > 0)
			{
				var input = action.inputs[i];
				if (input.device == KEYBOARD)
					action.remove(input);
			}
		}
	}

	public function addGamepad(id:Int, ?buttonMap:Map<Control, Array<FlxGamepadInputID>>):Void
	{
		if (gamepadsAdded.contains(id))
			gamepadsAdded.remove(id);

		gamepadsAdded.push(id);

		#if (haxe >= "4.0.0")
		for (control => buttons in buttonMap)
			inline bindButtons(control, id, buttons);
		#else
		for (control in buttonMap.keys())
			bindButtons(control, id, buttonMap[control]);
		#end
	}

	inline function addGamepadLiteral(id:Int, ?buttonMap:Map<Control, Array<FlxGamepadInputID>>):Void
	{
		gamepadsAdded.push(id);

		#if (haxe >= "4.0.0")
		for (control => buttons in buttonMap)
			inline bindButtons(control, id, buttons);
		#else
		for (control in buttonMap.keys())
			bindButtons(control, id, buttonMap[control]);
		#end
	}

	public function removeGamepad(deviceID:Int = FlxInputDeviceID.ALL):Void
	{
		for (action in this.digitalActions)
		{
			var i = action.inputs.length;
			while (i-- > 0)
			{
				var input = action.inputs[i];
				if (input.device == GAMEPAD && (deviceID == FlxInputDeviceID.ALL || input.deviceID == deviceID))
					action.remove(input);
			}
		}

		gamepadsAdded.remove(deviceID);
	}

	public function addDefaultGamepad(id):Void
	{
		#if !switch
		addGamepadLiteral(id, [
			Control.ACCEPT => [A],
			Control.BACK => [B],
			Control.UP => [DPAD_UP, LEFT_STICK_DIGITAL_UP],
			Control.DOWN => [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN],
			Control.LEFT => [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT],
			Control.RIGHT => [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT],
			Control.PAUSE => [START],
			Control.RESET => [Y]
		]);
		#else
		addGamepadLiteral(id, [
			// Swap A and B for switch
			Control.ACCEPT => [B],
			Control.BACK => [A],
			Control.UP => [DPAD_UP, LEFT_STICK_DIGITAL_UP, RIGHT_STICK_DIGITAL_UP],
			Control.DOWN => [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN, RIGHT_STICK_DIGITAL_DOWN],
			Control.LEFT => [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT, RIGHT_STICK_DIGITAL_LEFT],
			Control.RIGHT => [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT, RIGHT_STICK_DIGITAL_RIGHT],
			Control.PAUSE => [START],
			// Swap Y and X for switch
			Control.RESET => [Y],
			Control.CHEAT => [X]
		]);
		#end
	}

	/**
	 * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
	 * If binder is a literal you can inline this
	 */
	public function bindButtons(control:Control, id, buttons)
	{
		#if (haxe >= "4.0.0")
		inline forEachBound(control, (action, state) -> addButtons(action, buttons, state, id));
		#else
		forEachBound(control, function(action, state) addButtons(action, buttons, state, id));
		#end
	}

	/**
	 * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
	 * If binder is a literal you can inline this
	 */
	public function unbindButtons(control:Control, gamepadID:Int, buttons)
	{
		#if (haxe >= "4.0.0")
		inline forEachBound(control, (action, _) -> removeButtons(action, gamepadID, buttons));
		#else
		forEachBound(control, function(action, _) removeButtons(action, gamepadID, buttons));
		#end
	}

	inline static function addButtons(action:FlxActionDigital, buttons:Array<FlxGamepadInputID>, state, id)
	{
		for (button in buttons)
			action.addGamepad(button, state, id);
	}

	static function removeButtons(action:FlxActionDigital, gamepadID:Int, buttons:Array<FlxGamepadInputID>)
	{
		var i = action.inputs.length;
		while (i-- > 0)
		{
			var input = action.inputs[i];
			if (isGamepad(input, gamepadID) && buttons.indexOf(cast input.inputID) != -1)
				action.remove(input);
		}
	}

	public function getInputsFor(control:Control, device:Device, ?list:Array<Int>):Array<Int>
	{
		if (list == null)
			list = [];

		switch (device)
		{
			case Keys:
				for (input in getActionFromControl(control).inputs)
				{
					if (input.device == KEYBOARD)
						list.push(input.inputID);
				}
			case Gamepad(id):
				for (input in getActionFromControl(control).inputs)
				{
					if (input.deviceID == id)
						list.push(input.inputID);
				}
		}
		return list;
	}

	public function removeDevice(device:Device)
	{
		switch (device)
		{
			case Keys:
				#if web
				trace('I am removeing Keyboard Scheme of ${device}');
				#end
				setKeyboardScheme(None);
			case Gamepad(id):
				#if web
				trace('I am removeing Gamepad Scheme of ${device} No. ${id}');
				#end
				removeGamepad(id);
		}
	}

	static function isDevice(input:FlxActionInput, device:Device)
	{
		return switch device
		{
			case Keys: input.device == KEYBOARD;
			case Gamepad(id): isGamepad(input, id);
		}
	}

	inline static function isGamepad(input:FlxActionInput, deviceID:Int)
	{
		return input.device == GAMEPAD && (deviceID == FlxInputDeviceID.ALL || input.deviceID == deviceID);
	}
}
