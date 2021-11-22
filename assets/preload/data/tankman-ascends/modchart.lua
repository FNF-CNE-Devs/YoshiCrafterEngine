function start()

end

local ascending = false;
local rot = 0;
local fadingIn = 0;
function update(elapsed)
    if ascending == true then
        if fadingIn < 1 then
            fadingIn = fadingIn + elapsed / 5;
            if fadingIn > 1 then
                fadingIn = 1;
            end
        end
        rot = rot + (elapsed * 50);
        camHudAngle = math.sin(rot * math.pi / 180) * fadingIn * 7.5;
    end
end

function stepHit()
    if curStep >= 899 then
        ascending = true;
    end
end

function beatHit()
    -- Idiot keeps getting errors
end