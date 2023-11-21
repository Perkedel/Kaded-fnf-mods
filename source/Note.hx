package;

#if cpp
import cpp.abi.Abi;
#end
import flixel.addons.ui.FlxUISprite;
import flixel.addons.effects.FlxSkewedSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end
import LuaClass;
import PlayState;

using StringTools;

// JOELwindows7: Applied mod based on
/*
	- https://youtu.be/iiQfjYcpJfQ
	- https://gamebanana.com/questions/17887
 */
// Yes, noteTypes like mine or so.
class Note extends FlxUISprite
{
	public var strumTime:Float = 0;
	public var baseStrum:Float = 0;

	public var charterSelected:Bool = false;

	public var rStrumTime:Float = 0;

	// JOELwindows7: BOLO's psyched LuaNote reference
	// https://github.com/BoloVEVO/Kade-Engine-Public/blob/stable/source/Note.hx
	#if FEATURE_LUAMODCHART
	public var LuaNote:LuaNote;
	#end

	public var mustPress:Bool = false;
	public var noteData:Int = 0; // Orders for 4K = left, down, up, right.
	public var rawNoteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var modifiedByLua:Bool = false;
	public var totalOverride:Bool = false; // JOELwindows7: enable to disable special parametering & leave its original parametering.
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var originColor:Int = 0; // The sustain note's original note's color
	public var noteSection:Int = 0;
	public var noteType:Int = 0; // JOELwindows7: type of note.

	public var luaID:Int = 0;

	public var isAlt:Bool = false;

	// JOELwindows7: everything must use `FlxUISprite` from now on.
	public var noteCharterObject:FlxUISprite;

	public var noteScore:Float = 1;

	public var noteYOff:Float = 0; // JOELwindows7: Brother, it's Float supposedly bruh. look at BOLO!

	public var beat:Float = 0;

	public static var swagWidth:Float = 160 * 0.7;
	public static var swagHeight:Float = 160 * 0.7; // JOELwindows7: make it square.
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	// JOELwindows7: Psyched Lua shit
	public var noteSplashDisabled:Bool = false;
	public var noteSplashTexture:String = null;
	public var noteSplashHue:Float = 0;
	public var noteSplashSat:Float = 0;
	public var noteSplashBrt:Float = 0;

	public var rating:String = "shit";

	public var modAngle:Float = 0; // The angle set by modcharts
	public var localAngle:Float = 0; // The angle to be edited inside Note.hx
	public var originAngle:Float = 0; // The angle the OG note of the sus note had (?)

	public var dataColor:Array<String> = ['purple', 'blue', 'green', 'red'];
	public var dataColorCap:Array<String> = ['PURPLE', 'BLUE', 'GREEN', 'RED']; // JOELwindows7: EYY YEA
	public var dataColorDir:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT']; // JOELwindows7: OOPS
	public var quantityColor:Array<Int> = [RED_NOTE, 2, BLUE_NOTE, 2, PURP_NOTE, 2, GREEN_NOTE, 2];
	public var arrowAngles:Array<Int> = [180, 90, 270, 0];

	public var isParent:Bool = false;
	public var parent:Note = null;
	public var spotInLine:Int = 0;
	public var sustainActive:Bool = true;

	public var children:Array<Note> = [];

	public var inCharter:Bool = false; // JOELwindows7: globalize inCharter for all charting state detection
	public var noteTypeCheck:String; // JOELwindows7: globalize noteTypeCheck for all noteSkin detection

	public var hitsoundUseIt:Bool = false; // JOELwindows7: because there is BOLO here, now we have to prioritze default. flag up to override.
	public var hitsoundPath:String = "SNAP"; // JOELwindows7: hitsound audio file to play when hit & hitsound option enabled.
	public var hitlinePath:String = "HitLineParticle"; // JOELwindows7: hitline particle to emit when hit & hitline option enabled. idk this always on?
	public var vowelType:Int = 0; // JOELwindows7: vowel type. radpas12131's mod. a i u e o.
	public var noQuantize:Bool = false; // JOELwindows7: force the note to not quantize, useful for testing.

	// IDEA: JOELwindows7: you can have more variables about string or whatever too! like
	// sylables or phoneme for VOCALOID
	// noteNumber MIDI note number for everything
	// JOELwindows7: Hold on, BOLO has more of these
	public var stepHeight:Float = 0;

	var leSpeed:Float = 0;

	var leBpm:Float = 0;

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inCharter:Bool = false, ?isAlt:Bool = false,
			?bet:Float = 0, ?noteType:Int = 0, ?noQuantize:Bool = false) // JOELwindows7: edge long noteType
	{
		super();

		if (prevNote == null)
			prevNote = this;

		beat = bet;

		this.isAlt = isAlt;
		this.noteType = noteType; // JOELwindows7: oh yeah noteType
		this.prevNote = prevNote;
		this.inCharter = inCharter;
		this.noQuantize = noQuantize;
		isSustainNote = sustainNote;
		// hitsoundPath = hitsoundId; // yeah the note hitsound

		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;

		if (inCharter)
		{
			this.strumTime = strumTime;
			rStrumTime = strumTime;
		}
		else
		{
			this.strumTime = strumTime;
			#if FEATURE_STEPMANIA
			if (PlayState.isSM)
			{
				rStrumTime = strumTime;
			}
			else
				rStrumTime = strumTime;
			#else
			rStrumTime = strumTime;
			#end
		}

		if (this.strumTime < 0)
			this.strumTime = 0;

		this.noteData = noteData;

		// JOELwindows7: BOLO's mirror modifier people!!!
		// YOOO WTF IT WORKED???!!!
		if (PlayStateChangeables.mirrorMode)
		{
			this.noteData = Std.int(Math.abs(3 - noteData));
			noteData = Std.int(Math.abs(3 - noteData));
		}

		// JOELwindows7: consistenize capitalization for `optimize` pls.
		var daStage:String = ((PlayState.instance != null && !PlayStateChangeables.optimize) ? PlayState.Stage.curStage : 'stage');

		// defaults if no noteStyle was found in chart
		noteTypeCheck = 'normal';

		if (inCharter)
		{
			// JOELwindows7: sussy frames for special noteType
			// var fuckingSussy = Paths.getSparrowAtlas('noteskins/saubo/NOTE_assets_special');
			// for(amogus in fuckingSussy.frames)
			// {
			// 	this.frames.pushFrame(amogus);
			// }

			// frames = Paths.getSparrowAtlas('NOTE_assets');
			// JOELwindows7: noteType speziale
			switch (noteType)
			{
				// case -1:
				// receptor. use below play animation!
				// case 0:
				// normal. use default!
				// case 1:
				// powerup special
				case 2 | 4:
					Debug.logTrace("Whoah dude they adds mine?");
					frames = PlayState.noteskinSpriteMine != null ? PlayState.noteskinSpriteMine : NoteskinHelpers.generateNoteskinSprite(FlxG.save.data.noteskin,
						noteType);
					// frames = PlayState.noteskinSpriteMine;
					Debug.logTrace("Mine graphic loaded");
				// TODO: other note types! special 1, important 3, never 4, etc.
				// case 3: // important
				// case 4: // never
				// case 5: // reserved unknown etc.
				default:
					frames = PlayState.noteskinSprite != null ? PlayState.noteskinSprite : NoteskinHelpers.generateNoteskinSprite(FlxG.save.data.noteskin,
						noteType);
					// frames = PlayState.noteskinSprite;
			}
			// frames = PlayState.noteskinSprite;
			// frames = NoteskinHelpers.generateNoteskinSprite(FlxG.save.data.noteskin, noteType);

			for (i in 0...4)
			{
				if (noteType < 0)
					animation.addByPrefix(dataColor[i] + 'static', 'arrow' + dataColorDir[i]); // Receptor notes
				animation.addByPrefix(dataColor[i] + 'Scroll', dataColor[i] + ' alone'); // Normal notes
				animation.addByPrefix(dataColor[i] + 'hold', dataColor[i] + ' hold'); // Hold
				animation.addByPrefix(dataColor[i] + 'holdend', dataColor[i] + ' tail'); // Tails
			}

			setGraphicSize(Std.int(width * 0.7));
			updateHitbox();
			antialiasing = FlxG.save.data.antialiasing;
			// Debug.logTrace("Charter note yau");
		}
		else
		{
			if (PlayState.SONG != null)
			{
				if (PlayState.SONG.noteStyle == null)
				{
					switch (PlayState.storyWeek)
					{
						case 6:
							noteTypeCheck = 'pixel';
					}
				}
				else
				{
					noteTypeCheck = PlayState.SONG.noteStyle;
				}
			}
			else
			{
				noteTypeCheck = 'normal';
			}

			switch (noteTypeCheck)
			{
				case 'pixel':
					// JOELwindows7: resafety check I guess.
					loadGraphic(PlayState.noteskinPixelSprite != null ? PlayState.noteskinPixelSprite : NoteskinHelpers.generatePixelSprite(FlxG.save.data.noteskin,
						false, noteType),
						true, 17, 17);
					if (isSustainNote)
						loadGraphic(PlayState.noteskinPixelSpriteEnds != null ? PlayState.noteskinPixelSpriteEnds : NoteskinHelpers.generatePixelSprite(FlxG.save.data.noteskin,
							true, noteType),
							true, 7, 6);

					for (i in 0...4)
					{
						animation.add(dataColor[i] + 'Scroll', [i + 4]); // Normal notes
						animation.add(dataColor[i] + 'hold', [i]); // Holds
						if (noteType < 0)
							animation.add(dataColor[i] + 'static', [i]); // Receptor notes (if it uses main sprite)
						animation.add(dataColor[i] + 'holdend', [i + 4]); // Tails
					}

					setGraphicSize(Std.int(width * CoolUtil.daPixelZoom));
					updateHitbox();
				// case 'saubo':
				// 	// JOELwindows7: sussy frames for special noteType
				// 	// var fuckingSussy = Paths.getSparrowAtlas('noteskins/saubo/NOTE_assets_special');
				// 	// for(amogus in fuckingSussy.frames)
				// 	// {
				// 	// 	this.frames.pushFrame(amogus);
				// 	// }

				// 	// JOELwindows7: LFM original noteskin
				// 	// frames = Paths.getSparrowAtlas('noteskins/saubo/NOTE_assets');
				// 	// JOELwindows7: noteType speziale
				// 	switch (noteType)
				// 	{
				// 		case 2:
				// 			frames = Paths.getSparrowAtlas('noteskins/saubo/NOTE_assets_special');
				// 		default:
				// 			frames = Paths.getSparrowAtlas('noteskins/saubo/NOTE_assets');
				// 	}
				// 	// frames = PlayState.noteskinSprite;

				// 	for (i in 0...4)
				// 	{
				// 		animation.addByPrefix(dataColor[i] + 'Scroll', dataColor[i] + ' alone'); // Normal notes
				// 		animation.addByPrefix(dataColor[i] + 'hold', dataColor[i] + ' hold'); // Hold
				// 		animation.addByPrefix(dataColor[i] + 'holdend', dataColor[i] + ' tail'); // Tails
				// 	}

				// 	setGraphicSize(Std.int(width * 0.7));
				// 	updateHitbox();
				// 	antialiasing = FlxG.save.data.antialiasing;
				default:
					// JOELwindows7: sussy frames for special noteType
					// var fuckingSussy = Paths.getSparrowAtlas('NOTE_assets_special');
					// for(amogus in fuckingSussy.frames)
					// {
					// 	this.frames.pushFrame(amogus);
					// }

					// frames = Paths.getSparrowAtlas('NOTE_assets');
					// JOELwindows7: noteType speziale
					// switch(noteType){
					// 	case 2:
					// 		frames = Paths.getSparrowAtlas('NOTE_assets_special');
					// 	default:
					// 		frames = Paths.getSparrowAtlas('NOTE_assets');
					// }
					// JOELwindows7: okay fine, let's put here, how about that?
					// frames = PlayState.SONG.useCustomNoteStyle ? Paths.getSparrowAtlas('noteskins/' + PlayState.SONG.noteStyle) : PlayState.noteskinSprite;
					// JOELwindows7: okay let's be advanced
					switch (noteType)
					{
						case 2 | 4:
							// frames = PlayState.SONG.useCustomNoteStyle ? Paths.getSparrowAtlas(NoteSkinHelpers.giveMeNoteSkinPath(noteType) +
							// 	'-mine') : PlayState.noteskinSpriteMine;
							// frames = PlayState.SONG.useCustomNoteStyle ? NoteskinHelpers.generateNoteskinSpriteFromSay(PlayState.SONG.noteStyle, noteType,
							// 	PlayState.SONG.loadNoteStyleOtherWayAround) : PlayState.noteskinSpriteMine;
							frames = PlayState.noteskinSpriteMine; // JOELwindows7: smaller memory footprint
						default:
							// frames = PlayState.SONG.useCustomNoteStyle ? Paths.getSparrowAtlas(NoteSkinHelpers.giveMeNoteSkinPath(noteType)) : PlayState.noteskinSprite;
							// frames = PlayState.SONG.useCustomNoteStyle ? NoteskinHelpers.generateNoteskinSpriteFromSay(PlayState.SONG.noteStyle, noteType,
							// 	PlayState.SONG.loadNoteStyleOtherWayAround) : PlayState.noteskinSprite;
							frames = PlayState.noteskinSprite; // JOELwindows7: smaller memory footprint
					}

					for (i in 0...4)
					{
						if (noteType < 0)
							animation.addByPrefix(dataColor[i] + 'static', 'arrow' + dataColorDir[i]); // Receptor notes
						animation.addByPrefix(dataColor[i] + 'Scroll', dataColor[i] + ' alone'); // Normal notes
						animation.addByPrefix(dataColor[i] + 'hold', dataColor[i] + ' hold'); // Hold
						animation.addByPrefix(dataColor[i] + 'holdend', dataColor[i] + ' tail'); // Tails
					}

					setGraphicSize(Std.int(width * 0.7));
					updateHitbox();

					antialiasing = FlxG.save.data.antialiasing;
			}
		}

		// x += swagWidth * noteData;
		x += swagWidth * (noteData % 4); // JOELwindows7: idk why BOLO has this here, idk.. note row id modulo how many row we had..

		// animation.play(dataColor[noteData] + 'Scroll');
		animation.play(dataColor[noteData] + (noteType < 0 ? 'static' : 'Scroll')); // JOELwindows7: NOW CAN PLAY STATIC NOTES

		originColor = noteData; // The note's origin color will be checked by its sustain notes

		// JOELwindows7: whoa, the PlayState.instance can be null! make sure be careful
		// JOELwindows7: okay we still have to quantize color.
		// if (FlxG.save.data.stepMania
		// 	&& !isSustainNote
		// 	&& ((FlxG.save.data.forceStepmania) ? true : ((PlayState.instance != null) ? !(PlayState.instance.executeModchart
		// 		|| PlayState.instance.executeModHscript) : true)))
		// JOELwindows7: huh! turns out Kade decided to not quantize note if any modchart is running.
		// perhaps for authenticity in retransform craze, due to to this quantization only select other arrow,
		// and rotates it which dislodge the supposed original angle. idk just saying.
		// Okay, now I have installed force option. idk this still not recommended because again, pre-rotate messes up your rotation
		// craze calculations!
		if (FlxG.save.data.stepMania
			&& !noQuantize // JOELwindows7: yey tester no quantization
			&& !isSustainNote
			&& !(PlayState.instance != null ? (PlayState.instance.executeModchart || PlayState.instance.executeModHscript) : false))
		{
			var col:Int = 0;

			var beatRow = Math.round(beat * 48);

			// STOLEN ETTERNA CODE (IN 2002)

			if (beatRow % (192 / 4) == 0)
				col = quantityColor[0];
			else if (beatRow % (192 / 8) == 0)
				col = quantityColor[2];
			else if (beatRow % (192 / 12) == 0)
				col = quantityColor[4];
			else if (beatRow % (192 / 16) == 0)
				col = quantityColor[6];
			else if (beatRow % (192 / 24) == 0)
				col = quantityColor[4];
			else if (beatRow % (192 / 32) == 0)
				col = quantityColor[4];

			// animation.play(dataColor[col] + 'Scroll');
			animation.play(dataColor[col] + (noteType < 0 ? 'static' : 'Scroll')); // JOELwindows7: NOW CAN PLAY STATIC NOTES
			if (FlxG.save.data.rotateSprites)
			{
				localAngle -= arrowAngles[col];
				localAngle += arrowAngles[noteData];
				originAngle = localAngle;
			}
			originColor = col;
		}

		// we make sure its downscroll and its a SUSTAIN NOTE (aka a trail, not a note)
		// and flip it so it doesn't look weird.
		// THIS DOESN'T FUCKING FLIP THE NOTE, CONTRIBUTERS DON'T JUST COMMENT THIS OUT JESUS
		// then what is this lol
		// BRO IT LITERALLY SAYS IT FLIPS IF ITS A TRAIL AND ITS DOWNSCROLL
		if (FlxG.save.data.downscroll && sustainNote)
			flipY = true;

		var stepHeight = (((0.45 * Conductor.stepCrochet)) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? PlayState.SONG.speed : PlayStateChangeables.scrollSpeed,
			2)) / PlayState.songMultiplier;

		if (isSustainNote && prevNote != null)
		{
			// noteYOff = Math.round(-stepHeight + swagWidth * 0.5) + FlxG.save.data.offset + PlayState.songOffset;
			noteYOff = -stepHeight + swagWidth * 0.5; // JOELwindows7: hey, BOLO got this instead...

			noteScore * 0.2;
			alpha = 0.6;

			x += width / 2;

			originColor = prevNote.originColor;
			originAngle = prevNote.originAngle;

			animation.play(dataColor[originColor] + 'holdend'); // This works both for normal colors and quantization colors
			updateHitbox();

			x -= width / 2;

			// if (noteTypeCheck == 'pixel')
			//	x += 30;
			if (inCharter)
				x += 30;

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play(dataColor[prevNote.originColor] + 'hold');
				prevNote.updateHitbox();

				prevNote.scale.y *= stepHeight / prevNote.height;
				prevNote.updateHitbox();

				if (antialiasing)
				{
					// prevNote.scale.y *= 1.0 + (1.0 / prevNote.frameHeight);
					// JOELwindows7: BOLO note offseting antialiasing
					switch (FlxG.save.data.noteskin)
					{
						case 0:
							prevNote.scale.y *= 1.0064 + (1.0 / prevNote.frameHeight);
						default:
							prevNote.scale.y *= 0.995 + (1.0 / prevNote.frameHeight);
					}
				}

				// JOELwindows7: BOLO update all hitbox one last time
				prevNote.updateHitbox();
				updateHitbox();
			}
		}

		// Debug.logTrace("NOte newed enojy");

		// JOELwindows7: update all hitbox one last time
		updateHitbox();
	}

	override function update(elapsed:Float)
	{
		// JOELwindows7: INCOMING! BOLO STUFF FIXES
		// This updates hold notes height to current scroll Speed in case of scroll Speed changes.

		var newStepHeight = (((0.45 * PlayState.fakeNoteStepCrochet)) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? PlayState.SONG.speed : PlayStateChangeables.scrollSpeed,
			2)) * PlayState.songMultiplier;

		if (stepHeight != newStepHeight)
		{
			stepHeight = newStepHeight;
			if (isSustainNote)
			{
				// noteYOff = Math.round(-stepHeight + swagWidth * 0.5) + FlxG.save.data.offset + PlayState.songOffset;
				noteYOff = -stepHeight + swagWidth * 0.5;
			}
		}

		super.update(elapsed);
		// JOELwindows7: mine rotate pls
		if (!totalOverride)
		{ // JOELwindows7: here total override, if on forget special parameter!
			if (noteType == 0)
			{
				// JOELwindows7: This is normal mote!
				if (!modifiedByLua)
					angle = modAngle + localAngle;
				else
					angle = modAngle;

				// JOELwindows7: sneaky little punk! you can't get away from this! with BOLO tooLate
				if (!modifiedByLua)
				{
					if (!sustainActive && tooLate)
					{
						alpha = 0.3;
						// IDEA: JOELwindows7: tween alpha or animate the sustain bar, like
						// cell died creepily, deflatingly, something something turns dark & rot
						// instantly idk..
					}
				}
			}
			else
			{
				// JOELwindows7: spin mine!!! and other deadly & useful notes
				angularVelocity = switch (noteType)
				{
					case -1: // receptor
						0;
					case 1: // powerup
						0;
					case 2: // mine
						360;
					case 3: // important
						0;
					case 4: // never
						720;
					default:
						360;
				};

				// TODO: JOELwindows7: thing
				// lift note. note breaths in & out

				if (!modifiedByLua)
				{
					// angle += (modAngle + localAngle);
				}
				else
				{
					// angle += modAngle;
				}

				// JOELwindows7: sneaky little punk! you can't get away from this!
				if (!modifiedByLua)
				{
					if (!sustainActive && tooLate)
					{
						alpha = .3; // JOELwindows7: was 1
					}
				}
			}
		}

		if (mustPress)
		{
			if (isSustainNote)
			{
				if (strumTime - Conductor.songPosition <= (((166 * Conductor.timeScale) / (PlayState.songMultiplier < 1 ? PlayState.songMultiplier : 1) * 0.5))
					&& strumTime - Conductor.songPosition >= (((-166 * Conductor.timeScale) / (PlayState.songMultiplier < 1 ? PlayState.songMultiplier : 1))))
					canBeHit = true;
				else
					canBeHit = false;
			}
			else
			{
				if (strumTime - Conductor.songPosition <= (((166 * Conductor.timeScale) / (PlayState.songMultiplier < 1 ? PlayState.songMultiplier : 1)))
					&& strumTime - Conductor.songPosition >= (((-166 * Conductor.timeScale) / (PlayState.songMultiplier < 1 ? PlayState.songMultiplier : 1))))
					canBeHit = true;
				else
					canBeHit = false;
			}
			/*if (strumTime - Conductor.songPosition < (-166 * Conductor.timeScale) && !wasGoodHit)
				tooLate = true; */
		}
		else
		{
			canBeHit = false;
			// if (strumTime <= Conductor.songPosition)
			//	wasGoodHit = true;
		}

		if (tooLate && !wasGoodHit)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}

	// JOELwindows7: refresh Note
	public function refreshNoteLook()
	{
		if (inCharter)
		{
			// JOELwindows7: PLEASE!! JUST REFRESH 'EM UP!

			// JOELwindows7: noteType speziale
			switch (noteType)
			{
				case 2 | 4:
					// frames = Paths.getSparrowAtlas('NOTE_assets_special');
					frames = PlayState.noteskinSpriteMine != null ? PlayState.noteskinSpriteMine : NoteskinHelpers.generateNoteskinSprite(FlxG.save.data.noteskin,
						2);
				default:
					// frames = PlayState.noteskinSprite;
					frames = PlayState.noteskinSprite != null ? PlayState.noteskinSprite : NoteskinHelpers.generateNoteskinSprite(FlxG.save.data.noteskin, 0);
			}
			// frames = PlayState.noteskinSprite;

			for (i in 0...4)
			{
				if (noteType < 0)
					animation.addByPrefix(dataColor[i] + 'static', 'arrow' + dataColorDir[i]); // Receptor notes
				animation.addByPrefix(dataColor[i] + 'Scroll', dataColor[i] + ' alone'); // Normal notes
				animation.addByPrefix(dataColor[i] + 'hold', dataColor[i] + ' hold'); // Hold
				animation.addByPrefix(dataColor[i] + 'holdend', dataColor[i] + ' tail'); // Tails
			}

			setGraphicSize(Std.int(width * 0.7));
			updateHitbox();
			antialiasing = FlxG.save.data.antialiasing;
		}
		else
		{
			if (PlayState.SONG != null)
			{
				if (PlayState.SONG.noteStyle == null)
				{
					switch (PlayState.storyWeek)
					{
						case 6:
							noteTypeCheck = 'pixel';
					}
				}
				else
				{
					noteTypeCheck = PlayState.SONG.noteStyle;
				}
			}
			else
			{
				noteTypeCheck = 'normal';
			}

			switch (noteTypeCheck)
			{
				case 'pixel':
					// JOELwindows7: resafety check I guess.
					// loadGraphic(PlayState.noteskinPixelSprite, true, 17, 17);
					// TODO: revamp this noter pixel! combine!
					switch (noteType)
					{
						case 2 | 4:
							loadGraphic(PlayState.noteskinPixelSpriteMine != null ? PlayState.noteskinPixelSpriteMine : NoteskinHelpers.generatePixelSprite(FlxG.save.data.noteskin,
								false, noteType),
								true, 17, 17);
							if (isSustainNote) // loadGraphic(PlayState.noteskinPixelSpriteEnds, true, 7, 6);
								loadGraphic(PlayState.noteskinPixelSpriteEndsMine != null ? PlayState.noteskinPixelSpriteEndsMine : NoteskinHelpers.generatePixelSprite(FlxG.save.data.noteskin,
									true, noteType),
									true, 7, 6);
						default:
							loadGraphic(PlayState.noteskinPixelSprite != null ? PlayState.noteskinPixelSprite : NoteskinHelpers.generatePixelSprite(FlxG.save.data.noteskin,
								false, noteType),
								true, 17, 17);
							if (isSustainNote) // loadGraphic(PlayState.noteskinPixelSpriteEnds, true, 7, 6);
								loadGraphic(PlayState.noteskinPixelSpriteEnds != null ? PlayState.noteskinPixelSpriteEnds : NoteskinHelpers.generatePixelSprite(FlxG.save.data.noteskin,
									true, noteType),
									true, 7, 6);
					}

					for (i in 0...4)
					{
						animation.add(dataColor[i] + 'Scroll', [i + 4]); // Normal notes
						animation.add(dataColor[i] + 'hold', [i]); // Holds
						if (noteType < 0)
							animation.add(dataColor[i] + 'static', [i]); // Receptor notes (if it uses main sprite)
						animation.add(dataColor[i] + 'holdend', [i + 4]); // Tails
					}

					setGraphicSize(Std.int(width * CoolUtil.daPixelZoom));
					updateHitbox();
				// case 'saubo':
				// 	// JOELwindows7: sussy frames for special noteType
				// 	// var fuckingSussy = Paths.getSparrowAtlas('noteskins/saubo/NOTE_assets_special');
				// 	// for(amogus in fuckingSussy.frames)
				// 	// {
				// 	// 	this.frames.pushFrame(amogus);
				// 	// }

				// 	// JOELwindows7: LFM original noteskin
				// 	frames = Paths.getSparrowAtlas('noteskins/saubo/NOTE_assets');
				// 	// JOELwindows7: noteType speziale
				// 	switch (noteType)
				// 	{
				// 		case 2:
				// 			frames = Paths.getSparrowAtlas('noteskins/saubo/NOTE_assets_special');
				// 		default:
				// 			frames = Paths.getSparrowAtlas('noteskins/saubo/NOTE_assets');
				// 	}
				// 	// frames = PlayState.noteskinSprite;

				// 	for (i in 0...4)
				// 	{
				// 		animation.addByPrefix(dataColor[i] + 'Scroll', dataColor[i] + ' alone'); // Normal notes
				// 		animation.addByPrefix(dataColor[i] + 'hold', dataColor[i] + ' hold'); // Hold
				// 		animation.addByPrefix(dataColor[i] + 'holdend', dataColor[i] + ' tail'); // Tails
				// 	}

				// 	setGraphicSize(Std.int(width * 0.7));
				// 	updateHitbox();
				// 	antialiasing = FlxG.save.data.antialiasing;
				default:
					// JOELwindows7: sussy frames for special noteType
					// var fuckingSussy = Paths.getSparrowAtlas('NOTE_assets_special');
					// for(amogus in fuckingSussy.frames)
					// {
					// 	this.frames.pushFrame(amogus);
					// }

					// frames = Paths.getSparrowAtlas('NOTE_assets');
					// JOELwindows7: noteType speziale
					// switch(noteType){
					// 	case 2:
					// 		frames = Paths.getSparrowAtlas('NOTE_assets_special');
					// 	default:
					// 		frames = Paths.getSparrowAtlas('NOTE_assets');
					// }
					// frames = PlayState.noteskinSprite;
					// JOELwindows7: okay fine, let's put here, how about that?
					// frames = PlayState.SONG.useCustomNoteStyle ? Paths.getSparrowAtlas('noteskins/' + PlayState.SONG.noteStyle) : PlayState.noteskinSprite;
					// JOELwindows7: okay let's be advanced
					switch (noteType)
					{
						case 2 | 4:
							frames = PlayState.SONG.useCustomNoteStyle ? Paths.getSparrowAtlas('noteskins/' + PlayState.SONG.noteStyle +
								'-mine') : PlayState.noteskinSpriteMine;
						// frames = PlayState.noteskinSpriteMine;
						default:
							frames = PlayState.SONG.useCustomNoteStyle ? Paths.getSparrowAtlas('noteskins/' +
								PlayState.SONG.noteStyle) : PlayState.noteskinSprite;
							// frames = PlayState.noteskinSprite;
					}

					for (i in 0...4)
					{
						if (noteType < 0)
							animation.addByPrefix(dataColor[i] + 'static', 'arrow' + dataColorDir[i]); // Receptor notes
						animation.addByPrefix(dataColor[i] + 'Scroll', dataColor[i] + ' alone'); // Normal notes
						animation.addByPrefix(dataColor[i] + 'hold', dataColor[i] + ' hold'); // Hold
						animation.addByPrefix(dataColor[i] + 'holdend', dataColor[i] + ' tail'); // Tails
					}

					setGraphicSize(Std.int(width * 0.7));
					updateHitbox();

					antialiasing = FlxG.save.data.antialiasing;
			}
		}
		// JOELwindows7: update all hitbox one last time
		updateHitbox();
	}
}

// JOELwindows7: Pls noteskin file
typedef NoteskinFile =
{
	/*
		JSON

			{
			"name": "empty",
			"displayName": "Template Noteskins JSON",
			"noteskinPath": "Arrows",
			"noteskinMinePath": "Arrows-mine",
			"noteskinImportantPath": "",
			"noteskinNeverPath": "",
			"noteskinSpecialPath": "",
			"splashPath": "'Arrows-splash",
			"splashMinePath": "Arrows-splash-duar",
			"isPixel": false
			}
	 */
	// var arrows:String;
	// var mines:String;
	// var nevers:String;
	// var important:String;
	var name:String;
	var ?displayName:String;
	var noteskinPath:String;
	var noteskinMinePath:String;
	var noteskinImportantPath:String;
	var splashPath:String;
	var ?splashMinePath:String;
	var isPixel:Bool;
}
