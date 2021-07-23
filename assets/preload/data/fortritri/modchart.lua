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

function stepHit(beat)

end

function keyPressed(key)
    -- Okay guys don't know, but just found this cool changeDadCharacter function here
    -- basically to change player2 character in swift in game. that's all.
    -- maybe we can add vocal change too one day?
    if key == "down" then
        changeDadCharacter('hookx')
    elseif key == "up" then
        changeDadCharacter('pico')
    elseif key == "left" then
        changeDadCharacter('dad')
    elseif key == "right" then
        changeDadCharacter('mom')
    end
    
end

print("Mod Chart script loaded :)")