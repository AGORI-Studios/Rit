local RequestJsonData = {}
local env = require("lib.env")
local data = env.parse("assets/data/api/.env")

local API_SERVER_URL = "http://localhost:3000/api/v1/" -- development : localhost:3000
--                                                     -- production  : api.rit.agori.dev

x,d,y,RequestJsonData.setAPIAccessKey=nil,nil,nil,nil
local connected = false

function RequestJsonData.testConnection()
    if not https then
        return
    end
    local code, body, headers = https.request(API_SERVER_URL .. "test_connection")
    if code == 200 then
        connected = true
    end
end

RequestJsonData.testConnection() -- <- Do we have a connection to the api server?

function RequestJsonData.getUsers()
    if not connected then
        return {}
    end
    local code, body, headers = https.request(API_SERVER_URL .. "users")
    print(body)
    body = json.decode(body)
    if body.code == 404 then
        return {}
    elseif body.code == 200 then
        return body
    end

    return {}
end

function RequestJsonData.getUser(id)
    if not connected then
        return {}
    end
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
    if not connected then
        return {}
    end
    -- POST request
    local code, body, headers = https.request(API_SERVER_URL .. "users", {
        --[[ data = urlencode({
            id = id,
            API_KEY = API_ACCESS
        }),
        method = "POST" ]]
    })

    body = json.decode(body)
end

return RequestJsonData