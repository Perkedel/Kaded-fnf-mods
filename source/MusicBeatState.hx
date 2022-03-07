package;

import flixel.addons.ui.FlxUI;
import flixel.FlxState;
import plugins.sprites.QmovephBackground;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup;
import flixel.addons.display.FlxStarField;
import plugins.sprites.DVDScreenSaver;
import flixel.tweens.FlxEase;
import flixel.FlxCamera;
import ui.FlxVirtualPad;
import flixel.input.actions.FlxActionInput;
import TouchScreenControls;
import haxe.Json;
import lime.utils.Assets;
import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.math.FlxMath;
import flixel.FlxCamera;
import flixel.text.FlxText;
import lime.app.Application;
import flixel.FlxBasic;
#if FEATURE_DISCORD
import Discord.DiscordClient;
#end
import flixel.util.FlxColor;
import openfl.Lib;
import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;

using StringTools;

// JOELwindows7: now inherit from CoreState instead of FlxUIState
class MusicBeatState extends CoreState
{
	// JOELwindows7: all var I add moved to CoreState.hx
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var curDecimalBeat:Float = 0;

	// JOELwindows7: Kade + YinYang48 Hex stuff
	public var fuckYou:Bool = false; // Loading canceler. marked true if somebody already using it, preventing double call.

	public static var lastState:FlxState; // Last state

	// private var controls(get, never):Controls; //JOELwindows7: steal controls
	// JOELwindows7: stole this getter too
	/*
		inline function get_controls():Controls
			return PlayerSettings.player1.controls;
	 */
	public static var initSave:Bool = false;

	private var assets:Array<FlxBasic> = [];

	override function destroy()
	{
		Application.current.window.onFocusIn.remove(onWindowFocusOut);
		Application.current.window.onFocusIn.remove(onWindowFocusIn);
		super.destroy();
	}

	override function add(Object:flixel.FlxBasic):flixel.FlxBasic
	{
		// JOELwindows7: kade + yinyang48 hex stuff
		// https://github.com/KadeDev/Hex-The-Weekend-Update/blob/main/source/MusicBeatState.hx
		if (Std.isOfType(Object, FlxUI))
			return null;

		if (Std.isOfType(Object, FlxSprite))
		{
			var spr:FlxSprite = cast(Object, FlxSprite);
			if (spr.graphic != null)
			{
				if (spr.graphic.bitmap.image == null)
					if (FlxG.save.data.annoyingWarns)
						Debug.logWarn("you are adding a fuckin null texture (THIS WILL CRASH YOUR GAME!)");
			}
		}
		// Debug.logTrace(Object);
		#if EXPERIMENTAL_HEX_WEEKEND
		MasterObjectLoader.addObject(Object);
		#end

		// JOELwindows7: move it here
		if (FlxG.save.data.optimize)
			assets.push(Object);
		// var result = super.add(Object);
		// return result;
		// JOELwindows7: hey pls functional!
		return super.add(Object); // yeah that's better.
	}

	// JOELwindows7: also this remove override thingy
	override function remove(Object:flixel.FlxBasic, Splice:Bool = false):flixel.FlxBasic
	{
		#if EXPERIMENTAL_HEX_WEEKEND
		MasterObjectLoader.removeObject(Object);
		#end
		// var result = super.remove(Object, Splice);
		// return result;
		// JOELwindows7: hey pls functional!
		return super.remove(Object, Splice); // yeah that's better.
	}

	public function clean()
	{
		if (FlxG.save.data.optimize)
		{
			for (i in assets)
			{
				remove(i);
			}
		}
	}

	// JOELwindows7: here Hex by YinYang48 + Kade yoink stuff
	// https://github.com/KadeDev/Hex-The-Weekend-Update/blob/main/source/MusicBeatState.hx

	/**
	 * Better Switch state using Kade's & YinYang48's Hex loading screen, or just go straight to the game, idk.
	 * To make sure things got loaded properly before going to the target state.
	 * @param nextState your next state
	 * @param goToLoading whether to load stuffs beforehand
	 * @param trans whether to have transition
	 * @param song is this a song loading?
	 */
	public function switchState(nextState:FlxState, goToLoading:Bool = true, trans:Bool = true, song:Bool = false, stopMusic:Bool = false)
	{
		#if EXPERIMENTAL_HEX_WEEKEND
		if (fuckYou)
			return;
		fuckYou = true;
		Debug.logTrace("switching");
		if (trans)
		{
			Debug.logTrace("With Transition");
			transitionOut(function()
			{
				lastState = this;
				if (goToLoading)
				{
					Debug.logTrace("Loading screen pls");
					var state:FlxState = new LoadingScreen(nextState, song);

					@:privateAccess
					FlxG.game._requestedState = state;
				}
				else
				{
					Debug.logTrace("Straight to the core");
					@:privateAccess
					FlxG.game._requestedState = nextState;
				}
				Debug.logTrace("switched");
			});
		}
		else
		{
			Debug.logTrace("No Transition");
			lastState = this;
			if (goToLoading)
			{
				Debug.logTrace("Loading screen pls");
				var state:FlxState = new LoadingScreen(nextState, song);

				@:privateAccess
				FlxG.game._requestedState = state;
			}
			else
			{
				Debug.logTrace("Straight to the core");
				@:privateAccess
				FlxG.game._requestedState = nextState;
			}
			Debug.logTrace("switched");
		}
		#else
		if (song)
			LoadingState.loadAndSwitchState(nextState, stopMusic)
		else
			FlxG.switchState(nextState);
		#end
	}

	var loadedCompletely:Bool = false; // JOELwindows7: also used by that Switch state above

	/**
	 * mark this thing that this has completed loading.
	 */
	public function load()
	{
		loadedCompletely = true;

		Debug.logInfo("State loaded!");
	}

	override function create()
	{
		if (initSave)
		{
			if (FlxG.save.data.laneTransparency < 0)
				FlxG.save.data.laneTransparency = 0;

			if (FlxG.save.data.laneTransparency > 1)
				FlxG.save.data.laneTransparency = 1;
		}

		Application.current.window.onFocusIn.add(onWindowFocusIn);
		Application.current.window.onFocusOut.add(onWindowFocusOut);
		TimingStruct.clearTimings();

		if (transIn != null)
			trace('reg ' + transIn.region);

		super.create();
		// trace("created Music Beat State");
	}

	override function update(elapsed:Float)
	{
		// everyStep();
		/*var nextStep:Int = updateCurStep();

			if (nextStep >= 0)
			{
				if (nextStep > curStep)
				{
					for (i in curStep...nextStep)
					{
						curStep++;
						updateBeat();
						stepHit();
					}
				}
				else if (nextStep < curStep)
				{
					//Song reset?
					curStep = nextStep;
					updateBeat();
					stepHit();
				}
		}*/

		if (Conductor.songPosition < 0)
			curDecimalBeat = 0;
		else
		{
			if (TimingStruct.AllTimings.length > 1)
			{
				var data = TimingStruct.getTimingAtTimestamp(Conductor.songPosition);

				FlxG.watch.addQuick("Current Conductor Timing Seg", data.bpm);

				Conductor.crochet = ((60 / data.bpm) * 1000);

				var step = ((60 / data.bpm) * 1000) / 4;
				var startInMS = (data.startTime * 1000);

				curDecimalBeat = data.startBeat + ((((Conductor.songPosition / 1000)) - data.startTime) * (data.bpm / 60));
				var ste:Int = Math.floor(data.startStep + ((Conductor.songPosition) - startInMS) / step);
				if (ste >= 0)
				{
					if (ste > curStep)
					{
						for (i in curStep...ste)
						{
							curStep++;
							updateBeat();
							stepHit();
						}
					}
					else if (ste < curStep)
					{
						trace("reset steps for some reason?? at " + Conductor.songPosition);
						// Song reset?
						curStep = ste;
						updateBeat();
						stepHit();
					}
				}
			}
			else
			{
				curDecimalBeat = (((Conductor.songPosition / 1000))) * (Conductor.bpm / 60);
				var nextStep:Int = Math.floor((Conductor.songPosition) / Conductor.stepCrochet);
				if (nextStep >= 0)
				{
					if (nextStep > curStep)
					{
						for (i in curStep...nextStep)
						{
							curStep++;
							updateBeat();
							stepHit();
						}
					}
					else if (nextStep < curStep)
					{
						// Song reset?
						trace("(no bpm change) reset steps for some reason?? at " + Conductor.songPosition);
						curStep = nextStep;
						updateBeat();
						stepHit();
					}
				}
				Conductor.crochet = ((60 / Conductor.bpm) * 1000);
			}
		}

		(cast(Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);

		super.update(elapsed);
	}

	private function updateBeat():Void
	{
		lastBeat = curBeat;
		curBeat = Math.floor(curStep / 4);
	}

	private function updateCurStep():Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		return lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		// do literally nothing dumbass
	}

	public function fancyOpenURL(schmancy:String)
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [schmancy, "&"]);
		#else
		FlxG.openURL(schmancy);
		#end
	}

	// JOELwindows7: everything I add has been moved to CoreState.hx

	function onWindowFocusIn():Void
	{
		Debug.logTrace("IM BACK!!!");
		#if FEATURE_DISPLAY_FPS_CHANGE // JOELwindows7: ooo, sneaky!
		(cast(Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
		#end
	}

	function onWindowFocusOut():Void
	{
		if (PlayState.inDaPlay)
		{
			if (!PlayState.instance.paused && !PlayState.instance.endingSong && PlayState.instance.songStarted)
			{
				Debug.logTrace("Lost Focus");
				PlayState.instance.openSubState(new PauseSubState());
				PlayState.boyfriend.stunned = true;

				PlayState.instance.persistentUpdate = false;
				PlayState.instance.persistentDraw = true;
				PlayState.instance.paused = true;

				PlayState.instance.vocals.stop();
				FlxG.sound.music.stop();
			}
		}
	}
}
