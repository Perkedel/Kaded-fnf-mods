package;

import flixel.input.gamepad.FlxGamepad;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.Lib;
import Options;
import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;

class OptionsMenu extends MusicBeatState
{
	public static var instance:OptionsMenu;

	var selector:FlxText;
	var curSelected:Int = 0;

	var options:Array<OptionCategory> = [
		new OptionCategory("Gameplay", [
			new DFJKOption(controls),
			new UseTouchScreenButtons("Toggle touchscreen buttons in gameplay"),
			new SelectTouchScreenButtons("Choose which touchscreen button you'd like to have"),
			new DownscrollOption("Toggle making the notes scroll down rather than up."),
			new GhostTapOption("Toggle counting pressing a directional input when no arrow is there as a miss."),
			new Judgement("Customize your Hit Timings. (LEFT or RIGHT)"),
			#if desktop
			new FPSCapOption("Change your FPS Cap."),
			#end
			new ScrollSpeedOption("Change your scroll speed. (1 = Chart dependent)"),
			new AccuracyDOption("Change how accuracy is calculated. (Accurate = Simple, Complex = Milisecond Based)"),
			new ResetButtonOption("Toggle pressing R to gameover."),
			// new OffsetMenu("Get a note offset based off of your inputs!"),
			new PreUnlockAllWeeksOption("Toggle whether to preUnlock all weeks no matter what"),
			new CustomizeGameplay("Drag and drop gameplay modules to your prefered positions!")
		]),
		new OptionCategory("Appearance", [
			new FullScreenOption("Toggle Fullscreen Mode"),
			new DistractionsAndEffectsOption("Toggle stage distractions that can hinder your gameplay."),
			new CamZoomOption("Toggle the camera zoom in-game."),
			new StepManiaOption("Sets the colors of the arrows depending on quantization instead of direction."),
			new AccuracyOption("Display accuracy information on the info bar."),
			new SongPositionOption("Show the song's current position as a scrolling bar."),
			new NPSDisplayOption("Shows your current Notes Per Second on the info bar."),
			new RainbowFPSOption("Make the FPS Counter flicker through rainbow colors."),
			new CpuStrums("Toggle the CPU's strumline lighting up when it hits a note."),
		]),

		new OptionCategory("Audio",[
			new AdjustVolumeOption("Adjust Audio volume"),
			new SurroundTestOption("EXPERIMENTAL! Open 7.1 surround sound tester with Lime AudioSource"),
			new AnMIDITestOption("EXPERIMENTAL! Open MIDI output test room"),
		]),
		
		new OptionCategory("Misc", [
			#if !mobile
			new FPSOption("Toggle the FPS Counter"),
			new ReplayOption("View replays"),
			#end
			new CardiophileOption("Toggle heartbeat features that contains doki-doki stuffs"),
			new NaughtinessOption("Toggle naughtiness in game which may contains inappropriate contents"), //JOELwindows7: make this Odysee exclusive pls. how!
			new FlashingLightsOption("Toggle flashing lights that can cause epileptic seizures and strain."),
			new VibrationOption("Toggle Vibration that let your gamepade / device vibrates."),
			new VibrationOffsetOption("Adjust Vibration offset delaying"),
			new WatermarkOption("Enable and disable all watermarks from the engine."),
			new PerkedelmarkOption("Turn off all Perkedel watermarks from the engine."),
			new OdyseemarkOption("Turn off all Odysee watermarks from the engine."),
			new AntialiasingOption("Toggle antialiasing, improving graphics quality at a slight performance penalty."),
			new MissSoundsOption("Toggle miss sounds playing when you don't hit a note."),
			new ScoreScreen("Show the score screen after the end of a song"),
			new ShowInput("Display every single input on the score screen."),
			new Optimization("No characters or backgrounds. Just a usual rhythm game layout."),
			new GraphicLoading("On startup, cache every character. Significantly decrease load times. (HIGH MEMORY)"),
			new ExportSaveToJson("BETA! Export entire save data into JSON file"),
			new AnVideoCutscenerTestOption("EXPERIMENTAL! Test Video Cutscener capability"),
			new BotPlay("Showcase your charts and mods with autoplay.")
		]),
		
		new OptionCategory("Saves and Data", [
			#if desktop
			new ReplayOption("View saved song replays."),
			#end
			new ResetScoreOption("Reset your score on all songs and weeks. This is irreversible!"),
			new LockWeeksOption("Reset your story mode progress. This is irreversible!"),
			new ResetSettings("Reset ALL your settings. This is irreversible!")
		])
		
	];

	public var acceptInput:Bool = true;

	private var currentDescription:String = "";
	private var grpControls:FlxTypedGroup<Alphabet>;
	public static var versionShit:FlxText;
	
	var currentSelectedCat:OptionCategory;
	var blackBorder:FlxSprite;
	override function create()
	{
		instance = this;
		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menuDesat"));

		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		if(FlxG.save.data.antialiasing)
			{
				menuBG.antialiasing = true;
			}
		add(menuBG);

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		addBackButton(20,FlxG.height);
		addLeftButton(FlxG.width-400,FlxG.height);
		addRightButton(FlxG.width-200,FlxG.height);

		for (i in 0...options.length)
		{
			var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, options[i].getName(), true, false, true);
			controlLabel.isMenuItem = true;
			controlLabel.targetY = i;
			controlLabel.ID = i; //add the ID too for compare curSelected like Main Menu
			grpControls.add(controlLabel);
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
		}

		currentDescription = "none";

		versionShit = new FlxText(5, FlxG.height + 40, 0, "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset,2) + " - Description - " + currentDescription, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		
		blackBorder = new FlxSprite(-30,FlxG.height + 40).makeGraphic((Std.int(versionShit.width + 900)),Std.int(versionShit.height + 600),FlxColor.BLACK);
		blackBorder.alpha = 0.5;

		add(blackBorder);

		add(versionShit);

		FlxTween.tween(versionShit,{y: FlxG.height - 18},2,{ease: FlxEase.elasticInOut});
		FlxTween.tween(blackBorder,{y: FlxG.height - 18},2, {ease: FlxEase.elasticInOut});
		FlxTween.tween(backButton,{y:FlxG.height - 100},2,{ease: FlxEase.elasticInOut}); //JOELwindows7: also tween back button!
		FlxTween.tween(leftButton,{y:FlxG.height - 100},2,{ease: FlxEase.elasticInOut}); //JOELwindows7: also tween left right button
		FlxTween.tween(rightButton,{y:FlxG.height - 100},2,{ease: FlxEase.elasticInOut}); //JOELwindows7: yeah.

		super.create();

		
	}

	var isCat:Bool = false;
	

	override function update(elapsed:Float)
	{
		super.update(elapsed);

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

		if (acceptInput)
		{
			//JOELwindows7: right click to go back, I guess.
			//incase gamers get mad, smash keyboard, no longer working?
			if ((controls.BACK || haveBacked)&& !isCat)
			{
				FlxG.switchState(new MainMenuState());
				haveBacked = false;
			}
			else if (controls.BACK || haveBacked)
			{
				isCat = false;
				grpControls.clear();
				for (i in 0...options.length)
				{
					var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, options[i].getName(), true, false);
					controlLabel.isMenuItem = true;
					controlLabel.targetY = i;
					controlLabel.ID = i; //add the ID too for compare curSelected like Main Menu
					grpControls.add(controlLabel);
					// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
				}
				
				curSelected = 0;
				
				changeSelection(curSelected); //JOELwindows7: funny, this is not necessary. it jumps for num of cur selected
				haveBacked = false;
			}

			var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

			if (gamepad != null)
			{
				if (gamepad.justPressed.DPAD_UP)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeSelection(-1);
				}
				if (gamepad.justPressed.DPAD_DOWN)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeSelection(1);
				}
			}
			
			//JOELwindows7: idk how to mouse on option menu
			if (FlxG.keys.justPressed.UP || FlxG.mouse.wheel == 1)
				changeSelection(-1);
			if (FlxG.keys.justPressed.DOWN || FlxG.mouse.wheel == -1)
				changeSelection(1);
			
			if (isCat)
			{
				if (currentSelectedCat.getOptions()[curSelected].getAccept())
				{
					if (FlxG.keys.pressed.SHIFT)
						{
							if (FlxG.keys.pressed.RIGHT || haveRighted)
							{
								currentSelectedCat.getOptions()[curSelected].right();
								haveRighted = false;
							}
							if (FlxG.keys.pressed.LEFT || haveLefted)
							{
								currentSelectedCat.getOptions()[curSelected].left();
								haveLefted = false;
							}
						}
					else
					{
						if (FlxG.keys.justPressed.RIGHT || haveRighted)
						{
							currentSelectedCat.getOptions()[curSelected].right();
							haveRighted = false;
						}
						if (FlxG.keys.justPressed.LEFT || haveLefted)
						{
							currentSelectedCat.getOptions()[curSelected].left();
							haveLefted = false;
						}
					}
				}
				else
				{
					if (FlxG.keys.pressed.SHIFT)
					{
						if (FlxG.keys.justPressed.RIGHT || haveRighted)
						{
							FlxG.save.data.offset += 0.1;
							haveRighted = false;
						}
						else if (FlxG.keys.justPressed.LEFT || haveLefted)
						{
							FlxG.save.data.offset -= 0.1;
							haveLefted = false;
						}
					}
					else if (FlxG.keys.pressed.RIGHT || haveRighted)
					{
						FlxG.save.data.offset += 0.1;
						haveRighted = false;
					}
					else if (FlxG.keys.pressed.LEFT || haveLefted)
					{
						FlxG.save.data.offset -= 0.1;
						haveLefted = false;
					}
					
					versionShit.text = "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset,2) + " - Description - " + currentDescription;
				}
				if (currentSelectedCat.getOptions()[curSelected].getAccept())
					versionShit.text =  currentSelectedCat.getOptions()[curSelected].getValue() + " - Description - " + currentDescription;
				else
					versionShit.text = "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset,2) + " - Description - " + currentDescription;
			}
			else
			{
				if (FlxG.keys.pressed.SHIFT)
				{
					if (FlxG.keys.justPressed.RIGHT || haveRighted)
					{
						FlxG.save.data.offset += 0.1;
						haveRighted = false;
					}
					else if (FlxG.keys.justPressed.LEFT || haveLefted)
					{
						FlxG.save.data.offset -= 0.1;
						haveLefted = false;
					}
				}
				else if (FlxG.keys.pressed.RIGHT || haveRighted)
				{
					FlxG.save.data.offset += 0.1;
					haveRighted = false;
				}
				else if (FlxG.keys.pressed.LEFT || haveLefted)
				{
					FlxG.save.data.offset -= 0.1;
					haveLefted = false;
				}
				
				versionShit.text = "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset,2) + " - Description - " + currentDescription;
			}
		

			if (controls.RESET)
					FlxG.save.data.offset = 0;

			if (controls.ACCEPT || haveClicked) //JOELwindows7: add clicked when mouse click
			{
				if (isCat)
				{
					if (currentSelectedCat.getOptions()[curSelected].press()) {
						grpControls.members[curSelected].reType(currentSelectedCat.getOptions()[curSelected].getDisplay());
						trace(currentSelectedCat.getOptions()[curSelected].getDisplay());
					}
				}
				else
				{
					currentSelectedCat = options[curSelected];
					isCat = true;
					grpControls.clear();
					for (i in 0...currentSelectedCat.getOptions().length)
						{
							var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, currentSelectedCat.getOptions()[i].getDisplay(), true, false);
							controlLabel.isMenuItem = true;
							controlLabel.targetY = i;
							controlLabel.ID = i; //add the ID too for compare curSelected like Main Menu
							grpControls.add(controlLabel);
							// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
						}
					curSelected = 0;
				}
				
				changeSelection();

				haveClicked=false; //JOELwindows7: mouse supports
			}
		}
		FlxG.save.flush();

		//JOELwindows7: query every single menu category and each items
		//inspire this from MainMenuState like before!
		grpControls.forEach(function(alphabet:Alphabet){
			if(FlxG.mouse.overlaps(alphabet) && !FlxG.mouse.overlaps(backButton)
				&& !FlxG.mouse.overlaps(leftButton) && !FlxG.mouse.overlaps(rightButton)){
				if(FlxG.mouse.justPressed){
					if(alphabet.ID == curSelected){
						haveClicked = true;
					} else {
						goToSelection(alphabet.ID);
					}
				}
			}

			//JOELwindows7: back button for no keyboard
			if(FlxG.mouse.overlaps(backButton) && !FlxG.mouse.overlaps(alphabet)){
				if(FlxG.mouse.justPressed){
					if(!haveBacked){
						haveBacked = true;
					}
				}
			}
			if(FlxG.mouse.overlaps(leftButton) && !FlxG.mouse.overlaps(alphabet)){
				if(FlxG.mouse.justPressed){
					if(!haveLefted){
						haveLefted = true;
					}
				}
			}
			if(FlxG.mouse.overlaps(rightButton) && !FlxG.mouse.overlaps(alphabet)){
				if(FlxG.mouse.justPressed){
					if(!haveRighted){
						haveRighted = true;
					}
				}
			}
		});

		
	}

	var isSettingControl:Bool = false;

	function changeSelection(change:Int = 0)
	{
		#if !switch
		#if newgrounds
		// NGio.logEvent("Fresh");
		#end
		#end
		
		FlxG.sound.play(Paths.sound("scrollMenu"), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;

		if (isCat)
			currentDescription = currentSelectedCat.getOptions()[curSelected].getDescription();
		else
			currentDescription = "Please select a category";
		if (isCat)
		{
			if (currentSelectedCat.getOptions()[curSelected].getAccept())
				versionShit.text =  currentSelectedCat.getOptions()[curSelected].getValue() + " - Description - " + currentDescription;
			else
				versionShit.text = "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset,2) + " - Description - " + currentDescription;
		}
		else
			versionShit.text = "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset,2) + " - Description - " + currentDescription;
		// selector.y = (70 * curSelected) + 30;

		var bullShit:Int = 0;

		for (item in grpControls.members)
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

	//JOELwindows7: copy from above but this time set the selection number
	function goToSelection(change:Int = 0){
		#if !switch
		#if newgrounds
		// NGio.logEvent("Fresh");
		#end
		#end
		
		FlxG.sound.play(Paths.sound("scrollMenu"), 0.4);

		curSelected = change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;

		if (isCat)
			currentDescription = currentSelectedCat.getOptions()[curSelected].getDescription();
		else
			currentDescription = "Please select a category";
		if (isCat)
		{
			if (currentSelectedCat.getOptions()[curSelected].getAccept())
				versionShit.text =  currentSelectedCat.getOptions()[curSelected].getValue() + " - Description - " + currentDescription;
			else
				versionShit.text = "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset,2) + " - Description - " + currentDescription;
		}
		else
			versionShit.text = "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset,2) + " - Description - " + currentDescription;
		// selector.y = (70 * curSelected) + 30;

		var bullShit:Int = 0;

		for (item in grpControls.members)
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
