package;

import flixel.FlxG;

using StringTools;

class Highscore
{
	#if (haxe >= "4.0.0")
	public static var songScores:Map<String, Int> = new Map();
	public static var songCombos:Map<String, String> = new Map();
	// JOELwindows7: BOLO has more
	// https://github.com/BoloVEVO/Kade-Engine-Public/blame/stable/source/Highscore.hx
	public static var songAcc:Map<String, Float> = new Map();
	public static var songLetter:Map<String, String> = new Map();
	#else
	public static var songScores:Map<String, Int> = new Map<String, Int>();
	public static var songCombos:Map<String, String> = new Map<String, String>();
	// JOELwindows7: yeah
	public static var songAcc:Map<String, Float> = new Map<String, Float>;
	public static var songLetter:Map<String, String> = new Map<String, String>;
	#end

	public static function saveScore(song:String, score:Int = 0, ?diff:Int = 0):Void
	{
		var daSong:String = formatSong(song, diff);

		if (!FlxG.save.data.botplay)
		{
			if (songScores.exists(daSong))
			{
				if (songScores.get(daSong) < score)
					setScore(daSong, score);
			}
			else
				setScore(daSong, score);
		}
		else
			trace('BotPlay detected. Score saving is disabled.');
	}

	// JOELwindows7: BOLO save accuracy
	public static function saveAcc(song:String, accuracy:Float, ?diff:Int = 0):Void
	{
		var daSong:String = formatSong(song, diff);

		if (songAcc.exists(daSong))
		{
			if (songAcc.get(daSong) < accuracy)
				setAcc(daSong, accuracy);
		}
		else
		{
			setAcc(daSong, accuracy);
		}
	}

	// JOELwindows7: BOLO save letter
	public static function saveLetter(song:String, letter:String, ?diff:Int = 0):Void
	{
		var daSong:String = formatSong(song, diff);

		if (songLetter.exists(daSong))
		{
			if (getLetterInt(songLetter.get(daSong)) < getLetterInt(letter))
				setLetter(daSong, letter);
		}
		else
		{
			setLetter(daSong, letter);
		}
	}

	public static function saveCombo(song:String, combo:String, ?diff:Int = 0):Void
	{
		var daSong:String = formatSong(song, diff);
		var finalCombo:String = combo.split(')')[0].replace('(', '');

		if (!FlxG.save.data.botplay)
		{
			if (songCombos.exists(daSong))
			{
				if (getComboInt(songCombos.get(daSong)) < getComboInt(finalCombo))
					setCombo(daSong, finalCombo);
			}
			else
				setCombo(daSong, finalCombo);
		}
	}

	public static function saveWeekScore(week:Int = 1, score:Int = 0, ?diff:Int = 0):Void
	{
		if (!FlxG.save.data.botplay)
		{
			var daWeek:String = formatSong('week' + week, diff);

			if (songScores.exists(daWeek))
			{
				if (songScores.get(daWeek) < score)
					setScore(daWeek, score);
			}
			else
				setScore(daWeek, score);
		}
		else
			trace('BotPlay detected. Score saving is disabled.');
	}

	// JOELwindows7: for future use, with new week name.
	public static function saveWeekScoreNamed(week:String = '1', score:Int = 0, ?diff:Int = 0):Void
	{
		if (!FlxG.save.data.botplay)
		{
			var daWeek:String = formatSong('week' + week, diff);

			if (songScores.exists(daWeek))
			{
				if (songScores.get(daWeek) < score)
					setScore(daWeek, score);
			}
			else
				setScore(daWeek, score);
		}
		else
			trace('BotPlay detected. Score saving is disabled.');
	}

	/**
	 * YOU SHOULD FORMAT SONG WITH formatSong() BEFORE TOSSING IN SONG VARIABLE
	 */
	static function setScore(song:String, score:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songScores.set(song, score);
		FlxG.save.data.songScores = songScores;
		FlxG.save.flush();
	}

	// JOELwindows7: BOLO set letter
	static function setLetter(song:String, letter:String):Void
	{
		songLetter.set(song, letter);
		FlxG.save.data.songLetter = songLetter;
		FlxG.save.flush();
	}

	static function setCombo(song:String, combo:String):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songCombos.set(song, combo);
		FlxG.save.data.songCombos = songCombos;
		FlxG.save.flush();
	}

	// JOELwindows7: BOLO set accuracy
	static function setAcc(song:String, accuracy:Float):Void
	{
		songAcc.set(song, accuracy);
		FlxG.save.data.songAcc = songAcc;
		FlxG.save.flush();
	}

	public static function formatSong(song:String, diff:Int):String
	{
		var daSong:String = song;

		if (diff == 0)
			daSong += '-easy';
		else if (diff == 2)
			daSong += '-hard';

		return daSong;
	}

	// JOELwindows7: BOLO get letter int
	static function getLetterInt(letter:String):Int
	{
		switch (letter)
		{
			case 'D':
				return 0;
			case 'C':
				return 1;
			case 'B':
				return 2;
			case 'A':
				return 3;
			case 'A.':
				return 4;
			case 'A:':
				return 5;
			case 'AA':
				return 6;
			case 'AA.':
				return 7;
			case 'AA:':
				return 8;
			case 'AAA':
				return 9;
			case 'AAA.':
				return 10;
			case 'AAA:':
				return 11;
			case 'AAAA':
				return 12;
			case 'AAAA.':
				return 13;
			case 'AAAA:':
				return 14;
			case 'AAAAA':
				return 15;
			default:
				return -1;
		}
	}

	static function getComboInt(combo:String):Int
	{
		switch (combo)
		{
			// JOELwindows7: BOLO oh.
			case 'Clear':
				return 0; // just clear.
			case 'SDCB': // single digit combo break
				return 1;
			case 'FC': // full combo
				return 2;
			case 'GFC': // great full combo
				return 3;
			case 'MFC': // marvelous full combo
				return 4;
			// JOELwindows7: now additional ones!
			case 'LFC': // ludicrous full combo
				return 5;
			default: // no combo worth
				return -1; // JOELwindows7: okay -1, BOLO yess.
		}
	}

	// JOELwindows7: BOLO get accuracy
	public static function getAcc(song:String, diff:Int):Float
	{
		if (!songAcc.exists(formatSong(song, diff)))
			setAcc(formatSong(song, diff), 0);
		return songAcc.get(formatSong(song, diff));
	}

	// JOELwindows7: BOLO get letter
	public static function getLetter(song:String, diff:Int):String
	{
		if (!songLetter.exists(formatSong(song, diff)))
			setLetter(formatSong(song, diff), '');
		return songLetter.get(formatSong(song, diff));
	}

	public static function getScore(song:String, diff:Int):Int
	{
		if (!songScores.exists(formatSong(song, diff)))
			setScore(formatSong(song, diff), 0);

		return songScores.get(formatSong(song, diff));
	}

	public static function getCombo(song:String, diff:Int):String
	{
		if (!songCombos.exists(formatSong(song, diff)))
			setCombo(formatSong(song, diff), '');

		return songCombos.get(formatSong(song, diff));
	}

	public static function getWeekScore(week:Int, diff:Int):Int
	{
		if (!songScores.exists(formatSong('week' + week, diff)))
			setScore(formatSong('week' + week, diff), 0);

		return songScores.get(formatSong('week' + week, diff));
	}

	public static function load():Void
	{
		if (FlxG.save.data.songScores != null)
		{
			songScores = FlxG.save.data.songScores;
		}
		if (FlxG.save.data.songCombos != null)
		{
			songCombos = FlxG.save.data.songCombos;
		}
		// JOELwindows7: and BOLO's part
		if (FlxG.save.data.songAcc != null)
		{
			songAcc = FlxG.save.data.songAcc;
		}
		if (FlxG.save.data.songLetter != null)
		{
			songLetter = FlxG.save.data.songLetter;
		}
	}
}
