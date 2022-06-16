import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUISprite;
import flixel.addons.ui.FlxUIGroup;
import flixel.util.FlxDestroyUtil;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxTileFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;
import ui.FlxVirtualPad; // use included virtualpad instead.
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
 * 
 * Oh I just shifted it around so yeah.
 * @author JOELwindows7
 */
enum ControlsGroup
{
	KEYBOARD;
	HITBOX;
	VIRTUALPAD_RIGHT;
	VIRTUALPAD_LEFT;
	VIRTUALPAD_BOTH;
	VIRTUALPAD_CUSTOM;
}

/**
 *  Touch screen gameplay button protocolers
 *  peck it just steal it from 
 *  https://github.com/luckydog7/Funkin-android/blob/master/source/ui/Mobilecontrols.hx
 * 
 * @author JOELwindows7
 */
class OnScreenGameplayButtons extends FlxUIGroup
{
	var howManyButtons:Int = 4;

	public var initVisible = false;
	public var mode:ControlsGroup = HITBOX;

	public var _hitbox:TouchScreenControls;
	public var _virtualPad:FlxVirtualPad;
	// public var _virtualPadBoth:FlxVirtualPad;
	// public var _virtualPadLeft:FlxVirtualPad;
	// public var _virtualPadRight:FlxVirtualPad;
	public var _alreadyAdded:Array<Bool>;

	public function new(howManyButtons:Int = 4, initVisible:Bool = false)
	{
		trace("Start On Screen Gameplay Button da right now");
		this.howManyButtons = howManyButtons;
		this.initVisible = initVisible;
		super();
		if (_alreadyAdded == null)
			_alreadyAdded = new Array<Bool>();
		_alreadyAdded = [false, false, false, false, false];
		initialize(howManyButtons, initVisible);
		trace("Enjoy your On Screen Gameplay Button da right now");
	}

	public function initialize(howManyButtons:Int = 4, initVisible:Bool = false)
	{
		trace("TouchScreenControls type " + Std.string(FlxG.save.data.selectTouchScreenButtons));

		switch (Std.int(FlxG.save.data.selectTouchScreenButtons))
		{
			case 0:
				trace("No touch screen buttons");
			case 1:
				if (_hitbox == null)
				{
					trace("have Hitbox now yeah");
					_hitbox = new TouchScreenControls(howManyButtons, initVisible);
					if (!_alreadyAdded[1])
						add(_hitbox);
					trace("hitboxen");
				}
			default:
				trace("no special case found, using init virtualpad instead");
				initVirtualPad(Std.int(FlxG.save.data.selectTouchScreenButtons), false);
		}
		chooseOnScreenButtons(Std.int(FlxG.save.data.selectTouchScreenButtons));
		trace("the pad type "
			+ Std.int(FlxG.save.data.selectTouchScreenButtons)
			+ " has "
			+ (_alreadyAdded[Std.int(FlxG.save.data.selectTouchScreenButtons)] ? " been added " : " not been added"));
		_alreadyAdded[Std.int(FlxG.save.data.selectTouchScreenButtons)] = true;
	}

	function chooseOnScreenButtons(whichOneIsIt:Int = 0)
	{
		trace("Chosen this " + Std.string(whichOneIsIt));
		// if(_virtualPadLeft != null) _virtualPadLeft.visible = false;
		// if(_virtualPadRight != null) _virtualPadRight.visible = false;
		// if(_virtualPadBoth != null) _virtualPadBoth.visible = false;
		if (_virtualPad != null)
			_virtualPad.visible = false;
		if (_hitbox != null)
			_hitbox.visible = false;

		switch (whichOneIsIt)
		{
			case 0:
				trace("Choose none touchscreen");
			// case 1:
			//     trace("hitboxo");
			//     if(_hitbox != null)
			//         _hitbox.visible = true;
			// case 2:
			//     if(_virtualPadLeft != null)
			//         _virtualPadLeft.visible = true;
			// case 3:
			//     if(_virtualPadRight != null)
			//         _virtualPadRight.visible = true;
			// case 4:
			//     trace("Fulling Gamepad");
			//     if(_virtualPadBoth != null)
			//         _virtualPadBoth.visible = true;
			default:
				if (_virtualPad != null)
					_virtualPad.visible = true;
		}
	}

	function initVirtualPad(vpadMode:Int, bruteForce:Bool = false)
	{
		switch (vpadMode)
		{
			case 0:
				// Keyboard only
				trace("nothing to init");
			case 1:
				// Hitboxe
				trace("that's a hitbox. go get your friend");
			case 2:
				// Left
				// if(bruteForce)
				//     _virtualPadLeft = new FlxVirtualPad(FULL, NONE);
				// else
				_virtualPad = new FlxVirtualPad(FULL, NONE);
			case 3:
				// Right
				// if(bruteForce)
				//     _virtualPadRight = new FlxVirtualPad(NONE,A_B_X_Y);
				// else
				_virtualPad = new FlxVirtualPad(NONE, A_B_X_Y);
			case 4:
				// Both
				// if(bruteForce)
				//     _virtualPadBoth = new FlxVirtualPad(FULL,A_B_X_Y);
				// else
				_virtualPad = new FlxVirtualPad(FULL, A_B_X_Y);
			case 5:
			// Custom
			default:
				trace("unknown what virtual pad to init, bro!");
		}

		if (_virtualPad != null)
		{
			_virtualPad.alpha = 0.75;
			add(_virtualPad);
		}
		else
		{
			trace("no virtual pad thingy available");
		}
		// if(_virtualPadLeft != null){
		//     _virtualPadLeft.alpha = 0.75;
		//     add(_virtualPadLeft);
		// }
		// if(_virtualPadRight != null){
		//     _virtualPadRight.alpha = 0.75;
		//     add(_virtualPadRight);
		// }
		// if(_virtualPadBoth != null){
		//     _virtualPadBoth.alpha = 0.75;
		//     add(_virtualPadBoth);
		// }
	}

	override public function destroy()
	{
		super.destroy();
		trace("destroy touchscreen buttons");
		if (_hitbox != null)
		{
			_hitbox = FlxDestroyUtil.destroy(_hitbox);
		}
		trace("destroyeneding");
		if (_virtualPad != null)
		{
			_virtualPad = FlxDestroyUtil.destroy(_virtualPad);
		}
		trace("ratatatatatatata!");
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
 *  steal from https://github.com/luckydog7/Funkin-android/blob/master/source/ui/Hitbox.hx
 * 
 * @author JOELwindows7
 * 
 */
class TouchScreenControls extends FlxUIGroup
{
	var howManyButtons:Int = 4;

	public var initVisible = false;
	public var daButtoners:FlxTypedGroup<FlxUIButton>;
	public var hitbox:FlxUIGroup;

	var colorSchemes:Array<FlxColor> = [FlxColor.MAGENTA, FlxColor.CYAN, FlxColor.LIME, FlxColor.RED];

	public var buttonLeft:FlxUIButton;
	public var buttonDown:FlxUIButton;
	public var buttonUp:FlxUIButton;
	public var buttonRight:FlxUIButton;

	public function new(howManyButtons:Int = 4, initVisible:Bool = false)
	{
		trace("Start building hitbox");
		daButtoners = new FlxTypedGroup<FlxUIButton>();
		this.howManyButtons = howManyButtons;
		this.initVisible = initVisible;
		super();

		var hitbox_hint:FlxUISprite = cast new FlxUISprite(0, 0).loadGraphic(Paths.image('hitbox/hitbox_hint'));
		hitbox_hint.alpha = 0.2;
		add(hitbox_hint);

		hitbox = new FlxUIGroup();
		hitbox.scrollFactor.set();
		// initDoseButtons();
		bruteForceButtons();
		// visible = initVisible;
		trace("build hitbox complete");
	}

	// inspire it from https://github.com/luckydog7/Funkin-android/blob/master/source/ui/Hitbox.hx
	public function addDeezButton(positionX:Float = 0, positionY:Float = 0, sizeX:Float, sizeY:Float, handoverGraphic:FlxGraphic, index:Int = 0,
			framestring:String = ""):FlxUIButton
	{
		var button = new FlxUIButton(positionX, positionY);
		trace("load frame deez button");
		var frames = Paths.getSparrowAtlas("hitbox/hitbox", "shared");
		// var graphic:FlxGraphic = FlxGraphic.fromRectangle(
		//     Std.int(sizeX != 0? sizeX : FlxG.width/howManyButtons),
		//     Std.int(sizeY != 0? sizeY : FlxG.height),
		//     colorSchemes[index]);
		// var graphic:FlxGraphic = handoverGraphic;
		trace("inject frames to graphic deez button");
		var graphic:FlxGraphic = FlxGraphic.fromFrame(frames.getByName(framestring));

		// button.loadGraphic(handoverGraphic != null? handoverGraphic : graphic);
		button.loadGraphic(graphic);
		button.alpha = 0;

		button.onDown.callback = function()
		{
			FlxTween.num(0, 0.75, .075, {ease: FlxEase.circInOut}, function(a:Float)
			{
				button.alpha = a;
			});
		};

		button.onUp.callback = function()
		{
			FlxTween.num(0.75, 0, .1, {ease: FlxEase.circInOut}, function(a:Float)
			{
				button.alpha = a;
			});
		}

		button.onOut.callback = function()
		{
			FlxTween.num(button.alpha, 0, .2, {ease: FlxEase.circInOut}, function(a:Float)
			{
				button.alpha = a;
			});
		}
		button.alpha = 0;

		return button;
	}

	public function bruteForceButtons()
	{
		trace("brute force the hitbox");
		var graphic:FlxGraphic = FlxGraphic.fromRectangle(Std.int(FlxG.width / howManyButtons), Std.int(FlxG.height), colorSchemes[0]);
		var justImage:FlxUISprite = new FlxUISprite(Std.int(0 * (FlxG.width / howManyButtons)), Std.int(FlxG.height));
		justImage.makeGraphic(Std.int(FlxG.width / howManyButtons), Std.int(FlxG.height), colorSchemes[0]);

		hitbox.add(add(buttonLeft = addDeezButton(0 * (FlxG.width / howManyButtons), 0, (FlxG.width / howManyButtons), (FlxG.height), justImage.graphic, 0,
			"left")));
		hitbox.add(add(buttonDown = addDeezButton(1 * (FlxG.width / howManyButtons), 0, (FlxG.width / howManyButtons), (FlxG.height), justImage.graphic, 1,
			"down")));
		hitbox.add(add(buttonUp = addDeezButton(2 * (FlxG.width / howManyButtons), 0, (FlxG.width / howManyButtons), (FlxG.height), justImage.graphic, 2,
			"up")));
		hitbox.add(add(buttonRight = addDeezButton(3 * (FlxG.width / howManyButtons), 0, (FlxG.width / howManyButtons), (FlxG.height), justImage.graphic, 3,
			"right")));
		trace("less go");
	}

	public function initDoseButtons(spriteMode:Bool = false)
	{
		for (i in 0...howManyButtons)
		{
			/*
				var anButtoneg:FlxUISprite = new FlxUISprite(i * (FlxG.width/howManyButtons));
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

			var tombol:FlxUIButton = addDeezButton(i * (FlxG.width / howManyButtons), 0, (FlxG.width / howManyButtons), (FlxG.height), null, i);
			tombol.ID = i;
			daButtoners.add(tombol);
			hitbox.add(add(daButtoners.members[i]));
		}
		// visible = initVisible;
	}

	function pressDaButton(thingy:FlxUISprite, isOnIt:Bool)
	{
		if (thingy != null)
		{
			if (isOnIt)
			{
				thingy.alpha = .5;
			}
			else
			{
				thingy.alpha = .25;
			}
		}
	}

	override function update(elapsed:Float)
	{
		// JOELwindows7: oh no, For inside For. this is not good performance
		/*
			if(visible)
				forEach(function(thingy:FlxUISprite){
					for(touch in FlxG.touches.list){
						pressDaButton(thingy, touch.overlaps(thingy) && touch.pressed);
					}
				});
		 */
		super.update(elapsed);
	}

	override public function destroy():Void
	{
		super.destroy();

		trace("destroy hitbox");
		if (daButtoners != null)
			daButtoners.clear();
		buttonLeft = FlxDestroyUtil.destroy(buttonLeft);
		buttonDown = FlxDestroyUtil.destroy(buttonDown);
		buttonUp = FlxDestroyUtil.destroy(buttonUp);
		buttonRight = FlxDestroyUtil.destroy(buttonRight);
	}
}
