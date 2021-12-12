function start(song) -- do nothing

end

function update(elapsed)
local currentBeat = (songPos / 1000)*(bpm/60)
        if chorus then
		    for i=0,7 do
			    setActorY(_G['defaultStrum'..i..'Y'] + 9 * math.sin((currentBeat*2 * math.pi)), i)
                camHudAngle = camHudAngle - 0.01 * math.cos((currentBeat*0.5 * math.pi))
            end
		end  
        if gfsolo then
		    for i=0,7 do
			    setActorY(_G['defaultStrum'..i..'Y'] + 6 * math.sin((currentBeat*2 * math.pi)), i)
            end
		end  
        if chorus2 then
		    for i=0,7 do
			    setActorY(_G['defaultStrum'..i..'Y'] + 12 * math.sin((currentBeat*2 * math.pi)), i)
                camHudAngle = camHudAngle - 0.015 * math.cos((currentBeat*1 * math.pi))
            end
		end 
        if default then
            for i=4,7 do
                setActorX(_G['defaultStrum'..i..'X'],i)
                setActorY(_G['defaultStrum'..i..'Y'],i)
            end
        end
end

function beatHit(beat) -- do nothing

end

function stepHit(step) -- do nothing
    if step == 54 then
        playActorAnimation("dad", "singRIGHT", true, false)
    end
    if step == 60 then
        playActorAnimation("dad", "cheer", true, false)
    end
    if step == 118 then
        playActorAnimation("dad", "singRIGHT", true, false)
    end
    if step == 144 then
        chorus = true
    end
    if step == 272 then
        chorus = false
        default = true
    end
    if step == 300 then
        playActorAnimation("dad", "cheer", true, false)
        playActorAnimation("boyfriend", "hey", true, false)
    end
    if step == 304 then
        default = false
        gfsolo = true
    end
    if step == 344 then
        playActorAnimation("boyfriend", "singLEFTmiss", true, false)
    end
    if step == 350 then
        playActorAnimation("boyfriend", "singRIGHTmiss", true, false)
    end
    if step == 352 then
        playActorAnimation("boyfriend", "singRIGHTmiss", true, false)
    end
    if step == 360 then
        playActorAnimation("boyfriend", "singUPmiss", true, false)
    end
    if step == 368 then
        gfsolo = false
        default = true
    end
    if step == 400 then
        strumLine1Visible = false
        strumLine2Visible = false
        playActorAnimation("dad", "sad", true, false)
    end
    if step == 404 then
        playActorAnimation("dad", "sad", true, false)
    end
    if step == 408 then
        playActorAnimation("dad", "sad", true, false)
    end
    if step == 412 then
        playActorAnimation("dad", "sad", true, false)
    end
    if step == 416 then
        playActorAnimation("boyfriend", "scared", true, false)
        playActorAnimation("dad", "sad", true, false)
    end
    if step == 420 then
        playActorAnimation("boyfriend", "scared", true, false)
        playActorAnimation("dad", "sad", true, false)
    end
    if step == 424 then
        playActorAnimation("boyfriend", "scared", true, false)
        playActorAnimation("dad", "sad", true, false)
    end
    if step == 428 then
        strumLine1Visible = true
        strumLine2Visible = true
    end
    if step == 432 then
        default = false
        chorus = true
    end
    if step == 470 then
        playActorAnimation("dad", "singRIGHT", true, false)
    end
    if step == 476 then
        playActorAnimation("dad", "cheer", true, false)
    end
    if step == 534 then
        playActorAnimation("dad", "singRIGHT", true, false)
    end
    if step == 540 then
        playActorAnimation("dad", "cheer", true, false)
        playActorAnimation("boyfriend", "hey", true, false)
    end
    if step == 544 then
        chorus = false
        default = true
    end
    if step == 560 then
        default = false
        chorus2 = true
    end
    if step == 680 then
        playActorAnimation("dad", "cheer", true, false)
    end
    if step == 682 then
        playActorAnimation("dad", "cheer", true, false)
    end
    if step == 684 then
        playActorAnimation("dad", "cheer", true, false)
    end
    if step == 686 then
        playActorAnimation("dad", "cheer", true, false)
    end
    if step == 688 then
        chorus2 = false
        default = true
    end
    if step == 716 then
        playActorAnimation("boyfriend", "singUPmiss", true, false)
    end
    if step == 747 then
        playActorAnimation("boyfriend", "singLEFTmiss", true, false)
    end
    if step == 816 then
        default = false
        chorus = true
    end
    if step == 844 then
        playActorAnimation("dad", "cheer", true, false)
        playActorAnimation("boyfriend", "hey", true, false)
    end
    if step == 876 then
        playActorAnimation("dad", "cheer", true, false)
    end
    if step == 908 then
        playActorAnimation("boyfriend", "singUPmiss", true, false)
    end
    if step == 928 then
        chorus = false
        default = true
    end
    if step == 940 then
        playActorAnimation("dad", "sad", true, false)
    end
    if step == 944 then
        default = false
        chorus = true
    end
    if step == 982 then
        playActorAnimation("dad", "singRIGHT", true, false)
    end
    if step == 988 then
        playActorAnimation("dad", "cheer", true, false)
    end
    if step == 1046 then
        playActorAnimation("dad", "singRIGHT", true, false)
    end
    if step == 1052 then
        playActorAnimation("dad", "cheer", true, false)
        playActorAnimation("boyfriend", "hey", true, false)
    end
    if step == 1056 then
        chorus = false
        default = true
    end
    if step == 1072 then
        default = false
        chorus2 = true
    end
    if step == 1196 then
        playActorAnimation("dad", "cheer", true, false)
    end
    if step == 1200 then
        chorus2 = false
        default = true
    end
end

function playerTwoTurn()
    tweenCameraZoom(0.9,(crochet * 4) / 1000)
end

function playerOneTurn()
    tweenCameraZoom(0.9,(crochet * 4) / 1000)
end

print("Here Simple Dimple yey! chart by BahnDaten https://youtu.be/7GPmOYlUVLc ! port by JOELwindows7")