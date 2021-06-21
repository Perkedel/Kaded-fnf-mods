package;

import flixel.FlxSprite;
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
	private var haveClicked = false;
	private var haveBacked = false;
	private var haveLefted = false;
	private var haveUpped = false;
	private var haveDowned = false;
	private var haveRighted = false;
	private var havePausened = false;
	private var haveDebugSevened = false;

	var backButton:FlxSprite; //JOELwindows7: the back button here
	var leftButton:FlxSprite; //JOELwindows7: the left button here
	var rightButton:FlxSprite; //JOELwindows7: the right button here
	var upButton:FlxSprite; //JOELwindows7: the up button here
	var downButton:FlxSprite; //JOELwindows7: the down button here
	var pauseButton:FlxSprite; //JOELwindows7: the pause button here

	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function update(elapsed:Float)
	{
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		curBeat = Math.floor(curStep / 4);

		if (oldStep != curStep && curStep > 0)
			stepHit();


		super.update(elapsed);
	}

	private function updateCurStep():Void
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

	//JOELwindows7: buttons
	private function addBackButton(x:Int=720-200,y:Int=1280-100,scale:Float=.5){
		backButton = new FlxSprite(x, y).loadGraphic(Paths.image('backButton'));
		backButton.setGraphicSize(Std.int(backButton.width * scale),Std.int(backButton.height * scale));
		backButton.scrollFactor.set();
		backButton.updateHitbox();
		backButton.antialiasing = true;
		add(backButton);
	}
	private function addLeftButton(x:Int=100,y:Int=1280-100,scale:Float=.5){
		leftButton = new FlxSprite(x, y).loadGraphic(Paths.image('leftAdjustButton'));
		leftButton.setGraphicSize(Std.int(leftButton.width * scale),Std.int(leftButton.height * scale));
		leftButton.scrollFactor.set();
		leftButton.updateHitbox();
		leftButton.antialiasing = true;
		add(leftButton);
	}
	private function addRightButton(x:Int=525,y:Int=1280-100,scale:Float=.5){
		rightButton = new FlxSprite(x, y).loadGraphic(Paths.image('rightAdjustButton'));
		rightButton.setGraphicSize(Std.int(rightButton.width * scale),Std.int(rightButton.height * scale));
		rightButton.scrollFactor.set();
		rightButton.updateHitbox();
		rightButton.antialiasing = true;
		add(rightButton);
	}
	private function addUpButton(x:Int=240,y:Int=1280-100,scale:Float=.5){
		upButton = new FlxSprite(x, y).loadGraphic(Paths.image('upAdjustButton'));
		upButton.setGraphicSize(Std.int(upButton.width * scale),Std.int(upButton.height * scale));
		upButton.scrollFactor.set();
		upButton.updateHitbox();
		upButton.antialiasing = true;
		add(upButton);
	}
	private function addDownButton(x:Int=450,y:Int=1280-100,scale:Float=.5){
		downButton = new FlxSprite(x, y).loadGraphic(Paths.image('downAdjustButton'));
		downButton.setGraphicSize(Std.int(downButton.width * scale),Std.int(downButton.height * scale));
		downButton.scrollFactor.set();
		downButton.updateHitbox();
		downButton.antialiasing = true;
		add(downButton);
	}
	private function addPauseButton(x:Int=640,y:Int=10,scale:Float=.5){
		pauseButton = new FlxSprite(x, y).loadGraphic(Paths.image('pauseButton'));
		pauseButton.setGraphicSize(Std.int(pauseButton.width * scale),Std.int(pauseButton.height * scale));
		pauseButton.scrollFactor.set();
		pauseButton.updateHitbox();
		pauseButton.antialiasing = true;
		add(pauseButton);
	}
}
