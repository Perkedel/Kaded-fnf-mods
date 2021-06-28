// this file is for Stage chart things, this is to declutter ModchartState.hx

// Lua
//JOELwindows7: okay, please widen the area of support for macOS and Linux too.
//dang failed. I guess we go back to only Windows..
import openfl.display3D.textures.VideoTexture;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
#if ((windows || linux) && cpp) //LuaJit only works for C++ 
//https://lib.haxe.org/p/linc_luajit/
import flixel.tweens.FlxEase;
import openfl.filters.ShaderFilter;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import lime.app.Application;
import flixel.FlxSprite;
import llua.Convert;
import llua.Lua;
import llua.State;
import llua.LuaL;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
#end
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

using StringTools;

//JOELwindows7: inspire from Song.hx
enum BackgroundMode {GRAPHIC, MAKE};

typedef SwagBackground = {
    var callName:String;
    var generateMode:Bool;
    var graphic:String;
    var isXML;
    var prefixXMLName;
    var position:Array<Float>;
    var scrollFactor:Array<float>;
    var colorable:Bool;
    var size:Array<Int>;
    var initColor:String;
    var initInvisible;
    var antialiasing;
}

typedef SwagStage = {
    var name:String;

    /*
    var bg:String;
    var stageFront:String;
    var stageCurtain:String;
    var colorableBg:String;

    var bgScrollFactor:Array<Float>;
    var stageFrontScrollFactor:Array<Float>;
    var stageCurtainScrollFactor:Array<Float>;
    var colorableBgScrollFactor:Array<Float>;

    var useImagesMethodic:Bool;
    */
    var useStageScript:Bool;

    var backgroundImages:Array<SwagBackground>;

    var isHalloween:Bool;
    //var halloweenLevel:Bool;
}

class StageChart
{
    public var useStageScript:Bool = false;
    public var name:String = "anStage";
    public var backgroundImages:Array<SwagBackground>;
    public var isHalloween:Bool = false;

    public new(name:String = "anStage", backgroundImages:Array<SwagBackground>  = [
        {
            callName: 'anBackground',
            graphic:'null' ,
            isXML:false,
            prefixXMLName:'idle';
            generateMode:true,
            position: [0,0],
            scrollFactor: [0,0],
            colorable: false,
            size: [128, 128],
            initColor: 'white',
            initInvisible:false,
            useCustomScript:false,
            antialiasing = true;
        }
    ], isHalloween:Bool = false){
        this.name = name;
        this.backgroundImages = backgroundImages;
        this.isHalloween = isHalloween;
    }

    public static function loadFromJson(jsonInput:String):SwagStage
    {
        trace(jsonInput);
        
        trace('loading stageChart ' + jsonInput.toLowerCase());

        var rawJson = Assets.getText(Paths.json(jsonInput.toLowerCase())).trim();

        while (!rawJson.endsWith("}"))
        {
            rawJson = rawJson.substr(0, rawJson.length - 1);
            // LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
        }

        // FIX THE CASTING ON WINDOWS/NATIVE
        // Windows???
        // trace(songData);

        // trace('LOADED FROM JSON: ' + songData.notes);
        /* 
            for (i in 0...songData.notes.length)
            {
                trace('LOADED FROM JSON: ' + songData.notes[i].sectionNotes);
                // songData.notes[i].sectionNotes = songData.notes[i].sectionNotes
            }

                daNotes = songData.notes;
                daSong = songData.song;
                daBpm = songData.bpm; */

        return parseJSONshit(rawJson);
    }

    public static function parseJSONshit(rawJson:String):SwagStage
    {
        var swagShit:SwagStage = cast Json.parse(rawJson).song;
        return swagShit;
    }
}

//JOELwindows7: use modChart state class for the stage script!