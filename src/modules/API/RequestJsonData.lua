local RequestJsonData = {}
local env = require("lib.env")
local data = env.parse("assets/data/api/.env")

API_SERVER_URL = "https://rit.agori.dev/"         -- development : 127.0.0.1:8090
--                                                -- production  : rit.agori.dev

x,d,y,RequestJsonData.setAPIAccessKey=nil,nil,nil,nil
API_CONNECTED = false

function RequestJsonData.testConnection()
    if not https then
        return
    end
    local code = https.request(API_SERVER_URL)
    if code == 200 then
        API_CONNECTED = true
        API_SERVER_URL = API_SERVER_URL .. "api/"
    else
        print("UNABLE TO PING SERVER")
    end
end

RequestJsonData.testConnection()-- <- Do we have a connection to the api server?

function RequestJsonData.getUsers()
    if not API_CONNECTED then
        return {}
    end
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
    if not API_CONNECTED then
        return {}
    end
    local _, body = https.request(API_SERVER_URL .. "users/" .. id)
    body = json.decode(body)
    if body.code == 404 then
        return {}
    elseif body.code == 200 then
        return body
    end

    return {}
end

function RequestJsonData.createUser(id)
    if not API_CONNECTED then
        return {}
    end
    -- POST request
    local _, body = https.request(API_SERVER_URL .. "users", {
        --[[ data = urlencode({
            id = id,
            API_KEY = API_ACCESS
        }),
        method = "POST" ]]
    })

    body = json.decode(body)
end

return RequestJsonData