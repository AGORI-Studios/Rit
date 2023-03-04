local tipsy = {}
function tipsy:apply(amount)
    -- Apply the tipsy mod
    -- causes the note receptors to go up and down depending on its modifier
    table.insert(modifiers.curEnabled, {"tipsy", amount})
end

local tipsyTweens = {}

function tipsy:update(dt, beat, amount)
    --print("tipsyIsEnabled")
    local time = (beat / (beatHandler.bpm / 60)) * 1000 -- get the ms of the current beat
    if amount ~= 0 then 
        for i = 1, #receptors do
            local speed = 0.5
            local offset = (time / speed) * math.pi * 2
            receptors[i][1].newoffsetY = (amount * (math.cos((time*((speed*1.2)+1.2) + i*((offset * 1.8)+1.8))) * receptors[i][1]:getHeight()*0.4)) * 0.25

            if tipsyTweens[i] then 
                Timer.cancel(tipsyTweens[i])
            end
            
            tipsyTweens[i] = Timer.tween((60/beatHandler.bpm), receptors[i][1], {offsetY = receptors[i][1].newoffsetY}, "out-quad")
            receptors[i][2].offsetY = receptors[i][1].offsetY
            for j = 1, #charthits[i] do 
                noteImgs[i][1].offsetY = receptors[i][1].offsetY
                noteImgs[i][2].offsetY = receptors[i][1].offsetY
                noteImgs[i][3].offsetY = receptors[i][1].offsetY
            end
        end
    else
        -- disable the mod
        for i, receptor in pairs(receptors) do
            receptor[1].offsetY = 0
            receptor[2].offsetY = 0
        end
    end
end

return tipsy