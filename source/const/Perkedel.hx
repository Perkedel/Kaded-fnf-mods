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

import flixel.util.FlxColor;
import DokiDoki;

class Perkedel
{
	public static final OPTION_SAY_NEED_RESTART_SONG:String = "(Restart Song Required) ";
	public static final OPTION_SAY_CANNOT_ACCESS_IN_PAUSE:String = "(Can't access / toggle! in pause rn) "; // In kade it was "This option cannot be toggled in the pause menu."
	public static final MAX_FPS_CAP:Int = 3000; // JOELwindows7: usually 290
	public static final MIN_FPS_CAP:Int = 60; // JOELwindows7: usually 60
	public static final OPTION_CATEGORY_LENGTH:Int = 6; // How many categories on option menu? was 4, now we got 6. no wait that's DFJK.
	public static final ENGINE_NAME:String = "Last Funkin Moments"; // oh yeah LFM baby!
	public static final ENGINE_ID:String = "Last-Funkin-Moments"; // oh yeah LFM baby!
	public static final ENGINE_ABBREVIATE:String = "LFM"; // oh yeah LFM baby!
	public static final ENGINE_VERSION:String = "2022.06.0"; // current version number yeah!
	public static final ENGINE_NIGHTLY:String = ""; // say `-larutmalam` to mark this nightly build
	public static final ENGINE_VERSION_URL:String = 'https://raw.githubusercontent.com/Perkedel/kaded-fnf-mods/stable/versionLastFunkin.downloadMe'; // here URL check
	public static final ENGINE_CHANGELOG_PREFIX_URL:String = 'https://odysee.com/@JOELwindows7/LFM-changelog-'; // here URL of change log prefix, appened by what version needed there.
	public static final ENGINE_CORE_HANDLE_CRASH:Bool = true; // if true, engine will handle crash and restart. if false, engine will not handle crash and restart.
	public static final DONATE_BUTTON_URL:String = 'https://odysee.com/@JOELwindows7:a/LFM-links:a'; // here URL of donate button
	public static final ENABLE_MODS:Bool = true;
	public static final ENABLE_VERSION_CHECK:Bool = true;
	public static final CHART_EVENTS:Array<String> = [
		"Camera Zoom in", "HUD Zoom in", "Both Zoom in", "Shake camera", "Cheer Now", "Hey Now", "Cheer Hey Now", "Lightning Strike", "BPM Change",
		"Scroll Speed Change", "Vibrate for", "LED ON for", "Blammed Lights", "Appear Blackbar", "Disappear Blackbar"
	];
	public static final LFM_ICON_PATH_DOC:String = "art/LFMicon128";
	public static final STARTUP_TOAST_TITLE:String = "Cool and good";
	public static final STARTUP_TOAST_DESCRIPTION:String = "Welcome to Last Funkin Moments\n Today's Kontraktua Majoris\n (2 of 3): Sky, Whitty";
	public static final MAX_AVAILABLE_JUDGEMENT_RATING:Int = 3; // only up to sick we have.
	public static final MAX_NUMBER_OF_LOADING_IMAGES:Int = 3; // how many loading backdrops do we have here?
	public static final DISCLAIMER_SAY:String = "Disclaimer";
	public static final LOADING_TOO_LONG_TIME_THRESHOLD:Float = 30; // if the loading took more than 30 second
	public static final LOADING_TOO_LONG_SAY:String = 'Too long, didn\'t load? [OK]/[ENTER]/(START) Skip, [BACK]/[ESC]/(B) Cancel';
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
	public static final BIOS_BUTTON_DELAY_TIME:Float = 2;
	public static final BIOS_BUTTON_SAY:String = "Press ESCAPE / Gamepad SELECT to go to BIOS setting";
	public static final METRONOME_FIRST_OFF_ICON:String = "O";
	public static final METRONOME_FIRST_TICK_ICON:String = "A";
	public static final METRONOME_REST_OFF_ICON:String = "o";
	public static final METRONOME_REST_TICK_ICON:String = "a";
	public static final METRONOME_FIRST_SOUND_PATH:String = "CLAP-midi-ding";
	public static final METRONOME_REST_SOUND_PATH:String = "CLAP-midi";
	public static final NOTE_SNAP_SOUND_PATH:String = "SNAP";
	public static final SONG_POS_BAR_COLOR:FlxColor = FlxColor.fromRGB(0, 255, 128); // default color of bar
}
