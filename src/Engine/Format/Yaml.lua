local Yaml = {}

local testStr = [[
number: 123
num2: 456
string: abc def
array:
  - 1
  - 2
  - 3
object:
    key: value
    key2: value2
]]

local function parseValue(s, result)
    if i > #s then
        return nil
    end

    while s:sub(i, i) == " " do
        i = i + 1
    end

    local c = s:sub(i, i)
    if c == "\n" then
        i = i + 1
        return parseValue(s, result)
    end

    if c == "-" then
        i = i + 1
        while s:sub(i, i) == " " do
            i = i + 1
        end
        local array = {}
        table.insert(result, array)
        while true do
            table.insert(array, parseValue(s, result))
            if s:sub(i, i) ~= "-" then
                break
            end
            i = i + 1
        end
        return array
    end

    local key = ""

    while true do
        local c = s:sub(i, i)
        if c == ":" then
            i = i + 1
            break
        end
        key = key .. c
        i = i + 1
    end

    while s:sub(i, i) == " " do
        i = i + 1
    end

    local value = ""
    while true do
        local c = s:sub(i, i)
        if c == "\n" then
            break
        end
        value = value .. c
        i = i + 1
    end

    result[key] = value

    if s:sub(i, i) == "\n" then
        i = i + 1
        return parseValue(s, result)
    end
    
    return value
end

function Yaml.parse(s)
    i = 1
    print(s)
    local result = {}
    parseValue(s, result)
    return result
end

local result = Yaml.parse(testStr)
print(result.number, result.num2, result.string, result.array[1], result.array[2], result.array[3])