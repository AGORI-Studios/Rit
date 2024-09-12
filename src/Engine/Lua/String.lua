function string:split(sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c) fields[#fields + 1] = c end)
    return fields
end

function string:trim()
    return self:match("^%s*(.-)%s*$")
end

function string:startsWith(str)
    return self:sub(1, #str) == str
end

function string:endsWith(str)
    return self:sub(-#str) == str
end

function string:contains(str)
    return self:find(str) ~= nil
end

function string:toNumber()
    return tonumber(self)
end

function string:toBoolean()
    return self:lower() == "true"
end

function string:__tostring()
    return self
end

return string
