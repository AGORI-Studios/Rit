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
    for i = 1, 4 do
        local xm = modifiers.xmodLane[i]

        local ss = xm * speedLane[i] * (1 - 2 *getReverseForCol(i))
        print(xm, ss)
        setLaneScrollspeed(i, ss)
    end
end

return xmod