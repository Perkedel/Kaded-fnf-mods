import flixel.input.gamepad.FlxGamepad;
import openfl.Lib;
import flixel.FlxG;

class KadeEngineData
{
	public static function initSave()
	{
		trace("init save data now");
		if (FlxG.save.data.weekUnlocked == null)
			FlxG.save.data.weekUnlocked = 7;

		if (FlxG.save.data.newInput == null)
			FlxG.save.data.newInput = true;

		if (FlxG.save.data.downscroll == null)
			FlxG.save.data.downscroll = false;

		if (FlxG.save.data.antialiasing == null)
			FlxG.save.data.antialiasing = true;

		if (FlxG.save.data.missSounds == null)
			FlxG.save.data.missSounds = true;

		if (FlxG.save.data.dfjk == null)
			FlxG.save.data.dfjk = false;

		if (FlxG.save.data.accuracyDisplay == null)
			FlxG.save.data.accuracyDisplay = true;

		if (FlxG.save.data.offset == null)
			FlxG.save.data.offset = 0;

		if (FlxG.save.data.songPosition == null)
			FlxG.save.data.songPosition = false;

		if (FlxG.save.data.fps == null)
			FlxG.save.data.fps = false;

		if (FlxG.save.data.changedHit == null)
		{
			FlxG.save.data.changedHitX = -1;
			FlxG.save.data.changedHitY = -1;
			FlxG.save.data.changedHit = false;
		}

		// JOELwindows7: don't forget init save data of fullscreen mode
		if (FlxG.save.data.fullscreen == null)
			FlxG.save.data.fullscreen == FlxG.fullscreen;

		if (FlxG.save.data.fpsRain == null)
			FlxG.save.data.fpsRain = false;

		if (FlxG.save.data.fpsCap == null)
			FlxG.save.data.fpsCap = 120;

		if (FlxG.save.data.fpsCap > 340 || FlxG.save.data.fpsCap < 60)
			FlxG.save.data.fpsCap = 120; // baby proof so you can't hard lock ur copy of kade engine

		if (FlxG.save.data.scrollSpeed == null)
			FlxG.save.data.scrollSpeed = 1;

		if (FlxG.save.data.npsDisplay == null)
			FlxG.save.data.npsDisplay = false;

		if (FlxG.save.data.frames == null)
			FlxG.save.data.frames = 10;

		if (FlxG.save.data.accuracyMod == null)
			FlxG.save.data.accuracyMod = 1;

		if (FlxG.save.data.watermark == null)
			FlxG.save.data.watermark = true;

		// JOELwindows7: odysee watermark
		if (FlxG.save.data.odyseeMark == null)
			FlxG.save.data.odyseeMark = true;

		// JOELwindows7: Perkedel watermark
		if (FlxG.save.data.perkedelMark == null)
			FlxG.save.data.perkedelMark = true;

		// JOELwindows7: naughtiness option
		if (FlxG.save.data.naughtiness == null)
			FlxG.save.data.naughtiness = true;

		if (FlxG.save.data.cardiophile == null)
			FlxG.save.data.cardiophile = true;

		if (FlxG.save.data.ghost == null)
			FlxG.save.data.ghost = true;

		if (FlxG.save.data.distractions == null)
			FlxG.save.data.distractions = true;

		if (FlxG.save.data.colour == null)
			FlxG.save.data.colour = true;

		if (FlxG.save.data.stepMania == null)
			FlxG.save.data.stepMania = false;

		if (FlxG.save.data.flashing == null)
			FlxG.save.data.flashing = true;

		if (FlxG.save.data.resetButton == null)
			FlxG.save.data.resetButton = false;

		if (FlxG.save.data.InstantRespawn == null)
			FlxG.save.data.InstantRespawn = false;

		if (FlxG.save.data.botplay == null)
			FlxG.save.data.botplay = false;

		if (FlxG.save.data.cpuStrums == null)
			FlxG.save.data.cpuStrums = false;

		if (FlxG.save.data.strumline == null)
			FlxG.save.data.strumline = false;

		if (FlxG.save.data.customStrumLine == null)
			FlxG.save.data.customStrumLine = 0;

		if (FlxG.save.data.camzoom == null)
			FlxG.save.data.camzoom = true;

		if (FlxG.save.data.scoreScreen == null)
			FlxG.save.data.scoreScreen = true;

		if (FlxG.save.data.inputShow == null)
			FlxG.save.data.inputShow = false;

		if (FlxG.save.data.optimize == null)
			FlxG.save.data.optimize = false;

		// JOELwindows7: Touch screened button
		if (FlxG.save.data.useTouchScreenButtons == null)
			FlxG.save.data.useTouchScreenButtons = false;

		if (FlxG.save.data.selectTouchScreenButtons == null)
			FlxG.save.data.useTouchScreenButtons == 0;

		// JOELwindows7: Vibrations
		if (FlxG.save.data.vibration == null)
			FlxG.save.data.vibration = true;

		// JOELwindows7: PreUnlock weeks like in Stepmania Home mode
		if (FlxG.save.data.preUnlocked == null)
			FlxG.save.data.preUnlocked = false;

		// JOELwindows7: vibration offset
		if (FlxG.save.data.vibrationOffset == null || FlxG.save.data.vibrationOffset < 0.0)
			FlxG.save.data.vibrationOffset = 0.18;

		// JOELwindows7: Timing struct out of any segs warning
		if (FlxG.save.data.outOfSegsWarning == null)
		{
			FlxG.save.data.outOfSegsWarning = false;
		}

		// JOELwindows7: Print Song Chart content
		if (FlxG.save.data.traceSongChart == null)
		{
			FlxG.save.data.traceSongChart = false;
		}

		// JOELwindows7: enable legacy lua modchart supports
		if (FlxG.save.data.legacyLuaScript == null)
		{
			FlxG.save.data.legacyLuaScript = false;
		}

		// JOELwindows7: enigma init mod data
		if (FlxG.save.data.modData == null || FlxG.save.data.modData.get == null)
		{
			// JOELwindows7: take from https://github.com/EnigmaEngine/EnigmaEngine/blob/stable/source/funkin/behavior/SaveData.hx
			var properValue:Map<String, Dynamic> = [];
			FlxG.save.data.modData = properValue;
		}

		FlxG.save.data.cacheImages = false;

		if (FlxG.save.data.middleScroll == null)
			FlxG.save.data.middleScroll = false;

		if (FlxG.save.data.editorBG == null)
			FlxG.save.data.editor = false;

		if (FlxG.save.data.zoom == null)
			FlxG.save.data.zoom = 1;

		if (FlxG.save.data.judgementCounter == null)
			FlxG.save.data.judgementCounter = true;

		if (FlxG.save.data.laneUnderlay == null)
			FlxG.save.data.laneUnderlay = true;

		if (FlxG.save.data.healthBar == null)
			FlxG.save.data.healthBar = true;

		if (FlxG.save.data.laneTransparency == null)
			FlxG.save.data.laneTransparency = 0;

		if (FlxG.save.data.shitMs == null)
			FlxG.save.data.shitMs = 160.0;

		if (FlxG.save.data.badMs == null)
			FlxG.save.data.badMs = 135.0;

		if (FlxG.save.data.goodMs == null)
			FlxG.save.data.goodMs = 90.0;

		if (FlxG.save.data.sickMs == null)
			FlxG.save.data.sickMs = 45.0;

		Ratings.timingWindows = [
			FlxG.save.data.shitMs,
			FlxG.save.data.badMs,
			FlxG.save.data.goodMs,
			FlxG.save.data.sickMs
		];

		if (FlxG.save.data.noteskin == null)
			FlxG.save.data.noteskin = 0;

		// Gonna make this an option on another PR
		if (FlxG.save.data.overrideNoteskins == null)
			FlxG.save.data.overrideNoteskins = false;

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		KeyBinds.gamepad = gamepad != null;

		Conductor.recalculateTimings();
		PlayerSettings.player1.controls.loadKeyBinds();
		KeyBinds.keyCheck();

		Main.watermarks = FlxG.save.data.watermark;
		// JOELwindows7: hey, remember to load the data first!
		Main.odyseeMark = FlxG.save.data.odyseeMark;
		Main.perkedelMark = FlxG.save.data.perkedelMark;
		FlxG.fullscreen = FlxG.save.data.fullscreen;

		Debug.logInfo("set FPS stuff from setting"); // JOELwindows7: trace this for android crashsures
		(cast(Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
		Debug.logInfo("successfully set FPS settings"); // JOELwindows7: see if Android version crash!
	}
}
