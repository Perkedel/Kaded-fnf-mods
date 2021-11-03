package;

import flixel.FlxCamera;
import flixel.FlxSprite;
import lime.app.Application;
import openfl.Lib;
import flixel.text.FlxText;
import flixel.input.gamepad.FlxGamepad;
import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.FlxSubState;

class MusicBeatSubstate extends FlxSubState
{
	public function new()
	{
		super();
	}

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

	override function destroy()
	{
		Application.current.window.onFocusIn.remove(onWindowFocusOut);
		Application.current.window.onFocusIn.remove(onWindowFocusIn);
		super.destroy();
	}

	override function create()
	{
		super.create();
		Application.current.window.onFocusIn.add(onWindowFocusIn);
		Application.current.window.onFocusOut.add(onWindowFocusOut);
	}

	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var controls(get, never):Controls;

	public var camControl:FlxCamera;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function update(elapsed:Float)
	{
		// everyStep();
		var nextStep = updateCurStep();

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
				// Song reset?
				curStep = nextStep;
				updateBeat();
				stepHit();
			}
		}

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
		if (gamepad != null)
			KeyBinds.gamepad = true;
		else
			KeyBinds.gamepad = false;

		super.update(elapsed);

		manageMouse();
	}

	private function updateBeat():Void
	{
		lastBeat = curBeat;
		curBeat = Math.floor(curStep / 4);
	}

	private function updateCurStep():Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition > Conductor.bpmChangeMap[i].songTime)
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
		// do literally nothing dumbass
	}

	function onWindowFocusOut():Void
	{
		if (PlayState.inDaPlay)
		{
			if (!PlayState.instance.paused && !PlayState.instance.endingSong && PlayState.instance.songStarted)
			{
				Debug.logTrace("Lost Focus");
				PlayState.instance.openSubState(new PauseSubState());
				PlayState.boyfriend.stunned = true;

				PlayState.instance.persistentUpdate = false;
				PlayState.instance.persistentDraw = true;
				PlayState.instance.paused = true;

				PlayState.instance.vocals.stop();
				FlxG.sound.music.stop();
			}
		}
	}

	function onWindowFocusIn():Void
	{
		Debug.logTrace("IM BACK!!!");
		(cast(Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
	}

	//JOELwindows7: init dedicated touchscreen buttons camera
	function initCamControl(){
		trace("setting dedicated touchscreen buttons camera");
		camControl = new FlxCamera();
		FlxG.cameras.add(camControl);
		camControl.bgColor.alpha = 0;
	}

	//JOELwindows7: buttons
	private function addBackButton(x:Int=720-200,y:Int=1280-100,scale:Float=.5){
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
	private function addAcceptButton(x:Int=1280,y:Int=360,scale:Float=.5){
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

	function manageMouse():Void
	{
		// JOELwindows7: nothing. use this to manage mouse
	}
}
