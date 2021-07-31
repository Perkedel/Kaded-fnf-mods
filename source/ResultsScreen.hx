package;
import haxe.Exception;
#if sys
import smTools.SMFile;
import sys.FileSystem;
import sys.io.File;
#end
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import flixel.system.FlxSound;
import flixel.util.FlxAxes;
import flixel.FlxSubState;
import Options.Option;
import flixel.input.FlxInput;
import flixel.input.keyboard.FlxKey;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
#if newgrounds
import io.newgrounds.NG;
#end
import lime.app.Application;
import lime.utils.Assets;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.input.FlxKeyManager;


using StringTools;

class ResultsScreen extends FlxSubState
{
    public var background:FlxSprite;
    public var text:FlxText;

    public var anotherBackground:FlxSprite;
    public var graph:HitGraph;
    public var graphSprite:OFLSprite;

    public var comboText:FlxText;
    public var contText:FlxText;
    public var settingsText:FlxText;

    public var music:FlxSound;

    public var graphData:BitmapData;

    public var ranking:String;
    public var accuracy:String;

    public static var handoverHasVideo:Bool = false;
    public static var handoverVideoPath:String;

    //JOELwindows7: mouse support flags
	private var haveClicked:Bool = false;
	private var haveBacked:Bool = false;
	private var haveLefted:Bool = false;
	private var haveUpped:Bool = false;
	private var haveDowned:Bool = false;
	private var haveRighted:Bool = false;
	private var havePausened:Bool = false;
	private var haveRetryed:Bool = false;
	private var haveViewReplayed:Bool = false;
	private var haveDebugSevened:Bool = false;

	var backButton:FlxSprite; //JOELwindows7: the back button here
	var leftButton:FlxSprite; //JOELwindows7: the left button here
	var rightButton:FlxSprite; //JOELwindows7: the right button here
	var upButton:FlxSprite; //JOELwindows7: the up button here
	var downButton:FlxSprite; //JOELwindows7: the down button here
	var pauseButton:FlxSprite; //JOELwindows7: the pause button here
	var acceptButton:FlxSprite; //JOELwindows7: the accept button here
	var retryButton:FlxSprite; //JOELwindows7: the retry button here
	var viewReplayButton:FlxSprite; //JOELwindows7: the view replay button here

    public function new(tellHasVideo:Bool = false, tellVideoPath:String = "assets/videos/null.webm"){
        super();
        //JOELwindows7: there may be epilogue cutscene
        handoverHasVideo = tellHasVideo;
        handoverVideoPath = tellVideoPath;
    }

	override function create()
	{	
        background = new FlxSprite(0,0).makeGraphic(FlxG.width,FlxG.height,FlxColor.BLACK);
        background.scrollFactor.set();
        add(background);

        if (!PlayState.inResults) 
        {
            music = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
            music.volume = 0;
            music.play(false, FlxG.random.int(0, Std.int(music.length / 2)));
            FlxG.sound.list.add(music);
        }

        background.alpha = 0;

        text = new FlxText(20,-55,0,"Song Cleared!");
        text.size = 34;
        text.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
        text.color = FlxColor.WHITE;
        text.scrollFactor.set();
        add(text);

        var score = PlayState.instance.songScore;
        if (PlayState.isStoryMode)
        {
            score = PlayState.campaignScore;
            text.text = "Week Cleared!";
        }

        comboText = new FlxText(20,-75,0,'Judgements:\nSicks - ${PlayState.sicks}\nGoods - ${PlayState.goods}\nBads - ${PlayState.bads}\n\nCombo Breaks: ${(PlayState.isStoryMode ? PlayState.campaignMisses : PlayState.misses)}\nHighest Combo: ${PlayState.highestCombo + 1}\nScore: ${PlayState.instance.songScore}\nAccuracy: ${HelperFunctions.truncateFloat(PlayState.instance.accuracy,2)}%\n\n${Ratings.GenerateLetterRank(PlayState.instance.accuracy)}\n\n${!PlayState.loadRep ? "F1 - View replay\nF2 - Replay song" : ""}
        ');
        comboText.size = 28;
        comboText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
        comboText.color = FlxColor.WHITE;
        comboText.scrollFactor.set();
        add(comboText);

        contText = new FlxText(FlxG.width - 475,FlxG.height + 50,0,'Press ${KeyBinds.gamepad ? 'A' : 'ENTER'} to continue.');
        contText.size = 28;
        contText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
        contText.color = FlxColor.WHITE;
        contText.scrollFactor.set();
        add(contText);

        anotherBackground = new FlxSprite(FlxG.width - 500,45).makeGraphic(450,240,FlxColor.BLACK);
        anotherBackground.scrollFactor.set();
        anotherBackground.alpha = 0;
        add(anotherBackground);
        
        graph = new HitGraph(FlxG.width - 500,45,495,240);
        graph.alpha = 0;

        graphSprite = new OFLSprite(FlxG.width - 510,45,460,240,graph);

        graphSprite.scrollFactor.set();
        graphSprite.alpha = 0;
        
        add(graphSprite);


        var sicks = HelperFunctions.truncateFloat(PlayState.sicks / PlayState.goods,1);
        var goods = HelperFunctions.truncateFloat(PlayState.goods / PlayState.bads,1);

        if (sicks == Math.POSITIVE_INFINITY)
            sicks = 0;
        if (goods == Math.POSITIVE_INFINITY)
            goods = 0;

        var mean:Float = 0;


        for (i in 0...PlayState.rep.replay.songNotes.length)
        {
            // 0 = time
            // 1 = length
            // 2 = type
            // 3 = diff
            var obj = PlayState.rep.replay.songNotes[i];
            // judgement
            var obj2 = PlayState.rep.replay.songJudgements[i];

            var obj3 = obj[0];

            var diff = obj[3];
            var judge = obj2;
            if (diff != (166 * Math.floor((PlayState.rep.replay.sf / 60) * 1000) / 166))
                mean += diff;
            if (obj[1] != -1)
                graph.addToHistory(diff, judge, obj3);
        }

        graph.update();

        mean = HelperFunctions.truncateFloat(mean / PlayState.rep.replay.songNotes.length,2);

        settingsText = new FlxText(20,FlxG.height + 50,0,'SF: ${PlayState.rep.replay.sf} | Ratio (SA/GA): ${Math.round(sicks)}:1 ${Math.round(goods)}:1 | Mean: ${mean}ms | Played on ${PlayState.SONG.song} ${CoolUtil.difficultyFromInt(PlayState.storyDifficulty).toUpperCase()}');
        settingsText.size = 16;
        settingsText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,2,1);
        settingsText.color = FlxColor.WHITE;
        settingsText.scrollFactor.set();
        add(settingsText);


        FlxTween.tween(background, {alpha: 0.5},0.5);
        FlxTween.tween(text, {y:20},0.5,{ease: FlxEase.expoInOut});
        FlxTween.tween(comboText, {y:145},0.5,{ease: FlxEase.expoInOut});
        FlxTween.tween(contText, {y:FlxG.height - 45},0.5,{ease: FlxEase.expoInOut});
        FlxTween.tween(settingsText, {y:FlxG.height - 35},0.5,{ease: FlxEase.expoInOut});
        FlxTween.tween(anotherBackground, {alpha: 0.6},0.5, {onUpdate: function(tween:FlxTween) {
            graph.alpha = FlxMath.lerp(0,1,tween.percent);
            graphSprite.alpha = FlxMath.lerp(0,1,tween.percent);
        }});

        cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

        //JOELwindows7: button sings
        addAcceptButton(FlxG.width-100, FlxG.height-125);
        addViewReplayButton(Std.int((FlxG.width/2)-300), FlxG.height-250);
        addRetryButton(Std.int((FlxG.width/2)-300), FlxG.height-125);

		super.create();

        //JOELwindows7: visiblize mouse
        FlxG.mouse.visible = true;
	}


    var frames = 0;

	override function update(elapsed:Float)
	{
        if (music != null && music.volume < 0.5)
		    music.volume += 0.01 * elapsed;

        // keybinds

        if (PlayerSettings.player1.controls.ACCEPT || haveClicked) //JOELwindows7: install mouse support
        {
            music.fadeOut(0.3);
            
            PlayState.loadRep = false;
            PlayState.rep = null;

			var songHighscore = StringTools.replace(PlayState.SONG.song, " ", "-");
			switch (songHighscore) {
				case 'Dad-Battle': songHighscore = 'Dadbattle';
				case 'Philly-Nice': songHighscore = 'Philly';
			}

			#if !switch
			Highscore.saveScore(songHighscore, Math.round(PlayState.instance.songScore), PlayState.storyDifficulty);
			Highscore.saveCombo(songHighscore, Ratings.GenerateLetterRank(PlayState.instance.accuracy),PlayState.storyDifficulty);
			#end

            if (PlayState.isStoryMode)
            {
                FlxG.sound.playMusic(Paths.music('freakyMenu'));
                Conductor.changeBPM(102);
                // #if !mobile //JOELwindows7: not working in Android
                // FlxG.switchState(handoverHasVideo? new VideoState(handoverVideoPath, new StoryMenuState()) : new StoryMenuState()); //JOELwindows7: here epilogue cutscenes
                // #else
                // FlxG.switchState(new StoryMenuState()); //JOELwindows7: no cutscene. unsupported platform.
                // #end
                //JOELwindows7: works with Android
                FlxG.switchState(handoverHasVideo? VideoCutscener.getThe(handoverVideoPath, new StoryMenuState()) : new StoryMenuState()); 
                //JOELwindows7: here epilogue cutscenes
            }
            else
                FlxG.switchState(new FreeplayState());

            haveClicked = false;
        }

        if ((FlxG.keys.justPressed.F1 || haveViewReplayed) && !PlayState.loadRep)
        {
            trace(PlayState.rep.path);
            PlayState.rep = Replay.LoadReplay(PlayState.rep.path);

            PlayState.loadRep = true;
            PlayState.isSM = PlayState.rep.replay.sm;

            var songFormat = StringTools.replace(PlayState.rep.replay.songName, " ", "-");
            switch (songFormat) {
                case 'Dad-Battle': songFormat = 'Dadbattle';
                case 'Philly-Nice': songFormat = 'Philly';
                    // Replay v1.0 support
                case 'dad-battle': songFormat = 'Dadbattle';
                case 'philly-nice': songFormat = 'Philly';
            }

			var songHighscore = StringTools.replace(PlayState.SONG.song, " ", "-");
			switch (songHighscore) {
				case 'Dad-Battle': songHighscore = 'Dadbattle';
				case 'Philly-Nice': songHighscore = 'Philly';
			}

			#if !switch
			Highscore.saveScore(songHighscore, Math.round(PlayState.instance.songScore), PlayState.storyDifficulty);
			Highscore.saveCombo(songHighscore, Ratings.GenerateLetterRank(PlayState.instance.accuracy),PlayState.storyDifficulty);
			#end

            #if sys
            if (PlayState.rep.replay.sm)
                if (!FileSystem.exists(StringTools.replace(PlayState.rep.replay.chartPath,"converted.json","")))
                {
                    Application.current.window.alert("The SM file in this replay does not exist!","SM Replays");
                    return;
                }
            #end

            var poop = "";

            #if sys
            if (PlayState.isSM)
            {
                poop = File.getContent(PlayState.rep.replay.chartPath);
                try
                    {
                PlayState.sm = SMFile.loadFile(PlayState.pathToSm + "/" + StringTools.replace(PlayState.rep.replay.songName," ", "_") + ".sm");
                    }
                    catch(e:Exception)
                    {
                        Application.current.window.alert("Make sure that the SM file is called " + PlayState.pathToSm + "/" + StringTools.replace(PlayState.rep.replay.songName," ", "_") + ".sm!\nAs I couldn't read it.","SM Replays");
                        return;
                    }
            }
            else
                poop = Highscore.formatSong(songFormat, PlayState.rep.replay.songDiff);
            #else
            poop = Highscore.formatSong(PlayState.rep.replay.songName, PlayState.rep.replay.songDiff);
            #end

            music.fadeOut(0.3);

            if (PlayState.isSM)
                PlayState.SONG = Song.loadFromJsonRAW(poop);
            else
                PlayState.SONG = Song.loadFromJson(poop, PlayState.rep.replay.songName);
            PlayState.isStoryMode = false;
            PlayState.storyDifficulty = PlayState.rep.replay.songDiff;
            LoadingState.loadAndSwitchState(new PlayState());

            haveViewReplayed = false;
        }

        if ((FlxG.keys.justPressed.F2 || haveRetryed)  && !PlayState.loadRep)
        {
            PlayState.rep = null;

            PlayState.loadRep = false;

			var songHighscore = StringTools.replace(PlayState.SONG.song, " ", "-");
			switch (songHighscore) {
				case 'Dad-Battle': songHighscore = 'Dadbattle';
				case 'Philly-Nice': songHighscore = 'Philly';
			}

			#if !switch
			Highscore.saveScore(songHighscore, Math.round(PlayState.instance.songScore), PlayState.storyDifficulty);
			Highscore.saveCombo(songHighscore, Ratings.GenerateLetterRank(PlayState.instance.accuracy),PlayState.storyDifficulty);
			#end

            var songFormat = StringTools.replace(PlayState.SONG.song, " ", "-");
            switch (songFormat) {
                case 'Dad-Battle': songFormat = 'Dadbattle';
                case 'Philly-Nice': songFormat = 'Philly';
                case 'dad-battle': songFormat = 'Dadbattle';
                case 'philly-nice': songFormat = 'Philly';
            }

            var poop:String = Highscore.formatSong(songFormat, PlayState.storyDifficulty);

            if (music != null)
                music.fadeOut(0.3);

            PlayState.SONG = Song.loadFromJson(poop, PlayState.SONG.song);
            PlayState.isStoryMode = false;
            PlayState.storyDifficulty = PlayState.storyDifficulty;
            LoadingState.loadAndSwitchState(new PlayState());

            haveRetryed = false; //JOELwindows7: refalsing flag after done.
        }

		super.update(elapsed);
		
        //JOELwindows7: mouse supports. bruh, why not extend from MusicBeatSubstate, wait, Kade? whoah.
        //Didn't expect that. why FlxSubstate? not MusicBeat substate?
        if(FlxG.mouse.overlaps(viewReplayButton)){
            if(FlxG.mouse.justPressed)
                haveViewReplayed = true;
        } 
        if(FlxG.mouse.overlaps(retryButton)){
            if(FlxG.mouse.justPressed)
                haveRetryed = true;
        } 
        if(FlxG.mouse.overlaps(acceptButton)){
            //trace("hover accept button");
            if(FlxG.mouse.justPressed)
                haveClicked = true;
        }
	}

    //JOELwindows7: buttons
	private function addBackButton(x:Int=720-200,y:Int=1280-100,scale:Float=.5){
		backButton = new FlxSprite(x, y).loadGraphic(Paths.image('backButton'));
		backButton.setGraphicSize(Std.int(backButton.width * scale),Std.int(backButton.height * scale));
		backButton.scrollFactor.set();
		backButton.updateHitbox();
		backButton.antialiasing = true;
		add(backButton);
		return backButton;
	}
	private function addLeftButton(x:Int=100,y:Int=1280-100,scale:Float=.5){
		leftButton = new FlxSprite(x, y).loadGraphic(Paths.image('leftAdjustButton'));
		leftButton.setGraphicSize(Std.int(leftButton.width * scale),Std.int(leftButton.height * scale));
		leftButton.scrollFactor.set();
		leftButton.updateHitbox();
		leftButton.antialiasing = true;
		add(leftButton);
		return leftButton;
	}
	private function addRightButton(x:Int=525,y:Int=1280-100,scale:Float=.5){
		rightButton = new FlxSprite(x, y).loadGraphic(Paths.image('rightAdjustButton'));
		rightButton.setGraphicSize(Std.int(rightButton.width * scale),Std.int(rightButton.height * scale));
		rightButton.scrollFactor.set();
		rightButton.updateHitbox();
		rightButton.antialiasing = true;
		add(rightButton);
		return rightButton;
	}
	private function addUpButton(x:Int=240,y:Int=1280-100,scale:Float=.5){
		upButton = new FlxSprite(x, y).loadGraphic(Paths.image('upAdjustButton'));
		upButton.setGraphicSize(Std.int(upButton.width * scale),Std.int(upButton.height * scale));
		upButton.scrollFactor.set();
		upButton.updateHitbox();
		upButton.antialiasing = true;
		add(upButton);
		return upButton;
	}
	private function addDownButton(x:Int=450,y:Int=1280-100,scale:Float=.5){
		downButton = new FlxSprite(x, y).loadGraphic(Paths.image('downAdjustButton'));
		downButton.setGraphicSize(Std.int(downButton.width * scale),Std.int(downButton.height * scale));
		downButton.scrollFactor.set();
		downButton.updateHitbox();
		downButton.antialiasing = true;
		add(downButton);
		return downButton;
	}
	private function addPauseButton(x:Int=640,y:Int=10,scale:Float=.5){
		pauseButton = new FlxSprite(x, y).loadGraphic(Paths.image('pauseButton'));
		pauseButton.setGraphicSize(Std.int(pauseButton.width * scale),Std.int(pauseButton.height * scale));
		pauseButton.scrollFactor.set();
		pauseButton.updateHitbox();
		pauseButton.antialiasing = true;
		add(pauseButton);
		return pauseButton;
	}
	private function addAcceptButton(x:Int=1280,y:Int=360,scale:Float=.5){
		acceptButton = new FlxSprite(x, y).loadGraphic(Paths.image('acceptButton'));
		acceptButton.setGraphicSize(Std.int(acceptButton.width * scale),Std.int(acceptButton.height * scale));
		acceptButton.scrollFactor.set();
		acceptButton.updateHitbox();
		acceptButton.antialiasing = true;
		add(acceptButton);
		return acceptButton;
	}
	private function addRetryButton(x:Int = 500, y:Int =500, scale:Float=.5){
		retryButton = new FlxSprite(x, y).loadGraphic(Paths.image('retryButton'));
		retryButton.setGraphicSize(Std.int(retryButton.width * scale),Std.int(retryButton.height * scale));
		retryButton.scrollFactor.set();
		retryButton.updateHitbox();
		retryButton.antialiasing = true;
		add(retryButton);
		return retryButton;
	}
	private function addViewReplayButton(x:Int = 500, y:Int =500, scale:Float=.5){
		viewReplayButton = new FlxSprite(x, y).loadGraphic(Paths.image('viewReplayButton'));
		viewReplayButton.setGraphicSize(Std.int(viewReplayButton.width * scale),Std.int(viewReplayButton.height * scale));
		viewReplayButton.scrollFactor.set();
		viewReplayButton.updateHitbox();
		viewReplayButton.antialiasing = true;
		add(viewReplayButton);
		return viewReplayButton;
	}
}
