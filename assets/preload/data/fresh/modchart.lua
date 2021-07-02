-- Documentation at: https://kadedev.github.io/Kade-Engine/modchart
-- https://github.com/KadeDev/Kade-Engine/wiki
-- templated by JOELwindows7, with yoinks from that documentation

function start(song)
    print("Song: " .. song .. " @ " .. bpm .. " downscroll: " .. downscroll)
end

function update(elapsed)

end

function beatHit(beat)

end

function stepHit(step)

end

function keyPressed(key)
    
end

function playerOneTurn()

end

function playerTwoTurn()

end

function playerOneSing(note, position)
    print("P1 sing " .. note .. " at " .. position)
    if (curBeat > 0 and curBeat < 16) or (curBeat > 144) then
        if(flashing) then
            colorizeColorablebyKey(note,false,0)
        end
    else
        hideColoring(false, 0)
    end
end

function playerTwoSing(note, position)
    print("P2 sing " .. note .. " at " .. position)
    if (curBeat > 0 and curBeat < 16) or (curBeat > 144) then
        if(flashing) then
            colorizeColorablebyKey(note,false,0)
        end
        if(distractions) then
            camZoomNow(0.015, 0.03, 1.35)
            vibrate(0, 500)
        end
    else
        hideColoring(false, 0)
    end
end

function playerOneMiss(note, position)
    hideColoring(false, 0)
end

function playerTwoMiss(note, position)
    hideColoring(false, 0)
end

function colorizeColorablebyKey(note, justOne, toWhichBg)
    if note == "left" or note == 0 then
        print("set color magenta")
        chooseColoringColor("magenta", justOne, toWhichBg)
    elseif note == "down" or note == 1 then
        print("set color cyan")
        chooseColoringColor("cyan", justOne, toWhichBg)
    elseif note == "up" or note == 2 then
        print("set color lime")
        chooseColoringColor("lime", justOne, toWhichBg)
    elseif note == "right" or note == 3 then
        print("set color red")
        chooseColoringColor("red", justOne, toWhichBg)
    end
end

print("Mod Chart script loaded :)")