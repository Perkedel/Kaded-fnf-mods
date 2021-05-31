package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxObject;

	var stageSuffix:String = "";
	var midiSuffix:String = '-midi';
	var detectMidiSuffix:String = "";
	var memeSuffix = "-meme";
	var detectMemeSuffix = "";

	public function new(x:Float, y:Float)
	{
		var daStage = PlayState.curStage;
		var daBf:String = '';
		var daSong:String = PlayState.SONG.song; //damn, I couldn't access that. I change the publicity to public man!
		switch (PlayState.SONG.player1)
		{
			case 'bf-pixel':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			case 'bf-covid':
				//JOELwindows7: the bf masker torns too aswell!
				daBf = 'bf-covid';
			case 'hookx':
				daBf = 'hookx';
			default:
				daBf = 'bf';
		}

		//JOELwindows7: check if the song is midi version
		if(StringTools.endsWith(PlayState.SONG.song,midiSuffix)){
			detectMidiSuffix = "-midi";
		} else {
			detectMidiSuffix = "";
		}

		//JOELwindows7: checks depending on song
		switch(daSong.toLowerCase()){
			case 'tutorial':
				{
					//Noob failure lmao
					FlxG.sound.play(Paths.soundRandom('GF_', 1, 2));
					trace("WHAT? failure in Tutorial? XD hahahhahaha wtf person?!");
				}
			case 'blammed':
				{
					trace("haha lol you blammed!");
					FlxG.sound.play(Paths.sound('carCrash0'));
				}
			default:
				{

				}
		}

		super();

		Conductor.songPosition = 0;

		bf = new Boyfriend(x, y, daBf);
		add(bf);

		camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

		//JOELwindows7: add custom gameover sounds
		switch(daBf.toLowerCase()){
			case 'hookx':
				{
					FlxG.sound.play(Paths.sound('fnf_loss_sfx-BSoD'));
				}
			default:
				{
					FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix + detectMemeSuffix + detectMidiSuffix));
				}
		}
		Conductor.changeBPM(100);

		//JOELwindows7: also play the masker tear if daBf is covid version
		//checks depending on character to play additional sound
		switch(daBf.toLowerCase())
		{
			case 'bf-covid':
				FlxG.sound.play(Paths.sound('paperTear1'));
		}
		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		//JOELwindows7: add mouse press
		if (controls.ACCEPT || FlxG.mouse.justPressed)
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();

			if (PlayState.isStoryMode)
				FlxG.switchState(new StoryMenuState());
			else
				FlxG.switchState(new FreeplayState());
			PlayState.loadRep = false;
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
			//JOELwindows7: yess! the MIDI version detection.
			FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix + detectMemeSuffix + detectMidiSuffix));
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		var daStage = PlayState.curStage;
		var daBf:String = '';
		var daSong:String = PlayState.SONG.song;

		if (!isEnding)
		{
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			//JOELwindows7: yess! the MIDI version detection.
			FlxG.sound.play(Paths.music('gameOverEnd' + stageSuffix + detectMemeSuffix + detectMidiSuffix));

			//JOELwindows7: context detections scheme like above first loss
			switch(daBf){
				default:
					{

					}
			}

			switch(daSong.toLowerCase()){
				default:
					{

					}
			}

			switch(daStage){
				default:
					{

					}
			}

			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}
}
