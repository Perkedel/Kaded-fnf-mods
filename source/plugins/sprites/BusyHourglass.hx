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