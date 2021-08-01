package experiments;

// import org.si.midi.MIDIPlayer;
#if sys
import sys.io.File;
#end
import grig.midi.MidiFile;
import openfl.utils.Assets;
import grig.midi.MidiOut;
import grig.midi.MidiMessage;
import haxe.Timer;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import utils.*;
//import extension.android.*;

class AnMIDIyeay extends MusicBeatState{
    //JOELwindows7: MIDI test
    //example https://gitlab.com/haxe-grig/grig.midi/-/blob/main/examples/MidiWriter/src/Main.hx

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

    function midiMidi(handoverMIDIout:MidiOut){
        trace("Midi Midi");
        var counter:Int = 0;
        var beatTimer = new Timer(500);

        beatTimer.run = function() {
            trace("Step " + Std.string(counter) + " (" + (counter % 2 == 0 ? "Even" : "Odd") + ")");
            handoverMIDIout.sendMessage(MidiMessage.ofArray(counter % 2 == 0 ? [144,54,70] : [128,54,64]));
            if (counter == 7) beatTimer.stop();
            counter++;
        }

    }

    function midiFiler(handoverMIDIout:MidiOut){
        var steps:Int = 0;
        #if sys
        var midiFile:MidiFile = MidiFile.fromInput(File.read(Asset2File.getPath(Paths.midiMeta("senpai"))));
        var tracksOfIt = midiFile.tracks;
        #end
    }

    function sionMIDI(){
        // https://github.com/gunnbr/SiON/blob/master/src/org/si/midi/MIDIPlayer.hx
        // MIDIPlayer.play(Paths.midiMeta("senpai"));
    }

    override function update(elapsed){
        super.update(elapsed);

        if(FlxG.keys.justPressed.ESCAPE || haveBacked){
            FlxG.switchState(new MainMenuState());
            haveBacked = false;
        }
        if(FlxG.keys.justPressed.ENTER || haveClicked){
            sionMIDI();
        
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
}