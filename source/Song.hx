package;

import Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

using StringTools;

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var gfVersion:String;
	var noteStyle:String;
	var stage:String;
	var validScore:Bool;

	var hasVideo:Bool; //JOELwindows7: mark that this has video
	var videoPath:String; //JOELwindows7: the video file path
	var hasEpilogueVideo:Bool; //JOELwindows7: mark that this has Epilogue video
	var epilogueVideoPath:String; //JOELwindows7: the epilogue video file path;
	
	var hasDialogueChat:Bool; //JOELwindows7: mark that this has Dialogue chat
	var hasEpilogueChat:Bool; //JOELwindows7: mark that this has Epologue chat

	var allowedToHeadbang:Bool; //JOELwindows7: mark whether heys, color change, etc.
	var useCustomStage:Bool; //JOELwindows7: should use custom stage?
	//be allowed at certain moments in time

	var forceLuaModchart:Bool; //JOELwindows7: force Lua to load anyway. Will crash if modchart don't exist
	var forceHscriptModchart:Bool; //JOELwindows7: force Hscript to load anyway. Will crash if modchart don't exist'
}

class Song
{
	public var song:String;
	public var notes:Array<SwagSection>;
	public var bpm:Float;
	public var needsVoices:Bool = true;
	public var speed:Float = 1;

	public var player1:String = 'bf';
	public var player2:String = 'dad';
	public var gfVersion:String = '';
	public var noteStyle:String = '';
	public var stage:String = '';

	public var hadVideo:Bool = false;//JOELwindows7: mark that this has video
	public var videoPath:String = ''; //JOELwindows7: the video file path
	public var hasEpilogueVideo:Bool = false; //JOELwindows7: mark that this has Epilogue video
	public var epilogueVideoPath:String = ''; //JOELwindows7: the epilogue video file path;

	public var hasDialogueChat:Bool = false; //JOELwindows7: mark that this has Dialogue chat
	public var hasEpilogueChat:Bool = false; //JOELwindows7: mark that this has Epologue chat

	public var allowedToHeadbang:Bool = false; //JOELwindows7: mark whether heys, color change, etc.
	public var useCustomStage:Bool = false; //JOELwindows7: should use custom stage?
	//be allowed at certain moments in time

	public var forceLuaModchart:Bool = false; //JOELwindows7: force Lua to load anyway. Will crash if modchart don't exist
	public var forceHscriptModchart:Bool = false; //JOELwindows7: force Hscript to load anyway. Will crash if modchart don't exist'

	public function new(song, notes, bpm)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong
	{
		trace(jsonInput);

		// pre lowercasing the folder name
		var folderLowercase = StringTools.replace(folder, " ", "-").toLowerCase();
		switch (folderLowercase) {
			case 'dad-battle': folderLowercase = 'dadbattle';
			case 'philly-nice': folderLowercase = 'philly';
		}
		
		trace('loading ' + folderLowercase + '/' + jsonInput.toLowerCase());

		var rawJson = Assets.getText(Paths.json(folderLowercase + '/' + jsonInput.toLowerCase())).trim();
		trace('loaded raw JSON');

		while (!rawJson.endsWith("}"))
		{
			trace("clearing bullshits");
			rawJson = rawJson.substr(0, rawJson.length - 1);
			// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
		}

		// FIX THE CASTING ON WINDOWS/NATIVE
		// Windows???
		// trace(songData);

		// trace('LOADED FROM JSON: ' + songData.notes);
		/* 
			for (i in 0...songData.notes.length)
			{
				trace('LOADED FROM JSON: ' + songData.notes[i].sectionNotes);
				// songData.notes[i].sectionNotes = songData.notes[i].sectionNotes
			}

				daNotes = songData.notes;
				daSong = songData.song;
				daBpm = songData.bpm; */
		trace("now parse that JSON");
		return parseJSONshit(rawJson);
	}

	public static function parseJSONshit(rawJson:String):SwagSong
	{
		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		swagShit.validScore = true;
		trace("parsened"); //JOELwindows7: wtf happening.
		return swagShit;
	}
}
