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

function playerOneSing(note, position, beatOf, stepOf)

end

function playerTwoSing(note, position, beatOf, stepOf)

end

function playerOneMiss(note, position, beatOf, stepOf)

end

function playerTwoMiss(note, position, beatOf, stepOf)

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