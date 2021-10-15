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
class VideoCutscener{
    public static function startThe(source:String, toTrans:FlxState, frameSkipLimit:Int = 90, autopause:Bool = true){
        FlxG.switchState(
            #if mobile
            new VideoSelfContained(source, toTrans, frameSkipLimit, autopause)
            #else
            new VideoState(Paths.video(source), toTrans, frameSkipLimit, autopause)
            #end
        );
    }

    public static function getThe(source:String, toTrans:FlxState, frameSkipLimit:Int = 90, autopause:Bool = true):MusicBeatState{
        return
        #if mobile
        new VideoSelfContained(source, toTrans, frameSkipLimit, autopause)
        #elseif (windows || web)
        new VLCState(Paths.video(source), toTrans, frameSkipLimit, autopause)
        #else
        new VideoState(Paths.video(source), toTrans, frameSkipLimit, autopause)
        #end
        ;
    }
}

/**
 * To contain Android Video Player just like VideoState did without all the clutter
 * from such VideoState. hoof! I'm tired of this to go from where so peck this all.
 * let's just start this from scratch just for this particular video sprite thingy.
 * @author JOELwindows7
 */
class VideoSelfContained extends MusicBeatState{
    var videoSprite:VideoPlayer;
    var toTrans:FlxState;
    public var pauseText:String = "Press P To Pause/Unpause";
    public var autoPause:Bool = false;
	public var musicPaused:Bool = false;
    public var txt:FlxText;
    public var peckingVolume:Float = 1;
    var defaultText:String = "";
    public function new(source:String, toTrans:FlxState, frameSkipLimit:Int = -1, autopause:Bool = true){
        transIn = FlxTransitionableState.defaultTransIn;
        transOut = FlxTransitionableState.defaultTransOut;
        super();
        this.toTrans = toTrans;
        VideoPlayer.SKIP_STEP_LIMIT = frameSkipLimit;
        videoSprite = new VideoPlayer(source);
        videoSprite.finishCallback = donedCallback;
    }

    override function create(){
        super.create();
        // FlxG.autoPause = false;

        //FlxG.sound.music.stop();
        peckingVolume = FlxG.sound.music.volume;
        FlxG.sound.music.volume = 0;
        try {
            if(videoSprite != null){
                new FlxTimer().start(1, function(tmr:FlxTimer){
                    videoSprite.play();
                });
                add(videoSprite);
            } else {
                trace("Werror videoSprite null");
                donedCallback();
            }
        } catch(e){
            trace("Werror faile video!\n\n" + Std.string(e));
            donedCallback();
        }
        
        txt = new FlxText(0, 0, FlxG.width,
			defaultText,
			32);
		txt.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		txt.screenCenter();
		add(txt);
    }

    override function update(elapsed:Float){
        if (FlxG.keys.justPressed.P || FlxG.mouse.justPressed){
            txt.text = pauseText;
			trace("PRESSED PAUSE");
			//GlobalVideo.get().togglePause();
            videoSprite.togglePause();
			if (videoSprite.paused)
			{
				//GlobalVideo.get().alpha();
                videoSprite.dim();
			} else {
				//GlobalVideo.get().unalpha();
                videoSprite.undim();
				txt.text = defaultText;
			}
        }
    }

    function donedCallback(){
        FlxG.sound.music.volume = peckingVolume;
        FlxG.switchState(toTrans);
    }
}

class VLCState extends MusicBeatState{
    var theVLC:MP4Handler;
    var videoSprite:FlxSprite;
    var toTrans:FlxState;
    var source:String;
    public var pauseText:String = "Press P To Pause/Unpause";
    public var autoPause:Bool = false;
	public var musicPaused:Bool = false;
    public var txt:FlxText;
    public var peckingVolume:Float = 1;
    var defaultText:String = "";
    public function new(source:String, toTrans:FlxState, frameSkipLimit:Int = -1, autopause:Bool = true){
        transIn = FlxTransitionableState.defaultTransIn;
        transOut = FlxTransitionableState.defaultTransOut;
        super();
        this.toTrans = toTrans;
        this.source = source;
        // videoSprite = new FlxSprite(0,0);
        // VideoPlayer.SKIP_STEP_LIMIT = frameSkipLimit;
        theVLC = new MP4Handler();
        // videoSprite.finishCallback = donedCallback;
    }

    override function create(){
        super.create();
        // FlxG.autoPause = false;

        FlxG.sound.music.stop();
        peckingVolume = FlxG.sound.music.volume;
        // FlxG.sound.music.volume = 0;
        try {
            if(videoSprite != null){
                new FlxTimer().start(0.1, function(tmr:FlxTimer){
                    theVLC.playMP4(source,toTrans,videoSprite);
                    // videoSprite.play();
                });
                // add(videoSprite);
            } else {
                trace("Werror VLC null, just peck this out");
                new FlxTimer().start(0.1, function(tmr:FlxTimer){
                    theVLC.playMP4(source,toTrans);
                });
                // donedCallback();
            }
            
        } catch(e){
            trace("Werror faile video!\n\n" + Std.string(e));
            donedCallback();
        }
        
        txt = new FlxText(0, 0, FlxG.width,
			defaultText,
			32);
		txt.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		txt.screenCenter();
		add(txt);
    }

    override function update(elapsed:Float){
        if (FlxG.keys.justPressed.P || FlxG.mouse.justPressed){
            txt.text = pauseText;
			trace("PRESSED PAUSE");
			//GlobalVideo.get().togglePause();
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

    function donedCallback(){
        FlxG.autoPause = true;
        FlxG.sound.music.volume = peckingVolume;
        FlxG.switchState(toTrans);
    }

    override function onFocusLost(){
        super.onFocusLost();
        if(theVLC != null){
            // pause the VLC
            //theVLC.pause();
        }
    }
}