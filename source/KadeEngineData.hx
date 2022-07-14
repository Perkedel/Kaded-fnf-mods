import const.Perkedel;
import flixel.input.gamepad.FlxGamepad;
import openfl.Lib;
import flixel.FlxG;

class KadeEngineData
{
	public static function initSave()
	{
		trace("init save data now");
		// JOELwindows7: the OOBE init!!
		if (FlxG.save.data.oobeSetuped == null)
			FlxG.save.data.oobeSetuped = false;

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

		if (FlxG.save.data.fpsBorder == null)
			FlxG.save.data.fpsBorder = false;

		if (FlxG.save.data.rotateSprites == null)
			FlxG.save.data.rotateSprites = true;

		if (FlxG.save.data.changedHit == null)
		{
			FlxG.save.data.changedHitX = -1;
			FlxG.save.data.changedHitY = -1;
			FlxG.save.data.changedHit = false;
		}

		// JOELwindows7: accident vol keys
		if (FlxG.save.data.accidentVolumeKeys == null)
			FlxG.save.data.accidentVolumeKeys = false;

		// JOELwindows7: don't forget init save data of fullscreen mode
		if (FlxG.save.data.fullscreen == null)
			FlxG.save.data.fullscreen == FlxG.fullscreen;

		if (FlxG.save.data.fpsRain == null)
			FlxG.save.data.fpsRain = false;

		if (FlxG.save.data.memoryDisplay == null)
			FlxG.save.data.memoryDisplay = true; // JOELwindows7: bro wtf? false by default?! BOLO

		// JOELwindows7: BOLO lerp score
		if (FlxG.save.data.lerpScore == null)
			FlxG.save.data.lerpScore = true;

		if (FlxG.save.data.fpsCap == null)
			FlxG.save.data.fpsCap = 120;

		// JOELwindows7: was 340
		if (FlxG.save.data.fpsCap > Perkedel.MAX_FPS_CAP || FlxG.save.data.fpsCap < 60)
			FlxG.save.data.fpsCap = 120; // baby proof so you can't hard lock ur copy of kade engine

		if (FlxG.save.data.scrollSpeed == null)
			FlxG.save.data.scrollSpeed = 1;

		if (FlxG.save.data.npsDisplay == null)
			FlxG.save.data.npsDisplay = true; // JOELwindows7: BRO, set it tru instead!. BOLO did.

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

		// JOELwindows7: heartbeat fetish option
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
			FlxG.save.data.selectTouchScreenButtons == 0;

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

		// JOELwindows7: Print annoying debug messages, the warning messages
		if (FlxG.save.data.annoyingWarns == null)
		{
			FlxG.save.data.annoyingWarns = false;
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

		// JOELwindows7: dialogue autoclick
		if (FlxG.save.data.autoClick == null)
		{
			FlxG.save.data.autoClick = false;
		}
		if (FlxG.save.data.autoClickDelay == null)
		{
			FlxG.save.data.autoClickDelay = 2;
		}

		// JOELwindows7: freeplay threaded loading
		if (FlxG.save.data.freeplayThreadedLoading == null)
		{
			FlxG.save.data.freeplayThreadedLoading = false;
		}

		// JOELwindows7: end song early
		if (FlxG.save.data.endSongEarly == null)
		{
			FlxG.save.data.endSongEarly = false;
		}

		// JOELwindows7: score text zoom Psychedly
		if (FlxG.save.data.scoreTxtZoom == null)
		{
			FlxG.save.data.scoreTxtZoom = true;
		}

		// JOELwindows7: note splash Psychedly
		if (FlxG.save.data.noteSplashes == null)
		{
			FlxG.save.data.noteSplashes = true;
		}

		// JOELwindows7: and note splash CPU Psychedly
		if (FlxG.save.data.cpuSplash)
		{
			FlxG.save.data.cpuSplash = true;
		}

		// JOELwindows7: Force quantization even modchart loaded (note, stage modchart won't cancel quantization even this OFF)
		if (FlxG.save.data.forceStepmania == null)
		{
			FlxG.save.data.forceStepmania = false;
		}

		// JOELwindows7: unpause preparation countdown
		if (FlxG.save.data.unpausePreparation == null)
		{
			FlxG.save.data.unpausePreparation = 1;
		}

		// JOELwindows7: hitsound in gameplay bool
		if (FlxG.save.data.hitsound == null)
		{
			FlxG.save.data.hitsound = false; // originally in this game FNF, it's OFF. while osu! is ON
		}

		// JOELwindows7: BOLO's hitsound select!
		if (FlxG.save.data.hitSoundSelect == null)
			FlxG.save.data.hitSoundSelect = 0;

		// JOELwindows7: BOLO's hitsound volume
		if (FlxG.save.data.hitVolume == null)
			FlxG.save.data.hitVolume = 0.5;

		// JOELwindows7: left stuffs
		if (FlxG.save.data.leftAWeek == null)
		{
			FlxG.save.data.leftAWeek = false;
		}

		if (FlxG.save.data.leftStoryWeek == null)
		{
			FlxG.save.data.leftStoryWeek = 0;
		}

		if (FlxG.save.data.leftWeekSongAt == null)
		{
			FlxG.save.data.leftWeekSongAt = '';
		}

		if (FlxG.save.data.leftFullPlaylistCurrently == null)
		{
			FlxG.save.data.leftFullPlaylistCurrently = [];
		}

		if (FlxG.save.data.leftCampaignScore == null)
		{
			FlxG.save.data.leftCampaignScore = 0;
		}

		if (FlxG.save.data.leftCampaignMisses == null)
		{
			FlxG.save.data.leftCampaignMisses = 0;
		}

		if (FlxG.save.data.leftCampaignSicks == null)
		{
			FlxG.save.data.leftCampaignSicks = 0;
		}

		if (FlxG.save.data.leftCampaignGoods == null)
		{
			FlxG.save.data.leftCampaignGoods = 0;
		}

		if (FlxG.save.data.leftCampaignBads == null)
		{
			FlxG.save.data.leftCampaignBads = 0;
		}

		// Oh God, so many!!! pls help me what efficient way to do this?!?!?!?
		if (FlxG.save.data.leftCapaignShits == null)
		{
			FlxG.save.data.leftCapaignShits = 0;
		}

		if (FlxG.save.data.leftBlueBall == null)
		{
			FlxG.save.data.leftBlueBall = 0; // blueball counter / fail counter
		}

		// JOELwindows7: blueballWeek
		if (FlxG.save.data.blueballWeek == null)
		{
			FlxG.save.data.blueballWeek = false;
		}
		if (FlxG.save.data.roundAccuracy == null)
			FlxG.save.data.roundAccuracy = false;

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

		// JOELwindows7: BOLO background stage enablement
		if (FlxG.save.data.background == null)
			FlxG.save.data.background = true;

		if (FlxG.save.data.noteskin == null)
			FlxG.save.data.noteskin = 0;

		// Gonna make this an option on another PR
		if (FlxG.save.data.overrideNoteskins == null)
			FlxG.save.data.overrideNoteskins = false;

		// JOELwindows7: Toby-Fox tale character name. not to be confused with your own / player name
		if (FlxG.save.data.radiationName == null)
			FlxG.save.data.radiationName = "Ioniq";
		// Toby "Radiation" Fox. since we went on "Sorento" with Deltarune && Sorento happens to be Kia Sorento,
		// Then eh whatever why not call this character for Rhythm Tale / Rune "Ioniq" idk.. because
		// We made our own Sky, drives Hyundai IONIQ 5 lmao!

		// JOELwindows7: BOLO's modifier init!!!
		if (FlxG.save.data.hgain == null)
			FlxG.save.data.hgain = 1;

		if (FlxG.save.data.hloss == null)
			FlxG.save.data.hloss = 1;

		if (FlxG.save.data.hdrain == null)
			FlxG.save.data.hdrain = false;

		if (FlxG.save.data.sustains == null)
			FlxG.save.data.sustains = true;

		if (FlxG.save.data.noMisses == null)
			FlxG.save.data.noMisses = false;

		if (FlxG.save.data.modcharts == null)
			FlxG.save.data.modcharts = true;

		if (FlxG.save.data.practice == null)
			FlxG.save.data.practice = false;

		if (FlxG.save.data.opponent == null)
			FlxG.save.data.opponent = false;

		if (FlxG.save.data.mirror == null)
			FlxG.save.data.mirror = false;
		// end BOLO's modifier init!!!

		// JOELwindows7: workarounds!

		// video cutscene crash on Linux
		if (FlxG.save.data.disableVideoCutscener == null)
			FlxG.save.data.disableVideoCutscener = false;

		// end workarounds

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

		#if FEATURE_DISPLAY_FPS_CHANGE
		Debug.logInfo("set FPS stuff from setting"); // JOELwindows7: trace this for android crashsures
		(cast(Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
		Debug.logInfo("successfully set FPS settings"); // JOELwindows7: see if Android version crash!
		#end
	}

	// JOELwindows7: BOLO's reset modifier
	// https://github.com/BoloVEVO/Kade-Engine-Public/blob/stable/source/KadeEngineData.hx
	public static function resetModifiers():Void
	{
		FlxG.save.data.hgain = 1;
		FlxG.save.data.hloss = 1;
		FlxG.save.data.hdrain = false;
		FlxG.save.data.sustains = true;
		FlxG.save.data.noMisses = false;
		FlxG.save.data.modcharts = true;
		FlxG.save.data.practice = false;
		FlxG.save.data.opponent = false;
		FlxG.save.data.mirror = false;
	}
}
