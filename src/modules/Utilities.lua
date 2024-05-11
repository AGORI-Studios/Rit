for i, module in ipairs(love.filesystem.getDirectoryItems("modules/Lua")) do
    if module:sub(-4) == ".lua" then
        require("modules.Lua." .. module:sub(1, -5))
    end
end
for i, module in ipairs(love.filesystem.getDirectoryItems("modules/Love")) do
    if module:sub(-4) == ".lua" then
        require("modules.Love." .. module:sub(1, -5))
    end
end

---@name Try
---@description Tries to run a function, and if it fails, runs another function
---@param f function
---@param catch_f function
---@return nil
function Try(f, catch_f)
    local returnedValue, error = pcall(f)
    if not returnedValue then
        catch_f(error)
    end

    return returnedValue
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
