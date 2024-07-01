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
    for _, v in pairs(table) do
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
    for _, v in pairs(table) do
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
    for _, v in pairs(table) do
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

---@name table.copy
---@description Copies a table
---@param table table
---@return table
function table.copy(table)
    local newTable = {}
    for k, v in pairs(table) do
        newTable[k] = v
    end

    return newTable
end

local o_tblSort = table.sort

---@name table.sort
---@description Sorts a table if it exists
---@param table table
---@return table
---@diagnostic disable-next-line: duplicate-set-field
function table.sort(table, method)
    if table then 
        o_tblSort(table, method)
    end

    return {}
end

---@name table.merge
---@description Merges two tables together
---@param t1 table
---@param t2 table
---@return table
function table.merge(t1, t2)
    for k, v in pairs(t2) do
        t1[k] = v
    end
    return t1
end