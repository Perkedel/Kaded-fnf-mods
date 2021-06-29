-- inspire from Kade Engine modchart lua
-- JOELwindows7's new stage chart script

-- when the state has just loaded, do this background
function loaded(song)
    print("\nStage: " .. stage)
end

-- when the countdown started
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

end

function playerTwoSing(note, position)

end

function playerOneMiss(note, position)

end

function playerTwoMiss(note, position)

end

print("Stage Chart script loaded! :) cool and good.")