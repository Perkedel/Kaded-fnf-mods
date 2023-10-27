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

/**
 * Perkedel.hx in const. These are constant for Perkedel stuffs for Haxe like it this one here. some taken from Enigma
 */
package const;

// import systools.Dialogs;
import Character;
import flixel.text.FlxText.FlxTextFormatMarkerPair;
import flixel.text.FlxText.FlxTextFormat;
import flixel.util.FlxColor;
import DokiDoki;

class Perkedel
{
	public static final MAIN_FONT_FORMAT = "VCR OSD MONO";
	public static final OPTION_SAY_NEED_RESTART_SONG:String = "(Restart Song Required) ";
	public static final OPTION_SAY_CANNOT_ACCESS_IN_PAUSE:String = "(Can't access / toggle! in pause rn) "; // In kade it was "This option cannot be toggled in the pause menu."
	public static final OPTION_SAY_REQUIRES_RESTART:String = "(Requires restart!!!)"; // REQUIRES system restart
	public static final MAX_SCROLL_SPEED:Float = 6; // JOELwindows7: BOLO set max to 6 yeah
	public static final TYPICAL_REFRESH_RATE:Int = 144; // JOELwindows7: to check if someone is tremendously tech illiterate
	public static final MAX_FPS_CAP:Int = 3000; // JOELwindows7: usually 290
	public static final MIN_FPS_CAP:Int = 60; // JOELwindows7: usually 60
	public static final OPTION_CATEGORY_LENGTH:Int = 6; // How many categories on option menu? was 4, now we got 6. no wait that's DFJK.
	public static final ENGINE_NAME:String = "Last Funkin Moments"; // oh yeah LFM baby!
	public static final ENGINE_ID:String = "Last-Funkin-Moments"; // oh yeah LFM baby!
	public static final ENGINE_ID_CLOSE:String = "LastFunkinMoments"; // oh yeah LFM baby!
	public static final ENGINE_ABBREVIATE:String = "LFM"; // oh yeah LFM baby!
	public static final ENGINE_VERSION:String = "2023.12.0"; // current version number yeah!
	public static final ENGINE_VERSION_NUMBER:Array<Int> = [2023, 12, 0]; // and numbered version
	public static final ENGINE_NIGHTLY:String = ""; // say `-larutmalam` to mark this nightly build
	public static final ENGINE_VERSION_URL:String = 'https://raw.githubusercontent.com/Perkedel/kaded-fnf-mods/stable/versionLastFunkin.downloadMe'; // here URL check
	public static final ENGINE_REPO_URL:String = 'https://github.com/Perkedel/kaded-fnf-mods';
	public static final ENGINE_BUGREPORT_URL:String = 'https://github.com/Perkedel/kaded-fnf-mods/issues';
	public static final ENGINE_CHANGELOG_PREFIX_URL:String = 'https://odysee.com/@JOELwindows7/LFM-changelog-'; // here URL of change log prefix, appened by what version needed there.
	public static final ENGINE_CORE_HANDLE_CRASH:Bool = true; // if true, engine will handle crash and restart. if false, engine will not handle crash and restart.
	public static final DONATE_BUTTON_URL:String = 'https://odysee.com/@JOELwindows7:a/LFM-links:a'; // here URL of donate button
	public static final OFFICIAL_WEBSITE_BUTTON_URL:String = 'https://funkin.me/'; // here URL of official website
	public static final ENABLE_MODS:Bool = true;
	public static final ENABLE_VERSION_CHECK:Bool = true;
	public static final CHART_EVENTS:Array<String> = [
		"Camera Zoom in", "HUD Zoom in", "Both Zoom in", "Shake camera", "Cheer Now", "Hey Now", "Cheer Hey Now", "Lightning Strike", "BPM Change",
		"Scroll Speed Change", "Vibrate for", "LED ON for", "Blammed Lights", "Appear Blackbar", "Disappear Blackbar"
	];
	public static final CHART_HELP_TEXT:String = "\n\n" + "Help:\n" + "Ctrl-MWheel : Zoom in/out\n" + "Shift-Left/Right :\nChange playback speed\n"
		+ "Ctrl-Drag Click : Select notes\n" + "Ctrl-C : Copy notes\n" + "Ctrl-V : Paste notes\n" + "Ctrl-Z : Undo\n" + "Delete : Delete selection\n"
		+ "CTRL-Left/Right :\n  Change Snap\n" + "Hold Shift : Disable Snap\n" + "Click or 1/2/3/4/5/6/7/8 :\n\tPlace notes\n"
		+ "Place Note + ALT: Place mines\n" + "Up/Down :\n  Move selected notes 1 step\n" + "Shift-Up/Down :\nMove selected notes 1 beat\n"
		+ "Space: Play Music\n" + "Enter : Preview\n" + "Press F1 to hide/show help!";
	public static final CHART_HELP_TEXT_OFF:String = "\nPress F1 to hide/show help!";
	public static final LFM_ICON_PATH_DOC:String = "art/LFMicon128";
	public static final STARTUP_TOAST_TITLE:String = "Cool and good";
	public static final STARTUP_TOAST_DESCRIPTION:String = "Welcome to Last Funkin Moments\n Today's Kontraktua Majoris\n (2 of 3): Sky, Whitty";
	public static final MAX_AVAILABLE_JUDGEMENT_RATING:Int = 3; // only up to sick we have.
	public static final MAX_NUMBER_OF_LOADING_IMAGES:Int = 8; // how many loading backdrops do we have here?
	public static final DISCLAIMER_SAY:String = "Disclaimer";
	public static final LOADING_TOO_LONG_TIME_THRESHOLD:Float = 30; // if the loading took more than 30 second
	public static final LOADING_TOO_LONG_SAY:String = 'Too long, didn\'t load? [OK]/[ENTER]/(START) Skip, [BACK]/[ESC]/(B) Cancel.\n\n====================\n|\tAT YOUR OWN RISK!!\t|\n====================\n\n';
	public static final GOING_TO_OBSOLETE:String = "ALERT!\n"
		+ "\nThis mod is going to obsolete in favour of Friday Night Funkin Moment: Full Ass "
		+ "\nwhen modding support & Workshop becomes available"
		+ "\nPlease buy the sofware right now by pressing ENTER to go to the Steam store."
		+ "\nIf the new software is not yet available, still press ENTER & then please wishlist da right now."
		+ "\nRemember to buy the software legit when it's available now.";
	public static final HAS_BEEN_OBSOLETE:String = "ATTENTION!"
		+ "\nThis mod has been OBSOLETE! (Though, you can still ESC to use this mod anyway)"
		+ "\nThe new software is available for purchase by pressing ENTER"
		+ "\nwhich is this Friday Night Funkin: Full Ass. Please use this instead"
		+ "\nAll mods are available in the Workshop, thancc."
		+ "\nRemember, buy it legit! yeah.";
	public static final OBSOLESENCE_MODE:Int = 0; // Raise this to declare obsolete. only do this when Full Ass with modding support available.
	// Obsolesence stages:
	// 0: not obsolete. no full ass available yet
	// 1: going to be. full ass but no modding yet
	// 2: already obsolete. full ass with modding available.
	public static final STAY_LONGER_VOUCHER:String = "Stay Longer voucher applied "
		+ "\n(1 Staylong @ untrash/unprivate; Bonus 15 Staylong for all 3 comebacks):"
		+ "\n-Sky"
		+ "\n-Whitty"
		+ "\nKeep in mind, new mods will still be on Full Ass instead of here, sorry.";
	#if systools
	// public static final SAVE_LEVEL_FILTER:FILEFILTERS = {
	// 	count: 1,
	// 	descriptions: ["JSON file"],
	// 	extensions: ["*.json"]
	// }
	#end
	public static final NULL_DEATH_SOUND_PATHS:Array<DeathSoundPath> = [
		{
			pathPrefix: 'fnf_loss_sfx',
			volume: 1.0,
		},
	];
	public static final NULL_DEATH_CHARACTER:String = 'bf'; // use this char if bellow is false
	public static final NULL_DEATH_CHARACTER_IS_AS_SAME_AS_THIS:Bool = true; // this thing. is the death frame is in the same char or other file?
	public static final NULL_RANDOMIZED_DEATH_SOUND_PATHS:Array<RandomizedDeathSoundPath> = [];
	public static final NULL_RISE_UP_AGAIN_SOUND_PATHS:Array<DeathSoundPath> = [];
	public static final NULL_RANDOMIZED_RISE_UP_AGAIN_SOUND_PATHS:Array<RandomizedDeathSoundPath> = [];
	public static final NULL_HEART_SPEC:SwagHeart = {
		character: "null",
		isEmulator: false,
		initHR: 70,
		maxHR: 220,
		minHR: 70,
		baseRateScale: 70,
		heartTierBoundaries: [90, 120, 150, 200],
		successionAdrenalAdd: [4, 3, 2, 1],
		fearShockAdd: [10, 8, 7, 5],
		relaxMinusPerBeat: [1, 2, 4, 7],
		diastoleInTimeOf: [.1, .08, .06, .04, .02],
		relaxHeartEveryBeatOf: 4,
		requiredCPRCompression: 20,
		giveCPRTokenEachBlow: 5,
		postArrestRestoreRate: 50,
		tendencyToFibrilationAt: -1,
		stimulateInYayDidOf: 5,
		systoleSoundPath: "",
		diastoleSoundPath: "",
	};
	public static final NULL_DIALOGUE_CHAT:Array<String> = ['dad:blah blah blah', 'bf:coolswag'];
	public static final NULL_EPILOGUE_CHAT:Array<String> = ['dad:oh no I lose', 'bf: beep boop baaa hey!'];
	public static final NULL_DIALOGUE_FONT:String = "Pixel Arial 11 Bold";
	public static final NULL_DIALOGUE_FONT_DROP:String = "Pixel Arial 11 Bold";
	public static final NULL_DIALOGUE_FONT_COLOR:String = "0xFF3F2021";
	public static final NULL_DIALOGUE_FONT_COLOR_DROP:String = "0xFFD89494";
	public static final NULL_DIALOGUE_SOUND_PATHS:Array<String> = ['pixelText'];
	public static final NULL_DIALOGUE_SOUND_VOLUME:Float = .6;
	public static final NULL_DEATH_SOUND_VOLUME:Float = .3;
	public static final BIOS_BUTTON_DELAY_TIME:Float = 2;
	public static final BIOS_BUTTON_SAY:String = "Press ESCAPE / Gamepad SELECT to go to BIOS setting";
	public static final METRONOME_FIRST_OFF_ICON:String = "O";
	public static final METRONOME_FIRST_TICK_ICON:String = "A";
	public static final METRONOME_REST_OFF_ICON:String = "o";
	public static final METRONOME_REST_TICK_ICON:String = "a";
	// see https://github.com/HaxeFlixel/flixel-demos/blob/dev/UserInterface/FlxTextFormat/source/PlayState.hx
	// https://haxeflixel.com/demos/FlxTextFormat/
	public static final METRONOME_FIRST_FONT_FORMAT:FlxTextFormat = new FlxTextFormat(FlxColor.RED, true, false, FlxColor.CYAN);
	public static final METRONOME_REST_FONT_FORMAT:FlxTextFormat = new FlxTextFormat(FlxColor.BLUE, true, false, FlxColor.LIME);
	public static final METRONOME_OFF_FONT_FORMAT:FlxTextFormat = new FlxTextFormat(FlxColor.WHITE, false, false, FlxColor.BLACK);
	public static final METRONOME_FIRST_SYNTAX:String = '<MetroFirst>';
	public static final METRONOME_REST_SYNTAX:String = '<MetroRest>';
	public static final METRONOME_OFF_SYNTAX:String = '<MetroOff>';
	public static final METRONOME_FORMAT_BINDINGS:Array<FlxTextFormatMarkerPair> = [
		new FlxTextFormatMarkerPair(METRONOME_FIRST_FONT_FORMAT, METRONOME_FIRST_SYNTAX),
		new FlxTextFormatMarkerPair(METRONOME_REST_FONT_FORMAT, METRONOME_REST_SYNTAX),
		new FlxTextFormatMarkerPair(METRONOME_OFF_FONT_FORMAT, METRONOME_OFF_SYNTAX),
	];
	public static final METRONOME_FIRST_SOUND_PATH:String = "CLAP-midi-ding";
	public static final METRONOME_REST_SOUND_PATH:String = "CLAP-midi";
	public static final NOTE_SNAP_SOUND_PATH:String = "SNAP";
	public static final SONG_POS_BAR_COLOR:FlxColor = FlxColor.fromRGB(0, 255, 128); // default color of bar
	public static final VIDEO_DISABLED_OPTION_NAME:String = "(Workaround) Disable Video";
	public static final VIDEO_DISABLED_TITLE:String = "Video Disabled";
	public static final VIDEO_DISABLED_DESCRIPTION:String = 'You have setting that disabled video.\nTo reenable, go to Setting, Misc, uncheck ${VIDEO_DISABLED_OPTION_NAME}';
	public static final LYRIC_ENABLED_OPTION_NAME:String = 'Kpop Lyrics';
	public static final LYRIC_POSITION_OPTION_NAME:String = 'Lyrics Position';

	public static final API_DISCORD_CLIENT_ID:String = "557069829501091850"; // change to whatever the peck you want lol

	public static final SEPARATOR_DIALOG:String = "::";
	public static final SEPARATOR_LYRIC:String = "::";

	public static final QMOVEPH_BG_COLORS:Array<FlxColor> = [0xFF00A0FF, 0xFF00CEFF, 0xFF505050,];
	public static final QMOVEPH_BG_COLORS_STORY:Array<FlxColor> = [0xFF020077, 0xFF002833, 0xFF0D051F,];

	// Here image misc
	public static final CRASH_TEXT_BANNER:String = "
	████████████████████████████████████████████████████████████████████████████████
	█      ░▒▒▒▒▒▒▒░                                                               █
	█    ░░░░▒▒▒░░░░░    ███████         █        █  ██    █   ███       ███       █
	█   ░▒░░░░░░▒▒▒░░░   █               █        █ █  █   █   █  █        █       █
	█  ░░▒░░▒▒░░░▒░░▒░░  ███████ █ █ ███ █  ███ ███ ████ ███   █  █ █  █ ███ ████  █
	█         ░▒         █        █  █ █ █  █ █ █ █ █    █ █   █  █ █  █ █ █ █     █
	█    ░▓█████████▒    ███████ █ █ ███ ██ ███ ███  ██  ███   ███  ███  ███ █     █
	█         ░░                     █                                             █
	█         ▒▒                       M E D I T A T I O N ! ! !                   █
	█      ░░▒░▒░▓░                                                                █
	████████████████████████████████████████████████████████████████████████████████
	
	(image by JOELwindows7. CC4.0-BY-SA)\n
	
	";

	public static final LFM_LOGO_BANNER = "
	██████████████████████████████████████████████████████████████████████████████
	█▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░▒▒▒█
	█▒░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░░░▒▒▒▒▒▒▒▒▒░▒▒▒▒▒▒▒▒▒▒▒▒░▒▒▒▒▒░▒░░░░▒░░░░░▒░▒▒▒▒▒▒█
	█▒░▒▒▒▒░░░░▒░░░░▒░▒▒▒▒▒░▒▒▒▒▒▒▒▒▒▒▒▒▒▒░▒▒▒▒░▒▒▒▒▒▒▒░░▒▒▒░░▒░▒▒░▒░▒░▒░▒░░░░▒▒▒█
	█▒░▒▒▒▒▒▒▒░▒░▒▒▒▒░▒▒▒▒▒░░░░▒▒▒▒▒▒▒▒▒▒▒░▒░░▒▒▒▒▒▒▒▒▒░▒░▒░▒░▒░░░░▒░▒░▒░▒░▒▒▒▒▒▒█
	█▒░▒▒▒▒░░░░▒░░░░▒░░░░▒▒░▒▒▒▒░▒▒░▒░░░▒▒░░▒▒▒░▒░░░▒▒▒░▒▒░▒▒░▒▒▒▒▒▒░▒▒▒▒▒░░░░▒▒▒█
	█▒░▒▒▒▒░▒▒░▒▒▒▒░▒░▒▒▒▒▒░▒▒▒▒░▒▒░▒░▒▒░▒░▒░▒▒░▒░▒▒░▒▒░▒▒▒▒▒░▒░░░░▒░░░▒▒▒▒▒▒▒▒▒▒█
	█▒░░░░▒▒░░░▒░░░░▒░░░░▒▒░▒▒▒▒▒░░░▒░▒▒░▒░▒▒░▒░▒░▒▒░▒▒░▒▒▒▒▒░▒░▒▒░▒░▒▒▒▒▒s▒▒▒▒▒▒█
	█▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░▒▒▒▒▒▒▒▒▒▒█
	██████████████████████████████████████████████████████████████████████████████
	";

	public static final HARDCODE_GAMEOVER_ENEMY_INSULTS:Array<Array<String>> = [
		[
			// Tankman
			// '',
			'I said let\'s rock, not suck cock, XD!!!!!!',
			'Oh ho my God, what the hell was that?\n what the hell was THAT?',
			'I guess your shooting hair dyes got in your eyes.\nIt\'s okay, it happens to all of us.',
			'Maybe you should play Week 1 again. XD!!!!!!!',
			'Can you even feed yourself? Can you even walk straight?',
			//
			'Maybe if you had more friend then you\'d be less depressed and play better, mmM??',
			'You\'re ugly, and you can\'t keep a rhythm. \nTrully you are cursed.',
			'Man, are you tired of eating shit yet? XD!!!!!!!',
			'Ey you\'re getting closer. I won\'t brag about it tho..',
			'No wonder your parents hate you. .. XD!!!!!!!\n(sniff)!!',
			//
			'If you can\'t beat me, how are you gonna survive this harsh and cruel world, hMM??',
			'The only thing you\'re Funkin\' tonight is your sock.',
			'Why I\'m wasting my time against some baggy pants... fucked?, XD!!!!!!!!',
			'Why I\'m wasting my time against some baggy pants... punk?',
			'Hey here\'s some Friday Night Funkin\' lore for ya:\nI DON\'T LIKE YOU!',
			//
			'You just make me wanna cry T_T....',
			'You know I\'m running outta shit to say here, so you better beat this sometime today, asshole!',
			'Congratulations, you won. That\'s what I would say if you weren\'t such a Goddamn.. failure, .. XD!!!!!!!',
			'You gotta press the Arrows, kid, don\'t slap the keyboard like your blind uncle, WHAT??',
			'You feel that? That\'s called failure and you\'d better get used to it. Heh heh hee...',
			//
			'Open your fuckin\' eyes, geez!!',
			'I hope you\'re not some internet streamer screaming like a sociopath right now..',
			'That waaas terrible.\nJuuust terrible.',
			'My dead grandmother has more nimble fingers, come on!!',
			'Good Lord, what the hell is your problem, man?!\n(Burp).., just do it right, PLEASE!',
		],
		[
			// Shang Tsung
			'Your soul, is mine!',
		],
		[
			// Sans
			'Get dunk\'d on, kid.',
		],
	];

	public static final MAIN_MENU_MUSICS:Array<Array<Dynamic>> = [
		// path filename of the music
		['freakyMenu', 102], // Default
		['ke_freakyMenu', 102], // Kade Engine
	];

	public static final LANGUAGES_AVAILABLE:Array<Array<String>> = [['en-US', 'English (US)'], ['id-ID', 'Bahasa Indonesia'],];
}
