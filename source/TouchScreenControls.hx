import flixel.ui.FlxVirtualPad;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;

/**
 * Control Group enums from that luckydog7
 * https://github.com/luckydog7/Funkin-android/blob/master/source/ui/Mobilecontrols.hx
 */
enum ControlsGroup {
	VIRTUALPAD_RIGHT;
	VIRTUALPAD_LEFT;
	KEYBOARD;
	VIRTUALPAD_CUSTOM;
	HITBOX;
}

/**
 *  Touch screen gameplay button protocolers
 *  peck it just steal it from 
 *  https://github.com/luckydog7/Funkin-android/blob/master/source/ui/Mobilecontrols.hx
 * 
 * @author JOELwindows7
 */
class OnScreenGameplayButtons extends FlxSpriteGroup{
    public var mode:ControlsGroup = HITBOX;

	public var _hitbox:TouchScreenControls;
	public var _virtualPad:FlxVirtualPad;

	public function new(){
        super();

        _hitbox = new TouchScreenControls(4);
        //add(_hitbox);
    }
}

/**
 *  an touch screen controls
 * 
 *  How many buttons?
 *  4 = DDR, Funkin 1 player
 *  6 = Shaggy .008% power
 *  8 = DDR double
 *  9 = Shaggy God eater
 * 
 * @author JOELwindows7
 * 
 */
class TouchScreenControls extends FlxSpriteGroup{
    var howManyButtons:Int = 4;
    public var initVisible = false;
    public var daButtoners:FlxTypedGroup<FlxButton>;
    var colorSchemes:Array<FlxColor> = [FlxColor.MAGENTA, FlxColor.CYAN, FlxColor.LIME, FlxColor.RED];
    public function new(howManyButtons:Int = 4, initVisible:Bool = false){
        daButtoners = new FlxTypedGroup<FlxButton>();
        this.howManyButtons = howManyButtons;
        this.initVisible = initVisible;
        super(); 
    }

    // inspire it from https://github.com/luckydog7/Funkin-android/blob/master/source/ui/Hitbox.hx
    public function addDeezButton(positionX:Float = 0, positionY:Float = 0, sizeX:Float, sizeY:Float, handoverGraphic:FlxGraphic, index:Int = 0){
        var button = new FlxButton(positionX, positionY);
        var graphic:FlxGraphic = FlxGraphic.fromRectangle(
            Std.int(sizeX != 0? sizeX : FlxG.width/howManyButtons),
            Std.int(sizeY != 0? sizeY : FlxG.height),
            colorSchemes[index]);

        button.loadGraphic(handoverGraphic != null? handoverGraphic : graphic);
        button.alpha = 0;

        button.onDown.callback = function (){
			FlxTween.num(0, 0.75, .075, {ease: FlxEase.circInOut}, function (a:Float) { button.alpha = a; });
		};

		button.onUp.callback = function (){
			FlxTween.num(0.75, 0, .1, {ease: FlxEase.circInOut}, function (a:Float) { button.alpha = a; });
		}
		
		button.onOut.callback = function (){
			FlxTween.num(button.alpha, 0, .2, {ease: FlxEase.circInOut}, function (a:Float) { button.alpha = a; });
		}

        return button;
    }

    public function initDoseButtons(spriteMode:Bool = false){
        for(i in 0...howManyButtons){
            var anButtoneg:FlxSprite = new FlxSprite(i * (FlxG.width/howManyButtons));
            anButtoneg.makeGraphic(
                Std.int(FlxG.width/howManyButtons), 
                Std.int(FlxG.height), 
                colorSchemes[i]
            );

            anButtoneg.alpha = 0.25;
            anButtoneg.ID = i;
            //add(anButtoneg);
            
            var daButtoneg:FlxButton = addDeezButton(
                (FlxG.width/howManyButtons),
                (FlxG.height),
                (FlxG.width/howManyButtons),
                (FlxG.height),
                anButtoneg.graphic,
                i
            );
            daButtoners.add(daButtoneg);
            // add(daButtoneg);
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