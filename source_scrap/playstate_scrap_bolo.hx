// JOELwindows7: continue rest.
if (!daNote.modifiedByLua)
{
	if (PlayStateChangeables.useDownscroll)
	{
		/*
			if (daNote.mustPress)
				daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
					+
					0.45 * ((Conductor.songPosition - daNote.strumTime) / songMultiplier) * (FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
						2)))
					- daNote.noteYOff;
			else
				daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
					+
					0.45 * ((Conductor.songPosition - daNote.strumTime) / songMultiplier) * (FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
						2)))
					- daNote.noteYOff;
		 */
		// JOELwindows7: & so BOLO already has newer system for that note y positionalizier
		daNote.y = (strumY
			+
			0.45 * ((Conductor.songPosition - daNote.strumTime) / songMultiplier) * (FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
				2)))
			- daNote.noteYOff;
		// and there you go. more still comes here bellow!!!
		if (daNote.isSustainNote)
		{
			// JOELwindows7: Here's BOLO drastic edit here. and the message,
			// // Jesus Christ my head and it's still broken this shit FUCK.
			var bpmRatio = (SONG.bpm / 100);

			// daNote.y -= daNote.height - stepHeight;
			// JOELwindows7: BOLO incorporate bpmRatio to this now.
			daNote.y -= daNote.height - (1.5 * stepHeight / SONG.speed * bpmRatio);
			// If not in botplay, only clip sustain notes when properly hit, botplay gets to clip it everytime
			if ((daNote.sustainActive || !daNote.mustPress) && songStarted)
			{
				if ((PlayStateChangeables.botPlay
					|| !daNote.mustPress
					|| daNote.wasGoodHit
					|| holdArray[Math.floor(Math.abs(daNote.noteData))])
					&& daNote.y - daNote.offset.y * daNote.scale.y // + daNote.height >= (strumLine.y + Note.swagWidth / 2))
					+ daNote.height >= (origin)) // JOELwindows7: use above BOLO's origin already measured.
				{
					// Clip to strumline
					var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
					/*
						swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
							+ Note.swagWidth / 2
							- daNote.y) / daNote.scale.y;
					 */
					// JOELwindows7: New BOLO's swagRect height pls
					swagRect.height = (origin - daNote.y) / daNote.scale.y;
					swagRect.y = daNote.frameHeight - swagRect.height;
					daNote.clipRect = swagRect;
				}
			}
		}
	}
	else
	{
		// JOELwindows7: & so on. BOLO
		/*
			if (daNote.mustPress)
				daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
					- 0.45 * ((Conductor.songPosition - daNote.strumTime) / songMultiplier) * (FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
						2)))
					+ daNote.noteYOff;
			else
				daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
					- 0.45 * ((Conductor.songPosition - daNote.strumTime) / songMultiplier) * (FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
						2)))
					+ daNote.noteYOff;
		 */
		daNote.y = (strumY
			- 0.45 * ((Conductor.songPosition - daNote.strumTime) / songMultiplier) * (FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
				2)))
			+ daNote.noteYOff;
		if (daNote.isSustainNote)
		{
			if ((PlayStateChangeables.botPlay
				|| !daNote.mustPress
				|| daNote.wasGoodHit
				|| holdArray[Math.floor(Math.abs(daNote.noteData))]) // && daNote.y + daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2))
				&& daNote.y
				+ daNote.offset.y * daNote.scale.y <= (origin)) // JOELwindows7: again, BOLO's above origin
			{
				// Clip to strumline
				var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
				/*
					swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
						+ Note.swagWidth / 2
						- daNote.y) / daNote.scale.y;
				 */
				// JOELwindows7: new BOLO swagRect y position pls
				swagRect.y = (origin - daNote.y) / daNote.scale.y;
				swagRect.height -= swagRect.y;
				daNote.clipRect = swagRect;
			}
		}
	}
}


// JOELwindows7: Confustaron

				if (!daNote.mustPress && Conductor.songPosition >= daNote.strumTime)
				{
					if (SONG.songId != 'tutorial' && !PlayStateChangeables.optimize)
						camZooming = FlxG.save.data.camzoom; // JOELwindows7: was always true, now is BOLO's based on camzoom option.

					var altAnim:String = "";
					var curSection:Int = Math.floor((curStep / 16)); // JOELwindows7: grab curSection pls. BOLO

					if (daNote.isAlt)
					{
						altAnim = '-alt';
						trace("YOO WTF THIS IS AN ALT NOTE????");
					}

					// JOELwindows7: BOLO discord RPC
					#if FEATURE_DISCORD
					if (FlxG.save.data.discordMode == 1)
						DiscordClient.changePresence(SONG.songName
							+ " ("
							+ storyDifficultyText
							+ " "
							+ songMultiplier
							+ "x"
							+ ") " // + Ratings.GenerateComboRank(accuracy) + " " + Ratings.GenerateLetterRank(accuracy),
							+ Ratings.GenerateLetterRank(accuracy),
							"\nScr: "
							+ songScore
							+ " ("
							+ HelperFunctions.truncateFloat(accuracy, 2)
							+ "%)"
							+ " | Misses: "
							+ misses, iconRPC);
					#end

					// JOELwindows7: BOLO's health draineh
					if (PlayStateChangeables.healthDrain)
					{
						if (!daNote.isSustainNote)
							updateScoreText();
						if (!daNote.isSustainNote)
						{
							if (!PlayStateChangeables.opponentMode)
							{
								health -= .04 * PlayStateChangeables.healthLoss;
								if (health <= 0.01)
								{
									health = 0.01;
								}
							}
							else
							{
								health += .04 * PlayStateChangeables.healthLoss;
								if (health >= 2)
									health = 2;
							}
						}
						else
						{
							if (!PlayStateChangeables.opponentMode)
							{
								health -= .02 * PlayStateChangeables.healthLoss;
								if (health <= 0.01)
								{
									health = 0.01;
								}
							}
							else
							{
								health += .02 * PlayStateChangeables.healthLoss;
								if (health >= 2)
									health = 2;
							}
						}
					}

					// JOELwindows7: Do not step mine has been moved to `opponentNoteHit()`
					if (daNote.noteType != 2 || FlxG.random.bool(PlayStateChangeables.stupidityChances[1]))
					{ // JOELwindows7: do not step mine! player2
						// if stupidity chance is true, hit anyway.
						// Accessing the animation name directly to play it
						if (!daNote.isParent && daNote.parent != null)
						{
							if (daNote.spotInLine != daNote.parent.children.length - 1)
							{
								var singData:Int = Std.int(Math.abs(daNote.noteData));
								// dad.playAnim('sing' + dataSuffix[singData] + altAnim, true);
								// JOELwindows7: we got BOLO opponent mode now so pls check based on these pls
								if (!PlayStateChangeables.optimize)
								{
									if (PlayStateChangeables.opponentMode)
										boyfriend.playAnim('sing' + dataSuffix[singData] + altAnim, true);
									else
										dad.playAnim('sing' + dataSuffix[singData] + altAnim, true);
								}

								if (FlxG.save.data.cpuStrums)
								{
									cpuStrums.forEach(function(spr:StaticArrow)
									{
										pressArrow(spr, spr.ID, daNote);
										/*
											if (spr.animation.curAnim.name == 'confirm' && SONG.noteStyle != 'pixel')
											{
												spr.centerOffsets();
												spr.offset.x -= 13;
												spr.offset.y -= 13;
											}
											else
												spr.centerOffsets();
										 */
									});
								}

								#if FEATURE_LUAMODCHART
								if (luaModchart != null)
									luaModchart.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition, curBeat, curStep]);
								if (stageScript != null)
									stageScript.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition, curBeat, curStep]);
								#end
								if (hscriptModchart != null)
									hscriptModchart.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition, curBeat, curStep]);
								if (stageHscript != null)
									stageHscript.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition, curBeat, curStep]);
								// JOELwindows7: welp, gotta do this then! PLAYER TWO 2
								executeModchartState('characterSing', [
									!PlayStateChangeables.opponentMode ? 1 : 0,
									1,
									Math.abs(daNote.noteData),
									Conductor.songPosition,
									curBeat,
									curStep
								]);

								// dad.holdTimer = 0;
								// JOELwindows7: BOLO opponent hold timer
								if (!PlayStateChangeables.opponentMode)
									dad.holdTimer = 0;
								else
									boyfriend.holdTimer = 0;

								if (SONG.needsVoices)
									vocals.volume = 1;
								if (SONG.needsVoices2)
									vocals2.volume = 1; // JOELwindows7: ye
							}
						}
						else
						{
							// JOELwindows7: elsed
							var singData:Int = Std.int(Math.abs(daNote.noteData));
							// dad.playAnim('sing' + dataSuffix[singData] + altAnim, true);
							// JOELwindows7: BOLO new opponent mode play anim check
							if (!PlayStateChangeables.optimize)
							{
								if (PlayStateChangeables.opponentMode)
									boyfriend.playAnim('sing' + dataSuffix[singData] + altAnim, true);
								else
									dad.playAnim('sing' + dataSuffix[singData] + altAnim, true);
							}

							if (FlxG.save.data.cpuStrums)
							{
								cpuStrums.forEach(function(spr:StaticArrow)
								{
									pressArrow(spr, spr.ID, daNote);
									/*
										if (spr.animation.curAnim.name == 'confirm' && SONG.noteStyle != 'pixel')
										{
											spr.centerOffsets();
											spr.offset.x -= 13;
											spr.offset.y -= 13;
										}
										else
											spr.centerOffsets();
									 */
								});
							}

							// JOELwindows7: now BOLO changes the player sing which here! ORIGINALLY `playerTwoSing`
							#if FEATURE_LUAMODCHART
							if (luaModchart != null)
								if (!PlayStateChangeables.opponentMode)
									luaModchart.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition, curBeat, curStep]);
								else
									luaModchart.executeState('playerOneSing', [Math.abs(daNote.noteData), Conductor.songPosition, curBeat, curStep]);
							if (stageScript != null)
								if (!PlayStateChangeables.opponentMode)
									stageScript.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition, curBeat, curStep]);
								else
									stageScript.executeState('playerOneSing', [Math.abs(daNote.noteData), Conductor.songPosition, curBeat, curStep]);
							#end
							if (hscriptModchart != null)
								if (!PlayStateChangeables.opponentMode)
									hscriptModchart.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition, curBeat, curStep]);
								else
									hscriptModchart.executeState('playerOneSing', [Math.abs(daNote.noteData), Conductor.songPosition, curBeat, curStep]);
							if (stageHscript != null)
								if (!PlayStateChangeables.opponentMode)
									stageHscript.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition, curBeat, curStep]);
								else
									stageHscript.executeState('playerOneSing', [Math.abs(daNote.noteData), Conductor.songPosition, curBeat, curStep]);
							// JOELwindows7: welp, gotta do this then! PLAYER TWO 2
							executeModchartState('characterSing', [
								!PlayStateChangeables.opponentMode ? 1 : 0,
								1,
								Math.abs(daNote.noteData),
								Conductor.songPosition,
								curBeat,
								curStep
							]);

							// dad.holdTimer = 0;
							// JOELwindows7: BOLO hold timer opponent mode!!!!!!!!!!!!!
							if (!PlayStateChangeables.opponentMode)
								dad.holdTimer = 0;
							else
								boyfriend.holdTimer = 0;

							if (SONG.needsVoices)
								vocals.volume = 1;
							if (SONG.needsVoices2)
								vocals2.volume = 1; // JOELwindows7 : ye
						}
						daNote.active = false;

						if (!daNote.isSustainNote)
						{
							successfullyStep(1, daNote); // JOELwindows7:successfully step for p2
						}

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
					else
					{
						// JOELwindows7: this is mine skipped
						daNote.active = false;

						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();
						});
					}

					/*
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					 */
				}



                if (loadRep && daNote.isSustainNote)
								{
									// im tired and lazy this sucks I know i'm dumb
									if (findByTime(daNote.strumTime) != null)
										totalNotesHit += 1;
									else
									{
										vocals.volume = 0;
										// JOELwindows7: vocals2 not need vol 0
										/*
											if (theFunne && !daNote.isSustainNote)
											{
												noteMiss(daNote.noteData, daNote);
											}
										 */
										if (daNote.isParent)
										{
											// health -= 0.15; // give a health punishment for failing a LN // JOELwindows7: BOLO disable. because
											trace("hold fell over at the start");
											for (i in daNote.children)
											{
												i.alpha = 0.3;
												i.sustainActive = false;
											}
											noteMiss(daNote.noteData, daNote); // JOELwindows7: BOLO now get this.
										}
										else
										{
											if (!daNote.wasGoodHit
												&& daNote.isSustainNote
												&& daNote.sustainActive
												&& daNote.spotInLine < daNote.parent.children.length) // JOELwindows7: do not `!=`. use `<` like BOLO did!
											{
												// health -= 0.05; // give a health punishment for failing a LN
												trace("hold fell over at " + daNote.spotInLine);
												for (i in daNote.parent.children)
												{
													i.alpha = 0.3;
													i.sustainActive = false;
												}
												if (daNote.parent.wasGoodHit)
												{
													misses++;
													totalNotesHit -= 1;
												}
												updateAccuracy();
												noteMiss(daNote.noteData, daNote); // JOELwindows7: nvm. this seems all note miss here. ah whatever.
											}
											else if (!daNote.wasGoodHit && !daNote.isSustainNote)
											{
												noteMiss(daNote.noteData, daNote); // JOELwindows7: coz afterall we need 2B
												// precisely correct which moment here idk.
												misses++;
												// updateAccuracy();
												// health -= 0.15;
												// JOELwindows7: BOLO opponent mode! BOLO's is .04 times health loss value. rawly is .15.
												if (!PlayStateChangeables.opponentMode)
													health -= 0.04 * PlayStateChangeables.healthLoss;
												else
													health += 0.04 * PlayStateChangeables.healthLoss;
											}
										}
									}
								}
								else
								{
									// JOELwindows7: pinpoin COCAL
									vocals.volume = 0;
									// JOELwindows7: vocals2 no need vol 0
									if (theFunne && !daNote.isSustainNote)
									{
										if (PlayStateChangeables.botPlay)
										{
											daNote.rating = "bad";
											goodNoteHit(daNote);
										}
										else
										{
											// noteMiss(daNote.noteData, daNote);
											// JOElwindows7: BOLO miss funneh hp inflict
											if (!PlayStateChangeables.opponentMode)
												health -= 0.04 * PlayStateChangeables.healthLoss;
											else
												health += 0.04 * PlayStateChangeables.healthLoss;
										}
									}

									if (daNote.isParent && daNote.visible)
									{
										health -= 0.15; // give a health punishment for failing a LN
										trace("hold fell over at the start");
										for (i in daNote.children)
										{
											i.alpha = 0.3;
											i.sustainActive = false;
										}
										noteMiss(daNote.noteData, daNote); // JOELwindows7: BOLO
									}
									else
									{
										if (!daNote.wasGoodHit
											&& daNote.isSustainNote
											&& daNote.sustainActive
											&& daNote.spotInLine != daNote.parent.children.length)
										{
											// health -= 0.05; // give a health punishment for failing a LN
											trace("hold fell over at " + daNote.spotInLine);
											for (i in daNote.parent.children)
											{
												i.alpha = 0.3;
												i.sustainActive = false;
												// JOELwindows7: BOLO hp inflict
												if (!PlayStateChangeables.opponentMode)
													health -= (0.04 * PlayStateChangeables.healthLoss) / daNote.parent.children.length;
												else
													health += (0.04 * PlayStateChangeables.healthLoss) / daNote.parent.children.length;
											}
											if (daNote.parent.wasGoodHit)
											{
												misses++;
												totalNotesHit -= 1;
											}
											noteMiss(daNote.noteData, daNote); // JOELwindows7: BOLO
											// updateAccuracy();
										}
										else if (!daNote.wasGoodHit && !daNote.isSustainNote)
										{
											misses++;
											// JOELwindows7: and BOLO
											noteMiss(daNote.noteData, daNote);
											// updateAccuracy();
											// health -= 0.15; // JOELwindows7: BOLO says
											// "I forgot replay is broken. So it's not necessary to uncommment deez."
										}
									}
								}