/*
 * GNU General Public License, Version 3.0
 *
 * Copyright (c) 2021 Perkedel
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

package experiments;

import flixel.addons.ui.FlxUIText;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.text.FlxText;
#if FEATURE_VLC
import VideoHandler as MP4Handler; // JOELwindows7: newe

// import vlc.MP4Handler; // wait what?!
#end
// import extension.android.*;
class AnWebmer extends MusicBeatState
{
	public var infoText:FlxUIText;
	public var ownVidSprite:VideoPlayer;
	#if FEATURE_VLC
	public var anVideo:MP4Handler;
	#end

	override function create()
	{
		super.create();

		infoText = new FlxUIText();
		infoText.text = "WEBM tester\n" + "\n" + "ENTER = Play the video\n" + "V = Play the video with VLC" + "\nESCAPE = Go back\n" + "";
		infoText.size = 32;
		infoText.screenCenter(X);
		infoText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(infoText);

		addBackButton(100, FlxG.height - 128);
		addAcceptButton();
	}

	override function update(elapsed)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ESCAPE || haveBacked)
		{
			FlxG.switchState(new MainMenuState());
			haveBacked = false;
		}
		if (FlxG.keys.justPressed.ENTER || haveClicked)
		{
			trace("Play " + Paths.video("OldMacDonaldHadABinCannon"));
			// #if (desktop || web)
			// FlxG.switchState(new VideoState(Paths.video("OldMacDonaldHadABinCannon"), new AnWebmer(), 90));
			// #elseif mobile
			// //MediaPlayer.playFromAssets(Paths.video("OldMacDonaldHadABinCannon"));

			// //WORKS!!!
			// FlxG.sound.music.stop();
			// ownVidSprite = new VideoPlayer("OldMacDonaldHadABinCannon");
			// ownVidSprite.finishCallback = function(){FlxG.switchState(new AnWebmer());};
			// ownVidSprite.play();
			// add(ownVidSprite);
			// #end

			// FINAL
			FlxG.switchState(VideoCutscener.getThe("OldMacDonaldHadABinCannon", new AnWebmer(), 90));

			haveClicked = false;
		}
		if (FlxG.keys.justPressed.V)
		{
			#if (windows && cpp)
			// theVLC.play(Paths.sound("SurroundSoundTest"));
			// attempt BrightFyre's MP4 support powered by all working VLC
			anVideo = new MP4Handler();
			// add(anVideo);
			// anVideo.playVideo(Paths.videoVlc("Compilateur-justAlsa"), false, true);
			anVideo.playVideo(Paths.video("OldMacDonaldHadABinCannon"), false, true);
			// anVideo.stateCallback = new AnWebmer();
			anVideo.finishCallback = function()
			{
				// FlxG.switchState(new AnWebmer());
			};
			#end
		}

		if (FlxG.mouse.overlaps(backButton))
		{
			if (FlxG.mouse.justPressed)
			{
				haveBacked = true;
			}
		}
		if (FlxG.mouse.overlaps(acceptButton))
		{
			if (FlxG.mouse.justPressed)
			{
				haveClicked = true;
			}
		}
	}
}
