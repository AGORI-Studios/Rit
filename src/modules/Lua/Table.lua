---@name table.random
---@description Returns a random value from a table
---@param table table
---@return any
function table.random(table)
    local keys = {}
    for k, v in pairs(table) do
        keys[#keys+1] = k
    end

    return table[keys[love.math.random(#keys)]]
end

---@name table.clone
---@description Returns a clone of a table
---@param table table
---@return table
function table.clone(table)
    local newTable = {}
    for k, v in pairs(table) do
        newTable[k] = v
    end

    return newTable
end

---@name table.print
---@description Prints a table
---@param table table
---@return nil
function table.print(table)
    for k, v in pairs(table) do
        print(k, v)
    end
end

---@name table.randomize
---@description Randomizes the order of a table
---@param table table
---@return table
function table.randomize(table)
    local newTable = {}
    for k, v in pairs(table) do
        newTable[love.math.random(1, #newTable+1)] = v
    end

    return newTable
end

---@name table.find
---@description Finds a value in a table
---@param table table
---@param value any
---@return any
function table.find(table, value)
    for k, v in pairs(table) do
        if v == value then
            return v
        end
    end

    return nil
end

table.contains = table.find

---@name table.concate
---@description Concatenates a table to a string
---@param table table
---@param separator string
---@return string
function table.concate(table, separator)
    local str = ""
    for k, v in pairs(table) do
        str = str .. v .. separator
    end

    return str:sub(1, #str - #separator)
end

---@name table.protect
---@description Protects a table from being modified. Similar to lua 5.4's constants
---@param table table
---@return table
function table.protect(table)
    return setmetatable({}, {
        __index = table,
        __newindex = function(t, key, value)
            error("Attempting to change protected value " .. key .. " to " .. value .. " in " .. tostring(t))
        end,
        __metatable = false
    })
end
