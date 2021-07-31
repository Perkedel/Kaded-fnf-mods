package experiments;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.text.FlxText;
//import extension.android.*;

class AnWebmer extends MusicBeatState{

    public var infoText:FlxText;
    public var ownVidSprite:VideoPlayer;
    override function create(){
        super.create();

        infoText = new FlxText();
        infoText.text = "WEBM tester\n" +
        "\n" +
        "ENTER = Play the video\n" +
        "ESCAPE = Go back\n" +
        "";
        infoText.size = 32;
        infoText.screenCenter(X);
        infoText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
        add(infoText);

        addBackButton(100,FlxG.height-128);
        addAcceptButton();
    }

    override function update(elapsed){
        super.update(elapsed);

        if(FlxG.keys.justPressed.ESCAPE || haveBacked){
            FlxG.switchState(new MainMenuState());
            haveBacked = false;
        }
        if(FlxG.keys.justPressed.ENTER || haveClicked){
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

            //FINAL
            FlxG.switchState(VideoCutscener.getThe("OldMacDonaldHadABinCannon", new AnWebmer(), 90));
        
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
}