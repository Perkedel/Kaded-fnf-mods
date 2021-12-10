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

import flixel.addons.plugin.screengrab.FlxScreenGrab;
import flixel.addons.display.FlxStarField;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.text.FlxText;
//import extension.android.*;

class AnStarfielde extends MusicBeatState{

    public var infoText:FlxText;
    var stars:FlxStarField3D;
    var stors:FlxStarField2D;
    var is2D:Bool = false;
    override function create(){
        super.create();

        stars = new FlxStarField3D(0,0,FlxG.width,FlxG.height,300);
        stors = new FlxStarField2D(0,0,FlxG.width,FlxG.height,300);
        add(stars);
        add(stors);
        stors.visible = false;

        infoText = new FlxText();
        infoText.text = "Starfielder Test\n" +
        "\n" +
        "ENTER = Change mode\n" +
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
            
            switchStars();

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

    function switchStars(){
        is2D = !is2D;
        if(is2D){
            stars.visible = false;
            stors.visible = true;
        } else {
            stars.visible = true;
            stors.visible = false;
        }
    }
}