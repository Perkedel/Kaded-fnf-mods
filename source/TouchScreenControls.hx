import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;

/**
 *  an touch screen controls
 * 
 *  How many buttons?
 *  4 = DDR, Funkin 1 player
 *  6 = Shaggy .008% power
 *  8 = DDR double
 *  9 = Shaggy God eater
 * 
 *  @author: JOELwindows7
 */

class TouchScreenControls extends FlxTypedGroup<FlxSprite>{
    var howManyButtons:Int = 4;
    public var initVisible = false;
    var colorSchemes:Array<FlxColor> = [FlxColor.MAGENTA, FlxColor.CYAN, FlxColor.LIME, FlxColor.RED];
    public function new(howManyButtons:Int = 4, initVisible:Bool = false){
        this.howManyButtons = howManyButtons;
        this.initVisible = initVisible;
        super(); 
    }

    public function initDoseButtons(){
        for(i in 0...howManyButtons){
            var anButtoneg:FlxSprite = new FlxSprite(i * (FlxG.width/howManyButtons));
            anButtoneg.makeGraphic(
                Std.int(FlxG.width/howManyButtons), 
                Std.int(FlxG.height), 
                colorSchemes[i]
            );

            anButtoneg.alpha = 0.25;
            anButtoneg.ID = i;
            add(anButtoneg);
        }
        visible = initVisible;
    }

    function pressDaButton(thingy:FlxSprite, isOnIt:Bool){
        if(thingy != null){
            if(isOnIt){
                thingy.alpha = .5;
            } else {
                thingy.alpha = .25;
            }
        }
    }

    override function update(elapsed:Float) {
        //JOELwindows7: oh no, For inside For. this is not good performance
        if(visible)
            forEach(function(thingy:FlxSprite){
                for(touch in FlxG.touches.list){
                    pressDaButton(thingy, touch.overlaps(thingy) && touch.pressed);
                }
            });
        super.update(elapsed);
    }
}