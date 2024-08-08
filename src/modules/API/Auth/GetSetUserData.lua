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

function API:GetCurrentUserAvatar()
    if not API_CONNECTED or not API.LoggedInUser.id then
        return love.image.newImageData(1, 1)
    end

    local code, body, headers = https.request(API_SERVER_URL .. "avatar/" .. API.LoggedInUser.id, {
        method = "GET"
    })

    -- Now we download the PFP
    if code == 200 then
        local url = json.decode(body).avatarUrl
        print(url)
        local code, body, headers = https.request(url)

        -- file name is like gsa_ka0o_x0_aai9m_m_lk2oQuVHQH.jpg?thumb=150x150"
        -- we want to grab the extension of it and call it userAvatar.extension
        if code == 200 then
            local extension = url:match("^.+%.([^%?]+)%??.*$")
            local filePath = ".cache/.web/userAvatar." .. extension
            love.filesystem.write(filePath, body)

            return love.image.newImageData(filePath)
        end
    else
        return love.image.newImageData(1, 1)
    end
end

function API:SetUserData()
    if not API_CONNECTED or not API.LoggedInUser.id then
        return false
    end

    print(API.LoggedInUser.id)

    local code, body, headers = https.request(
        API_SERVER_URL .. "updateUser/" .. API.LoggedInUser.id .. "?userData=" .. urlB64Enc(json.encode(API.LoggedInUser)
    ), {
        method = "GET"
    })
end