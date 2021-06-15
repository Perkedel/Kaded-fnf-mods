package;

import Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

using StringTools;
//JOELwindows7: Doki Doki heartbeating characters
//inspire from the Song.hx
typedef SwagHeart = {
    var character:String;
    var initHR:Int;
    var minHR:Int;
    var maxHR:Int;
    var heartTierBoundaries:Array<Int>;
    var successionAdrenalAdd:Array<Int>;
    var fearShockAdd:Array<Int>;
    var relaxMinusPerBeat:Array<Int>;
}
typedef HeartList = {
    var heartSpecs:Array<SwagHeart>;
    var heartOrder:Array<String>;
}

class DokiDoki {
    var heartSpecs:Array<SwagHeart>;

    var character:String;
    var initHR:Int = 70;
    var minHR:Int = 70;
    var maxHR:Int = 220;
    var heartTierBoundaries:Array<Int> = [90, 120, 150, 200];
    var successionAdrenalAdd:Array<Int> = [20,15, 10, 5];
    var fearShockAdd:Array<Int> = [22,20,10,5];
    var relaxMinusPerBeat:Array<Int> = [1,5,10,15];

    public function new(character:String = "bf"){
        this.character = character;
        var heartList:HeartList = loadFromJson("heartBeatSpec");
        this.heartSpecs = heartList.heartSpecs;
        var chooseIndex:Int = 0;
        switch(character){
            case 'bf': chooseIndex = 0;
            case 'gf': chooseIndex = 1;
            default: chooseIndex = 0;
        }

        var theHeart:SwagHeart = cast this.heartSpecs[chooseIndex];
        this.minHR = theHeart.minHR;
        this.maxHR = theHeart.maxHR;
        this.heartTierBoundaries = theHeart.heartTierBoundaries;
        this.successionAdrenalAdd = theHeart.successionAdrenalAdd;
        this.fearShockAdd = theHeart.fearShockAdd;
    }
    public static function loadFromJson(jsonInput:String):HeartList{
        trace(jsonInput);

        trace('loading heart spec ' + jsonInput);

		var rawJson = Assets.getText(Paths.json(jsonInput)).trim();

        while (!rawJson.endsWith("}"))
        {
            rawJson = rawJson.substr(0, rawJson.length - 1);
            // LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
        }

		return parseJSONshit(rawJson);
    }
    public static function parseJSONshit(rawJson:String):HeartList{
		var swagShit:HeartList = cast Json.parse(rawJson);
        return swagShit;
    }

}