local drunk = {}
-- Drunk is a notig mod. It's a modifier that makes the notes look drunk.
function drunk:apply(amount)
    -- Apply the drunk mod
    -- causes the note receptors to go left and right depending on its modifier
    table.insert(modifiers.curEnabled, {"drunk", amount})

end

local drunkTweens = {}

function drunk:update(dt, beat, amount)
    --print("drunkIsEnabled")
    local time = (beat / (beatHandler.bpm / 60)) * 1000 -- get the ms of the current beat
    if amount ~= 0 then 
        for i = 1, #receptors do
            local speed = 0.5
            local period = 1 / speed
            local offset = (time / period) * math.pi * 2

            local angle = time * (1+speed) + i*( (offset*0.2) + 0.2)
            receptors[i][1].newoffsetX = amount * (math.cos(angle) * receptors[i][1]:getWidth()/2)

            if drunkTweens[i] then 
                Timer.cancel(drunkTweens[i])
            end

            drunkTweens[i] = Timer.tween((60/beatHandler.bpm), receptors[i][1], {offsetX = receptors[i][1].newoffsetX}, "out-quad")
            receptors[i][2].offsetX = receptors[i][1].offsetX
            for j = 1, #charthits[i] do 
                noteImgs[i][1].offsetX = receptors[i][1].offsetX
                noteImgs[i][2].offsetX = receptors[i][1].offsetX
                noteImgs[i][3].offsetX = receptors[i][1].offsetX
            end
        end
    else
        -- disable the mod
        for i, receptor in pairs(receptors) do
            receptor[1].offsetX = 0
            receptor[2].offsetX = 0
        end
    end
end

return drunk