local env = {
    _NAME = "env",
    _VERSION = "1.0.0",
    _DESCRIPTION = "A simple env parser",
    _CREATOR = "GuglioIsStupid",
    _LICENSE = [[
        MIT LICENSE
    ]]
}

local function split(str, sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    str:gsub(pattern, function(c) fields[#fields + 1] = c end)
    return fields
end

local function convert(str)
    if tonumber(str) then
        return tonumber(str)
    elseif str:lower() == "true" then
        return true
    elseif str:lower() == "false" then
        return false
    else
        return str
    end
end

function env.parse(env)
    local str 

    if love.filesystem.getInfo(env) then
        str = love.filesystem.read(env)
    else
        str = env
    end

    if not str then str = "key=default" end -- The default key.

    local lines = split(str, "\n")

    local data = {}

    for i, line in ipairs(lines) do
        local comment = string.match(line, "^%s*;(.*)")
        if line ~= "" and not comment then
            local name, value = string.match(line, "^%s*(.-)%s*=%s*(.-)%s*$")
            if name and value then
                data[name] = convert(value)
            end
        end
    end

    return data
end

function env.save(env, data)
    local str = ""

    for k, v in pairs(data) do
        str = str .. k .. "=" .. tostring(v) .. "\n"
    end

    love.filesystem.write(env, str)
end

return env