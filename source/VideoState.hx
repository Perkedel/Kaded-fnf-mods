package;

import flixel.addons.ui.FlxUIText;
import flixel.addons.ui.FlxUISprite;
#if cpp
import webm.WebmPlayer;
#end
import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import flixel.system.FlxSound;
import openfl.utils.Assets;
import openfl.utils.AssetType;
import openfl.Lib;

using StringTools;

// JOELwindows7: carefully FlxUI fy!

class VideoState extends MusicBeatState
{
	public var leSource:String = "";
	public var transClass:FlxState;
	public var txt:FlxUIText;
	public var fuckingVolume:Float = 1;
	public var notDone:Bool = true;
	public var vidSound:FlxSound;
	public var useSound:Bool = false;
	public var soundMultiplier:Float = 1;
	public var prevSoundMultiplier:Float = 1;
	public var videoFrames:Int = 0;
	public var defaultText:String = "";
	public var doShit:Bool = false;
	public var pauseText:String = "Press P To Pause/Unpause";
	public var autoPause:Bool = false;
	public var musicPaused:Bool = false;

	#if FEATURE_FRAME_COUNTER
	static private var nativeFramecount:String->Int = cpp.Lib.load("webmHelper", "GetFramecount", 1);
	#end

	public function new(source:String, toTrans:FlxState, frameSkipLimit:Int = -1, autopause:Bool = false)
	{
		super();

		autoPause = autopause;

		leSource = source;
		transClass = toTrans;
		if (frameSkipLimit != -1 && GlobalVideo.isWebm)
		{
			#if (desktop) // JOELwindows7: no more mobile. hey wha happened?
			#if (!linux && !mac)
			GlobalVideo.getWebm().webm.SKIP_STEP_LIMIT = frameSkipLimit;
			// WebmPlayer.SKIP_STEP_LIMIT = frameSkipLimit; //JOElwindows7 somekind for the kade's
			#end
			#end

			// no field skip step limit
		}
	}

	// JOELwindows7: from kem0x's webm helper
	// https://github.com/kem0x/openfl-haxeflixel-video-code/blob/main/source/VideoState.hx
	public function frameCount():Int
	{
		#if FEATURE_FRAME_COUNTER
		return nativeFramecount(leSource);
		#else
		return Std.parseInt(Assets.getText(leSource.replace(".webm", ".txt")));
		#end
	}

	// JOELwindows7: and now the utility for it
	public static function frameCountUtil(daSource:String = ''):Int
	{
		#if FEATURE_FRAME_COUNTER
		return nativeFramecount(daSource);
		#else
		return Std.parseInt(Assets.getText(daSource.replace(".webm", ".txt")));
		#end
	}

	override function create()
	{
		super.create();

		// JOELwindows7: cancel breakpoint
		if (FlxG.save.data.disableVideoCutscener)
		{
			FlxG.switchState(transClass);
			return;
		}

		FlxG.autoPause = false;
		doShit = false;

		if (GlobalVideo.isWebm)
		{
			// videoFrames = Std.parseInt(Assets.getText(leSource.replace(".webm", ".txt")));
			#if FEATURE_FRAME_COUNTER
			videoFrames = frameCount();

			trace("swag dll told us vid has " + videoFrames);

			if (videoFrames == 0)
			{
			#end
				videoFrames = Std.parseInt(Assets.getText(leSource.replace(".webm", ".txt")));

			#if FEATURE_FRAME_COUNTER
			}
			#end
		}

		fuckingVolume = FlxG.sound.music.volume;
		FlxG.sound.music.volume = 0;
		var isHTML:Bool = false;
		#if web
		isHTML = true;
		#end
		var bg:FlxUISprite = cast new FlxUISprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);
		var html5Text:String = "You Are Not Using HTML5...\nThe Video Didnt Load!";
		if (isHTML)
		{
			html5Text = "You Are Using HTML5!";
		}
		defaultText = "If Your On HTML5\nTap Anything...\nThe Bottom Text Indicates If You\nAre Using HTML5...\n\n" + html5Text;
		txt = new FlxUIText(0, 0, FlxG.width, defaultText, 32);
		txt.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		txt.screenCenter();
		add(txt);

		trace("check vidSound exist");
		if (GlobalVideo.isWebm)
		{
			// JOELwindows7: i pecking don't understand why it doesn't work at all
			// in Android
			if ( // #if !mobile
				Assets.exists(leSource.replace(".webm", ".ogg"), MUSIC) || Assets.exists(leSource.replace(".webm", ".ogg"), SOUND) // #else
					// true
					// #end
			)
			{
				useSound = true;
				vidSound = FlxG.sound.play(leSource.replace(".webm", ".ogg"));
			}
		}
		trace("checked vidSound exists.");

		trace("le put the video in dees");
		GlobalVideo.get().source(leSource);
		trace('clear pauseoid');
		GlobalVideo.get().clearPause();
		if (GlobalVideo.isWebm)
		{
			trace("update da player");
			GlobalVideo.get().updatePlayer();
		}
		GlobalVideo.get().show();
		if (GlobalVideo.isWebm)
		{
			trace("restart vid");
			GlobalVideo.get().restart();
		}
		else
		{
			trace("oh just play vid okey");
			GlobalVideo.get().play();
		}
		trace("setup done for the le vid");

		/*if (useSound)
			{ */
		// vidSound = FlxG.sound.play(leSource.replace(".webm", ".ogg"));

		/*new FlxTimer().start(0.1, function(tmr:FlxTimer)
			{ */
		// JOELwindows7: only do this if not null
		trace("fix vidSound time by timing its length with soundMultiplier " + Std.string(soundMultiplier));
		if (vidSound != null)
			vidSound.time = vidSound.length * soundMultiplier;
		/*new FlxTimer().start(1.2, function(tmr:FlxTimer)
			{
				if (useSound)
				{
					vidSound.time = vidSound.length * soundMultiplier;
				}
		}, 0);*/
		doShit = true;
		trace("enable doing some poops of VIdeo here man");
		// }, 1);
		// }

		if (autoPause && FlxG.sound.music != null && FlxG.sound.music.playing)
		{
			musicPaused = true;
			FlxG.sound.music.pause();
		}
		trace("finish create VideoState cool and good");
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (useSound)
		{
			var wasFuckingHit = GlobalVideo.get().webm.wasHitOnce;
			soundMultiplier = GlobalVideo.get().webm.renderedCount / videoFrames;

			if (soundMultiplier > 1)
			{
				soundMultiplier = 1;
			}
			if (soundMultiplier < 0)
			{
				soundMultiplier = 0;
			}
			if (doShit)
			{
				var compareShit:Float = 50;
				if (vidSound.time >= (vidSound.length * soundMultiplier) + compareShit
					|| vidSound.time <= (vidSound.length * soundMultiplier) - compareShit)
					vidSound.time = vidSound.length * soundMultiplier;
			}
			if (wasFuckingHit)
			{
				if (soundMultiplier == 0)
				{
					if (prevSoundMultiplier != 0)
					{
						vidSound.pause();
						vidSound.time = 0;
					}
				}
				else
				{
					if (prevSoundMultiplier == 0)
					{
						vidSound.resume();
						vidSound.time = vidSound.length * soundMultiplier;
					}
				}
				prevSoundMultiplier = soundMultiplier;
			}
		}

		if (notDone)
		{
			FlxG.sound.music.volume = 0;
		}
		GlobalVideo.get().update(elapsed);

		if (controls.RESET)
		{
			GlobalVideo.get().restart();
		}

		if (FlxG.keys.justPressed.P || FlxG.mouse.justPressed) // JOELwindows7: click to pause/unpause
		{
			txt.text = pauseText;
			trace("PRESSED PAUSE");
			GlobalVideo.get().togglePause();
			if (GlobalVideo.get().paused)
			{
				GlobalVideo.get().alpha();
			}
			else
			{
				GlobalVideo.get().unalpha();
				txt.text = defaultText;
			}
		}

		if (controls.ACCEPT || GlobalVideo.get().ended || GlobalVideo.get().stopped)
		{
			txt.visible = false;
			GlobalVideo.get().hide();
			GlobalVideo.get().stop();
		}

		if (controls.ACCEPT || GlobalVideo.get().ended)
		{
			notDone = false;
			FlxG.sound.music.volume = fuckingVolume;
			txt.text = pauseText;
			if (musicPaused)
			{
				musicPaused = false;
				FlxG.sound.music.resume();
			}
			FlxG.autoPause = true;
			FlxG.switchState(transClass);
		}

		if (GlobalVideo.get().played || GlobalVideo.get().restarted)
		{
			GlobalVideo.get().show();
		}

		GlobalVideo.get().restarted = false;
		GlobalVideo.get().played = false;
		GlobalVideo.get().stopped = false;
		GlobalVideo.get().ended = false;
	}
}
