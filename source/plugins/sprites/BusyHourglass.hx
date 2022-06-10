/**
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

package plugins.sprites;

import flixel.FlxG;
import flixel.system.FlxAssets;
import flixel.graphics.FlxGraphic;
import openfl.display.Sprite;
import flixel.FlxSprite;

/**
 * Busy hourGlass for loading animation stuffs
 * @author JOELwindows7
 */
class BusyHourglass extends FlxSprite{
    public function new(positionX:Float = 100, positionY:Float = 100){
        super();
        frames = Paths.getSparrowAtlas('Gravity-HourGlass');
        animation.addByPrefix('working', 'Gravity-HourGlass idle', 24);
        animation.play('working');
        setPosition(positionX, positionY);
        updateHitbox();
    }
}

//Test import random stuff
// import flixel.FlxG;
// import plugins.sprites.DVDScreenSaver;
//nope! this is not allowed after declaration