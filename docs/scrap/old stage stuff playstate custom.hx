//JOELwindows7: init stagefile
function loadStageFile(path:String){
    customStage = StageChart.loadFromJson(path);
    if(customStage != null){
        useStageScript = customStage.useStageScript;
        isHalloween = customStage.isHalloween;
    }
}

function spawnStageImages(daData:SwagStage){
    if(bgAll != null){
        for(i in 0...customStage.backgroundImages.length){
            var dataBg:SwagBackground = customStage.backgroundImages[i];
            var anBgThing:FlxSprite = new FlxSprite(dataBg.position[0],dataBg.position[1]);
            multiColorable[i] = dataBg.colorable;
            trace("spawning bg " + dataBg.callName);
            if(dataBg.generateMode){
                anBgThing.makeGraphic(Std.int(dataBg.size[0]),Std.int(dataBg.size[1]),FlxColor.fromString(dataBg.initColor));
                multiIsChromaScreen[i] = true;
            } else {
                if(dataBg.isXML){
                    anBgThing.frames = Paths.getSparrowAtlas("stage/" + toCompatCase(SONG.stage) + "/" + dataBg.graphic);
                    anBgThing.animation.addByPrefix(dataBg.frameXMLName,dataBg.prefixXMLName,dataBg.frameRate,dataBg.mirrored);
                } else {
                    anBgThing.loadGraphic(Paths.image("stages/" + toCompatCase(SONG.stage) + "/" + dataBg.graphic));
                }
                anBgThing.setGraphicSize(Std.int(anBgThing.width * dataBg.scale[0]),Std.int(anBgThing.height * dataBg.scale[1]));
                if(dataBg.colorable){
                    anBgThing.color = FlxColor.fromString(dataBg.initColor);
                }
            }
            //anBgThing.setPosition(dataBg.position[0],dataBg.position[1]);
            anBgThing.active = dataBg.active;
            anBgThing.antialiasing = dataBg.antialiasing && FlxG.save.data.antialiasing;
            anBgThing.scrollFactor.set(dataBg.scrollFactor[0],dataBg.scrollFactor[1]);
            anBgThing.ID = i;
            anBgThing.updateHitbox();
            multiOriginalColor[i] = anBgThing.color;

            bgAll.add(anBgThing);
            anBgThing.visible = dataBg.initVisible;

            if(trailAll != null){
                if(dataBg.hasTrail){
                    var trailing = new FlxTrail(anBgThing, null, 4, 24, 0.3, 0.069);
                    trailing.ID = i;
                    trailAll.add(trailing);
                }
            }
        }
    }
}

//JOELwindows7: when stage is using Lua script
function spawnStageScript(daPath:String){
    #if ((windows) && cpp)
    if(executeStageScript){
        trace('stage script: ' + executeStageScript + " - " + Paths.lua(daPath)); //JOELwindows7: check too

        stageScript = ModchartState.createModchartState(true,daPath);
        stageScript.executeState('loaded',[toCompatCase(SONG.song)]);
        trace("loaded it up stage lua script");
        stageScript.setVar("originalColors", multiOriginalColor);
        stageScript.setVar("areChromaScreen", multiIsChromaScreen);
    }
    #end
    if(executeStageHscript){
        trace('stage Hscript: ' + executeStageHscript + " - " + Paths.hscript(daPath)); //JOELwindows7: check too

        stageHscript = HaxeScriptState.createModchartState(true,daPath);
        stageHscript.executeState('loaded',[toCompatCase(SONG.song)]);
        trace("loaded it up stage haxe script");
        stageHscript.setVar("originalColors", multiOriginalColor);
        stageHscript.setVar("areChromaScreen", multiIsChromaScreen);
    }

    trace("Spawned the stage script yeay");
}

//JOELwindows7: core starting point for custom stage
function initDaCustomStage(stageJsonPath:String){
    var p;
    trace("Lets init da json stage " + stageJsonPath);
    curStage = SONG.stage;
    loadStageFile("stages/" + toCompatCase(SONG.stage) + "/" + toCompatCase(SONG.stage));

    if(customStage != null)
    {
        defaultCamZoom = customStage.defaultCamZoom;
        halloweenLevel = customStage.isHalloween;
        bgAll = new FlxTypedGroup<FlxSprite>();
        add(bgAll);
        trailAll = new FlxTypedGroup<FlxTrail>();
        add(trailAll);
        #if ((windows) && sys)
        if (!PlayStateChangeables.Optimize && SONG.useCustomStage && customStage.useStageScript)
            executeStageScript = FileSystem.exists(
                Paths.lua("stage/" + toCompatCase(SONG.stage) +"/stageScript")) ||
                customStage.forceLuaModchart
                ;
        #elseif (windows)
        if (!PlayStateChangeables.Optimize && SONG.useCustomStage && customStage.useStageScript)
        {
            #if !web
            p = Path.of(Paths.lua("stage/" + toCompatCase(SONG.stage) +"/stageScript"));
            trace("Stage file checking is " + Std.string(p.exists()) + " as " + p.getAbsolutePath());
            executeStageScript = p.exists() || customStage.forceLuaModchart;
            #else
            executeStageScript = customStage.forceLuaModchart;
            #end
        }
        #else
            executeStageScript = false;
        #end
        #if !cpp
            executeStageScript = false;
        #end

        //for hscript pls
        #if !web
        p = Path.of(Paths.hscript("stage/" + toCompatCase(SONG.stage) +"/stageScript"));
        if (!PlayStateChangeables.Optimize && SONG.useCustomStage && customStage.useStageScript)
            executeStageHscript = p.exists() || customStage.forceHscriptModchart;
        trace("Stage hscript file checking is " + Std.string(p.exists()) + " as " + p.getAbsolutePath());
        #else
        if (!PlayStateChangeables.Optimize && SONG.useCustomStage && customStage.useStageScript)
            executeStageHscript = customStage.forceHscriptModchart;
        #end
        trace("forced stage Hscript exist is " + Std.string(customStage.forceHscriptModchart));

        if(!customStage.ignoreMainImages)
            spawnStageImages(customStage);
        if(#if ((windows) && cpp) executeStageScript || #end executeStageHscript){
            // spawnStageScript("stages/" + toCompatCase(SONG.stage) +"/stageScript");
            attemptStageScript = true;
        }

        overrideCamFollowP1 = customStage.overrideCamFollowP1;
        overrideCamFollowP2 = customStage.overrideCamFollowP2;
    }
}
*/

//JOELwindows7: offset characters
function repositionThingsInStage(whatStage:String){
    trace("use Custom Stage Positioners");
    if(customStage != null)
    {
        boyfriend.x += customStage.bfPosition[0];
        boyfriend.y += customStage.bfPosition[1];
        gf.x += customStage.gfPosition[0];
        gf.y += customStage.gfPosition[1];
        dad.x += customStage.dadPosition[0];
        dad.y += customStage.dadPosition[1];
    }
}