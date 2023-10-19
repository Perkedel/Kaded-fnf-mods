package;

import flixel.addons.ui.FlxUIText;
import flixel.addons.ui.FlxUISprite;
import CoreState;
import haxe.Exception;
#if FEATURE_STEPMANIA
import smTools.SMFile;
#end
#if FEATURE_FILESYSTEM
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
import lime.app.Application;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.input.FlxKeyManager;

using StringTools;

// JOELwindows7: let use CoreSubState instead of FlxSubState instead!
// I have more functions that are cool and good here.
// also FlxUI this pls.
class ResultsScreen extends CoreSubState
{
	public var background:FlxUISprite;
	public var text:FlxUIText;

	public var anotherBackground:FlxUISprite;
	public var graph:HitGraph;
	public var graphSprite:OFLSprite;

	public var comboText:FlxUIText;
	public var contText:FlxUIText;
	public var settingsText:FlxUIText;

	public var music:FlxSound;

	public var graphData:BitmapData;

	public var ranking:String;
	public var accuracy:String;

	// JOELwindows7: handover the video things
	public static var handoverHasVideo:Bool = false;
	public static var handoverVideoPath:String;

	// JOELwindows7: all vars I have now in CoreState.hx. class CoreSubState

	public function new(tellHasVideo:Bool = false, tellVideoPath:String = "assets/videos/null.webm")
	{
		super();
		// JOELwindows7: there may be epilogue cutscene
		handoverHasVideo = tellHasVideo;
		handoverVideoPath = tellVideoPath;
	}

	override function create()
	{
		// JOELwindows7: cast!
		background = cast new FlxUISprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
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

		text = new FlxUIText(20, -55, 0, "Song Cleared!");
		text.size = 34;
		text.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 4, 1);
		text.color = FlxColor.WHITE;
		text.scrollFactor.set();
		add(text);

		var score = PlayState.instance.songScore;
		if (PlayState.isStoryMode)
		{
			score = PlayState.campaignScore;
			text.text = "Week Cleared!";
		}

		var sicks = PlayState.isStoryMode ? PlayState.campaignSicks : PlayState.sicks;
		var goods = PlayState.isStoryMode ? PlayState.campaignGoods : PlayState.goods;
		var bads = PlayState.isStoryMode ? PlayState.campaignBads : PlayState.bads;
		var shits = PlayState.isStoryMode ? PlayState.campaignShits : PlayState.shits;

		comboText = new FlxUIText(20, -75, 0,
			'Judgements:\nSicks - ${sicks}\nGoods - ${goods}\nBads - ${bads}\n\nCombo Breaks: ${(PlayState.isStoryMode ? PlayState.campaignMisses : PlayState.misses)}\nHighest Combo: ${PlayState.highestCombo + 1}\nScore: ${PlayState.instance.songScore}\nAccuracy: ${HelperFunctions.truncateFloat(PlayState.instance.accuracy, 2)}%\n\n${Ratings.GenerateLetterRank(PlayState.instance.accuracy)}\nRate: ${PlayState.songMultiplier}x\n\n${!PlayState.loadRep ? "\nF1 - Replay song" : ""}
        ');
		comboText.size = 28;
		comboText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 4, 1);
		comboText.color = FlxColor.WHITE;
		comboText.scrollFactor.set();
		add(comboText);

		contText = new FlxUIText(FlxG.width - 475, FlxG.height + 50, 0, 'Press ${KeyBinds.gamepad ? 'A' : 'ENTER'} to continue.');
		contText.size = 28;
		contText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 4, 1);
		contText.color = FlxColor.WHITE;
		contText.scrollFactor.set();
		add(contText);

		// JOELwindows7: Yeah
		anotherBackground = cast new FlxUISprite(FlxG.width - 500, 45).makeGraphic(450, 240, FlxColor.BLACK);
		anotherBackground.scrollFactor.set();
		anotherBackground.alpha = 0;
		add(anotherBackground);

		graph = new HitGraph(FlxG.width - 500, 45, 495, 240);
		graph.alpha = 0;

		graphSprite = new OFLSprite(FlxG.width - 510, 45, 460, 240, graph);

		graphSprite.scrollFactor.set();
		graphSprite.alpha = 0;

		add(graphSprite);

		var sicks = HelperFunctions.truncateFloat(PlayState.sicks / PlayState.goods, 1);
		var goods = HelperFunctions.truncateFloat(PlayState.goods / PlayState.bads, 1);

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
				graph.addToHistory(diff / PlayState.songMultiplier, judge, obj3 / PlayState.songMultiplier);
		}

		if (sicks == Math.POSITIVE_INFINITY || sicks == Math.NaN)
			sicks = 0;
		if (goods == Math.POSITIVE_INFINITY || goods == Math.NaN)
			goods = 0;

		graph.update();

		mean = HelperFunctions.truncateFloat(mean / PlayState.rep.replay.songNotes.length, 2);

		settingsText = new FlxUIText(20, FlxG.height + 50, 0,
			'Mean: ${mean}ms (SICK:${Ratings.timingWindows[3]}ms,GOOD:${Ratings.timingWindows[2]}ms,BAD:${Ratings.timingWindows[1]}ms,SHIT:${Ratings.timingWindows[0]}ms)');
		settingsText.size = 16;
		settingsText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2, 1);
		settingsText.color = FlxColor.WHITE;
		settingsText.scrollFactor.set();
		add(settingsText);

		FlxTween.tween(background, {alpha: 0.5}, 0.5);
		FlxTween.tween(text, {y: 20}, 0.5, {ease: FlxEase.expoInOut});
		FlxTween.tween(comboText, {y: 145}, 0.5, {ease: FlxEase.expoInOut});
		FlxTween.tween(contText, {y: FlxG.height - 45}, 0.5, {ease: FlxEase.expoInOut});
		FlxTween.tween(settingsText, {y: FlxG.height - 35}, 0.5, {ease: FlxEase.expoInOut});
		FlxTween.tween(anotherBackground, {alpha: 0.6}, 0.5, {
			onUpdate: function(tween:FlxTween)
			{
				graph.alpha = FlxMath.lerp(0, 1, tween.percent);
				graphSprite.alpha = FlxMath.lerp(0, 1, tween.percent);
			}
		});

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		// JOELwindows7: button sings
		addAcceptButton(FlxG.width - 100, FlxG.height - 125);
		addViewReplayButton(Std.int((FlxG.width / 2) - 300), FlxG.height - 250);
		addRetryButton(Std.int((FlxG.width / 2) - 300), FlxG.height - 125);

		super.create();

		// JOELwindows7: visiblize mouse
		FlxG.mouse.visible = true;
	}

	var frames = 0;

	override function update(elapsed:Float)
	{
		if (music != null)
			if (music.volume < 0.5)
				music.volume += 0.01 * elapsed;

		// keybinds

		if (PlayerSettings.player1.controls.ACCEPT || haveClicked #if android || FlxG.android.justReleased.BACK #end)
		{
			if (music != null)
				music.fadeOut(0.3);

			PlayState.loadRep = false;
			PlayState.stageTesting = false;
			PlayState.rep = null;

			#if !switch
			Highscore.saveScore(PlayState.SONG.songId, Math.round(PlayState.instance.songScore), PlayState.storyDifficulty);
			Highscore.saveCombo(PlayState.SONG.songId, Ratings.GenerateLetterRank(PlayState.instance.accuracy), PlayState.storyDifficulty);
			#end

			if (PlayState.isStoryMode)
			{
				// FlxG.sound.playMusic(Paths.music('freakyMenu'));
				// Conductor.changeBPM(102);
				// JOELwindows7: // above used
				// FlxG.switchState(new MainMenuState());
				// JOELwindows7: works with Android
				FlxG.switchState(handoverHasVideo ? VideoCutscener.getThe(handoverVideoPath, new StoryMenuState()) : new StoryMenuState());
				// JOELwindows7: here epilogue cutscenes
			}
			else
				FlxG.switchState(new FreeplayState());
			PlayState.instance.clean();

			haveClicked = false;
		}

		if ((FlxG.keys.justPressed.F1 || haveViewReplayed || haveRetryed) && !PlayState.loadRep)
		{
			PlayState.rep = null;

			PlayState.loadRep = false;
			PlayState.stageTesting = false;

			#if !switch
			Highscore.saveScore(PlayState.SONG.songId, Math.round(PlayState.instance.songScore), PlayState.storyDifficulty);
			Highscore.saveCombo(PlayState.SONG.songId, Ratings.GenerateLetterRank(PlayState.instance.accuracy), PlayState.storyDifficulty);
			#end

			if (music != null)
				music.fadeOut(0.3);

			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = PlayState.storyDifficulty;
			LoadingState.loadAndSwitchState(new PlayState());
			PlayState.instance.clean();

			haveRetryed = false; // JOELwindows7: refalsing flag after done.
			haveViewReplayed = false;
		}

		super.update(elapsed);
	}

	// JOELwindows7: new CoreState.hx yess
	override function manageMouse()
	{
		super.manageMouse();
		// JOELwindows7: mouse supports. bruh, why not extend from MusicBeatSubstate, wait, Kade? whoah.
		// Didn't expect that. why FlxSubstate? not MusicBeat substate?
		if (FlxG.mouse.overlaps(viewReplayButton))
		{
			if (FlxG.mouse.justPressed)
				haveViewReplayed = true;
		}
		if (FlxG.mouse.overlaps(retryButton))
		{
			if (FlxG.mouse.justPressed)
				haveRetryed = true;
		}
		if (FlxG.mouse.overlaps(acceptButton))
		{
			// trace("hover accept button");
			if (FlxG.mouse.justPressed)
				haveClicked = true;
		}
	}
}
