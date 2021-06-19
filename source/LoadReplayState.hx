package;

import haxe.Json;
import MusicBeatState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import Controls.KeyboardScheme;
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
#if sys
import sys.io.File;
#end

using StringTools;

class LoadReplayState extends MusicBeatState
{
	var initWeekJson:SwagWeeks; //JOELwindows7: week JSON

	var selector:FlxText;
	var curSelected:Int = 0;

    var songs:Array<FreeplayState.SongMetadata> = [];

	var controlsStrings:Array<String> = [];
    var actualNames:Array<String> = [];

	private var grpControls:FlxTypedGroup<Alphabet>;
	var versionShit:FlxText;
	var poggerDetails:FlxText;
	override function create()
	{
		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        #if sys
		controlsStrings = sys.FileSystem.readDirectory(Sys.getCwd() + "/assets/replays/");
        #end
		trace(controlsStrings);

        controlsStrings.sort(Reflect.compare);

		//JOELwindows7: procedural week adder
		initWeekJson = loadFromJson('weekList');
		for(i in 1...initWeekJson.weekData.length){
			addWeek(initWeekJson.weekData[i],i,initWeekJson.weekCharacters[i]);
		}

		/*
        addWeek(['Bopeebo', 'Fresh', 'Dadbattle'], 1, ['dad']);
        addWeek(['Spookeez', 'South', 'Monster'], 2, ['spooky']);
        addWeek(['Pico', 'Philly', 'Blammed'], 3, ['pico']);

        addWeek(['Satin-Panties', 'High', 'Milf'], 4, ['mom']);
        addWeek(['Cocoa', 'Eggnog', 'Winter-Horrorland'], 5, ['parents-christmas', 'parents-christmas', 'monster-christmas']);
        
        addWeek(['Senpai', 'Roses', 'Thorns'], 6, ['senpai', 'senpai', 'spirit']);
		
		//JOELwindows7: whoah add own week again, what?
		addWeek(["Windfall", "Rule The World", "Well Meet Again"], 7, ["hookx", "bf", "gf"]);
        addWeek(["Senpai-midi", "Roses-midi", "Thorns-midi"], 8, ['senpai', 'senpai', 'spirit']);
        addWeek(["433"], 9, ["hookx", "bf", "gf"]);
		*/


        for(i in 0...controlsStrings.length)
        {
            var string:String = controlsStrings[i];
            actualNames[i] = string;
			var rep:Replay = Replay.LoadReplay(string);
            controlsStrings[i] = string.split("time")[0] + " " + (rep.replay.songDiff == 2 ? "HARD" : rep.replay.songDiff == 1 ? "EASY" : "NORMAL");
        }

        if (controlsStrings.length == 0)
            controlsStrings.push("No Replays...");

		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		for (i in 0...controlsStrings.length)
		{
				var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, controlsStrings[i], true, false);
				controlLabel.isMenuItem = true;
				controlLabel.ID = i; //JOELwindows7: ID each file
				controlLabel.targetY = i;
				grpControls.add(controlLabel);
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
		}


		versionShit = new FlxText(5, FlxG.height - 34, 0, "Replay Loader (ESCAPE TO GO BACK)\nNOTICE!!!! Replays are in a beta stage, and they are probably not 100% correct. expect misses and other stuff that isn't there!", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		
		poggerDetails = new FlxText(5, 34, 0, "Replay Details - \nnone", 12);
		poggerDetails.scrollFactor.set();
		poggerDetails.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(poggerDetails);

		//JOELwindows7: add back button
		addBackButton(20,FlxG.height);

		changeSelection(0);

		FlxTween.tween(backButton,{y:FlxG.height - 120},2,{ease: FlxEase.elasticInOut}); //JOELwindows7: also tween back button!
		
		super.create();
	}

    public function getWeekNumbFromSong(songName:String):Int
    {
        var week:Int = 0;
        for (i in 0...songs.length)
        {
            var pog:FreeplayState.SongMetadata = songs[i];
            if (pog.songName.toLowerCase() == songName)
                week = pog.week;
        }
        return week;
    }

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
        {
            songs.push(new FreeplayState.SongMetadata(songName, weekNum, songCharacter));
        }
    
        public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
        {
            if (songCharacters == null)
                songCharacters = ['bf'];
    
            var num:Int = 0;
            for (song in songs)
            {
                addSong(song, weekNum, songCharacters[num]);
    
                if (songCharacters.length != 1)
                    num++;
            }
        }
    

	override function update(elapsed:Float)
	{
		super.update(elapsed);

			if (controls.BACK || haveBacked)
			{
				FlxG.switchState(new OptionsMenu());
				haveBacked = false; //JOELwindows7: now click back button
			}
			if (controls.UP_P || FlxG.mouse.wheel == 1)
				changeSelection(-1);
			if (controls.DOWN_P || FlxG.mouse.wheel == -1)
				changeSelection(1);
		

			if ((controls.ACCEPT || haveClicked) && grpControls.members[curSelected].text != "No Replays...")
			{
				//JOELwindows7: install mouse support
                trace('loading ' + actualNames[curSelected]);
                PlayState.rep = Replay.LoadReplay(actualNames[curSelected]);

                PlayState.loadRep = true;

                var poop:String = Highscore.formatSong(PlayState.rep.replay.songName.toLowerCase(), PlayState.rep.replay.songDiff);

				PlayState.SONG = Song.loadFromJson(poop, PlayState.rep.replay.songName.toLowerCase());
                PlayState.isStoryMode = false;
                PlayState.storyDifficulty = PlayState.rep.replay.songDiff;
                PlayState.storyWeek = getWeekNumbFromSong(PlayState.rep.replay.songName);
                LoadingState.loadAndSwitchState(new PlayState());

				haveClicked = false;
			}

			//JOELwindows7: copy from option menu back there
			grpControls.forEach(function(alphabet:Alphabet){
				if(FlxG.mouse.overlaps(alphabet) && !FlxG.mouse.overlaps(backButton)){
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
			});
	}

	var isSettingControl:Bool = false;

	function changeSelection(change:Int = 0)
	{
		#if !switch
		#if newgrounds
		// NGio.logEvent('Fresh');
		#end
		#end
		
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;

		var rep:Replay = Replay.LoadReplay(actualNames[curSelected]);

		poggerDetails.text = "Replay Details - \nDate Created: " + rep.replay.timestamp + "\nSong: " + rep.replay.songName + "\nReplay Version: " + (rep.replay.replayGameVer != Replay.version ? "OUTDATED" : "Latest");

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

	//JOELwindows7: mouse support go to item
	function goToSelection(change:Int = 0)
	{
		#if !switch
		#if newgrounds
		// NGio.logEvent('Fresh');
		#end
		#end
		
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected = change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;

		var rep:Replay = Replay.LoadReplay(actualNames[curSelected]);

		poggerDetails.text = "Replay Details - \nDate Created: " + rep.replay.timestamp + "\nSong: " + rep.replay.songName + "\nReplay Version: " + (rep.replay.replayGameVer != Replay.version ? "OUTDATED" : "Latest");

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
}
