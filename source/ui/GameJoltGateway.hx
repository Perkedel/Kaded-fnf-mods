/*
 * GNU General Public License, Version 3.0
 *
 * Copyright (c) 2022 Perkedel
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

package ui;

#if gamejolt
import GameJolt;
#end

/**
 * Gateway to and out from GameJolt, for compatibilities kludgeing.
 */
class GameJoltGateway extends MusicBeatState
{
	public static var getOut:Bool = false;

	public var handoverState:MusicBeatState = new MainMenuState();

	public function new(handoverState:MusicBeatState)
	{
		super();
		// this.getOut = getOut;
		this.handoverState = handoverState;
	}

	override function create()
	{
		super.create();
		if (getOut)
		{
			switchState(handoverState, false, false, false);
		}
		else
		{
			#if gamejolt
			FlxG.switchState(new GameJoltLogin());
			#else
			Debug.logWarn("GameJolt unsupported! getting out immediately");
			getOut = true;
			createToast(null, "GameJolt unsupported!", "getting out immediately.");
			switchState(handoverState, false, false, false);
			#end
		}
	}
}
