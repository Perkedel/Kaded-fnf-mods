package;

import flixel.addons.ui.FlxUIText;
import flixel.addons.ui.FlxUISprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

// JOELwindows7: oops, Wait. no, this is not used one. still, FlxUI this??
class OptionsSubState extends MusicBeatSubstate
{
	var textMenuItems:Array<String> = ['Master Volume', 'Sound Volume', 'Controls'];

	var selector:FlxUISprite;
	var curSelected:Int = 0;

	var grpOptionsTexts:FlxTypedGroup<FlxUIText>;

	public function new()
	{
		super();

		grpOptionsTexts = new FlxTypedGroup<FlxUIText>();
		add(grpOptionsTexts);

		selector = cast new FlxUISprite().makeGraphic(5, 5, FlxColor.RED);
		add(selector);

		for (i in 0...textMenuItems.length)
		{
			var optionText:FlxUIText = new FlxUIText(20, 20 + (i * 50), 0, textMenuItems[i], 32);
			optionText.ID = i;
			grpOptionsTexts.add(optionText);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.UP_P)
			curSelected -= 1;

		if (controls.DOWN_P)
			curSelected += 1;

		if (curSelected < 0)
			curSelected = textMenuItems.length - 1;

		if (curSelected >= textMenuItems.length)
			curSelected = 0;

		grpOptionsTexts.forEach(function(txt:FlxUIText)
		{
			txt.color = FlxColor.WHITE;

			if (txt.ID == curSelected)
				txt.color = FlxColor.YELLOW;
		});

		if (controls.ACCEPT)
		{
			switch (textMenuItems[curSelected])
			{
				case "Controls":
					FlxG.state.closeSubState();
					FlxG.state.openSubState(new ControlsSubState());
			}
		}
	}
}
