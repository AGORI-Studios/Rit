local Json = {}
Json.tabSize = 4

local charEscape = {
    ['"'] = '\\"',
    ['\\'] = '\\\\',
    ['/'] = '\\/',
    ['\b'] = '\\b',
    ['\f'] = '\\f',
    ['\n'] = '\\n',
    ['\r'] = '\\r',
    ['\t'] = '\\t'
}

function Json.escapeChar(c)
    return charEscape[c] or string.format("\\u%04x", c:byte())
end

function Json:encodeString(s)
    return s:gsub('[%z\1-\31\\"]', Json.escapeChar)
end

function Json:encodeValue(v, indent)
    indent = indent or 0
    if type(v) == "string" then
        return '"' .. Json:encodeString(v) .. '"'
    elseif type(v) == "number" then
        return tostring(v)
    elseif type(v) == "boolean" then
        return v and "true" or "false"
    elseif type(v) == "table" then
        return Json:encode(v, indent)
    else
        return "null"
    end
end

function Json:encodeTable(t, indent)
    indent = indent or 0
    local result = {}
    local array = true
    for k, v in pairs(t) do
        if type(k) ~= "number" then
            array = false
            break
        end
    end
    if array then
        for i, v in ipairs(t) do
            table.insert(result, Json:encodeValue(v, indent))
        end
        return "[" .. table.concat(result, ",") .. "]"
    else
        for k, v in pairs(t) do
            table.insert(result, '"' .. k .. '":' .. Json:encodeValue(v, indent))
        end
        return "{" .. table.concat(result, ",") .. "}"
    end
end

function Json:encode(value, indent)
    indent = indent or 0
    return Json:encodeTable(value, indent)
end

local i = 1
local function parseValue(s)
    local c = s:sub(i, i)
    if c == "{" then
        i = i + 1
        local result = {}
        while true do
            local key = parseValue(s)
            if key == nil then
                return result
            end
            if s:sub(i, i) ~= ":" then
                error("Expected ':'")
            end
            i = i + 1
            local value = parseValue(s)
            ---@diagnostic disable-next-line: need-check-nil 
            result[key] = value -- It literally checks if its nil but it still gives the warning
            if s:sub(i, i) == "}" then
                i = i + 1
                return result
            end
            if s:sub(i, i) ~= "," then
                error("Expected ','")
            end
            i = i + 1
        end
    elseif c == "[" then
        i = i + 1
        local result = {}
        while true do
            local value = parseValue(s)
            table.insert(result, value)
            if s:sub(i, i) == "]" then
                i = i + 1
                return result
            end
            if s:sub(i, i) ~= "," then
                error("Expected ','")
            end
            i = i + 1
        end
    elseif c == '"' then
        i = i + 1
        local result = ""
        while true do
            local c = s:sub(i, i)
            if c == '"' then
                i = i + 1
                return result
            end
            if c == "\\" then
                i = i + 1
                c = s:sub(i, i)
                if c == "u" then
                    i = i + 1
                    local hex = s:sub(i, i + 3)
                    i = i + 4
                    result = result .. string.char(tonumber(hex, 16))
                else
                    result = result .. c
                end
            else
                result = result .. c
            end
            i = i + 1
        end
    elseif c == "t" then
        if s:sub(i, i + 3) == "true" then
            i = i + 4
            return true
        end
    elseif c == "f" then
        if s:sub(i, i + 4) == "false" then
            i = i + 5
            return false
        end
    elseif c == "n" then
        if s:sub(i, i + 3) == "null" then
            i = i + 4
            return nil
        end
    else
        local j = i
        while true do
            local c = s:sub(j, j)
            if c == "," or c == "}" or c == "]" then
                local value = tonumber(s:sub(i, j - 1))
                i = j
                return value
            end
            j = j + 1
        end
    end

    error("Unexpected character: " .. c)

end

local function parse(s)
    i = 1
    return parseValue(s)
end

function Json:decode(s)
    s = s:gsub("%s", "")
    return parse(s)
end

return Json