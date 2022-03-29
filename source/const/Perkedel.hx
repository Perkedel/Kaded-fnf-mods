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

class Perkedel
{
	public static final OPTION_SAY_NEED_RESTART_SONG:String = "(Restart Song Required) ";
	public static final OPTION_SAY_CANNOT_ACCESS_IN_PAUSE:String = "(Can't access / toggle! in pause rn) "; // In kade it was "This option cannot be toggled in the pause menu."
	public static final MAX_FPS_CAP:Int = 3000; // JOELwindows7: usually 290
	public static final MIN_FPS_CAP:Int = 60; // JOELwindows7: usually 60
	public static final OPTION_CATEGORY_LENGTH:Int = 6; // How many categories on option menu? was 4, now we got 6. no wait that's DFJK.
	public static final ENGINE_NAME:String = "Last Funkin Moments"; // oh yeah LFM baby!
	public static final ENGINE_VERSION:String = "2022.03.180"; // current version number yeah!
	public static final ENGINE_NIGHTLY:String = ""; // say `-larutmalam` to mark this nightly build
	public static final ENGINE_VERSION_URL:String = 'https://raw.githubusercontent.com/Perkedel/kaded-fnf-mods/stable/versionLastFunkin.downloadMe'; // here URL check
	public static final ENGINE_CHANGELOG_PREFIX_URL:String = 'https://odysee.com/@JOELwindows7/LFM-changelog-'; // here URL of change log prefix, appened by what version needed there.
	public static final DONATE_BUTTON_URL:String = 'https://odysee.com/@JOELwindows7:a/LFM-links:a'; // here URL of donate button
	public static final ENABLE_MODS:Bool = true;
	public static final ENABLE_VERSION_CHECK:Bool = true;
}
