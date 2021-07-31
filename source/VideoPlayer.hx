// JOELwindows7: stolen from luckydog7
// https://github.com/luckydog7/Funkin-android/blob/master/source/VideoPlayer.hx

package;

import openfl.utils.Assets;
//import utils.AndroidData;
import flixel.FlxG;
import flixel.FlxCamera;
import Paths;
#if cpp
import webm.*;
import flixel.system.FlxSound;
import utils.Asset2File;
#elseif html5
import openfl.net.NetStream;
import openfl.media.Video;
#end
import flixel.FlxSprite;

/**
	usage:
	var video = new VideoPlayer('videos/ughintro.webm');
	video.play();
	add(video);

	- Bitstream not supported by this decoder
	maybe use vp8 (idk)
**/

class VideoPlayer extends FlxSprite
{
	public static var SKIP_STEP_LIMIT:Int = 90;
	public var paused:Bool;
	#if sys
	public var webm:WebmPlayer;
	var sound:FlxSound;


	#elseif html5
	var netStream:NetStream;
	public var player:Video;
	#end

	var pathVideo:String;


	/* 
	execute function after stop, finish video
	usage:
	video.finishCallback = () -> {
		remove(video);
		startCountdown();
	}
	*/
	public var finishCallback:Void->Void=null;

	public function new(asset:String, ?x:Float, ?y:Float) 
	{
		super(x, y);
		paused = false;

		#if cpp
		//WebmPlayer.SKIP_STEP_LIMIT = SKIP_STEP_LIMIT;

		webm = new WebmPlayer();
		webm.SKIP_STEP_LIMIT = SKIP_STEP_LIMIT;
		
		changeVideo(asset);

		webm.addEventListener('play', cast play);
		webm.addEventListener('stop', cast stop);
		webm.addEventListener('end', cast end);


		loadGraphic(webm.bitmapData); 
		#elseif html5
		trace('video is unsupported');
		#end
	
	}

	public function play() {
		//var PLAYDUMBASS = new AndroidData().getCutscenes();
		var PLAYDUMBASS = true;
		#if sys
		if (PLAYDUMBASS)
		{
			webm.play();

			if (Assets.exists(Paths.videoSound(pathVideo)))
				// sound = FlxG.sound.play(Paths.file(pathVideo + '.ogg'))
				sound = FlxG.sound.play(Paths.videoSound(pathVideo))
			else
				trace('sound dont exists');
		}else
		{
			if (finishCallback != null)
				finishCallback();
		}
		#elseif html5
		//player = new Video();
		if (finishCallback != null)
			finishCallback();
		
		#end
	}

	//JOELwindows7: steal from VideoState.hx
	public function togglePause():Void
	{
		if (paused)
		{
			resume();
		} else {
			pause();
		}
	}
	public function pause():Void
	{
		#if sys
		webm.changePlaying(false);
		#end
		paused = true;
	}
	public function resume():Void
	{
		#if sys
		webm.changePlaying(true);
		#end
		paused = false;
	}
	public function dim():Void
	{
		#if sys
		webm.alpha = GlobalVideo.daAlpha1;
		#end
	}
	public function undim():Void
	{
		#if sys
		webm.alpha = GlobalVideo.daAlpha2;
		#end
	}

	//callbacks
	function start() {
		trace('starting video!');
	}
	function stop() {
		if (finishCallback != null)
			finishCallback();
	}
	function end() {
		if (finishCallback != null)
			finishCallback();
	}
	

	function changeVideo(asset:String) {
		pathVideo = asset;
		#if cpp
		// var path = Asset2File.getPath(Paths.file(pathVideo), ".webm"); // maybe use without paths
		var path = Asset2File.getPath(Paths.video(pathVideo)); // maybe use without paths

		var io:WebmIo = new WebmIoFile(path);
		webm.fuck(io);

		#end
	}

	public function ownCamera() {
		var cam = new FlxCamera();
		FlxG.cameras.add(cam);
		cam.bgColor.alpha = 0;
		cameras = [cam];
	}

	override public function destroy() {
		#if sys
		webm.stop();
		super.destroy();
		#elseif html5

		#end
	}
}