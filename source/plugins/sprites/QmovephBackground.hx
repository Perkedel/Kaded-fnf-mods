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

import flixel.addons.ui.FlxUISprite;
import flixel.graphics.FlxGraphic;
import flixel.FlxBasic;
import flixel.util.FlxGradient;
import flixel.util.FlxColor;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

/**
 * The infamous default background of Perkedel Technologies. Now animated here yeya!
 * @author JOELwindows7
 */
class QmovephBackground extends FlxGroup{
    var bg:FlxUISprite;
    var stars:FlxTypedGroup<QmovephFlying>;
    var starSpawnTime:Float;
    var bubbles:FlxTypedGroup<QmovephFlying>;
    var bubbleSpawnTime:Float;
    public function new(){
        
        super();
    }
    public function startDoing(){
        // bg = FlxGradient.createGradientFlxSprite(
        //     FlxG.width, FlxG.height,
        //     [
        //         FlxColor.fromRGB(0,160,255),
        //         FlxColor.fromRGB(0,206,255),
        //         FlxColor.fromRGB(80,80,80)
        //     ]
        //     )
        //     ;
        bg = new FlxUISprite(0,0,Paths.image("DefaultBackground-empty720p"));
        trace("addre");
        stars = new FlxTypedGroup<QmovephFlying>(50);
        trace("dreea");
        bubbles = new FlxTypedGroup<QmovephFlying>(50);
        trace("druuu " + Std.string(bg) + " " + Std.string(stars) + " " + Std.string(bubbles) + " ");
        add(bg);
        trace("add bg");
        add(stars);
        trace("add stars");
        add(bubbles);
        trace("druuua");
    }
    override function update(elapsed:Float){
        if(stars != null){
            starSpawnTime += elapsed * 5;
            if (starSpawnTime > 1)
            {
                starSpawnTime--;
                stars.add(stars.recycle(QmovephFlying.new));
            }
        }   

        if(bubbles != null){
            bubbleSpawnTime += elapsed * 5;
            if (bubbleSpawnTime > 1)
            {
                bubbleSpawnTime--;
                var reBubble = bubbles.recycle(QmovephFlying.new);
                reBubble.aStar = false;
                bubbles.add(reBubble);
            }
        }

        super.update(elapsed);
    }
}

/**
 * The flying objects in this Qmoveph background. can be circle or star
 * @author JOELwindows7
 */
class QmovephFlying extends FlxUISprite{
    public var aStar:Bool = true;
    public function new()
    {
        super();
        // this.aStar = aStar;
        if(this.aStar){
            //trace("Star pls");
        } else {
            //trace("Bubbles pls");
        }
        kill();
    }

    override public function revive()
    {
        var ratio = FlxG.random.float(0.2,1.2);
        scale.x = ratio;
        scale.y = ratio;
        x = FlxG.width;
        y = aStar? 
            FlxG.random.int(0, Std.int((FlxG.height/2) - height)):
            FlxG.random.int(Std.int((FlxG.height/2)-height), Std.int(FlxG.height - height))
            ;
        loadGraphic(Paths.image(aStar? "QmovephStar" : "QmovephBubble"));
        velocity.x = -(FlxG.random.float(200,750));
        angularVelocity = FlxG.random.float(-720,720);
        color = FlxG.random.color(FlxColor.fromRGB(10,10,10),FlxColor.WHITE);
        updateHitbox();
        super.revive();
    }

    override public function update(elapsed:Float)
    {
        if (x < -width)
            kill();
        super.update(elapsed);
    }
}

class QmovephBubble extends FlxUISprite{
    public function new()
    {
        super();
        kill();
    }

    override public function revive()
    {
        var ratio = FlxG.random.float(0.2,1.2);
        scale.x = ratio;
        scale.y = ratio;
        x = FlxG.width;
        y = FlxG.random.int(Std.int((FlxG.height/2)-height), Std.int(FlxG.height - height))
            ;
        loadGraphic(Paths.image("QmovephBubble"));
        velocity.x = -(FlxG.random.float(500,1000));
        angularVelocity = FlxG.random.float(-720,720);
        color = FlxG.random.color(FlxColor.fromRGB(10,10,10),FlxColor.WHITE);
        updateHitbox();
        super.revive();
    }

    override public function update(elapsed:Float)
    {
        if (x < -width)
            kill();
        super.update(elapsed);
    }
}