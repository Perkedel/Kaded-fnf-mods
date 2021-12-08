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

import flixel.addons.transition.FlxTransitionableState;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import flixel.system.FlxSound;
import openfl.utils.Assets;
import openfl.utils.AssetType;

/**
 * To select which the best Video cutscener system to choose from.
 * @author JOELwindows7
 */
class VideoCutscener
{
	public static function startThe(source:String, toTrans:FlxState, frameSkipLimit:Int = 90, autopause:Bool = true)
	{
		FlxG.switchState(#if FEATURE_VLC new VLCState(Paths.video(source), toTrans, frameSkipLimit,
			autopause) #elseif (!FEATURE_VLC && FEATURE_WEBM_NATIVE && !android) new VideoState(Paths.video(source), toTrans, frameSkipLimit,
				autopause) #else new VideoSelfContained(source, toTrans, frameSkipLimit, autopause) #end);
	}

	public static function getThe(source:String, toTrans:FlxState, frameSkipLimit:Int = 90, autopause:Bool = true):MusicBeatState
	{
		return #if FEATURE_VLC
			new VLCState(Paths.video(source), toTrans, frameSkipLimit, autopause)
		#elseif (!FEATURE_VLC && (FEATURE_WEBM_NATIVE || FEATURE_WEBM_JS))
			new VideoState(Paths.video(source), toTrans, frameSkipLimit, autopause)
		#else
			new VideoSelfContained(source, toTrans, frameSkipLimit, autopause)
		#end;
	}
}

/**
 * To contain Android Video Player just like VideoState did without all the clutter
 * from such VideoState. hoof! I'm tired of this to go from where so peck this all.
 * let's just start this from scratch just for this particular video sprite thingy.
 * @author JOELwindows7
 */
class VideoSelfContained extends MusicBeatState
{
	var videoSprite:VideoPlayer;
	var toTrans:FlxState;

	public var pauseText:String = "Press P To Pause/Unpause";
	public var autoPause:Bool = false;
	public var musicPaused:Bool = false;
	public var txt:FlxText;
	public var peckingVolume:Float = 1;

	var defaultText:String = "";

	public function new(source:String, toTrans:FlxState, frameSkipLimit:Int = -1, autopause:Bool = true)
	{
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;
		super();
		this.toTrans = toTrans;
		VideoPlayer.SKIP_STEP_LIMIT = frameSkipLimit;
		videoSprite = new VideoPlayer(source);
		videoSprite.finishCallback = donedCallback;
	}

	override function create()
	{
		super.create();
		// FlxG.autoPause = false;

		// FlxG.sound.music.stop();
		peckingVolume = FlxG.sound.music.volume;
		FlxG.sound.music.volume = 0;
		try
		{
			if (videoSprite != null)
			{
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					videoSprite.play();
				});
				add(videoSprite);
			}
			else
			{
				trace("Werror videoSprite null");
				donedCallback();
			}
		}
		catch (e)
		{
			trace("Werror faile video!\n\n" + Std.string(e));
			Debug.logError("Werror faile video!\n\n" + e);
			donedCallback();
		}

		txt = new FlxText(0, 0, FlxG.width, defaultText, 32);
		txt.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		txt.screenCenter();
		add(txt);
	}

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.P || FlxG.mouse.justPressed)
		{
			txt.text = pauseText;
			trace("PRESSED PAUSE");
			// GlobalVideo.get().togglePause();
			videoSprite.togglePause();
			if (videoSprite.paused)
			{
				// GlobalVideo.get().alpha();
				videoSprite.dim();
			}
			else
			{
				// GlobalVideo.get().unalpha();
				videoSprite.undim();
				txt.text = defaultText;
			}
		}
	}

	function donedCallback()
	{
		FlxG.sound.music.volume = peckingVolume;
		FlxG.switchState(toTrans);
	}
}

class VLCState extends MusicBeatState
{
	#if FEATURE_VLC
	var theVLC:MP4Handler;
	#end
	var videoSprite:FlxSprite;
	var toTrans:FlxState;
	var source:String;

	public var pauseText:String = "Press P To Pause/Unpause";
	public var autoPause:Bool = false;
	public var musicPaused:Bool = false;
	public var txt:FlxText;
	public var peckingVolume:Float = 1;

	var defaultText:String = "";

	public function new(source:String, toTrans:FlxState, frameSkipLimit:Int = -1, autopause:Bool = true)
	{
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;
		super();
		this.toTrans = toTrans;
		this.source = source;
		// videoSprite = new FlxSprite(0,0);
		// VideoPlayer.SKIP_STEP_LIMIT = frameSkipLimit;
		#if FEATURE_VLC
		theVLC = new MP4Handler();
		theVLC.finishCallback = donedCallback;
		#end
		// videoSprite.finishCallback = donedCallback;
	}

	override function create()
	{
		super.create();
		// FlxG.autoPause = false;

		FlxG.sound.music.stop();
		peckingVolume = FlxG.sound.music.volume;

		#if FEATURE_VLC
		// FlxG.sound.music.volume = 0;
		try
		{
			if (videoSprite != null)
			{
				new FlxTimer().start(0.1, function(tmr:FlxTimer)
				{
					theVLC.playMP4(source, false, videoSprite);
					// videoSprite.play();
				});
				// add(videoSprite);
			}
			else
			{
				trace("Werror VLC null, just peck this out");
				new FlxTimer().start(0.1, function(tmr:FlxTimer)
				{
					theVLC.playMP4(source);
				});
				// donedCallback();
			}
		}
		catch (e)
		{
			Debug.logError("Werror faile video!\n\n" + Std.string(e));
			// Debug.logError("Werror faile video!\n\n" + e);
			donedCallback();
		}
		#else
		donedCallback();
		#end

		txt = new FlxText(0, 0, FlxG.width, defaultText, 32);
		txt.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		txt.screenCenter();
		add(txt);
	}

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.P || FlxG.mouse.justPressed)
		{
			txt.text = pauseText;
			trace("PRESSED PAUSE");
			// GlobalVideo.get().togglePause();
			// videoSprite.togglePause();
			// if (videoSprite.paused)
			// {
			// 	//GlobalVideo.get().alpha();
			//     videoSprite.dim();
			// } else {
			// 	//GlobalVideo.get().unalpha();
			//     videoSprite.undim();
			// 	txt.text = defaultText;
			// }
		}
	}

	function donedCallback()
	{
		// FlxG.autoPause = true; //No longer necessary because the gameplay pauses on lost focus
		FlxG.sound.music.volume = peckingVolume;
		FlxG.switchState(toTrans);
		// LoadingState.loadAndSwitchState(toTrans);
	}

	override function onFocusLost()
	{
		super.onFocusLost();
		#if FEATURE_VLC
		if (theVLC != null)
		{
			// pause the VLC
			// theVLC.pause();
		}
		#end
	}
}
