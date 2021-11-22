local didBeatHit = false;

function start()
    local difference = math.abs(_G['defaultStrum0X'] - _G['defaultStrum1X']);
    for i=4,7 do
        setActorX(720 - (difference * 2) + (difference * (i - 4.75)), i)
    end
    for i=0,3 do
        setActorX(-500, i)
    end
end

function update()
    if didBeatHit == true then
        didBeatHit = false;
    end
end

function beatHit(beat) -- arguments, the current beat of the song
    didBeatHit = true;
    
end

function stepHit()

end