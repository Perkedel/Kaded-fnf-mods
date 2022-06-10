/*
 * GNU General Public License, Version 3.0
 *
 * Copyright (c) 2022 Perkedel
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package ui;

import flixel.addons.ui.FlxUIButton;
import ui.states.modding.ModMenuState;
import flixel.text.FlxText;
import flixel.addons.ui.FlxUIText;
import flixel.addons.transition.FlxTransitionSprite;
import flixel.addons.transition.TransitionData;
import utils.Initializations;
#if FEATURE_MULTITHREADING
import sys.thread.Mutex;
#end
import GameJolt;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import flixel.effects.FlxFlicker;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.util.FlxColor;
import flixel.FlxState;
import flash.display.Graphics;
import flash.display.Sprite;
// import flash.Lib;
import openfl.Lib;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flixel.FlxG;
import flixel.FlxState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;

/**
 * A splash screen for the application.
 * @author JOELwindows7
 */
class SplashScreen extends MusicBeatState
{
	// Inspire & yoink from that FlxSplash.hx!!!
	public static var nextState:FlxState = new TitleState();

	/**
	 * @since 4.8.0
	 */
	public static var muted:Bool = #if html5 true #else false #end;

	// Master Eric Enigma mod load evaluations
	var configFound = false;
	var modsToLoad = [];

	// static var modAlreadyLoaded = false; // raise this flag if mod already loaded.
	// Haxe logo
	var _sprite:Sprite;
	var _gfx:Graphics;
	var _text:TextField;
	var _poweredByText:TextField;

	// other things
	var _times:Array<Float>;
	var _colors:Array<Int>;
	var _functions:Array<Void->Void>;
	var _curPart:Int = 0;
	var _cachedBgColor:FlxColor;
	var _cachedTimestep:Bool;
	var _cachedAutoPause:Bool;

	var _aModOfText:FlxUIText;
	var _aPressEscapeToBiosText:FlxUIText;
	var _aPressEscapeToBiosButton:FlxUIButton;
	var _productLogo:FlxSprite;
	var _companyLogo:FlxSprite;

	public function new()
	{
		// check mod support
		@:privateAccess {
			#if FEATURE_MODCORE
			CarryAround._supportsModding = true;
			#else
			CarryAround._supportsModding = false;
			#end
		}

		super();
	}

	override public function create():Void
	{
		// Master Eric Enigma check mod configuration
		#if FEATURE_MODCORE
		var modsToLoad = ModCore.getConfiguredMods();
		configFound = (modsToLoad != null && modsToLoad.length > 0);
		#else
		configFound = false;
		#end

		super.create();

		Initializations.begin();

		_cachedBgColor = FlxG.cameras.bgColor;
		FlxG.cameras.bgColor = FlxColor.BLACK;

		installTemporaryDiamondTransition();

		FlxG.mouse.visible = false;

		// HaxeFlixel logo yess
		_times = [0.041, 0.184, 0.334, 0.495, 0.636];
		_colors = [0x00b922, 0xffc132, 0xf5274e, 0x3641ff, 0x04cdfb];
		_functions = [drawGreen, drawYellow, drawRed, drawBlue, drawLightBlue];

		for (time in _times)
		{
			new FlxTimer().start(time, timerCallback);
		}

		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		_sprite = new Sprite();
		FlxG.stage.addChild(_sprite);
		_sprite.scaleX = _sprite.scaleY = .5;
		_sprite.y = stageHeight - 40;
		_gfx = _sprite.graphics;

		_text = new TextField();
		_text.selectable = false;
		_text.embedFonts = true;
		var dtf = new TextFormat(openfl.utils.Assets.getFont("assets/fonts/vcr.ttf").fontName, 24, 0xffffff);
		dtf.align = TextFormatAlign.CENTER;
		_text.defaultTextFormat = dtf;
		_text.text = "HaxeFlixel";
		FlxG.stage.addChild(_text);
		_text.x = stageWidth / 2 - _text.textWidth / 2;
		_text.y = stageHeight - 40;

		_sprite.x = stageWidth / 2 - _text.x - 50;

		_poweredByText = new TextField();
		_poweredByText.selectable = false;
		_poweredByText.embedFonts = true;
		var dtf2 = new TextFormat(openfl.utils.Assets.getFont("assets/fonts/vcr.ttf").fontName, 18, 0xffffff);
		dtf2.align = TextFormatAlign.CENTER;
		_poweredByText.defaultTextFormat = dtf2;
		_poweredByText.text = "Powered by";
		FlxG.stage.addChild(_poweredByText);
		_poweredByText.y = stageHeight - 90;

		onResize(stageWidth, stageHeight);

		_aModOfText = new FlxUIText(Std.int(FlxG.width / 2), Std.int((FlxG.height / 2) + 150), 0, "A mod of Friday Night Funkin", 24);
		_aModOfText.setFormat(Paths.font("UbuntuMono-R.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		_aModOfText.scrollFactor.set();
		_aModOfText.screenCenter(XY);
		_aModOfText.y += 150;
		add(_aModOfText);

		_aPressEscapeToBiosText = new FlxUIText(Std.int(FlxG.width / 2), Std.int((FlxG.height / 2) + 180), 0, Perkedel.BIOS_BUTTON_SAY, 18);
		_aPressEscapeToBiosText.setFormat(Paths.font("UbuntuMono-R.ttf"), 18, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		_aPressEscapeToBiosText.scrollFactor.set();
		_aPressEscapeToBiosText.screenCenter(XY);
		_aPressEscapeToBiosText.y += 180;
		add(_aPressEscapeToBiosText);
		_aPressEscapeToBiosText.visible = !CarryAround.modAlreadyLoaded() && CarryAround.supportsModding(); // only visiblize if not already loaded & supports modding

		_aPressEscapeToBiosButton = new FlxUIButton(Std.int(FlxG.width / 2), Std.int((FlxG.height / 2) + 230), "BIOS Setting", onBiosButtonClick);
		_aPressEscapeToBiosButton.setSize(90, 50);
		_aPressEscapeToBiosButton.setGraphicSize(90, 50);
		_aPressEscapeToBiosButton.updateHitbox();
		_aPressEscapeToBiosButton.setLabelFormat(Paths.font("UbuntuMono-R.ttf"), 18, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		_aPressEscapeToBiosButton.scrollFactor.set();
		_aPressEscapeToBiosButton.screenCenter(XY);
		_aPressEscapeToBiosButton.y += 230;
		add(_aPressEscapeToBiosButton);
		_aPressEscapeToBiosButton.visible = !CarryAround.modAlreadyLoaded() && CarryAround.supportsModding(); // only visiblize if not already loaded & supports modding

		_productLogo = new FlxSprite((FlxG.width / 2), (FlxG.height / 2), Paths.image("LFMLogoSplash"));
		_productLogo.setPosition((FlxG.width / 2) - (_productLogo.width / 2), (FlxG.height / 2) - (_productLogo.height / 2));
		_productLogo.screenCenter(XY);
		_productLogo.scrollFactor.set();
		add(_productLogo);

		_companyLogo = new FlxSprite((FlxG.width / 2), (FlxG.height / 2), Paths.image("Perkedel_Logo_Typeborder"));
		// _companyLogo.scale.x = _companyLogo.scale.y = .5;
		_companyLogo.setGraphicSize(Std.int(_companyLogo.width * .075), Std.int(_companyLogo.height * .075));
		_companyLogo.setPosition((FlxG.width / 2) - (_companyLogo.width / 2), (FlxG.height / 2) - (_companyLogo.height / 2) + 80);
		_companyLogo.scrollFactor.set();
		add(_companyLogo);

		// FlxG.sound.play(Paths.sound('scrollMenu'));
		playSoundEffect('scrollMenu');

		// if (nextState != null)
		// 	FlxG.switchState(nextState);
	}

	override public function update(elapsed:Float)
	{
		// if user press escape, go to BIOS setting
		if (_aPressEscapeToBiosText.visible)
		{
			if (CarryAround.supportsModding())
			{
				_aPressEscapeToBiosText.text = Perkedel.BIOS_BUTTON_SAY
					+ " ("
					+ (_beginSplashTimer != null ? Std.string(HelperFunctions.truncateFloat(_beginSplashTimer.timeLeft, 1)) : "")
					+ ")";
				if (FlxG.keys.justPressed.ESCAPE || (joypadLastActive != null ? joypadLastActive.justPressed.BACK : false))
				{
					onBiosButtonClick();
				}
			}
		}

		super.update(elapsed);
	}

	override public function destroy():Void
	{
		_sprite = null;
		_gfx = null;
		_text = null;
		_times = null;
		_colors = null;
		_functions = null;
		super.destroy();
	}

	var _beginSplashTimer:FlxTimer;

	function beginSplashShow()
	{
		_beginSplashTimer = new FlxTimer();
		_beginSplashTimer.start(2, function(tmr:FlxTimer)
		{
			intoStateNow();
		});
	}

	var _intoStateFlicker:FlxFlicker;
	var _intoStateTimer:FlxTimer;

	function intoStateNow()
	{
		_aPressEscapeToBiosText.visible = false; // immediately invisible bios text
		_aPressEscapeToBiosButton.visible = false; // immediately invisible bios button

		// check mods!
		if (!CarryAround.modAlreadyLoaded())
		{
			// #if FEATURE_MODCORE
			if (configFound)
			{
				Debug.logTrace("Load configured mods");
				ModCore.loadConfiguredMods();
			}
			else
			{
				Debug.logTrace("Load all mods");
				ModCore.initialize();
			}
			// #else
			// Debug.logTrace("Mod support unavailable");
			// #end
		}
		else
		{
		}

		// FlxG.sound.play(Paths.sound('confirmMenu'));
		playSoundEffect('confirmMenu');
		if (FlxG.save.data.flashing)
		{
			_intoStateFlicker = FlxFlicker.flicker(_productLogo, 2, 0.06, false, false, function(flicker:FlxFlicker)
			{
				finishedFlicker();
				// flicker.stop();
			});
		}
		else
		{
			_intoStateTimer = new FlxTimer();
			_intoStateTimer.start(2, function(tmr:FlxTimer)
			{
				finishedFlicker();
			});
		}
	}

	function finishedFlicker()
	{
		// then cleanup & move to the next state!
		justComplete();
		if (nextState != null)
			// FlxG.switchState(nextState);
			switchState(nextState);
	}

	override public function onResize(Width:Int, Height:Int):Void
	{
		super.onResize(Width, Height);

		_sprite.x = (Width / 2) - (_sprite.width / 2) - 50;
		// _sprite.y = (Height / 2) - 20 * FlxG.game.scaleY;
		_sprite.y = (Height) - 50 * FlxG.game.scaleY;

		_text.width = Width / FlxG.game.scaleX;
		// _text.x = 0;
		_text.x = 50;
		// _text.y = _sprite.y + 80 * FlxG.game.scaleY;
		_text.y = (_sprite.y) * FlxG.game.scaleY;

		// _sprite.scaleX = _text.scaleX = FlxG.game.scaleX;
		// _sprite.scaleY = _text.scaleY = FlxG.game.scaleY;

		_poweredByText.width = Width / FlxG.game.scaleX;
	}

	function timerCallback(Timer:FlxTimer):Void
	{
		_functions[_curPart]();
		_text.textColor = _colors[_curPart];
		_text.text = "HaxeFlixel";
		_curPart++;

		if (_curPart == 5)
		{
			// Make the logo a tad bit longer, so our users fully appreciate our hard work :D
			// FlxTween.tween(_sprite, {alpha: 0}, 3.0, {ease: FlxEase.quadOut, onComplete: onComplete});
			// FlxTween.tween(_text, {alpha: 0}, 3.0, {ease: FlxEase.quadOut});
			// new FlxTimer().start(1, function(tmr:FlxTimer)
			// {
			// 	beginSplashShow();
			// });
			beginSplashShow();
		}
	}

	function drawGreen():Void
	{
		_gfx.beginFill(0x00b922);
		_gfx.moveTo(0, -37);
		_gfx.lineTo(1, -37);
		_gfx.lineTo(37, 0);
		_gfx.lineTo(37, 1);
		_gfx.lineTo(1, 37);
		_gfx.lineTo(0, 37);
		_gfx.lineTo(-37, 1);
		_gfx.lineTo(-37, 0);
		_gfx.lineTo(0, -37);
		_gfx.endFill();
	}

	function drawYellow():Void
	{
		_gfx.beginFill(0xffc132);
		_gfx.moveTo(-50, -50);
		_gfx.lineTo(-25, -50);
		_gfx.lineTo(0, -37);
		_gfx.lineTo(-37, 0);
		_gfx.lineTo(-50, -25);
		_gfx.lineTo(-50, -50);
		_gfx.endFill();
	}

	function drawRed():Void
	{
		_gfx.beginFill(0xf5274e);
		_gfx.moveTo(50, -50);
		_gfx.lineTo(25, -50);
		_gfx.lineTo(1, -37);
		_gfx.lineTo(37, 0);
		_gfx.lineTo(50, -25);
		_gfx.lineTo(50, -50);
		_gfx.endFill();
	}

	function drawBlue():Void
	{
		_gfx.beginFill(0x3641ff);
		_gfx.moveTo(-50, 50);
		_gfx.lineTo(-25, 50);
		_gfx.lineTo(0, 37);
		_gfx.lineTo(-37, 1);
		_gfx.lineTo(-50, 25);
		_gfx.lineTo(-50, 50);
		_gfx.endFill();
	}

	function drawLightBlue():Void
	{
		_gfx.beginFill(0x04cdfb);
		_gfx.moveTo(50, 50);
		_gfx.lineTo(25, 50);
		_gfx.lineTo(1, 37);
		_gfx.lineTo(37, 1);
		_gfx.lineTo(50, 25);
		_gfx.lineTo(50, 50);
		_gfx.endFill();
	}

	function onComplete(Tween:FlxTween):Void
	{
		FlxG.cameras.bgColor = _cachedBgColor;
		// FlxG.fixedTimestep = _cachedTimestep;
		// FlxG.autoPause = _cachedAutoPause;
		#if FLX_KEYBOARD
		FlxG.keys.enabled = true;
		#end
		FlxG.stage.removeChild(_sprite);
		FlxG.stage.removeChild(_text);
		FlxG.stage.removeChild(_poweredByText);
		// FlxG.switchState(Type.createInstance(nextState, []));
		// FlxG.game._gameJustStarted = true;
	}

	function justComplete():Void
	{
		FlxG.cameras.bgColor = _cachedBgColor;
		// FlxG.fixedTimestep = _cachedTimestep;
		// FlxG.autoPause = _cachedAutoPause;
		#if FLX_KEYBOARD
		FlxG.keys.enabled = true;
		#end
		FlxG.stage.removeChild(_sprite);
		FlxG.stage.removeChild(_text);
		FlxG.stage.removeChild(_poweredByText);
		// FlxG.switchState(Type.createInstance(nextState, []));
		// FlxG.game._gameJustStarted = true;
	}

	function installTemporaryDiamondTransition():Void
	{
		// JOELwindows7: temporary diamond from TitleScreen
		var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
		diamond.persist = true;
		diamond.destroyOnNoUse = false;

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1), {asset: diamond, width: 32, height: 32},
			new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
	}

	public static function markModLoaded():Void
	{
		// modAlreadyLoaded = true;
		CarryAround.raiseModAlreadyLoaded();
	}

	function cancelEverything():Void
	{
		if (_beginSplashTimer != null)
		{
			_beginSplashTimer.cancel();
			// _beginSplashTimer = null;
		}
		if (_intoStateFlicker != null)
		{
			_intoStateFlicker.stop();
			// _intoStateFlicker = null;
		}
		if (_intoStateTimer != null)
		{
			_intoStateTimer.cancel();
			// _intoStateTimer = null;
		}
		FlxG.stage.removeChild(_sprite);
		FlxG.stage.removeChild(_text);
		FlxG.stage.removeChild(_poweredByText);
	}

	function onBiosButtonClick()
	{
		if (_aPressEscapeToBiosText.visible)
		{
			// FlxG.sound.play(Paths.sound('cancelMenu'));
			playSoundEffect('cancelMenu');
			// FlxG.switchState(new BiosSettingsState());
			cancelEverything();
			_aPressEscapeToBiosText.visible = false;
			_aPressEscapeToBiosButton.visible = false;
			#if FEATURE_MODCORE
			switchState(new ModMenuState()); // temporary. pls make proper BIOS setting menu!
			#end
		}
	}
}
