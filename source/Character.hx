package;

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
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';
	public var barColor:FlxColor;
	public var colorTween:FlxTween; //JOELwindows7: Psyched color tween lol! what a big surpise.

	public var holdTimer:Float = 0;

	public var name:String = 'Boyfriend'; // JOELwindows7: JSON character name, with detaile.
	public var displayName:String = 'Boyfriend'; // JOELwindows7: for showcase name on screen rather than ID

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);

		barColor = isPlayer ? 0xFF66FF33 : 0xFFFF0000;
		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		var tex:FlxAtlasFrames;
		antialiasing = FlxG.save.data.antialiasing;

		// JOELwindows7: bruh you forgot to lowercase curCharacter case name. that's why it crash if I capital one of the letter.
		// please toLowerCase, should I do that?
		switch (curCharacter)
		{
			/*
				case 'gf':
					//JOELwindows7: deprecated, use JSON file at preload/data/characters/gf.json and so on.
					name = "Girlfriend"; // JOELwindows7: name it
					displayName = "Girlfriend"; // JOELwindows7: display name it
					// GIRLFRIEND CODE
					tex = Paths.getSparrowAtlas('GF_assets','shared',true);
					frames = tex;
					animation.addByPrefix('cheer', 'GF Cheer', 24, false);
					animation.addByPrefix('singLEFT', 'GF left note', 24, false);
					animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
					animation.addByPrefix('singUP', 'GF Up Note', 24, false);
					animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
					animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
					animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
					animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
					animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
					animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
					animation.addByPrefix('scared', 'GF FEAR', 24);

					loadOffsetFile(curCharacter);

					playAnim('danceRight');
			 */

			case 'gf-ht':
				// JOELwindows7: copy from above GIRLFRIEND CODE
				name = "Television"; // JOELwindows7: name it
				displayName = "Television"; // JOELwindows7: display name it
				tex = Paths.getSparrowAtlas('characters/gfHomeTheater');
				frames = tex;
				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);

				// addOffset('cheer', 0, 2);
				// addOffset('sad', 0, 2);
				// addOffset('danceLeft', 0, 2);
				// addOffset('danceRight', 0, 2);

				// addOffset("singUP", 0, 2);
				// addOffset("singRIGHT", 0, 2);
				// addOffset("singLEFT", 0, 2);
				// addOffset("singDOWN", 0, 2);
				// addOffset('hairBlow', 0, 2);
				// addOffset('hairFall', 0, 2);

				// addOffset('scared', 0, 2);
				loadOffsetFile(curCharacter);
				// JOELwindows7: this should be deprecated because of Characters JSON file

				playAnim('danceRight');

				barColor = 0xFFFF0000;
			case 'gf-covid':
				// JOELwindows7: copy from that GIRLFRIEND CODE
				name = "Girlfriend"; // JOELwindows7: name it
				displayName = "Girlfriend"; // JOELwindows7: display name it
				tex = Paths.getSparrowAtlas('GF-covid_assets', 'shared', true);
				frames = tex;
				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);

				loadOffsetFile(curCharacter);

				playAnim('danceRight');

				barColor = 0xFFFF0000;
			case 'gf-christmas':
				name = "Girlfriend (Christmas)"; // JOELwindows7: name it
				displayName = "Girlfriend"; // JOELwindows7: display name it
				tex = Paths.getSparrowAtlas('gfChristmas', 'shared', true);
				frames = tex;
				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);

				loadOffsetFile(curCharacter);

				playAnim('danceRight');

			case 'gf-car':
				name = "Girlfriend (Car)"; // JOELwindows7: name it
				tex = Paths.getSparrowAtlas('gfCar', 'shared', true);
				frames = tex;
				animation.addByIndices('singUP', 'GF Dancing Beat Hair blowing CAR', [0], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat Hair blowing CAR', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat Hair blowing CAR', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24,
					false);
				animation.addByIndices('idleHair', 'GF Dancing Beat Hair blowing CAR', [10, 11, 12, 25, 26, 27], "", 24, true);

				loadOffsetFile(curCharacter);

				playAnim('danceRight');

			case 'gf-pixel':
				name = "Girlfriend"; // JOELwindows7: name it
				displayName = "Girlfriend"; // JOELwindows7: display name it
				tex = Paths.getSparrowAtlas('gfPixel', 'shared', true);
				frames = tex;
				animation.addByIndices('singUP', 'GF IDLE', [2], "", 24, false);
				animation.addByIndices('danceLeft', 'GF IDLE', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF IDLE', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				loadOffsetFile(curCharacter);

				playAnim('danceRight');

				setGraphicSize(Std.int(width * CoolUtil.daPixelZoom));
				updateHitbox();
				antialiasing = false;

			case 'dad':
				// DAD ANIMATION LOADING CODE
				name = "Daddy Dearest"; // JOELwindows7: name it
				displayName = "Daddy Dearest"; // JOELwindows7: display name it
				tex = Paths.getSparrowAtlas('DADDY_DEAREST', 'shared', true);
				frames = tex;
				animation.addByPrefix('idle', 'Dad idle dance', 24, false);
				animation.addByPrefix('singUP', 'Dad Sing Note UP', 24, false);
				animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24, false);
				animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24, false);
				animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24, false);
				animation.addByIndices('idleLoop', "Dad idle dance", [11, 12], "", 12, true);

				loadOffsetFile(curCharacter);
				barColor = 0xFFaf66ce;

				playAnim('idle');
			case 'hookx':
				// HOOKX ANIMATION LOADING CODE
				name = "Hookx"; // JOELwindows7: name it
				displayName = "Hookx"; // JOELwindows7: display name it
				// JOELwindows7: bruh you forgot to lowecase the character case name!
				tex = Paths.getSparrowAtlas('characters/Hookx');
				frames = tex;
				animation.addByPrefix('idle', 'Hookx idle dance', 24);
				animation.addByPrefix('singUP', 'Hookx Sing Note UP', 24);
				animation.addByPrefix('singRIGHT', 'Hookx Sing Note RIGHT', 24);
				animation.addByPrefix('singDOWN', 'Hookx Sing Note DOWN', 24);
				animation.addByPrefix('singLEFT', 'Hookx Sing Note LEFT', 24);

				loadOffsetFile(curCharacter);

				// addOffset('idle');
				// addOffset("singUP");
				// addOffset("singRIGHT");
				// addOffset("singLEFT");
				// addOffset("singDOWN");

				barColor = 0xFF5000E6; // Also: Sky, Carol

				playAnim('idle');
			case 'spooky':
				name = "Skid and Pump"; // JOELwindows7: name them
				displayName = "Skid and Pump"; // JOELwindows7: display name them
				tex = Paths.getSparrowAtlas('spooky_kids_assets', 'shared', true);
				frames = tex;
				animation.addByPrefix('singUP', 'spooky UP NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'spooky DOWN note', 24, false);
				animation.addByPrefix('singLEFT', 'note sing left', 24, false);
				animation.addByPrefix('singRIGHT', 'spooky sing right', 24, false);
				animation.addByIndices('danceLeft', 'spooky dance idle', [0, 2, 6], "", 12, false);
				animation.addByIndices('danceRight', 'spooky dance idle', [8, 10, 12, 14], "", 12, false);

				loadOffsetFile(curCharacter);
				barColor = 0xFFd57e00;

				playAnim('danceRight');
			case 'mom':
				name = "Mommy Mearest"; // JOELwindows7: name it
				displayName = "Mommy Mearest"; // JOELwindows7: display name it
				tex = Paths.getSparrowAtlas('Mom_Assets', 'shared', true);
				frames = tex;

				animation.addByPrefix('idle', "Mom Idle", 24, false);
				animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
				animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
				animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
				// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
				// CUZ DAVE IS DUMB!
				animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);
				animation.addByIndices('idleLoop', "Mom Idle", [11, 12], "", 12, true);

				loadOffsetFile(curCharacter);
				barColor = 0xFFd8558e;

				playAnim('idle');

			case 'mom-car':
				name = "Mommy Mearest (Car)"; // JOELwindows7: name it
				displayName = "Mommy Mearest"; // JOELwindows7: display name it
				tex = Paths.getSparrowAtlas('momCar', 'shared', true);
				frames = tex;

				animation.addByPrefix('idle', "Mom Idle", 24, false);
				animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
				animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
				animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
				// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
				// CUZ DAVE IS DUMB!
				animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);
				animation.addByIndices('idleHair', 'Mom Idle', [10, 11, 12, 13], "", 24, true);

				loadOffsetFile(curCharacter);
				barColor = 0xFFd8558e;

				playAnim('idle');
			case 'monster':
				name = "Monster"; // JOELwindows7: name it
				displayName = "Monster"; // JOELwindows7: display name it
				tex = Paths.getSparrowAtlas('Monster_Assets', 'shared', true);
				frames = tex;
				animation.addByPrefix('idle', 'monster idle', 24, false);
				animation.addByPrefix('singUP', 'monster up note', 24, false);
				animation.addByPrefix('singDOWN', 'monster down', 24, false);
				animation.addByPrefix('singLEFT', 'Monster left note', 24, false);
				animation.addByPrefix('singRIGHT', 'Monster Right note', 24, false);

				loadOffsetFile(curCharacter);
				barColor = 0xFFf3ff6e;
				playAnim('idle');
			case 'monster-christmas':
				name = "Monster (Christmas)"; // JOELwindows7: name it
				displayName = "Monster"; // JOELwindows7: name it
				tex = Paths.getSparrowAtlas('monsterChristmas', 'shared', true);
				frames = tex;
				animation.addByPrefix('idle', 'monster idle', 24, false);
				animation.addByPrefix('singUP', 'monster up note', 24, false);
				animation.addByPrefix('singDOWN', 'monster down', 24, false);
				animation.addByPrefix('singLEFT', 'Monster left note', 24, false);
				animation.addByPrefix('singRIGHT', 'Monster Right note', 24, false);

				loadOffsetFile(curCharacter);
				barColor = 0xFFf3ff6e;
				playAnim('idle');
			case 'pico':
				name = "Pico"; // JOELwindows7: name it
				displayName = "Pico"; // JOELwindows7: display name it
				tex = Paths.getSparrowAtlas('Pico_FNF_assetss', 'shared', true);
				frames = tex;
				animation.addByPrefix('idle', "Pico Idle Dance", 24, false);
				animation.addByPrefix('singUP', 'pico Up note0', 24, false);
				animation.addByPrefix('singDOWN', 'Pico Down Note0', 24, false);
				if (isPlayer)
				{
					animation.addByPrefix('singLEFT', 'Pico NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHT', 'Pico Note Right0', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'Pico Note Right Miss', 24, false);
					animation.addByPrefix('singLEFTmiss', 'Pico NOTE LEFT miss', 24, false);
				}
				else
				{
					// Need to be flipped! REDO THIS LATER!
					animation.addByPrefix('singLEFT', 'Pico Note Right0', 24, false);
					animation.addByPrefix('singRIGHT', 'Pico NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'Pico NOTE LEFT miss', 24, false);
					animation.addByPrefix('singLEFTmiss', 'Pico Note Right Miss', 24, false);
				}

				animation.addByPrefix('singUPmiss', 'pico Up note miss', 24);
				animation.addByPrefix('singDOWNmiss', 'Pico Down Note MISS', 24);

				loadOffsetFile(curCharacter);
				barColor = 0xFFb7d855;

				playAnim('idle');

				flipX = true;

			case 'bf':
				name = "Boyfriend"; // JOELwindows7: name it
				displayName = "Boyfriend"; // JOELwindows7: display name it
				var tex = Paths.getSparrowAtlas('BOYFRIEND', 'shared', true);
				frames = tex;

				trace(tex.frames.length);

				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, false);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				animation.addByPrefix('scared', 'BF idle shaking', 24);

				loadOffsetFile(curCharacter);

				playAnim('idle');

				barColor = 0xFF31b0d1;

				flipX = true;

			case 'bf-covid':
				// JOELwindows7: copy paste the bf above, add masker in his face, and mic. also add vaccine injection mark plaster in left arm
				name = "Boyfriend (Covid-19)"; // JOELwindows7: name it
				displayName = "Boyfriend"; // JOELwindows7: display name it
				// install masker and vaccine injection (all done) Hopefully can fight omicron in case of the worst
				var tex = Paths.getSparrowAtlas('characters/BOYFRIEND-covid');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				animation.addByPrefix('scared', 'BF idle shaking', 24);

				// addOffset('idle', -5);
				// addOffset("singUP", -29, 27);
				// addOffset("singRIGHT", -38, -7);
				// addOffset("singLEFT", 12, -6);
				// addOffset("singDOWN", -10, -50);
				// addOffset("singUPmiss", -29, 27);
				// addOffset("singRIGHTmiss", -30, 21);
				// addOffset("singLEFTmiss", 12, 24);
				// addOffset("singDOWNmiss", -11, -19);
				// addOffset("hey", 7, 4);
				// addOffset('firstDeath', 37, 11);
				// addOffset('deathLoop', 37, 5);
				// addOffset('deathConfirm', 37, 69);
				// addOffset('scared', -4);
				loadOffsetFile(curCharacter);

				playAnim('idle');

				barColor = 0xFF31b0d1;

				flipX = true;
			case 'bf-christmas':
				name = "Boyfriend (Christmas)"; // JOELwindows7: name it
				displayName = "Boyfriend"; // JOELwindows7: display name it
				var tex = Paths.getSparrowAtlas('bfChristmas', 'shared', true);
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				loadOffsetFile(curCharacter);

				playAnim('idle');

				flipX = true;
			case 'bf-car':
				name = "Boyfriend (Car)"; // JOELwindows7: name it
				displayName = "Boyfriend"; // JOELwindows7: display name it
				var tex = Paths.getSparrowAtlas('bfCar', 'shared', true);
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByIndices('idleHair', 'BF idle dance', [10, 11, 12, 13], "", 24, true);

				loadOffsetFile(curCharacter);
				playAnim('idle');

				barColor = 0xFF31b0d1;

				flipX = true;
			case 'bf-pixel':
				name = "Boyfriend (Pixel Day)"; // JOELwindows7: name it
				displayName = "Boyfriend"; // JOELwindows7: name it
				frames = Paths.getSparrowAtlas('bfPixel', 'shared', true);
				animation.addByPrefix('idle', 'BF IDLE', 24, false);
				animation.addByPrefix('singUP', 'BF UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'BF LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'BF RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'BF DOWN NOTE', 24, false);
				animation.addByPrefix('singUPmiss', 'BF UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF DOWN MISS', 24, false);

				loadOffsetFile(curCharacter);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				width -= 100;
				height -= 100;

				antialiasing = false;

				barColor = 0xFF31b0d1;

				flipX = true;
			case 'bf-pixel-dead':
				name = "Boyfriend (Pixel Day) (Game Over)"; // JOELwindows7: name it
				displayName = "Boyfriend"; // JOELwindows7: displayname it
				frames = Paths.getSparrowAtlas('bfPixelsDEAD', 'shared', true);
				animation.addByPrefix('singUP', "BF Dies pixel", 24, false);
				animation.addByPrefix('firstDeath', "BF Dies pixel", 24, false);
				animation.addByPrefix('deathLoop', "Retry Loop", 24, false);
				animation.addByPrefix('deathConfirm', "RETRY CONFIRM", 24, false);
				animation.play('firstDeath');

				loadOffsetFile(curCharacter);
				playAnim('firstDeath');
				// pixel bullshit
				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				antialiasing = false;
				flipX = true;

				barColor = 0xFF31b0d1;

			case 'senpai':
				name = "Senpai"; // JOELwindows7: name it
				displayName = "Senpai"; // JOELwindows7: name it
				frames = Paths.getSparrowAtlas('senpai', 'shared', true);
				animation.addByPrefix('idle', 'Senpai Idle', 24, false);
				animation.addByPrefix('singUP', 'SENPAI UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'SENPAI LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'SENPAI RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'SENPAI DOWN NOTE', 24, false);

				loadOffsetFile(curCharacter);
				barColor = 0xFFffaa6f;

				playAnim('idle');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				antialiasing = false;
			case 'senpai-angry':
				name = "Senpai (Angry)"; // JOELwindows7: name it
				displayName = "Senpai"; // JOELwindows7: name it
				frames = Paths.getSparrowAtlas('senpai', 'shared', true);
				animation.addByPrefix('idle', 'Angry Senpai Idle', 24, false);
				animation.addByPrefix('singUP', 'Angry Senpai UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'Angry Senpai LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'Angry Senpai RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'Angry Senpai DOWN NOTE', 24, false);

				loadOffsetFile(curCharacter);
				barColor = 0xFFffaa6f;
				playAnim('idle');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				antialiasing = false;

			case 'spirit':
				name = "Spirit"; // JOELwindows7: name it
				displayName = "Senpai"; // JOELwindows7: display name it
				frames = Paths.getPackerAtlas('spirit', 'shared', true);
				animation.addByPrefix('idle', "idle spirit_", 24, false);
				animation.addByPrefix('singUP', "up_", 24, false);
				animation.addByPrefix('singRIGHT', "right_", 24, false);
				animation.addByPrefix('singLEFT', "left_", 24, false);
				animation.addByPrefix('singDOWN', "spirit down_", 24, false);

				loadOffsetFile(curCharacter);
				barColor = 0xFFff3c6e;

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

			case 'parents-christmas':
				name = "Parents (Christmas)"; // JOELwindows7: name them
				name = "Mom and Dad"; // JOELwindows7: display name them
				frames = Paths.getSparrowAtlas('mom_dad_christmas_assets', 'shared', true);
				animation.addByPrefix('idle', 'Parent Christmas Idle', 24, false);
				animation.addByPrefix('singUP', 'Parent Up Note Dad', 24, false);
				animation.addByPrefix('singDOWN', 'Parent Down Note Dad', 24, false);
				animation.addByPrefix('singLEFT', 'Parent Left Note Dad', 24, false);
				animation.addByPrefix('singRIGHT', 'Parent Right Note Dad', 24, false);

				animation.addByPrefix('singUP-alt', 'Parent Up Note Mom', 24, false);
				animation.addByPrefix('singDOWN-alt', 'Parent Down Note Mom', 24, false);
				animation.addByPrefix('singLEFT-alt', 'Parent Left Note Mom', 24, false);
				animation.addByPrefix('singRIGHT-alt', 'Parent Right Note Mom', 24, false);
				animation.addByIndices('idleLoop', "Parent Christmas Idle", [11, 12], "", 12, true);

				loadOffsetFile(curCharacter);
				barColor = 0xFF9a00f8;

				playAnim('idle');
			case 'placeholder' | 'gf-placeholder':
				name = "Placeholder"; // JOELwindows7: name it
				displayName = "?????"; // JOELwindows7: name it
				// JOELwindows7: Placeholder character
				// For temporary placeholder & gone mods cope machine
				frames = Paths.getSparrowAtlas('Placeholder', 'shared', true);
				animation.addByPrefix('idle', 'Placeholder idle', 24, false);
				animation.addByPrefix('singUP', 'Placeholder Sing Note UP', 24, false);
				animation.addByPrefix('singDOWN', 'Placeholder Sing Note DOWN', 24, false);
				animation.addByPrefix('singLEFT', 'Placeholder Sing Note LEFT', 24, false);
				animation.addByPrefix('singRIGHT', 'Placeholder Sing Note RIGHT', 24, false);

				animation.addByPrefix('singUP-alt', 'Placeholder Sing Note alt UP', 24, false);
				animation.addByPrefix('singDOWN-alt', 'Placeholder Sing Note alt DOWN', 24, false);
				animation.addByPrefix('singLEFT-alt', 'Placeholder Sing Note alt LEFT', 24, false);
				animation.addByPrefix('singRIGHT-alt', 'Placeholder Sing Note alt RIGHT', 24, false);

				animation.addByPrefix('singUPmiss', 'Placeholder Miss up', 24, false);
				animation.addByPrefix('singLEFTmiss', 'Placeholder Miss left', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'Placeholder Miss right', 24, false);
				animation.addByPrefix('singDOWNmiss', 'Placeholder Miss down', 24, false);

				animation.addByPrefix('hey', 'Placeholder Hey', 24, false);
				animation.addByPrefix('cheer', 'Placeholder Hey alt', 24, false);
				animation.addByPrefix('firstDeath', "Placeholder First Death", 24, false);
				animation.addByPrefix('deathLoop', "Placeholder Dead Loop", 24, false);
				animation.addByPrefix('deathConfirm', "Placeholder Dead Confirm", 24, false);

				animation.addByPrefix('scared', 'Placeholder Scared', 24);
				animation.addByPrefix('sad', 'Placeholder Sad', 24);

				animation.addByPrefix('danceLeft', 'Placeholder Dance LEFT', 24, false);
				animation.addByPrefix('danceRight', 'Placeholder Dance RIGHT', 24, false);
				animation.addByPrefix('hairBlow', "Placeholder Hair Blowing", 24);
				animation.addByPrefix('hairFall', "Placeholder Hair Falling", 24, false);
				trace("Added Placeholderizing frames");
				loadOffsetFile(curCharacter);

				barColor = 0xFF0D0D0D;

				if (!curCharacter.contains('gf'))
					playAnim('idle')
				else
					playAnim('danceLeft');
				trace("Go placeholdering");
			default:
				parseDataFile();
		}

		if (curCharacter.startsWith('bf'))
			dance();

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

		name = data.name; // JOELwindows7: name it. wow, Kade and friends prepared that already lol! thancc Eric Millyoja yey cool and good!
		displayName = data.displayName;
		if (data.displayName == null) // JOELwindows7: If displayName is empty, copy from name
			displayName = name;
		var tex:FlxAtlasFrames = Paths.getSparrowAtlas(data.asset, 'shared');
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
			}

		barColor = FlxColor.fromString(data.barColor);

		playAnim(data.startingAnim);
	}

	public function loadOffsetFile(character:String, library:String = 'shared')
	{
		var offset:Array<String> = CoolUtil.coolTextFile(Paths.txt('images/characters/' + character + "Offsets", library));

		for (i in 0...offset.length)
		{
			var data:Array<String> = offset[i].split(' ');
			addOffset(data[0], Std.parseInt(data[1]), Std.parseInt(data[2]));
		}
	}

	override function update(elapsed:Float)
	{
		if (!isPlayer)
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			if (curCharacter.endsWith('-car')
				&& !animation.curAnim.name.startsWith('sing')
				&& animation.curAnim.finished
				&& animation.getByName('idleHair') != null)
				playAnim('idleHair');

			if (animation.getByName('idleLoop') != null)
			{
				if (!animation.curAnim.name.startsWith('sing') && animation.curAnim.finished)
					playAnim('idleLoop');
			}

			var dadVar:Float = 4;

			if (curCharacter == 'dad')
				dadVar = 6.1;
			else if (curCharacter == 'gf' || curCharacter == 'spooky')
				dadVar = 4.1; // fix double dances
			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				if (curCharacter == 'gf' || curCharacter == 'spooky')
					playAnim('danceLeft'); // overridden by dance correctly later
				dance();
				holdTimer = 0;
			}
		}

		switch (curCharacter)
		{
			case 'gf' | 'gf-ht' | 'gf-covid' | 'gf-placeholder':
				// JOELwindows7: okay idk how to make this work at all!
				if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
				{
					danced = true;
					playAnim('danceRight');
				}
		}

		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance(forced:Bool = false, altAnim:Bool = false)
	{
		if (!debugMode)
		{
			switch (curCharacter)
			{
				case 'gf' | 'gf-christmas' | 'gf-car' | 'gf-pixel' | 'gf-covid' | 'gf-placeholder' | 'gf-ht':
					// JOELwindows7: copy this if from above case
					// well we can just add OR to this.
					if (!animation.curAnim.name.startsWith('hair') && !animation.curAnim.name.startsWith('sing'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}
				case 'spooky':
					if (!animation.curAnim.name.startsWith('sing'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}
				/*
					// new dance code is gonna end up cutting off animation with the idle
					// so here's example code that'll fix it. just adjust it to ya character 'n shit
					case 'custom character':
						if (!animation.curAnim.name.endsWith('custom animation'))
							playAnim('idle', forced);
				 */
				default:
					if (altAnim && animation.getByName('idle-alt') != null)
						playAnim('idle-alt', forced);
					else
						playAnim('idle', forced);
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
}

typedef CharacterData =
{
	var name:String;
	var ?displayName:String; // JOELwindows7: If they have special name, reregular name, or whatever it should be displayed as.
	var asset:String;
	var startingAnim:String;

	/**
	 * The color of this character's health bar.
	 */
	var barColor:String;

	var animations:Array<AnimationData>;
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
}
