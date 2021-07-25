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

		//JOELwindows7: don't forget init save data of fullscreen mode
		if (FlxG.save.data.fullscreen == null)
			FlxG.save.data.fullscreen == FlxG.fullscreen;

		if (FlxG.save.data.fpsRain == null)
			FlxG.save.data.fpsRain = false;

		if (FlxG.save.data.fpsCap == null)
			FlxG.save.data.fpsCap = 120;

		if (FlxG.save.data.fpsCap > 285 || FlxG.save.data.fpsCap < 60)
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

		//JOELwindows7: odysee watermark
		if (FlxG.save.data.odyseeMark == null)
			FlxG.save.data.odyseeMark = true;

		//JOELwindows7: Perkedel watermark
		if (FlxG.save.data.perkedelMark == null)
			FlxG.save.data.perkedelMark = true;

		//JOELwindows7: naughtiness option
		if (FlxG.save.data.naughtiness == null)
			FlxG.save.data.naughtiness = true;

		if (FlxG.save.data.cardiophile == null)
			FlxG.save.data.cardiophile = true;

		if (FlxG.save.data.ghost == null)
			FlxG.save.data.ghost = true;

		if (FlxG.save.data.distractions == null)
			FlxG.save.data.distractions = true;
		
		if (FlxG.save.data.stepMania == null)
			FlxG.save.data.stepMania = false;

		if (FlxG.save.data.flashing == null)
			FlxG.save.data.flashing = true;

		if (FlxG.save.data.resetButton == null)
			FlxG.save.data.resetButton = false;
		
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

		//JOELwindows7: Touch screened button
		if (FlxG.save.data.useTouchScreenButtons == null)
			FlxG.save.data.useTouchScreenButtons = false;

		if (FlxG.save.data.selectTouchScreenButtons == null)
			FlxG.save.data.useTouchScreenButtons == 0;

		//JOELwindows7: Vibrations
		if (FlxG.save.data.vibration == null)
			FlxG.save.data.vibration = true;

		//JOELwindows7: PreUnlock weeks like in Stepmania Home mode
		if (FlxG.save.data.preUnlocked == null)
			FlxG.save.data.preUnlocked = false;
		
		if (FlxG.save.data.cacheImages == null)
			FlxG.save.data.cacheImages = false;

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
		
		KeyBinds.gamepad = gamepad != null;

		Conductor.recalculateTimings();
		PlayerSettings.player1.controls.loadKeyBinds();
		KeyBinds.keyCheck();

		Main.watermarks = FlxG.save.data.watermark;
		//JOELwindows7: hey, remember to load the data first!
		Main.odyseeMark = FlxG.save.data.odyseeMark;
		Main.perkedelMark = FlxG.save.data.perkedelMark;
		FlxG.fullscreen = FlxG.save.data.fullscreen;

		trace("set FPS stuff from setting"); //JOELwindows7: trace this for android crashsures
		(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
		#if (desktop && sys && !mobile && !web)
		//(cast (Lib.current.getChildAt(0), Main)).toggleFPS(FlxG.save.data.fps);
		#end //JOELwindows7: nvm, don't do that!
		trace("successfully set FPS settings"); //JOELwindows7: see if Android version crash!
	}
}