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
    elseif str:lower() == "true" then
        return true
    elseif str:lower() == "false" then
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
    -- sort 0-Z
    
    local newTab = {}
    for k, v in pairs(tab) do
        table.insert(newTab, k)
    end
    table.sort(newTab, function(a, b) return a < b end)

    local str = ""

    for i, section in ipairs(newTab) do
        str = str .. "[" .. section .. "]\n"
        local newTab2 = {}
        for k, v in pairs(tab[section]) do
            table.insert(newTab2, k)
        end
        table.sort(newTab2, function(a, b) return a < b end)
        for i, name in ipairs(newTab2) do
            str = str .. name .. " = " .. tostring(tab[section][name]) .. "\n"
        end
        str = str .. "\n"
    end

    love.filesystem.write(fileName, str)
end

return ini