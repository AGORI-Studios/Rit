-- local variables for API functions. any changes to the line below will be lost on re-generation
local string_format, tonumber, assert, ipairs, string_match, table_insert, pairs, table_sort, type, tostring =
    string.format,
    tonumber,
    assert,
    ipairs,
    string.match,
    table.insert,
    pairs,
    table.sort,
    type,
    tostring

local ini = {}

local function split(str, sep)
    local sep, fields = sep or ":", {}
    local pattern = string_format("([^%s]+)", sep)
    str:gsub(
        pattern,
        function(c)
            fields[#fields + 1] = c
        end
    )
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

---@param ini string
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
    local currentKey = nil
    local isArray = false

    for _, line in ipairs(lines) do
        local comment = string_match(line, "^%s*;(.*)")
        if line ~= "" and not comment then
            local sec = string_match(line, "^%s*%[(.*)%]")
            if sec ~= nil then
                currentSection = sec
                data[currentSection] = {}
            else
                local name, value = string_match(line, "^%s*(.-)%s*=%s*(.-)%s*$")
                if name and value then
                    currentKey = name
                    if value:sub(1, 1) == "[" then
                        isArray = true
                        data[currentSection][currentKey] = {}
                        local trimmedValue = value:match("^%s*%[(.*)%]%s*$")
                        if trimmedValue and trimmedValue ~= "" then
                            for _, v in ipairs(split(trimmedValue, ",")) do
                                table_insert(data[currentSection][currentKey], convert(v:match("^%s*(.-)%s*$")))
                            end
                        end
                    else
                        data[currentSection][name] = convert(value)
                    end
                elseif isArray then
                    if line:match("^%s*%]") then
                        isArray = false
                        currentKey = nil
                    else
                        local trimmedValue = line:match("^%s*(.-)%s*$")
                        if trimmedValue and trimmedValue ~= "" then
                            table_insert(data[currentSection][currentKey], convert(trimmedValue))
                        end
                    end
                end
            end
        end
    end

    return data
end

---@param tab table
---@param fileName string
function ini.save(tab, fileName)
    -- sort 0-Z
    local newTab = {}
    for k, _ in pairs(tab) do
        table_insert(newTab, k)
    end
    table_sort(
        newTab,
        function(a, b)
            return a < b
        end
    )

    local str = ""

    for _, section in ipairs(newTab) do
        str = str .. "[" .. section .. "]\n"
        local newTab2 = {}
        for k, _ in pairs(tab[section]) do
            table_insert(newTab2, k)
        end
        table_sort(
            newTab2,
            function(a, b)
                return a < b
            end
        )
        for _, name in ipairs(newTab2) do
            if type(tab[section][name]) == "table" then
                str = str .. name .. " = [\n"
                for _, v in ipairs(tab[section][name]) do
                    str = str .. "    " .. tostring(v) .. "\n"
                end
                str = str .. "]\n"
            else
                str = str .. name .. " = " .. tostring(tab[section][name]) .. "\n"
            end
        end
        str = str .. "\n"
    end

    love.filesystem.write(fileName, str)
end

return ini
