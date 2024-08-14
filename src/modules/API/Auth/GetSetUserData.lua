local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_'
local function urlB64Enc(data)
    local encoded = ((data:gsub('.', function(x)
        local r, b = '', x:byte()
        for i = 8, 1, -1 do r = r .. (b % 2^i - b % 2^(i-1) > 0 and '1' or '0') end
        return r
    end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c = 0
        for i = 1, 6 do c = c + (x:sub(i, i) == '1' and 2^(6-i) or 0) end
        return b:sub(c + 1, c + 1)
    end) .. ({ '', '==', '=' })[#data % 3 + 1])

    return encoded:gsub('+', '-'):gsub('/', '_'):gsub('=', '')
end

-- decoding
local function urlB64Dec(data)
    local padded = data:gsub('-', '+'):gsub('_', '/')
    local padding = #data % 4
    if padding == 2 then padded = padded .. '=='
    elseif padding == 3 then padded = padded .. '='
    end

    padded = padded:gsub('[^' .. b .. '=]', '')
    return (padded:gsub('.', function(x)
        if (x == '=') then return '' end
        local r, f = '', (b:find(x) - 1)
        for i = 6, 1, -1 do r = r .. (f % 2^i - f % 2^(i-1) > 0 and '1' or '0') end
        return r
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c = 0
        for i = 1, 8 do c = c + (x:sub(i, i) == '1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end