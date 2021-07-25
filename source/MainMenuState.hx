package;

import flixel.ui.FlxSpriteButton;
import flixel.ui.FlxButton;
import flixel.addons.display.FlxExtendedSprite;
import flixel.input.gamepad.FlxGamepad;
import Controls.KeyboardScheme;
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
import flixel.util.FlxTimer;
#if newgrounds
import io.newgrounds.NG;
#end
import lime.app.Application;

#if (windows && cpp)
import Discord.DiscordClient;
#end

using StringTools;

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;
	//JOELwindows7: which clicked & have they clicked.
	var curClicked:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	#if !switch
	var optionShit:Array<String> = ['story mode', 'freeplay', 'donate', 'options'];
	#else
	var optionShit:Array<String> = ['story mode', 'freeplay'];
	#end

	var newGaming:FlxText;
	var newGaming2:FlxText;
	public static var firstStart:Bool = true;

	public static var nightly:String = "";
	public static var larutMalam:String = ""; //JOELwindows7: Last Funkin Nightly mark

	public static var kadeEngineVer:String = "1.6" + nightly;
	public static var gameVer:String = "0.2.7.1";
	public static var lastFunkinMomentVer:String = "2021.07.160" + larutMalam; //JOELwindows7: last funkin moments version
	public static var yourModVer:String = "0.0.0.0"; //JOELwindows7: your own mod version

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	public static var finishedFunnyMove:Bool = false;

	override function create()
	{
		

		#if (windows && cpp)
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.10;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		if(FlxG.save.data.antialiasing)
			{
				bg.antialiasing = true;
			}
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0.10;
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		if(FlxG.save.data.antialiasing)
			{
				magenta.antialiasing = true;
			}
		magenta.color = 0xFFfd719b;
		add(magenta);
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('FNF_main_menu_assets');

		//JOELwindows7: add back button
		addBackButton(10, FlxG.height + 100);
		//backButton.screenCenter(X);
		backButton.scrollFactor.set();

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, FlxG.height * 1.6);
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			if(FlxG.save.data.antialiasing)
				{
					menuItem.antialiasing = true;
				}
			if (firstStart)
			{
				FlxTween.tween(menuItem,{y: 60 + (i * 160)},1 + (i * 0.25) ,{ease: FlxEase.expoInOut, onComplete: function(flxTween:FlxTween) 
					{ 
						finishedFunnyMove = true; 
						changeItem();
					}});
				
			}
			else
			{
				menuItem.y = 60 + (i * 160);
				
			}
		}

		//JOELwindows7: back button swiaush
		if(firstStart){
			FlxTween.tween(backButton,{y: FlxG.height - 150},{ease: FlxEase.expoInOut});
		} else {
			backButton.y = FlxG.height - 150;
		}

		firstStart = false;

		FlxG.camera.follow(camFollow, null, 0.60 * (60 / FlxG.save.data.fpsCap));

		//JOELwindows7: hard code our download link in case illegally reuploaded no matter what sign given
		//we also covered both Kade Engine and the vanilla itself
		var reuploadEdgeCase:FlxText = new FlxText(5, FlxG.height - 72, 0, "Download Last Funkin Moments for free $0 legit on https://github.com/Perkedel/kaded-fnf-mods,\noriginal Kade Engine at https://github.com/KadeDev/Kade-Engine,\nand vanilla Funkin at https://github.com/ninjamuffin99/Funkin .\nplay vanilla Funkin at https://www.newgrounds.com/portal/view/770371\n", 12);
		reuploadEdgeCase.scrollFactor.set();
		reuploadEdgeCase.setFormat("VCR OSD Mono", 12, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(reuploadEdgeCase);
		//Kade, ninja, you should do that too. follow this example!
		//also somehow at the end of the paragraph above, you must `\n` it at the very end. idk why, but that's the workaround
		//so the last line of text also shows.

		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, gameVer +  (Main.watermarks ? " FNF - " + kadeEngineVer + " Kade Engine" : "") + (Main.perkedelMark ? " Perkedel Mod v" + lastFunkinMomentVer : ""), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();


		if (FlxG.save.data.dfjk)
			controls.setKeyboardScheme(KeyboardScheme.Solo, true);
		else
			controls.setKeyboardScheme(KeyboardScheme.Duo(true), true);

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!selectedSomethin)
		{
			//JOELwindows7: make mouse visible when moved.
			if(FlxG.mouse.justMoved){
				//trace("mouse moved");
				FlxG.mouse.visible = true;
			}
			//JOELwindows7: detect any keypresses or any button presses
			if(FlxG.keys.justPressed.ANY){
				//lmao! inspire from GameOverState.hx!
				FlxG.mouse.visible = false;
			}
			if(FlxG.gamepads.lastActive != null){
				if(FlxG.gamepads.lastActive.justPressed.ANY){
					FlxG.mouse.visible = false;
				}
				//peck this I'm tired! plns work lol
			}
			
			var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

			if (gamepad != null)
			{
				if (gamepad.justPressed.DPAD_UP)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeItem(-1);
				}
				if (gamepad.justPressed.DPAD_DOWN)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeItem(1);
				}
			}

			//JOELwindows7: attempt add mouse support kinda..
			if (FlxG.keys.justPressed.UP)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (FlxG.keys.justPressed.DOWN)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK || haveBacked)
			{
				FlxG.switchState(new TitleState());

				haveBacked = false;
			}

			if (controls.ACCEPT || haveClicked)
			{
				if (optionShit[curSelected] == 'donate')
				{
					FlxG.sound.play(Paths.sound('confirmMenu')); // JOELwindows7: hey, pls don't forget the confirm sound for Kickstarter go to one also!
					fancyOpenURL("https://ninja-muffin24.itch.io/funkin");
				}
				else
				{
					FlxG.mouse.visible = false;
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));
					
					if (FlxG.save.data.flashing)
						FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 1.3, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							if (FlxG.save.data.flashing)
							{
								FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
								{
									goToState();
								});
							}
							else
							{
								new FlxTimer().start(1, function(tmr:FlxTimer)
								{
									goToState();
								});
							}
						}
					});

					//JOELwindows7: also for the back button fade
					FlxTween.tween(backButton,{alpha:0},1.3,{ease:FlxEase.quadOut, onComplete: function(twn:FlxTween){
						backButton.kill();
					}});
				}
				//JOELwindows7: have clicked refalsing after done.
				haveClicked = false;
			}
			
			
		}

		super.update(elapsed);

		//JOELwindows7: not my code, but this one is important!
		//do this all time to center the spr every single time!
		menuItems.forEach(function(spr:FlxSprite)
		{
			//JOELwindows7: itterate sprite menu items overlaps and click functions
			if(!selectedSomethin && FlxG.mouse.visible && finishedFunnyMove){
				if(FlxG.mouse.overlaps(spr) && !FlxG.mouse.overlaps(backButton)){
					if(curSelected != spr.ID){
						FlxG.sound.play(Paths.sound('scrollMenu'));
						goToItem(spr.ID);
					}
					if(FlxG.mouse.justPressed){
						trace("mouse clicked on " + Std.string(curSelected) + ". " + optionShit[curSelected]);
						haveClicked = true;
					}
				}

				if(FlxG.mouse.overlaps(backButton) && !FlxG.mouse.overlaps(spr)){
					if(FlxG.mouse.justPressed){
						if(!haveBacked) {
							haveBacked = true;
						}
					}
				}
			}
			
			spr.screenCenter(X);
		});
	}
	
	function goToState()
	{
		var daChoice:String = optionShit[curSelected];

		switch (daChoice)
		{
			case 'story mode':
				FlxG.switchState(new StoryMenuState());
				trace("Story Menu Selected");
			case 'freeplay':
				FlxG.switchState(new FreeplayState());

				trace("Freeplay Menu Selected");

			case 'options':
				FlxG.switchState(new OptionsMenu());
		}
	}

	function changeItem(huh:Int = 0)
	{
		if (finishedFunnyMove)
		{
			curSelected += huh;

			if (curSelected >= menuItems.length)
				curSelected = 0;
			if (curSelected < 0)
				curSelected = menuItems.length - 1;
		}
		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected && finishedFunnyMove)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			spr.updateHitbox();
		});
	}

	//JOELwindows7: go to item for hover mouse
	//copy from above but the curSelected is set value instead
	function goToItem(huh:Int = 0){

		if(finishedFunnyMove)
		{
			curSelected = huh;

			if (curSelected >= menuItems.length)
				curSelected = 0;
			if (curSelected < 0)
				curSelected = menuItems.length - 1;
		}
		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected && finishedFunnyMove)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			spr.updateHitbox();
		});
	}
}
