package;

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

class OptionCata extends FlxSprite
{
	public var title:String;
	public var options:Array<Option>;

	public var optionObjects:FlxTypedGroup<FlxText>;

	public var titleObject:FlxText;

	public var middle:Bool = false;

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

		titleObject = new FlxText((middleType ? 1180 / 2 : x), y + (middleType ? 0 : 16), 0, title);
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
			var text:FlxText = new FlxText((middleType ? 1180 / 2 : 72), titleObject.y + 54 + (46 * i), 0, opt.getValue());
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

	public var background:FlxSprite;

	public var selectedCat:OptionCata;

	public var selectedOption:Option;

	public var selectedCatIndex = 0;
	public var selectedOptionIndex = 0;

	public var isInCat:Bool = false;

	public var options:Array<OptionCata>;

	public static var isInPause = false;

	public var shownStuff:FlxTypedGroup<FlxText>;

	public static var visibleRange = [114, 640]; // JOELwindows7: was 640

	public var upToHowManyCatsOnScreen:Int = 6; // JOELwindows7: by default there was 4 categories.

	public function new(pauseMenu:Bool = false)
	{
		super();

		isInPause = pauseMenu;
	}

	public var menu:FlxTypedGroup<FlxSprite>;

	public var descText:FlxText;
	public var descBack:FlxSprite;

	override function create()
	{
		options = [
			new OptionCata(50, 40, "Gameplay", [
				new ScrollSpeedOption("Change your scroll speed. (1 = Chart dependent)"),
				new OffsetThing("Change the note audio offset (how many milliseconds a note is offset in a chart)"),
				new AccuracyDOption("Change how accuracy is calculated. (Accurate = Simple, Complex = Milisecond Based)"),
				new GhostTapOption("Toggle counting pressing a directional input when no arrow is there as a miss."),
				new DownscrollOption("Toggle making the notes scroll down rather than up."),
				new BotPlay("A bot plays for you!"),
				#if desktop new FPSCapOption("Change your FPS Cap."),
				#end
				new ResetButtonOption("Toggle pressing R to gameover."),
				new InstantRespawn("Toggle if you instantly respawn after dying."),
				new CamZoomOption("Toggle the camera zoom in-game."),
				// new OffsetMenu("Get a note offset based off of your inputs!"),
				new DFJKOption(),
				new Judgement("Create a custom judgement preset"),
				new CustomizeGameplay("Drag and drop gameplay modules to your prefered positions!"),

			]),
			new OptionCata(345, 40, "Appearance", [
				new NoteskinOption("Change your current noteskin"), new EditorRes("Not showing the editor grid will greatly increase editor performance"),
				new DistractionsAndEffectsOption("Toggle stage distractions that can hinder your gameplay."),
				new MiddleScrollOption("Put your lane in the center or on the right."), new HealthBarOption("Toggles health bar visibility"),
				new JudgementCounter("Show your judgements that you've gotten in the song"),
				new LaneUnderlayOption("How transparent your lane is, higher = more visible."),
				new StepManiaOption("Sets the colors of the arrows depending on quantization instead of direction."),
				new AccuracyOption("Display accuracy information on the info bar."),
				new SongPositionOption("Show the song's current position as a scrolling bar."),
				new Colour("The color behind icons now fit with their theme. (e.g. Pico = green)"),
				new NPSDisplayOption("Shows your current Notes Per Second on the info bar."),
				new RainbowFPSOption("Make the FPS Counter flicker through rainbow colors."),
				new CpuStrums("Toggle the CPU's strumline lighting up when it hits a note."),
			]),
			// JOELwindows7: Audio
			new OptionCata(640, 40, 'Audio', [
				new AdjustVolumeOption("Adjust Audio volume"),
				// new MissSoundsOption("Toggle miss sounds playing when you don't hit a note."), //JOELwindows7: how about move it here?
				new SurroundTestOption("EXPERIMENTAL! Open 7.1 surround sound tester with Lime AudioSource"),
				// new AnMIDITestOption("EXPERIMENTAL! Open MIDI output test room"),
			]),
			// JOELwindows7: Account options
			new OptionCata(935, 40, 'Accounts', [
				new LogGameJoltIn(#if gamejolt "(" + GameJoltAPI.getUserInfo(true) +
					") Log your GameJolt account in" #else "GameJolt not supported. SADD!" #end)
			]),
			// JOELwindows7: was 640, 40
			new OptionCata(1040, 40, "Misc", [
				new FPSOption("Toggle the FPS Counter"),
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
				new ShowInput("Display every single input on the score screen."),
				new ExportSaveToJson("BETA! Export entire save data into JSON file"),
				new AnVideoCutscenerTestOption("EXPERIMENTAL! Test Video Cutscener capability"),
				new AnStarfieldTestOption("EXPERIMENTAL! Test FlxStarfield"),
				new AnDefaultBekgronTestOption("EXPERIMENTAL! Test default background of Hexagon Engine"),
				new AnChangeChannelOption("EXPERIMENTAL! Test change channel and rate"),
				// new OutOfSegsWarningOption("Toggle whether Out of Any Segs to be printed (`ON` WILL CAUSE LAG)"),
				new PrintSongChartContentOption("Toggle whether Song Chart to be printed (WILL DELAY LONGER THE CONTENT IS)"),
			]),
			// JOELwindows7: was 935, 40
			new OptionCata(1100, 40, "Saves", [
				#if desktop // new ReplayOption("View saved song replays."),
				#end
				new ResetScoreOption("Reset your score on all songs and weeks. This is irreversible!"),
				new LockWeeksOption("Reset your story mode progress. This is irreversible!"),
				new ResetSettings("Reset ALL your settings. This is irreversible!")
			]),
			// TODO: JOELwindows7: Category about for credits a& acknowledgements
			new OptionCata(-1, 125, "Editing Keybinds", [
				new LeftKeybind("The left note's keybind"), new DownKeybind("The down note's keybind"), new UpKeybind("The up note's keybind"),
				new RightKeybind("The right note's keybind"), new PauseKeybind("The keybind used to pause the game"),
				new ResetBind("The keybind used to die instantly"), new MuteBind("The keybind used to mute game audio"),
				new VolUpBind("The keybind used to turn the volume up"), new VolDownBind("The keybind used to turn the volume down"),
				new FullscreenBind("The keybind used to fullscreen the game")], true),
			new OptionCata(-1, 125, "Editing Judgements", [
				new SickMSOption("How many milliseconds are in the SICK hit window"),
				new GoodMsOption("How many milliseconds are in the GOOD hit window"),
				new BadMsOption("How many milliseconds are in the BAD hit window"),
				new ShitMsOption("How many milliseconds are in the SHIT hit window")
			], true),
		];

		instance = this;

		menu = new FlxTypedGroup<FlxSprite>();

		shownStuff = new FlxTypedGroup<FlxText>();

		// JOELwindows7: pinpoint, this is inner square
		background = new FlxSprite(50, 40).makeGraphic(1180, 640, FlxColor.BLACK);
		background.alpha = 0.5;
		background.scrollFactor.set();
		menu.add(background);

		descBack = new FlxSprite(50, 640).makeGraphic(1180, 38, FlxColor.BLACK);
		descBack.alpha = 0.3;
		descBack.scrollFactor.set();
		menu.add(descBack);

		if (isInPause)
		{
			// JOELwindows7: pinpoint, this is outer square that fill entire game screen when in Pause.
			var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
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
			if (i >= upToHowManyCatsOnScreen)
				continue;
			var cat = options[i];
			add(cat);
			add(cat.titleObject); // JOELwindows7: pinpoint, so you must take of this too.
			// Remember, this is not Godot where you can have node inside node recursively.
			// So, you can only have this title text thingy side by side, on top of the cat FlxSprite itself.
		}

		descText = new FlxText(62, 648);
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
			if (cat.middle)
				visibleRange = [Std.int(cat.titleObject.y), 640]; // JOELwindows7: was [the value, 640]
			if (selectedOption != null)
			{
				var object = selectedCat.optionObjects.members[selectedOptionIndex];
				object.text = selectedOption.getValue();
			}

			if (selectedCatIndex > options.length - 3 && checkForOutOfBounds)
				selectedCatIndex = 0;

			if (selectedCat.middle)
				remove(selectedCat.titleObject);

			selectedCat.changeColor(FlxColor.BLACK);
			selectedCat.alpha = 0.3;

			for (i in 0...selectedCat.options.length)
			{
				var opt = selectedCat.optionObjects.members[i];
				opt.y = selectedCat.titleObject.y + 54 + (46 * i);
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
			Debug.logError("oops\n" + e);
			selectedCatIndex = 0;
		}

		Debug.logTrace("Changed cat: " + selectedCatIndex);
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

					if (selectedCatIndex > options.length - 3)
						selectedCatIndex = 0;
					if (selectedCatIndex < 0)
						selectedCatIndex = options.length - 3;

					switchCat(options[selectedCatIndex]);
				}
				else if (left)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();
					selectedCatIndex--;

					if (selectedCatIndex > options.length - 3)
						selectedCatIndex = 0;
					if (selectedCatIndex < 0)
						selectedCatIndex = options.length - 3;

					switchCat(options[selectedCatIndex]);
				}

				if (accept)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					selectedOptionIndex = 0;
					isInCat = false;
					selectOption(selectedCat.options[0]);

					haveClicked = false; // JOELwindows7: don't forget
				}

				if (escape)
				{
					if (!isInPause)
						FlxG.switchState(new MainMenuState());
					else
					{
						PauseSubState.goBack = true;
						PlayStateChangeables.scrollSpeed = FlxG.save.data.scrollSpeed * PlayState.songMultiplier;
						close();
					}

					haveBacked = false; // JOELwindows7: don't forget
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
							haveBacked = false; // JOELwindows7: whie
							return;
						}
						else if (any)
						{
							var object = selectedCat.optionObjects.members[selectedOptionIndex];
							selectedOption.onType(gamepad == null ? FlxG.keys.getIsDown()[0].ID.toString() : gamepad.firstJustPressedID());
							object.text = "> " + selectedOption.getValue();
							Debug.logTrace("New text: " + object.text);
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
					}

					if (down)
					{
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
								opt.y = selectedCat.titleObject.y + 54 + (46 * i);
							}
							selectedOptionIndex = 0;
						}

						if (selectedOptionIndex != 0
							&& selectedOptionIndex != options[selectedCatIndex].options.length - 1
							&& options[selectedCatIndex].options.length > 6)
						{
							if (selectedOptionIndex >= (options[selectedCatIndex].options.length - 1) / 2)
								for (i in selectedCat.optionObjects.members)
								{
									i.y -= 46;
								}
						}

						selectOption(options[selectedCatIndex].options[selectedOptionIndex]);
						haveDowned = false; // JOELwindows7: yea
						haveClicked = false; // JOELwindows7: mouse supports
					}
					else if (up)
					{
						if (selectedOption.acceptType)
							selectedOption.waitingType = false;
						FlxG.sound.play(Paths.sound('scrollMenu'));
						selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();
						selectedOptionIndex--;

						// just kinda ignore this math lol

						if (selectedOptionIndex < 0)
						{
							selectedOptionIndex = options[selectedCatIndex].options.length - 1;

							if (options[selectedCatIndex].options.length > 6)
								for (i in selectedCat.optionObjects.members)
								{
									i.y -= (46 * ((options[selectedCatIndex].options.length - 1) / 2));
								}
						}

						if (selectedOptionIndex != 0 && options[selectedCatIndex].options.length > 6)
						{
							if (selectedOptionIndex >= (options[selectedCatIndex].options.length - 1) / 2)
								for (i in selectedCat.optionObjects.members)
								{
									i.y += 46;
								}
						}

						if (selectedOptionIndex < (options[selectedCatIndex].options.length - 1) / 2)
						{
							for (i in 0...selectedCat.options.length)
							{
								var opt = selectedCat.optionObjects.members[i];
								opt.y = selectedCat.titleObject.y + 54 + (46 * i);
							}
						}

						selectOption(options[selectedCatIndex].options[selectedOptionIndex]);
						haveUpped = false; // JOELwindows7: yep
						haveClicked = false; // JOELwindows7: mouse supports
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
					}

					if (escape)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));

						if (selectedCatIndex >= 4)
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

						haveBacked = false; // JOELwindows7: okeh.
					}
				}
			}
		}
		catch (e)
		{
			Debug.logError("wtf we actually did something wrong, but we dont crash bois.\n" + e);
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
		}

		// JOELwindows7: wtf, FlxSubstate? not MusicBeatSubstate?!
		manageMouse(); // JOELwindows7: WHY THE PECK INHERIT FROM FlxSubState?!?!?!?
	}

	// JOELwindows7: copy from above but this time set the selection number
	function goToSelection(change:Int = 0)
	{
		if (!rawMouseHeld) // Only if you had not held mouse.
		{
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
					opt.y = selectedCat.titleObject.y + 54 + (46 * i);
				}
				selectedOptionIndex = 0;
			}

			if (selectedOptionIndex != 0
				&& selectedOptionIndex != options[selectedCatIndex].options.length - 1
				&& options[selectedCatIndex].options.length > 6)
			{
				if (selectedOptionIndex >= (options[selectedCatIndex].options.length - 1) / 2)
					for (i in selectedCat.optionObjects.members)
					{
						i.y -= 46;
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
	public static function switchState(ofHere:FlxState)
	{
		if (isInPause)
		{
			// JOELwindows7: it's static method, you cannot access any instance method of this class.
			Main.gjToastManager.createToast(null, "Cannot access option", "Please leave the gameplay before accessing this option.");
			return;
		}
		FlxG.switchState(ofHere);
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
		selectedCat.optionObjects.forEach(function(option:FlxText)
		{
			option.ID = count;
			count++;
		});
	}

	// JOELwindows7: we need to tidy the categories first
	function tidyThoseCats()
	{
		for (i in 0...options.length - 1)
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
		shownStuff.forEach(function(stuff:FlxText)
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
		});
	}
}
