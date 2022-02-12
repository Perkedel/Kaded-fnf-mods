package;

import flixel.util.FlxAxes;
import utils.Asset2File;
import flixel.util.FlxDestroyUtil;
import flixel.*;
import flixel.FlxGame;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.input.gamepad.FlxGamepadManager;
import flixel.input.FlxSwipe;
import flixel.input.FlxAccelerometer;
import flixel.input.touch.FlxTouch;
#if FLX_TOUCH
import flixel.input.touch.FlxTouchManager;
#end
import flixel.input.keyboard.FlxKeyboard;
import flixel.system.frontEnds.InputFrontEnd;
import flixel.system.*;
import flixel.system.frontEnds.*;
import flixel.system.frontEnds.CameraFrontEnd;
import flixel.system.frontEnds.BitmapFrontEnd;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.system.FlxSound;
import flixel.sound.*;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.system.FlxAssets.*;
import hscript.*;
import hx.files.*;
import Controls;
import openfl.display3D.textures.VideoTexture;
import flixel.*;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxSoundGroup;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.FlxSound.*;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import openfl.filters.ShaderFilter;
import openfl.filters.BitmapFilter;
import openfl.display.DisplayObject;
import openfl.display.Stage;
import openfl.display.Sprite;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.media.Sound;
import openfl.geom.Matrix;
import openfl.Lib;
import flixel.util.FlxColor;
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import lime.app.Application;
import flixel.FlxSprite;
import lime.utils.Assets;
import hscript.*;
import plugins.tools.MetroSprite;

using StringTools;

/**
 * BulbyVR's display layer enums
 * 
 * @author JOELwindows7
* **/
enum abstract DisplayLayer(Int) from Int to Int
{
	var BEHIND_GF = 1;
	var BEHIND_BF = 1 << 1;
	var BEHIND_DAD = 1 << 2;
	var BEHIND_ALL = BEHIND_GF | BEHIND_BF | BEHIND_DAD;
}

/**
 * Modchart state but it's Haxe script. Also no need recompile. you can modchart with Haxe language.
 * alternative against Kade Engine's LuaJIT modchart. provided due to LuaJIT incompatibility for some platform.
 * inspired from BulbyVR's Modding+ https://github.com/TheDrawingCoder-Gamer/Funkin
 * using https://lib.haxe.org/p/hscript/ & https://github.com/ianharrigan/hscript-ex
 * @author JOELwindows7
 * @see https://github.com/TheDrawingCoder-Gamer/Funkin/blob/master/source/PlayState.hx
 */
class HaxeScriptState
{
	public var script:String = ""; // Content of the hscript file

	var parser:ParserEx = new ParserEx();
	var prog = null;
	var interp:InterpEx;
	var retailIsReady:Bool = false;
	var hscriptState:Map<String, InterpEx>;
	var defaultUseHaxe:String = "modchart";

	// var instancering;
	// Some other variables
	public static var hscriptSprite:Map<String, FlxSprite> = [];

	public var haxeWiggles:Map<String, WiggleEffect> = new Map<String, WiggleEffect>();

	// JOELwindows7: kem0x mod shader
	#if EXPERIMENTAL_KEM0X_SHADERS
	public var luaShaders:Map<String, DynamicShaderHandler> = new Map<String, DynamicShaderHandler>();
	#end
	public var camTarget:FlxCamera;

	/**
	 * Instance HaxeScriptState.
	 * @param rawMode 
	 * @param path 
	 * @param className 
	 */
	function new(rawMode:Bool = false, path:String = "", useHaxe:String = "modchart", className:String = "HaxeMod", useRetail:Bool = false)
	{
		trace("open hscript state because we are cool");
		initHaxeScriptState(rawMode, path, useHaxe, className, useRetail);
	}

	function callHscript(func_name:String, args:Array<Dynamic>, useHaxe:String = "modchart")
	{
		if (retailIsReady)
		{
			// if function doesn't exist
			if (!hscriptState.get(useHaxe).variables.exists(func_name))
			{
				trace(func_name + " Function in Retail doesn't exist, silently skipping...");
				return;
			}
		}
		else
		{
			// if function doesn't exist
			if (!interp.variables.exists(func_name))
			{
				trace(func_name + " Function in Interp doesn't exist, silently skipping...");
				return;
			}
		}
		var method;
		if (retailIsReady)
			method = hscriptState.get(useHaxe).variables.get(func_name);
		else
			method = interp.variables.get(func_name);
		switch (args.length)
		{
			case 0:
				method();
			case 1:
				method(args[0]);
			case 2:
				method(args[0], args[1]);
			case 3:
				method(args[0], args[1], args[2]);
			case 4:
				method(args[0], args[1], args[2], args[3]);
			case 5:
				method(args[0], args[1], args[2], args[3], args[4]);
			case 6:
				method(args[0], args[1], args[2], args[3], args[4], args[5]);
			case 7:
				method(args[0], args[1], args[2], args[3], args[4], args[5], args[6]);
			case 8:
				method(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7]);
			case 9:
				method(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8]);
			case 10:
				method(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9]);
			case 11:
				method(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10]);
			case 12:
				method(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11]);
			case 13:
				method(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12]);
			case 14:
				method(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13]);
			case 15:
				method(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13],
					args[14]);
				// JOELwindows7: Okay that's enough & inefficient. wtf?!?! there's no way to procedurally do this?!?!?
		}
	}

	function callAllHScript(func_name:String, args:Array<Dynamic>)
	{
		for (key in hscriptState.keys())
		{
			callHscript(func_name, args, key);
		}
	}

	/**
	 * Set variable's value into something.
	 * @author JOELwindows7
	 * @param var_name which variable?
	 * @param object what value be filled with?
	 */
	public function setVar(name:String, value:Dynamic, useHaxe:String = "modchart")
	{
		if (interp != null)
			if (retailIsReady)
			{
				hscriptState.get(useHaxe).variables.set(name, value);
			}
			else
				interp.variables.set(name, value);
		else
		{
			interp = createInterp();
			setVar(name, value, useHaxe);
		}
	}

	public function getVar(name:String, useHaxe:String = "modchart"):Dynamic
	{
		if (retailIsReady)
			return hscriptState.get(useHaxe).variables.get(name);
		else
			return interp.variables.get(name);
	}

	/**
	 * same as setVar, for compatibility I guess
	 * @param var_name 
	 * @param object 
	 */
	public function addCallback(var_name:String, object:Dynamic)
	{
		setVar(var_name, object);
	}

	public function executeState(name:String, args:Array<Dynamic>, useHaxe:String = "modchart")
	{
		callHscript(name, args, useHaxe);
	}

	function resetHaxeScriptState(soft:Bool = false)
	{
		if (soft)
		{
			if (parser == null)
				parser = new ParserEx();
			if (interp == null)
				interp = createInterp();
			return;
		}
		parser = new ParserEx();
		interp = createInterp();
	}

	function fillInScripts(rawMode:Bool = false, path:String = "")
	{
		// JOELwindows7: please be direct from now on.
		// Pre lowecase song files
		// var songLowercase = StringTools.replace(PlayState.SONG.songId, " ", "-").toLowerCase();
		// switch (songLowercase) {
		//     case 'dad-battle': songLowercase = 'dadbattle';
		//     case 'philly-nice': songLowercase = 'philly';
		// }

		var patho = Paths.hscript('songs/${PlayState.SONG.songId}/modchart');
		#if FEATURE_STEPMANIA
		if (PlayState.isSM)
			patho = PlayState.pathToSm + "/modchart.hscript";
		#end

		script = Assets.getText(rawMode ? Paths.hscript(path) : patho).trim();
		trace(script);
		prog = parser.parseString(script);
		trace("parsened");
	}

	/**
	 * Create instance of a class in the hscript
	 * @author JOELwindows7
	 * @param className 
	 * @param args 
	 * @param addModule 
	 */
	public function createScriptClassInstance(className:String, args:Array<Dynamic> = null, addModule:String)
	{
		if (interp != null)
		{
			if (addModule != null && addModule != "")
				interp.addModule(addModule);
			return interp.createScriptClassInstance(className, args);
		}
		else
		{
			interp = createInterp();
			return createScriptClassInstance(className, args, addModule);
		}
	}

	function initHaxeScriptState(rawMode:Bool = false, path:String = "", useHaxe:String = "modchart", className:String = "", useRetail:Bool = false)
	{
		// start by init core stuffs.
		resetHaxeScriptState();

		// var p = Path.of(Paths.hscript(path));
		// trace("opening the hscript of " + p.getAbsolutePath() + "\nisExist " + p.exists());
		// var f = p.toFile();
		// script = p.exists()? f.readAsString(): "";

		fillInScripts(rawMode, path);
		trace("Filled Script");

		// Syndicate all vars here boys!
		// Peck this. let's just yoink BulbyVR's modchart inits and stuffs
		// https://github.com/TheDrawingCoder-Gamer/Funkin/blob/master/source/PlayState.hx
		// https://github.com/TheDrawingCoder-Gamer/Funkin/blob/master/source/PluginManager.hx
		// now with copy from ModChartState.hx
		setVar("difficulty", PlayState.storyDifficulty);
		setVar("bpm", Conductor.bpm);
		setVar("scrollspeed", FlxG.save.data.scrollSpeed != 1 ? FlxG.save.data.scrollSpeed : PlayState.SONG.speed);
		setVar("fpsCap", FlxG.save.data.fpsCap);
		setVar("downscroll", FlxG.save.data.downscroll);
		setVar("flashing", FlxG.save.data.flashing);
		setVar("distractions", FlxG.save.data.distractions);
		trace("setVar those metadata");

		setVar("curStep", 0);
		setVar("curBeat", 0);
		setVar("crochet", Conductor.stepCrochet);
		setVar("safeZoneOffset", Conductor.safeZoneOffset);

		setVar("hudZoom", PlayState.instance.camHUD.zoom);
		setVar("cameraZoom", FlxG.camera.zoom);

		setVar("cameraAngle", FlxG.camera.angle);
		setVar("camHudAngle", PlayState.instance.camHUD.angle);

		setVar("followXOffset", 0);
		setVar("followYOffset", 0);
		trace("camera setVar");

		setVar("showOnlyStrums", false);
		setVar("strumLine1Visible", true);
		setVar("strumLine2Visible", true);

		setVar("screenWidth", FlxG.width);
		setVar("screenHeight", FlxG.height);
		setVar("windowWidth", FlxG.width);
		setVar("windowHeight", FlxG.height);
		setVar("hudWidth", PlayState.instance.camHUD.width);
		setVar("hudHeight", PlayState.instance.camHUD.height);
		trace("HUD setVar");

		setVar("mustHit", false);
		trace("mustHit setVar");

		setVar("strumLineY", PlayState.instance.strumLine.y);
		trace("Camera target & Strumline height setVar");

		// JOELwindows7: mirror the variables here!
		// Colored bg
		setVar("originalColor", PlayState.Stage.originalColor);
		setVar("isChromaScreen", PlayState.Stage.isChromaScreen);
		// end mirror variables

		// init just in case
		setVar("songLength", 0);

		// callbacks

		// JOELwindows7: BulbyVR's special stuffs
		setVar("BEHIND_GF", BEHIND_GF);
		setVar("BEHIND_BF", BEHIND_BF);
		setVar("BEHIND_DAD", BEHIND_DAD);
		setVar("BEHIND_ALL", BEHIND_ALL);
		setVar("BEHIND_NONE", 0);
		setVar("songData", PlayState.SONG);
		setVar("camHUD", PlayState.instance.camHUD);
		setVar("playerStrums", PlayState.playerStrums);
		setVar("enemyStrums", PlayState.cpuStrums);
		setVar("hscriptPath", path);
		@:privateAccess { // JOELwindows7: Oh yeah, I suggest that uh... idk. maybe keep those characters private? no idk.
			setVar("boyfriend", PlayState.boyfriend);
			setVar("gf", PlayState.gf);
			setVar("dad", PlayState.dad);
		}
		setVar("vocals", PlayState.instance.vocals);
		setVar("gfSpeed", PlayState.instance.gfSpeed);
		setVar("tweenCamIn", PlayState.instance.tweenCamIn);
		setVar("health", PlayState.instance.health);
		setVar("iconP1", PlayState.instance.iconP1);
		setVar("iconP2", PlayState.instance.iconP2);
		setVar("currentPlayState", PlayState.instance);
		setVar("PlayState", PlayState);
		setVar("window", Lib.application.window);
		setVar("add", PlayState.instance.add);
		setVar("remove", PlayState.instance.remove);
		setVar("insert", PlayState.instance.insert);
		setVar("setDefaultZoom", function(zoom)
		{
			PlayState.Stage.camZoom = zoom;
		});
		setVar("removeSprite", function(sprite)
		{
			PlayState.instance.remove(sprite);
		});
		setVar("instancePluginClass", createScriptClassInstance);
		setVar("addSprite", function(sprite, position)
		{
			// sprite is a FlxSprite
			// position is a Int
			if (position & BEHIND_GF != 0)
				PlayState.instance.remove(PlayState.gf);
			if (position & BEHIND_DAD != 0)
				PlayState.instance.remove(PlayState.dad);
			if (position & BEHIND_BF != 0)
				PlayState.instance.remove(PlayState.boyfriend);
			PlayState.instance.add(sprite);
			if (position & BEHIND_GF != 0)
				PlayState.instance.add(PlayState.gf);
			if (position & BEHIND_DAD != 0)
				PlayState.instance.add(PlayState.dad);
			if (position & BEHIND_BF != 0)
				PlayState.instance.add(PlayState.boyfriend);
		});
		// JOELwindows7: & even more!!!
		setVar("thisStage", PlayState.Stage); // JOELwindows7: Stage class is already FlxG.stage I think..
		setVar("Paths", Paths);
		trace("setVar BulbyVR stuffs");

		// You must init the function callbacks first before even considered existed.
		addCallback("loaded", function(song)
		{
		});
		addCallback("start", function(song)
		{
		});
		addCallback("beatHit", function(beat)
		{
		});
		addCallback("update", function(elapsed)
		{
		});
		addCallback("songStart", function(elapsed)
		{
		});
		addCallback("songEnd", function(elapsed)
		{
			// JOELwindows7: call when song end before unloading this thing.
		});
		addCallback("stepHit", function(step)
		{
		});
		addCallback("playerTwoTurn", function()
		{
		});
		addCallback("playerTwoMiss", function(note, position, beatOf, stepOf)
		{
		});
		addCallback("playerTwoSing", function(note, position, beatOf, stepOf)
		{
		});
		addCallback("playerOneTurn", function()
		{
		});
		addCallback("playerOneMiss", function(note, position, beatOf, stepOf)
		{
		});
		addCallback("playerOneSing", function(note, position, beatOf, stepOf)
		{
		});
		addCallback("noteHit", function(player1:Bool, note:Note)
		{
		});
		addCallback("keyPressed", function(key)
		{
		});
		addCallback("introCutscene", function()
		{
		});
		addCallback("outroCutscene", function()
		{
		});
		addCallback("dialogueStart", function()
		{
		});
		addCallback("dialogueSkip", function()
		{
		});
		addCallback("dialogueFinish", function()
		{
		});
		addCallback("dialogueNext", function()
		{
		});
		trace("Inited setVars");

		// Callbacks heres, Kade Engine like
		// Sprites
		addCallback("makeSprite", makeHscriptSprite);
		addCallback("makeGifSprite", makeHscriptGifSprite); // JOELwindows7: the Gif Sprite GWebdev
		addCallback("changeDadCharacter", changeDadCharacter);
		addCallback("changeBoyfriendCharacter", changeBoyfriendCharacter);
		addCallback("changeGirlfriendCharacter", changeGirlfriendCharacter); // JOELwindows7: change GF
		addCallback("getProperty", getPropertyByName);

		addCallback("setNoteWiggle", function(wiggleId)
		{
			PlayState.instance.camNotes.setFilters([new ShaderFilter(haxeWiggles.get(wiggleId).shader)]);
		});

		addCallback("setSustainWiggle", function(wiggleId)
		{
			PlayState.instance.camSustains.setFilters([new ShaderFilter(haxeWiggles.get(wiggleId).shader)]);
		});

		addCallback("createWiggle", function(freq:Float, amplitude:Float, speed:Float)
		{
			var wiggle = new WiggleEffect();
			wiggle.waveAmplitude = amplitude;
			wiggle.waveSpeed = speed;
			wiggle.waveFrequency = freq;

			var id = Lambda.count(haxeWiggles) + 1 + "";

			haxeWiggles.set(id, wiggle);
			return id;
		});

		addCallback("setWiggleTime", function(wiggleId:String, time:Float)
		{
			var wiggle = haxeWiggles.get(wiggleId);

			wiggle.shader.uTime.value = [time];
		});

		addCallback("setWiggleAmplitude", function(wiggleId:String, amp:Float)
		{
			var wiggle = haxeWiggles.get(wiggleId);

			wiggle.waveAmplitude = amp;
		});
		trace("wiggle wiggle setVar");

		// addCallback("makeAnimatedSprite", makeAnimatedLuaSprite); //KadeDev says it's in development right now.
		addCallback("destroySprite", function(id:String)
		{
			var sprite = hscriptSprite.get(id);
			if (sprite == null)
				return false;
			PlayState.instance.removeObject(sprite);
			return true;
		});

		// HUD / Camera
		addCallback("initBackgroundVideo", function(videoName:String)
		{
			trace('playing assets/videos/' + videoName + '.webm');
			PlayState.instance.backgroundVideo("assets/videos/" + videoName + ".webm");
		});
		addCallback("pauseVideo", function()
		{
			if (PlayState.instance.useVLC)
			{
				PlayState.instance.vlcHandler.pause();
			}
			else if (!GlobalVideo.get().paused)
				GlobalVideo.get().pause();
		});
		addCallback("resumeVideo", function()
		{
			if (PlayState.instance.useVLC)
			{
				PlayState.instance.vlcHandler.resume();
			}
			else if (GlobalVideo.get().paused)
				GlobalVideo.get().pause();
		});
		addCallback("restartVideo", function()
		{
			if (PlayState.instance.useVLC)
			{
				// PlayState.instance.vlcHandler.restart();
			}
			else
				GlobalVideo.get().restart();
		});
		addCallback("getVideoSpriteX", function()
		{
			return PlayState.instance.videoSprite.x;
		});
		addCallback("getVideoSpriteY", function()
		{
			return PlayState.instance.videoSprite.y;
		});
		addCallback("setVideoSpritePos", function(x:Int, y:Int)
		{
			PlayState.instance.videoSprite.setPosition(x, y);
		});
		addCallback("setVideoSpriteScale", function(scale:Float)
		{
			PlayState.instance.videoSprite.setGraphicSize(Std.int(PlayState.instance.videoSprite.width * scale));
		});
		addCallback("setHudAngle", function(x:Float)
		{
			PlayState.instance.camHUD.angle = x;
		});
		addCallback("setHealth", function(heal:Float)
		{
			PlayState.instance.health = heal;
		});
		addCallback("setHudPosition", function(x:Int, y:Int)
		{
			PlayState.instance.camHUD.x = x;
			PlayState.instance.camHUD.y = y;
		});
		addCallback("getHudX", function()
		{
			return PlayState.instance.camHUD.x;
		});
		addCallback("getHudY", function()
		{
			return PlayState.instance.camHUD.y;
		});
		addCallback("setCamPosition", function(x:Int, y:Int)
		{
			// JOELwindows7: pls werk again wtf man
			// FlxG.camera.x = x;
			// FlxG.camera.y = y;
			PlayState.instance.camGame.x = x;
			PlayState.instance.camGame.y = y;
		});
		addCallback("getCameraX", function()
		{
			return FlxG.camera.x;
		});
		addCallback("getCameraY", function()
		{
			return FlxG.camera.y;
		});
		addCallback("setCamZoom", function(zoomAmount:Float)
		{
			// JOELwindows7: was go refer to FlxG.camera directly.
			// C'mon it was working before 1.7 wtf man?!
			// FlxG.camera.zoom = zoomAmount;
			PlayState.instance.camGame.zoom = zoomAmount;
		});
		addCallback("setHudZoom", function(zoomAmount:Float)
		{
			PlayState.instance.camHUD.zoom = zoomAmount;
		});
		addCallback("camShake", function(intensity:Float = .05, duration:Float = .5, force:Bool = true, axes:Int = 0, onComplete:String)
		{
			// JOELwindows7: decide which axes this shakes at. yoink from HaxeFlixel snippet of camera shake.
			// https://snippets.haxeflixel.com/camera/shake/
			var shakeAxes:FlxAxes = switch (axes)
			{
				case 0: FlxAxes.XY;
				case 1: FlxAxes.X;
				case 2: FlxAxes.Y;
				case _: FlxAxes.XY;
			}

			// JOELwindows7: "I'm, not, that, OLD!!!" lol vs. oswald damn forgor user author.
			FlxG.camera.shake(intensity, duration, function()
			{
				if (onComplete != '' && onComplete != null)
				{
					callHscript(onComplete, ["camera"]);
				}
			}, force, shakeAxes);
		});

		// Strumline
		addCallback("setStrumlineY", function(y:Float)
		{
			PlayState.instance.strumLine.y = y;
		});

		// Actors
		addCallback("getRenderedNotes", function()
		{
			return PlayState.instance.notes.length;
		});
		addCallback("getRenderedNoteX", function(id:Int)
		{
			return PlayState.instance.notes.members[id].x;
		});
		addCallback("getRenderedNoteY", function(id:Int)
		{
			return PlayState.instance.notes.members[id].y;
		});

		addCallback("getRenderedNoteType", function(id:Int)
		{
			return PlayState.instance.notes.members[id].noteData;
		});

		addCallback("isSustain", function(id:Int)
		{
			return PlayState.instance.notes.members[id].isSustainNote;
		});

		addCallback("isParentSustain", function(id:Int)
		{
			return PlayState.instance.notes.members[id].prevNote.isSustainNote;
		});

		addCallback("getRenderedNoteParentX", function(id:Int)
		{
			return PlayState.instance.notes.members[id].prevNote.x;
		});

		addCallback("getRenderedNoteParentY", function(id:Int)
		{
			return PlayState.instance.notes.members[id].prevNote.y;
		});

		addCallback("getRenderedNoteHit", function(id:Int)
		{
			return PlayState.instance.notes.members[id].mustPress;
		});

		addCallback("getRenderedNoteCalcX", function(id:Int)
		{
			if (PlayState.instance.notes.members[id].mustPress)
				return PlayState.playerStrums.members[Math.floor(Math.abs(PlayState.instance.notes.members[id].noteData))].x;
			return PlayState.strumLineNotes.members[Math.floor(Math.abs(PlayState.instance.notes.members[id].noteData))].x;
		});

		addCallback("anyNotes", function()
		{
			return PlayState.instance.notes.members.length != 0;
		});

		addCallback("getRenderedNoteStrumtime", function(id:Int)
		{
			return PlayState.instance.notes.members[id].strumTime;
		});

		addCallback("getRenderedNoteScaleX", function(id:Int)
		{
			return PlayState.instance.notes.members[id].scale.x;
		});

		addCallback("setRenderedNotePos", function(x:Float, y:Float, id:Int)
		{
			if (PlayState.instance.notes.members[id] == null)
				throw('error! you cannot set a rendered notes position when it doesnt exist! ID: ' + id);
			else
			{
				PlayState.instance.notes.members[id].modifiedByLua = true;
				PlayState.instance.notes.members[id].x = x;
				PlayState.instance.notes.members[id].y = y;
			}
		});

		addCallback("setRenderedNoteAlpha", function(alpha:Float, id:Int)
		{
			PlayState.instance.notes.members[id].modifiedByLua = true;
			PlayState.instance.notes.members[id].alpha = alpha;
		});

		addCallback("setRenderedNoteScale", function(scale:Float, id:Int)
		{
			PlayState.instance.notes.members[id].modifiedByLua = true;
			PlayState.instance.notes.members[id].setGraphicSize(Std.int(PlayState.instance.notes.members[id].width * scale));
		});

		addCallback("setRenderedNoteScale", function(scaleX:Int, scaleY:Int, id:Int)
		{
			PlayState.instance.notes.members[id].modifiedByLua = true;
			PlayState.instance.notes.members[id].setGraphicSize(scaleX, scaleY);
		});

		addCallback("getRenderedNoteWidth", function(id:Int)
		{
			return PlayState.instance.notes.members[id].width;
		});

		addCallback("setRenderedNoteAngle", function(angle:Float, id:Int)
		{
			PlayState.instance.notes.members[id].modifiedByLua = true;
			PlayState.instance.notes.members[id].angle = angle;
		});

		addCallback("setActorX", function(x:Int, id:String)
		{
			getActorByName(id).x = x;
		});

		addCallback("setActorAccelerationX", function(x:Int, id:String)
		{
			getActorByName(id).acceleration.x = x;
		});

		addCallback("setActorDragX", function(x:Int, id:String)
		{
			getActorByName(id).drag.x = x;
		});

		addCallback("setActorVelocityX", function(x:Int, id:String)
		{
			getActorByName(id).velocity.x = x;
		});

		addCallback("playActorAnimation", function(id:String, anim:String, force:Bool = false, reverse:Bool = false)
		{
			getActorByName(id).playAnim(anim, force, reverse);
		});

		addCallback("setActorAlpha", function(alpha:Float, id:String)
		{
			getActorByName(id).alpha = alpha;
		});

		addCallback("setActorY", function(y:Int, id:String)
		{
			getActorByName(id).y = y;
		});

		addCallback("setActorAccelerationY", function(y:Int, id:String)
		{
			getActorByName(id).acceleration.y = y;
		});

		addCallback("setActorDragY", function(y:Int, id:String)
		{
			getActorByName(id).drag.y = y;
		});

		addCallback("setActorVelocityY", function(y:Int, id:String)
		{
			getActorByName(id).velocity.y = y;
		});

		addCallback("setActorAngle", function(angle:Int, id:String)
		{
			getActorByName(id).angle = angle;
		});

		addCallback("setActorScale", function(scale:Float, id:String)
		{
			getActorByName(id).setGraphicSize(Std.int(getActorByName(id).width * scale));
		});

		addCallback("setActorScaleXY", function(scaleX:Float, scaleY:Float, id:String)
		{
			getActorByName(id).setGraphicSize(Std.int(getActorByName(id).width * scaleX), Std.int(getActorByName(id).height * scaleY));
		});

		addCallback("setActorFlipX", function(flip:Bool, id:String)
		{
			getActorByName(id).flipX = flip;
		});

		addCallback("setActorFlipY", function(flip:Bool, id:String)
		{
			getActorByName(id).flipY = flip;
		});

		// JOELwindows7: moar
		addCallback("setActorScrollFactor", function(x:Float, y:Float, id:String)
		{
			getActorByName(id).scrollFactor.set(x, y);
		});

		addCallback("getActorWidth", function(id:String)
		{
			return getActorByName(id).width;
		});

		addCallback("getActorHeight", function(id:String)
		{
			return getActorByName(id).height;
		});

		addCallback("getActorAlpha", function(id:String)
		{
			return getActorByName(id).alpha;
		});

		addCallback("getActorAngle", function(id:String)
		{
			return getActorByName(id).angle;
		});

		addCallback("getActorX", function(id:String)
		{
			return getActorByName(id).x;
		});

		addCallback("getActorY", function(id:String)
		{
			return getActorByName(id).y;
		});

		// JOELwindows7: moar get
		addCallback("getActorScrollFactorX", function(id:String)
		{
			return getActorByName(id).scrollFactor.x;
		});

		addCallback("getActorScrollFactorY", function(id:String)
		{
			return getActorByName(id).scrollFactor.y;
		});

		addCallback("getActorVelocityX", function(id:String)
		{
			return getActorByName(id).velocity.x;
		});

		addCallback("getActorVelocityY", function(id:String)
		{
			return getActorByName(id).velocity.y;
		});

		addCallback("setWindowPos", function(x:Int, y:Int)
		{
			Application.current.window.x = x;
			Application.current.window.y = y;
		});

		addCallback("getWindowX", function()
		{
			return Application.current.window.x;
		});

		addCallback("getWindowY", function()
		{
			return Application.current.window.y;
		});

		addCallback("resizeWindow", function(Width:Int, Height:Int)
		{
			Application.current.window.resize(Width, Height);
		});

		addCallback("getScreenWidth", function()
		{
			return Application.current.window.display.currentMode.width;
		});

		addCallback("getScreenHeight", function()
		{
			return Application.current.window.display.currentMode.height;
		});

		addCallback("getWindowWidth", function()
		{
			return Application.current.window.width;
		});

		addCallback("getWindowHeight", function()
		{
			return Application.current.window.height;
		});

		// tweens
		addCallback("tweenCameraPos", function(toX:Int, toY:Int, time:Float, onComplete:String)
		{
			// JOELwindows7: was using FlxG.camera directly.
			// Now this no longer work let's go through the variable camGame instead.
			FlxTween.tween(PlayState.instance.camGame, {x: toX, y: toY}, time, {
				ease: FlxEase.linear,
				onComplete: function(flxTween:FlxTween)
				{
					if (onComplete != '' && onComplete != null)
					{
						callHscript(onComplete, ["camera"]);
					}
				}
			});
		});

		addCallback("tweenCameraAngle", function(toAngle:Float, time:Float, onComplete:String)
		{
			// JOELwindows7: this too
			FlxTween.tween(PlayState.instance.camGame, {angle: toAngle}, time, {
				ease: FlxEase.linear,
				onComplete: function(flxTween:FlxTween)
				{
					if (onComplete != '' && onComplete != null)
					{
						callHscript(onComplete, ["camera"]);
					}
				}
			});
		});

		addCallback("tweenCameraZoom", function(toZoom:Float, time:Float, onComplete:String)
		{
			// JOELwindows7: and another.
			FlxTween.tween(PlayState.instance.camGame, {zoom: toZoom}, time, {
				ease: FlxEase.linear,
				onComplete: function(flxTween:FlxTween)
				{
					if (onComplete != '' && onComplete != null)
					{
						callHscript(onComplete, ["camera"]);
					}
				}
			});
		});

		addCallback("tweenHudPos", function(toX:Int, toY:Int, time:Float, onComplete:String)
		{
			FlxTween.tween(PlayState.instance.camHUD, {x: toX, y: toY}, time, {
				ease: FlxEase.linear,
				onComplete: function(flxTween:FlxTween)
				{
					if (onComplete != '' && onComplete != null)
					{
						callHscript(onComplete, ["camera"]);
					}
				}
			});
		});

		addCallback("tweenHudAngle", function(toAngle:Float, time:Float, onComplete:String)
		{
			FlxTween.tween(PlayState.instance.camHUD, {angle: toAngle}, time, {
				ease: FlxEase.linear,
				onComplete: function(flxTween:FlxTween)
				{
					if (onComplete != '' && onComplete != null)
					{
						callHscript(onComplete, ["camera"]);
					}
				}
			});
		});

		addCallback("tweenHudZoom", function(toZoom:Float, time:Float, onComplete:String)
		{
			FlxTween.tween(PlayState.instance.camHUD, {zoom: toZoom}, time, {
				ease: FlxEase.linear,
				onComplete: function(flxTween:FlxTween)
				{
					if (onComplete != '' && onComplete != null)
					{
						callHscript(onComplete, ["camera"]);
					}
				}
			});
		});

		addCallback("tweenPos", function(id:String, toX:Int, toY:Int, time:Float, onComplete:String)
		{
			FlxTween.tween(getActorByName(id), {x: toX, y: toY}, time, {
				ease: FlxEase.linear,
				onComplete: function(flxTween:FlxTween)
				{
					if (onComplete != '' && onComplete != null)
					{
						callHscript(onComplete, [id]);
					}
				}
			});
		});

		addCallback("tweenPosXAngle", function(id:String, toX:Int, toAngle:Float, time:Float, onComplete:String)
		{
			FlxTween.tween(getActorByName(id), {x: toX, angle: toAngle}, time, {
				ease: FlxEase.linear,
				onComplete: function(flxTween:FlxTween)
				{
					if (onComplete != '' && onComplete != null)
					{
						callHscript(onComplete, [id]);
					}
				}
			});
		});

		addCallback("tweenPosYAngle", function(id:String, toY:Int, toAngle:Float, time:Float, onComplete:String)
		{
			FlxTween.tween(getActorByName(id), {y: toY, angle: toAngle}, time, {
				ease: FlxEase.linear,
				onComplete: function(flxTween:FlxTween)
				{
					if (onComplete != '' && onComplete != null)
					{
						callHscript(onComplete, [id]);
					}
				}
			});
		});

		addCallback("tweenAngle", function(id:String, toAngle:Int, time:Float, onComplete:String)
		{
			FlxTween.tween(getActorByName(id), {angle: toAngle}, time, {
				ease: FlxEase.linear,
				onComplete: function(flxTween:FlxTween)
				{
					if (onComplete != '' && onComplete != null)
					{
						callHscript(onComplete, [id]);
					}
				}
			});
		});

		addCallback("tweenCameraPosOut", function(toX:Int, toY:Int, time:Float, onComplete:String)
		{
			FlxTween.tween(FlxG.camera, {x: toX, y: toY}, time, {
				ease: FlxEase.cubeOut,
				onComplete: function(flxTween:FlxTween)
				{
					if (onComplete != '' && onComplete != null)
					{
						callHscript(onComplete, ["camera"]);
					}
				}
			});
		});

		addCallback("tweenCameraAngleOut", function(toAngle:Float, time:Float, onComplete:String)
		{
			FlxTween.tween(FlxG.camera, {angle: toAngle}, time, {
				ease: FlxEase.cubeOut,
				onComplete: function(flxTween:FlxTween)
				{
					if (onComplete != '' && onComplete != null)
					{
						callHscript(onComplete, ["camera"]);
					}
				}
			});
		});

		addCallback("tweenCameraZoomOut", function(toZoom:Float, time:Float, onComplete:String)
		{
			FlxTween.tween(FlxG.camera, {zoom: toZoom}, time, {
				ease: FlxEase.cubeOut,
				onComplete: function(flxTween:FlxTween)
				{
					if (onComplete != '' && onComplete != null)
					{
						callHscript(onComplete, ["camera"]);
					}
				}
			});
		});

		addCallback("tweenHudPosOut", function(toX:Int, toY:Int, time:Float, onComplete:String)
		{
			FlxTween.tween(PlayState.instance.camHUD, {x: toX, y: toY}, time, {
				ease: FlxEase.cubeOut,
				onComplete: function(flxTween:FlxTween)
				{
					if (onComplete != '' && onComplete != null)
					{
						callHscript(onComplete, ["camera"]);
					}
				}
			});
		});

		addCallback("tweenHudAngleOut", function(toAngle:Float, time:Float, onComplete:String)
		{
			FlxTween.tween(PlayState.instance.camHUD, {angle: toAngle}, time, {
				ease: FlxEase.cubeOut,
				onComplete: function(flxTween:FlxTween)
				{
					if (onComplete != '' && onComplete != null)
					{
						callHscript(onComplete, ["camera"]);
					}
				}
			});
		});

		addCallback("tweenHudZoomOut", function(toZoom:Float, time:Float, onComplete:String)
		{
			FlxTween.tween(PlayState.instance.camHUD, {zoom: toZoom}, time, {
				ease: FlxEase.cubeOut,
				onComplete: function(flxTween:FlxTween)
				{
					if (onComplete != '' && onComplete != null)
					{
						callHscript(onComplete, ["camera"]);
					}
				}
			});
		});

		addCallback("tweenPosOut", function(id:String, toX:Int, toY:Int, time:Float, onComplete:String)
		{
			FlxTween.tween(getActorByName(id), {x: toX, y: toY}, time, {
				ease: FlxEase.cubeOut,
				onComplete: function(flxTween:FlxTween)
				{
					if (onComplete != '' && onComplete != null)
					{
						callHscript(onComplete, [id]);
					}
				}
			});
		});

		addCallback("tweenPosXAngleOut", function(id:String, toX:Int, toAngle:Float, time:Float, onComplete:String)
		{
			FlxTween.tween(getActorByName(id), {x: toX, angle: toAngle}, time, {
				ease: FlxEase.cubeOut,
				onComplete: function(flxTween:FlxTween)
				{
					if (onComplete != '' && onComplete != null)
					{
						callHscript(onComplete, [id]);
					}
				}
			});
		});

		addCallback("tweenPosYAngleOut", function(id:String, toY:Int, toAngle:Float, time:Float, onComplete:String)
		{
			FlxTween.tween(getActorByName(id), {y: toY, angle: toAngle}, time, {
				ease: FlxEase.cubeOut,
				onComplete: function(flxTween:FlxTween)
				{
					if (onComplete != '' && onComplete != null)
					{
						callHscript(onComplete, [id]);
					}
				}
			});
		});

		addCallback("tweenAngleOut", function(id:String, toAngle:Int, time:Float, onComplete:String)
		{
			FlxTween.tween(getActorByName(id), {angle: toAngle}, time, {
				ease: FlxEase.cubeOut,
				onComplete: function(flxTween:FlxTween)
				{
					if (onComplete != '' && onComplete != null)
					{
						callHscript(onComplete, [id]);
					}
				}
			});
		});

		addCallback("tweenCameraPosIn", function(toX:Int, toY:Int, time:Float, onComplete:String)
		{
			FlxTween.tween(FlxG.camera, {x: toX, y: toY}, time, {
				ease: FlxEase.cubeIn,
				onComplete: function(flxTween:FlxTween)
				{
					if (onComplete != '' && onComplete != null)
					{
						callHscript(onComplete, ["camera"]);
					}
				}
			});
		});

		addCallback("tweenCameraAngleIn", function(toAngle:Float, time:Float, onComplete:String)
		{
			FlxTween.tween(FlxG.camera, {angle: toAngle}, time, {
				ease: FlxEase.cubeIn,
				onComplete: function(flxTween:FlxTween)
				{
					if (onComplete != '' && onComplete != null)
					{
						callHscript(onComplete, ["camera"]);
					}
				}
			});
		});

		addCallback("tweenCameraZoomIn", function(toZoom:Float, time:Float, onComplete:String)
		{
			FlxTween.tween(FlxG.camera, {zoom: toZoom}, time, {
				ease: FlxEase.cubeIn,
				onComplete: function(flxTween:FlxTween)
				{
					if (onComplete != '' && onComplete != null)
					{
						callHscript(onComplete, ["camera"]);
					}
				}
			});
		});

		addCallback("tweenHudPosIn", function(toX:Int, toY:Int, time:Float, onComplete:String)
		{
			FlxTween.tween(PlayState.instance.camHUD, {x: toX, y: toY}, time, {
				ease: FlxEase.cubeIn,
				onComplete: function(flxTween:FlxTween)
				{
					if (onComplete != '' && onComplete != null)
					{
						callHscript(onComplete, ["camera"]);
					}
				}
			});
		});

		addCallback("tweenHudAngleIn", function(toAngle:Float, time:Float, onComplete:String)
		{
			FlxTween.tween(PlayState.instance.camHUD, {angle: toAngle}, time, {
				ease: FlxEase.cubeIn,
				onComplete: function(flxTween:FlxTween)
				{
					if (onComplete != '' && onComplete != null)
					{
						callHscript(onComplete, ["camera"]);
					}
				}
			});
		});

		addCallback("tweenHudZoomIn", function(toZoom:Float, time:Float, onComplete:String)
		{
			FlxTween.tween(PlayState.instance.camHUD, {zoom: toZoom}, time, {
				ease: FlxEase.cubeIn,
				onComplete: function(flxTween:FlxTween)
				{
					if (onComplete != '' && onComplete != null)
					{
						callHscript(onComplete, ["camera"]);
					}
				}
			});
		});

		addCallback("tweenPosIn", function(id:String, toX:Int, toY:Int, time:Float, onComplete:String)
		{
			FlxTween.tween(getActorByName(id), {x: toX, y: toY}, time, {
				ease: FlxEase.cubeIn,
				onComplete: function(flxTween:FlxTween)
				{
					if (onComplete != '' && onComplete != null)
					{
						callHscript(onComplete, [id]);
					}
				}
			});
		});

		addCallback("tweenPosXAngleIn", function(id:String, toX:Int, toAngle:Float, time:Float, onComplete:String)
		{
			FlxTween.tween(getActorByName(id), {x: toX, angle: toAngle}, time, {
				ease: FlxEase.cubeIn,
				onComplete: function(flxTween:FlxTween)
				{
					if (onComplete != '' && onComplete != null)
					{
						callHscript(onComplete, [id]);
					}
				}
			});
		});

		addCallback("tweenPosYAngleIn", function(id:String, toY:Int, toAngle:Float, time:Float, onComplete:String)
		{
			FlxTween.tween(getActorByName(id), {y: toY, angle: toAngle}, time, {
				ease: FlxEase.cubeIn,
				onComplete: function(flxTween:FlxTween)
				{
					if (onComplete != '' && onComplete != null)
					{
						callHscript(onComplete, [id]);
					}
				}
			});
		});

		addCallback("tweenAngleIn", function(id:String, toAngle:Int, time:Float, onComplete:String)
		{
			FlxTween.tween(getActorByName(id), {angle: toAngle}, time, {
				ease: FlxEase.cubeIn,
				onComplete: function(flxTween:FlxTween)
				{
					if (onComplete != '' && onComplete != null)
					{
						callHscript(onComplete, [id]);
					}
				}
			});
		});

		addCallback("tweenFadeIn", function(id:String, toAlpha:Float, time:Float, onComplete:String)
		{
			FlxTween.tween(getActorByName(id), {alpha: toAlpha}, time, {
				ease: FlxEase.circIn,
				onComplete: function(flxTween:FlxTween)
				{
					if (onComplete != '' && onComplete != null)
					{
						callHscript(onComplete, [id]);
					}
				}
			});
		});

		addCallback("tweenFadeOut", function(id:String, toAlpha:Float, time:Float, onComplete:String)
		{
			FlxTween.tween(getActorByName(id), {alpha: toAlpha}, time, {
				ease: FlxEase.circOut,
				onComplete: function(flxTween:FlxTween)
				{
					if (onComplete != '' && onComplete != null)
					{
						callHscript(onComplete, [id]);
					}
				}
			});
		});

		// Shaders
		/*addCallback("createShader", function(frag:String,vert:String) {
				var shader:LuaShader = new LuaShader(frag,vert);

				trace(shader.glFragmentSource);

				shaders.push(shader);
				// if theres 1 shader we want to say theres 0 since 0 index and length returns a 1 index.
				return shaders.length == 1 ? 0 : shaders.length;
			});


			addCallback("setFilterHud", function(shaderIndex:Int) {
				PlayState.instance.camHUD.setFilters([new ShaderFilter(shaders[shaderIndex])]);
			});

			addCallback("setFilterCam", function(shaderIndex:Int) {
				FlxG.camera.setFilters([new ShaderFilter(shaders[shaderIndex])]);
		});*/

		// JOELwindows7: kem0x mod shader
		addCallback("createShaders", function(shaderName, ?optimize:Bool = false)
		{
			#if EXPERIMENTAL_KEM0X_SHADERS
			var shader = new DynamicShaderHandler(shaderName, optimize);

			return shaderName;
			#end
		});

		addCallback("modifyShaderProperty", function(shaderName, propertyName, value)
		{
			#if EXPERIMENTAL_KEM0X_SHADERS
			var handler = luaShaders[shaderName];
			handler.modifyShaderProperty(propertyName, value);
			#end
		});

		// shader set

		addCallback("setShadersToCamera", function(shaderName:Array<String>, cameraName)
		{
			switch (cameraName)
			{
				case 'hud':
					camTarget = PlayState.instance.camHUD;
				case 'notes':
					camTarget = PlayState.instance.camNotes;
				case 'sustains':
					camTarget = PlayState.instance.camSustains;
				case 'game':
					camTarget = FlxG.camera;
			}

			#if EXPERIMENTAL_KEM0X_SHADERS
			var shaderArray = new Array<BitmapFilter>();

			for (i in shaderName)
			{
				shaderArray.push(new ShaderFilter(luaShaders[i].shader));
			}

			camTarget.setFilters(shaderArray);
			#end
		});

		// shader clear

		addCallback("clearShadersFromCamera", function(cameraName)
		{
			switch (cameraName)
			{
				case 'hud':
					camTarget = PlayState.instance.camHUD;
				case 'notes':
					camTarget = PlayState.instance.camNotes;
				case 'sustains':
					camTarget = PlayState.instance.camSustains;
				case 'game':
					camTarget = FlxG.camera;
			}
			camTarget.setFilters([]);
		});
		// end kem0x mod shader

		// Special JOELwindows7
		addCallback("cheerNow",
			function(ooutOfBeatFractioning:Int = 4, doItOn:Int = 0, randomizeColor:Bool = false, justOne:Bool = false, toWhichBg:Int = 0, forceIt:Bool = false)
			{
				PlayState.instance.cheerNow(ooutOfBeatFractioning, doItOn, randomizeColor, justOne, toWhichBg, forceIt);
			});

		addCallback("heyNow",
			function(ooutOfBeatFractioning:Int = 4, doItOn:Int = 0, randomizeColor:Bool = false, justOne:Bool = false, toWhichBg:Int = 0, forceIt:Bool = false)
			{
				PlayState.instance.heyNow(ooutOfBeatFractioning, doItOn, randomizeColor, justOne, toWhichBg, forceIt);
			});

		addCallback("justCheer", function(forceIt:Bool = false)
		{
			PlayState.instance.justCheer(forceIt);
		});

		addCallback("justHey", function(forceIt:Bool = false)
		{
			PlayState.instance.justHey(forceIt);
		});

		addCallback("appearBlackbar", function(forHowLong:Float = 1, useStageLevel:Bool = false)
		{
			if(useStageLevel)
				PlayState.Stage.appearBlackBar(forHowLong)
			else
				PlayState.instance.appearRealBlackBar(forHowLong);
		});

		addCallback("disappearBlackbar", function(forHowLong:Float = 1, useStageLevel:Bool = false)
		{
			if(useStageLevel)
				PlayState.Stage.disappearBlackBar(forHowLong)
			else
				PlayState.instance.disappearRealBlackBar(forHowLong);
		});

		addCallback("prepareColorableBg",
			function(useImage:Bool = false, positionX:Float = -500, positionY:Float = -500, imagePath:String = '', animated:Bool = false,
					color:String = "WHITE", width:Int = 1, height:Int = 1, upscaleX:Int = 1, upscaleY:Int = 1, antialiasing:Bool = true,
					scrollFactorX:Float = .5, scrollFactorY:Float = .5, active:Bool = false, callNow:Bool = true, unique:Bool = false)
			{
				PlayState.Stage.prepareColorableBg(useImage, positionX, positionY, imagePath, animated, FlxColor.fromString(color), width, height, upscaleX,
					upscaleY, antialiasing, scrollFactorX, scrollFactorY, active, callNow, unique);
				// HOOF! so complicated!
				// idk man who will use this. but just in case you would like to reset spawn
				// a graphics here, you can use this.
				// and this is NOT RECOMMENDED to be used at all
				// because loading new image or generate graphic has lags on it.
				// Just don't touch this.
			});

		addCallback("randomizeColoring", function(justOne:Bool = false, toWhichBg:Int = 0, inHowLong:Float = 0.01)
		{
			// trace("wattempt script randomize color");
			PlayState.Stage.randomizeColoring(justOne, toWhichBg, inHowLong);
			// ARE YOU SERIOUS??!?!? i SUPPOSED TO MEANT randomizeColoring not randomizeColor
			// and you, Haxe Language Server laggs on purpose
			// hence I blinded & mistyped!!! C'MON!!!! REALLY??!?!
		});

		addCallback("chooseColoringColor", function(color:String = "WHITE", justOne:Bool = true, toWhichBg:Int = 0, inHowLong:Float = 0)
		{
			trace("wattempt script choose color " + color);
			PlayState.Stage.chooseColoringColor(FlxColor.fromString(color.trim()), justOne, toWhichBg, inHowLong);
			// hmm, I am afraid using raw FlxColor data doing won't work.
			// You see, I believe Lua can't have weird datatype other than Int, Float, String, Array, something like that.
			// so, maybe you should use the.. string version?
			// so here it is. the FlxCOlor.fromString() is magic. it can understand 0x000000, #FFFFFFFF, or even Name!!! wow!!
		});

		addCallback("hideColoring", function(justOne:Bool = false, toWhichBg:Int = 0, inHowLong:Float = 0)
		{
			PlayState.Stage.hideColoring(justOne, toWhichBg, inHowLong);
			// hide the colorings
		});

		addCallback("camZoomNow", function(howMuchZoom:Float = .015, howMuchZoomHUD:Float = .03, maxZoom:Float = 1.35)
		{
			PlayState.instance.camZoomNow(howMuchZoom, howMuchZoomHUD, maxZoom);
			// zoom the cam now
		});

		addCallback("trainStart", function()
		{
			// Manually start the train right from the modchart anyway.
			PlayState.Stage.trainStart();
		});

		addCallback("trainReset", function()
		{
			// Also reset the train from modchart as well
			PlayState.Stage.trainReset();
		});

		addCallback("lightningStrikeHit", function()
		{
			// Now you can abuse the lightning lol!!!
			PlayState.Stage.lightningStrikeShit();
		}); // what the heck, Haxe Language server? you didn't quickly tell me
		// That I missed semicolon? what cause of all these lags?

		addCallback("fastCarDrive", function()
		{
			// haha fast car go brrrrr!!!
			PlayState.Stage.fastCarDrive();
		});

		addCallback("resetFastCar", function()
		{
			// reset da cars! now!!
			PlayState.Stage.resetFastCar();
		});

		addCallback("vibrate", function(player:Int = 0, duration:Float = 100, period:Float = 0, strengthLeft:Float = 0, strengthRight:Float = 0)
		{
			// vibration, sensation, okeh self explanatory. lol TheFatRat - Electrified
			Controls.vibrate(player, duration, period, strengthLeft, strengthRight);
		});

		addCallback("createToast", function(iconPath:String = "", title:String = "", description:String = "", sound:Bool = false)
		{
			// JOELwindows7: gamejolt toast
			Main.gjToastManager.createToast(iconPath, title, description, sound);
		});

		// Cutscene calls
		addCallback("introSceneIsDone", function()
		{
			@:privateAccess {
				if (!PlayState.instance.introDoneCalled)
					PlayState.instance.recallIntroSceneDone();
			}
		});

		addCallback("outroSceneIsDone", function()
		{
			@:privateAccess {
				if (!PlayState.instance.outroDoneCalled)
					PlayState.instance.recallOutroSceneDone();
			}
		});

		// end more special functions
		// So you don't have to hard code your cool effects.

		// Default Strums
		for (i in 0...PlayState.strumLineNotes.length)
		{
			var member = PlayState.strumLineNotes.members[i];
			trace(PlayState.strumLineNotes.members[i].x
				+ " "
				+ PlayState.strumLineNotes.members[i].y + " " + PlayState.strumLineNotes.members[i].angle + " | strum" + i);
			// setVar("strum" + i + "X", Math.floor(member.x));
			setVar("defaultStrum" + i + "X", Math.floor(member.x));
			// setVar("strum" + i + "Y", Math.floor(member.y));
			setVar("defaultStrum" + i + "Y", Math.floor(member.y));
			// setVar("strum" + i + "Angle", Math.floor(member.angle));
			setVar("defaultStrum" + i + "Angle", Math.floor(member.angle));
			trace("Adding strum" + i);
		}

		// set hscriptState
		hscriptState = new Map<String, InterpEx>();
		if (useRetail)
			hscriptState.set(useHaxe, interp);
		interp.execute(prog);
		// call loaded once the file just loaded
		executeState("loaded", [PlayState.SONG.songId], useHaxe);

		// interp.addModule(script);
		// instancering:HaxeModBase = interp.createScriptClassInstance(className);

		trace("Hscript loaded");

		retailIsReady = useRetail;
	}

	/**
	 * Init haxe but register module version
	 * @param rawMode 
	 * @param path 
	 * @param className 
	 */
	public function registerModule(rawMode:Bool = false, path:String = "", className:String = "")
	{
		resetHaxeScriptState(true);
		var progs = parser.parseModule(script);
		trace("register stuffs");
		interp.registerModule(progs);
		trace("stuffs registered");
	}

	/**
	 * build the interp with all essential stuffs injected for the hscript's referencings
	 * steal from BulbyVR lol
	 * @author JOELwindows7
	 * @see https://github.com/TheDrawingCoder-Gamer/Funkin/blob/master/source/PluginManager.hx
	 * @return InterpEx() the prebuilt InterpEx instance
	 */
	function createInterp():InterpEx
	{
		var reterp:InterpEx = new InterpEx();

		reterp.variables.set("Conductor", Conductor);
		reterp.variables.set("FlxSprite", DynamicSprite);
		reterp.variables.set("FlxSound", DynamicSound);
		reterp.variables.set("FlxAtlasFrames", DynamicSprite.DynamicAtlasFrames);
		reterp.variables.set("FlxGroup", flixel.group.FlxGroup);
		reterp.variables.set("FlxAngle", flixel.math.FlxAngle);
		reterp.variables.set("FlxMath", flixel.math.FlxMath);
		reterp.variables.set("TitleState", TitleState);
		reterp.variables.set("makeRangeArray", CoolUtil.numberArray);

		reterp.variables.set("FlxG", HscriptGlobals);
		reterp.variables.set("FlxTimer", flixel.util.FlxTimer);
		reterp.variables.set("FlxTween", flixel.tweens.FlxTween);
		reterp.variables.set("Std", Std);
		reterp.variables.set("StringTools", StringTools);
		reterp.variables.set("MetroSprite", MetroSprite);
		reterp.variables.set("FlxTrail", FlxTrail);
		reterp.variables.set("FlxEase", FlxEase);
		reterp.variables.set("Reflect", Reflect);
		reterp.variables.set("Character", Character);
		reterp.variables.set("OptionsHandler", OptionsHandler);

		#if debug
		reterp.variables.set("debug", true);
		#else
		reterp.variables.set("debug", false);
		#end

		return reterp;
	}

	// Bonus stuffs

	function getPropertyByName(id:String)
	{
		return Reflect.field(PlayState.instance, id);
	}

	function makeHscriptSprite(spritePath:String, toBeCalled:String, drawBehind:Bool, imageFolder:Bool = false, ?library:String = '')
	{
		// pre lowercasing the song name (makeLuaSprite)
		// var songLowercase = StringTools.replace(PlayState.SONG.songId, " ", "-").toLowerCase();
		var songLowercase = PlayState.SONG.songId;
		// switch (songLowercase)
		// {
		// 	case 'dad-battle':
		// 		songLowercase = 'dadbattle';
		// 	case 'philly-nice':
		// 		songLowercase = 'philly';
		// }
		var convertingPath = "assets/" + (imageFolder ? (library != null && library != '' ? library + "/" : '') + "images" : "data/songs/" + songLowercase);
		// var path = #if !mobile Asset2File.getPath("assets/data/" + songLowercase) #else "assets/data/" + songLowercase #end;
		var path = #if !mobile Asset2File.getPath(convertingPath) #else convertingPath #end;

		#if sys
		if (PlayState.isSM && !imageFolder)
			path = PlayState.pathToSm;
		#end
		trace(path);

		var data:BitmapData = BitmapData.fromFile(#if !mobile path + "/" + spritePath + ".png" #else Asset2File.getPath(path + "/" + spritePath + ".png") #end
		);
		trace("bitmap data " + Std.string(data));

		var sprite:FlxSprite = new FlxSprite(0, 0);
		var imgWidth:Float = FlxG.width / data.width;
		var imgHeight:Float = FlxG.height / data.height;
		var scale:Float = imgWidth <= imgHeight ? imgWidth : imgHeight;

		// Cap the scale at x1
		if (scale > 1)
			scale = 1;

		sprite.makeGraphic(Std.int(data.width * scale), Std.int(data.width * scale), FlxColor.TRANSPARENT);

		var data2:BitmapData = sprite.pixels.clone();
		var matrix:Matrix = new Matrix();
		matrix.identity();
		matrix.scale(scale, scale);
		data2.fillRect(data2.rect, FlxColor.TRANSPARENT);
		data2.draw(data, matrix, null, null, null, true);
		sprite.pixels = data2;

		hscriptSprite.set(toBeCalled, sprite);
		trace("new " + toBeCalled + " Sprite added \n" + Std.string(hscriptSprite.get(toBeCalled)));
		// and I quote:
		// shitty layering but it works!
		@:privateAccess
		{
			if (drawBehind)
			{
				PlayState.instance.removeObject(PlayState.gf);
				PlayState.instance.removeObject(PlayState.boyfriend);
				PlayState.instance.removeObject(PlayState.dad);
			}
			PlayState.instance.addObject(sprite);
			if (drawBehind)
			{
				PlayState.instance.addObject(PlayState.gf);
				PlayState.instance.addObject(PlayState.boyfriend);
				PlayState.instance.addObject(PlayState.dad);
			}
		}
		return toBeCalled;
	}

	// JOELwindows7: here gif sprite
	function makeHscriptGifSprite(spritePath:String, toBeCalled:String, drawBehind:Bool, imageFolder:Bool = false, ?library:String = '')
	{
		// pre lowercasing the song name (makeLuaSprite)
		// var songLowercase = StringTools.replace(PlayState.SONG.songId, " ", "-").toLowerCase();
		var songLowercase = PlayState.SONG.songId;
		// switch (songLowercase)
		// {
		// 	case 'dad-battle':
		// 		songLowercase = 'dadbattle';
		// 	case 'philly-nice':
		// 		songLowercase = 'philly';
		// }
		var convertingPath = "assets/" + (imageFolder ? (library != null && library != '' ? library + "/" : '') + "images" : "data/songs/" + songLowercase);
		// var path = #if !mobile Asset2File.getPath("assets/data/" + songLowercase) #else "assets/data/" + songLowercase #end;
		var path = #if !mobile Asset2File.getPath(convertingPath) #else convertingPath #end;

		#if sys
		if (PlayState.isSM && !imageFolder)
			path = PlayState.pathToSm;
		#end
		trace(path);

		// var data:BitmapData = BitmapData.fromFile(#if !mobile path + "/" + spritePath + ".png" #else Asset2File.getPath(path + "/" + spritePath + ".png") #end
		// );
		// trace("bitmap data " + Std.string(data));

		var sprite:FlxGifSprite = new FlxGifSprite(path, 0, 0);
		// var imgWidth:Float = FlxG.width / data.width;
		// var imgHeight:Float = FlxG.height / data.height;
		// var scale:Float = imgWidth <= imgHeight ? imgWidth : imgHeight;
		// var sprite:FlxGifSprite = new FlxGifSprite(spritePath, 0, 0, Std.int(imgWidth), Std.int(imgHeight));

		// Cap the scale at x1
		// if (scale > 1)
		// 	scale = 1;

		// sprite.makeGraphic(Std.int(data.width * scale), Std.int(data.width * scale), FlxColor.TRANSPARENT);

		// var data2:BitmapData = sprite.pixels.clone();
		// var matrix:Matrix = new Matrix();
		// matrix.identity();
		// matrix.scale(scale, scale);
		// data2.fillRect(data2.rect, FlxColor.TRANSPARENT);
		// data2.draw(data, matrix, null, null, null, true);
		// sprite.pixels = data2;

		hscriptSprite.set(toBeCalled, sprite);
		trace("new " + toBeCalled + " GIF Sprite added \n" + Std.string(hscriptSprite.get(toBeCalled)));
		// and I quote:
		// shitty layering but it works!
		@:privateAccess
		{
			if (drawBehind)
			{
				PlayState.instance.removeObject(PlayState.gf);
				PlayState.instance.removeObject(PlayState.boyfriend);
				PlayState.instance.removeObject(PlayState.dad);
			}
			PlayState.instance.addObject(sprite);
			if (drawBehind)
			{
				PlayState.instance.addObject(PlayState.gf);
				PlayState.instance.addObject(PlayState.boyfriend);
				PlayState.instance.addObject(PlayState.dad);
			}
		}
		return toBeCalled;
	}

	function makeAnimatedHscriptSprite(spritePath:String, names:Array<String>, prefixes:Array<String>, startAnim:String, id:String, imageFolder:Bool = false,
			?library:String = '')
	{
		// pre lowercasing the song name (makeAnimatedLuaSprite)
		// var songLowercase = StringTools.replace(PlayState.SONG.songId, " ", "-").toLowerCase();
		var songLowercase = PlayState.SONG.songId;
		// switch (songLowercase)
		// {
		// 	case 'dad-battle':
		// 		songLowercase = 'dadbattle';
		// 	case 'philly-nice':
		// 		songLowercase = 'philly';
		// }
		var convertingPath = "assets/" + (imageFolder ? (library != null && library != '' ? library + "/" : '') + "images" : "data/songs" + songLowercase);
		// var path = #if !mobile Asset2File.getPath("assets/data/" + songLowercase) #else "assets/data/" + songLowercase #end;
		var path = #if !mobile Asset2File.getPath(convertingPath) #else convertingPath #end;

		#if sys
		if (PlayState.isSM)
			path = PlayState.pathToSm;
		#end
		trace(path);

		var data:BitmapData = BitmapData.fromFile(#if !mobile path + "/" + spritePath + ".png" #else Asset2File.getPath(path + "/" + spritePath + ".png") #end
		);

		var sprite:FlxSprite = new FlxSprite(0, 0);

		// sprite.frames = FlxAtlasFrames.fromSparrow(FlxGraphic.fromBitmapData(data), Sys.getCwd() + "assets/data/" + songLowercase + "/" + spritePath + ".xml");
		sprite.frames = FlxAtlasFrames.fromSparrow(FlxGraphic.fromBitmapData(data), Paths.xml(songLowercase + "/" + spritePath));

		trace(sprite.frames.frames.length);

		for (p in 0...names.length)
		{
			var i = names[p];
			var ii = prefixes[p];
			sprite.animation.addByPrefix(i, ii, 24, false);
		}

		hscriptSprite.set(id, sprite);

		PlayState.instance.addObject(sprite);

		sprite.animation.play(startAnim);
		return id;
	}

	function getActorByName(id:String):Dynamic
	{
		// pre defined names
		switch (id)
		{
			case 'boyfriend':
				@:privateAccess
				return PlayState.boyfriend;
			case 'girlfriend':
				@:privateAccess
				return PlayState.gf;
			case 'dad':
				@:privateAccess
				return PlayState.dad;
		}
		// hscript objects or what ever
		if (hscriptSprite.get(id) == null)
		{
			if (Std.parseInt(id) == null)
				return Reflect.getProperty(PlayState.instance, id);
			return PlayState.PlayState.strumLineNotes.members[Std.parseInt(id)];
		}
		return hscriptSprite.get(id);
	}

	// JOELwindows7: BulbyVR get actor
	function getHaxeActor(name:String):Dynamic
	{
		switch (name)
		{
			case "boyfriend" | "bf":
				return PlayState.boyfriend;
			case "girlfriend" | "gf":
				return PlayState.gf;
			case "dad":
				return PlayState.dad;
			default:
				return PlayState.strumLineNotes.members[Std.parseInt(name)];
		}
	}

	function changeDadCharacter(id:String)
	{
		var olddadx = PlayState.dad.x;
		var olddady = PlayState.dad.y;
		PlayState.instance.removeObject(PlayState.dad);
		PlayState.dad = new Character(olddadx, olddady, id);
		PlayState.instance.addObject(PlayState.dad);
		PlayState.instance.iconP2.animation.play(id);
	}

	function changeBoyfriendCharacter(id:String)
	{
		var oldboyfriendx = PlayState.boyfriend.x;
		var oldboyfriendy = PlayState.boyfriend.y;
		PlayState.instance.removeObject(PlayState.boyfriend);
		PlayState.boyfriend = new Boyfriend(oldboyfriendx, oldboyfriendy, id);
		PlayState.instance.addObject(PlayState.boyfriend);
		PlayState.instance.iconP2.animation.play(id);
	}

	// JOELwindows7: also change girlfriend yess
	function changeGirlfriendCharacter(id:String)
	{
		var oldgfx = PlayState.gf.x;
		var oldgfy = PlayState.gf.y;
		PlayState.instance.removeObject(PlayState.gf);
		PlayState.gf = new Character(oldgfx, oldgfy, id);
		PlayState.instance.addObject(PlayState.gf);
	}

	public static function createModchartState(rawMode:Bool = false, path:String = "", useHaxe:String = "modchart", useRetail:Bool = false):HaxeScriptState
	{
		return new HaxeScriptState(rawMode, path, useHaxe, useRetail);
	}

	public function die()
	{
		trace("Hscript: Eik serkat!");
		hscriptState.clear;
		prog = null;
		interp = null;
		parser = null;
		script = "";
		retailIsReady = false;
	}
}

/**
 * JOELwindows7: BulbyVR's FlxG filtering for safety reason.
 *
 */
class HscriptGlobals
{
	public static var VERSION = FlxG.VERSION;
	public static var autoPause(get, set):Bool;
	public static var bitmap(get, never):BitmapFrontEnd;
	// no bitmapLog
	public static var camera(get, set):FlxCamera;
	public static var cameras(get, never):CameraFrontEnd;
	// no console frontend
	// no debugger frontend
	public static var drawFramerate(get, set):Int;
	public static var elapsed(get, never):Float;
	public static var fixedTimestep(get, set):Bool;
	public static var fullscreen(get, set):Bool;
	public static var game(get, never):FlxGame;
	public static var gamepads(get, never):FlxGamepadManager;
	public static var height(get, never):Int;
	public static var initialHeight(get, never):Int;
	public static var initialWidth(get, never):Int;
	public static var initialZoom(get, never):Float;
	public static var inputs(get, never):InputFrontEnd;
	public static var keys(get, never):FlxKeyboard;
	public static var log(get, never):LogFrontEnd;
	public static var maxElapsed(get, set):Float;
	public static var mouse = FlxG.mouse;
	// no plugins
	public static var random = FlxG.random;
	public static var renderBlit(get, never):Bool;
	public static var renderMethod(get, never):FlxRenderMethod;
	public static var renderTile(get, never):Bool;
	// no save because there are other ways to access it and i don't trust you guys
	public static var sound(default, never):HscriptSoundFrontEndWrapper = new HscriptSoundFrontEndWrapper(FlxG.sound);
	public static var stage(get, never):Stage;
	public static var state(get, never):FlxState;
	public static var swipes(get, never):Array<FlxSwipe>; // added
	public static var timeScale(get, set):Float;
	public static var touches(get, never):Array<FlxTouch>; // added
	public static var updateFramerate(get, set):Int;
	// no vcr : )
	public static var watch(get, never):WatchFrontEnd; // added
	public static var width(get, never):Int;
	public static var worldBounds(get, never):FlxRect;
	public static var worldDivisions(get, set):Int;

	static function get_bitmap()
	{
		return FlxG.bitmap;
	}

	static function get_cameras()
	{
		return FlxG.cameras;
	}

	static function get_autoPause():Bool
	{
		return FlxG.autoPause;
	}

	static function set_autoPause(b:Bool):Bool
	{
		return FlxG.autoPause = b;
	}

	static function get_drawFramerate():Int
	{
		return FlxG.drawFramerate;
	}

	static function set_drawFramerate(b:Int):Int
	{
		return FlxG.drawFramerate = b;
	}

	static function get_elapsed():Float
	{
		return FlxG.elapsed;
	}

	static function get_fixedTimestep():Bool
	{
		return FlxG.fixedTimestep;
	}

	static function set_fixedTimestep(b:Bool):Bool
	{
		return FlxG.fixedTimestep = b;
	}

	static function get_fullscreen():Bool
	{
		return FlxG.fullscreen;
	}

	static function set_fullscreen(b:Bool):Bool
	{
		return FlxG.fullscreen = b;
	}

	static function get_height():Int
	{
		return FlxG.height;
	}

	static function get_initialHeight():Int
	{
		return FlxG.initialHeight;
	}

	static function get_camera():FlxCamera
	{
		return FlxG.camera;
	}

	static function set_camera(c:FlxCamera):FlxCamera
	{
		return FlxG.camera = c;
	}

	static function get_game():FlxGame
	{
		return FlxG.game;
	}

	static function get_gamepads():FlxGamepadManager
	{
		return FlxG.gamepads;
	}

	static function get_initialWidth():Int
	{
		return FlxG.initialWidth;
	}

	static function get_initialZoom():Float
	{
		return FlxG.initialZoom;
	}

	static function get_inputs()
	{
		return FlxG.inputs;
	}

	static function get_keys()
	{
		return FlxG.keys;
	}

	static function get_log()
	{
		return FlxG.log;
	}

	static function set_maxElapsed(s)
	{
		return FlxG.maxElapsed = s;
	}

	static function get_maxElapsed()
	{
		return FlxG.maxElapsed;
	}

	static function get_renderBlit()
	{
		return FlxG.renderBlit;
	}

	static function get_renderMethod()
	{
		return FlxG.renderMethod;
	}

	static function get_renderTile()
	{
		return FlxG.renderTile;
	}

	static function get_stage()
	{
		return FlxG.stage;
	}

	static function get_state()
	{
		return FlxG.state;
	}

	static function get_swipes():Array<FlxSwipe>
	{
		return FlxG.swipes;
	}

	static function set_timeScale(s)
	{
		return FlxG.timeScale = s;
	}

	static function get_timeScale()
	{
		return FlxG.timeScale;
	}

	static function get_touches()
	{
		return FlxG.touches.list;
	}

	static function set_updateFramerate(s)
	{
		return FlxG.updateFramerate = s;
	}

	static function get_updateFramerate()
	{
		return FlxG.updateFramerate;
	}

	static function get_watch()
	{
		return FlxG.watch;
	}

	static function get_width()
	{
		return FlxG.width;
	}

	static function get_worldBounds()
	{
		return FlxG.worldBounds;
	}

	static function get_worldDivisions()
	{
		return FlxG.worldDivisions;
	}

	static function set_worldDivisions(s)
	{
		return FlxG.worldDivisions = s;
	}

	public static function addChildBelowMouse<T:DisplayObject>(Child:T, IndexModifier:Int = 0):T
	{
		return FlxG.addChildBelowMouse(Child, IndexModifier);
	}

	public static function addPostProcess(postProcess)
	{
		return FlxG.addPostProcess(postProcess);
	}

	public static function collide(?ObjectOrGroup1, ?ObjectOrGroup2, ?NotifyCallback)
	{
		return FlxG.collide(ObjectOrGroup1, ObjectOrGroup2, NotifyCallback);
	}

	// no open url because i don't trust you guys

	public static function overlap(?ObjectOrGroup1, ?ObjectOrGroup2, ?NotifyCallback, ?ProcessCallback)
	{
		return FlxG.overlap(ObjectOrGroup1, ObjectOrGroup2, NotifyCallback, ProcessCallback);
	}

	public static function pixelPerfectOverlap(Sprite1, Sprite2, AlphaTolerance = 255, ?Camera)
	{
		return FlxG.pixelPerfectOverlap(Sprite1, Sprite2, AlphaTolerance, Camera);
	}

	public static function removeChild<T:DisplayObject>(Child:T):T
	{
		return FlxG.removeChild(Child);
	}

	public static function removePostProcess(postProcess)
	{
		FlxG.removePostProcess(postProcess);
	}

	// no reset game or reset state because i don't trust you guys
	public static function resizeGame(Width, Height)
	{
		FlxG.resizeGame(Width, Height);
	}

	public static function resizeWindow(Width, Height)
	{
		FlxG.resizeWindow(Width, Height);
	}

	// no switch state because i don't trust you guys
}

/**
 * JOELwindows7: BulbyVR's Sound wrapper filter
 */
class HscriptSoundFrontEndWrapper
{
	var wrapping:SoundFrontEnd;

	public var defaultMusicGroup(get, set):FlxSoundGroup;
	public var defaultSoundGroup(get, set):FlxSoundGroup;
	public var list(get, never):FlxTypedGroup<FlxSound>;
	public var music(get, set):FlxSound;

	// no mute keys because why do you need that
	// no muted because i don't trust you guys
	// no soundtray enabled because i'm lazy
	// no volume because i don't trust you guys
	function get_defaultMusicGroup()
	{
		return wrapping.defaultMusicGroup;
	}

	function set_defaultMusicGroup(a)
	{
		return wrapping.defaultMusicGroup = a;
	}

	function get_defaultSoundGroup()
	{
		return wrapping.defaultSoundGroup;
	}

	function set_defaultSoundGroup(a)
	{
		return wrapping.defaultSoundGroup = a;
	}

	function get_list()
	{
		return wrapping.list;
	}

	function get_music()
	{
		return wrapping.music;
	}

	function set_music(a)
	{
		return wrapping.music = a;
	}

	public function load(?EmbeddedSound:FlxSoundAsset, Volume = 1.0, Looped = false, ?Group, AutoDestroy = false, AutoPlay = false, ?URL, ?OnComplete)
	{
		if ((EmbeddedSound is String))
		{
			// var sound = FNFAssets.getSound(EmbeddedSound);
			var sound = Paths.sound(EmbeddedSound);
			return wrapping.load(sound, Volume, Looped, Group, AutoDestroy, AutoPlay, URL, OnComplete);
		}
		return wrapping.load(EmbeddedSound, Volume, Looped, Group, AutoDestroy, AutoPlay, URL, OnComplete);
	}

	public function pause()
	{
		wrapping.pause();
	}

	public function play(EmbeddedSound:FlxSoundAsset, Volume = 1.0, Looped = false, ?Group, AutoDestroy = true, ?OnComplete)
	{
		if ((EmbeddedSound is String))
		{
			// var sound = FNFAssets.getSound(EmbeddedSound);
			var sound = Paths.sound(EmbeddedSound);
			return wrapping.play(sound, Volume, Looped, Group, AutoDestroy, OnComplete);
		}
		return wrapping.play(EmbeddedSound, Volume, Looped, Group, AutoDestroy, OnComplete);
	}

	public function playMusic(Music:FlxSoundAsset, Volume = 1.0, Looped = true, ?Group)
	{
		if ((Music is String))
		{
			// var sound = FNFAssets.getSound(Music);
			var sound = Paths.music(Music);
			wrapping.playMusic(sound, Volume, Looped, Group);
			return;
		}
		wrapping.playMusic(Music, Volume, Looped, Group);
	}

	public function resume()
	{
		wrapping.resume();
	}

	public function new(wrap:SoundFrontEnd)
	{
		wrapping = wrap;
	}
}

/**
 * Base for the modchart classes to extend from.
 * inspire the content of function from Kade Engine's & BulbyVR's
 * here link https://github.com/TheDrawingCoder-Gamer/Funkin/blob/master/assets/data/tutorial/modchart.hscript
 * @author JOELwindows7
 */
class HaxeModBase
{
	var difficulty:Int;
}
