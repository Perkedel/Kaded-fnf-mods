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

typedef SwagAchievement = {
    var nameID:String;
    var displayName:String;
    var howToUnlock:String;
    var isSecret:Bool;
    var unlockedTime:Date;
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

    }
}