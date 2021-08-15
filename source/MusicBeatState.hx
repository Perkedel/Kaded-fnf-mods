package;

import plugins.sprites.QmovephBackground;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup;
import flixel.addons.display.FlxStarField;
import plugins.sprites.DVDScreenSaver;
import flixel.tweens.FlxEase;
import flixel.FlxCamera;
import ui.FlxVirtualPad;
import flixel.input.actions.FlxActionInput;
import TouchScreenControls;
import haxe.Json;
import lime.utils.Assets;
import flixel.FlxSprite;
#if (windows && cpp)
import Discord.DiscordClient;
#end
import flixel.util.FlxColor;
import openfl.Lib;
import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;

using StringTools;

//JOELwindows7: let's inspire from Song.hx. 
//here's the typedef for Json file of weekList yess.
typedef SwagWeeks = {
	var weekData:Array<Dynamic>;
	var weekUnlocked:Array<Bool>;
	var weekCharacters:Array<Dynamic>;
	var weekNames:Array<String>;
} 

class MusicBeatState extends FlxUIState
{
	//JOELwindows7: copy screen size
	private var screenWidth:Int = FlxG.width;
	private var screenHeight:Int = FlxG.height;

	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var curDecimalBeat:Float = 0;
	private var controls(get, never):Controls;

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
	//JOELwindows7: starfields here.
	var starfield2D:FlxStarField2D;
	var starfield3D:FlxStarField3D;
	var multiStarfield2D:FlxTypedGroup<FlxStarField2D>;
	var multiStarfield3D:FlxTypedGroup<FlxStarField3D>;
	//var touchscreenButtons:TouchScreenControls; //JOELwindows7: the touchscreen buttons here
	var hourGlass:FlxSprite; //JOELwindows7: animated gravity hourglass Piskel
	public var onScreenGameplayButtons:OnScreenGameplayButtons; //JOELwindows7: the touchscreen buttons here
	public static var dueAdded:Bool = false;
	var defaultBekgron:FlxBackdrop;
	var qmovephBekgron:QmovephBackground;

	public var camControl:FlxCamera;

	//JOELwindows7: touchscreen button stuffs
	// https://github.com/luckydog7/Funkin-android/blob/master/source/MusicBeatState.hx
	var _virtualpad:FlxVirtualPad;
	var trackedinputs:Array<FlxActionInput> = [];

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create()
	{
		TimingStruct.clearTimings();
		(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);

		if (transIn != null)
			trace('reg ' + transIn.region);

		initCamControl(); //JOELwindows7: init the cam control now! 
		//dedicated touchscreen button container
		super.create();
		//trace("created Music Beat State");
	}


	var array:Array<FlxColor> = [
		FlxColor.fromRGB(148, 0, 211),
		FlxColor.fromRGB(75, 0, 130),
		FlxColor.fromRGB(0, 0, 255),
		FlxColor.fromRGB(0, 255, 0),
		FlxColor.fromRGB(255, 255, 0),
		FlxColor.fromRGB(255, 127, 0),
		FlxColor.fromRGB(255, 0 , 0)
	];

	var skippedFrames = 0;

	override function update(elapsed:Float)
	{
		//everyStep();
		/*var nextStep:Int = updateCurStep();

		if (nextStep >= 0)
		{
			if (nextStep > curStep)
			{
				for (i in curStep...nextStep)
				{
					curStep++;
					updateBeat();
					stepHit();
				}
			}
			else if (nextStep < curStep)
			{
				//Song reset?
				curStep = nextStep;
				updateBeat();
				stepHit();
			}
		}*/

		if (Conductor.songPosition < 0)
			curDecimalBeat = 0;
		else
		{
			if (TimingStruct.AllTimings.length > 1)
			{
				var data = TimingStruct.getTimingAtTimestamp(Conductor.songPosition);

				FlxG.watch.addQuick("Current Conductor Timing Seg", data.bpm);

				Conductor.crochet = ((60 / data.bpm) * 1000);

				var step = ((60 / data.bpm) * 1000) / 4;
				var startInMS = (data.startTime * 1000);


				var percent = (Conductor.songPosition - startInMS) / (data.length * 1000);

				curDecimalBeat = data.startBeat + (((Conductor.songPosition/1000) - data.startTime) * (data.bpm / 60));
				var ste:Int = Math.floor(data.startStep + ((Conductor.songPosition - startInMS) / step));
				if (ste >= 0)
				{
					if (ste > curStep)
					{
						for (i in curStep...ste)
						{
							curStep++;
							updateBeat();
							stepHit();
						}
					}
					else if (ste < curStep)
					{
						//Song reset?
						curStep = ste;
						updateBeat();
						stepHit();
					}
				}
			}
			else
			{
				curDecimalBeat = (Conductor.songPosition / 1000) * (Conductor.bpm/60);
				var nextStep:Int = Math.floor(Conductor.songPosition / Conductor.stepCrochet);
				if (nextStep >= 0)
				{
					if (nextStep > curStep)
					{
						for (i in curStep...nextStep)
						{
							curStep++;
							updateBeat();
							stepHit();
						}
					}
					else if (nextStep < curStep)
					{
						//Song reset?
						curStep = nextStep;
						updateBeat();
						stepHit();
					}
				}
				Conductor.crochet = ((60 / Conductor.bpm) * 1000);
			}
		}


		if (FlxG.save.data.fpsRain && skippedFrames >= 6)
			{
				if (currentColor >= array.length)
					currentColor = 0;
				(cast (Lib.current.getChildAt(0), Main)).changeFPSColor(array[currentColor]);
				currentColor++;
				skippedFrames = 0;
			}
			else
				skippedFrames++;

		if ((cast (Lib.current.getChildAt(0), Main)).getFPSCap != FlxG.save.data.fpsCap && FlxG.save.data.fpsCap <= 290)
			(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);

		super.update(elapsed);
	}

	private function updateBeat():Void
	{
		lastBeat = curBeat;
		curBeat = Math.floor(curStep / 4);
	}

	public static var currentColor = 0;

	private function updateCurStep():Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		return lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		//do literally nothing dumbass
	}
	
	public function fancyOpenURL(schmancy:String)
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [schmancy, "&"]);
		#else
		FlxG.openURL(schmancy);
		#end
	}

	//JOELwindows7: week loader
	//JOELwindows7: Okay so, cleanup Json? and then parse? okeh
	// yeah I know, I copied from Song.hx. for this one, the weekList.json isn't anywhere in special folder
	// but root of asset/data . that's all... idk
	public static function loadFromJson(jsonInput:String):SwagWeeks{
		var rawJson = Assets.getText(Paths.json(jsonInput)).trim();
		trace("load weeklist Json");

		while (!rawJson.endsWith("}")){
			//JOELwindows7: okay also going through bullshit cleaning what the peck strange
			rawJson = rawJson.substr(0, rawJson.length - 1);
		}
		return parseJSONshit(rawJson);
	}
	//JOELwindows7: lol!literally copy from Song.hx minus the 
	//changing valid score which SwagWeeks typedef doesn't have, idk..
	public static function parseJSONshit(rawJson:String):SwagWeeks
	{
		var swagShit:SwagWeeks = cast Json.parse(rawJson);
		return swagShit;
	}

	//JOELwindows7: init dedicated touchscreen buttons camera
	function initCamControl(){
		trace("setting dedicated touchscreen buttons camera");
		camControl = new FlxCamera();
		FlxG.cameras.add(camControl);
		camControl.bgColor.alpha = 0;
	}

	//JOELwindows7: buttons
	private function addBackButton(x:Int=100,y:Int=720-100,scale:Float=.5){
		backButton = new FlxSprite(x, y).loadGraphic(Paths.image('backButton'));
		backButton.setGraphicSize(Std.int(backButton.width * scale),Std.int(backButton.height * scale));
		backButton.scrollFactor.set();
		backButton.updateHitbox();
		backButton.antialiasing = FlxG.save.data.antialiasing;
		if(camControl != null)
			backButton.cameras = [camControl];
		add(backButton);
		return backButton;
	}
	private function addLeftButton(x:Int=100,y:Int=1280-100,scale:Float=.5){
		leftButton = new FlxSprite(x, y).loadGraphic(Paths.image('leftAdjustButton'));
		leftButton.setGraphicSize(Std.int(leftButton.width * scale),Std.int(leftButton.height * scale));
		leftButton.scrollFactor.set();
		leftButton.updateHitbox();
		leftButton.antialiasing = FlxG.save.data.antialiasing;
		if(camControl != null)
			leftButton.cameras = [camControl];
		add(leftButton);
		return leftButton;
	}
	private function addRightButton(x:Int=525,y:Int=1280-100,scale:Float=.5){
		rightButton = new FlxSprite(x, y).loadGraphic(Paths.image('rightAdjustButton'));
		rightButton.setGraphicSize(Std.int(rightButton.width * scale),Std.int(rightButton.height * scale));
		rightButton.scrollFactor.set();
		rightButton.updateHitbox();
		rightButton.antialiasing = FlxG.save.data.antialiasing;
		if(camControl != null)
			rightButton.cameras = [camControl];
		add(rightButton);
		return rightButton;
	}
	private function addUpButton(x:Int=240,y:Int=1280-100,scale:Float=.5){
		upButton = new FlxSprite(x, y).loadGraphic(Paths.image('upAdjustButton'));
		upButton.setGraphicSize(Std.int(upButton.width * scale),Std.int(upButton.height * scale));
		upButton.scrollFactor.set();
		upButton.updateHitbox();
		upButton.antialiasing = FlxG.save.data.antialiasing;
		if(camControl != null)
			upButton.cameras = [camControl];
		add(upButton);
		return upButton;
	}
	private function addDownButton(x:Int=450,y:Int=1280-100,scale:Float=.5){
		downButton = new FlxSprite(x, y).loadGraphic(Paths.image('downAdjustButton'));
		downButton.setGraphicSize(Std.int(downButton.width * scale),Std.int(downButton.height * scale));
		downButton.scrollFactor.set();
		downButton.updateHitbox();
		downButton.antialiasing = FlxG.save.data.antialiasing;
		if(camControl != null)
			downButton.cameras = [camControl];
		add(downButton);
		return downButton;
	}
	private function addPauseButton(x:Int=640,y:Int=10,scale:Float=.5){
		pauseButton = new FlxSprite(x, y).loadGraphic(Paths.image('pauseButton'));
		pauseButton.setGraphicSize(Std.int(pauseButton.width * scale),Std.int(pauseButton.height * scale));
		pauseButton.scrollFactor.set();
		pauseButton.updateHitbox();
		pauseButton.antialiasing = FlxG.save.data.antialiasing;
		if(camControl != null)
			pauseButton.cameras = [camControl];
		add(pauseButton);
		return pauseButton;
	}
	private function addAcceptButton(x:Int=1280-100,y:Int=720-100,scale:Float=.5){
		acceptButton = new FlxSprite(x, y).loadGraphic(Paths.image('acceptButton'));
		acceptButton.setGraphicSize(Std.int(acceptButton.width * scale),Std.int(acceptButton.height * scale));
		acceptButton.scrollFactor.set();
		acceptButton.updateHitbox();
		acceptButton.antialiasing = FlxG.save.data.antialiasing;
		if(camControl != null)
			acceptButton.cameras = [camControl];
		add(acceptButton);
		return acceptButton;
	}
	private function addRetryButton(x:Int = 500, y:Int =500, scale:Float=.5){
		retryButton = new FlxSprite(x, y).loadGraphic(Paths.image('retryButton'));
		retryButton.setGraphicSize(Std.int(retryButton.width * scale),Std.int(retryButton.height * scale));
		retryButton.scrollFactor.set();
		retryButton.updateHitbox();
		retryButton.antialiasing = FlxG.save.data.antialiasing;
		if(camControl != null)
			retryButton.cameras = [camControl];
		add(retryButton);
		return retryButton;
	}
	private function addViewReplayButton(x:Int = 500, y:Int =500, scale:Float=.5){
		viewReplayButton = new FlxSprite(x, y).loadGraphic(Paths.image('viewReplayButton'));
		viewReplayButton.setGraphicSize(Std.int(viewReplayButton.width * scale),Std.int(viewReplayButton.height * scale));
		viewReplayButton.scrollFactor.set();
		viewReplayButton.updateHitbox();
		viewReplayButton.antialiasing = FlxG.save.data.antialiasing;
		if(camControl != null)
			viewReplayButton.cameras = [camControl];
		add(viewReplayButton);
		return viewReplayButton;
	}
	private function installBusyHourglassScreenSaver(){
		hourGlass = new DVDScreenSaver(null,100,100);
		hourGlass.frames = Paths.getSparrowAtlas('Gravity-HourGlass');
		hourGlass.animation.addByPrefix('working', 'Gravity-HourGlass idle', 24);
		hourGlass.animation.play('working');
		hourGlass.updateHitbox();
		add(hourGlass);
		return hourGlass;
	}
	private function addTouchScreenButtons(howManyButtons:Int = 4, initVisible:Bool = false){
		/*
		touchscreenButtons = new TouchScreenControls(howManyButtons, initVisible);
		touchscreenButtons.initDoseButtons();
		add(touchscreenButtons);
		*/
		var _alreadyAdded:Array<Bool> = [false, false, false, false];
		trace("init the touchscreen buttons");
		if(onScreenGameplayButtons == null){
			onScreenGameplayButtons = new OnScreenGameplayButtons(howManyButtons, initVisible);
			//_alreadyAdded = onScreenGameplayButtons._alreadyAdded;
		}
		if(true)
			switch(Std.int(FlxG.save.data.selectTouchScreenButtons)){
				case 0:
					trace("No touch screen button to init at all.");
				case 1:
					trace("hitbox the touchscreen buttons");
					if(_alreadyAdded[1] == false) controls.installTouchScreenGameplays(onScreenGameplayButtons._hitbox,howManyButtons);
				case 2:
					trace("Left side touchscreen buttons only");
					if(_alreadyAdded[2] == false) controls.setVirtualPad(onScreenGameplayButtons._virtualPad, FULL, NONE, true);
				case 3:
					trace("Right side touchscreen buttons only");
					if(_alreadyAdded[3] == false) controls.setVirtualPad(onScreenGameplayButtons._virtualPad, NONE, A_B_X_Y, true);
				case 4:
					trace("Full gamepad touchscreen");
					if(_alreadyAdded[4] == false) controls.setVirtualPad(onScreenGameplayButtons._virtualPad, FULL, A_B_X_Y, true);
				default:
					trace("huh? what do you mean? we don't know this touch buttons type\nUgh fine I guess you are my little pogchamp, come here.");
					//lmao! gothmei reference & PEAR animated it this
			}
		else
			trace("due has already added bruh");
		dueAdded = true;
		_alreadyAdded[Std.int(FlxG.save.data.selectTouchScreenButtons)] = true;
		trackedinputs = controls.trackedinputs;
		// if(onScreenGameplayButtons != null)
		// 	onScreenGameplayButtons.initialize(howManyButtons, initVisible);
		controls.trackedinputs = [];
		if(camControl == null){
			initCamControl();
			onScreenGameplayButtons.cameras = [camControl];
		} else {
			camControl.bgColor.alpha = 0;
			onScreenGameplayButtons.cameras = [camControl];
		}
		onScreenGameplayButtons.visible = initVisible;
		
		add(onScreenGameplayButtons);
	}
	public function showOnScreenGameplayButtons(){
		if(onScreenGameplayButtons != null) onScreenGameplayButtons.visible = true;
	}
	public function hideOnScreenGameplayButtons(){
		if(onScreenGameplayButtons != null) onScreenGameplayButtons.visible = false;
	}
	public function removeTouchScreenButtons(){
		if(onScreenGameplayButtons != null){
			trace("uninstall touchscreen buttonings");
			controls.trackedinputs = trackedinputs;
			switch(Std.int(FlxG.save.data.selectTouchScreenButtons)){
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
					//lmao! gothmei reference & PEAR animated it this
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

	//JOELwindows7: install starfield
	function installStarfield2D(
		x:Int=0,
		y:Int=0,
		width:Int=0,
		height:Int=0,
		starAmount:Int=300, 
		inArray:Bool = false
		):FlxStarField2D
		{
		if(inArray){
			var starfielding = new FlxStarField2D(x,y,width,height,starAmount);
			var id:Int = multiStarfield2D.length;
			starfielding.ID = id;
			multiStarfield2D.add(starfielding);
			add(starfielding);
			return starfielding;
		} else {
			starfield2D = new FlxStarField2D(x,y,width,height,starAmount);
			add(starfield2D);
			return starfield2D;
		}
	}
	function installStarfield3D(
		x:Int=0,
		y:Int=0,
		width:Int=0,
		height:Int=0,
		starAmount:Int=300, 
		inArray:Bool = false
		):FlxStarField3D
		{
		if(inArray){
			var starfielding = new FlxStarField3D(x,y,width,height,starAmount);
			var id:Int = multiStarfield2D.length;
			starfielding.ID = id;
			multiStarfield3D.add(starfielding);
			add(starfielding);
			return starfielding;
		} else {
			starfield3D = new FlxStarField3D(x,y,width,height,starAmount);
			add(starfield3D);
			return starfield3D;
		}
	}
	function installDefaultBekgron(){
		defaultBekgron = new FlxBackdrop(Paths.image('DefaultBackground-720p'),50,0,true,false);
		// defaultBekgron.setGraphicSize(FlxG.width,FlxG.height);
		defaultBekgron.velocity.x = -100;
		defaultBekgron.updateHitbox();
		add(defaultBekgron);
	}
	function justInitDefaultBekgron():FlxBackdrop {
		var theBekgron:FlxBackdrop = new FlxBackdrop(Paths.image('DefaultBackground-720p'),50,0,true,false);
		theBekgron.velocity.x = -100;
		theBekgron.updateHitbox();
		return theBekgron;
	}
	function installSophisticatedDefaultBekgron() {
		qmovephBekgron = new QmovephBackground();
		add(qmovephBekgron);
		qmovephBekgron.startDoing();
	}
}
