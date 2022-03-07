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
