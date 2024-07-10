---Returns a random value from a table
---@param table table
---@return any
function table.random(table)
    local keys = {}
    for k, v in pairs(table) do
        keys[#keys+1] = k
    end

    return table[keys[love.math.random(#keys)]]
end

---Returns a clone of a table
---@param table table
---@return table
function table.clone(table)
    local newTable = {}
    for k, v in pairs(table) do
        newTable[k] = v
    end

    return newTable
end

---Prints a table
---@param table table
---@return nil
function table.print(table)
    for k, v in pairs(table) do
        print(k, v)
    end
end

---Randomizes the order of a table
---@param table table
---@return table
function table.randomize(table)
    local newTable = {}
    for _, v in pairs(table) do
        newTable[love.math.random(1, #newTable+1)] = v
    end

    return newTable
end

---Finds a value in a table
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

---Concatenates a table to a string
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

---Protects a table from being modified. Similar to lua 5.4's constants
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

---Copies a table
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

---Sorts a table if it exists
---@param table table
---@return table
---@diagnostic disable-next-line: duplicate-set-field
function table.sort(table, method)
    if table then 
        o_tblSort(table, method)
    end

    return {}
end

---Merges two tables together
---@param t1 table
---@param t2 table?
---@return table
function table.merge(t1, t2)
    for k, v in pairs(t2 or {}) do
        if type(v) == "table" and type(t1[k] or false) == "table" then
            table.merge(t1[k], v)
        else
            t1[k] = v
        end
    end
    return t1
end

---Adds a value to the first index
---@param tbl table
---@param value any
---@return table
function table.addToFirstIndex(tbl, value)
    -- Shift elements to the right
    for i = #tbl, 1, -1 do
        tbl[i + 1] = tbl[i]
    end
    
    -- Add the value at the first index
    tbl[1] = value

    return tbl
end