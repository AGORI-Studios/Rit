local RequestJsonData = {}
local env = require("lib.env")
local data = env.parse("assets/data/api/.env")

local API_SERVER_URL = "https://localhost:3000/api/v1/"

x,d,y,RequestJsonData.setAPIAccessKey=nil,nil,nil,nil

function RequestJsonData.getUsers()
    local code, body, headers = https.request(API_SERVER_URL .. "users")
    body = json.decode(body)
    if body.code == 404 then
        return {}
    elseif body.code == 200 then
        return body
    end

    return {}
end

function RequestJsonData.getUser(id)
    local code, body, headers = https.request(API_SERVER_URL .. "users/" .. id)
    body = json.decode(body)
    if body.code == 404 then
        return {}
    elseif body.code == 200 then
        return body
    end

    return {}
end

function RequestJsonData.createUser(id)
    -- POST request
    local code, body, headers = https.request(API_SERVER_URL .. "users", {
        --[[ data = {
            id = id,
            API_KEY = API_ACCESS
        }, ]]
        data = urlencode({
            id = id,
            API_KEY = API_ACCESS
        }),
        method = "POST"
    })

    body = json.decode(body)
end

return RequestJsonData