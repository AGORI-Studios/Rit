function table.findID(tbl, val)
    for i, v in ipairs(tbl) do
        if v == val then
            return i
        end
    end
end

function table.random(tbl)
    local rnd = {}
    for _, v in pairs(tbl) do
        table.insert(rnd, v)
    end

    return rnd[love.math.random(1, #rnd)]
end