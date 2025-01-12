import flixel.FlxG;

class Ratings
{
	// JOELwindows7: BOLO generate combo rank!!!! wait, this is duplicate.
	// https://github.com/BoloVEVO/Kade-Engine-Public/blob/stable/source/Ratings.hx
	public static function GenerateComboRank(accuracy:Float) // generate a letter ranking
	{
		var comboranking:String = "N/A";
		if (PlayState.misses == 0 && PlayState.bads == 0 && PlayState.shits == 0 && PlayState.goods == 0) // Marvelous (SICK) Full Combo
			comboranking = "(MFC)";
		else if (PlayState.misses == 0 && PlayState.bads == 0 && PlayState.shits == 0 && PlayState.goods >= 1) // Good Full Combo (Nothing but Goods & Sicks)
			comboranking = "(GFC)";
		else if (PlayState.misses == 0) // Regular FC
			comboranking = "(FC)";
		else if (PlayState.misses < 10) // Single Digit Combo Breaks
			comboranking = "(SDCB)";
		else
			comboranking = "(Clear)";

		return comboranking;
		// WIFE TIME :)))) (based on Wife3)
	}

	// JOELwindows7: let's BOLO just letter rank
	// https://github.com/BoloVEVO/Kade-Engine-Public/blob/stable/source/Ratings.hx
	public static function GenerateJustLetterRank(accuracy:Float) // generate just a letter ranking
	{
		var letterRanking:String = "";
		var wifeConditions:Array<Bool> = [
			accuracy >= 99.9935, // AAAAA
			accuracy >= 99.980, // AAAA:
			accuracy >= 99.970, // AAAA.
			accuracy >= 99.955, // AAAA
			accuracy >= 99.90, // AAA:
			accuracy >= 99.80, // AAA.
			accuracy >= 99.70, // AAA
			accuracy >= 99, // AA:
			accuracy >= 96.50, // AA.
			accuracy >= 93, // AA
			accuracy >= 90, // A:
			accuracy >= 85, // A.
			accuracy >= 80, // A
			accuracy >= 70, // B
			accuracy >= 60, // C
			accuracy < 60 // D
		];

		for (i in 0...wifeConditions.length)
		{
			var b = wifeConditions[i];

			if (b)
			{
				switch (i)
				{
					case 0:
						letterRanking += "AAAAA";
					case 1:
						letterRanking += "AAAA:";
					case 2:
						letterRanking += "AAAA.";
					case 3:
						letterRanking += "AAAA";
					case 4:
						letterRanking += "AAA:";
					case 5:
						letterRanking += "AAA.";
					case 6:
						letterRanking += "AAA";
					case 7:
						letterRanking += "AA:";
					case 8:
						letterRanking += "AA.";
					case 9:
						letterRanking += "AA";
					case 10:
						letterRanking += "A:";
					case 11:
						letterRanking += "A.";
					case 12:
						letterRanking += "A";
					case 13:
						letterRanking += "B";
					case 14:
						letterRanking += "C";
					case 15:
						letterRanking += "D";
				}
				break;
			}
		}
		// JOELwindows7: FireTongue pls
		if (accuracy == 0 && !PlayStateChangeables.practiceMode)
			// letterRanking = "You suck lmao";
			letterRanking = CoolUtil.getText("$GAMEPLAY_RESULT_LETTER_RANKING_SUCK");
		else if (PlayStateChangeables.botPlay && !PlayState.loadRep)
			// letterRanking = "BotPlay";
			letterRanking = CoolUtil.getText("$GAMEPLAY_RESULT_LETTER_RANKING_BOTPLAY");
		else if (PlayStateChangeables.practiceMode)
			// letterRanking = "PRACTICE";
			letterRanking = CoolUtil.getText("$GAMEPLAY_RESULT_LETTER_RANKING_PRACTICE");
		return letterRanking;
	}

	public static function GenerateLetterRank(accuracy:Float) // generate a letter ranking
	{
		var ranking:String = "N/A";
		if (FlxG.save.data.botplay && !PlayState.loadRep)
			ranking = "BotPlay";

		if (PlayState.misses == 0 && PlayState.bads == 0 && PlayState.shits == 0 && PlayState.goods == 0) // Marvelous (SICK) Full Combo
			ranking = "(MFC)";
		else if (PlayState.misses == 0 && PlayState.bads == 0 && PlayState.shits == 0 && PlayState.goods >= 1) // Good Full Combo (Nothing but Goods & Sicks)
			ranking = "(GFC)";
		else if (PlayState.misses == 0) // Regular FC
			ranking = "(FC)";
		else if (PlayState.misses < 10) // Single Digit Combo Breaks
			ranking = "(SDCB)";
		else
			ranking = "(Clear)";

		// WIFE TIME :)))) (based on Wife3)

		var wifeConditions:Array<Bool> = [
			accuracy >= 99.9935, // AAAAA
			accuracy >= 99.980, // AAAA:
			accuracy >= 99.970, // AAAA.
			accuracy >= 99.955, // AAAA
			accuracy >= 99.90, // AAA:
			accuracy >= 99.80, // AAA.
			accuracy >= 99.70, // AAA
			accuracy >= 99, // AA:
			accuracy >= 96.50, // AA.
			accuracy >= 93, // AA
			accuracy >= 90, // A:
			accuracy >= 85, // A.
			accuracy >= 80, // A
			accuracy >= 70, // B
			accuracy >= 60, // C
			accuracy < 60 // D
		];

		for (i in 0...wifeConditions.length)
		{
			var b = wifeConditions[i];
			if (b)
			{
				switch (i)
				{
					case 0:
						ranking += " AAAAA";
					case 1:
						ranking += " AAAA:";
					case 2:
						ranking += " AAAA.";
					case 3:
						ranking += " AAAA";
					case 4:
						ranking += " AAA:";
					case 5:
						ranking += " AAA.";
					case 6:
						ranking += " AAA";
					case 7:
						ranking += " AA:";
					case 8:
						ranking += " AA.";
					case 9:
						ranking += " AA";
					case 10:
						ranking += " A:";
					case 11:
						ranking += " A.";
					case 12:
						ranking += " A";
					case 13:
						ranking += " B";
					case 14:
						ranking += " C";
					case 15:
						ranking += " D";
				}
				break;
			}
		}

		if (accuracy == 0)
			// ranking = "N/A";
			ranking = CoolUtil.getText("$ABBREVIATION_NOT_AVAILABLE");
		else if (FlxG.save.data.botplay && !PlayState.loadRep)
			ranking = "BotPlay";

		return ranking;
	}

	public static var timingWindows:Array<Float> = []; // JOELwindows7: hey, you forgot to type!

	// JOELwindows7: here judge heartbeat condition
	public static function judgeHeartBeat(heartBeat:Float, heartTier:Int)
	{
		var classify:String = "Nrml";
		switch (heartTier)
		{
			case -3:
				classify = "Disconnected";
			case -2:
				classify = "Dead";
			case -1:
				classify = "Brady";
			case 0:
				classify = "Nrml";
			case 1:
				classify = "Fast";
			case 2:
				classify = "Rcing";
			case 3:
				classify = "Poundn";
			case 4:
				classify = "Tachy";
			default:
				classify = "???";
		}

		return Std.string(HelperFunctions.truncateFloat(heartBeat, 2)) + " BPM (" + classify + ")";
	}

	// JOELwindows7: here judge metronome
	public static function judgeMetronome(curBeat:Int = 0, beatsInABar:Int = 4, formating:Bool = false):String
	{
		var say:String = '';
		if (curBeat >= 0)
		{
			for (i in 0...beatsInABar)
			{
				say += if (curBeat % beatsInABar == i)
				{
					(i == 0 ? (formating ? Perkedel.METRONOME_FIRST_SYNTAX : '') + Perkedel.METRONOME_FIRST_TICK_ICON
						+ (formating ? Perkedel.METRONOME_FIRST_SYNTAX : '') : (formating ? Perkedel.METRONOME_REST_SYNTAX : '')
							+ Perkedel.METRONOME_REST_TICK_ICON + (formating ? Perkedel.METRONOME_REST_SYNTAX : ''));
				}
				else
				{
					(i == 0 ? (formating ? Perkedel.METRONOME_OFF_SYNTAX : '') + Perkedel.METRONOME_FIRST_OFF_ICON
						+ (formating ? Perkedel.METRONOME_OFF_SYNTAX : '') : (formating ? Perkedel.METRONOME_OFF_SYNTAX : '')
							+ Perkedel.METRONOME_REST_OFF_ICON + (formating ? Perkedel.METRONOME_OFF_SYNTAX : ''));
				};
			}
			return say;
		}
		return "....";
	}

	// JOELwindows7: and the true false version of metronome. true if first beat in bar
	public static function judgeMetronomeDing(curBeat:Int = 0, beatsInABar:Int = 4):Bool
	{
		if (curBeat >= 0)
		{
			return (curBeat % beatsInABar == 0);
		}
		return false;
	}

	public static function judgeNote(noteDiff:Float)
	{
		var diff = Math.abs(noteDiff);
		// JOELwindows7: oh maybe you should also use non-absolute noteDiff to titld which direction it goes?
		// depending on how late or early you are... idk
		for (index in 0...timingWindows.length) // based on 4 timing windows, will break with anything else
		{
			var time = timingWindows[index];
			var nextTime = index + 1 > timingWindows.length - 1 ? 0 : timingWindows[index + 1];
			if (diff < time && diff >= nextTime)
			{
				switch (index)
				{
					case 0: // shit
						return "shit";
					case 1: // bad
						return "bad";
					case 2: // good
						return "good";
					case 3: // sick
						return "sick";
					// JOELwindows7: add more insane ratings like Stepmania & semi-vapourware Pulsen!
					// Those are Flawless (dank), Ludicrous (mvp, or maybe `JESUS CHRIST!` idk), etc.
					// Oh maybe it's safe, because the timing windows are only loaded 4 of them everytime this game
					// starts.
					case 4: // dank (Flawless)
						return "dank";
					case 5: // mvp (Ludicrous)
						return "mvp";
				}
			}
		}
		return "good";
	}

	// JOELwindows7: scored integered version of judgenote for those who need to count it
	public static function judgeNoteInt(noteDiff:Float):Int
	{
		var diff = Math.abs(noteDiff);
		// JOELwindows7: oh maybe you should also use non-absolute noteDiff to titld which direction it goes?
		// depending on how late or early you are... idk
		for (index in 0...timingWindows.length) // based on 4 timing windows, will break with anything else
		{
			var time = timingWindows[index];
			var nextTime = index + 1 > timingWindows.length - 1 ? 0 : timingWindows[index + 1];

			if (diff < time && diff >= nextTime)
			{
				// JOELwindows7: idk if I should let it wild.
				return index; // immediately stuff like that..
				// miss is zero. nvm, minus one!
				// switch (index)
				// {
				// 	case 0: // shit
				// 		return 1;
				// 	case 1: // bad
				// 		return 2;
				// 	case 2: // good
				// 		return 3;
				// 	case 3: // sick
				// 		return 4;
				// 	// JOELwindows7: add more insane ratings like Stepmania & semi-vapourware Pulsen!
				// 	// Those are Flawless (dank), Ludicrous (mvp, or maybe `JESUS CHRIST!` idk), etc.
				// 	// Oh maybe it's safe, because the timing windows are only loaded 4 of them everytime this game
				// 	// starts.
				// 	case 4: // dank (Flawless)
				// 		return 5;
				// 	case 5: // mvp (Ludicrous)
				// 		return 6;
				// }
			}
		}
		return 2;
	}

	public static function CalculateRanking(score:Int, scoreDef:Int, nps:Int, maxNPS:Int, accuracy:Float, hR:Float, hTier:Int):String
	{
		return (FlxG.save.data.npsDisplay ? // NPS Toggle
			"NPS: "
			+ nps
			+ " (Max "
			+ maxNPS
			+ ")"
			+ (!PlayStateChangeables.botPlay || PlayState.loadRep ? " | " : "") : "") + // 	NPS
			(!PlayStateChangeables.botPlay
				|| PlayState.loadRep ? "Score:" + (Conductor.safeFrames != 10 ? score + " (" + scoreDef + ")" : "" + score) + // Score
					(FlxG.save.data.accuracyDisplay ? // Accuracy Toggle
						// " | Combo Breaks: "
						' | ${CoolUtil.getText("$GAMEPLAY_RANKING_BAR_COMBO_BREAKS")}: '
						+ PlayState.misses
						+ // 	Misses/Combo Breaks
						// " | Accuracy: "
						' | ${CoolUtil.getText("$GAMEPLAY_RANKING_BAR_ACCURACY")}:'
						+ (PlayStateChangeables.botPlay
							&& !PlayState.loadRep ? CoolUtil.getText("$ABBREVIATION_NOT_AVAILABLE") : HelperFunctions.truncateFloat(accuracy, 2) + " %") // N/A
						+ // 	Accuracy
						" | "
						+ GenerateLetterRank(accuracy) : "") : "" // 	Letter Rank
					+ " " // JOELwindows7: spacer
					+ (!PlayStateChangeables.practiceMode ? '' : 'PRACTICE') // JOELwindows7: BOLO's Practive mode
			) // JOELwindows7: block ends
			+ (FlxG.save.data.cardiophile ? " | HR: " + judgeHeartBeat(hR, hTier) : "") // JOELwindows7: in game heartbeat rate

			;
	}
}
