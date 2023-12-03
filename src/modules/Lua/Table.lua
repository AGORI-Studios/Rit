--@name table.random
--@description Returns a random value from a table
--@param table
--@return any
function table.random(table)
    local keys = {}
    for k, v in pairs(table) do
        keys[#keys+1] = k
    end

    return table[keys[love.math.random(#keys)]]
end