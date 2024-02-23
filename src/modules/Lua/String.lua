---@diagnostic disable: param-type-mismatch
---@name string.split
---@description Splits a string into a table
---@param sep string
---@return table
function string.split(self, sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    ---@diagnostic disable-next-line: discard-returns
    self:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

---@name string.splitAllCharacters
---@description Splits a string into a table of all characters
---@return table
function string.splitAllCharacters(self)
    local fields = {}
    for c in self:gmatch(".") do
        fields[#fields+1] = c
    end
    return fields
end

---@name string.trim
---@description Trims whitespace from the beginning and end of a string
---@return string
function string.trim(self)
    ---@diagnostic disable-next-line: redundant-return-value
    return self:gsub("^%s*(.-)%s*$", "%1")
end

---@name string.startsWith
---@description Checks if a string starts with another string
---@param start string
---@return boolean
function string.startsWith(self, start)
    return self:sub(1, #start) == start
end

---@name string.endsWith
---@description Checks if a string ends with another string
---@param ending string
---@return boolean
function string.endsWith(self, ending)
    return ending == "" or self:sub(-#ending) == ending
end

---@name string.contains
---@description Checks if a string contains another string
---@param str string
---@return boolean
function string.contains(self, str)
    return self:find(str) ~= nil
end

---@name string.count
---@description Counts the number of times a string appears in another string
---@param str string
---@return number
function string.count(self, str)
    local count = 0
    for _ in self:gmatch(str) do
        count = count + 1
    end
    return count
end

---@name string.replace
---@description Replaces all instances of a string with another string
---@param search string
---@param replace string
---@return string
function string.replace(self, search, replace)
---@diagnostic disable-next-line: redundant-return-value
    return self:gsub(search, replace)
end

---@name string.reverse
---@description Reverses a string
---@return string
---@diagnostic disable-next-line: duplicate-set-field
function string.reverse(self)
    return self:splitAllCharacters():reverse():concat()
end

---@name string.capitalize
---@description Capitalizes the first letter of a string
---@return string
function string.capitalize(self)
    return self:sub(1, 1):upper() .. self:sub(2)
end

---@name string.toTable
---@description Converts a string to a table of all characters
---@return table
function string.toTable(self)
    local t = {}
    for c in self:gmatch(".") do
        t[#t+1] = c
    end
    return t
end

---@name string.fromTable
---@description Converts a table of all characters to a string
---@param t table
---@return string
function string.fromTable(self, t)
    return table.concat(t)
end

---@name string.random
---@description Generates a random string
---@param length number
---@return string
function string.random(length)
    local length = length or 16
    local str = ""
    for i = 1, length do
        str = str .. string.char(love.math.random(32, 126))
    end
    return str
end

---@name string.strip
---@description Strips all whitespace from a string (left and right)
---@return string
function string.strip(self)
    ---@diagnostic disable-next-line: redundant-return-value
    return self:gsub("^%s*(.-)%s*$", "%1")
end