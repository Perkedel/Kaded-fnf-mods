-- Documentation at: https://kadedev.github.io/Kade-Engine/modchart
-- https://github.com/KadeDev/Kade-Engine/wiki
-- templated by JOELwindows7, with yoinks from that documentation

-- this gets called starts when the level loads.
function start(song) -- arguments, the song name
    print("Song: " .. song .. " @ " .. bpm .. " downscroll: " .. downscroll)
end

-- this gets called every frame
function update(elapsed) -- arguments, how long it took to complete a frame

end

-- this gets called after GO!
function songStart()

end

-- this gets called when song is ended right before unloading the script. not to be confused with epilogue cutscene things!
function songEnd()

end

-- this gets called when passing intro cutscene
function introCutscene()

end

-- this gets called when passing outro cutscene
function outroCutscene()

end

-- this gets called when dialogue opens
function dialogueStart()

end

-- this gets called when dialogue finish
function dialogueEnd()

end

-- this gets called when dialogue skipped
function dialogueSkip()
    --dialogueEnd() -- do you want to do the same anyway
end

-- this gets called every next dialogue
function dialogueNext(index)
    -- `index` is where dialogue line number you were at
end

-- this gets called every beat
function beatHit(beat) -- arguments, the current beat of the song

end

-- this gets called every step
function stepHit(step) -- arguments, the current step of the song (4 steps are in a beat)

end

function keyPressed(key)
    
end

function playerOneTurn()

end

function playerTwoTurn()

end

function playerOneSing(note, position, beatOf, stepOf)
    -- note:Int => left 0, down 1, up 2, right 3
    -- position:Float => Song position where pressed
end

function playerTwoSing(note, position, beatOf, stepOf)

end

function playerOneMiss(note, position, beatOf, stepOf)

end

function playerTwoMiss(note, position, beatOf, stepOf)

end

function characterSing(whichTurn, absoluteCharId, note, position, beatOf, stepOf)
    -- whichTurn:Int => 0 your turn (bf if not opponent, dad if opponent), 1 opponent turn
    -- absoluteCharId:Int => bf 0, dad 1
end
    
function characterTurn(whichTurn, absoluteCharId)


end
    
function characterMiss(whichTurn, absoluteCharId, note, position, beatOf, stepOf)


end

function variableChange(name,value)

end

function methodExecutes(name,args)

end

function colorizeColorablebyKey(note, justOne, toWhichBg)
    if note == "left" or note == 0 then
        -- print("set color magenta")
        chooseColoringColor("magenta", justOne, toWhichBg)
    elseif note == "down" or note == 1 then
        -- print("set color cyan")
        chooseColoringColor("cyan", justOne, toWhichBg)
    elseif note == "up" or note == 2 then
        -- print("set color lime")
        chooseColoringColor("lime", justOne, toWhichBg)
    elseif note == "right" or note == 3 then
        -- print("set color red")
        chooseColoringColor("red", justOne, toWhichBg)
    end
end

print("Mod Chart script loaded :)")