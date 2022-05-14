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

class Initializations
{
	static public var initialized = false; // JOELwindows7: to wait initializations
	/**
	 * Initialize save datas & stuffs
	 */
	static public function begin()
	{
		// JOELwindows7: Yoinkered Kade + YinYang48 Hex
		// https://github.com/KadeDev/Hex-The-Weekend-Update/blob/main/source/TitleState.hx
		#if FEATURE_MULTITHREADING
		MasterObjectLoader.mutex = new Mutex(); // JOELwindows7: you must first initialize the mutex.
		#end

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

		PlayerSettings.init();

		KadeEngineData.initSave();

		// It doesn't reupdate the list before u restart rn lmao
		KeyBinds.keyCheck();
		NoteskinHelpers.updateNoteskins();

		// JOELwindows7: this should be nulled because these buttons can accident volkeys
		if (FlxG.save.data.volDownBind == null)
			FlxG.save.data.volDownBind = "MINUS";
		// FlxG.save.data.volDownBind = "";
		if (FlxG.save.data.volUpBind == null)
			FlxG.save.data.volUpBind = "PLUS";
		// FlxG.save.data.volUpBind = "";

		// JOELwindows7: now depending on what happened, there you can have the accident volume keys null if you don't want it.
		FlxG.sound.muteKeys = FlxG.save.data.accidentVolumeKeys ? [FlxKey.fromString(FlxG.save.data.muteBind)] : null;
		FlxG.sound.volumeDownKeys = FlxG.save.data.accidentVolumeKeys ? [FlxKey.fromString(FlxG.save.data.volDownBind)] : null;
		FlxG.sound.volumeUpKeys = FlxG.save.data.accidentVolumeKeys ? [FlxKey.fromString(FlxG.save.data.volUpBind)] : null;

		FlxG.worldBounds.set(0, 0);

		FlxGraphic.defaultPersist = FlxG.save.data.cacheImages;

		MusicBeatState.initSave = true;
		initialized = true;
	}

	public static function isInitialized():Bool
	{
		return initialized;
	}
}
