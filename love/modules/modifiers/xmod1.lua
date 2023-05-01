local xmod = {}

function xmod:apply(amount, lane)
    if lane == 0 then
        for i = 1, 4 do
            modifiers.xmodLane[i] = amount
            table.insert(modifiers.curEnabled, {"xmod" .. i, amount}) 
        end
    else
        modifiers.xmodLane[lane] = amount
        table.insert(modifiers.curEnabled, {"xmod" .. lane, amount})
    end
    
end

function xmod:update(dt, beat, amount)
    local xm = modifiers.xmodLane[1]

    local ss = xm * speedLane[1] * (1 - 2 *modifiers.reverseScale)
    setLaneScrollspeed(1, ss)
end

return xmod