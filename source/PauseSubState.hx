package;

import flixel.input.gamepad.FlxGamepad;
import openfl.Lib;
#if (windows && cpp)
import llua.Lua;
#end
import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Exit to menu'];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var perSongOffset:FlxText;
	
	var offsetChanged:Bool = false;

	public function new(x:Float, y:Float)
	{
		super();

		if (PlayState.instance.useVideo)
		{
			menuItems.remove("Resume");
			if (GlobalVideo.get().playing)
				GlobalVideo.get().pause();
		}

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyFromInt(PlayState.storyDifficulty).toUpperCase();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);
		perSongOffset = new FlxText(5, FlxG.height - 18, 0, "Additive Offset (Left, Right): " + PlayState.songOffset + " - Description - " + 'Adds value to global offset, per song.', 12);
		perSongOffset.scrollFactor.set();
		perSongOffset.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		
		#if cpp
			add(perSongOffset);
		#end

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.scrollFactor.set(); //JOELwindows7: don't forget to zero the scrollfactor so the hover point doesn't scroll with camera it.
			//JOELwindows7: where the peck is zoom factor?!?
			songText.targetY = i;
			songText.ID = i; //JOELwindows7: ID each menu item to compare with current selected
			//songText.updateHitbox(); //JOELwindows7: not necessary, this can mess touch mouse support
			grpMenuShit.add(songText);
			trace("add menu " + Std.string(songText.ID) + ". " + songText.text); //JOELwindows7: cmon what happened
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		//JOELwindows7: button desu
		addBackButton(20,FlxG.height);
		addLeftButton(FlxG.width-400,FlxG.height);
		addRightButton(FlxG.width-200,FlxG.height);
		addUpButton(FlxG.width,Std.int(FlxG.height/2)-200);
		addAcceptButton(FlxG.width,Std.int(FlxG.height/2));
		addDownButton(FlxG.width,Std.int(FlxG.height/2)+200);

		backButton.visible = false; //JOELwindows7: oops that backButton ESC not work here. choose resume instead!
		#if !desktop //JOELwindows7: hide the offset adjustment key to prevent people pressing it
		leftButton.visible = false;
		rightButton.visible = false;
		#end //and then crash the game because again, file writing doesn't work in Android currently

		//JOELwindows7: tweenenied.
		FlxTween.tween(backButton,{y:FlxG.height - 100},2,{ease: FlxEase.elasticInOut}); //JOELwindows7: also tween back button!
		FlxTween.tween(leftButton,{y:FlxG.height - 100},2,{ease: FlxEase.elasticInOut}); //JOELwindows7: also tween left right button
		FlxTween.tween(rightButton,{y:FlxG.height - 100},2,{ease: FlxEase.elasticInOut}); //JOELwindows7: yeah.
		FlxTween.tween(upButton,{x:FlxG.width - 100},2,{ease: FlxEase.elasticInOut});
		FlxTween.tween(acceptButton,{x:FlxG.width - 100},2,{ease: FlxEase.elasticInOut});
		FlxTween.tween(downButton,{x:FlxG.width - 100},2,{ease: FlxEase.elasticInOut});
	}

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		if (PlayState.instance.useVideo)
			menuItems.remove('Resume');

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		var upPcontroller:Bool = false;
		var downPcontroller:Bool = false;
		var leftPcontroller:Bool = false;
		var rightPcontroller:Bool = false;
		var oldOffset:Float = 0;

		if (gamepad != null && KeyBinds.gamepad)
		{
			upPcontroller = gamepad.justPressed.DPAD_UP;
			downPcontroller = gamepad.justPressed.DPAD_DOWN;
			leftPcontroller = gamepad.justPressed.DPAD_LEFT;
			rightPcontroller = gamepad.justPressed.DPAD_RIGHT;
		}

		// pre lowercasing the song name (update)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
		switch (songLowercase) {
			case 'dad-battle': songLowercase = 'dadbattle';
			case 'philly-nice': songLowercase = 'philly';
		}
		var songPath = 'assets/data/' + songLowercase + '/';

		#if sys
		if (PlayState.isSM && !PlayState.isStoryMode)
			songPath = PlayState.pathToSm;
		#end

		if (controls.UP_P || upPcontroller || FlxG.mouse.wheel == 1 || haveUpped) //JOELwindows7: scroll up
		{
			changeSelection(-1);
			//trace("curSelection is " + Std.string(curSelected) + ". " + menuItems[curSelected]); // JOELwindows7: trace cur selection number

			haveUpped = false;
		}
		else if (controls.DOWN_P || downPcontroller || FlxG.mouse.wheel == -1 || haveDowned) //JOELwindows7: scroll down
		{
			changeSelection(1);
			trace("curSelection is " + Std.string(curSelected) + ". " + menuItems[curSelected]);
			//trace("well that alphabet is " + grpMenuShit.members[curSelected].ID + ". " + grpMenuShit.members[curSelected].text);
			
			haveDowned = false;
		}
		
		#if cpp
			else if (controls.LEFT_P || leftPcontroller  || haveLefted) //JOELwindows7: have lefted touchscreen button 
			{
				oldOffset = PlayState.songOffset;
				PlayState.songOffset -= 1;
				sys.FileSystem.rename(songPath + oldOffset + '.offset', songPath + PlayState.songOffset + '.offset');
				perSongOffset.text = "Additive Offset (Left, Right): " + PlayState.songOffset + " - Description - " + 'Adds value to global offset, per song.';

				// Prevent loop from happening every single time the offset changes
				if(!offsetChanged)
				{
					grpMenuShit.clear();

					menuItems = ['Restart Song', 'Exit to menu'];

					for (i in 0...menuItems.length)
					{
						var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
						songText.isMenuItem = true;
						songText.targetY = i;
						songText.scrollFactor.set(); //JOELwindows7: don't forget to zero the scrollfactor so the hover point doesn't scroll with camera it.
						songText.ID = i; //JOELwindows7: add ID to compare with curSelected
						grpMenuShit.add(songText);
					}

					changeSelection();

					cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
					offsetChanged = true;
				}
			haveLefted = false;
			} 
			else if (controls.RIGHT_P || rightPcontroller || haveRighted) //JOELwindows7: have Righted touchscreen button
			{
				oldOffset = PlayState.songOffset;
				PlayState.songOffset += 1;
				sys.FileSystem.rename(songPath + oldOffset + '.offset', songPath + PlayState.songOffset + '.offset');
				perSongOffset.text = "Additive Offset (Left, Right): " + PlayState.songOffset + " - Description - " + 'Adds value to global offset, per song.';
				if(!offsetChanged)
				{
					grpMenuShit.clear();

					menuItems = ['Restart Song', 'Exit to menu'];

					for (i in 0...menuItems.length)
					{
						var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
						songText.isMenuItem = true;
						songText.targetY = i;
						songText.scrollFactor.set(); //JOELwindows7: don't forget to zero the scrollfactor so the hover point doesn't scroll with camera it.
						songText.ID = i; //JOELwindows7: add ID to compare with curSelected
						grpMenuShit.add(songText);
					}

					changeSelection();

					cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
					offsetChanged = true;
				}
			haveRighted = false;
			}
		#end

		if ((controls.ACCEPT || haveClicked) && !FlxG.keys.pressed.ALT)
		{
			FlxG.mouse.visible = false; //JOELwindows7: invisiblize after select
			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
				case "Resume":
					FlxG.mouse.visible = false; //JOELwindows7: just in case
					close();
				case "Restart Song":
					FlxG.mouse.visible = false; //JOELwindows7: just in case
					PlayState.startTime = 0;
					if (PlayState.instance.useVideo)
					{
						GlobalVideo.get().stop();
						PlayState.instance.remove(PlayState.instance.videoSprite);
						PlayState.instance.removedVideo = true;
					}
					FlxG.resetState();
				case "Exit to menu":
					PlayState.startTime = 0;
					if (PlayState.instance.useVideo)
					{
						GlobalVideo.get().stop();
						PlayState.instance.remove(PlayState.instance.videoSprite);
						PlayState.instance.removedVideo = true;
					}
					if(PlayState.loadRep)
					{
						FlxG.save.data.botplay = false;
						FlxG.save.data.scrollSpeed = 1;
						FlxG.save.data.downscroll = false;
					}
					PlayState.loadRep = false;
					#if (windows && cpp)
					if (PlayState.luaModchart != null)
					{
						PlayState.luaModchart.die();
						PlayState.luaModchart = null;
					}
					#end
					//JOELwindows7: the controller destroy
					// if (PlayState.instance.onScreenGameplayButtons != null){
					// 	PlayState.instance.removeTouchScreenButtons();
					// }
					PlayState.instance.removeTouchScreenButtons();
					if (FlxG.save.data.fpsCap > 290)
						(cast (Lib.current.getChildAt(0), Main)).setFPSCap(290);
					
					if (PlayState.isStoryMode)
						FlxG.switchState(new StoryMenuState());
					else
						FlxG.switchState(new FreeplayState());
			}
			haveClicked = false;
		} else {
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
		}

		if (FlxG.keys.justPressed.J)
		{
			// for reference later!
			// PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxKey.J, null);
		}

		//JOELwindows7: mouse support
		if(FlxG.mouse.visible)
		{
			//do something here
			//only when mouse is visible
			grpMenuShit.forEach(function(poop:Alphabet){
				if(FlxG.mouse.overlaps(poop) /*&& !FlxG.mouse.overlaps(backButton)*/
					&& !FlxG.mouse.overlaps(leftButton) && !FlxG.mouse.overlaps(rightButton)){
					//trace("hover over " + Std.string(poop.ID)); //JOELwindows7: temp tracer
					//alright. it looks like that, the alphabet hover
					//isn't placed like it was appeared.
					//must find another way then. how?
					if(FlxG.mouse.justPressed){
						trace("click a menu " + Std.string(poop.ID) + ". " + Std.string(poop.text));
						if(poop.ID == curSelected){
							trace("haveClicked yes");
							haveClicked = true;
						} else {
							//go to clicked menu
							goToSelection(poop.ID);
							trace("Go to menu " + Std.string(poop.ID) + ". " + Std.string(poop.text));
						}
					}
				}

				//JOELwindows7: back button for no keyboard
				if(FlxG.mouse.overlaps(backButton) && !FlxG.mouse.overlaps(poop)){
					if(FlxG.mouse.justPressed){
						if(!haveBacked){
							haveBacked = true;
						}
					}
				}
				if(FlxG.mouse.overlaps(leftButton) && !FlxG.mouse.overlaps(poop)){
					if(FlxG.mouse.justPressed){
						if(!haveLefted){
							haveLefted = true;
						}
					}
				}
				if(FlxG.mouse.overlaps(rightButton) && !FlxG.mouse.overlaps(poop)){
					if(FlxG.mouse.justPressed){
						if(!haveRighted){
							haveRighted = true;
						}
					}
				}

				//JOELwindows7: last measure if none of the click pause menu work at all somehow.
				if(FlxG.mouse.overlaps(acceptButton) && !FlxG.mouse.overlaps(poop)){
					if(FlxG.mouse.justPressed){
						haveClicked = true;
					}
				}
				if(FlxG.mouse.overlaps(upButton) && !FlxG.mouse.overlaps(poop)){
					if(FlxG.mouse.justPressed){
						haveUpped = true;
					}
				}
				if(FlxG.mouse.overlaps(downButton) && !FlxG.mouse.overlaps(poop)){
					if(FlxG.mouse.justPressed){
						haveDowned = true;
					}
				}
			});

			
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;
		
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}

	//JOELwindows7: same as above but this one set to which menu item
	function goToSelection(change:Int){
		curSelected = change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}
