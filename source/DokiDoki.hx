/*
 * GNU General Public License, Version 3.0
 *
 * Copyright (c) 2021 Perkedel
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package;

import Conductor;
import Section.SwagSection;
import haxe.Json;
import tjson.TJSON;
import haxe.format.JsonParser;
import lime.utils.Assets;

using StringTools;

// JOELwindows7: Doki Doki heartbeating characters
// inspire from the Song.hx
typedef SwagHeart =
{
	var character:String;
	var initHR:Int;
	var minHR:Int;
	var maxHR:Int;
	var heartTierBoundaries:Array<Int>;
	var successionAdrenalAdd:Array<Int>;
	var fearShockAdd:Array<Int>;
	var relaxMinusPerBeat:Array<Int>;
}

typedef HeartList =
{
	var heartSpecs:Array<SwagHeart>;
	var heartOrder:Array<String>;
}

enum HeartStimulateType
{
	ADRENAL; // successfully step
	FEAR; // jumpscare heart rate up above
	SHOCK; // clear! reset heart rate to 0, idk.
	RELAX; // relax heart rate
	TRANSCUTANEOUS; // set heart rate to given value
}

class DokiDoki
{
	var heartSpecs:Array<SwagHeart>;

	var character:String;
	var initHR:Int = 70;
	var minHR:Int = 70;
	var maxHR:Int = 220;
	var heartTierBoundaries:Array<Int> = [90, 120, 150, 200];
	var successionAdrenalAdd:Array<Int> = [20, 15, 10, 5];
	var fearShockAdd:Array<Int> = [22, 20, 10, 5];
	var relaxMinusPerBeat:Array<Int> = [1, 5, 10, 15];

	public static var hearts:Map<String, SwagHeart>;

	public function new(character:String = "bf")
	{
		this.character = character;
		var heartList:HeartList = loadFromJson("heartBeatSpec");
		this.heartSpecs = heartList.heartSpecs;
		var chooseIndex:Int = 0;
		switch (character)
		{
			case 'bf':
				chooseIndex = 0;
			case 'gf':
				chooseIndex = 1;
			default:
				chooseIndex = 0;
		}

		var theHeart:SwagHeart = cast this.heartSpecs[chooseIndex];
		this.minHR = theHeart.minHR;
		this.maxHR = theHeart.maxHR;
		this.heartTierBoundaries = theHeart.heartTierBoundaries;
		this.successionAdrenalAdd = theHeart.successionAdrenalAdd;
		this.fearShockAdd = theHeart.fearShockAdd;
	}

	public static function loadFromJson(jsonInput:String):HeartList
	{
		trace(jsonInput);

		trace('loading heart spec ' + jsonInput);

		var rawJson = Assets.getText(Paths.json(jsonInput)).trim();

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
			// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
		}

		return parseJSONshit(rawJson);
	}

	public static function buildHeartsList():Map<String, SwagHeart>
	{
		if (hearts == null)
			hearts = new Map<String, SwagHeart>(); // Must be instantiated first!
		var HEARTS:HeartList = loadFromJson("heartBeatSpec");
		// trace("HEARTS: \n" + Std.string(HEARTS));
		var things:Array<SwagHeart> = HEARTS.heartSpecs.copy();
		// trace("things ("+ Std.string(things.length) +"): \n" + things.toString());
		// var workaroundList:Map<String,SwagHeart>; //wtf why still null object reference?!
		for (i in 0...things.length)
		{
			// workaroundList.set(things[i].character,things[i]);
			DokiDoki.hearts.set(things[i].character, things[i]);
		}
		return hearts;
		// return workaroundList;
	}

	public static function parseJSONshit(rawJson:String):HeartList
	{
		// var swagShit:HeartList = cast Json.parse(rawJson);
		var swagShit:HeartList = cast TJSON.parse(rawJson); // JOELwindows7: use TJSON instead!
		return swagShit;
	}
}

/**
 * This is one heart organ object that'll be located inside Character instance.
 * @author JOELwindows7
 */
class JantungOrgan
{
	var character:String;
	var initHR:Int = 70;
	var minHR:Int = 70;
	var maxHR:Int = 220;
	var heartTierBoundaries:Array<Int> = [90, 120, 150, 200];
	var successionAdrenalAdd:Array<Int> = [20, 15, 10, 5];
	var fearShockAdd:Array<Int> = [22, 20, 10, 5];
	var relaxMinusPerBeat:Array<Int> = [1, 5, 10, 15];
	var relaxHeartEveryBeatOf:Int = 4;

	var curHR:Float = 70;
	var crochet:Float = ((60 / 70) * 1000); // beats in milisecond.
	var stepCrochet:Float = ((60 / 70) * 1000) / 4; // steps in milisecond.
	var startTime:Float = 0; // second
	var curStep:Int = 0;
	var curBeat:Int = 0;
	var lastBeat:Int = 0;
	var curDecimalBeat:Float = 0;
	var startBeat:Int = 0;
	var startStep:Int = 0;
	var lifePosition:Float = 0;
	var tierDaRightNow:Int = 0;
	var slowedAlready:Bool = false;

	public var onStepHitCallback:Void->Void;
	public var onBeatHitCallback:Void->Void;

	public function new(handoverSpec:SwagHeart)
	{
		this.character = handoverSpec.character;
		// var chooseIndex:Int = 0;
		// switch (character)
		// {
		// 	case 'bf':
		// 		chooseIndex = 0;
		// 	case 'gf':
		// 		chooseIndex = 1;
		// 	default:
		// 		chooseIndex = 0;
		// }

		this.minHR = handoverSpec.minHR;
		this.maxHR = handoverSpec.maxHR;
		this.heartTierBoundaries = handoverSpec.heartTierBoundaries;
		this.successionAdrenalAdd = handoverSpec.successionAdrenalAdd;
		this.fearShockAdd = handoverSpec.fearShockAdd;
		this.relaxMinusPerBeat = handoverSpec.relaxMinusPerBeat;

		curHR = initHR;
	}

	/**
	 * This is the heart beat function. idk, the heart beats itself, it has electric system.
	 * the brain, controls its rate.
	 * This gets called in time of heart beat. 
	 * Like beatHit, but for the heart of its own. yeah another rhythm to simulate heartbeat
	 * just like Shinon51788's doki-doki dance but kinda advanced, idk.
	 * keep in mind, due to nature of programming design, the using class instance must call this in its own update function.
	 * @param	elapsed update elapsed handover
	 * @return
	 */
	public function update(elapsed:Float)
	{
		lifePosition = elapsed;

		// copy from MusicBeatState! try to use existing infrastructures, idk.
		if (TimingStruct.AllTimings.length > 1)
		{
		}

		// ah damn, we can't over depend on the song system can we?
		crochet = ((60 / curHR) * 1000);
		// var step = ((60 / curHR) * 1000) / 4;
		// var startInMS = (startTime * 1000);
		// curDecimalBeat = startBeat + ((((lifePosition / 1000)) - startTime) * (curHR / 60));
		// var ste:Int = Math.floor(startStep + ((lifePosition) - startInMS) / step);
		curDecimalBeat = (((lifePosition / 1000))) * (curHR / 60);
		var nextStep:Int = Math.floor((lifePosition) / Conductor.stepCrochet);
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
				// heart reset?
				trace("(no bpm change) reset heart steps for some reason?? at " + lifePosition);
				curStep = nextStep;
				updateBeat();
				stepHit();
			}
		}
	}

	function updateBeat()
	{
		// curBeat = Math.floor(curDecimalBeat);
		// curDecimalBeat = curDecimalBeat - curBeat;
		lastBeat = curBeat;
		curBeat = Math.floor(curStep / 4);
	}

	private function updateCurStep():Int
	{
		// var lastChange:BPMChangeEvent = {
		// 	stepTime: 0,
		// 	songTime: 0,
		// 	bpm: 0
		// }
		// for (i in 0...Conductor.bpmChangeMap.length)
		// {
		// 	if (lifePosition >= Conductor.bpmChangeMap[i].songTime)
		// 		lifePosition = Conductor.bpmChangeMap[i];
		// }

		// return lastChange.stepTime + Math.floor((lifePosition - lastChange.songTime) / Conductor.stepCrochet);
		return 0;
	}

	function stepHit()
	{
		if (curStep % 4 == 0)
			beatHit();

		onStepHitCallback();
	}

	function beatHit()
	{
		onBeatHitCallback();

		// auto slowdown
		if (curBeat % relaxHeartEveryBeatOf == 0)
		{
			if (!slowedAlready)
			{
				stimulate(HeartStimulateType.RELAX);
				slowedAlready = true;
			}
		}
		else
		{
			slowedAlready = false;
		}
	}

	/**
	 * Stimulate the heart organ to change its rate. 
	 * can be adrenal when successfully step, fear scare of that lightning bolt, or relaxation idles, etc.
	 * @param typeOfStimulate 
	 */
	public function stimulate(typeOfStimulate:HeartStimulateType, givenValue:Float = 0)
	{
		switch (typeOfStimulate)
		{
			case HeartStimulateType.ADRENAL:
				// curHR += successionAdrenalAdd[tierDaRightNow];
				increaseHR(successionAdrenalAdd[tierDaRightNow]);

			case HeartStimulateType.FEAR:
				// curHR += fearShockAdd[tierDaRightNow];
				increaseHR(fearShockAdd[tierDaRightNow]);
			case HeartStimulateType.RELAX:
				// curHR -= relaxMinusPerBeat[tierDaRightNow];
				increaseHR(-relaxMinusPerBeat[tierDaRightNow]);
			default:
		}

		checkWhichHeartTierWent(curHR);
	}

	public function increaseHR(forHowMuch:Float = 0)
	{
		curHR += forHowMuch;

		if (curHR > maxHR)
		{
			curHR = maxHR;
		}
		if (curHR < minHR)
		{
			curHR = minHR;
		}

		// update the tier status
		checkWhichHeartTierWent(curHR);
	}

	function checkWhichHeartTierWent(giveHB:Float)
	{
		// Hard code bcause logic brainstorm is haarde
		if (giveHB < heartTierBoundaries[0])
			tierDaRightNow = 0;
		else if (giveHB >= heartTierBoundaries[0] && giveHB < heartTierBoundaries[1])
			tierDaRightNow = 1;
		else if (giveHB >= heartTierBoundaries[1] && giveHB < heartTierBoundaries[2])
			tierDaRightNow = 2;
		else if (giveHB >= heartTierBoundaries[2] && giveHB < heartTierBoundaries[3])
			tierDaRightNow = 3;
		else if (giveHB >= heartTierBoundaries[3])
		{
			// uhhh, idk..
		}
	}
}
