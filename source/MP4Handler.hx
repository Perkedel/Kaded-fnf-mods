package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.events.Event;
import flixel.FlxG;
import openfl.media.Video; // Oh this exist?! https://github.com/polybiusproxy/PolyEngine/blob/master/source/VideoHandler.hx

/**
 * Play a video using cpp.
 * Use bitmap to connect to a graphic or use `MP4Sprite`.
 */
class MP4Handler extends vlc.VlcBitmap
{
	public var readyCallback:Void->Void;
	public var finishCallback:Void->Void;

	var pauseMusic:Bool;

	// JOELwindows7: statuses
	public var playing:Bool = false;

	public function new(width:Float = 320, height:Float = 240, autoScale:Bool = true)
	{
		super(width, height, autoScale);

		onVideoReady = onVLCVideoReady;
		onComplete = finishVideo;
		onError = onVLCError;

		FlxG.addChildBelowMouse(this);

		FlxG.stage.addEventListener(Event.ENTER_FRAME, update);

		FlxG.signals.focusGained.add(function()
		{
			resume();
		});
		FlxG.signals.focusLost.add(function()
		{
			pause();
		});
	}

	// JOELwindows7: play
	// public function play()
	// {
	// 	bitmap.play();
	// 	playing = bitmap.isPlaying;
	// }

	// // JOELwindows7: pause
	// public function pause()
	// {
	// 	bitmap.pause();
	// 	playing = bitmap.isPlaying;
	// }

	// // JOELwindows7: resume
	// public function resume()
	// {
	// 	bitmap.resume();
	// 	playing = bitmap.isPlaying;
	// }

	// // JOELwindows7: restart
	// public function restart()
	// {
	// 	// bitmap.restart();
	// 	// bitmap.stop();
	// 	// bitmap.play();
	// 	// maybe you should seek to 0 instead???
	// 	bitmap.pause();
	// 	bitmap.seek(0);
	// 	bitmap.play();
	// 	playing = bitmap.isPlaying;
	// }

	function update(e:Event)
	{
		if ((FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE) && isPlaying)
			finishVideo();

		if (FlxG.sound.muted || FlxG.sound.volume <= 0)
			volume = 0;
		else
			volume = FlxG.sound.volume + 0.4;
	}

	#if sys
	function checkFile(fileName:String):String
	{
		var pDir = "";
		var appDir = "file:///" + Sys.getCwd() + "/";

		if (fileName.indexOf(":") == -1) // Not a path
			pDir = appDir;
		else if (fileName.indexOf("file://") == -1 || fileName.indexOf("http") == -1) // C:, D: etc? ..missing "file:///" ?
			pDir = "file:///";

		return pDir + fileName;
	}
	#end

	function onVLCVideoReady()
	{
		trace("Video loaded!");

		if (readyCallback != null)
			readyCallback();
	}

	function onVLCError()
	{
		// TODO: Catch the error
		throw "VLC caught an error!";
	}

	public function finishVideo()
	{
		if (FlxG.sound.music != null && pauseMusic)
			FlxG.sound.music.resume();

		FlxG.stage.removeEventListener(Event.ENTER_FRAME, update);

		dispose();

		if (FlxG.game.contains(this))
		{
			FlxG.game.removeChild(this);

			if (finishCallback != null)
				finishCallback();
		}
	}

	/**
	 * Native video support for Flixel & OpenFL
	 * @param path Example: `your/video/here.mp4`
	 * @param repeat Repeat the video.
	 * @param pauseMusic Pause music until done video.
	 */
	public function playVideo(path:String, ?repeat:Bool = false, pauseMusic:Bool = false)
	{
		this.pauseMusic = pauseMusic;

		if (FlxG.sound.music != null && pauseMusic)
			FlxG.sound.music.pause();

		#if sys
		play(checkFile(path));

		this.repeat = repeat ? -1 : 0;
		#else
		throw "Doesn't support sys";
		#end
	}
}
