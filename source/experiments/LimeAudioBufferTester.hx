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
import plugins.sprites.DVDScreenSaver;
import lime.media.openal.AL;
import lime.media.openal.ALSource;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxG;
import lime.media.*;
// import faxe.*;
// import faxe.Faxe;
#if (windows && cpp)
// import vlc.*;
// import vlc.VlcBitmap;
#end

class LimeAudioBufferTester extends MusicBeatState{
    public var theSound:AudioSource;
    public var theBuffer:AudioBuffer;
    // public var theVLC:VlcBitmap;
    public var anHitCorner:DVDScreenSaver;

    public var infoText:FlxUIText;
    override function create(){
        FlxG.mouse.visible = true;
        if(FlxG.sound.music != null){FlxG.sound.music.stop();}
        theBuffer = AudioBuffer.fromFile(Paths.sound("SurroundSoundTest"));
        theSound = new AudioSource(theBuffer);

        //Dangerous, fmod, proprietary
        // Faxe.fmod_init();
        // Faxe.fmod_load_sound(Paths.sound("SurroundSoundTest"));

        //VLC trye
        #if (windows && cpp)
        // initVlc();
        // theVLC.play(Paths.sound("SurroundSoundTest"));
        #end

        //add DVDScreenSaver hit corner
        anHitCorner = new DVDScreenSaver();

        trace("There are " + theBuffer.channels + " channels here");
        trace("Play " + Paths.sound("SurroundSoundTest"));
        infoText = new FlxUIText();
        infoText.text = "Surround Sound Test\n" +
        "\n" +
        "ENTER = Play the sound\n" +
        "ESCAPE = Go back\n" +
        "";
        infoText.size = 32;
        infoText.screenCenter(X);
        infoText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
        add(infoText);
        super.create();
        theSound.play();
        //var alSourceId = @:privateAccess (theSound.buffer);
        //var aLSource = AL.createSource();
        //AL.source3f(aLSource, AL.POSITION, 0,0,0);
        add(anHitCorner);

        addBackButton(100,FlxG.height-128);
        addAcceptButton();
    }

    function initVlc(){
        #if (windows && cpp)
        // theVLC = new VlcBitmap();
        // theVLC.onVideoReady = onVlcVideoReady;
		// theVLC.onPlay = onVLCPlay;
		// theVLC.onPause = onVLCPause;
		// theVLC.onResume = onVLCResume;
		// theVLC.onStop = onVLCStop;
		// theVLC.onSeek = onVLCSeek;
		// theVLC.onComplete = onVLCComplete;
		// theVLC.onProgress = onVLCProgress;
		// theVLC.volume = 1;
		// theVLC.repeat = -1;
        #end
    }

    function addVLC(){
        #if (windows && cpp)
        // theVLC.inWindow = false;
		// theVLC.fullscreen = true;
        // add(cast theVLC);
        #end
    }

    override function update(elapsed){
        super.update(elapsed);

        // Faxe.fmod_update();

        if(FlxG.keys.justPressed.ESCAPE || haveBacked){
            FlxG.switchState(new MainMenuState());
            haveBacked = false;
        }
        if(FlxG.keys.justPressed.ENTER || haveClicked){
            trace("Play " + Paths.sound("SurroundSoundTest"));
            theSound.play();

            //fmod dangerous
            // Faxe.fmod_play_sound(Paths.sound("SurroundSoundTest"));

            haveClicked = false;
        }
        if(FlxG.keys.justPressed.V){
            #if (windows && cpp)
            // theVLC.play(Paths.sound("SurroundSoundTest"));
            #end
        }

        if(FlxG.mouse.overlaps(backButton)){
            if(FlxG.mouse.justPressed){
                haveBacked = true;
            }
        }
        if(FlxG.mouse.overlaps(acceptButton)){
            if(FlxG.mouse.justPressed){
                haveClicked = true;
            }
        }
    }

    // VLC functions
    function onVlcVideoReady() 
    {
    }
    
    function onVLCPlay() 
    {
    }
    
    function onVLCPause() 
    {
    }
    
    function onVLCResume() 
    {
    }
    
    function onVLCStop() 
    {
    }
    
    function onVLCSeek() 
    {
    }
    
    function onVLCComplete() 
    {
    }
    
    function onVLCProgress() 
    {
    }
    //end VLC functions
}