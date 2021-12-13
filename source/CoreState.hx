/*
 * GNU General Public License, Version 3.0
 *
 * Copyright (c) 2021 Perkedel
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package;

import ui.FlxVirtualPad;
import flixel.input.actions.FlxActionInput;
import plugins.sprites.DVDScreenSaver;
import haxe.Json;
import flixel.FlxG;
import flixel.FlxCamera;
import flixel.group.FlxGroup;
import flixel.addons.display.FlxStarField;
import flixel.FlxSprite;
import TouchScreenControls;
import plugins.sprites.QmovephBackground;
import flixel.addons.display.FlxBackdrop;
import MusicBeatState;
import lime.utils.Assets;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.ui.FlxUIState;

using StringTools;

// JOELwindows7: let's inspire from Song.hx.
// here's the typedef for Json file of weekList yess.

/** let's inspire from Song.hx.
 * here's the typedef for Json file of weekList yess.
 * @author JOELwindows7
 */
typedef SwagWeeks =
{
	var weekData:Array<Dynamic>;
	var weekUnlocked:Array<Bool>;
	var weekCharacters:Array<Dynamic>;
	var weekNames:Array<String>;
	var weekColor:Array<String>;
	var ?weekBannerPath:Array<String>;
	var ?weekUnderlayPath:Array<String>;
	var ?weekClickSoundPath:Array<String>;
}

/** Your Loading Type. what's status is it.
 * @author JOELwindows7
 */
enum ExtraLoadingType
{
	NONE;
	VAGUE;
	GOING;
	DONE;
}

// TODO: JOELwindows7: make granular week data like Psych
// https://github.com/ShadowMario/FNF-PsychEngine

/**
 * Alright, that's it. I'm pissed off. Let's settle this.
 * Now, here the CoreState. all things that I add to State & SubState, will be here in each respective class.
 * From now on, using this mod or if you merge that up, inherit from here.
 * We got all stuff that should be here with compensation for all platform & peripherals as all as possible.
 * 
 * GNU GPL v3
 * @author JOELwindows7
 */
class CoreState extends FlxUIState
{
	// JOELwindows7: copy screen size
	private var screenWidth:Int = FlxG.width;
	private var screenHeight:Int = FlxG.height;

	// JOELwindows7: mouse support flags
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

	var backButton:FlxSprite; // JOELwindows7: the back button here
	var leftButton:FlxSprite; // JOELwindows7: the left button here
	var rightButton:FlxSprite; // JOELwindows7: the right button here
	var upButton:FlxSprite; // JOELwindows7: the up button here
	var downButton:FlxSprite; // JOELwindows7: the down button here
	var pauseButton:FlxSprite; // JOELwindows7: the pause button here
	var acceptButton:FlxSprite; // JOELwindows7: the accept button here
	var retryButton:FlxSprite; // JOELwindows7: the retry button here
	var viewReplayButton:FlxSprite; // JOELwindows7: the view replay button here
	// JOELwindows7: starfields here.
	var starfield2D:FlxStarField2D;
	var starfield3D:FlxStarField3D;
	var multiStarfield2D:FlxTypedGroup<FlxStarField2D>;
	var multiStarfield3D:FlxTypedGroup<FlxStarField3D>;
	// var touchscreenButtons:TouchScreenControls; //JOELwindows7: the touchscreen buttons here
	var hourGlass:FlxSprite; // JOELwindows7: animated gravity hourglass Piskel

	// JOELwindows7: raw button situations
	var rawMouseHeld:Bool = false;

	public var onScreenGameplayButtons:OnScreenGameplayButtons; // JOELwindows7: the touchscreen buttons here

	public static var dueAdded:Bool = false;

	var defaultBekgron:FlxBackdrop;
	var qmovephBekgron:QmovephBackground;

	// JOELwindows7: touchscreen button stuffs
	// https://github.com/luckydog7/Funkin-android/blob/master/source/MusicBeatState.hx
	var _virtualpad:FlxVirtualPad;
	var trackedinputs:Array<FlxActionInput> = [];

	public var camControl:FlxCamera;

	// JOELwindows7: steal control var in order to make it work
	private var controls(get, never):Controls;

	// JOELwindows7: stuff OpenFl
	private var _loadingBar = Main.loadingBar;

	// JOELwindows7: and the control getter
	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create()
	{
		super.create();

		initCamControl(); // JOELwindows7: init the cam control now!
		// dedicated touchscreen button container
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		// JOELwindows7: manage Stuffs
		manageMouse();
	}

	// JOELwindows7: week loader
	// JOELwindows7: Okay so, cleanup Json? and then parse? okeh
	// yeah I know, I copied from Song.hx. for this one, the weekList.json isn't anywhere in special folder
	// but root of asset/data . that's all... idk
	public static function loadFromJson(jsonInput:String):SwagWeeks
	{
		var rawJson = Assets.getText(Paths.json(jsonInput)).trim();
		trace("load weeklist Json");

		while (!rawJson.endsWith("}"))
		{
			// JOELwindows7: okay also going through bullshit cleaning what the peck strange
			rawJson = rawJson.substr(0, rawJson.length - 1);
		}
		return parseJSONshit(rawJson);
	}

	// JOELwindows7: lol!literally copy from Song.hx minus the
	// changing valid score which SwagWeeks typedef doesn't have, idk..
	public static function parseJSONshit(rawJson:String):SwagWeeks
	{
		var swagShit:SwagWeeks = cast Json.parse(rawJson);
		return swagShit;
	}

	// JOELwindows7: init dedicated touchscreen buttons camera
	function initCamControl()
	{
		trace("setting dedicated touchscreen buttons camera");
		camControl = new FlxCamera();
		FlxG.cameras.add(camControl);
		camControl.bgColor.alpha = 0;
	}

	// JOELwindows7: buttons
	private function addBackButton(x:Int = 100, y:Int = 720 - 100, scale:Float = .5)
	{
		backButton = new FlxSprite(x, y).loadGraphic(Paths.image('backButton'));
		backButton.setGraphicSize(Std.int(backButton.width * scale), Std.int(backButton.height * scale));
		backButton.scrollFactor.set();
		backButton.updateHitbox();
		backButton.antialiasing = FlxG.save.data.antialiasing;
		if (camControl != null)
			backButton.cameras = [camControl];
		add(backButton);
		return backButton;
	}

	private function addLeftButton(x:Int = 100, y:Int = 1280 - 100, scale:Float = .5)
	{
		leftButton = new FlxSprite(x, y).loadGraphic(Paths.image('leftAdjustButton'));
		leftButton.setGraphicSize(Std.int(leftButton.width * scale), Std.int(leftButton.height * scale));
		leftButton.scrollFactor.set();
		leftButton.updateHitbox();
		leftButton.antialiasing = FlxG.save.data.antialiasing;
		if (camControl != null)
			leftButton.cameras = [camControl];
		add(leftButton);
		return leftButton;
	}

	private function addRightButton(x:Int = 525, y:Int = 1280 - 100, scale:Float = .5)
	{
		rightButton = new FlxSprite(x, y).loadGraphic(Paths.image('rightAdjustButton'));
		rightButton.setGraphicSize(Std.int(rightButton.width * scale), Std.int(rightButton.height * scale));
		rightButton.scrollFactor.set();
		rightButton.updateHitbox();
		rightButton.antialiasing = FlxG.save.data.antialiasing;
		if (camControl != null)
			rightButton.cameras = [camControl];
		add(rightButton);
		return rightButton;
	}

	private function addUpButton(x:Int = 240, y:Int = 1280 - 100, scale:Float = .5)
	{
		upButton = new FlxSprite(x, y).loadGraphic(Paths.image('upAdjustButton'));
		upButton.setGraphicSize(Std.int(upButton.width * scale), Std.int(upButton.height * scale));
		upButton.scrollFactor.set();
		upButton.updateHitbox();
		upButton.antialiasing = FlxG.save.data.antialiasing;
		if (camControl != null)
			upButton.cameras = [camControl];
		add(upButton);
		return upButton;
	}

	private function addDownButton(x:Int = 450, y:Int = 1280 - 100, scale:Float = .5)
	{
		downButton = new FlxSprite(x, y).loadGraphic(Paths.image('downAdjustButton'));
		downButton.setGraphicSize(Std.int(downButton.width * scale), Std.int(downButton.height * scale));
		downButton.scrollFactor.set();
		downButton.updateHitbox();
		downButton.antialiasing = FlxG.save.data.antialiasing;
		if (camControl != null)
			downButton.cameras = [camControl];
		add(downButton);
		return downButton;
	}

	private function addPauseButton(x:Int = 640, y:Int = 10, scale:Float = .5)
	{
		pauseButton = new FlxSprite(x, y).loadGraphic(Paths.image('pauseButton'));
		pauseButton.setGraphicSize(Std.int(pauseButton.width * scale), Std.int(pauseButton.height * scale));
		pauseButton.scrollFactor.set();
		pauseButton.updateHitbox();
		pauseButton.antialiasing = FlxG.save.data.antialiasing;
		if (camControl != null)
			pauseButton.cameras = [camControl];
		add(pauseButton);
		return pauseButton;
	}

	private function addAcceptButton(x:Int = 1280 - 100, y:Int = 720 - 100, scale:Float = .5)
	{
		acceptButton = new FlxSprite(x, y).loadGraphic(Paths.image('acceptButton'));
		acceptButton.setGraphicSize(Std.int(acceptButton.width * scale), Std.int(acceptButton.height * scale));
		acceptButton.scrollFactor.set();
		acceptButton.updateHitbox();
		acceptButton.antialiasing = FlxG.save.data.antialiasing;
		if (camControl != null)
			acceptButton.cameras = [camControl];
		add(acceptButton);
		return acceptButton;
	}

	private function addRetryButton(x:Int = 500, y:Int = 500, scale:Float = .5)
	{
		retryButton = new FlxSprite(x, y).loadGraphic(Paths.image('retryButton'));
		retryButton.setGraphicSize(Std.int(retryButton.width * scale), Std.int(retryButton.height * scale));
		retryButton.scrollFactor.set();
		retryButton.updateHitbox();
		retryButton.antialiasing = FlxG.save.data.antialiasing;
		if (camControl != null)
			retryButton.cameras = [camControl];
		add(retryButton);
		return retryButton;
	}

	private function addViewReplayButton(x:Int = 500, y:Int = 500, scale:Float = .5)
	{
		viewReplayButton = new FlxSprite(x, y).loadGraphic(Paths.image('viewReplayButton'));
		viewReplayButton.setGraphicSize(Std.int(viewReplayButton.width * scale), Std.int(viewReplayButton.height * scale));
		viewReplayButton.scrollFactor.set();
		viewReplayButton.updateHitbox();
		viewReplayButton.antialiasing = FlxG.save.data.antialiasing;
		if (camControl != null)
			viewReplayButton.cameras = [camControl];
		add(viewReplayButton);
		return viewReplayButton;
	}

	private function installBusyHourglassScreenSaver()
	{
		hourGlass = new DVDScreenSaver(null, 100, 100);
		hourGlass.frames = Paths.getSparrowAtlas('Gravity-HourGlass');
		hourGlass.animation.addByPrefix('working', 'Gravity-HourGlass idle', 24);
		hourGlass.animation.play('working');
		hourGlass.updateHitbox();
		add(hourGlass);
		return hourGlass;
	}

	private function addTouchScreenButtons(howManyButtons:Int = 4, initVisible:Bool = false)
	{
		/*
			touchscreenButtons = new TouchScreenControls(howManyButtons, initVisible);
			touchscreenButtons.initDoseButtons();
			add(touchscreenButtons);
		 */
		var _alreadyAdded:Array<Bool> = [false, false, false, false];
		trace("init the touchscreen buttons");
		if (onScreenGameplayButtons == null)
		{
			onScreenGameplayButtons = new OnScreenGameplayButtons(howManyButtons, initVisible);
			// _alreadyAdded = onScreenGameplayButtons._alreadyAdded;
		}
		if (true)
			switch (Std.int(FlxG.save.data.selectTouchScreenButtons))
			{
				case 0:
					trace("No touch screen button to init at all.");
				case 1:
					trace("hitbox the touchscreen buttons");
					if (_alreadyAdded[1] == false)
						controls.installTouchScreenGameplays(onScreenGameplayButtons._hitbox, howManyButtons);
				case 2:
					trace("Left side touchscreen buttons only");
					if (_alreadyAdded[2] == false)
						controls.setVirtualPad(onScreenGameplayButtons._virtualPad, FULL, NONE, true);
				case 3:
					trace("Right side touchscreen buttons only");
					if (_alreadyAdded[3] == false)
						controls.setVirtualPad(onScreenGameplayButtons._virtualPad, NONE, A_B_X_Y, true);
				case 4:
					trace("Full gamepad touchscreen");
					if (_alreadyAdded[4] == false)
						controls.setVirtualPad(onScreenGameplayButtons._virtualPad, FULL, A_B_X_Y, true);
				default:
					trace("huh? what do you mean? we don't know this touch buttons type\nUgh fine I guess you are my little pogchamp, come here.");
					// lmao! gothmei reference & PEAR animated it this
			}
		else
			trace("due has already added bruh");
		dueAdded = true;
		_alreadyAdded[Std.int(FlxG.save.data.selectTouchScreenButtons)] = true;
		trackedinputs = controls.trackedinputs;
		// if(onScreenGameplayButtons != null)
		// 	onScreenGameplayButtons.initialize(howManyButtons, initVisible);
		controls.trackedinputs = [];
		if (camControl == null)
		{
			initCamControl();
			onScreenGameplayButtons.cameras = [camControl];
		}
		else
		{
			camControl.bgColor.alpha = 0;
			onScreenGameplayButtons.cameras = [camControl];
		}
		onScreenGameplayButtons.visible = initVisible;

		add(onScreenGameplayButtons);
	}

	public function showOnScreenGameplayButtons()
	{
		if (onScreenGameplayButtons != null)
			onScreenGameplayButtons.visible = true;
	}

	public function hideOnScreenGameplayButtons()
	{
		if (onScreenGameplayButtons != null)
			onScreenGameplayButtons.visible = false;
	}

	public function removeTouchScreenButtons()
	{
		if (onScreenGameplayButtons != null)
		{
			trace("uninstall touchscreen buttonings");
			controls.trackedinputs = trackedinputs;
			switch (Std.int(FlxG.save.data.selectTouchScreenButtons))
			{
				case 0:
					trace("No touch screen button to init at all.");
				case 1:
					trace("hitbox the touchscreen buttons");
					controls.uninstallTouchScreenGameplays(onScreenGameplayButtons._hitbox);
				case 2:
					trace("Left side touchscreen buttons only");
					controls.unsetVirtualPad(onScreenGameplayButtons._virtualPad, FULL, NONE, true);
				case 3:
					trace("Right side touchscreen buttons only");
					controls.unsetVirtualPad(onScreenGameplayButtons._virtualPad, NONE, A_B_X_Y, true);
				case 4:
					trace("Full gamepad touchscreen");
					controls.unsetVirtualPad(onScreenGameplayButtons._virtualPad, FULL, A_B_X_Y, true);
				default:
					trace("huh? what do you mean? we don't know this touch buttons type\nUgh fine I guess you are my little pogchamp, come here.");
					// lmao! gothmei reference & PEAR animated it this
			}
			/*
				for(i in 0..trackedinputs.length){
					controls.deleteActionButtonings(action, trackedinputs[i]);
				}
			 */
			/*
				FlxTween.tween(onScreenGameplayButtons,{alpha:0}, 1, {ease:FlxEase.circInOut, onComplete: function(tween:FlxTween){
					onScreenGameplayButtons.visible = false;
					trackedinputs = [];
					onScreenGameplayButtons.destroy();
				}});
			 */
			/*
				FlxTween.num(onScreenGameplayButtons.alpha,0,1,
					{ease:FlxEase.circInOut, 
						onComplete: function(tween:FlxTween){
							onScreenGameplayButtons.visible = false;
							//trackedinputs = [];
							//onScreenGameplayButtons.destroy();
						}
					}, 
					function (a:Float) { 
						onScreenGameplayButtons.alpha = a; 
				});
			 */
			onScreenGameplayButtons.visible = false;
		}
	}

	// JOELwindows7: install starfield
	function installStarfield2D(x:Int = 0, y:Int = 0, width:Int = 0, height:Int = 0, starAmount:Int = 300, inArray:Bool = false):FlxStarField2D
	{
		if (inArray)
		{
			var starfielding = new FlxStarField2D(x, y, width, height, starAmount);
			var id:Int = multiStarfield2D.length;
			starfielding.ID = id;
			multiStarfield2D.add(starfielding);
			add(starfielding);
			return starfielding;
		}
		else
		{
			starfield2D = new FlxStarField2D(x, y, width, height, starAmount);
			add(starfield2D);
			return starfield2D;
		}
	}

	function installStarfield3D(x:Int = 0, y:Int = 0, width:Int = 0, height:Int = 0, starAmount:Int = 300, inArray:Bool = false):FlxStarField3D
	{
		if (inArray)
		{
			var starfielding = new FlxStarField3D(x, y, width, height, starAmount);
			var id:Int = multiStarfield2D.length;
			starfielding.ID = id;
			multiStarfield3D.add(starfielding);
			add(starfielding);
			return starfielding;
		}
		else
		{
			starfield3D = new FlxStarField3D(x, y, width, height, starAmount);
			add(starfield3D);
			return starfield3D;
		}
	}

	function installDefaultBekgron()
	{
		defaultBekgron = new FlxBackdrop(Paths.image('DefaultBackground-720p'), 50, 0, true, false);
		// defaultBekgron.setGraphicSize(FlxG.width,FlxG.height);
		defaultBekgron.velocity.x = -100;
		defaultBekgron.updateHitbox();
		add(defaultBekgron);
	}

	function justInitDefaultBekgron():FlxBackdrop
	{
		var theBekgron:FlxBackdrop = new FlxBackdrop(Paths.image('DefaultBackground-720p'), 50, 0, true, false);
		theBekgron.velocity.x = -100;
		theBekgron.updateHitbox();
		return theBekgron;
	}

	function installSophisticatedDefaultBekgron()
	{
		qmovephBekgron = new QmovephBackground();
		add(qmovephBekgron);
		qmovephBekgron.startDoing();
	}

	/**
	 * Create Toast message using TentaRJ x Firubii technology
	 * @author JOELwindows7
	 * @param iconPath the path to the icon image file
	 * @param title title of the toast message
	 * @param description description of the toast message
	 * @param sound whether to play a sound or not
	 */
	public function createToast(iconPath:String, title:String, description:String, sound:Bool = false)
	{
		Main.gjToastManager.createToast(iconPath, title, description, sound);
	}

	function manageMouse():Void
	{
		// JOELwindows7: nothing. use this special update to manage mouse

		// JOELwindows7: check hold & release mouse
		if (FlxG.mouse.justPressed)
		{
			rawMouseHeld = true;
		}
		if (FlxG.mouse.justReleased)
		{
			rawMouseHeld = false;
		}
	}
}

/**Now for the FlxSubstate with my spice yeah!
 * 
 * @author JOELwindows7
 */
class CoreSubState extends FlxSubState
{
	// JOELwindows7: mouse support flags
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

	var backButton:FlxSprite; // JOELwindows7: the back button here
	var leftButton:FlxSprite; // JOELwindows7: the left button here
	var rightButton:FlxSprite; // JOELwindows7: the right button here
	var upButton:FlxSprite; // JOELwindows7: the up button here
	var downButton:FlxSprite; // JOELwindows7: the down button here
	var pauseButton:FlxSprite; // JOELwindows7: the pause button here
	var acceptButton:FlxSprite; // JOELwindows7: the accept button here
	var retryButton:FlxSprite; // JOELwindows7: the retry button here
	var viewReplayButton:FlxSprite; // JOELwindows7: the view replay button here

	public var camControl:FlxCamera;

	// JOELwindows7: raw button situations
	var rawMouseHeld:Bool = false;

	// JOELwindows7: steal control in order to make it work
	private var controls(get, never):Controls;

	// JOELwindows7: stuff OpenFl
	private var _loadingBar = Main.loadingBar;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	public function new()
	{
		super();
	}

	override function create()
	{
		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		manageMouse();
	}

	override function destroy()
	{
		super.destroy();
	}

	// JOELwindows7: init dedicated touchscreen buttons camera
	function initCamControl()
	{
		trace("setting dedicated touchscreen buttons camera");
		camControl = new FlxCamera();
		FlxG.cameras.add(camControl);
		camControl.bgColor.alpha = 0;
	}

	// JOELwindows7: buttons
	private function addBackButton(x:Int = 720 - 200, y:Int = 1280 - 100, scale:Float = .5)
	{
		backButton = new FlxSprite(x, y).loadGraphic(Paths.image('backButton'));
		backButton.setGraphicSize(Std.int(backButton.width * scale), Std.int(backButton.height * scale));
		backButton.scrollFactor.set();
		backButton.updateHitbox();
		backButton.antialiasing = FlxG.save.data.antialiasing;
		if (camControl != null)
			backButton.cameras = [camControl];
		add(backButton);
		return backButton;
	}

	private function addLeftButton(x:Int = 100, y:Int = 1280 - 100, scale:Float = .5)
	{
		leftButton = new FlxSprite(x, y).loadGraphic(Paths.image('leftAdjustButton'));
		leftButton.setGraphicSize(Std.int(leftButton.width * scale), Std.int(leftButton.height * scale));
		leftButton.scrollFactor.set();
		leftButton.updateHitbox();
		leftButton.antialiasing = FlxG.save.data.antialiasing;
		if (camControl != null)
			leftButton.cameras = [camControl];
		add(leftButton);
		return leftButton;
	}

	private function addRightButton(x:Int = 525, y:Int = 1280 - 100, scale:Float = .5)
	{
		rightButton = new FlxSprite(x, y).loadGraphic(Paths.image('rightAdjustButton'));
		rightButton.setGraphicSize(Std.int(rightButton.width * scale), Std.int(rightButton.height * scale));
		rightButton.scrollFactor.set();
		rightButton.updateHitbox();
		rightButton.antialiasing = FlxG.save.data.antialiasing;
		if (camControl != null)
			rightButton.cameras = [camControl];
		add(rightButton);
		return rightButton;
	}

	private function addUpButton(x:Int = 240, y:Int = 1280 - 100, scale:Float = .5)
	{
		upButton = new FlxSprite(x, y).loadGraphic(Paths.image('upAdjustButton'));
		upButton.setGraphicSize(Std.int(upButton.width * scale), Std.int(upButton.height * scale));
		upButton.scrollFactor.set();
		upButton.updateHitbox();
		upButton.antialiasing = FlxG.save.data.antialiasing;
		if (camControl != null)
			upButton.cameras = [camControl];
		add(upButton);
		return upButton;
	}

	private function addDownButton(x:Int = 450, y:Int = 1280 - 100, scale:Float = .5)
	{
		downButton = new FlxSprite(x, y).loadGraphic(Paths.image('downAdjustButton'));
		downButton.setGraphicSize(Std.int(downButton.width * scale), Std.int(downButton.height * scale));
		downButton.scrollFactor.set();
		downButton.updateHitbox();
		downButton.antialiasing = FlxG.save.data.antialiasing;
		if (camControl != null)
			downButton.cameras = [camControl];
		add(downButton);
		return downButton;
	}

	private function addPauseButton(x:Int = 640, y:Int = 10, scale:Float = .5)
	{
		pauseButton = new FlxSprite(x, y).loadGraphic(Paths.image('pauseButton'));
		pauseButton.setGraphicSize(Std.int(pauseButton.width * scale), Std.int(pauseButton.height * scale));
		pauseButton.scrollFactor.set();
		pauseButton.updateHitbox();
		pauseButton.antialiasing = FlxG.save.data.antialiasing;
		if (camControl != null)
			pauseButton.cameras = [camControl];
		add(pauseButton);
		return pauseButton;
	}

	private function addAcceptButton(x:Int = 1280, y:Int = 360, scale:Float = .5)
	{
		acceptButton = new FlxSprite(x, y).loadGraphic(Paths.image('acceptButton'));
		acceptButton.setGraphicSize(Std.int(acceptButton.width * scale), Std.int(acceptButton.height * scale));
		acceptButton.scrollFactor.set();
		acceptButton.updateHitbox();
		acceptButton.antialiasing = FlxG.save.data.antialiasing;
		if (camControl != null)
			acceptButton.cameras = [camControl];
		add(acceptButton);
		return acceptButton;
	}

	private function addRetryButton(x:Int = 500, y:Int = 500, scale:Float = .5)
	{
		retryButton = new FlxSprite(x, y).loadGraphic(Paths.image('retryButton'));
		retryButton.setGraphicSize(Std.int(retryButton.width * scale), Std.int(retryButton.height * scale));
		retryButton.scrollFactor.set();
		retryButton.updateHitbox();
		retryButton.antialiasing = FlxG.save.data.antialiasing;
		if (camControl != null)
			retryButton.cameras = [camControl];
		add(retryButton);
		return retryButton;
	}

	private function addViewReplayButton(x:Int = 500, y:Int = 500, scale:Float = .5)
	{
		viewReplayButton = new FlxSprite(x, y).loadGraphic(Paths.image('viewReplayButton'));
		viewReplayButton.setGraphicSize(Std.int(viewReplayButton.width * scale), Std.int(viewReplayButton.height * scale));
		viewReplayButton.scrollFactor.set();
		viewReplayButton.updateHitbox();
		viewReplayButton.antialiasing = FlxG.save.data.antialiasing;
		if (camControl != null)
			viewReplayButton.cameras = [camControl];
		add(viewReplayButton);
		return viewReplayButton;
	}

	/**
	 * Create Toast message using TentaRJ x Firubii technology
	 * @author JOELwindows7
	 * @param iconPath the path to the icon image file
	 * @param title title of the toast message
	 * @param description description of the toast message
	 * @param sound whether to play a sound or not
	 */
	public function createToast(iconPath:String, title:String, description:String, sound:Bool = false)
	{
		Main.gjToastManager.createToast(iconPath, title, description, sound);
	}

	function manageMouse():Void
	{
		// JOELwindows7: nothing. use this to manage mouse

		// JOELwindows7: check hold & release mouse
		if (FlxG.mouse.justPressed)
		{
			rawMouseHeld = true;
		}
		if (FlxG.mouse.justReleased)
		{
			rawMouseHeld = false;
		}
	}
}
