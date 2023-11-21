// package funkin.menus.objects;
package utils.assets;

// JOELwindows7: yoink BOLO
// https://github.com/BoloVEVO/Kade-Engine/blob/stable/source/funkin/menus/objects/MenuCharacter.hx
import flixel.tweens.misc.ColorTween;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.addons.ui.FlxUIText;
import flixel.addons.ui.FlxUISprite;

typedef MenuCharData =
{
	var image:String;
	var scale:Float;
	var position:Array<Int>;
	var idle_anim:String;
	var confirm_anim:String;
	var flipped:Bool;
}

class MenuCharacter extends FlxUISprite
{
	public var character:String;
	public var hasConfirmAnimation:Bool = false;
	var colorTween:ColorTween; // oh yeahhhhhh

	public function new(x:Float, character:String = 'bf')
	{
		super(x);

		changeCharacter(character);
	}

	public function changeCharacter(?character:String = 'bf')
	{
		if (character == null)
			character = '';
		if (character == this.character)
			return;

		this.character = character;
		antialiasing = FlxG.save.data.antialiasing;
		visible = true;

		var dontPlayAnim:Bool = false;
		scale.set(1, 1);
		updateHitbox();

		hasConfirmAnimation = false;
		switch (character)
		{
			case '':
				visible = false;
				dontPlayAnim = true;
			default:
				var jsonPath:String = 'menuCharacters/' + character;

				var charJson:MenuCharData = cast Paths.loadJSON(jsonPath);

				frames = Paths.getSparrowAtlas('menuCharacters/' + charJson.image);
				animation.addByPrefix('idle', charJson.idle_anim, 24);

				var confirmAnim:String = charJson.confirm_anim;
				if (confirmAnim != null && confirmAnim.length > 0 && confirmAnim != charJson.idle_anim)
				{
					animation.addByPrefix('confirm', confirmAnim, 24, false);
					if (animation.getByName('confirm') != null) // check for invalid animation
						hasConfirmAnimation = true;
				}

				flipX = (charJson.flipped == true);

				if (charJson.scale != 1)
				{
					scale.set(charJson.scale, charJson.scale);
					updateHitbox();
				}
				offset.set(charJson.position[0], charJson.position[1]);
				animation.play('idle');
		}
	}

	// JOELwindows7: Hey, buddy, you better Bophead.
	public function bopHead(LastFrame:Bool = false):Void{
		if (animation.name == "confirm")
			return;
		if (LastFrame)
		{
			animation.finish();
		}
	}

	// JOELwindows7: extra twist, change color
	public function changeColor(into:FlxColor,duration:Float = 1){
		// color = into;
		if (colorTween != null)
			colorTween.cancel();
		colorTween.tween(duration,color,into,this);
	}
}
