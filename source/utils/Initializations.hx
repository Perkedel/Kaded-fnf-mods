/*
 * GNU General Public License, Version 3.0
 *
 * Copyright (c) 2022 Perkedel
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

package utils;

import flixel.graphics.FlxGraphic;
import GameJolt;
#if FEATURE_MULTITHREADING
import sys.thread.Mutex;
#end
import openfl.utils.Assets as OpenFlAssets;

class Initializations
{
	static public var initialized = false; // JOELwindows7: to wait initializations

	/**
	 * Initialize save datas & stuffs
	 */
	static public function begin()
	{
		// getBuildVer(); // JOELwindows7: BOLO thingy
		// JOELwindows7: Yoinkered Kade + YinYang48 Hex
		// https://github.com/KadeDev/Hex-The-Weekend-Update/blob/main/source/TitleState.hx
		#if FEATURE_MULTITHREADING
		MasterObjectLoader.mutex = new Mutex(); // JOELwindows7: you must first initialize the mutex.
		#end

		// JOELwindows7: clear unused memory first. BOLO
		Paths.clearUnusedMemory();
		Paths.clearUnusedMemory();
		// JOELwindows7: here init first!
		// JOELwindows7: TentaRJ GameJolter
		#if gamejolt
		// Main.gjToastManager.createToast(Paths.image("art/LFMicon64"), "Cool and good", "Welcome to Last Funkin Moments",
		// 	false); // JOELwindows7: create GameJolt Toast here.
		GameJoltAPI.connect();
		GameJoltAPI.authDaUser(FlxG.save.data.gjUser, FlxG.save.data.gjToken);
		#end

		FlxG.autoPause = false;

		FlxG.save.bind('funkin', 'ninjamuffin99');

		HitSounds.init(); // JOELwindows7: initialize BOLO's hitsound sound list yey!

		PlayerSettings.init();

		OpenFlAssets.cache.enabled = true; // JOELwindows7: BOLO enable caching OpenFl Assets

		KadeEngineData.initSave();

		// It doesn't reupdate the list before u restart rn lmao
		KeyBinds.keyCheck();
		NoteskinHelpers.updateNoteskins();

		// JOELwindows7: this should be nulled because these buttons can accident volkeys.
		// BOLO now moves these buttons into Numpad `+` & `-` now.
		// but still, accident can still happens despite that so. so no.
		// still disable by default!
		if (FlxG.save.data.volDownBind == null)
			FlxG.save.data.volDownBind = "NUMPADMINUS";
		// FlxG.save.data.volDownBind = "";
		if (FlxG.save.data.volUpBind == null)
			FlxG.save.data.volUpBind = "NUMPADPLUS";
		// FlxG.save.data.volUpBind = "";

		FlxG.game.focusLostFramerate = 60; // JOELwindows7: BOLO. Now there is auto reduce framerate when lost focus!
		// JOELwindows7: now depending on what happened, there you can have the accident volume keys null if you don't want it.
		FlxG.sound.muteKeys = FlxG.save.data.accidentVolumeKeys ? [FlxKey.fromString(FlxG.save.data.muteBind)] : null;
		FlxG.sound.volumeDownKeys = FlxG.save.data.accidentVolumeKeys ? [FlxKey.fromString(FlxG.save.data.volDownBind)] : null;
		FlxG.sound.volumeUpKeys = FlxG.save.data.accidentVolumeKeys ? [FlxKey.fromString(FlxG.save.data.volUpBind)] : null;

		FlxG.worldBounds.set(0, 0);

		FlxGraphic.defaultPersist = FlxG.save.data.cacheImages;

		MusicBeatState.initSave = true;

		FlxG.sound.volume = FlxG.save.data.volume;
		FlxG.sound.muted = FlxG.save.data.mute;

		initialized = true;
		trace('Things Initialized yey');
	}

	public static function isInitialized():Bool
	{
		return initialized;
	}

	public static function getBuildVer(forWhich:Int = 0):Void
	{
		// JOELwindows7: hey lemme just copy that from here.
		// Kade
		// Get current version of Kade Engine

		// JOELwindows7: do this if not mobile since in there this doesn't work
		// according to the luckydog7 and mods that don't care update
		#if FEATURE_HTTP
		var http = new haxe.Http("https://raw.githubusercontent.com/KadeDev/Kade-Engine/master/version.downloadMe");
		var returnedData:Array<String> = [];

		http.onData = function(data:String)
		{
			returnedData[0] = data.substring(0, data.indexOf(';'));
			returnedData[1] = data.substring(data.indexOf('-'), data.length);
			if (!MainMenuState.kadeEngineVer.contains(returnedData[0].trim()) && !OutdatedSubState.leftState)
			{
				OutdatedSubState.outdatedList[0] = true;
				trace('outdated lmao! ' + returnedData[0] + ' != ' + MainMenuState.kadeEngineVer);
				OutdatedSubState.needVer = returnedData[0];
				OutdatedSubState.currChanges = returnedData[1];
				// clean();
			}
			else
			{
				// FlxG.switchState(new MainMenuState());
				// switchState(new MainMenuState()); // JOELwindows7: hex switch state lol
				// clean();
				// JOELwindows7: hey, now step by step to this one
				checkLFMUpdateNow();
			}
		}

		http.onError = function(error)
		{
			trace('error: $error');
			// FlxG.switchState(new MainMenuState()); // fail but we go anyway
			// switchState(new MainMenuState()); // fail but we go anyway; JOELwindows7: hex switch state lol
			// clean();
			// JOELwindows7: hey, now step by step to this one
			checkLFMUpdateNow();
		}

		http.request();
		#else
		#end
	}

	public static function checkLFMUpdateNow():Void
	{
	}
}
