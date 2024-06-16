-- This is so they're loaded in a-z order, because love2d be wacky and sometimes randomizes the order of the files it finds
local luaModules = love.filesystem.getDirectoryItems("modules/Lua")
table.sort(luaModules, function(a, b)
    return a:sub(-4) == ".lua" and b:sub(-4) == ".lua" and a < b
end)
for i, module in ipairs(luaModules) do
    if module:sub(-4) == ".lua" then
        require("modules.Lua." .. module:sub(1, -5))
    end
end

local loveModules = love.filesystem.getDirectoryItems("modules/Love")
table.sort(loveModules, function(a, b)
    return a:sub(-4) == ".lua" and b:sub(-4) == ".lua" and a < b
end)
for i, module in ipairs(loveModules) do
    if module:sub(-4) == ".lua" then
        require("modules.Love." .. module:sub(1, -5))
    end
end

---@name Try
---@description Tries to run a function, and if it fails, runs another function
---@param f function
---@param catchFunc function
---@return nil, any
function Try(f, catchFunc)
    local returnedValue, error = pcall(f)
    if not returnedValue then
        catchFunc(error)
    end

    return returnedValue, (error or false) --  not actually an error, just the value returned
end

---@name switch
---@description calls a function based on a value
---@param value any
---@param cases table
---@return any
function Switch(value, cases) -- similar to the case statement in C
    if cases[value] then
        return cases[value]()
    elseif cases.default then
        return cases.default()
    end
    return value
end
