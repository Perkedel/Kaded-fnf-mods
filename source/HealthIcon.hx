package;

import flixel.addons.ui.FlxUISprite;
import flixel.FlxG;
import flixel.FlxSprite;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

// JOELwindows7: use `FlxUISprite` instead.
class HealthIcon extends FlxUISprite
{
	public var char:String = 'bf';
	public var isPlayer:Bool = false;
	public var isOldIcon:Bool = false;
	public var forceIcon:Bool = false;

	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite; // JOELwindows7: turns out FlxUISprite fy causes position trouble.

	public function new(?char:String = "bf", ?isPlayer:Bool = false, ?forceIcon:Bool = false)
	{
		super();

		this.char = char;
		this.isPlayer = isPlayer;
		this.forceIcon = forceIcon; // JOELwindows7: icon is forced to be this exact icon, skipping the filtering.

		isPlayer = isOldIcon = false;

		changeIcon(char);
		scrollFactor.set();
	}

	public function swapOldIcon()
	{
		(isOldIcon = !isOldIcon) ? changeIcon("bf-old") : changeIcon(char);
	}

	// JOELwindows7: this inspires me to have swap icon into another icons we have.
	public function resetIcon()
	{
		changeIcon(char);
	}

	public function changeIcon(char:String)
	{
		// JOELwindows7: maybe we should not do this filter anymore? or.. add something?
		if ((char != 'bf-pixel' && char != 'bf-old' && char != 'bf-holding-gf') && !forceIcon)
			char = char.split("-")[0];

		if (!FNFAssets.exists(Paths.image('icons/icon-' + char))) // JOELwindows7: was OpenFlAssets. use BulbyVR Modding+ FNFAssets
			char = 'face';

		loadGraphic(Paths.loadImage('icons/icon-' + char), true, 150, 150);

		if (char.endsWith('-pixel') || char.startsWith('senpai') || char.startsWith('spirit'))
			antialiasing = false
		else
			antialiasing = FlxG.save.data.antialiasing;

		animation.add(char, [0, 1], 0, false, isPlayer);
		animation.play(char);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
