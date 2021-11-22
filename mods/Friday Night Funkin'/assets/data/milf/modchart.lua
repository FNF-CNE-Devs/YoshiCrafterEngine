local didBeatHit = false;

function start()

end

function update()
    if didBeatHit == true then
        if curBeat >= 168 and curBeat < 200 and cameraZoom < 1.35 then
            cameraZoom = cameraZoom + 0.015;
            hudZoom = hudZoom + 0.03;
        end
        didBeatHit = false;
    end
end

function beatHit(beat) -- arguments, the current beat of the song
    didBeatHit = true;
    
end

function stepHit()

end