package;

import flixel.addons.ui.FlxUISprite;
import flixel.addons.ui.FlxUIText;
import CoreState;
import flixel.FlxState;
import GalleryAchievements;
#if gamejolt
import GameJolt;
#end
import flixel.FlxCamera;
import flixel.FlxSubState;
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

// JOELwindows7: FlxUI fy!!!
// JOELwindows7: ome component yoink from
// https://github.com/BoloVEVO/Kade-Engine-Public/blob/stable/source/OptionsMenu.hx

class OptionCata extends FlxUISprite
{
	public var title:String;
	public var options:Array<Option>;

	public var optionObjects:FlxTypedGroup<FlxUIText>;

	public var titleObject:FlxUIText;

	public var middle:Bool = false;

	public var text:FlxUIText; // JOELwindows7: BOLO have globalized this

	public function new(x:Float, y:Float, _title:String, _options:Array<Option>, middleType:Bool = false)
	{
		super(x, y);
		title = _title;
		middle = middleType;
		if (!middleType)
			makeGraphic(295, 64, FlxColor.BLACK);
		alpha = 0.4;

		options = _options;

		optionObjects = new FlxTypedGroup();

		titleObject = new FlxUIText((middleType ? 1180 / 2 : x), y + (middleType ? 0 : 16), 0, title);
		titleObject.setFormat(Paths.font("vcr.ttf"), 35, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		titleObject.borderSize = 3;

		if (middleType)
		{
			titleObject.x = 50 + ((1180 / 2) - (titleObject.fieldWidth / 2));
		}
		else
			titleObject.x += (width / 2) - (titleObject.fieldWidth / 2);

		titleObject.scrollFactor.set();

		scrollFactor.set();

		for (i in 0...options.length)
		{
			var opt = options[i];
			text = new FlxUIText((middleType ? 1180 / 2 : 72), titleObject.y + 54 + (46 * i), 0, opt.getValue());
			if (middleType)
			{
				text.screenCenter(X);
			}
			text.setFormat(Paths.font("vcr.ttf"), 35, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			text.borderSize = 3;
			text.borderQuality = 1;
			text.scrollFactor.set();
			optionObjects.add(text);
		}
	}

	public function changeColor(color:FlxColor)
	{
		makeGraphic(295, 64, color);
	}
}

// JOELwindows7: I disagree. let's inherit from MusicBeatSubstate can we? no wait.
// peck this. let's just do it.
class OptionsMenu extends CoreSubState
{
	public static var instance:OptionsMenu;

	public var background:FlxUISprite;

	public var selectedCat:OptionCata;

	public var selectedOption:Option;

	public var selectedCatIndex = 0;
	public var selectedOptionIndex = 0;

	var maxCatIndex = 7; // JOELwindows7: how many visible categories we had here?
	var maxHiddenCatIndex = 2; // JOELwindows7: and the hidden ones.

	public var isInCat:Bool = false;

	public var options:Array<OptionCata>;

	public static var isInPause = false;

	public var shownStuff:FlxTypedGroup<FlxUIText>;

	public static var visibleRange = [114, 640]; // JOELwindows7: was 640

	public var upToHowManyCatsOnScreen:Int = 5; // JOELwindows7: by default there was 4 categories. Now we have 6 on first row, 1 on second row.
	public var upToHowManyCatsOnSecond:Int = 2;

	public static var markForGameplayRestart:Bool = false; // JOELwindows7: mark this true to tell that you have to restart song.

	public function new(pauseMenu:Bool = false)
	{
		super();

		isInPause = pauseMenu;
	}

	public var menu:FlxTypedGroup<FlxUISprite>;

	public var descText:FlxUIText;
	public var descBack:FlxUISprite;

	var menuTweenSo:Array<Array<FlxTween>> = [[], [], [], []]; // JOELwindows7: this machine tweenso.
	var menuTweenTime:Float = .3;

	override function create()
	{
		// JOELwindows7: init tweenso first!
		menuTweenSo = [[], [], [], []];

		options = [
			new OptionCata(50, 40, "Gameplay", [
				new ScrollSpeedOption("Change your scroll speed. (1 = Chart dependent)"),
				new OffsetThing("Change the note visual offset (how many milliseconds a note looks like it is offset in a chart)"),
				new AccuracyDOption("Change how accuracy is calculated. (Accurate = Simple, Complex = Milisecond Based)"),
				new GhostTapOption("Toggle counting pressing a directional input when no arrow is there as a miss."),
				new DownscrollOption("Toggle making the notes scroll down rather than up."),
				new BotPlay("A bot plays for you!"),
				// #if desktop // JOELwindows7: BOLO no longer do this.
				new FPSCapOption("Change your FPS Cap."),
				// #end
				new ResetButtonOption("Toggle pressing R to gameover. (Use it with caution!)"), // JOELwindows7: BOLO warned
				new InstantRespawn("Toggle if you instantly respawn after dying."),
				new CamZoomOption("Toggle the camera zoom in-game."),
				// new OffsetMenu("Get a note offset based off of your inputs!"),
				new DFJKOption(),
				new Judgement("Create a custom judgement preset"),
				new CustomizeGameplay("Drag and drop gameplay modules to your prefered positions!"),
				new LuaLegacyModchartOption("Enable Lua modchart compatibility for <1.7 modchart files."),
				new AutoClickEnabledOption("Let the game click the dialogue for you"),
				new AutoClickDelayOption("Set the delay of click between dialogue typing completition"),
				new EndSongEarlyOption("Toggle whether or not to end song early or wait music complete 1st"),
				new BlueballWeekOption("Toggle whether or not should blueball counts carries entire week or just this song"),
				new UnpausePreparationOption("(RECOMMENDED Always / Manual Only) Initiate quick preparation countdown after unpausing"),
			]),
			new OptionCata(345, 40, "Appearance", [
				new NoteskinOption("Change your current noteskin"),
				new NoteSplashOption("Have your note press splash for every SICK! kyaaa!"),
				new RotateSpritesOption("Should the game rotate the sprites to do color quantization (turn off for bar skins)"),
				new ScoreSmoothing("Toggle smoother poping score for Score Text (High CPU usage)."), // JOELwindows7: BOLO
				new EditorRes("Not showing the editor grid will greatly increase editor performance"),
				// new DistractionsAndEffectsOption("Toggle stage distractions that can hinder your gameplay."),
				new MiddleScrollOption("Put your lane in the center or on the right."),
				new HealthBarOption("Toggles health bar visibility"),
				new JudgementCounter("Show your judgements that you've gotten in the song"),
				new LaneUnderlayOption("How transparent your lane is, higher = more visible."),
				new StepManiaOption("Sets the colors of the arrows depending on quantization instead of direction."),
				new ForceStepmaniaOption("Force that quantization even when any modcharts are loaded."), // JOELwindows7: yeha! sneaky sneaky!
				new AccuracyOption("Display accuracy information on the info bar."),
				new RoundAccuracy("Round your accuracy to the nearest whole number for the score text (cosmetic only)."),
				new SongPositionOption("Show the song's current position as a scrolling bar."),
				new Colour("The color behind icons now fit with their theme. (e.g. Pico = green)"),
				new NPSDisplayOption("Shows your current Notes Per Second on the info bar."),
				new RainbowFPSOption("Make the FPS Counter flicker through rainbow colors."),
				new BorderFps("Draw a border around the FPS Text (Consumes a lot of CPU Resources)"),
				new CpuStrums("Toggle the CPU's strumline lighting up when it hits a note."),
				new CpuSplashOption("Toggle the CPU's note splash when it hits a note (REQUIRES: Note Splash to be ON)"),
			]),
			// JOELwindows7: Audio
			new OptionCata(640, 40, 'Audio', [
				new AdjustVolumeOption("Adjust Audio volume"),
				// new MissSoundsOption("Toggle miss sounds playing when you don't hit a note."), //JOELwindows7: how about move it here?
				new AccidentVolumeKeysOption("Enable / Disable volume shortcut key all time beyond pause menu (- decrease, + increase, 0 mute)"),
				new HitsoundOption("Enable / Disable Gameplay Hitsound everytime note got hit in Gameplay (not in Editor)"),
				new HitsoundSelect("Choose your hitsound. [ENTER] / (A) to preview"), // JOELwindows7: BOLO's choose hitsound
				new HitSoundVolume("Set hitsound volume. [ENTER] / (A) to preview"), // JOELwindows7: BOLO's hitsound volume
				// JOELwindows7: IDEA: only enable volume keys on pause menu?
				new SurroundTestOption("EXPERIMENTAL! Open 7.1 surround sound tester with Lime AudioSource"),
				// new AnMIDITestOption("EXPERIMENTAL! Open MIDI output test room"),
				new AnLoneBopeeboOption("Test gameplay music"),
			]),
			// JOELwindows7: Account options
			new OptionCata(935, 40, 'Accounts', [
				new LogGameJoltIn(#if gamejolt "(" + GameJoltAPI.getUserInfo(true) +
					") Log your GameJolt account in & manage" #else "GameJolt not supported. SADD!" #end)
			]),
			// JOELwindows7: BOLO had this category of Performance
			new OptionCata(1100, 40, "Performance", [
				new OptimizeOption("Disable Background and Characters to save memory. Useful to low-end computers."),
				new Background("Disable Stage Background to save memory (Only characters are visible)."),
				new DistractionsAndEffectsOption("Toggle stage distractions that can hinder your gameplay and save memory.")
			]),
			// JOELwindows7: was 640, 40
			new OptionCata(1040, 40, "Misc", [
				new FPSOption("Toggle the FPS Counter"),
				new DisplayMemory("Toggle the Memory Usage"), // JOELwindows7: BOLO show memory usages
				#if FEATURE_DISCORD
				new DiscordOption("Change your Discord Rich Presence update interval."), // JOELwindows7: BOLO discordant
				#end
				new PreUnlockAllWeeksOption("Toggle to Pre-unlock all weeks"),
				new CardiophileOption("Toggle heartbeat features that contains doki-doki stuffs"),
				new NaughtinessOption("Toggle naughtiness in game which may contains inappropriate contents"), // JOELwindows7: make this Odysee exclusive pls. how!
				new FlashingLightsOption("Toggle flashing lights that can cause epileptic seizures and strain."),
				new VibrationOption("Toggle Vibration that let your gamepade / device vibrates."),
				new VibrationOffsetOption("Adjust Vibration offset delaying"),
				new WatermarkOption("Enable and disable all watermarks from the engine."),
				new PerkedelmarkOption("Enable and disable all Perkedel watermarks from the engine."),
				new OdyseemarkOption("Enable and disable all Odysee watermarks from the engine."), // JOELwindows7: yep Odysee.
				new FlashingLightsOption("Toggle flashing lights that can cause epileptic seizures and strain."),
				new AntialiasingOption("Toggle antialiasing, improving graphics quality at a slight performance penalty."),
				new MissSoundsOption("Toggle miss sounds playing when you don't hit a note."),
				new ScoreScreen("Show the score screen after the end of a song"),
				new ScoreTxtZoomOption("Toggle score screen side zooming for each successive note"),
				new ShowInput("Display every single input on the score screen."),
				new ExportSaveToJson("BETA! Export entire save data into JSON file"),
				new AnVideoCutscenerTestOption("EXPERIMENTAL! Test Video Cutscener capability"),
				new AnStarfieldTestOption("EXPERIMENTAL! Test FlxStarfield"),
				new AnDefaultBekgronTestOption("EXPERIMENTAL! Test default background of Hexagon Engine"),
				new AnChangeChannelOption("EXPERIMENTAL! Test change channel and rate"),
				new AnMiniWindowOption("EXPERIMENTAL! Test MiniWindow using debugger's windowing"),
				new AnKem0xTestStateOption("EXPERIMENTAL! Test Kem0x's Nexus Engine stuffs"),
				// new OutOfSegsWarningOption("Toggle whether Out of Any Segs to be printed (`ON` WILL CAUSE LAG)"),
				new FreeplayThreadedOption("BETA! Enable Freeplay Threading, may cause system instabilities"),
				new WorkaroundNoVideoOption("Disable Video Cutscener to workaround crash when trying to start loading video or whatever"),
				new PrintSongChartContentOption("Toggle whether Song Chart to be printed (WILL DELAY LONGER THE CONTENT IS)"),
				new PrintAnnoyingDebugWarnOption("Toggle whether should frequent warns appears (is annoying)"),
				new ModConfigurationsOption("Configure which Polymod Kade-LFM mods to be loaded"),
			]),
			// JOELwindows7: was 935, 40. was 1100, 40
			new OptionCata(50, 140, "Saves", [
				#if desktop // new ReplayOption("View saved song replays."),
				#end
				new ResetScoreOption("Reset your score on all songs and weeks. This is irreversible!"),
				new LockWeeksOption("Reset your story mode progress. This is irreversible!"),
				new ResetSettings("Reset ALL your settings. This is irreversible!")
			]),
			// TODO: JOELwindows7: Category about for credits a& acknowledgements
			new OptionCata(-1, 125, "Editing Keybinds", [
				new LeftKeybind("The left note's keybind"),
				new DownKeybind("The down note's keybind"),
				new UpKeybind("The up note's keybind"),
				new RightKeybind("The right note's keybind"),
				new PauseKeybind("The keybind used to pause the game"),
				new ResetBind("The keybind used to die instantly"),
				new MuteBind("The keybind used to mute game audio"),
				new VolUpBind("The keybind used to turn the volume up"),
				new VolDownBind("The keybind used to turn the volume down"),
				new FullscreenBind("The keybind used to fullscreen the game")
			], true),
			new OptionCata(-1, 125, "Editing Judgements", [
				new SickMSOption("How many milliseconds are in the SICK hit window"),
				new GoodMsOption("How many milliseconds are in the GOOD hit window"),
				new BadMsOption("How many milliseconds are in the BAD hit window"),
				new ShitMsOption("How many milliseconds are in the SHIT hit window")
			], true),
		];

		instance = this;

		menu = new FlxTypedGroup<FlxUISprite>();

		shownStuff = new FlxTypedGroup<FlxUIText>();

		// JOELwindows7: pinpoint, this is inner square. also the cast, nvm
		background = new FlxUISprite(50, 40);
		background.makeGraphic(1180, 640, FlxColor.BLACK);
		background.alpha = 0.5;
		background.scrollFactor.set();
		menu.add(background);

		// JOELwindows7: was 50, 640. no cast pls
		// https://github.com/BoloVEVO/Kade-Engine-Public/blob/stable/source/OptionsMenu.hx
		descBack = new FlxUISprite(50, 642);
		descBack.makeGraphic(1180, 38, FlxColor.BLACK);
		descBack.alpha = 0.3;
		descBack.scrollFactor.set();
		menu.add(descBack);

		if (isInPause)
		{
			// JOELwindows7: pinpoint, this is outer square that fill entire game screen when in Pause.
			var bg:FlxUISprite = new FlxUISprite();
			bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			bg.alpha = 0;
			bg.scrollFactor.set();
			menu.add(bg);

			background.alpha = 0.5;
			bg.alpha = 0.6;

			cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		}

		selectedCat = options[0];

		selectedOption = selectedCat.options[0];

		// JOELwindows7: assign ID to category
		assignIDToCats();

		add(menu);

		add(shownStuff);

		for (i in 0...options.length - 1)
		{
			// JOELwindows7: what is this thing doing? skip adding it that after 4th?
			if (i >= maxCatIndex)
				continue;
			var cat = options[i];
			add(cat);
			add(cat.titleObject); // JOELwindows7: pinpoint, so you must take of this too.
			// Remember, this is not Godot where you can have node inside node recursively.
			// So, you can only have this title text thingy side by side, on top of the cat FlxSprite itself.
		}

		descText = new FlxUIText(62, 648);
		descText.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.borderSize = 2;

		add(descBack);
		add(descText);

		isInCat = true;

		switchCat(selectedCat);

		selectedOption = selectedCat.options[0];

		// JOELwindows7: now tidy the category
		tidyThoseCats();

		// JOELwindows7: now add these all up
		addBackButton(1, FlxG.height, .3);
		addLeftButton(FlxG.width - 400, FlxG.height, .3);
		addRightButton(FlxG.width - 200, FlxG.height, .3);
		addUpButton(FlxG.width, Std.int(FlxG.height / 2) - 200, .4);
		addAcceptButton(FlxG.width, Std.int(FlxG.height / 2), .4);
		addDownButton(FlxG.width, Std.int(FlxG.height / 2) + 200, .4);

		// JOELwindows7: Then animate them.
		FlxTween.tween(backButton, {y: FlxG.height - backButton.height - 10}, 2, {ease: FlxEase.elasticInOut}); // JOELwindows7: also tween back button!
		FlxTween.tween(leftButton, {y: FlxG.height - leftButton.height - 10}, 2, {ease: FlxEase.elasticInOut}); // JOELwindows7: also tween left right button
		FlxTween.tween(rightButton, {y: FlxG.height - rightButton.height - 10}, 2, {ease: FlxEase.elasticInOut}); // JOELwindows7: yeah.
		// JOEL:windows7: rest of side buttons tweenegh
		FlxTween.tween(upButton, {x: FlxG.width - upButton.width - 10}, 2, {ease: FlxEase.elasticInOut});
		FlxTween.tween(acceptButton, {x: FlxG.width - acceptButton.width - 10}, 2, {ease: FlxEase.elasticInOut});
		FlxTween.tween(downButton, {x: FlxG.width - downButton.width - 10}, 2, {ease: FlxEase.elasticInOut});

		super.create();

		// JOELwindows7: stuffs
		AchievementUnlocked.whichIs("anOption");
	}

	public function switchCat(cat:OptionCata, checkForOutOfBounds:Bool = true)
	{
		try
		{
			visibleRange = [114, 640]; // JOELwindows7: expand check visible range. was [114, 640]
			// JOELwindows7: BOLO disabled it?!
			// if (cat.middle)
			// 	visibleRange = [Std.int(cat.titleObject.y), 640]; // JOELwindows7: was [the value, 640]
			if (selectedOption != null)
			{
				var object = selectedCat.optionObjects.members[selectedOptionIndex];
				object.text = selectedOption.getValue();
			}

			if (selectedCatIndex > options.length - maxHiddenCatIndex - 1 && checkForOutOfBounds) // JOELwindows7: options.length minus 3
				selectedCatIndex = 0;

			if (selectedCat.middle)
				remove(selectedCat.titleObject);

			selectedCat.changeColor(FlxColor.BLACK);
			selectedCat.alpha = 0.3;

			for (i in 0...selectedCat.options.length)
			{
				var opt = selectedCat.optionObjects.members[i];
				opt.y = selectedCat.titleObject.y + 54 + (46 * i);
				// opt.y = options[4].titleObject.y + 54 + (46 * i); // JOELwindows7: pls figure this one out
			}

			while (shownStuff.members.length != 0)
			{
				shownStuff.members.remove(shownStuff.members[0]);
			}
			selectedCat = cat;
			selectedCat.alpha = 0.2;
			selectedCat.changeColor(FlxColor.WHITE);

			if (selectedCat.middle)
				add(selectedCat.titleObject);

			var count:Int = 0;
			for (i in selectedCat.optionObjects)
			{
				i.ID = count; // JOELwindows7: brute forced ID assign
				shownStuff.add(i);
				count++; // JOELwindows7: yep, idk the code anymore.
			}

			selectedOption = selectedCat.options[0];

			if (selectedOptionIndex > options[selectedCatIndex].options.length - 1)
			{
				for (i in 0...selectedCat.options.length)
				{
					var opt = selectedCat.optionObjects.members[i];
					opt.ID = i; // JOELwindows7: assign ID to each option member.
					opt.y = selectedCat.titleObject.y + 54 + (46 * i);
					// opt.y = options[4].titleObject.y + 54 + (46 * i); // JOELwindows7: I think figurely, 4 is `up to how many`?
				}
			}

			// JOELwindows7: nope, try again Assign ID
			assignIDToOptions();

			selectedOptionIndex = 0;

			if (!isInCat)
				selectOption(selectedOption);

			// JOELwindows7: pinpoint, this is to invisiblize outside visible range and revisible in range.
			for (i in selectedCat.optionObjects.members)
			{
				if (i.y < visibleRange[0] - 24)
					i.alpha = 0;
				else if (i.y > visibleRange[1] - 24)
					i.alpha = 0;
				else
				{
					i.alpha = 0.4;
				}
			}
		}
		catch (e)
		{
			// JOELwindows7: add detaile!
			Debug.logError('oops\n $e : ${e.message}\n${e.details()}');
			selectedCatIndex = 0;
		}

		Debug.logTrace("Changed cat: " + selectedCatIndex);

		updateOptColors(); // JOELwindows7: Change color based on things. wait, don't do now. there's alot of illelegancies.

		haveClicked = false; // JOELwindows7 idk..
	}

	public function selectOption(option:Option)
	{
		var object = selectedCat.optionObjects.members[selectedOptionIndex];

		selectedOption = option;

		if (!isInCat)
		{
			object.text = "> " + option.getValue();

			descText.text = option.getDescription();
		}
		Debug.logTrace("Changed opt: " + selectedOptionIndex);

		Debug.logTrace("Bounds: " + visibleRange[0] + "," + visibleRange[1]);
		haveClicked = false; // JOELwindows7: mouse supports
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		var accept = false;
		var right = false;
		var left = false;
		var up = false;
		var down = false;
		var any = false;
		var escape = false;

		// JOELwindows7: add mouseoid.
		accept = FlxG.keys.justPressed.ENTER || (gamepad != null ? gamepad.justPressed.A : false) || haveClicked;
		right = FlxG.keys.justPressed.RIGHT || (gamepad != null ? gamepad.justPressed.DPAD_RIGHT : false) || haveRighted;
		left = FlxG.keys.justPressed.LEFT || (gamepad != null ? gamepad.justPressed.DPAD_LEFT : false) || haveLefted;
		up = FlxG.keys.justPressed.UP || (gamepad != null ? gamepad.justPressed.DPAD_UP : false) || haveUpped || FlxG.mouse.wheel > 0;
		down = FlxG.keys.justPressed.DOWN
			|| (gamepad != null ? gamepad.justPressed.DPAD_DOWN : false)
			|| haveDowned
			|| FlxG.mouse.wheel < 0;

		any = FlxG.keys.justPressed.ANY || (gamepad != null ? gamepad.justPressed.ANY : false);
		escape = FlxG.keys.justPressed.ESCAPE || (gamepad != null ? gamepad.justPressed.B : false) || haveBacked;
		// JOELwindows7: turns out, double back was because this escape bool is not updated until you go back here again.
		// when you thought you've flipped haveBacked false, the escape is not. you should also flip back false that too.
		// you only see escape while you should see haveBacked directly instead.

		if (selectedCat != null && !isInCat)
		{
			for (i in selectedCat.optionObjects.members)
			{
				if (selectedCat.middle)
				{
					i.screenCenter(X);
				}

				// I wanna die!!!
				if (i.y < visibleRange[0] - 24)
					i.alpha = 0;
				else if (i.y > visibleRange[1] - 24)
					i.alpha = 0;
				else
				{
					if (selectedCat.optionObjects.members[selectedOptionIndex].text != i.text)
						i.alpha = 0.4;
					else
						i.alpha = 1;
				}
			}
		}

		try
		{
			if (isInCat)
			{
				descText.text = "Please select a category";
				if (right)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();
					selectedCatIndex++;

					if (selectedCatIndex > options.length - maxHiddenCatIndex - 1) // JOELwindows7: 2 hidden max cat?
						selectedCatIndex = 0;
					if (selectedCatIndex < 0)
						selectedCatIndex = options.length - maxHiddenCatIndex - 1; // JOELwindows7: 2 yeah. was `3`

					switchCat(options[selectedCatIndex]);
				}
				else if (left)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();
					selectedCatIndex--;

					if (selectedCatIndex > options.length - maxHiddenCatIndex - 1) // JOElwindows7: yea
						selectedCatIndex = 0;
					if (selectedCatIndex < 0)
						selectedCatIndex = options.length - maxHiddenCatIndex - 1; // JOELwindows7: woohoo

					switchCat(options[selectedCatIndex]);
				}

				if (accept)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					selectedOptionIndex = 0;
					isInCat = false;
					selectOption(selectedCat.options[0]);

					haveClicked = false; // JOELwindows7: don't forget
					accept = false; // JOELwindows7: update this too
				}

				if (escape)
				{
					if (!isInPause)
						// FlxG.switchState(new MainMenuState());
						OptionsDirect.instance.switchState(new MainMenuState()); // JOELwindows7: hex switch state lol
					else
					{
						PauseSubState.goBack = true;
						PlayStateChangeables.scrollSpeed = FlxG.save.data.scrollSpeed * PlayState.songMultiplier;
						// JOELwindows7: heurestic to see if a marker has raised
						if (markForGameplayRestart)
						{
							createToast(null, "Please Restart Song",
								"You have changed options that needs reloading. Please restart the song to apply the changes.");
						}
						// JOELwindows7: reset value again.
						markForGameplayRestart = false;
						close();
					}

					haveBacked = false; // JOELwindows7: don't forget
					escape = false; // JOELwindows7: update this too
				}
			}
			else
			{
				if (selectedOption != null)
					if (selectedOption.acceptType)
					{
						if (escape && selectedOption.waitingType)
						{
							FlxG.sound.play(Paths.sound('scrollMenu'));
							selectedOption.waitingType = false;
							var object = selectedCat.optionObjects.members[selectedOptionIndex];
							object.text = "> " + selectedOption.getValue();
							Debug.logTrace("New text: " + object.text);

							// JOELwindows7: heurestic to see if a marker has raised
							if (markForGameplayRestart)
							{
								createToast(null, "Please Restart Song",
									"You have changed options that needs reloading. Please restart the song to apply the changes.");
							}
							// JOELwindows7: reset value again.
							markForGameplayRestart = false;
							haveBacked = false; // JOELwindows7: whie
							escape = false; // JOELwindows7: update this too
							return;
						}
						else if (any)
						{
							var object = selectedCat.optionObjects.members[selectedOptionIndex];
							selectedOption.onType(gamepad == null ? FlxG.keys.getIsDown()[0].ID.toString() : gamepad.firstJustPressedID());
							object.text = "> " + selectedOption.getValue();
							Debug.logTrace("New text: " + object.text);

							any = false; // JOELwindows7: don't forget
						}
					}
				if (selectedOption.acceptType || !selectedOption.acceptType)
				{
					if (accept)
					{
						var prev = selectedOptionIndex;
						var object = selectedCat.optionObjects.members[selectedOptionIndex];
						selectedOption.press();

						if (selectedOptionIndex == prev)
						{
							FlxG.save.flush();

							object.text = "> " + selectedOption.getValue();
						}
						haveClicked = false; // JOELwindows7: mouse supports
						accept = false; // JOELwindows7: update this too
					}

					if (down)
					{
						cancelTweenSo(); // JOELwindows7: clear tween!
						if (selectedOption.acceptType)
							selectedOption.waitingType = false;
						FlxG.sound.play(Paths.sound('scrollMenu'));
						selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();
						selectedOptionIndex++;

						// just kinda ignore this math lol

						if (selectedOptionIndex > options[selectedCatIndex].options.length - 1)
						{
							for (i in 0...selectedCat.options.length)
							{
								var opt = selectedCat.optionObjects.members[i];
								// opt.y = selectedCat.titleObject.y + 54 + (46 * i);
								// JOELwindows7: let's make fancy
								menuTweenSo[0][i] = FlxTween.tween(opt, {y: selectedCat.titleObject.y + 54 + (46 * i)}, menuTweenTime,
									{ease: FlxEase.quadInOut});
							}
							selectedOptionIndex = 0;
						}

						if (selectedOptionIndex != 0
							&& selectedOptionIndex != options[selectedCatIndex].options.length - 1
							&& options[selectedCatIndex].options.length > 6)
						{
							var andex:Int = 0; // JOELwindows7: tweenSo
							// if (selectedOptionIndex >= (options[selectedCatIndex].options.length - 1) / 2)
							if (selectedOptionIndex >= 9) // JOELwindows7: attempt manual fix late scroll for many option in that category
								for (i in selectedCat.optionObjects.members)
								{
									// i.y -= 46;
									// JOELwindows7: fancy move attempt
									menuTweenSo[2][andex] = FlxTween.tween(i, {y: i.y - 46}, menuTweenTime, {ease: FlxEase.quadInOut});
									andex++;
								}
						}

						selectOption(options[selectedCatIndex].options[selectedOptionIndex]);
						haveDowned = false; // JOELwindows7: yea
						haveClicked = false; // JOELwindows7: mouse supports
						down = false; // JOELwindows7: update this too
						accept = false; // JOELwindows7: update this too
					}
					else if (up)
					{
						cancelTweenSo(); // JOELwindows7: clear tween!
						if (selectedOption.acceptType)
							selectedOption.waitingType = false;
						FlxG.sound.play(Paths.sound('scrollMenu'));
						selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();
						selectedOptionIndex--;

						// just kinda ignore this math lol

						if (selectedOptionIndex < 0)
						{
							var andex:Int = 0; // JOELwindows7 for this tweenerSo
							selectedOptionIndex = options[selectedCatIndex].options.length - 1;

							if (options[selectedCatIndex].options.length > 6)
								for (i in selectedCat.optionObjects.members)
								{
									i.y -= (46 * ((options[selectedCatIndex].options.length - 1) / 2)); // JOELwindows7: keep, because there is bug here.
									// JOELwindows7: fancy movement attempt
									menuTweenSo[1][andex] = FlxTween.tween(i, {y: i.y - (46 * ((options[selectedCatIndex].options.length - 1) / 2))},
										menuTweenTime, {ease: FlxEase.quadInOut});
									andex++;
								}
						}

						if (selectedOptionIndex != 0 && options[selectedCatIndex].options.length > 6)
						{
							var andex:Int = 0; // JOELwindows7: tweenSO
							// if (selectedOptionIndex >= (options[selectedCatIndex].options.length - 1) / 2)
							if (selectedOptionIndex >= 9) // JOELwindows7: attempt manual fix late scroll for many option in that category
								for (i in selectedCat.optionObjects.members)
								{
									// i.y += 46;
									// JOELwindows7: fancy move attempt
									menuTweenSo[2][andex] = FlxTween.tween(i, {y: i.y + 46}, menuTweenTime, {ease: FlxEase.quadInOut});
									andex++;
								}
						}

						if (selectedOptionIndex < (options[selectedCatIndex].options.length - 1) / 2)
						{
							for (i in 0...selectedCat.options.length)
							{
								var opt = selectedCat.optionObjects.members[i];
								// opt.y = selectedCat.titleObject.y + 54 + (46 * i);
								// JOELwindows7: attempt fancy movement
								menuTweenSo[0][i] = FlxTween.tween(opt, {y: selectedCat.titleObject.y + 54 + (46 * i)}, menuTweenTime,
									{ease: FlxEase.quadInOut});
							}
						}

						selectOption(options[selectedCatIndex].options[selectedOptionIndex]);
						haveUpped = false; // JOELwindows7: yep
						haveClicked = false; // JOELwindows7: mouse supports
						up = false; // JOELwindows7: update this too
						accept = false; // JOELwindows7: update this too
					}

					if (right)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						var object = selectedCat.optionObjects.members[selectedOptionIndex];
						selectedOption.right();

						FlxG.save.flush();

						object.text = "> " + selectedOption.getValue();
						Debug.logTrace("New text: " + object.text);

						haveRighted = false; // JOELwindows7: oye
						right = false; // JOELwindows7: update this too
					}
					else if (left)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						var object = selectedCat.optionObjects.members[selectedOptionIndex];
						selectedOption.left();

						FlxG.save.flush();

						object.text = "> " + selectedOption.getValue();
						Debug.logTrace("New text: " + object.text);

						haveLefted = false; // JOELwindows7: ok
						left = false; // JOELwindows7: update this too
					}

					if (escape)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));

						if (selectedCatIndex >= maxCatIndex) // JOELwindows7: oyeng!
							selectedCatIndex = 0;

						PlayerSettings.player1.controls.loadKeyBinds();

						Ratings.timingWindows = [
							FlxG.save.data.shitMs,
							FlxG.save.data.badMs,
							FlxG.save.data.goodMs,
							FlxG.save.data.sickMs
						];

						for (i in 0...selectedCat.options.length)
						{
							var opt = selectedCat.optionObjects.members[i];
							opt.y = selectedCat.titleObject.y + 54 + (46 * i);
						}
						selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();
						isInCat = true;
						if (selectedCat.optionObjects != null)
							for (i in selectedCat.optionObjects.members)
							{
								if (i != null)
								{
									if (i.y < visibleRange[0] - 24)
										i.alpha = 0;
									else if (i.y > visibleRange[1] - 24)
										i.alpha = 0;
									else
									{
										i.alpha = 0.4;
									}
								}
							}
						if (selectedCat.middle)
							switchCat(options[0]);

						// JOELwindows7: heurestic to see if a marker has raised
						if (markForGameplayRestart)
						{
							createToast(null, "Please Restart Song",
								"You have changed options that needs reloading. Please restart the song to apply the changes.");
						}
						// JOELwindows7: reset value again.
						markForGameplayRestart = false;

						haveBacked = false; // JOELwindows7: okeh.
						escape = false; // JOELwindows7: update this too
					}
				}
			}
			haveBacked = false; // JOELwindows7: okeh.
			escape = false; // JOELwindows7: pls.
		}
		catch (e)
		{
			cancelTweenSo(); // JOELwindows7: clear tween immediately
			Debug.logError('wtf we actually did something wrong, but we dont crash bois.\n$e: ${e.message}\n${e.details()}');
			selectedCatIndex = 0;
			selectedOptionIndex = 0;
			FlxG.sound.play(Paths.sound('scrollMenu'));
			if (selectedCat != null)
			{
				for (i in 0...selectedCat.options.length)
				{
					var opt = selectedCat.optionObjects.members[i];
					opt.y = selectedCat.titleObject.y + 54 + (46 * i);
				}
				selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();
				isInCat = true;
			}
			haveBacked = false; // JOELwindows7: okeh.
			escape = false; // JOELwindows7: pls.
		}

		// JOELwindows7: wtf, FlxSubstate? not MusicBeatSubstate?!
		manageMouse(); // JOELwindows7: WHY THE PECK INHERIT FROM FlxSubState?!?!?!?
	}

	// JOELwindows7: copy from above but this time set the selection number
	function goToSelection(change:Int = 0)
	{
		if (!rawMouseHeld) // Only if you had not held mouse.
		{
			cancelTweenSo(); // clear tween
			if (selectedOption.acceptType)
				selectedOption.waitingType = false;
			FlxG.sound.play(Paths.sound("scrollMenu"), 0.4);
			// JOELwindows7: just change the index number
			selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();
			selectedOptionIndex = change;

			// JOELwindows7: copy from above up & down
			// just kinda ignore this math lol

			if (selectedOptionIndex > options[selectedCatIndex].options.length - 1)
			{
				for (i in 0...selectedCat.options.length)
				{
					var opt = selectedCat.optionObjects.members[i];
					// opt.y = selectedCat.titleObject.y + 54 + (46 * i);
					// JOELwindows7: make fancy movement
					menuTweenSo[0][i] = FlxTween.tween(opt, {y: selectedCat.titleObject.y + 54 + (46 * i)}, menuTweenTime, {ease: FlxEase.quadInOut});
				}
				selectedOptionIndex = 0;
			}

			if (selectedOptionIndex != 0
				&& selectedOptionIndex != options[selectedCatIndex].options.length - 1
				&& options[selectedCatIndex].options.length > 6)
			{
				var andex:Int = 0;
				if (selectedOptionIndex >= (options[selectedCatIndex].options.length - 1) / 2)
					for (i in selectedCat.optionObjects.members)
					{
						// i.y -= 46;
						// JOELwindows7: fancy movement
						menuTweenSo[2][andex] = FlxTween.tween(i, {y: i.y - 46}, menuTweenTime, {ease: FlxEase.quadInOut});
						andex++;
					}
			}

			selectOption(selectedCat.options[selectedOptionIndex]);
			haveClicked = false; // JOELwindows7: mouse supports
			rawMouseHeld = true;
		}
	}

	function goToCategory(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound("scrollMenu"), 0.4);
		selectedCatIndex = change;
		switchCat(options[selectedCatIndex], false);
	}

	// JOELwindows7: go to flxState. prevent go to there if you are in gameplay.
	public static function goToState(ofHere, goToLoading:Bool = false, transition:Bool = true, isSong:Bool = false)
	{
		if (isInPause)
		{
			// JOELwindows7: it's static method, you cannot access any instance method of this class.
			// playSoundEffect("cancelMenu",.4);
			FlxG.sound.play(Paths.sound("cancelMenu"), 0.4);
			Main.gjToastManager.createToast(Paths.image("uhOh", "core"), "Cannot access option", "Please leave the gameplay before accessing this option.");
			return;
		}
		// FlxG.switchState(ofHere);
		OptionsDirect.instance.switchState(ofHere, goToLoading, transition,
			isSong); // JOELwindows7: cyclic reference! rename switchState of this into goToState?
	}

	// JOELwindows7: now it is easinerer
	// JOELwindows7: mark needs restart song if the option requires restart
	public static function markRestartSong()
	{
		markForGameplayRestart = true;
	}

	// JOELwindows7: assign ID to category on screen
	function assignIDToCats()
	{
		for (i in 0...options.length - 1)
		{
			options[i].ID = i;
		}
	}

	// JOELwindows7: assign ID to option on screen
	function assignIDToOptions()
	{
		var count = 0;
		selectedCat.optionObjects.forEach(function(option:FlxUIText)
		{
			option.ID = count;
			count++;
		});
	}

	// JOELwindows7: we need to tidy the categories first
	function tidyThoseCats()
	{
		// for (i in 0...options.length - 1)
		for (i in 0...upToHowManyCatsOnScreen - 1)
		{
			// options[i].width = background.width / upToHowManyCatsOnScreen; //Unfortunately this only adjust the hitbox, not the graphic.
			options[i].setGraphicSize(Std.int(background.width / upToHowManyCatsOnScreen), Std.int(options[i].height));
			options[i].x = (background.width / upToHowManyCatsOnScreen) * i;
			// I guess..
			// oh almost forgot!
			options[i].titleObject.x = options[i].x + (options[i].width / 2) - (options[i].titleObject.width / 2);
			options[i].titleObject.y = options[i].y + 10;
			// Wow, GitHub Copilot sentience yeay!
		}
		tidySecondRowCats();
	}

	// JOELwindows7: well, second row..
	function tidySecondRowCats()
	{
		for (i in 0...upToHowManyCatsOnSecond - 1)
		{
			var prakstend = i + upToHowManyCatsOnScreen - 1;
			// options[i].width = background.width / upToHowManyCatsOnScreen; //Unfortunately this only adjust the hitbox, not the graphic.
			options[prakstend].setGraphicSize(Std.int(Math.max(background.width / upToHowManyCatsOnSecond, options[prakstend].width)),
				Std.int(options[prakstend].height));
			options[prakstend].x = (background.width / upToHowManyCatsOnSecond) * i;
			options[prakstend].y = 10; // JOELwindows7: maybe like this?
			// I guess..
			// oh almost forgot!
			options[prakstend].titleObject.x = options[prakstend].x + (options[prakstend].width / 2) - (options[prakstend].titleObject.width / 2);
			options[prakstend].titleObject.y = options[prakstend].y + 10;
			// Wow, GitHub Copilot sentience yeay!
		}
	}

	// JOELwindows7: BOLO has option color!?!?!??!
	function updateOptColors():Void
	{
		for (i in 0...selectedCat.optionObjects.length)
		{
			// JOELwindows7: okay new way!
			var ref = selectedCat.optionObjects.members[i];
			var ruf = selectedCat.options[i];
			ref.color = ruf.cannotInPause ? FlxColor.YELLOW : FlxColor.WHITE;
		}
		if (selectedCatIndex == 0)
		{
			#if html5
			selectedCat.optionObjects.members[8].color = FlxColor.YELLOW;
			#end
			if (FlxG.save.data.optimize)
				selectedCat.optionObjects.members[11].color = FlxColor.YELLOW;
		}
		if (FlxG.save.data.optimize && selectedCatIndex == 3)
		{
			selectedCat.optionObjects.members[1].color = FlxColor.YELLOW;
			selectedCat.optionObjects.members[2].color = FlxColor.YELLOW;
		}
		if (!FlxG.save.data.background && selectedCatIndex == 3)
		{
			selectedCat.optionObjects.members[2].color = FlxColor.YELLOW;
		}
		if (selectedCatIndex == 1)
		{
			if (!FlxG.save.data.healthBar)
				selectedCat.optionObjects.members[12].color = FlxColor.YELLOW;
		}

		if (isInPause) // DUPLICATED CUZ MEMORY LEAK OR SMTH IDK
		{
			switch (selectedCatIndex)
			{
				case 0:
					selectedCat.optionObjects.members[2].color = FlxColor.YELLOW;
					selectedCat.optionObjects.members[14].color = FlxColor.YELLOW;
					if (PlayState.isStoryMode)
						selectedCat.optionObjects.members[7].color = FlxColor.YELLOW;
				case 1:
					selectedCat.optionObjects.members[17].color = FlxColor.YELLOW;
				case 3:
					for (i in 0...3)
						selectedCat.optionObjects.members[i].color = FlxColor.YELLOW;
				case 4:
					for (i in 0...4)
						selectedCat.optionObjects.members[i].color = FlxColor.YELLOW;
			}
		}

		// JOELwindows7: this is way too inellegant!! I gotta fix this!
		if (!isInCat)
		{
			if (selectedOptionIndex == 12 && !FlxG.save.data.healthBar && selectedCatIndex == 1)
			{
				descText.text = "HEALTH BAR IS DISABLED! Colored health bar are disabled.";
				descText.color = FlxColor.YELLOW;
			}
			if (selectedOptionIndex == 1 && FlxG.save.data.optimize && selectedCatIndex == 3)
			{
				descText.text = "OPTIMIZATION IS ENABLED! Distracions are disabled.";
				descText.color = FlxColor.YELLOW;
			}
			if (selectedOptionIndex == 2 && FlxG.save.data.optimize && selectedCatIndex == 3)
			{
				descText.text = "OPTIMIZATION IS ENABLED! Backgrounds are disabled.";
				descText.color = FlxColor.YELLOW;
			}
			if (selectedOptionIndex == 2 && !FlxG.save.data.background && selectedCatIndex == 3)
			{
				descText.text = "BACKGROUNDS ARE DISABLED! Distracions are disabled.";
				descText.color = FlxColor.YELLOW;
			}
			if (selectedOptionIndex == 9 && FlxG.save.data.optimize && selectedCatIndex == 0)
			{
				descText.text = "OPTIMIZATION IS ENABLED! Cam Zooming is disabled.";
				descText.color = FlxColor.YELLOW;
			}
			#if html5
			if (selectedOptionIndex == 6 && selectedCatIndex == 0)
			{
				descText.text = "FPS cap setting is disabled in browser build.";
				descText.color = FlxColor.YELLOW;
			}
			#end
			if (descText.text == "BOTPLAY is disabled on Story Mode.")
			{
				descText.color = FlxColor.YELLOW;
			}
			if (descText.text == "This option cannot be toggled in the pause menu.")
				descText.color = FlxColor.YELLOW;
		}
	}

	// JOELwindows7: darn you Kade!!! why let anyone inherit from FlxSubState instead of MusicBeat Substate?!?!??!
	override function manageMouse()
	{
		// JOELwindows7: make mouse visible when moved.
		if (FlxG.mouse.justMoved)
		{
			// trace("mouse moved");
			FlxG.mouse.visible = true;
		}
		// JOELwindows7: detect any keypresses or any button presses
		if (FlxG.keys.justPressed.ANY)
		{
			// lmao! inspire from GameOverState.hx!
			FlxG.mouse.visible = false;
		}
		if (FlxG.gamepads.lastActive != null)
		{
			if (FlxG.gamepads.lastActive.justPressed.ANY)
			{
				FlxG.mouse.visible = false;
			}
			// peck this I'm tired! plns work lol
		}

		// JOELwindows7: query every single menu category and each items
		// inspire this from MainMenuState like before!

		// JOELwindows7: check if you have clicked on a category. whoah, GitHub Copilot sentience finally kicks in!
		for (i in 0...options.length - 1)
		{
			if (FlxG.mouse.overlaps(options[i]) && !FlxG.mouse.overlaps(backButton) && !FlxG.mouse.overlaps(leftButton)
				&& !FlxG.mouse.overlaps(rightButton) && !FlxG.mouse.overlaps(upButton) && !FlxG.mouse.overlaps(downButton))
			{
				if (FlxG.mouse.justPressed)
				{
					if (options[i].ID == selectedCatIndex)
					{
						haveClicked = true;
					}
					else
					{
						goToCategory(options[i].ID);
					}
				}
			}
		}

		// JOELwindows7: check if you have clicked on an item.
		shownStuff.forEach(function(stuff:FlxUIText)
		{
			if (stuff != null)
			{
				if (FlxG.mouse.overlaps(stuff))
				{
					if (FlxG.mouse.justPressed)
					{
						if (stuff.ID == selectedOptionIndex)
						{
							haveClicked = true;
						}
						else
						{
							goToSelection(stuff.ID);
							haveClicked = false;
						}

						// JOELwindows7: but it's not perfect.
					}
					else
					{
						haveClicked = false;
					}
				}
				else
				{
					// JOELwindows7: back button for no keyboard
					if (FlxG.mouse.overlaps(backButton) && !FlxG.mouse.overlaps(stuff))
					{
						if (FlxG.mouse.justPressed)
						{
							haveBacked = true;
						}
						else
						{
							// haveBacked = false;
						}
					}
					if (FlxG.mouse.overlaps(leftButton) && !FlxG.mouse.overlaps(stuff))
					{
						if (FlxG.mouse.justPressed)
						{
							haveLefted = true;
						}
						else
						{
							haveLefted = false;
						}
					}
					if (FlxG.mouse.overlaps(rightButton) && !FlxG.mouse.overlaps(stuff))
					{
						if (FlxG.mouse.justPressed)
						{
							haveRighted = true;
						}
						else
						{
							haveRighted = false;
						}
					}
					if (FlxG.mouse.overlaps(upButton) && !FlxG.mouse.overlaps(stuff))
					{
						if (FlxG.mouse.justPressed)
						{
							haveUpped = true;
						}
						else
						{
							haveUpped = false;
						}
					}
					if (FlxG.mouse.overlaps(downButton) && !FlxG.mouse.overlaps(stuff))
					{
						if (FlxG.mouse.justPressed)
						{
							haveDowned = true;
						}
						else
						{
							haveDowned = false;
						}
					}
				}
			}
		});
	}

	// JOELwindows7: clear currently running tween first!
	function cancelTweenSo()
	{
		if (menuTweenSo != null)
		{
			for (i in 0...menuTweenSo.length)
			{
				if (menuTweenSo[i] != null)
				{
					for (j in 0...menuTweenSo[i].length)
					{
						if (menuTweenSo[i][j] != null)
						{
							menuTweenSo[i][j].cancel();
							menuTweenSo[i][j].destroy();
						}
					}
				}
			}
		}
	}
}
