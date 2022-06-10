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

/** CarryAround.hx. lots of static variable you can carry around.
 * @author JOELwindows7
 */
package utils;

class CarryAround
{
	/** JOELwindows7: store lines of birthday stuffs, and its date when. use Cool text get line to collect names, months, and dates.
	 * If there are more than 1 person at the same date, simply comma in the name of that same line.
	 * 
	 */
	public static var hbdLines:Array<String>;

	/**
	 * JOELwindows7: fillout vars for Outro
	 */
	public static var __isNextSong:Bool;

	public static var __handoverName:String;
	public static var __handoverDelayFirst:Float;
	public static var __handoverHasEpilogueVid:Bool;
	public static var __handoverEpilogueVidPath:String;
	public static var __handoverHasTankmanEpilogueVid:Bool;
	public static var __handoverTankmanEpilogueVidPath:String;

	static var _modAlreadyLoaded:Bool = false;
	static var _supportsModding:Bool = false;

	public static function modAlreadyLoaded():Bool
	{
		return _modAlreadyLoaded;
	}

	public static function raiseModAlreadyLoaded():Void
	{
		_modAlreadyLoaded = true;
	}

	public static function supportsModding():Bool
	{
		return _supportsModding;
	}
}
