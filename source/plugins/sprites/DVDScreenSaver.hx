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

//https://snippets.haxeflixel.com/collision/1-to-1-collision/

/**
 * DVD screensaver. running sprite that bounces back when hit the screen border.
 * @author JOELwindows7
 */
class DVDScreenSaver extends FlxSprite{

    public function new(?theGraphic:FlxGraphicAsset, velocityX:Float = 100, velocityY:Float = 100){
        super();
        if(theGraphic == null){
            loadGraphic(new GraphicLogo(64,64));
        }
        x = FlxG.random.float(0,FlxG.width-width-100);
        y = FlxG.random.float(0,FlxG.height-height-100);
        velocity.x = velocityX;
        velocity.y = velocityY;
        updateHitbox();
    }

    override function update(elapsed){
        //FlxG.collide(); // enabling this will push elements away! dont do that
        if(x<=0 || x>= FlxG.width-width) velocity.x *= -1;
        if(y<=0 || y>= FlxG.height-height) velocity.y *= -1;
        super.update(elapsed);
    }
}