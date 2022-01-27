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

/*
// import org.si.midi.MIDIPlayer;
import grig.midi.file.event.MidiMessageEvent;
import grig.midi.file.event.*;
import lime.utils.Bytes;
import flixel.util.FlxTimer;
#if sys
import sys.io.File;
#end
import grig.midi.MidiFile;
import grig.midi.*;
import openfl.utils.Assets;
import grig.midi.MidiOut;
import grig.midi.MidiMessage;
import haxe.Timer;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import utils.*;
import grig.midi.file.event.ChannelPrefixEvent;
import grig.midi.file.event.PortPrefixEvent;
import haxe.io.BytesInput;
import haxe.Resource;
import grig.midi.MidiFile;

// import tink.unit.Assert.*;
//import extension.android.*;

class AnMIDIyeay extends MusicBeatState{
    //JOELwindows7: MIDI test
    //example https://gitlab.com/haxe-grig/grig.midi/-/blob/main/examples/MidiWriter/src/Main.hx

    var midiFile:MidiFile;
    var virtualStep:Int = 0;
    var maxStep:Int;
    var isPlaying:Bool = false;

    public var infoText:FlxText;
    override function create(){
        super.create();

        infoText = new FlxText();
        infoText.text = "MIDI tester\n" +
        "\n" +
        "ENTER = Play the MIDI\n" +
        "ESCAPE = Go back\n" +
        "";
        infoText.size = 32;
        infoText.screenCenter(X);
        infoText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
        add(infoText);

        addBackButton(100,FlxG.height-128);
        addAcceptButton();

        FlxG.sound.music.stop();
        winitMIDI();
    }

    function winitMIDI(){
        Main.midiOut.getPorts().handle(function(outcome) {
            switch outcome {
                case Success(ports):
                    trace(ports);
                    Main.midiOut.openPort(0, 'grig.midi').handle(function(midiOutcome) {
                        switch midiOutcome {
                            case Success(_):
                                midiMidi(Main.midiOut);
                            case Failure(error):
                                trace(error);
                        }
                    });
                case Failure(error):
                    trace(error);
            }
        });
    }
    /*
    function midiMidi(handoverMIDIout:MidiOut){
        trace("Midi Midi");
        var counter:Int = 0;
        var beatTimer = new Timer(500);

        beatTimer.run = function() {
            trace("Step " + Std.string(counter) + " (" + (counter % 2 == 0 ? "Even" : "Odd") + ")");
            handoverMIDIout.sendMessage(MidiMessage.ofArray(counter % 2 == 0 ? [144,54,70] : [128,54,64]));
            if (counter == 7) {
                trace("Finish MIDI MIDI");
                beatTimer.stop();
                //midiFiler(handoverMIDIout);
            }
            counter++;
        }

    }

    function midiFiler(handoverMIDIout:MidiOut){
        Conductor.changeBPM(144);
        curStep = 0;
        maxStep = 0;
        trace("Attempt MIDI filer " + Asset2File.getPath(Paths.midiMeta("senpai")));
        // var steps:Int = 0;
        // #if sys
        // var midiFile:MidiFile = MidiFile.fromInput(File.read());
        // var tracksOfIt = midiFile.tracks;
        // #end

        // https://gitlab.com/haxe-grig/grig.midi/-/blob/main/tests/MidiFileTest.hx
        //var bytes = Resource.getBytes(Paths.midiMeta("senpai"));
        var bytes = Bytes.fromFile(Paths.midiMeta("senpai"));
        trace("Bytes retrieved \n"+Std.string(bytes));
        var input = new BytesInput(bytes);
        midiFile = MidiFile.fromInput(input);

        for(tracks in midiFile.tracks){
            trace("Track No. " + Std.string(tracks));
            for(midiEvent in tracks.midiEvents){
                try{
                    // var messageEvent = cast(midiEvent, grig.midi.file.event.MidiMessageEvent);
                    // trace("Filling sounds in " + messageEvent.absoluteTime);
                    // new FlxTimer().start(messageEvent.absoluteTime,function(timer:FlxTimer) {
                    //     handoverMIDIout.sendMessage(messageEvent.midiMessage);
                    // });
                    // var soundsin = new Timer(messageEvent.absoluteTime);
                    // soundsin.run = function() {
                    //     handoverMIDIout.sendMessage(messageEvent.midiMessage);
                    //     soundsin.stop();
                    // }
                    // if(messageEvent.midiMessage.messageType == TempoChang){

                    // }
                    // setMaxStep(midiEvent.absoluteTime);

                    // https://stackoverflow.com/a/47346821/9079640
                    //trace("MIDI event of " + Std.string(midiEvent.absoluteTime));
                    switch(Type.typeof(midiEvent)){
                        case TClass(MidiMessageEvent):
                            //trace("MIDI Message ");
                        case TClass(TempoChangeEvent):
                            trace("Tempo Change " + Std.string(cast(midiEvent, TempoChangeEvent).tempo));
                        case TClass(EndTrackEvent):

                        default:
                            //trace("default MIDI message");
                    }
                } catch(e){
					trace("Werror MIDIfiler " + Std.string(e) + ": " + e.message);
                }
            }
        }
    }

    function setMaxStep(eval:Int){
        if(eval>maxStep) maxStep = eval;
    }

    function stepTheMIDI(handoverEvent:MidiMessageEvent){
        
    }

    // public function testNumTracks()
    // {
    //     return assert(midiFile.tracks.length == 14);
    // }
    

    function sionMIDI(){
        // https://github.com/gunnbr/SiON/blob/master/src/org/si/midi/MIDIPlayer.hx
        // MIDIPlayer.play(Paths.midiMeta("senpai"));
    }

    override function update(elapsed){
        super.update(elapsed);

        if(isPlaying){

            //virtualStep++;
        }

        if(FlxG.keys.justPressed.ESCAPE || haveBacked){
            FlxG.switchState(new MainMenuState());
            haveBacked = false;
        }
        if(FlxG.keys.justPressed.ENTER || haveClicked){
            //sionMIDI();
            //midiFiler(Main.midiOut);
        
            haveClicked = false;
        }
        if(FlxG.keys.justPressed.V){
            #if (windows && cpp)
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

    override function stepHit(){
        super.stepHit();

        if(isPlaying){
            for(tracks in midiFile.tracks){

            }
        }
    }
    
}
*/