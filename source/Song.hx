package;

import Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import openfl.utils.Assets as OpenFlAssets;
import tjson.TJSON;

using StringTools;

class Event
{
	public var name:String;
	public var position:Float;
	public var value:Float;
	public var value2:Float; // JOELwindows7: another one
	public var value3:Float; // JOELwindows7: aanother one
	public var type:String;

	// JOELwindows7: extra
	public function new(name:String, pos:Float, value:Float, type:String, value2:Float, value3:Float)
	{
		this.name = name;
		this.position = pos;
		this.value = value;
		this.value2 = value2; // JOELwindows7: extra
		this.value3 = value3; // JOELwindows7: extra
		this.type = type;
	}
}

typedef SongData =
{
	@:deprecated
	var ?song:String;

	/**
	 * The readable name of the song, as displayed to the user.
	 		* Can be any string.
	 */
	var songName:String;

	/**
	 * The internal name of the song, as used in the file system.
	 */
	var songId:String;

	/**
	 * The artist for the song
	 */
	var artist:String; // JOELwindows7: the artist of it

	var ?charter:String; // JOELwindows7: who charted the song.
	var chartVersion:String;
	var notes:Array<SwagSection>;
	var eventObjects:Array<Event>;
	var bpm:Float;
	var needsVoices:Bool;
	var ?needsVoices2:Bool; // JOELwindows7: player 2 voices
	var speed:Float;
	var player1:String;
	var player2:String;
	var gfVersion:String;
	var noteStyle:String;
	var ?arrowSkin:String; // JOELwindows7: psyched noteskin
	var stage:String;
	var ?hasVideo:Bool; // JOELwindows7: mark that this has video
	var ?videoPath:String; // JOELwindows7: the video file path
	var ?hasEpilogueVideo:Bool; // JOELwindows7: mark that this has Epilogue video
	var ?epilogueVideoPath:String; // JOELwindows7: the epilogue video file path;
	var ?hasTankmanVideo:Bool; // JOELwindows7: same as hasVideo but this is for when entered PlayState like week7.
	var ?tankmanVideoPath:String; // JOELwindows7: same as videoPath but this is for when entered PlayState like week7.
	var ?hasEpilogueTankmanVideo:Bool; // JOELwindows7: same as hasEpilogueVideo but this is for when entered PlayState like week7.
	var ?epilogueTankmanVideoPath:String; // JOELwindows7: same as epilogueVideoPath but this is for when entered PlayState like week7.
	var ?hasDialogueChat:Bool; // JOELwindows7: mark that this has Dialogue chat
	var ?hasEpilogueChat:Bool; // JOELwindows7: mark that this has Epologue chat
	var ?allowedToHeadbang:Bool; // JOELwindows7: mark whether heys, color change, etc.
	var ?introCutSceneDoneManually:Bool; // JOELwindows7: mark whether intro done manually with modchart
	var ?outroCutSceneDoneManually:Bool; // JOELwindows7: mark whether outro done manually with modchart
	var ?useCustomStage:Bool; // JOELwindows7: should use custom stage?
	// be allowed at certain moments in time
	var ?forceLuaModchart:Bool; // JOELwindows7: force Lua to load anyway. Will crash if modchart don't exist
	var ?forceLuaModchartLegacy:Bool; // JOELwindows7: force to support legacy Lua modchart system as in <1.7 I guess
	var ?forceHscriptModchart:Bool; // JOELwindows7: force Hscript to load anyway. Will crash if modchart don't exist'
	// JOELwindows7: Countdown funny configs
	var ?reversedCountdown:Bool;
	var ?invisibleCountdown:Bool;
	var ?silentCountdown:Bool;
	var ?skipCountdown:Bool;
	// JOELwindows7: more configs
	var ?loadNoteStyleOtherWayAround:Bool; // use foldered noteskin
	var ?useCustomNoteStyle:Bool; // enable to custom noteskin
	// JOELwindows7: Delays
	var ?delayBeforeStart:Float; // Delay before the song start. for cutscene after dia video
	var ?delayAfterFinish:Float; // Delay after song finish before load next song. for cutscene before epilogue video
	var ?isCreditRoll:Bool; // JOELwindows7: is this credit roll? if yes then roll credit.
	var ?creditRunsOnce:Bool; // JOELwindows7: is this credit runs once?
	var ?validScore:Bool;
	var ?offset:Int;
	var ?variables:Dynamic; // JOELwindows7: Variables for all difficulty to be accessed by elements of the gameplay. Stage, song, modchart, whatever.
	var ?diffVariables:Dynamic; // JOELwindows7: like `variables`, but only to be filled by each song difficulty, not meta.
	var ?strumCounts:Int; // JOELwindows7: how many strum collumns? 4 keys, 6 keys, or 9 keys? (Unused)
	var ?strumProfile:String; // JOELwindows7: what strum profile to use? Dance Dance Revolution? 6 keys? 9 keys?
	var ?difficulty:Int; // JOELwindows7: the difficulty of the song. New way of defining rather than by name (unused, current system exist using name)
	var ?difficultyId:String; // JOELwindows7: what's the difficulty ID? easy, medium, hard, or any other?
	var ?difficultyStrength:Float; // JOELwindows7: how much number is the difficulty? just like Stepmania diff number.
}

typedef SongMeta =
{
	var ?artist:String;

	var ?charter:String; // JOELwindows7: who charted the song.
	var ?offset:Int;
	var ?name:String;
	var ?hasVideo:Bool; // JOELwindows7: mark that this has video
	var ?videoPath:String; // JOELwindows7: the video file path
	var ?hasEpilogueVideo:Bool; // JOELwindows7: mark that this has Epilogue video
	var ?epilogueVideoPath:String; // JOELwindows7: the epilogue video file path;
	var ?hasTankmanVideo:Bool; // JOELwindows7: same as hasVideo but this is for when entered PlayState like week7.
	var ?tankmanVideoPath:String; // JOELwindows7: same as videoPath but this is for when entered PlayState like week7.
	var ?hasEpilogueTankmanVideo:Bool; // JOELwindows7: same as hasEpilogueVideo but this is for when entered PlayState like week7.
	var ?epilogueTankmanVideoPath:String; // JOELwindows7: same as epilogueVideoPath but this is for when entered PlayState like week7.
	var ?hasDialogueChat:Bool; // JOELwindows7: mark that this has Dialogue chat
	var ?hasEpilogueChat:Bool; // JOELwindows7: mark that this has Epologue chat
	var ?forceLuaModchart:Bool; // JOELwindows7: force Lua to load anyway. Will crash if modchart don't exist
	var ?forceLuaModchartLegacy:Bool; // JOELwindows7: force to support legacy Lua modchart system as in <1.7 I guess
	var ?forceHscriptModchart:Bool; // JOELwindows7: force Hscript to load anyway. Will crash if modchart don't exist'
	var ?delayBeforeStart:Float; // Delay before the song start. for cutscene after dia video
	var ?delayAfterFinish:Float; // Delay after song finish before load next song. for cutscene before epilogue video
	var ?introCutSceneDoneManually:Bool; // JOELwindows7: mark whether intro done manually with modchart
	var ?outroCutSceneDoneManually:Bool; // JOELwindows7: mark whether outro done manually with modchart
	var ?isCreditRoll:Bool; // JOELwindows7: is this credit roll? if yes then roll credit.
	var ?creditRunsOnce:Bool; // JOELwindows7: is this credit runs once?
	var ?allowedToHeadbang:Bool; // JOELwindows7: mark whether heys, color change, etc.
	// JOELwindows7: more configs
	var ?loadNoteStyleOtherWayAround:Bool; // use foldered noteskin
	var ?useCustomNoteStyle:Bool; // enable to custom noteskin
	// JOELwindows7: fallbackers
	var ?player1:String;
	var ?player2:String;
	var ?gfVersion:String;
	var ?eventObjects:Array<Event>; // JOELwindows7: make event objects possible to be song wide rather than just 1 diff
	var ?variables:Dynamic; // JOELwindows7: Variables for all difficulty to be accessed by elements of the gameplay. Stage, song, modchart, whatever.
	var ?diffVariables:Dynamic; // JOELwindows7: like `variables`, but only to be filled by each song difficulty, not meta.
	var ?strumCounts:Int; // JOELwindows7: how many strum collumns? 4 keys, 6 keys, or 9 keys? (Unused)
	var ?strumProfile:String; // JOELwindows7: what strum profile to use? Dance Dance Revolution? 6 keys? 9 keys?
	var ?difficulty:Int; // JOELwindows7: the difficulty of the song. New way of defining rather than by name (unused, current system exist using name)
	var ?difficultyId:String; // JOELwindows7: what's the difficulty ID? easy, medium, hard, or any other?
	var ?difficultyStrength:Float; // JOELwindows7: how much number is the difficulty? just like Stepmania diff number.
}

class Song
{
	public static var latestChart:String = "KE1";

	public static function loadFromJsonRAW(rawJson:String)
	{
		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
			// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
		}
		// var jsonData = Json.parse(rawJson);
		var jsonData = TJSON.parse(rawJson); // JOELwindows7: use TJSON instead of regular Haxe Json, let's see..

		return parseJSONshit("rawsong", jsonData, ["name" => jsonData.name]);
	}

	public static function loadFromJson(songId:String, difficulty:String):SongData
	{
		var songFile = '$songId/$songId$difficulty';

		Debug.logInfo('Loading song JSON: $songFile');

		var rawJson = Paths.loadJSON('songs/$songFile');
		var rawMetaJson = Paths.loadJSON('songs/$songId/_meta');

		trace("now parse that JSON");
		return parseJSONshit(songId, rawJson, rawMetaJson);
	}

	public static function conversionChecks(song:SongData):SongData
	{
		var ba = song.bpm;

		var index = 0;
		Debug.logTrace("conversion stuff " + song.songId + " " + song.notes.length);
		var convertedStuff:Array<Song.Event> = [];

		if (song.eventObjects == null)
			song.eventObjects = [new Song.Event("Init BPM", 0, song.bpm, "BPM Change", 0, 0)]; // JOELwindows7: oh banana

		for (i in song.eventObjects)
		{
			var name = Reflect.field(i, "name");
			var type = Reflect.field(i, "type");
			var pos = Reflect.field(i, "position");
			var value = Reflect.field(i, "value");
			var value2 = Reflect.field(i, "value2");
			var value3 = Reflect.field(i, "value3");

			convertedStuff.push(new Song.Event(name, pos, value, type, value2, value3)); // JOELwindows7: super idol
		}

		// JOELwindows7: also stringify stuffs like note type
		for (i in song.notes)
		{
			if (i.betterSectionNotes == null || i.betterSectionNotes.length <= 0 || i.betterSectionNotes.length < i.sectionNotes.length)
			{
				i.betterSectionNotes = [];
				for (j in 0...i.sectionNotes.length)
				{
					var stringedNoteType:String = switch (i.sectionNotes[j][5])
					{
						case 0:
							'default'; // regular note
						case 1:
							'special'; // powerup
						case 2:
							'mine'; // decrease HP
						case 3:
							'important'; // critical do not miss or die
						case 4:
							'never'; // critical do not step or die
						case _:
							'default';
					};

					// i.betterSectionNotes
					i.betterSectionNotes[j] = {
						strumTime: i.sectionNotes[j][0],
						noteData: i.sectionNotes[j][1],
						sustainLength: i.sectionNotes[j][2],
						isAlt: i.sectionNotes[j][3],
						beat: i.sectionNotes[j][4],
						noteType: i.sectionNotes[j][5],
						noteTypeId: stringedNoteType,
						hitsoundPath: i.sectionNotes[j][6],
						vowelType: i.sectionNotes[j][7],
					}
				}
			}
		}

		song.eventObjects = convertedStuff;

		if (song.noteStyle == null)
			// JOELwindows7: then check maybe it's defined psychedly I guess..
			song.noteStyle = song.arrowSkin != null ? song.arrowSkin : "normal";

		if (song.gfVersion == null)
			song.gfVersion = "gf";

		TimingStruct.clearTimings();

		var currentIndex = 0;
		for (i in song.eventObjects)
		{
			if (i.type == "BPM Change")
			{
				var beat:Float = i.position;

				var endBeat:Float = Math.POSITIVE_INFINITY;

				TimingStruct.addTiming(beat, i.value, endBeat, 0); // offset in this case = start time since we don't have a offset

				if (currentIndex != 0)
				{
					var data = TimingStruct.AllTimings[currentIndex - 1];
					data.endBeat = beat;
					data.length = (data.endBeat - data.startBeat) / (data.bpm / 60);
					var step = ((60 / data.bpm) * 1000) / 4;
					TimingStruct.AllTimings[currentIndex].startStep = Math.floor(((data.endBeat / (data.bpm / 60)) * 1000) / step);
					TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length;
				}

				currentIndex++;
			}
		}

		for (i in song.notes)
		{
			if (i.altAnim)
				i.CPUAltAnim = i.altAnim;

			var currentBeat = 4 * index;

			var currentSeg = TimingStruct.getTimingAtBeat(currentBeat);

			if (currentSeg == null)
				continue;

			var beat:Float = currentSeg.startBeat + (currentBeat - currentSeg.startBeat);

			if (i.changeBPM && i.bpm != ba)
			{
				Debug.logTrace("converting changebpm for section " + index);
				ba = i.bpm;
				song.eventObjects.push(new Song.Event("FNF BPM Change " + index, beat, i.bpm, "BPM Change", 0, 0)); // JOELwindows7: bep
			}

			for (ii in i.sectionNotes)
			{
				if (song.chartVersion == null)
				{
					ii[3] = false;
					ii[4] = TimingStruct.getBeatFromTime(ii[0]);
				}

				if (ii[3] == 0)
					ii[3] == false;
			}

			index++;
		}

		song.chartVersion = latestChart;

		return song;
	}

	public static function parseJSONshit(songId:String, jsonData:Dynamic, jsonMetaData:Dynamic):SongData
	{
		var songData:SongData = cast jsonData.song;

		songData.songId = songId;
		trace("parsened"); // JOELwindows7: wtf happening.

		// Enforce default values for optional fields.
		if (songData.validScore == null)
			songData.validScore = true;

		// Inject info from _meta.json.
		var songMetaData:SongMeta = cast jsonMetaData;
		if (songMetaData.name != null)
		{
			songData.songName = songMetaData.name;
		}
		else
		{
			// songData.songName = songId.split('-').join(' ');
			// JOELwindows7: extend classification.
			songData.songName = songData.songName == null || songData.songName == '' ? songId.split('-').join(' ') : songData.songName;
		}

		// JOELwindows7: the artist too
		songData.artist = songMetaData.artist != null ? songMetaData.artist : songData.artist != null ? songData.artist : "Unknown";

		// JOELwindows7: more too
		songData.isCreditRoll = songMetaData.isCreditRoll != null ? songMetaData.isCreditRoll : songData.isCreditRoll != null ? songData.isCreditRoll : false;

		// JOELwindows7: yut
		if (songData.creditRunsOnce == null)
			songData.creditRunsOnce = songMetaData.creditRunsOnce != null ? songMetaData.creditRunsOnce : false;

		// JOELwindows7: dude, is there a procedural way to fill these all up?
		if (songData.hasVideo == null)
			songData.hasVideo = songMetaData.hasVideo != null ? songMetaData.hasVideo : false;

		// JOELwindows7: Oh my God this is tiring already. btw, some are optional and can still be per difficulty basis.
		if (songData.videoPath == null)
			songData.videoPath = songMetaData.videoPath != null ? songMetaData.videoPath : "";

		// JOELwindows7: haaaaaaaaaaaaaaaa!!!!
		if (songData.hasEpilogueVideo == null)
			songData.hasEpilogueVideo = songMetaData.hasEpilogueVideo != null ? songMetaData.hasEpilogueVideo : false;

		// JOELwindows7: boooooooof
		if (songData.epilogueVideoPath == null)
			songData.epilogueVideoPath = songMetaData.epilogueVideoPath != null ? songMetaData.epilogueVideoPath : "";

		// JOELwindows7: yay GitHub Copilot yey
		if (songData.hasDialogueChat == null)
			songData.hasDialogueChat = songMetaData.hasDialogueChat != null ? songMetaData.hasDialogueChat : false;

		// JOELwindows7: yay GitHub Copilot yeyu
		if (songData.hasEpilogueChat == null)
			songData.hasEpilogueChat = songMetaData.hasEpilogueChat != null ? songMetaData.hasEpilogueChat : false;

		// JOELwindows7: try casting, but no. that's aggressive and destroys per difficulty basis.
		if (songData.delayBeforeStart == null)
			songData.delayBeforeStart = songMetaData.delayBeforeStart != null ? songMetaData.delayBeforeStart : 0;

		if (songData.delayAfterFinish == null)
			songData.delayAfterFinish = songData.delayAfterFinish != null ? songMetaData.delayAfterFinish : 0;

		// JOELwindows7: right, these are all we have.
		if (songData.allowedToHeadbang == null)
			songData.allowedToHeadbang = songMetaData.allowedToHeadbang != null ? songMetaData.allowedToHeadbang : false;

		// JOELwindows7: lua & haxescript stuffs
		if (songData.forceLuaModchartLegacy == null)
			songData.forceLuaModchartLegacy = songMetaData.forceLuaModchartLegacy != null ? songMetaData.forceLuaModchartLegacy : false;

		if (songData.forceLuaModchart == null)
			songData.forceLuaModchart = songMetaData.forceLuaModchart != null ? songMetaData.forceLuaModchart : false;

		if (songData.forceHscriptModchart == null)
			songData.forceHscriptModchart = songMetaData.forceHscriptModchart != null ? songMetaData.forceHscriptModchart : false;

		// JOELwindows7: fallbackers of the stuffs. the metadata should only overwrite if the variable is empty or null
		if (songData.player1 == null || songData.player1 == "")
			songData.player1 = songMetaData.player1 != null ? songMetaData.player1 : "bf";

		if (songData.player2 == null || songData.player2 == "")
			songData.player2 = songMetaData.player2 != null ? songMetaData.player2 : "dad";

		if (songData.gfVersion == null || songData.gfVersion == "")
			songData.gfVersion = songMetaData.gfVersion != null ? songMetaData.gfVersion : "gf";

		if (songData.hasTankmanVideo == null)
			songData.hasTankmanVideo = songMetaData.hasTankmanVideo != null ? songMetaData.hasTankmanVideo : false;

		if (songData.hasEpilogueTankmanVideo == null)
			songData.hasEpilogueTankmanVideo = songMetaData.hasEpilogueTankmanVideo != null ? songMetaData.hasEpilogueTankmanVideo : false;

		if (songData.tankmanVideoPath == null || songData.tankmanVideoPath == "")
			songData.tankmanVideoPath = songMetaData.tankmanVideoPath != null ? songMetaData.tankmanVideoPath : "null";

		if (songData.epilogueTankmanVideoPath == null || songData.epilogueTankmanVideoPath == "")
			songData.epilogueTankmanVideoPath = songMetaData.epilogueTankmanVideoPath != null ? songMetaData.epilogueTankmanVideoPath : "null";

		if (songMetaData.eventObjects != null && songMetaData.eventObjects != [] && songMetaData.eventObjects.length > 1)
		{
			if (songData.eventObjects == null || songData.eventObjects == [] || songData.eventObjects.length <= 1)
			{
				songData.eventObjects = songMetaData.eventObjects;
			}
		}

		if (songData.loadNoteStyleOtherWayAround == null)
			songData.loadNoteStyleOtherWayAround = songMetaData.loadNoteStyleOtherWayAround != null ? songMetaData.loadNoteStyleOtherWayAround : false;

		if (songData.useCustomNoteStyle == null)
			songData.useCustomNoteStyle = songMetaData.useCustomNoteStyle != null ? songMetaData.useCustomNoteStyle : false;

		if (songData.introCutSceneDoneManually == null)
			songData.introCutSceneDoneManually = songMetaData.introCutSceneDoneManually != null ? songMetaData.introCutSceneDoneManually : false;

		if (songData.outroCutSceneDoneManually == null)
			songData.outroCutSceneDoneManually = songMetaData.outroCutSceneDoneManually != null ? songMetaData.outroCutSceneDoneManually : false;

		// if (songData.variables == null)
		// 	songData.variables = songMetaData.variables != null ? songMetaData.variables : {};

		songData.variables = songMetaData.variables != null ? songMetaData.variables : {};
		// always overwrite from meta.

		if (songData.diffVariables == null)
			songData.diffVariables = songMetaData.diffVariables != null ? songMetaData.diffVariables : {};
		// in case meta defines it instead, which is why would you.

		if (songData.difficulty == null)
			songData.difficulty = songMetaData.difficulty != null ? songMetaData.difficulty : 0;

		if (songData.difficultyId == null)
			songData.difficultyId = songMetaData.difficultyId != null ? songMetaData.difficultyId : "";

		if (songData.difficultyStrength == null)
			songData.difficultyStrength = songMetaData.difficultyStrength != null ? songMetaData.difficultyStrength : 1;

		if (songData.strumCounts == null)
			songData.strumCounts = songMetaData.strumCounts != null && songMetaData.strumCounts > 0 ? songMetaData.strumCounts : 4;

		if (songData.strumProfile == null)
			songData.strumProfile = songMetaData.strumProfile != null ? songMetaData.strumProfile : "Dance-Single";

		// songData += cast(jsonMetaData); //JOELwindows7: how the peck I append this?!

		songData.offset = songMetaData.offset != null ? songMetaData.offset : 0;

		return Song.conversionChecks(songData);
	}
}
