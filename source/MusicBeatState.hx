package;

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
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import openfl.Lib;
import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;

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
	//var touchscreenButtons:TouchScreenControls; //JOELwindows7: the touchscreen buttons here
	public var onScreenGameplayButtons:OnScreenGameplayButtons; //JOELwindows7: the touchscreen buttons here
	public static var dueAdded:Bool = false;

	public var camControl:FlxCamera;

	//JOELwindows7: touchscreen button stuffs
	// https://github.com/luckydog7/Funkin-android/blob/master/source/MusicBeatState.hx
	var _virtualpad:FlxVirtualPad;
	var trackedinputs:Array<FlxActionInput> = [];

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create()
	{
		(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);

		if (transIn != null)
			trace('reg ' + transIn.region);

		super.create();
		trace("created Music Beat State");
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
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep > 0)
			stepHit();

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
		lastBeat = curStep;
		curBeat = Math.floor(curStep / 4);
	}

	public static var currentColor = 0;

	private function updateCurStep():Void
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

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
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

	//JOELwindows7: buttons
	private function addBackButton(x:Int=720-200,y:Int=1280-100,scale:Float=.5){
		backButton = new FlxSprite(x, y).loadGraphic(Paths.image('backButton'));
		backButton.setGraphicSize(Std.int(backButton.width * scale),Std.int(backButton.height * scale));
		backButton.scrollFactor.set();
		backButton.updateHitbox();
		backButton.antialiasing = true;
		add(backButton);
		return backButton;
	}
	private function addLeftButton(x:Int=100,y:Int=1280-100,scale:Float=.5){
		leftButton = new FlxSprite(x, y).loadGraphic(Paths.image('leftAdjustButton'));
		leftButton.setGraphicSize(Std.int(leftButton.width * scale),Std.int(leftButton.height * scale));
		leftButton.scrollFactor.set();
		leftButton.updateHitbox();
		leftButton.antialiasing = true;
		add(leftButton);
		return leftButton;
	}
	private function addRightButton(x:Int=525,y:Int=1280-100,scale:Float=.5){
		rightButton = new FlxSprite(x, y).loadGraphic(Paths.image('rightAdjustButton'));
		rightButton.setGraphicSize(Std.int(rightButton.width * scale),Std.int(rightButton.height * scale));
		rightButton.scrollFactor.set();
		rightButton.updateHitbox();
		rightButton.antialiasing = true;
		add(rightButton);
		return rightButton;
	}
	private function addUpButton(x:Int=240,y:Int=1280-100,scale:Float=.5){
		upButton = new FlxSprite(x, y).loadGraphic(Paths.image('upAdjustButton'));
		upButton.setGraphicSize(Std.int(upButton.width * scale),Std.int(upButton.height * scale));
		upButton.scrollFactor.set();
		upButton.updateHitbox();
		upButton.antialiasing = true;
		add(upButton);
		return upButton;
	}
	private function addDownButton(x:Int=450,y:Int=1280-100,scale:Float=.5){
		downButton = new FlxSprite(x, y).loadGraphic(Paths.image('downAdjustButton'));
		downButton.setGraphicSize(Std.int(downButton.width * scale),Std.int(downButton.height * scale));
		downButton.scrollFactor.set();
		downButton.updateHitbox();
		downButton.antialiasing = true;
		add(downButton);
		return downButton;
	}
	private function addPauseButton(x:Int=640,y:Int=10,scale:Float=.5){
		pauseButton = new FlxSprite(x, y).loadGraphic(Paths.image('pauseButton'));
		pauseButton.setGraphicSize(Std.int(pauseButton.width * scale),Std.int(pauseButton.height * scale));
		pauseButton.scrollFactor.set();
		pauseButton.updateHitbox();
		pauseButton.antialiasing = true;
		add(pauseButton);
		return pauseButton;
	}
	private function addAcceptButton(x:Int=1280,y:Int=360,scale:Float=.5){
		acceptButton = new FlxSprite(x, y).loadGraphic(Paths.image('acceptButton'));
		acceptButton.setGraphicSize(Std.int(acceptButton.width * scale),Std.int(acceptButton.height * scale));
		acceptButton.scrollFactor.set();
		acceptButton.updateHitbox();
		acceptButton.antialiasing = true;
		add(acceptButton);
		return acceptButton;
	}
	private function addRetryButton(x:Int = 500, y:Int =500, scale:Float=.5){
		retryButton = new FlxSprite(x, y).loadGraphic(Paths.image('retryButton'));
		retryButton.setGraphicSize(Std.int(retryButton.width * scale),Std.int(retryButton.height * scale));
		retryButton.scrollFactor.set();
		retryButton.updateHitbox();
		retryButton.antialiasing = true;
		add(retryButton);
		return retryButton;
	}
	private function addViewReplayButton(x:Int = 500, y:Int =500, scale:Float=.5){
		viewReplayButton = new FlxSprite(x, y).loadGraphic(Paths.image('viewReplayButton'));
		viewReplayButton.setGraphicSize(Std.int(viewReplayButton.width * scale),Std.int(viewReplayButton.height * scale));
		viewReplayButton.scrollFactor.set();
		viewReplayButton.updateHitbox();
		viewReplayButton.antialiasing = true;
		add(viewReplayButton);
		return viewReplayButton;
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
			trace("setting dedicated touchscreen buttons camera");
			camControl = new FlxCamera();
			FlxG.cameras.add(camControl);
			camControl.bgColor.alpha = 0;
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
}
