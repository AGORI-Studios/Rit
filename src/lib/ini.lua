local ini = {
    _NAME = "Ini",
    _VERSION = "1.0.0",
    _DESCRIPTION = "A simple ini parser",
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
    elseif str == "true" then
        return true
    elseif str == "false" then
        return false
    else
        return str
    end
end

function ini.parse(ini)
    -- is it a file or str
    local str

    if love.filesystem.getInfo(ini) then
        str = love.filesystem.read(ini)
    else
        str = ini
    end

    -- assert str to see if its nil or nah
    assert(str, "No ini file or string provided")

    local lines = split(str, "\n")

    local data = {}
    local currentSection = nil

    for i, line in ipairs(lines) do
        local comment = string.match(line, "^%s*;(.*)")
        if line ~= "" and not comment then
            local sec = string.match(line, "^%s*%[(.*)%]")
            if sec ~= nil then
                currentSection = sec
                data[currentSection] = {}
            else
                local name, value = string.match(line, "^%s*(.-)%s*=%s*(.-)%s*$")
                if name and value then
                    data[currentSection][name] = convert(value)
                end
            end
        end
    end

    return data
end

function ini.save(tab, fileName)
    if table then
        local str = ""
        for name, value in pairs(tab) do
            str = str .. "[" .. name .. "]\n"
            for k, v in pairs(value) do
                str = str .. k .. " = " .. tostring(v) .. "\n"
            end

            str = str .. "\n"
        end
        local ok, err = love.filesystem.write(fileName, str)
        if not ok then
            return false, err
        end
        return true, "File saved"
    end
    return false, "No table provided"
end

return ini