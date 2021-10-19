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

import flixel.FlxG;
import flixel.util.FlxSave;
#if gamejolt
import GameJolt;
#end
import Options;

 //JOELwindows7: This is Achievement system.

/**
 * View Gallery Achievements.
 */
class GalleryAchievementsMenu extends MusicBeatState{
    override function create(){
        super.create();
    }    
}

typedef AchievementAPIs = {
    var gameJolt:Int;
}

typedef SwagAchievement = {
    var nameID:String;
    var displayName:String;
    var howToUnlock:String;
    var isSecret:Bool;
    // var unlockedTime:Date;
    var externalAchievmentIDs:AchievementAPIs;
}

class HardCodeAchievements{
    public static var listings:Map<String,SwagAchievement> = [
        "anFunkin" => {
            nameID : "anFunkin",
            displayName: "Getting Freaky",
            howToUnlock : "Started Funkin",
            isSecret: false,
            externalAchievmentIDs : {
                gameJolt : 148268
            }
        },
        "story_mode" => {
            nameID : "story_mode",
            displayName: "The Funkin Story",
            howToUnlock : "open Story Mode menu",
            isSecret: false,
            externalAchievmentIDs : {
                gameJolt : 148275
            }
        },
        "freeplay_mode" => {
            nameID : "freeplay_mode",
            displayName: "lemme be wild",
            howToUnlock : "open Freeplay menu",
            isSecret: false,
            externalAchievmentIDs : {
                gameJolt : 148274
            }
        },
        "acknowledgement" => {
            nameID : "acknowledgement",
            displayName: "acknowledge the devs",
            howToUnlock : "open Donate / Credit menu",
            isSecret: false,
            externalAchievmentIDs : {
                gameJolt : 148276
            }
        },
        "key_map" => {
            nameID : "key_map",
            displayName: "I must adjust the keys first",
            howToUnlock : "open Key mapping configurator",
            isSecret: false,
            externalAchievmentIDs : {
                gameJolt : 148278
            }
        },
        "no_week_7" => {
            nameID : "no_week_7",
            displayName: "No Week 7 huh?",
            howToUnlock : "Completed week 6",
            isSecret: false,
            externalAchievmentIDs : {
                gameJolt : 148271
            }
        },
        "just_like_the_game" => {
            nameID : "just_like_the_game",
            displayName: "Just like the game",
            howToUnlock : "Started Funkin in Friday (actual real time)",
            isSecret: false,
            externalAchievmentIDs : {
                gameJolt : 148270
            }
        },
        "anSpook" => {
            nameID : "anSpook",
            displayName: "Daddy defeaten anSpook ready",
            howToUnlock : "Beat Week 1",
            isSecret: false,
            externalAchievmentIDs : {
                gameJolt : 148269
            }
        },
        "tankman_in_embargo" =>{
            nameID : "tankman_in_embargo",
            displayName: "No Week 7 Huh?",
            howToUnlock : "Completed Week 6",
            isSecret: false,
            externalAchievmentIDs : {
                gameJolt : 148271
            }
        },
        "no_more_accident_volkeys" =>{
            nameID : "no_more_accident_volkeys",
            displayName: "No more accident Volume keys",
            howToUnlock : "Adjust Volume",
            isSecret: false,
            externalAchievmentIDs : {
                gameJolt : 148277
            }
        },
        "anBeethoven" =>{
            nameID : "anBeethoven",
            displayName: "Beethoven",
            howToUnlock : "make volume 0 or mute",
            isSecret: false,
            externalAchievmentIDs : {
                gameJolt : 148272
            }
        },
        "anOption" =>{
            nameID : "anOption",
            displayName: "Option Menu guys",
            howToUnlock : "open Option menu",
            isSecret: false,
            externalAchievmentIDs : {
                gameJolt : 148273
            }
        }
    ];
}

class TheAchievementOption extends Option{
    public var nameID:String = "the_achievement";
    public var displayName:String = "The Achievement";
    public var howToUnlock:String = "Do this and that";
    public var isSecret:Bool = false;
    public var unlockedTime:Date = Date.now();

    public function new(){
        super();
		description = howToUnlock;
    }

    public override function press():Bool{ 

        return false;
    }

    private override function updateDisplay():String{ 
        return isSecret && unlockedTime != null? "???????" : displayName;
    }
}

class ViewTheAchievement extends MusicBeatSubstate{
    function new(handover:TheAchievementOption){
        super();
    }

    public static function yesOpenIt(handover:TheAchievementOption){
        return new ViewTheAchievement(handover);
    }
}

class AchievementUnlocked{
    public static function whichIs(nameID:String){
        #if gamejolt
        GameJoltAPI.getTrophy(HardCodeAchievements.listings[nameID].externalAchievmentIDs.gameJolt);
        #end
        // FlxG.save.data.achievementUnlocked[nameID] = true;
        trace("Achievement Unlocked: " + nameID);
    }
}