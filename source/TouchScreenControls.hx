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
    var howManyButtons:Int = 4;
    public var initVisible = false;
    public var mode:ControlsGroup = HITBOX;

	public var _hitbox:TouchScreenControls;
	public var _virtualPad:FlxVirtualPad;

	public function new(howManyButtons:Int = 4, initVisible:Bool = false){
        this.howManyButtons = howManyButtons;
        this.initVisible = initVisible;
        super();

        _hitbox = new TouchScreenControls(howManyButtons, initVisible);
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
    public var hitbox:FlxSpriteGroup;
    var colorSchemes:Array<FlxColor> = [FlxColor.MAGENTA, FlxColor.CYAN, FlxColor.LIME, FlxColor.RED];

    public var buttonLeft:FlxButton;
	public var buttonDown:FlxButton;
	public var buttonUp:FlxButton;
	public var buttonRight:FlxButton;

    public function new(howManyButtons:Int = 4, initVisible:Bool = false){
        daButtoners = new FlxTypedGroup<FlxButton>();
        this.howManyButtons = howManyButtons;
        this.initVisible = initVisible;
        super();
        
        hitbox = new FlxSpriteGroup();
        hitbox.scrollFactor.set();
        //initDoseButtons();
        bruteForceButtons();
        //visible = initVisible;
    }

    // inspire it from https://github.com/luckydog7/Funkin-android/blob/master/source/ui/Hitbox.hx
    public function addDeezButton(positionX:Float = 0, positionY:Float = 0, sizeX:Float, sizeY:Float, handoverGraphic:FlxGraphic, index:Int = 0){
        var button = new FlxButton(positionX, positionY);
        var graphic:FlxGraphic = FlxGraphic.fromRectangle(
            Std.int(sizeX != 0? sizeX : FlxG.width/howManyButtons),
            Std.int(sizeY != 0? sizeY : FlxG.height),
            colorSchemes[index]);
        //var graphic:FlxGraphic = handoverGraphic;

        //button.loadGraphic(handoverGraphic != null? handoverGraphic : graphic);
        button.loadGraphic(handoverGraphic);
        button.alpha = 0.2;

        button.onDown.callback = function (){
			FlxTween.num(0.2, 0.75, .075, {ease: FlxEase.circInOut}, function (a:Float) { button.alpha = a; });
		};

		button.onUp.callback = function (){
			FlxTween.num(0.75, 0.2, .1, {ease: FlxEase.circInOut}, function (a:Float) { button.alpha = a; });
		}
		
		button.onOut.callback = function (){
			FlxTween.num(button.alpha, 0.2, .2, {ease: FlxEase.circInOut}, function (a:Float) { button.alpha = a; });
		}

        return button;
    }

    public function bruteForceButtons(){
        var graphic:FlxGraphic = FlxGraphic.fromRectangle(
            Std.int(FlxG.width/howManyButtons),
            Std.int(FlxG.height),
            colorSchemes[0]);
        var justImage:FlxSprite = new FlxSprite(
            Std.int(0*(FlxG.width/howManyButtons)),
            Std.int(FlxG.height)
        );
        justImage.makeGraphic(
            Std.int(FlxG.width/howManyButtons), 
            Std.int(FlxG.height), 
            colorSchemes[0]
        );

        hitbox.add(add(buttonLeft = addDeezButton(0*(FlxG.width/howManyButtons),0,(FlxG.width/howManyButtons),(FlxG.height),justImage.graphic,0)));
        hitbox.add(add(buttonDown = addDeezButton(1*(FlxG.width/howManyButtons),0,(FlxG.width/howManyButtons),(FlxG.height),justImage.graphic,1)));
        hitbox.add(add(buttonUp = addDeezButton(2*(FlxG.width/howManyButtons),0,(FlxG.width/howManyButtons),(FlxG.height),justImage.graphic,2)));
        hitbox.add(add(buttonRight = addDeezButton(3*(FlxG.width/howManyButtons),0,(FlxG.width/howManyButtons),(FlxG.height),justImage.graphic,3)));
    }

    public function initDoseButtons(spriteMode:Bool = false){
        for(i in 0...howManyButtons){
            /*
            var anButtoneg:FlxSprite = new FlxSprite(i * (FlxG.width/howManyButtons));
            anButtoneg.makeGraphic(
                Std.int(FlxG.width/howManyButtons), 
                Std.int(FlxG.height), 
                colorSchemes[i]
            );

            anButtoneg.alpha = 0.25;
            anButtoneg.ID = i;
            //add(anButtoneg);
            */
            
            /*
            var daButtoneg:FlxButton = addDeezButton(
                (FlxG.width/howManyButtons),
                (FlxG.height),
                (FlxG.width/howManyButtons),
                (FlxG.height),
                null,
                i
            );
            daButtoners.add(daButtoneg);
            // add(daButtoneg);
            */
            
            var tombol:FlxButton =  addDeezButton(i*(FlxG.width/howManyButtons),0,(FlxG.width/howManyButtons),(FlxG.height),null,i);
            tombol.ID = i;
            daButtoners.add(tombol);
            hitbox.add(add(daButtoners.members[i]));
        }
        //visible = initVisible;
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
        /*
        if(visible)
            forEach(function(thingy:FlxSprite){
                for(touch in FlxG.touches.list){
                    pressDaButton(thingy, touch.overlaps(thingy) && touch.pressed);
                }
            });
        */
        super.update(elapsed);
    }

    override public function destroy():Void{
        super.destroy();

        daButtoners.clear();
    }
}