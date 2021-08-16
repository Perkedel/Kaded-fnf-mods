package experiments;

import plugins.sprites.QmovephBackground;
import flixel.addons.plugin.screengrab.FlxScreenGrab;
import flixel.addons.display.FlxStarField;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.text.FlxText;
//import extension.android.*;

class AnDefaultBekgronde extends MusicBeatState{

    public var infoText:FlxText;
    
    override function create(){
        super.create();

        // installDefaultBekgron();
        try{
            // var defaultBackgrounder = new QmovephBackground();
            // add(defaultBackgrounder);
            installSophisticatedDefaultBekgron();
        } catch(e){
            trace(e);
        }

        infoText = new FlxText();
        infoText.text = "Default Bekgron Test\n" +
        "\n" +
        "ENTER = ...\n" +
        "V = Take Screenshot\n" +
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
            
            

            haveClicked = false;
        }
        if(FlxG.keys.justPressed.V){
            #if !js
           FlxScreenGrab.grab(false,false);
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