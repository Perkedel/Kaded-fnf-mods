package;

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

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;

	var curCharacter:String = '';

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	var dropText:FlxText;

	//public var finishThing:Void->Void;
	public var finishThing:Void->Void;

	var portraitLeft:FlxSprite;
	var portraitRight:FlxSprite;
	var portraitMiddle:FlxSprite; //JOELwindows7: for gf

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;

	//JOELwindows7: heuristic flag for non-pixel level
	var nonPixel:Bool = false;

	//JOELwindows7: heuristic flag for character that is not default Senpai
	var customCharPls:Bool = false;
	var customBfPls:Bool = false;
	var customGfPls:Bool = false;

	//JOELwindows7: own FlxSound because generate song destroyed the intro music
	var sound:FlxSound;

	public function new(
		talkingRight:Bool = true, 
		?dialogueList:Array<String>, 
		?isEpilogue:Bool = false,
		?hadChat:Bool = false, 
		?customChar:Bool = false, 
		?customCharXML:String = "jakartaFair/Hookx-dialogueAppear",
		?customCharFrame:String = "enter",
		?customCharPrefix:String = "Hookx Portrait Enter"
		)
	{
		super();

		//JOELwindows7: not my code. but what the?! refer other class without import?! NO NEED TO POINT THE INSTANCE TOO?!
		// whoah! in Flutter, I have to import. even when they're next to it! wow! Haxe is great!!!
		// AND THE PECK?! in Unity, I must point also the instance inside the class 
		// (just to grab its current value of a variable right now), not just the class itself. hoof! I am jealous!
		if(!isEpilogue)
		{
			switch (PlayState.SONG.song.toLowerCase())
			{
				case 'senpai':
					sound = new FlxSound().loadEmbedded(Paths.music('Lunchbox'),true);
					sound.volume = 0;
					FlxG.sound.list.add(sound);
					sound.fadeIn(1, 0, 0.8);
				case 'thorns':
					sound = new FlxSound().loadEmbedded(Paths.music('LunchboxScary'),true);
					sound.volume = 0;
					FlxG.sound.list.add(sound);
					sound.fadeIn(1, 0, 0.8);
				case 'senpai-midi':
					trace("Hey play lunchbox now");
					// FlxG.sound.playMusic(Paths.music('Lunchbox-midi'), 0);
					// FlxG.sound.music.fadeIn(1, 0.1, 0.8);
					// DialogueBox.ownIntroMusic = new FlxSound().loadEmbedded(Paths.music('Lunchbox-midi'));
					sound = new FlxSound().loadEmbedded(Paths.music('Lunchbox-midi'),true);
					sound.volume = 0;
					FlxG.sound.list.add(sound);
					sound.fadeIn(1, 0, 0.8);
				case 'thorns-midi':
					// FlxG.sound.playMusic(Paths.music('LunchboxScary-midi'), 0);
					// FlxG.sound.music.fadeIn(1, 0.1, 0.8);
					// DialogueBox.ownIntroMusic = new FlxSound().loadEmbedded(Paths.music('LunchboxScary-midi'));
					sound = new FlxSound().loadEmbedded(Paths.music('LunchboxScary-midi'),true);
					sound.volume = 0;
					FlxG.sound.list.add(sound);
					sound.fadeIn(1, 0, 0.8);
				default:
					// DialogueBox.ownIntroMusic = new FlxSound();
					trace("No pre-dialog sound to play!");
			}
		} else {
			sound = new FlxSound();
		}

		//JOELwindows7: because generate song destroyed the music.
		// DialogueBox.ownIntroMusic.volume = 0;
		// DialogueBox.ownIntroMusic.fadeIn(1, 0.1, 0.8);
		// FlxG.sound.list.add(ownIntroMusic);
		// DialogueBox.ownIntroMusic.play();

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);

		new FlxTimer().start(0.83, function(tmr:FlxTimer)
		{
			bgFade.alpha += (1 / 5) * 0.7;
			if (bgFade.alpha > 0.7)
				bgFade.alpha = 0.7;
		}, 5);

		box = new FlxSprite(-20, 45);
		
		var hasDialog = false;
		trace("song is: " + PlayState.SONG.song.toLowerCase() + " so pls check dialog!");
		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'senpai' | 'senpai-midi':
				//JOELwindows7: pls add week 6 library makering.
				//it seems the lime confused between main weeb and week special weeb folder
				//or try to remove weeb and add week6 in here
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

				var face:FlxSprite = new FlxSprite(320, 170).loadGraphic(Paths.image('weeb/spiritFaceForward', 'week6'));
				face.setGraphicSize(Std.int(face.width * 6));
				add(face);
			
			case 'windfall' | 
				'rule the world' | 
				'well meet again' | 
				'getting-freaky' |
				'breakfast' |
				'dont stop' |
				'title classic' |
				'test-vanilla'
				:
				//JOELwindows7: the dialogue normalizations
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('speech_bubble_talking');
				box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
				box.animation.addByIndices('normal', 'speech bubble normal', [4], "", 24);

				nonPixel = true;

				customCharPls = true;
				initiatePortraitLeft(-20,40,0.9,'jakartaFair/Hookx-dialogueAppear','enter','Hookx Portrait Enter');
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

				if(customChar){
					customCharPls = true;
					initiatePortraitLeft(-20,40,0.9,
						customCharXML,
						customCharFrame,
						customCharPrefix
						);
				}
		}

		this.dialogueList = dialogueList;
		
		if (!hasDialog){
			trace("yeah no dialog.");
			return;
		}
		else
			trace("You should have dialog man");
		
		//JOELwindows7: doned the heuristic sort of
		//for dad player
		if(!customCharPls)
		{
			portraitLeft = new FlxSprite(-20, 40);
			portraitLeft.frames = Paths.getSparrowAtlas('weeb/senpaiPortrait', 'week6');
			portraitLeft.animation.addByPrefix('enter', 'Senpai Portrait Enter', 24, false);
			portraitLeft.setGraphicSize(Std.int(portraitLeft.width * PlayState.daPixelZoom * 0.9));
			portraitLeft.updateHitbox();
			portraitLeft.scrollFactor.set();
			add(portraitLeft);
			portraitLeft.visible = false;
		}

		//For BF too as well
		if(!customBfPls)
		{
			portraitRight = new FlxSprite(0, 40);
			portraitRight.frames = Paths.getSparrowAtlas('weeb/bfPortrait', 'week6');
			portraitRight.animation.addByPrefix('enter', 'Boyfriend portrait enter', 24, false);
			portraitRight.setGraphicSize(Std.int(portraitRight.width * PlayState.daPixelZoom * 0.9));
			portraitRight.updateHitbox();
			portraitRight.scrollFactor.set();
			add(portraitRight);
			portraitRight.visible = false;
		}
		
		//last but not least the bf
		if(!customGfPls){
			portraitMiddle = new FlxSprite(0, 40);
			portraitMiddle.frames = Paths.getSparrowAtlas('weeb/gfPortrait', 'shared');
			portraitMiddle.animation.addByPrefix('enter', 'Girlfriend portrait enter', 24, false);
			portraitMiddle.setGraphicSize(Std.int(portraitMiddle.width * PlayState.daPixelZoom * 0.9));
			portraitMiddle.updateHitbox();
			portraitMiddle.scrollFactor.set();
			add(portraitMiddle);
			portraitMiddle.visible = false;
		}

		//JOELwindows7: I've added a heuristic to size width accordingly between nonPixel and pixel level.
		box.animation.play('normalOpen');
		if(nonPixel)
			{
				box.setPosition(FlxG.width * .5,FlxG.height - 300); //correct shoot is 300 behind screen height
				box.setGraphicSize(Std.int(box.width * 0.9)); // JOELwindows7: copy from original without daPixelZoom value!
			}
		else
			{
				box.setPosition(FlxG.width * .5,FlxG.height - 690); //correct shoot is 690 behind screen height
				//JOELwindows7: it was 20 behind screen height
				//ok ladies and gentlemen. how in the world did we overshot that?
				//it wasn't like that before, and the same 20 behind screen height was fine!
				// who Haxe part fault this is?
				box.setGraphicSize(Std.int(box.width * PlayState.daPixelZoom * 0.9));
			}
		box.updateHitbox();
		add(box);

		box.screenCenter(X);
		portraitLeft.screenCenter(X);

		handSelect = new FlxSprite(FlxG.width * 0.9, FlxG.height * 0.9).loadGraphic(Paths.image('weeb/pixelUI/hand_textbox', 'week6'));
		add(handSelect);


		if (!talkingRight)
		{
			// box.flipX = true;
		}

		dropText = new FlxText(242, 502, Std.int(FlxG.width * 0.6), "", 32);
		dropText.font = 'Pixel Arial 11 Bold';
		dropText.color = 0xFFD89494;
		add(dropText);

		swagDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.6), "", 32);
		swagDialogue.font = 'Pixel Arial 11 Bold';
		swagDialogue.color = 0xFF3F2021;
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
		add(swagDialogue);

		dialogue = new Alphabet(0, 80, "", false, true);
		// dialogue.x = 90;
		// add(dialogue);
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{
		// HARD CODING CUZ IM STUPDI
		if (PlayState.SONG.song.toLowerCase() == 'roses' || PlayState.SONG.song.toLowerCase() == 'roses-midi')
			portraitLeft.visible = false;
		if (PlayState.SONG.song.toLowerCase() == 'thorns' || PlayState.SONG.song.toLowerCase() == 'thorns-midi')
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

		//JOELwindows7: add mouse click t continue
		if ((PlayerSettings.player1.controls.ACCEPT || FlxG.mouse.justPressed) && dialogueStarted == true)
		{
			remove(dialogue);
				
			FlxG.sound.play(Paths.sound('clickText'), 0.8);

			if (dialogueList[1] == null && dialogueList[0] != null)
			{
				if (!isEnding)
				{
					isEnding = true;

					if (PlayState.SONG.song.toLowerCase() == 'senpai' || PlayState.SONG.song.toLowerCase() == 'thorns' 
						|| PlayState.SONG.song.toLowerCase() == 'senpai-midi' || PlayState.SONG.song.toLowerCase() == 'thorns-midi')
						sound.fadeOut(2.2, 0);

					//JOELwindows7: Do this after that music faded out
					new FlxTimer().start(2.2, function(tmr:FlxTimer) {
						sound.stop();
					});
					
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
				dialogueList.remove(dialogueList[0]);
				startDialogue();
			}
		}
		
		super.update(elapsed);
	}

	var isEnding:Bool = false;

	//JOELwindows7: let's just put some part of module as a function shall we?
	function initiatePortraitLeft(newSpriteX:Int = -20, newSpriteY:Int = 40, zooming:Float = 0.9, textureXmlPath:String = 'weeb/senpaiPortrait', name:String = 'enter', prefix:String = 'Senpai Portrait Enter', frameRate:Int = 24, flip:Bool = false):Void
	{
		portraitLeft = new FlxSprite(newSpriteX, newSpriteY);
		portraitLeft.frames = Paths.getSparrowAtlas(textureXmlPath);
		portraitLeft.animation.addByPrefix(name, prefix, frameRate, flip);
		portraitLeft.setGraphicSize(Std.int(portraitLeft.width * PlayState.daPixelZoom * zooming));
		portraitLeft.updateHitbox();
		portraitLeft.scrollFactor.set();
		add(portraitLeft);
		portraitLeft.visible = false;
	}

	//JOELwindows7: same for the bf too
	function initiatePortraitRight(newSpriteX:Int = -20, newSpriteY:Int = 40, zooming:Float = 0.9, textureXmlPath:String = 'weeb/bfPortrait', name:String = 'enter', prefix:String = 'Boyfriend portrait Enter', frameRate:Int = 24, flip:Bool = false):Void
	{
		portraitRight = new FlxSprite(0, 40);
		portraitRight.frames = Paths.getSparrowAtlas(textureXmlPath);
		portraitRight.animation.addByPrefix(name, prefix, frameRate, flip);
		portraitRight.setGraphicSize(Std.int(portraitRight.width * PlayState.daPixelZoom * zooming));
		portraitRight.updateHitbox();
		portraitRight.scrollFactor.set();
		add(portraitRight);
		portraitRight.visible = false;
	}

	function startDialogue():Void
	{
		cleanDialog();
		// var theDialog:Alphabet = new Alphabet(0, 70, dialogueList[0], false, true);
		// dialogue = theDialog;
		// add(theDialog);

		// swagDialogue.text = ;
		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.start(0.04, true);

		switch (curCharacter)
		{
			case 'dad':
				portraitRight.visible = false;
				portraitMiddle.visible = false;
				if (!portraitLeft.visible)
				{
					portraitLeft.visible = true;
					portraitLeft.animation.play('enter');
				}
			case 'bf':
				portraitLeft.visible = false;
				portraitMiddle.visible = false;
				if (!portraitRight.visible)
				{
					portraitRight.visible = true;
					portraitRight.animation.play('enter');
				}
			case 'gf':
				portraitRight.visible = false;
				portraitLeft.visible = false;
				if (!portraitMiddle.visible)
				{
					portraitMiddle.visible = true;
					portraitMiddle.animation.play('enter');
				}
		}
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1];
		dialogueList[0] = dialogueList[0].substr(splitName[1].length + 2).trim();
	}
}
