trace(PlayState.rep.path);
            PlayState.rep = Replay.LoadReplay(PlayState.rep.path);

            PlayState.loadRep = true;
            PlayState.isSM = PlayState.rep.replay.sm;

            var songFormat = StringTools.replace(PlayState.rep.replay.songName, " ", "-");
            switch (songFormat) {
                case 'Dad-Battle': songFormat = 'Dadbattle';
                case 'Philly-Nice': songFormat = 'Philly';
                    // Replay v1.0 support
                case 'dad-battle': songFormat = 'Dadbattle';
                case 'philly-nice': songFormat = 'Philly';
            }

			var songHighscore = StringTools.replace(PlayState.SONG.song, " ", "-");
			switch (songHighscore) {
				case 'Dad-Battle': songHighscore = 'Dadbattle';
				case 'Philly-Nice': songHighscore = 'Philly';
			}

			#if !switch
			Highscore.saveScore(songHighscore, Math.round(PlayState.instance.songScore), PlayState.storyDifficulty);
			Highscore.saveCombo(songHighscore, Ratings.GenerateLetterRank(PlayState.instance.accuracy),PlayState.storyDifficulty);
			#end

            #if sys
            if (PlayState.rep.replay.sm)
                if (!FileSystem.exists(StringTools.replace(PlayState.rep.replay.chartPath,"converted.json","")))
                {
                    Application.current.window.alert("The SM file in this replay does not exist!","SM Replays");
                    return;
                }
            #end

            var poop = "";

            #if sys
            if (PlayState.isSM)
            {
                poop = File.getContent(PlayState.rep.replay.chartPath);
                try
                    {
                PlayState.sm = SMFile.loadFile(PlayState.pathToSm + "/" + StringTools.replace(PlayState.rep.replay.songName," ", "_") + ".sm");
                    }
                    catch(e:Exception)
                    {
                        Application.current.window.alert("Make sure that the SM file is called " + PlayState.pathToSm + "/" + StringTools.replace(PlayState.rep.replay.songName," ", "_") + ".sm!\nAs I couldn't read it.","SM Replays");
                        return;
                    }
            }
            else
                poop = Highscore.formatSong(songFormat, PlayState.rep.replay.songDiff);
            #else
            poop = Highscore.formatSong(PlayState.rep.replay.songName, PlayState.rep.replay.songDiff);
            #end

            music.fadeOut(0.3);

            if (PlayState.isSM)
                PlayState.SONG = Song.conversionChecks(Song.loadFromJsonRAW(poop));
            else
                PlayState.SONG = Song.conversionChecks(Song.loadFromJson(poop, PlayState.rep.replay.songName));
            PlayState.isStoryMode = false;
            PlayState.storyDifficulty = PlayState.rep.replay.songDiff;
            LoadingState.loadAndSwitchState(new PlayState());

            PlayState.instance.clean();
            haveViewReplayed = false;