package;

import DokiDoki;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.Assets as OpenFlAssets;
import haxe.Json;

using StringTools;

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var animInterrupt:Map<String, Bool>;
	public var animNext:Map<String, String>;
	public var animDanced:Map<String, Bool>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';
	public var barColor:FlxColor;
	public var colorTween:FlxTween; // JOELwindows7: Psyched color tween lol! what a big surpise.

	public var holdTimer:Float = 0;

	public var name:String = 'Boyfriend'; // JOELwindows7: JSON character name, with detaile.
	public var displayName:String = 'Boyfriend'; // JOELwindows7: for showcase name on screen rather than ID
	public var replacesGF:Bool;
	public var hasTrail:Bool;
	public var isDancing:Bool;
	public var holdLength:Float;
	public var charPos:Array<Int>;
	public var camPos:Array<Int>;
	public var camFollow:Array<Int>;

	public var heartOrgans:Array<SwagHeart>; // JOELwindows7: for the 🫀 hearts. yep, Shinon51788 Doki Doki dance thingy. turns out either:

	// - more than one characters at once in this class instance, which of course has 1 heart each.
	// - more than one hearts at once in this class instance, which yess they do exists.

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);

		barColor = isPlayer ? 0xFF66FF33 : 0xFFFF0000;
		animOffsets = new Map<String, Array<Dynamic>>();
		animInterrupt = new Map<String, Bool>();
		animNext = new Map<String, String>();
		animDanced = new Map<String, Bool>();
		curCharacter = character;
		this.isPlayer = isPlayer;
		this.jantungInstances = new Array<JantungOrgan>(); // JOELwindows7: first, initialize the thorax cavity/ies.

		// JOELwindows7: bruh you forgot to lowercase curCharacter case name. that's why it crash if I capital one of the letter.
		// please toLowerCase, should I do that?

		// PAIN IS TEMPORARY, GLORY IS FOREVER. LOL WINTERGATAN

		parseDataFile();

		if (isPlayer && frames != null)
		{
			flipX = !flipX;

			// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('bf'))
			{
				// var animArray
				var oldRight = animation.getByName('singRIGHT').frames;
				animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
				animation.getByName('singLEFT').frames = oldRight;

				// IF THEY HAVE MISS ANIMATIONS??
				if (animation.getByName('singRIGHTmiss') != null)
				{
					var oldMiss = animation.getByName('singRIGHTmiss').frames;
					animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
					animation.getByName('singLEFTmiss').frames = oldMiss;
				}
			}
		}
	}

	function parseDataFile()
	{
		Debug.logInfo('Generating character (${curCharacter}) from JSON data...');

		// Load the data from JSON and cast it to a struct we can easily read.
		var jsonData = Paths.loadJSON('characters/${curCharacter}');
		if (jsonData == null)
		{
			Debug.logError('Failed to parse JSON data for character ${curCharacter}');
			return;
		}

		var data:CharacterData = cast jsonData;
		var tex:FlxAtlasFrames;

		// to be deleted
		name = data.name; // JOELwindows7: name it. wow, Kade and friends prepared that already lol! thancc Eric Millyoja yey cool and good!
		displayName = data.displayName;
		if (data.displayName == null) // JOELwindows7: If displayName is empty, copy from name
			displayName = name;
		// tex:FlxAtlasFrames = Paths.getSparrowAtlas(data.asset, 'shared');
		// end to be deleted

		if (data.usePackerAtlas)
			tex = Paths.getPackerAtlas(data.asset, 'shared');
		else
			tex = Paths.getSparrowAtlas(data.asset, 'shared');

		frames = tex;
		if (frames != null)
			for (anim in data.animations)
			{
				var frameRate = anim.frameRate == null ? 24 : anim.frameRate;
				var looped = anim.looped == null ? false : anim.looped;
				var flipX = anim.flipX == null ? false : anim.flipX;
				var flipY = anim.flipY == null ? false : anim.flipY;

				if (anim.frameIndices != null)
				{
					animation.addByIndices(anim.name, anim.prefix, anim.frameIndices, "", frameRate, looped, flipX, flipY);
				}
				else
				{
					animation.addByPrefix(anim.name, anim.prefix, frameRate, looped, flipX, flipY);
				}

				animOffsets[anim.name] = anim.offsets == null ? [0, 0] : anim.offsets;
				animInterrupt[anim.name] = anim.interrupt == null ? true : anim.interrupt;

				if (data.isDancing && anim.isDanced != null)
					animDanced[anim.name] = anim.isDanced;

				if (anim.nextAnim != null)
					animNext[anim.name] = anim.nextAnim;
			}

		this.replacesGF = data.replacesGF == null ? false : data.replacesGF;
		this.hasTrail = data.hasTrail == null ? false : data.hasTrail;
		this.isDancing = data.isDancing == null ? false : data.isDancing;
		this.charPos = data.charPos == null ? [0, 0] : data.charPos;
		this.camPos = data.camPos == null ? [0, 0] : data.camPos;
		this.camFollow = data.camFollow == null ? [0, 0] : data.camFollow;
		this.holdLength = data.holdLength == null ? 4 : data.holdLength;
		this.heartOrgans = data.heartOrgans == null ? [Perkedel.NULL_HEART_SPEC] : data.heartOrgans; // JOELwindows7: yess, the hearts & each specification!

		flipX = data.flipX == null ? false : data.flipX;

		if (data.scale != null)
		{
			setGraphicSize(Std.int(width * data.scale));
			updateHitbox();
		}

		antialiasing = data.antialiasing == null ? FlxG.save.data.antialiasing : data.antialiasing;

		barColor = FlxColor.fromString(data.barColor);

		playAnim(data.startingAnim);

		// JOELwindows7: fill out heart organs!
		for (thisSpec in heartOrgans)
		{
			var aHeart = new JantungOrgan(thisSpec);
			jantungInstances.push(aHeart);
		}
	}

	override function update(elapsed:Float)
	{
		if (!isPlayer)
		{
			if (animation.curAnim.name.startsWith('sing'))
				holdTimer += elapsed;

			if (holdTimer >= Conductor.stepCrochet * holdLength * 0.001)
			{
				if (isDancing)
					playAnim('danceLeft'); // overridden by dance correctly later
				dance();
				holdTimer = 0;
			}
		}

		if (!debugMode)
		{
			var nextAnim = animNext.get(animation.curAnim.name);
			var forceDanced = animDanced.get(animation.curAnim.name);

			// case 'gf' | 'gf-ht' | 'gf-covid' | 'gf-placeholder':
			// JOELwindows7: okay idk how to make this work at all!
			if (nextAnim != null && animation.curAnim.finished)
			{
				if (isDancing && forceDanced != null)
					danced = forceDanced;
			}
		}

		super.update(elapsed);

		// JOELwindows7: update heart organs!
		if (jantungInstances != null)
			for (each in jantungInstances)
			{
				if (each != null)
					each.update(elapsed);
			}
	}

	private var danced:Bool = false;
	private var jantungInstances:Array<JantungOrgan>; // JOELwindows7: bunch of 🫀 heart organs object instances.

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance(forced:Bool = false, altAnim:Bool = false)
	{
		if (!debugMode)
		{
			var canInterrupt = animInterrupt.get(animation.curAnim.name);

			if (canInterrupt)
			{
				// case 'gf' | 'gf-christmas' | 'gf-car' | 'gf-pixel' | 'gf-covid' | 'gf-placeholder' | 'gf-ht':
				if (isDancing)
				{
					// JOELwindows7: copy this if from above case
					// well we can just add OR to this.
					// if (!animation.curAnim.name.startsWith('hair') && !animation.curAnim.name.startsWith('sing'))
					//
					danced = !danced;

					if (altAnim && animation.getByName('danceRight-alt') != null && animation.getByName('danceLeft-alt') != null)
					{
						if (danced)
							playAnim('danceRight-alt');
						else
							playAnim('danceLeft-alt');
					}
					else
					{
						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}
				}
				else
				{
					if (altAnim && animation.getByName('idle-alt') != null)
						playAnim('idle-alt', forced);
					else
						playAnim('idle', forced);
				}
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if (AnimName.endsWith('alt') && animation.getByName(AnimName) == null)
		{
			#if debug
			FlxG.log.warn(['Such alt animation doesnt exist: ' + AnimName]);
			#end
			AnimName = AnimName.split('-')[0];
		}

		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);

		if (curCharacter == 'gf' || curCharacter == 'gf-ht' || curCharacter == 'gf-placeholder')
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

	// JOELwindows7: heart functions!
	public function stimulateHeart(whichOne:Int = -1, typeOfStimulate:HeartStimulateType, givenValue:Float = 0)
	{
		if (whichOne < 0)
		{
			// all of them
			for (each in jantungInstances)
			{
				each.stimulate(typeOfStimulate, givenValue);
			}
		}
		else
		{
			// one of selected
			try
			{
				jantungInstances[whichOne].stimulate(typeOfStimulate, givenValue);
			}
			catch (e)
			{
				Debug.logError("WERROR! Heart organ No. "
					+ Std.string(whichOne)
					+ " not found while attempting to: Stimulate!\n"
					+ e
					+ ": "
					+ e.message);
			}
		}
	}

	public function successfullyStep(whichOne:Int = -1, rewards:Int = 1)
	{
		if (whichOne < 0)
		{
			// all of them
			for (each in jantungInstances)
			{
				each.successfullyStep(rewards);
			}
		}
		else
		{
			// one of selected
			try
			{
				jantungInstances[whichOne].successfullyStep(rewards);
			}
			catch (e)
			{
				Debug.logError("WERROR 404! Heart organ No. " + Std.string(whichOne) + " not found while attempting to: Succesfully Step!\n" + e + ": "
					+ e.message);
			}
		}
	}

	public function getHeartRate(which:Int = -1):Float
	{
		if (which < 0)
		{
			// JOELwindows7: GitHub copilot coded this! average heart rate of all heart organs inside! lmao!
			var total:Float = 0;
			for (each in jantungInstances)
			{
				total += each.getHeartRate();
			}
			return total / jantungInstances.length;
		}
		try
		{
			return jantungInstances[which].getHeartRate();
		}
		catch (e)
		{
			Debug.logError("WERROR 404! Heart organ No. "
				+ Std.string(which)
				+ " not found while attempting to: Get heart rate!\n"
				+ e
				+ ": "
				+ e.message);
		}
		return -1;
	}

	public function getHeartTier(which:Int = 0):Int
	{
		if (which < 0)
		{
			// JOELwindows7: GitHub copilot coded this! average heart tier of all heart organs inside! lmao!
			var total:Int = 0;
			for (each in jantungInstances)
			{
				total += each.getHeartTier();
			}
			return Std.int(total / jantungInstances.length);
		}
		try
		{
			return jantungInstances[which].getHeartTier();
		}
		catch (e)
		{
			Debug.logError("WERROR 404! Heart organ No. "
				+ Std.string(which)
				+ " not found while attempting to: Get heart tier!\n"
				+ e
				+ ": "
				+ e.message);
		}
		return -3;
	}
}

typedef CharacterData =
{
	var name:String;
	var ?displayName:String; // JOELwindows7: If they have special name, reregular name, or whatever it should be displayed as.
	var asset:String;
	var startingAnim:String;

	var ?charPos:Array<Int>;
	var ?camPos:Array<Int>;
	var ?camFollow:Array<Int>;
	var ?holdLength:Float;
	var ?heartOrgans:Array<SwagHeart>; // JOELwindows7: Array of heart organs inside this Character.

	/**
	 * The color of this character's health bar.
	 */
	var barColor:String;

	var animations:Array<AnimationData>;

	/**
	 * Whether this character is flipped horizontally.
	 * @default false
	 */
	var ?flipX:Bool;

	/**
	 * The scale of this character.
	 * Pixel characters typically use 6.
	 * @default 1
	 */
	var ?scale:Int;

	/**
	 * Whether this character has antialiasing.
	 * @default true
	 */
	var ?antialiasing:Bool;

	/**
	 * Whether this character uses PackerAtlas.
	 * @default false
	 */
	var ?usePackerAtlas:Bool;

	/**
	 * Whether this character uses a dancing idle instead of a regular idle.
	 * (ex. gf, spooky)
	 * @default false
	 */
	var ?isDancing:Bool;

	/**
	 * Whether this character has a trail behind them.
	 * @default false
	 */
	var ?hasTrail:Bool;

	/**
	 * Whether this character replaces gf if they are set as dad.
	 * @default false
	 */
	var ?replacesGF:Bool;
}

typedef AnimationData =
{
	var name:String;
	var prefix:String;
	var ?offsets:Array<Int>;

	/**
	 * Whether this animation is looped.
	 * @default false
	 */
	var ?looped:Bool;

	var ?flipX:Bool;
	var ?flipY:Bool;

	/**
	 * The frame rate of this animation.
	 		* @default 24
	 */
	var ?frameRate:Int;

	var ?frameIndices:Array<Int>;

	/**
	 * Whether this animation can be interrupted by the dance function.
	 * @default true
	 */
	var ?interrupt:Bool;

	/**
	 * The animation that this animation will go to after it is finished.
	 */
	var ?nextAnim:String;

	/**
	 * Whether this animation sets danced to true or false.
	 * Only works for characters with isDancing enabled.
	 */
	var ?isDanced:Bool;
}
