package experiments;

import lime.media.openal.AL;
import lime.media.openal.ALSource;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxG;
import lime.media.*;
// import faxe.*;
// import faxe.Faxe;

class LimeAudioBufferTester extends MusicBeatState{
    public var theSound:AudioSource;
    public var theBuffer:AudioBuffer;

    public var infoText:FlxText;
    override function create(){
        FlxG.mouse.visible = true;
        if(FlxG.sound.music != null){FlxG.sound.music.stop();}
        theBuffer = AudioBuffer.fromFile(Paths.sound("SurroundSoundTest"));
        theSound = new AudioSource(theBuffer);

        //Dangerous, fmod, proprietary
        // Faxe.fmod_init();
        // Faxe.fmod_load_sound(Paths.sound("SurroundSoundTest"));

        trace("There are " + theBuffer.channels + " channels here");
        trace("Play " + Paths.sound("SurroundSoundTest"));
        infoText = new FlxText();
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

        addBackButton(100,FlxG.height-128);
        addAcceptButton();
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