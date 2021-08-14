package plugins.sprites;

import flixel.graphics.FlxGraphic;
import flixel.FlxBasic;
import flixel.util.FlxGradient;
import flixel.util.FlxColor;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

class QmovephBackground extends FlxGroup{
    var bg:FlxSprite;
    var stars:FlxTypedGroup<QmovephFlying>;
    var starSpawnTime:Float;
    var bubbles:FlxTypedGroup<QmovephBubble>;
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
        bg = new FlxSprite(0,0,Paths.image("DefaultBackground-empty720p"));
        trace("addre");
        stars = new FlxTypedGroup<QmovephFlying>(20);
        trace("dreea");
        bubbles = new FlxTypedGroup<QmovephBubble>(20);
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
            if (starSpawnTime > 1)
            {
                bubbleSpawnTime--;
                var reBubble = bubbles.recycle(QmovephBubble.new);
                reBubble.aStar = false;
                bubbles.add(reBubble);
            }
        }

        super.update(elapsed);
    }
}

class QmovephFlying extends FlxSprite{
    public var aStar:Bool = true;
    public function new()
    {
        super();
        // this.aStar = aStar;
        if(this.aStar){
            trace("Star pls");
        } else trace("Bubbles pls");
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
        velocity.x = -(FlxG.random.float(500,1000));
        angularVelocity = FlxG.random.float(-100,100);
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

class QmovephBubble extends QmovephFlying{
    override public function new(){
        this.aStar = false;
        trace("a bubble, star is " + Std.string(aStar));
        super();
    }
    override function revive(){
        aStar = false;
        super.revive();
    }
}