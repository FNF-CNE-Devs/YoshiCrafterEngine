function start()

end

local curBeatHit = false
function update()
    if curBeatHit == true then
        if not curBeat == 283 and not curBeat == 282 then
            cameraZoom = cameraZoom + 0.02;
            hudZoom = hudZoom + 0.022;
        end
    end
end

function stepHit()

end

function beatHit(b)
    curBeatHit = true
end