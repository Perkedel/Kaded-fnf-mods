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
            loadGraphic(FlxAssets.getBitmapData("flixel/images/logo/logo"));
        }
        x = FlxG.width/2;
        y = FlxG.height/2;
        velocity.x = velocityX;
        velocity.y = velocityY;
        
    }

    override function update(elapsed){
        //FlxG.collide();
        if(x<=0 || x>= FlxG.width) velocity.x *= -1;
        if(y<=0 || y>= FlxG.height) velocity.y *= -1;
        super.update(elapsed);
    }
}