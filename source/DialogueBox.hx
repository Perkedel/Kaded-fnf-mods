package;

import flixel.addons.ui.FlxUIGroup;
import flixel.addons.ui.FlxUISprite;
import flixel.addons.ui.FlxUIText;
import flixel.addons.display.FlxPieDial;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIButton;
import flixel.ui.FlxButton;
import flixel.tweens.FlxTween;
import flixel.system.FlxSound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

// JOELwindows7: use FlxUI stuffs!
// and remember, `FlxUIGroup` inherits `FlxSpriteGroup`.
class DialogueBox extends FlxUIGroup
{
	var box:FlxUISprite;

	var curCharacter:String = '';

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	var dropText:FlxUIText;
	var skipText:FlxUIText;

	var paththing:String = 'sky/port'; // JOELwindows7: I swear, this was how bbpanzu did this on vs. Sky!

	// public var finishThing:Void->Void;
	public var finishThing:Void->Void;

	var portraitLeft:FlxUISprite;
	var portraitRight:FlxUISprite;
	var portraitMiddle:FlxUISprite; // JOELwindows7: for gf
	var portraitJustDoIt:FlxUISprite; // JOELwindows7: for custom character beyond bf, dad, or gf. use in-game image from character folder I guess
	// JOELwindows7: incoming! bbpanzu's vs. Sky'
	var portraitB:FlxUISprite;
	var portraitD:FlxUISprite;
	var portraitDD:FlxUISprite;

	var handSelect:FlxUISprite;
	var bgFade:FlxUISprite;

	// JOELwindows7: heuristic flag for non-pixel level
	var nonPixel:Bool = false;

	// JOELwindows7: heuristic flag for character that is not default Senpai
	var customCharPls:Bool = false;
	var customBfPls:Bool = false;
	var customGfPls:Bool = false;

	// JOELwindows7: We found out that there is prefix according to Flixel demo FlxType
	// https://haxeflixel.com/demos/FlxTypeText/
	var prefixDad:String = 'DialogueBox Dad';
	var prefixBf:String = 'DialogueBox Bf';
	var prefixGf:String = 'DialogueBox Gf';

	// JOELwindows7: okay, screw this, let's have entire character handed over shall we?
	var handoverDad:Character;
	var handoverBf:Boyfriend;
	var handoverGf:Character;

	// JOELwindows7: own FlxSound because generate song destroyed the intro music
	public var sound:FlxSound; // make public to let modchart perhaps manipulate it, idk. Okay this is now bg music for dialogue.

	// JOELwindows7: touchscreen stuffs
	var skipButton:FlxUIButton;
	var autoClickCheckbox:FlxUICheckBox;
	var autoClickDelayStepper:FlxUINumericStepper;
	var autoClickDelayLabel:FlxUIText;
	var haveSkippedDialogue:Bool = false;
	var tobeAutoClicked:Bool = false;

	public var autoClickTimer:FlxTimer;

	var autoClickTimerDisplay:FlxPieDial; // JOELwindows7: yes, the timer display. see https://haxeflixel.com/demos/FlxPieDial/ & https://github.com/HaxeFlixel/flixel-demos/blob/master/Features/FlxPieDial/source/DemoState.hx

	var counterEH:Int = 0; // dialog counterer

	var skyDialogue:Bool; // JOELwindows7: well, ultimately we gotta compensate this. for vs. Sky by bbpanzu. idk what else how to use for others.

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>, ?hadChat:Bool = false, ?isEpilogue:Bool = false, ?customChar:Bool = false,
			?customCharXML:String = "jakartaFair/Hookx-dialogueAppear", ?customCharFrame:String = "enter", ?customCharPrefix:String = "Hookx Portrait Enter")
	{
		super();

		// JOELwindows7: immediately harvest all characters
		handoverDad = PlayState.dad;
		handoverBf = PlayState.boyfriend;
		handoverGf = PlayState.gf;

		// JOELwindows7: not my code. but what the?! refer other class without import?! NO NEED TO POINT THE INSTANCE TOO?!
		// whoah! in Flutter, I have to import. even when they're next to it! wow! Haxe is great!!!
		// AND THE PECK?! in Unity, I must point also the instance inside the class
		// (just to grab its current value of a variable right now), not just the class itself. hoof! I am jealous!
		if (!isEpilogue)
		{
			switch (PlayState.SONG.songId.toLowerCase())
			{
				case 'senpai':
					sound = new FlxSound().loadEmbedded(Paths.music('Lunchbox'), true);
					sound.volume = 0;
					FlxG.sound.list.add(sound);
					sound.fadeIn(1, 0, 0.8);
				case 'thorns':
					sound = new FlxSound().loadEmbedded(Paths.music('LunchboxScary'), true);
					sound.volume = 0;
					FlxG.sound.list.add(sound);
					sound.fadeIn(1, 0, 0.8);
				case 'senpai-midi':
					trace("Hey play lunchbox now");
					// FlxG.sound.playMusic(Paths.music('Lunchbox-midi'), 0);
					// FlxG.sound.music.fadeIn(1, 0.1, 0.8);
					// DialogueBox.ownIntroMusic = new FlxSound().loadEmbedded(Paths.music('Lunchbox-midi'));
					sound = new FlxSound().loadEmbedded(Paths.music('Lunchbox-midi'), true);
					sound.volume = 0;
					FlxG.sound.list.add(sound);
					sound.fadeIn(1, 0, 0.8);
				case 'thorns-midi':
					// FlxG.sound.playMusic(Paths.music('LunchboxScary-midi'), 0);
					// FlxG.sound.music.fadeIn(1, 0.1, 0.8);
					// DialogueBox.ownIntroMusic = new FlxSound().loadEmbedded(Paths.music('LunchboxScary-midi'));
					sound = new FlxSound().loadEmbedded(Paths.music('LunchboxScary-midi'), true);
					sound.volume = 0;
					FlxG.sound.list.add(sound);
					sound.fadeIn(1, 0, 0.8);
				// JOELwindows7: sounds dialogue for vs. Sky by bbpanzu
				case 'wife-forever':
					// FlxG.sound.playMusic(Paths.music('skyShift', 'shared'), 0);
					// FlxG.sound.music.fadeIn(1, 0, 0.8);
					sound = new FlxSound().loadEmbedded(Paths.music('skyShift', 'shared'), true);
					sound.volume = 0;
					FlxG.sound.list.add(sound);
					sound.fadeIn(1, 0, 0.8);
				case 'manifest':
					sound = new FlxSound();
				// end of vs. Sky by bbpanzu
				default:
					sound = new FlxSound();
					// DialogueBox.ownIntroMusic = new FlxSound();
					trace("No pre-dialog sound to play!");
			}
		}
		else
		{
			sound = new FlxSound();
		}

		// JOELwindows7: because generate song destroyed the music.
		// DialogueBox.ownIntroMusic.volume = 0;
		// DialogueBox.ownIntroMusic.fadeIn(1, 0.1, 0.8);
		// FlxG.sound.list.add(ownIntroMusic);
		// DialogueBox.ownIntroMusic.play();

		// JOELwindows7: rehg
		bgFade = cast new FlxUISprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);
		// IDEA: JOELwindows7: color the background of dialogue based on the color chosen by song data.

		new FlxTimer().start(0.83, function(tmr:FlxTimer)
		{
			bgFade.alpha += (1 / 5) * 0.7;
			if (bgFade.alpha > 0.7)
				bgFade.alpha = 0.7;
		}, 5);

		box = new FlxUISprite(-20, 45);

		var hasDialog = false;
		// JOELwindows7: no lowercase needed anymore.
		// trace("song is: " + PlayState.SONG.song.toLowerCase() + " so pls check dialog!");
		trace("song is: " + PlayState.SONG.songId + " so pls check dialog!");
		// switch (PlayState.SONG.songId.toLowerCase())
		switch (PlayState.SONG.songId)
		{
			case 'senpai' | 'senpai-midi':
				// JOELwindows7: pls add week 6 library makering.
				// it seems the lime confused between main weeb and week special weeb folder
				// or try to remove weeb and add week6 in here
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-pixel', 'week6');
				box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
				box.animation.addByIndices('normal', 'Text Box Appear', [4], "", 24);
			case 'roses':
				hasDialog = true;
				FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX'));

				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-senpaiMad', 'week6');
				box.animation.addByPrefix('normalOpen', 'SENPAI ANGRY IMPACT SPEECH', 24, false);
				box.animation.addByIndices('normal', 'SENPAI ANGRY IMPACT SPEECH', [4], "", 24);

			case 'thorns' | 'thorns-midi':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-evil', 'week6');
				box.animation.addByPrefix('normalOpen', 'Spirit Textbox spawn', 24, false);
				box.animation.addByIndices('normal', 'Spirit Textbox spawn', [11], "", 24);

				// JOELwindows7: bruh
				var face:FlxUISprite = cast new FlxUISprite(320, 170).loadGraphic(Paths.loadImage('weeb/spiritFaceForward'));
				face.setGraphicSize(Std.int(face.width * 6));
				add(face);
			// JOELwindows7: bbpanzu's vs. Sky
			case 'wife-forever':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('sky/dia');
				box.animation.addByIndices('normalOpen', 'dia', [0, 1, 2, 3, 4, 5], "", 24, false);
				box.animation.addByIndices('normal', 'dia', [6], "", 24);
				box.setPosition();
				nonPixel = true;
				skyDialogue = true;
				customCharPls = true;
				customBfPls = true;
				customGfPls = true;
			case 'manifest':
				paththing = 'sky/port_mad';
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('sky/dia');
				box.animation.addByIndices('normalOpen', 'dia', [0, 1, 2, 3, 4, 5], "", 24, false);
				box.animation.addByIndices('normal', 'dia', [6], "", 24);
				box.setPosition();
				nonPixel = true;
				skyDialogue = true;
				customCharPls = true;
				customBfPls = true;
				customGfPls = true;
			case 'sky':
				paththing = 'sky/port_an';
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('sky/dia');
				box.animation.addByIndices('normalOpen', 'dia', [0, 1, 2, 3, 4, 5], "", 24, false);
				box.animation.addByIndices('normal', 'dia', [6], "", 24);
				box.setPosition();
				nonPixel = true;
				skyDialogue = true;
				customCharPls = true;
				customBfPls = true;
				customGfPls = true;
			// end of bbpanzu's vs. Sky
			case 'windfall' | 'rule-the-world' | 'well-meet-again' | 'getting-freaky' | 'breakfast' | 'dont-stop' | 'title-classic' | 'mayday' | 'cradles' |
				'doremi' | 'test-vanilla':
				// JOELwindows7: the dialogue normalizations
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('speech_bubble_talking');
				box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
				box.animation.addByIndices('normal', 'speech bubble normal', [4], "", 24);

				nonPixel = true;

				customCharPls = true;
				initiatePortraitLeft(-20, 40, 0.9, 'jakartaFair/Hookx-dialogueAppear', 'enter', 'Hookx Portrait Enter', 24, false, 'shared');
			case 'roses-midi':
				hasDialog = true;
				FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX-midi'));

				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-senpaiMad', 'week6');
				box.animation.addByPrefix('normalOpen', 'SENPAI ANGRY IMPACT SPEECH', 24, false);
				box.animation.addByIndices('normal', 'SENPAI ANGRY IMPACT SPEECH', [4], "", 24);
			default:
				trace("Uh, no dialog info...");
				hasDialog = hadChat;
				box.frames = Paths.getSparrowAtlas('speech_bubble_talking');
				box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
				box.animation.addByIndices('normal', 'speech bubble normal', [4], "", 24);

				nonPixel = true;

				if (customChar)
				{
					customCharPls = true;
					initiatePortraitLeft(-20, 40, 0.9, customCharXML, customCharFrame, customCharPrefix, 24, false, 'shared');
				}
		}
		if (PlayState.instance != null)
			PlayState.instance.dialogueScene(); // JOELwindows7: here functions when dialog starts.

		this.dialogueList = dialogueList;

		if (!hasDialog)
		{
			trace("yeah no dialog.");
			return;
		}
		else
			trace("You should have dialog man");

		// JOELwindows7: doned the heuristic sort of
		// for dad player
		if (!customCharPls)
		{
			portraitLeft = new FlxUISprite(-20, 40);
			portraitLeft.frames = Paths.getSparrowAtlas('weeb/senpaiPortrait');
			portraitLeft.animation.addByPrefix('enter', 'Senpai Portrait Enter', 24, false);
			portraitLeft.setGraphicSize(Std.int(portraitLeft.width * CoolUtil.daPixelZoom * 0.9));
			portraitLeft.updateHitbox();
			portraitLeft.scrollFactor.set();
			add(portraitLeft);
			portraitLeft.visible = false;
		}
		else if (skyDialogue)
		{
			// JOELwindows7: here bbpanzu's vs. Sky
			portraitLeft = new FlxUISprite(276.95, 149.9);
			portraitLeft.frames = Paths.getSparrowAtlas(paththing);
			portraitLeft.animation.addByPrefix('enter', 'portrait', 24, false);
			// portraitLeft.setGraphicSize(Std.int(portraitLeft.width * PlayState.daPixelZoom * 0.9));
			portraitLeft.updateHitbox();
			portraitLeft.scrollFactor.set();
			add(portraitLeft);
			portraitLeft.visible = false;
		}

		// JOELwindows7: Oh, God. there's alot of unprocedural objectings here. vs. Sky by bbpanzu
		// if (skyDialogue)
		// {
		portraitD = new FlxUISprite(276.95, 149.9);
		portraitD.frames = Paths.getSparrowAtlas('sky/port_an');
		portraitD.animation.addByPrefix('enter', 'portrait', 24, false);
		// portraitLeft.setGraphicSize(Std.int(portraitLeft.width * PlayState.daPixelZoom * 0.9));
		portraitD.updateHitbox();
		portraitD.scrollFactor.set();
		add(portraitD);
		portraitD.visible = false;

		portraitDD = new FlxUISprite(276.95, 149.9);
		portraitDD.frames = Paths.getSparrowAtlas('sky/port');
		portraitDD.animation.addByPrefix('enter', 'portrait', 24, false);
		// portraitLeft.setGraphicSize(Std.int(portraitLeft.width * PlayState.daPixelZoom * 0.9));
		portraitDD.updateHitbox();
		portraitDD.scrollFactor.set();
		add(portraitDD);
		portraitDD.visible = false;

		portraitB = new FlxUISprite(684.05, 149.9);
		portraitB.frames = Paths.getSparrowAtlas('sky/bfport');
		portraitB.animation.addByPrefix('enter', 'bfport', 24, false);
		// portraitLeft.setGraphicSize(Std.int(portraitLeft.width * PlayState.daPixelZoom * 0.9));
		portraitB.updateHitbox();
		portraitB.scrollFactor.set();
		add(portraitB);
		portraitB.visible = false;
		// }
		// end of vs. Sky by bbpanzu

		// For BF too as well
		if (!customBfPls)
		{
			portraitRight = new FlxUISprite(0, 40);
			portraitRight.frames = Paths.getSparrowAtlas('weeb/bfPortrait');
			portraitRight.animation.addByPrefix('enter', 'Boyfriend portrait enter', 24, false);
			portraitRight.setGraphicSize(Std.int(portraitRight.width * CoolUtil.daPixelZoom * 0.9));
			portraitRight.updateHitbox();
			portraitRight.scrollFactor.set();
			add(portraitRight);
			portraitRight.visible = false;
		}
		else if (skyDialogue)
		{
			// JOELwindows7: here bbpanzu's vs. Sky
			portraitRight = new FlxUISprite(684.05, 149.9);
			if (PlayState.SONG.songId == "manifest")
			{
				portraitRight.frames = Paths.getSparrowAtlas('sky/gfport');
				portraitRight.animation.addByPrefix('enter', 'gfport', 24, false);
				portraitRight.animation.addByPrefix('fuckyou', 'gfporFUCKYOU', 24, false);
			}
			else
			{
				portraitRight.frames = Paths.getSparrowAtlas('sky/bfport');
				portraitRight.animation.addByPrefix('enter', 'bfport', 24, false);
			}
			// portraitRight.setGraphicSize(Std.int(portraitRight.width * PlayState.daPixelZoom * 0.9));
			portraitRight.updateHitbox();
			portraitRight.scrollFactor.set();
			add(portraitRight);
			portraitRight.visible = false;
		}

		// last but not least the bf
		if (!customGfPls)
		{
			portraitMiddle = new FlxUISprite(0, 40);
			portraitMiddle.frames = Paths.getSparrowAtlas('weeb/gfPortrait', 'shared');
			portraitMiddle.animation.addByPrefix('enter', 'Girlfriend portrait enter', 24, false);
			portraitMiddle.setGraphicSize(Std.int(portraitMiddle.width * CoolUtil.daPixelZoom * 0.9));
			portraitMiddle.updateHitbox();
			portraitMiddle.scrollFactor.set();
			add(portraitMiddle);
			portraitMiddle.visible = false;
		}
		else if (skyDialogue)
		{
			portraitMiddle = new FlxUISprite(684.05, 149.9);
			// if (PlayState.SONG.songId == "manifest")
			// {
			portraitMiddle.frames = Paths.getSparrowAtlas('sky/gfport');
			portraitMiddle.animation.addByPrefix('enter', 'gfport', 24, false);
			portraitMiddle.animation.addByPrefix('fuckyou', 'gfporFUCKYOU', 24, false);
			// }
			// else
			// {
			// 	portraitMiddle.frames = Paths.getSparrowAtlas('sky/bfport');
			// 	portraitMiddle.animation.addByPrefix('enter', 'bfport', 24, false);
			// }
			// portraitMiddle.setGraphicSize(Std.int(portraitRight.width * PlayState.daPixelZoom * 0.9));
			portraitMiddle.updateHitbox();
			portraitMiddle.scrollFactor.set();
			add(portraitMiddle);
			portraitMiddle.visible = false;
		}

		// JOELwindows7: I've added a heuristic to size width accordingly between nonPixel and pixel level.
		box.animation.play('normalOpen');
		// box.setGraphicSize(Std.int(box.width * CoolUtil.daPixelZoom * 0.9));
		if (nonPixel)
		{
			box.setPosition(FlxG.width * .5, FlxG.height - 300); // correct shoot is 300 behind screen height
			box.setGraphicSize(Std.int(box.width * 0.9)); // JOELwindows7: copy from original without daPixelZoom value!
		}
		else
		{
			box.setPosition(FlxG.width * .5, FlxG.height - 690); // correct shoot is 690 behind screen height
			// JOELwindows7: it was 20 behind screen height
			// ok ladies and gentlemen. how in the world did we overshot that?
			// it wasn't like that before, and the same 20 behind screen height was fine!
			// who Haxe part fault this is?
			box.setGraphicSize(Std.int(box.width * CoolUtil.daPixelZoom * 0.9));
		}
		box.updateHitbox();
		add(box);

		box.screenCenter(X);
		portraitLeft.screenCenter(X);
		skipText = new FlxUIText(10, 18, Std.int(FlxG.width * 0.6), "", 16); // JOELwindows7: due to watermark, push Y down. was Y = 10
		skipText.font = 'Pixel Arial 11 Bold';
		skipText.color = 0x000000;
		skipText.text = 'press back to skip';
		add(skipText);
		// JOELwindows7: c'mon, why chain return data type is not the extension class itself? why? `cast` keyword will accumulate & becomes expensive!!!
		handSelect = cast new FlxUISprite(FlxG.width * 0.9, FlxG.height * 0.9).loadGraphic(Paths.loadImage('weeb/pixelUI/hand_textbox'));
		add(handSelect);

		if (!talkingRight)
		{
			// box.flipX = true;
		}

		dropText = new FlxUIText(242, 502, Std.int(FlxG.width * 0.6), "", 32);
		dropText.font = 'Pixel Arial 11 Bold';
		dropText.color = FlxColor.fromInt(0xFFD89494);
		add(dropText);

		swagDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.6), "", 32);
		swagDialogue.font = 'Pixel Arial 11 Bold';
		swagDialogue.color = FlxColor.fromInt(0xFF3F2021);
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
		add(swagDialogue);

		dialogue = new Alphabet(0, 80, "", false, true);
		// dialogue.x = 90;
		// add(dialogue);

		// JOELwindows7: now the touchscreen buttons!
		// Skip dialogue
		// FlxG.width * 0.9
		// was Y 45.
		skipButton = new FlxUIButton(10, 50, "Skip", function()
		{
			haveSkippedDialogue = true;
		});
		// skipButton.loadGraphic(Paths.loadImage('weeb/pixelUI/skip_button'));
		skipButton.scrollFactor.set();
		add(skipButton);

		// JOELwindows7: autoclick options
		autoClickTimer = new FlxTimer();
		autoClickCheckbox = new FlxUICheckBox(FlxG.width - 80, 10, null, null, "Auto-click", 100);
		// autoClickCheckbox.font = 'Pixel Arial 11 Bold';
		autoClickCheckbox.scrollFactor.set();
		autoClickCheckbox.checked = FlxG.save.data.autoClick;
		autoClickCheckbox.callback = function()
		{
			Debug.logTrace("Auto Click is " + Std.string(autoClickCheckbox.checked));
			FlxG.save.data.autoClick = autoClickCheckbox.checked;
			checkAutoClick(autoClickCheckbox.checked);
			FlxG.save.flush();
		};
		add(autoClickCheckbox);
		autoClickDelayStepper = new FlxUINumericStepper(FlxG.width - 80, 45, .5, 2, 1, 5, 1);
		autoClickDelayStepper.scrollFactor.set();
		autoClickDelayStepper.value = FlxG.save.data.autoClickDelay;
		autoClickDelayStepper.name = "autoClick_delay";
		// autoClickDelayStepper.callback = function(){
		// 	FlxG.save.data.autoClickDelay = autoClickDelayStepper.value;
		// 	FlxG.save.flush();
		// };
		add(autoClickDelayStepper);
		autoClickDelayLabel = new FlxUIText(FlxG.width - 180, 45, Std.int(FlxG.width * 0.6), "", 8);
		autoClickDelayLabel.scrollFactor.set();
		autoClickDelayLabel.font = 'Pixel Arial 11 Bold';
		autoClickDelayLabel.color = 0x00000000;
		autoClickDelayLabel.text = 'Auto-click delay: ';
		add(autoClickDelayLabel);
		autoClickTimerDisplay = new FlxPieDial(FlxG.width - 180, 10, 15, FlxColor.GREEN, FlxPieDialShape.CIRCLE, true, 0);
		add(autoClickTimerDisplay);
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{
		// HARD CODING CUZ IM STUPDI
		if (PlayState.SONG.songId.toLowerCase() == 'roses' || PlayState.SONG.songId.toLowerCase() == 'roses-midi')
			portraitLeft.visible = false;
		if (PlayState.SONG.songId.toLowerCase() == 'thorns' || PlayState.SONG.songId.toLowerCase() == 'thorns-midi')
		{
			portraitLeft.visible = false;
			swagDialogue.color = FlxColor.WHITE;
			dropText.color = FlxColor.BLACK;
		}

		dropText.text = swagDialogue.text;

		if (box.animation.curAnim != null)
		{
			if (box.animation.curAnim.name == 'normalOpen' && box.animation.curAnim.finished)
			{
				box.animation.play('normal');
				dialogueOpened = true;
			}
		}

		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}
		// JOELwindows7: press skip dialogue
		if ((PlayerSettings.player1.controls.BACK || haveSkippedDialogue) && isEnding != true)
		{
			haveSkippedDialogue = false;
			remove(dialogue);
			isEnding = true;
			// switch (PlayState.SONG.songId.toLowerCase())
			// {
			// JOELwindows7: sneaky sneaky! also add sky.
			// case "senpai" | "thorns" | "senpai-midi" | "thorns-midi" | 'sky' | 'wife-forever':
			if (sound != null) // JOELwindows7: safety first.
				sound.fadeOut(2.2, 0, function(tween:FlxTween)
				{
					sound.stop(); // JOELwindows7: make sure it stops for good.
				});
			// case "roses" | "roses-midi":
			// 	trace("roses");
			// default:
			// 	trace("other song");
			// }
			if (PlayState.instance != null)
				PlayState.instance.dialogueSceneClose(); // JOELwindows7: do functions when this close.
			new FlxTimer().start(0.2, function(tmr:FlxTimer)
			{
				box.alpha -= 1 / 5;
				bgFade.alpha -= 1 / 5 * 0.7;
				portraitLeft.visible = false;
				portraitRight.visible = false;
				swagDialogue.alpha -= 1 / 5;
				dropText.alpha = swagDialogue.alpha;
			}, 5);

			new FlxTimer().start(1.2, function(tmr:FlxTimer)
			{
				finishThing();
				kill();
			});
		}
		// JOELwindows7: add mouse click t continue, also auto-click
		if ((PlayerSettings.player1.controls.ACCEPT || (haveClicked) || tobeAutoClicked) && dialogueStarted == true)
		{
			// JOELwindows7: reset auto-click first.
			tobeAutoClicked = false;
			haveClicked = false;
			autoClickTimer.cancel();

			remove(dialogue);

			FlxG.sound.play(Paths.sound('clickText'), 0.8);

			if (dialogueList[1] == null && dialogueList[0] != null)
			{
				// JOELwindows7: MARK FOR DIALOG RAN OUT
				if (!isEnding)
				{
					isEnding = true;

					// if (PlayState.SONG.songId.toLowerCase() == 'senpai'
					// 	|| PlayState.SONG.songId.toLowerCase() == 'thorns'
					// 	|| PlayState.SONG.songId.toLowerCase() == 'senpai-midi'
					// 	|| PlayState.SONG.songId.toLowerCase() == 'thorns-midi')
					// JOELwindows7: Fade out & Do this after that music faded out
					if (sound != null) // JOELwindows7: safety first.
						sound.fadeOut(2.2, 0, function(twn:FlxTween)
						{
							sound.stop();
						});
					if (PlayState.instance != null)
						PlayState.instance.dialogueSceneEnding(); // JOELwindows7: here when ending.

					new FlxTimer().start(0.2, function(tmr:FlxTimer)
					{
						box.alpha -= 1 / 5;
						bgFade.alpha -= 1 / 5 * 0.7;
						portraitLeft.visible = false;
						portraitRight.visible = false;
						swagDialogue.alpha -= 1 / 5;
						dropText.alpha = swagDialogue.alpha;
					}, 5);

					new FlxTimer().start(1.2, function(tmr:FlxTimer)
					{
						finishThing();
						kill();
					});
				}
			}
			else
			{
				// JOELwindows7: MARK FOR DIALOG STILL HAS NEXT LINE
				dialogueList.remove(dialogueList[0]);
				counterEH++; // JOELwindows7: add count
				startDialogue();
			}
		}

		super.update(elapsed);

		// JOELwindows7: try to watch time remaining of the auto click
		if (autoClickCheckbox.checked)
		{
			if (autoClickTimer.active && autoClickTimer.timeLeft > 0 && !autoClickTimer.finished)
				autoClickTimerDisplay.amount = (autoClickTimer.timeLeft / autoClickTimer.time);
			else
				autoClickTimerDisplay.amount = 1;
		}
		else
		{
			autoClickTimerDisplay.amount = 0;
		}

		// JOELwindows7: unfortunately this is neither Core state we had
		manageMouse();
	}

	var isEnding:Bool = false;

	// JOELwindows7: let's just put some part of module as a function shall we?
	function initiatePortraitLeft(newSpriteX:Int = -20, newSpriteY:Int = 40, zooming:Float = 0.9, textureXmlPath:String = 'weeb/senpaiPortrait',
			name:String = 'enter', prefix:String = 'Senpai Portrait Enter', frameRate:Int = 24, flip:Bool = false, ?library = ''):Void
	{
		portraitLeft = new FlxUISprite(newSpriteX, newSpriteY);
		portraitLeft.frames = Paths.getSparrowAtlas(textureXmlPath, library);
		portraitLeft.animation.addByPrefix(name, prefix, frameRate, flip);
		portraitLeft.setGraphicSize(Std.int(portraitLeft.width * CoolUtil.daPixelZoom * zooming));
		portraitLeft.updateHitbox();
		portraitLeft.scrollFactor.set();
		add(portraitLeft);
		portraitLeft.visible = false;
	}

	// Hookx y 90
	// JOELwindows7: same for the bf too
	function initiatePortraitRight(newSpriteX:Int = 0, newSpriteY:Int = 40, zooming:Float = 0.9, textureXmlPath:String = 'weeb/bfPortrait',
			name:String = 'enter', prefix:String = 'Boyfriend portrait Enter', frameRate:Int = 24, flip:Bool = false, ?library = ''):Void
	{
		portraitRight = new FlxUISprite(newSpriteX, newSpriteY);
		portraitRight.frames = Paths.getSparrowAtlas(textureXmlPath, library);
		portraitRight.animation.addByPrefix(name, prefix, frameRate, flip);
		portraitRight.setGraphicSize(Std.int(portraitRight.width * CoolUtil.daPixelZoom * zooming));
		portraitRight.updateHitbox();
		portraitRight.scrollFactor.set();
		add(portraitRight);
		portraitRight.visible = false;
	}

	function initiatePortraitMiddle(newSpriteX:Int = -20, newSpriteY:Int = 40, zooming:Float = 0.9, textureXmlPath:String = 'weeb/gfPortrait',
			name:String = 'enter', prefix:String = 'Girlfriend portrait enter', frameRate:Int = 24, flip:Bool = false, ?library = 'shared')
	{
		portraitMiddle = new FlxUISprite(newSpriteX, newSpriteY);
		portraitMiddle.frames = Paths.getSparrowAtlas(textureXmlPath, library);
		portraitMiddle.animation.addByPrefix(name, prefix, frameRate, flip);
		portraitMiddle.setGraphicSize(Std.int(portraitMiddle.width * CoolUtil.daPixelZoom * zooming));
		portraitMiddle.updateHitbox();
		portraitMiddle.scrollFactor.set();
		add(portraitMiddle);
		portraitMiddle.visible = false;
	}

	function initiatePortraitCustom(character:String = 'dad', side:Int = 0)
	{
	}

	function startDialogue():Void
	{
		cleanDialog();
		// var theDialog:Alphabet = new Alphabet(0, 70, dialogueList[0], false, true);
		// dialogue = theDialog;
		// add(theDialog);

		// swagDialogue.text = ;
		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.start(0.04, true, false, null, swagDialogueOnComplete.bind());

		// JOELwindows7: tired to go everything invisiblize each. let's invisiblez all first instead
		// regular
		// portraitRight.visible = false;
		// portraitLeft.visible = false;
		// portraitMiddle.visible = false;
		// bbpanzu's vs. sky
		// portraitB.visible = false;
		// portraitD.visible = false;
		// portraitDD.visible = false;
		// JOELwindows7: NEW!!! ALL IN ONE INVISIBILIZER WITH SAFETY!
		invisiblizePortraits();

		switch (curCharacter)
		{
			case 'dad':
				// JOELwindows7: YEY the prefix
				// prefixDad = PlayState.SONG.player2.toUpperCase();
				prefixDad = PlayState.dad.displayName;
				swagDialogue.prefix = prefixDad + ": ";
				portraitRight.visible = false;
				portraitMiddle.visible = false;
				if (!portraitLeft.visible)
				{
					portraitLeft.visible = true;
					portraitLeft.animation.play('enter'); // JOELwindows7: no, wait.
				}
				switch (PlayState.SONG.player2.toLowerCase())
				{ // JOELwindows7: HAHA! different character sound go brrrrr!!!
					// case 'bf-covid':
					// 	// JOELwindows7: reconvert to regular name
					// 	prefixDad = 'Boyfriend';
					// 	swagDialogue.prefix = prefixDad + ": ";
					// case 'gf-covid':
					// 	// JOELwindows7: reconvert to regular name
					// 	prefixDad = 'Girlfriend';
					// 	swagDialogue.prefix = prefixDad + ": ";
					// case 'gf-ht':
					// 	// JOELwindows7: idk what's the name of this TV
					// 	prefixDad = 'Television';
					// 	swagDialogue.prefix = prefixDad + ": ";
					case 'hookx' | 'hookx-legacy':
						dropText.font = 'Ubuntu Bold';
						swagDialogue.font = 'Ubuntu Bold';
						dropText.color = 0xFF7d00bf;
						swagDialogue.color = 0xFF055bff;
						swagDialogue.sounds = [
							FlxG.sound.load(Paths.sound('textSpeak/hookx/talk1'), 0.6),
							FlxG.sound.load(Paths.sound('textSpeak/hookx/talk2'), 0.6),
							FlxG.sound.load(Paths.sound('textSpeak/hookx/talk3'), 0.6),
						];
					case 'bf-pixel' | 'senpai' | 'senpai-mad' | 'senpai-angry':
						// somehow color bug with pixel font
						dropText.font = 'Pixel Arial 11 Bold';
						swagDialogue.font = 'Pixel Arial 11 Bold';
						dropText.color = 0xFFD89494;
						swagDialogue.color = 0xFF3F2021;
						swagDialogue.sounds = [
							FlxG.sound.load(Paths.sound(Perkedel.NULL_DIALOGUE_SOUND_PATHS[0]), Perkedel.NULL_DIALOGUE_SOUND_VOLUME)
						];
						if (handoverBf.dialogueChatSoundPaths != null && handoverBf.dialogueChatSoundPaths.length > 0)
						{
							for (i in handoverBf.dialogueChatSoundPaths)
							{
								swagDialogue.sounds.push(FlxG.sound.load(Paths.sound(i), handoverBf.dialogueChatSoundVolume));
							}
						}
					default:
						dropText.font = handoverDad.fontDrop != null
							&& handoverDad.fontDrop != '' ? handoverDad.fontDrop : 'Pixel Arial 11 Bold';
						swagDialogue.font = handoverDad.font != null && handoverDad.font != '' ? handoverDad.font : 'Pixel Arial 11 Bold';
						dropText.color = handoverDad.fontColorDrop != null
							&& handoverDad.fontColorDrop != '' ? FlxColor.fromString(handoverDad.fontColorDrop) : FlxColor.fromInt(0xFFD89494);
						swagDialogue.color = handoverDad.fontColor != null
							&& handoverDad.fontColor != '' ? FlxColor.fromString(handoverDad.fontColor) : FlxColor.fromInt(0xFF3F2021);
						// swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
						swagDialogue.sounds = [
							FlxG.sound.load(Paths.sound(Perkedel.NULL_DIALOGUE_SOUND_PATHS[0]), Perkedel.NULL_DIALOGUE_SOUND_VOLUME)
						];
						if (handoverDad.dialogueChatSoundPaths != null && handoverDad.dialogueChatSoundPaths.length > 0)
						{
							for (i in handoverDad.dialogueChatSoundPaths)
							{
								swagDialogue.sounds.push(FlxG.sound.load(Paths.sound(i), handoverDad.dialogueChatSoundVolume));
							}
						}

						// swagDialogue.sounds = handoverDad.dialogueChatSoundPaths != null
						// 	&& handoverDad.dialogueChatSoundPaths.length > 0 ? (for (i in 0...handoverDad.dialogueChatSoundPaths.length)
						// 	{
						// 		FlxG.sound.load(Paths.sound(handoverDad.dialogueChatSoundPaths[i]),
						// 			handoverDad.dialogueChatSoundVolume != null ? handoverDad.dialogueChatSoundVolume : 0.6);
						// 	}) : [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
				}
			case 'bf':
				// JOELwindows7: YEY the prefix
				// prefixBf = PlayState.SONG.player1.toUpperCase();
				prefixBf = PlayState.boyfriend.displayName;
				// TODO: JOELwindows7: use name field, not ID field
				swagDialogue.prefix = prefixBf + ": ";
				portraitLeft.visible = false;
				portraitMiddle.visible = false;
				if (!portraitRight.visible)
				{
					portraitRight.visible = true;
					portraitRight.animation.play('enter'); // JOELwindows7: always play now. nvm.
				}
				switch (PlayState.SONG.player1.toLowerCase())
				{ // JOELwindows7: HAHA! different character sound go brrrrr!!!
					// case 'bf-covid':
					// 	// JOELwindows7: reconvert to regular name
					// 	prefixBf = 'Boyfriend';
					// 	swagDialogue.prefix = prefixBf + ": ";
					// case 'gf-covid':
					// 	// JOELwindows7: reconvert to regular name
					// 	prefixBf = 'Girlfriend';
					// 	swagDialogue.prefix = prefixBf + ": ";
					// case 'gf-ht':
					// 	// JOELwindows7: idk what's the name of this TV
					// 	prefixBf = 'Television';
					// 	swagDialogue.prefix = prefixBf + ": ";
					case 'hookx' | 'hookx-legacy':
						dropText.font = 'Ubuntu Bold';
						swagDialogue.font = 'Ubuntu Bold';
						dropText.color = 0xFF7d00bf;
						swagDialogue.color = 0xFF055bff;
						swagDialogue.sounds = [
							FlxG.sound.load(Paths.sound('textSpeak/hookx/talk1'), 0.6),
							FlxG.sound.load(Paths.sound('textSpeak/hookx/talk2'), 0.6),
							FlxG.sound.load(Paths.sound('textSpeak/hookx/talk3'), 0.6),
						];
					case 'bf-pixel' | 'senpai' | 'senpai-mad' | 'senpai-angry':
						// somehow color bug with pixel font
						dropText.font = 'Pixel Arial 11 Bold';
						swagDialogue.font = 'Pixel Arial 11 Bold';
						dropText.color = 0xFFD89494;
						swagDialogue.color = 0xFF3F2021;
						swagDialogue.sounds = [
							FlxG.sound.load(Paths.sound(Perkedel.NULL_DIALOGUE_SOUND_PATHS[0]), Perkedel.NULL_DIALOGUE_SOUND_VOLUME)
						];
						if (handoverBf.dialogueChatSoundPaths != null && handoverBf.dialogueChatSoundPaths.length > 0)
						{
							for (i in handoverBf.dialogueChatSoundPaths)
							{
								swagDialogue.sounds.push(FlxG.sound.load(Paths.sound(i), handoverBf.dialogueChatSoundVolume));
							}
						}
					default:
						// dropText.font = 'Pixel Arial 11 Bold';
						// swagDialogue.font = 'Pixel Arial 11 Bold';
						// dropText.color = FlxColor.fromInt(0xFFD89494);
						// swagDialogue.color = FlxColor.fromInt(0xFF3F2021);
						// swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
						dropText.font = handoverBf.fontDrop != null
							&& handoverBf.fontDrop != '' ? handoverBf.fontDrop : 'Pixel Arial 11 Bold';
						swagDialogue.font = handoverBf.font != null && handoverBf.font != '' ? handoverBf.font : 'Pixel Arial 11 Bold';
						dropText.color = handoverBf.fontColorDrop != null
							&& handoverBf.fontColorDrop != '' ? FlxColor.fromString(handoverBf.fontColorDrop) : FlxColor.fromInt(0xFFD89494);
						swagDialogue.color = handoverBf.fontColor != null
							&& handoverBf.fontColor != '' ? FlxColor.fromString(handoverBf.fontColor) : FlxColor.fromInt(0xFF3F2021);
						swagDialogue.sounds = [
							FlxG.sound.load(Paths.sound(Perkedel.NULL_DIALOGUE_SOUND_PATHS[0]), Perkedel.NULL_DIALOGUE_SOUND_VOLUME)
						];
						if (handoverBf.dialogueChatSoundPaths != null && handoverBf.dialogueChatSoundPaths.length > 0)
						{
							for (i in handoverBf.dialogueChatSoundPaths)
							{
								swagDialogue.sounds.push(FlxG.sound.load(Paths.sound(i), handoverBf.dialogueChatSoundVolume));
							}
						}
				}
			case 'gf':
				// JOELwindows7: YEY prefix
				// prefixGf = PlayState.SONG.gfVersion.toUpperCase();
				prefixGf = PlayState.gf.displayName;
				swagDialogue.prefix = prefixGf + ": ";
				portraitRight.visible = false;
				portraitLeft.visible = false;
				if (!portraitMiddle.visible)
				{
					portraitMiddle.visible = true;
					portraitMiddle.animation.play('enter');
				}
				switch (PlayState.SONG.gfVersion.toLowerCase())
				{ // JOELwindows7: HAHA! different character sound go brrrrr!!!
					// case 'bf-covid':
					// 	// JOELwindows7: reconvert to regular name
					// 	prefixGf = 'Boyfriend';
					// 	swagDialogue.prefix = prefixGf + ": ";
					// case 'gf-covid':
					// 	// JOELwindows7: reconvert to regular name
					// 	prefixDad = 'Girlfriend';
					// 	swagDialogue.prefix = prefixGf + ": ";
					// case 'gf-ht':
					// 	// JOELwindows7: idk what's the name of this TV
					// 	prefixGf = 'Television';
					// 	swagDialogue.prefix = prefixGf + ": ";
					default:
						// dropText.font = 'Pixel Arial 11 Bold';
						// swagDialogue.font = 'Pixel Arial 11 Bold';
						// dropText.color = FlxColor.fromInt(0xFFD89494);
						// swagDialogue.color = FlxColor.fromInt(0xFF3F2021);
						// swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
						dropText.font = handoverGf.fontDrop != null
							&& handoverGf.fontDrop != '' ? handoverBf.fontDrop : 'Pixel Arial 11 Bold';
						swagDialogue.font = handoverGf.font != null && handoverGf.font != '' ? handoverGf.font : 'Pixel Arial 11 Bold';
						dropText.color = handoverGf.fontColorDrop != null
							&& handoverGf.fontColorDrop != '' ? FlxColor.fromString(handoverGf.fontColorDrop) : FlxColor.fromInt(0xFFD89494);
						swagDialogue.color = handoverGf.fontColor != null
							&& handoverGf.fontColor != '' ? FlxColor.fromString(handoverGf.fontColor) : FlxColor.fromInt(0xFF3F2021);
						swagDialogue.sounds = [
							FlxG.sound.load(Paths.sound(Perkedel.NULL_DIALOGUE_SOUND_PATHS[0]), Perkedel.NULL_DIALOGUE_SOUND_VOLUME)
						];
						if (handoverGf.dialogueChatSoundPaths != null && handoverGf.dialogueChatSoundPaths.length > 0)
						{
							for (i in handoverGf.dialogueChatSoundPaths)
							{
								swagDialogue.sounds.push(FlxG.sound.load(Paths.sound(i), handoverGf.dialogueChatSoundVolume));
							}
						}
				}
			// JOELwindows7: extra for bbpanzu's vs. Sky
			case 'dad_happy':
				portraitRight.visible = false;
				portraitB.visible = false;
				portraitD.visible = false;
				if (!portraitDD.visible)
				{
					portraitDD.visible = true;
				}
				portraitDD.animation.play('enter', true);

				dropText.font = handoverDad.fontDrop != null && handoverDad.fontDrop != '' ? handoverDad.fontDrop : 'Pixel Arial 11 Bold';
				swagDialogue.font = handoverDad.font != null && handoverDad.font != '' ? handoverDad.font : 'Pixel Arial 11 Bold';
				dropText.color = handoverDad.fontColorDrop != null
					&& handoverDad.fontColorDrop != '' ? FlxColor.fromString(handoverDad.fontColorDrop) : FlxColor.fromInt(0xFFD89494);
				swagDialogue.color = handoverDad.fontColor != null
					&& handoverDad.fontColor != '' ? FlxColor.fromString(handoverDad.fontColor) : FlxColor.fromInt(0xFF3F2021);
				// swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
				swagDialogue.sounds = [
					FlxG.sound.load(Paths.sound(Perkedel.NULL_DIALOGUE_SOUND_PATHS[0]), Perkedel.NULL_DIALOGUE_SOUND_VOLUME)
				];
				if (handoverDad.dialogueChatSoundPaths != null && handoverDad.dialogueChatSoundPaths.length > 0)
				{
					for (i in handoverDad.dialogueChatSoundPaths)
					{
						swagDialogue.sounds.push(FlxG.sound.load(Paths.sound(i), handoverDad.dialogueChatSoundVolume));
					}
				}
			case 'dadd':
				portraitRight.visible = false;
				portraitB.visible = false;
				portraitDD.visible = false;
				if (!portraitD.visible)
				{
					portraitD.visible = true;
				}
				portraitD.animation.play('enter', true);

				dropText.font = handoverDad.fontDrop != null && handoverDad.fontDrop != '' ? handoverDad.fontDrop : 'Pixel Arial 11 Bold';
				swagDialogue.font = handoverDad.font != null && handoverDad.font != '' ? handoverDad.font : 'Pixel Arial 11 Bold';
				dropText.color = handoverDad.fontColorDrop != null
					&& handoverDad.fontColorDrop != '' ? FlxColor.fromString(handoverDad.fontColorDrop) : FlxColor.fromInt(0xFFD89494);
				swagDialogue.color = handoverDad.fontColor != null
					&& handoverDad.fontColor != '' ? FlxColor.fromString(handoverDad.fontColor) : FlxColor.fromInt(0xFF3F2021);
				// swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
				swagDialogue.sounds = [
					FlxG.sound.load(Paths.sound(Perkedel.NULL_DIALOGUE_SOUND_PATHS[0]), Perkedel.NULL_DIALOGUE_SOUND_VOLUME)
				];
				if (handoverDad.dialogueChatSoundPaths != null && handoverDad.dialogueChatSoundPaths.length > 0)
				{
					for (i in handoverDad.dialogueChatSoundPaths)
					{
						swagDialogue.sounds.push(FlxG.sound.load(Paths.sound(i), handoverDad.dialogueChatSoundVolume));
					}
				}
			case 'boyf':
				portraitLeft.visible = false;
				portraitRight.visible = false;
				portraitD.visible = false;
				portraitDD.visible = false;
				if (!portraitB.visible)
				{
					portraitB.visible = true;
				}
				portraitB.animation.play('enter', true);

				dropText.font = handoverBf.fontDrop != null && handoverBf.fontDrop != '' ? handoverBf.fontDrop : 'Pixel Arial 11 Bold';
				swagDialogue.font = handoverBf.font != null && handoverBf.font != '' ? handoverBf.font : 'Pixel Arial 11 Bold';
				dropText.color = handoverBf.fontColorDrop != null
					&& handoverBf.fontColorDrop != '' ? FlxColor.fromString(handoverBf.fontColorDrop) : FlxColor.fromInt(0xFFD89494);
				swagDialogue.color = handoverBf.fontColor != null
					&& handoverBf.fontColor != '' ? FlxColor.fromString(handoverBf.fontColor) : FlxColor.fromInt(0xFF3F2021);
				swagDialogue.sounds = [
					FlxG.sound.load(Paths.sound(Perkedel.NULL_DIALOGUE_SOUND_PATHS[0]), Perkedel.NULL_DIALOGUE_SOUND_VOLUME)
				];
				if (handoverBf.dialogueChatSoundPaths != null && handoverBf.dialogueChatSoundPaths.length > 0)
				{
					for (i in handoverBf.dialogueChatSoundPaths)
					{
						swagDialogue.sounds.push(FlxG.sound.load(Paths.sound(i), handoverBf.dialogueChatSoundVolume));
					}
				}
			case 'gffu':
				portraitLeft.visible = false;
				portraitB.visible = false;
				portraitD.visible = false;
				portraitDD.visible = false;
				if (!portraitRight.visible)
				{
					portraitRight.visible = true;
				}
				portraitRight.animation.play('fuckyou', true);

				dropText.font = handoverGf.fontDrop != null && handoverGf.fontDrop != '' ? handoverBf.fontDrop : 'Pixel Arial 11 Bold';
				swagDialogue.font = handoverGf.font != null && handoverGf.font != '' ? handoverGf.font : 'Pixel Arial 11 Bold';
				dropText.color = handoverGf.fontColorDrop != null
					&& handoverGf.fontColorDrop != '' ? FlxColor.fromString(handoverGf.fontColorDrop) : FlxColor.fromInt(0xFFD89494);
				swagDialogue.color = handoverGf.fontColor != null
					&& handoverGf.fontColor != '' ? FlxColor.fromString(handoverGf.fontColor) : FlxColor.fromInt(0xFF3F2021);
				swagDialogue.sounds = [
					FlxG.sound.load(Paths.sound(Perkedel.NULL_DIALOGUE_SOUND_PATHS[0]), Perkedel.NULL_DIALOGUE_SOUND_VOLUME)
				];
				if (handoverGf.dialogueChatSoundPaths != null && handoverGf.dialogueChatSoundPaths.length > 0)
				{
					for (i in handoverGf.dialogueChatSoundPaths)
					{
						swagDialogue.sounds.push(FlxG.sound.load(Paths.sound(i), handoverGf.dialogueChatSoundVolume));
					}
				}
			// end of bbpanzu's vs. Sky
			default:
				// JOELwindows7: use character folder image fully instead
				// initiatePortraitCustom();
				swagDialogue.prefix = curCharacter + ": ";
				portraitRight.visible = false;
				portraitLeft.visible = false;
				portraitMiddle.visible = false;
		}
		swagDialogue.width = Std.int(FlxG.width * .6); // JOELwindows7: don't forget to refresh the width!

		// JOELwindows7: then execute the function for the modchart
		if (PlayState.instance != null)
			PlayState.instance.dialogueNext(counterEH);
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1];
		dialogueList[0] = dialogueList[0].substr(splitName[1].length + 2).trim();
	}

	// JOELwindows7: seriously.
	var haveClicked:Bool = false;

	function manageMouse()
	{
		if (FlxG.mouse.overlaps(box))
		{
			// JOELwindows7: only if not doing something in autoclick parameter or skip button
			if (!(FlxG.mouse.overlaps(skipButton)
				|| FlxG.mouse.overlaps(autoClickDelayLabel)
				|| FlxG.mouse.overlaps(autoClickDelayStepper)
				|| FlxG.mouse.overlaps(autoClickCheckbox)))
			{
				if (FlxG.mouse.justPressed)
				{
					haveClicked = true;
				}
			}
		}
	}

	// JOELwindows7: clear all portraits out the visibility
	function invisiblizePortraits()
	{
		if (portraitRight != null)
			portraitRight.visible = false;
		if (portraitLeft != null)
			portraitLeft.visible = false;
		if (portraitMiddle != null)
			portraitMiddle.visible = false;
		if (portraitB != null)
			portraitB.visible = false;
		if (portraitD != null)
			portraitD.visible = false;
		if (portraitDD != null)
			portraitDD.visible = false;
	}

	// JOELwindows7: check autoclick
	function checkAutoClick(handoverCheck:Bool)
	{
		if (handoverCheck)
		{
			autoClickTimer.start(autoClickDelayStepper.value, function(tmr:FlxTimer)
			{
				tobeAutoClicked = true;
			});
		}
		else
		{
			autoClickTimer.cancel();
		}
	}

	// JOELwindows7: swagDialogue finish typing
	function swagDialogueOnComplete()
	{
		// JOELwindows7: check autoclick
		if (autoClickCheckbox.checked)
		{
			autoClickTimer.start(autoClickDelayStepper.value, function(tmr:FlxTimer)
			{
				tobeAutoClicked = true;
			});
		}
		else
		{
		}
	}
}
