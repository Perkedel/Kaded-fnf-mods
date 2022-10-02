package;

import flixel.util.FlxSort;
import Section;
import flixel.addons.ui.FlxUISprite;
import DokiDoki;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.Assets as OpenFlAssets;
import haxe.Json;

using StringTools;

// JOELwindows7: hey, should we do that here too as well??
class Character extends FlxUISprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var animInterrupt:Map<String, Bool>;
	public var animNext:Map<String, String>;
	public var animDanced:Map<String, Bool>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var forceIcon:Bool = false; // JOELwindows7: force the health icon to be this exact icon name, skipping filter.
	public var curCharacter:String = 'bf';
	public var barColor:FlxColor;
	public var colorTween:FlxTween; // JOELwindows7: Psyched color tween lol! what a big surpise.

	public var holdTimer:Float = 0;

	// public var name:String = 'Boyfriend'; // JOELwindows7: JSON character name, with detaile. Oh, there's already built in.
	public var displayName:String = 'Boyfriend'; // JOELwindows7: for showcase name on screen rather than ID
	public var replacesGF:Bool;
	public var hasTrail:Bool;
	public var isDancing:Bool;
	public var holdLength:Float;
	public var charPos:Array<Int>;
	public var camPos:Array<Int>;
	public var camFollow:Array<Int>;

	// JOELwindows7: death character
	public var deathCharacter:String = 'bf';
	public var deathCharacterIsSameAsThis:Bool = true;

	public var heartOrgans:Array<SwagHeart>; // JOELwindows7: for the 🫀 hearts. yep, Shinon51788 Doki Doki dance thingy. turns out either:
	public var deathSoundPaths:Array<DeathSoundPath>; // JOELwindows7: play these death sounds defined in this list on the asset sound folders.
	public var randomizedDeathSoundPaths:Array<RandomizedDeathSoundPath>; // JOELwindows7: same but each bit plays one of the random variations
	public var riseUpAgainSoundPaths:Array<DeathSoundPath>; // JOELwindows7: press retry
	public var randomizedRiseUpAgainSoundPaths:Array<RandomizedDeathSoundPath>; // JOELwindows7: and random one each bit plays one of the random variations

	public var font:String; // JOELwindows7: name of the font for dialoguebox. e.g. `Pixel Arial 11 Bold` or `Ubuntu Bold` etc.
	public var fontDrop:String; // JOELwindows7: & for the text behind
	public var fontColor:String; // JOELwindows7: dialog font color
	public var fontColorDrop:String; // JOELwindows7: and the drop color, for text behind.
	public var dialogueChatSoundPaths:Array<String>; // JOELwindows7: array of dialogue chat sound paths.
	public var dialogueChatSoundVolume:Float; // JOELwindows7: volume for all sounds

	// - more than one characters at once in this class instance, which of course has 1 heart each.
	// - more than one hearts at once in this class instance, which yess they do exists.
	public var externalBeating:Bool = false;

	public static var animationNotes:Array<Note> = []; // JOELwindows7: BOLO animation note contains.

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

		// JOELwindows7: INCOMING BOLO RETHOUGHT STUFFS
		// https://github.com/BoloVEVO/Kade-Engine-Public/blame/stable/source/Character.hx
		// Load the data from JSON and cast it to a struct we can easily read.
		var jsonData = Paths.loadJSON('characters/${curCharacter}');
		if (jsonData == null)
		{
			Debug.logError('Failed to parse JSON data for character ${curCharacter}');
			// JOELwindows7: BOLO has habbit to unfullscreen for alert window. idk why tho..
			// if (FlxG.fullscreen)
			// 	FlxG.fullscreen = !FlxG.fullscreen;
			if (isPlayer)
			{
				Debug.displayAlert('Kade Engine JSON Parser', 'Failed to parse JSON data for character  ${curCharacter}. Loading default boyfriend...');
				jsonData = Paths.loadJSON('characters/bf');
			}
			else if (replacesGF)
			{
				Debug.displayAlert('Kade Engine JSON Parser', 'Failed to parse JSON data for character  ${curCharacter}. Loading default girlfriend...');
				jsonData = Paths.loadJSON('characters/gf');
			}
			else
			{
				Debug.displayAlert('Kade Engine JSON Parser', 'Failed to parse JSON data for character  ${curCharacter}. Loading default opponent...');
				jsonData = Paths.loadJSON('characters/dad');
			}
			// return; // JOELwindows7: no longer needed! we already just loaded emergency fallbacks!!
		}

		var data:CharacterData = cast jsonData;

		// JOELwindows7: BOLO optimizener. uuhh, idk, why.. we have heart organ things here!
		// var tex:FlxAtlasFrames;
		var tex:FlxFramesCollection;

		// to be deleted
		name = data.name; // JOELwindows7: name it. wow, Kade and friends prepared that already lol! thancc Eric Millyoja yey cool and good!
		displayName = data.displayName; // JOELwindows7: separate name for on screen because `name` can have variation descriptors.
		if (data.displayName == null) // JOELwindows7: If displayName is empty, copy from name
			displayName = name;
		// tex:FlxAtlasFrames = Paths.getSparrowAtlas(data.asset, 'shared');
		// end to be deleted

		/*
			if (data.usePackerAtlas)
				tex = Paths.getPackerAtlas(data.asset, 'shared');
			else
				tex = Paths.getSparrowAtlas(data.asset, 'shared');
		 */
		// JOELwindows7: NEW BOLO types of atlas!
		switch (data.AtlasType)
		{
			case 'PackerAtlas':
				tex = Paths.getPackerAtlas(data.asset, 'shared');
			case 'TextureAtlas':
				tex = Paths.getTextureAtlas(data.asset, 'shared');
			case 'JsonAtlas':
				tex = Paths.getJSONAtlas(data.asset, 'shared');
			default: // SparrowAtlas
				tex = Paths.getSparrowAtlas(data.asset, 'shared');
		}

		frames = tex;
		if (frames != null)
			for (anim in data.animations)
			{
				var frameRate = anim.frameRate == null ? 24 : anim.frameRate;
				var looped = anim.looped == null ? false : anim.looped;
				var flipX = anim.flipX == null ? false : anim.flipX;
				var flipY = anim.flipY == null ? false : anim.flipY;

				// JOELwindows7: BOLO. frameRate times song multiplier right now.
				if (anim.frameIndices != null)
				{
					animation.addByIndices(anim.name, anim.prefix, anim.frameIndices, "", Std.int(frameRate * PlayState.songMultiplier), looped, flipX, flipY);
				}
				else
				{
					animation.addByPrefix(anim.name, anim.prefix, Std.int(frameRate * PlayState.songMultiplier), looped, flipX, flipY);
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
		this.forceIcon = data.forceIcon == null ? false : data.forceIcon; // JOELwindows7: force icon to be exact this.
		this.charPos = data.charPos == null ? [0, 0] : data.charPos;
		this.camPos = data.camPos == null ? [0, 0] : data.camPos;
		this.camFollow = data.camFollow == null ? [0, 0] : data.camFollow;
		this.holdLength = data.holdLength == null ? 4 : data.holdLength;
		// JOELwindows7: chec death is same with this or not.
		this.deathCharacterIsSameAsThis = data.deathCharacterIsSameAsThis == null ? Perkedel.NULL_DEATH_CHARACTER_IS_AS_SAME_AS_THIS : data.deathCharacterIsSameAsThis;
		this.deathCharacter = data.deathCharacter == null ? Perkedel.NULL_DEATH_CHARACTER : data.deathCharacter;
		this.deathSoundPaths = data.deathSoundPaths == null ? Perkedel.NULL_DEATH_SOUND_PATHS : data.deathSoundPaths;
		this.randomizedDeathSoundPaths = data.randomizedDeathSoundPaths == null ? Perkedel.NULL_RANDOMIZED_DEATH_SOUND_PATHS : data.randomizedDeathSoundPaths;
		this.riseUpAgainSoundPaths = data.riseUpAgainSoundPaths == null ? Perkedel.NULL_RISE_UP_AGAIN_SOUND_PATHS : data.riseUpAgainSoundPaths;
		this.randomizedRiseUpAgainSoundPaths = data.randomizedRiseUpAgainSoundPaths == null ? Perkedel.NULL_RANDOMIZED_DEATH_SOUND_PATHS : data.randomizedRiseUpAgainSoundPaths;
		this.heartOrgans = data.heartOrgans == null ? [Perkedel.NULL_HEART_SPEC] : data.heartOrgans; // JOELwindows7: yess, the hearts & each specification!
		this.font = data.font == null ? Perkedel.NULL_DIALOGUE_FONT : data.font;
		this.fontDrop = data.fontDrop == null ? Perkedel.NULL_DIALOGUE_FONT_DROP : data.fontDrop;
		this.fontColor = data.fontColor == null ? Perkedel.NULL_DIALOGUE_FONT_COLOR : data.fontColor;
		this.fontColorDrop = data.fontColorDrop == null ? Perkedel.NULL_DIALOGUE_FONT_COLOR_DROP : data.fontColorDrop;
		this.dialogueChatSoundPaths = data.dialogueChatSoundPaths == null ? Perkedel.NULL_DIALOGUE_SOUND_PATHS : data.dialogueChatSoundPaths;
		this.dialogueChatSoundVolume = data.dialogueChatSoundVolume == null ? Perkedel.NULL_DIALOGUE_SOUND_VOLUME : data.dialogueChatSoundVolume;

		flipX = data.flipX == null ? false : data.flipX;

		if (data.scale != null)
		{
			setGraphicSize(Std.int(width * data.scale));
			updateHitbox();
		}

		antialiasing = data.antialiasing == null ? FlxG.save.data.antialiasing : data.antialiasing;

		playAnim(data.startingAnim);
		// end optimize

		barColor = FlxColor.fromString(data.barColor);

		// JOELwindows7: fill out heart organs!
		for (thisSpec in heartOrgans)
		{
			var aHeart = new JantungOrgan(thisSpec);
			jantungInstances.push(aHeart);
		}
	}

	override function update(elapsed:Float)
	{
		// JOELwindows7: BOLO's safety bruh!
		// https://github.com/BoloVEVO/Kade-Engine-Public/blame/stable/source/Character.hx
		if (animation.curAnim != null)
		{
			if (!isPlayer)
			{
				if (!PlayStateChangeables.opponentMode) // JOELwindows7: BOLO opponent mode check moved out here
				{
				if (animation.curAnim.name.startsWith('sing'))
					holdTimer += elapsed;

				if (holdTimer >= Conductor.stepCrochet * holdLength * 0.001)
				{
					// JOELwindows7: BOLO's opponent mode check. if not opponent mode then dance
					if (!PlayStateChangeables.opponentMode)
					{
						/*
							if (isDancing)
								playAnim('danceLeft'); // overridden by dance correctly later
						 */
						dance();
					}
					holdTimer = 0;
				}

				// JOELwindows7: BOLO's return back to idle when not player.
				if (animation.curAnim.name.endsWith('miss') && animation.curAnim.finished && !debugMode)
				{
					// playAnim('idle', true, false, 10); // perhaps no, don't, I guess..
				}
				} else {
					// JOELwindows7: BOLO opponent mode
					if (animation.curAnim.name.startsWith('sing'))
						holdTimer += elapsed;
					else
						holdTimer = 0;

					if (animation.curAnim.name.endsWith('miss') && animation.curAnim.finished && !debugMode)
						dance();

					if (animation.curAnim.name == 'firstDeath' && animation.curAnim.finished)
						playAnim('deathLoop');
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
					playAnim(nextAnim); // JOELwindows7: BOLO play next anim!
				}
				else
				{
					// if (isDancing || animation.curAnim.finished)
					// 	dance();
					// animation.curAnim
				}
			}

			// JOELwindows7: BOLO additional special
			switch (curCharacter)
			{
				case 'pico-speaker':
					if (animationNotes.length > 0 && Conductor.songPosition >= animationNotes[0].strumTime)
					{
						var noteData:Int = 1;
						if (2 <= animationNotes[0].noteData)
							noteData = 3;

						noteData += FlxG.random.int(0, 1);
						playAnim('shoot' + noteData, true);
						animationNotes.shift();
					}
			}
		}
		else
		{
			// JOELwindows7: curAnim is null bruh
		}

		super.update(elapsed);

		if (!externalBeating)
			updateHeartbeats(elapsed); // JOELwindows7: DOESN'T UPDATE! ATTACH TO STATE'S UPDATE INSTEAD!! nvm. it works.
		// okay don't I notice faster the song, faster character, faster heart.
		// slower song, slower character, slower heart.
		// no no no! that's not how heart organ works!
	}

	/**
	 * Turns out, the `update` function above doesn't work. 
	 * try manually attach this update method into state's update method we are right now instead.
	 * wait, I guess I've fixed it lol!
	 * ever mind! the character speed affects! go attach it!
	 * @author JOELwindows7
	 * @param elapsed handover elapsed
	 */
	function updateHeartbeats(elapsed:Float)
	{
		// JOELwindows7: update heart organs!
		if (jantungInstances != null)
			for (each in jantungInstances)
			{
				// if (each != null)
				each.update(elapsed);
			}
	}

	/**
	 * Send heart update frame & elapsed to here.
	 * Please call this method in your state's `update` method 
	 * complete with `elapsed` argument variable to this `elapsed` argument.
	 * By accessing this function, you enable external clock.
	 * this will disable self heartbeat management.
	 * to disable external clock & let heart management does itself again, set `reself` to true.
	 * @param elapsed handover elapsed
	 * @param reself whether to reenable own heart management system again
	 */
	public function doHeartbeats(elapsed:Float, reself:Bool = false)
	{
		externalBeating = !reself;
		updateHeartbeats(elapsed);
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
			// JOELwindows7: BOLO nested safety pls!
			if (!PlayStateChangeables.optimize)
			{
				if (animation.curAnim != null)
				{
					// trace('${curCharacter} Dancening force ${forced}, alt ${altAnim}');
					// JOELwindows7: looks like interupt is defaultly true looks like!
					// crash if animation frame reference in the name is missing
					// Debug.logTrace('${animation.curAnim.name} here,');
					// Debug.logTrace('${animation.curAnim.name} can interupt? ${animInterrupt.get(animation.curAnim.name)}');
					var canInterrupt = animInterrupt.get(animation.curAnim.name);
					if (canInterrupt == null)
					{
						canInterrupt = true;
					} // JOELwindows7: prevent gf goes dead silent after train hair fall.

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
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		// JOELwindows7: BOLO optimizeoid
		if (!PlayStateChangeables.optimize)
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
	}

	// JOELwindows7: add BOLO things here.
	// https://github.com/BoloVEVO/Kade-Engine-Public/blob/stable/source/Character.hx
	// the load mapped anim
	public static function loadMappedAnims():Void
	{
		var noteData:Array<SwagSection> = Song.loadFromJson(PlayState.SONG.songId, 'picospeaker').notes;
		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = (songNotes[0] - FlxG.save.data.offset - PlayState.songOffset) / PlayState.songMultiplier;
				if (daStrumTime < 0)
					daStrumTime = 0;

				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var oldNote:Note;

				if (PlayState.instance.unspawnNotes.length > 0)
					oldNote = PlayState.instance.unspawnNotes[Std.int(PlayState.instance.unspawnNotes.length - 1)];
				else
					oldNote = null;
				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, false, false, songNotes[4]);

				animationNotes.push(swagNote);
			}
		}
		TankmenBG.animationNotes = animationNotes;
		animationNotes.sort(sortAnims);
	}

	// JOELwindows7: BOLO sort anims
	static function sortAnims(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
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

	// JOELwindows7: enable print the lub dub for debugging purpose
	public function _setDebugPrintHeart(which:Int = -1, into:Bool = false)
	{
		if (which < 0)
		{
			for (each in jantungInstances)
			{
				each._setDebugPrint(into);
			}
		}
		else
		{
			try
			{
				jantungInstances[which]._setDebugPrint(into);
			}
			catch (e)
			{
				Debug.logError("WERROR 404! Heart organ No. " + Std.string(which) + " not found while attempting to: set debug print!\n" + e + ": " +
					e.message);
			}
		}
	}

	// JOELwindows7: play death animation & all sounds defined
	public function blueballsNow(mute:Bool = false)
	{
		playAnim('firstDeath');
		if (!mute)
		{
			if (deathSoundPaths != null && deathSoundPaths.length > 0)
			{
				for (daThing in deathSoundPaths)
				{
					FlxG.sound.play(Paths.sound('${daThing.pathPrefix}${(daThing.addSuffixes == null ? true : daThing.addSuffixes) ? GameOverSubstate.getAddSuffixes() : ""}',
						'shared'),
						daThing.volume == null ? Perkedel.NULL_DEATH_SOUND_VOLUME : daThing.volume);
				}
			}
			if (randomizedDeathSoundPaths != null && randomizedDeathSoundPaths.length > 0)
			{
				for (daThing in randomizedDeathSoundPaths)
				{
					FlxG.sound.play(Paths.soundRandom('${daThing.pathPrefix}${(daThing.addSuffixes == null ? false : daThing.addSuffixes) ? GameOverSubstate.getAddSuffixes() : ""}',
						daThing.minRange, daThing.maxRange, 'shared'),
						daThing.volume == null ? Perkedel.NULL_DEATH_SOUND_VOLUME : daThing.volume);
				}
			}
		}
	}

	// JOELwindows7: maybe also add witnessing of death too? e.g. when fail in tutorial uh.. idk.
	public function witnessBlueball(mute:Bool = false, yayPersonDied:Bool = false)
	{
		// yayPersonDied true means this character play "yay he's dead!" animation a.k.a. evil character.
		// otherwise show pity a.k.a. good character
		if (!mute)
		{
			// TODO: pls build way of differenter.
		}
	}

	// JOELwindows7: press retry
	public function riseUpAgain(mute:Bool = false)
	{
		playAnim('deathConfirm', true);
		if (!mute)
		{
			if (riseUpAgainSoundPaths != null && riseUpAgainSoundPaths.length > 0)
			{
				for (daThing in riseUpAgainSoundPaths)
				{
					FlxG.sound.play(Paths.sound('${daThing.pathPrefix}${(daThing.addSuffixes == null ? true : daThing.addSuffixes) ? GameOverSubstate.getAddSuffixes() : ""}',
						'shared'),
						daThing.volume == null ? Perkedel.NULL_DEATH_SOUND_VOLUME : daThing.volume);
				}
			}
			if (randomizedRiseUpAgainSoundPaths != null && randomizedRiseUpAgainSoundPaths.length > 0)
			{
				for (daThing in randomizedRiseUpAgainSoundPaths)
				{
					FlxG.sound.play(Paths.soundRandom('${daThing.pathPrefix}${(daThing.addSuffixes == null ? false : daThing.addSuffixes) ? GameOverSubstate.getAddSuffixes() : ""}',
						daThing.minRange, daThing.maxRange, 'shared'),
						daThing.volume == null ? Perkedel.NULL_DEATH_SOUND_VOLUME : daThing.volume);
				}
			}
		}
	}
}

typedef CharacterData =
{
	var name:String;

	/**
	 * Name of the character that'll be displayed on screen such as Dialogue chat
	 */
	var ?displayName:String; // JOELwindows7: If they have special name, reregular name, or whatever it should be displayed as.

	/**
	 * Force the health icon to be specific icon regardless of the filter.
	 */
	var ?forceIcon:Bool; // JOELwindows7: force the health icon to be specific icon regardless of the filter.

	/**
	 * Font for the dialog. e.g. `Pixel Arial 11 Bold` or `Ubuntu Bold` etc.
	 */
	var ?font:String; // JOELwindows7: name of the font for dialoguebox. e.g. `Pixel Arial 11 Bold` or `Ubuntu Bold` etc.

	/**
	 * Drop Font for the dialog text behind. e.g. `Pixel Arial 11 Bold` or `Ubuntu Bold` etc.
	 */
	var ?fontDrop:String; // JOELwindows7: & for the text behind

	/**
	 * Paths of sounds to play all at the same time in event of death / blueball
	 */
	var ?deathSoundPaths:Array<DeathSoundPath>; // JOELwindows7: sounds to play when death. plays these all at the same time.

	/**
		Character ID for the Game Over screen.
	**/
	var ?deathCharacter:String; // JOELwindows7: if the death char is different, then which character is it

	/**
		Would you like to use this same character or different character ID defined in `deathCharacter`?
	**/
	var ?deathCharacterIsSameAsThis:Bool; // JOELwindows7: whether the death character is same or use above path idk.

	/**
	 * Paths of sounds to play all at the same time in event of death / blueball
	 * with each bit randomly chooses different variations ranging from minimum number to maximum number
	 */
	var ?randomizedDeathSoundPaths:Array<RandomizedDeathSoundPath>; // JOELwindows7: and play sound randomized one. play all, each bit plays which.

	/**
	 * Paths of sounds to play all at the same time in event of press retry
	 */
	var ?riseUpAgainSoundPaths:Array<DeathSoundPath>; // JOELwindows7: press retry

	/**
	 * Paths of sounds to play all at the same time in event of press retry
	 * with each bit randomly chooses different variations ranging from minimum number to maximum number
	 */
	var ?randomizedRiseUpAgainSoundPaths:Array<RandomizedDeathSoundPath>; // and randomized ones.

	// var ?forceHealthIconIsThat:Bool; // JOELwindows7: force the health icon to be specific icon regardless of the filter.
	var asset:String;
	var startingAnim:String;
	var ?charPos:Array<Int>;
	var ?camPos:Array<Int>;
	var ?camFollow:Array<Int>;
	var ?holdLength:Float;

	/**
	 * Heart organs specification inside this character. can have more than 1 heart specification.
	 */
	var ?heartOrgans:Array<SwagHeart>; // JOELwindows7: Array of heart organs inside this Character.

	/**
	 * The color of this character's health bar.
	 */
	var barColor:String;

	/**
	 * The color of this character's dialogue font.
	 */
	var ?fontColor:String; // JOELwindows7: dialog font color

	/**
	 * The color of this character's dialogue font for the drop behind text.
	 */
	var ?fontColorDrop:String; // JOELwindows7: and the drop color, for text behind.

	/**
	 * The sound path of this character's dialogue.
	 */
	var ?dialogueChatSoundPaths:Array<String>; // JOELwindows7: array of dialogue chat sound paths.

	/**
	 * The sound volume for all sounds of character dialogue.
	 */
	var ?dialogueChatSoundVolume:Float; // JOELwindows7: volume for all sounds

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

	// JOELwindows7: BOLO

	/**
	 * What type of Atlas the character uses.
	 * @default SparrowAtlas
	 */
	var ?AtlasType:String;

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

// JOELwindows7: turns out there is random sound bits from num which to what.
typedef RandomizedDeathSoundPath =
{
	var pathPrefix:String;
	var minRange:Int;
	var maxRange:Int;
	var ?volume:Float;
	var ?addSuffixes:Bool;
}

// JOELwindows7: oh turns out the regular death sound may have various volumes too!
typedef DeathSoundPath =
{
	var pathPrefix:String;
	var ?volume:Float;
	var ?addSuffixes:Bool;
}

// JOELwindows7: damn, could've just one unisound type for many various parametering things right? this used for both regular & randomized one.
typedef WitnessBlueballSoundPath =
{
	var pathPrefix:String;
	var ?minRange:Int;
	var ?maxRange:Int;
	var ?volume:Float;
	var ?addSuffixes:Bool;

	/**
		Set this to `true`, if this character hates that opponent, it'll play sound with `insulting` set to `true`. show insult haha you lose!!
		Set this to `false`, if this character likes the opponent, it'll play sound with `insulting` set to `false`. show pity oh no are you okay?!
	**/
	var ?insulting:Bool; // JOELwindows7: true means that this if for when hated opponent lose. otherwise this is for to pity.

}
