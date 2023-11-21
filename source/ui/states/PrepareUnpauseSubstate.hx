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

package ui.states;

// JOELwindows7: somehow the import detector IntelliSense broken today lmao!
import flixel.addons.ui.FlxUIText;
import flixel.addons.ui.FlxUISprite;
import flixel.util.FlxTimer;
import flixel.util.FlxSpriteUtil;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.text.FlxText;
import flixel.util.FlxColor;

// JOELwindows7: FlxUI fy!!!!!!!

/**
 * This Substate appears upon unpausing to let you prepare with countdown like song start.
 * damn it! where's the issue from Stepmania here? I am the one that requested that feature!
 * I saw it! I want that there. it updates now on development, and I first time see it!
 * And I feel like that I also want to have pause menu too! press `BACK` once instead of holding it!
 * https://github.com/stepmania/stepmania/issues?q=pause+user%3AJOELwindows7+is%3Aclosed
 * @author JOELwindows7
 */
class PrepareUnpauseSubstate extends MusicBeatSubstate
{
	var startedCountdown:Bool = false;
	var startTimer:FlxTimer;
	var getReadyText:FlxUIText;

	/**
	 * Construct unpause preparation countdown substate.
	 */
	public function new()
	{
		super();
		Debug.logInfo("Prepare for Unpause!");

		getReadyText = new FlxUIText((FlxG.width / 2) - 100, (FlxG.height / 2) + 50, 0, "Get Ready!", 32);
		getReadyText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK); // was vcr.ttf
		getReadyText.scrollFactor.set();
		getReadyText.screenCenter(XY);
		add(getReadyText);
		Game.fadePauseMusic();

		if (PlayState.instance != null)
			PlayState.instance.waitLemmePrepareUnpauseFirst = false;
		else
		{
			close(); // wtf PlayState null?!?!? what are you doing here?
			return;
		}

		startCountdown();
	}

	/**
	 * Copy countdown from PlayState and after GO, it closes.
	 */
	function startCountdown()
	{
		// JOELwindows7: hmm, perhaps we should not mess with this countdown. make it obvious and clear instead.
		// var silent:Bool = PlayState.SONG.silentCountdown;
		// var invisible:Bool = PlayState.SONG.invisibleCountdown;
		// var reversed:Bool = PlayState.SONG.reversedCountdown;
		var silent:Bool = false;
		var invisible:Bool = false;
		var reversed:Bool = false;

		startedCountdown = true;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			var altSuffix:String = "";
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('pixel', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var week6Bullshit:String = null;

			// JOELwindows7: detect MIDI suffix
			var detectMidiSuffix:String = '-midi';
			var midiSuffix:String = "midi";

			if (PlayState.SONG.noteStyle == 'pixel')
			{
				introAlts = introAssets.get('pixel');
				altSuffix = '-pixel';
				week6Bullshit = 'week6';
			}

			// JOELwindows7: scan MIDI suffix in the song name
			if (PlayState.SONG.songId.contains(detectMidiSuffix.trim()))
			{
				midiSuffix = detectMidiSuffix;
			}
			else
				midiSuffix = "";

			switch (swagCounter)

			{
				case 0:
					// JOELwindows7:Lol! I added reverse
					if (!silent)
						FlxG.sound.play(Paths.sound('intro3' + altSuffix + midiSuffix), 0.6);
				case 1:
					var ready:FlxUISprite = cast new FlxUISprite().loadGraphic(Paths.loadImage(introAlts[0], week6Bullshit));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (PlayState.SONG.noteStyle == 'pixel')
						ready.setGraphicSize(Std.int(ready.width * CoolUtil.daPixelZoom));

					ready.screenCenter();
					add(ready);
					if (invisible)
						ready.visible = false; // JOELwindows7: infisipel
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					if (!silent) // JOELwindows7: Silencio Bruno!
						FlxG.sound.play(Paths.sound('intro2' + altSuffix + midiSuffix), 0.6);

					// JOELwindows7: set color for get ready text
					getReadyText.color = FlxColor.RED;
				case 2:
					var set:FlxUISprite = cast new FlxUISprite().loadGraphic(Paths.loadImage(introAlts[1], week6Bullshit));
					set.scrollFactor.set();

					if (PlayState.SONG.noteStyle == 'pixel')
						set.setGraphicSize(Std.int(set.width * CoolUtil.daPixelZoom));

					set.screenCenter();
					add(set);
					if (invisible)
						set.visible = false; // JOELwindows7: inbizibel
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					if (!silent) // JOELwindows7: ssshhh
						FlxG.sound.play(Paths.sound('intro1' + altSuffix + midiSuffix), 0.6);

					// JOELwindows7: set color for get ready text
					getReadyText.color = FlxColor.YELLOW;
				case 3:
					var go:FlxUISprite = cast new FlxUISprite().loadGraphic(Paths.loadImage(introAlts[2], week6Bullshit));
					go.scrollFactor.set();

					if (PlayState.SONG.noteStyle == 'pixel')
						go.setGraphicSize(Std.int(go.width * CoolUtil.daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					if (invisible)
						go.visible = false; // JOELwindows7: disepir
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					if (!silent) // JOELwindows7: quiet!
						FlxG.sound.play(Paths.sound('introGo' + altSuffix + midiSuffix), 0.6);

					trace("GO! Unpause the song now!");

					// JOELwindows7: start Credit rolling if the song has so
					// if (PlayState.SONG.isCreditRoll && PlayState.creditRollout != null)
					// {
					// 	PlayState.creditRollout.startRolling();
					// }

					if (PlayState.instance != null)
						PlayState.instance.waitLemmePrepareUnpauseFirst = false;

					// JOELwindows7: set color for get ready text
					getReadyText.color = FlxColor.LIME;

					FlxTween.tween(getReadyText, {alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							getReadyText.destroy();
						}
					});
				case 4:
					// JOELwindows7: close this substate
					close();
			}

			swagCounter += 1;
		}, 5);

		// JOELwindows7: num of countdown loop decreased from 5 to 4. ok, Kade.
		// okay in this countdown, there are 5. the 4th is to close this substate after Go.
		// let me tell you, if you close on 3rd, the "GO!" say will immediately poof interupted as this substate closes.
	}
}
