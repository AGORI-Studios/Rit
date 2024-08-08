function API:LoginUser(email, password, writeFile)
    if not API_CONNECTED then
        return {}
    end

    local code, body, headers = https.request(API_SERVER_URL .. "login/?email=" .. (email or "") .. "&password=" .. (password or ""), {
        method = "GET"
    })

    body = json.decode(body)

    if code == 200 then
        API.LoggedInUser = body.user.record
        API.UserToken = body.user.token
        if writeFile then
            -- Since it worked, we save the user info so we can quickly login on next open
            API:SaveUserInfo(email, password)
        end
    elseif code == 500 then
        print("FAILED TO GET USER INFO")
        if body.error == "Invalid email or password" then
            print("Invalid email or password")
            love.filesystem.remove("data/userinfo.dat")
        end
    end

    return code == 200
end

function API:SaveUserInfo(email, password) -- saves as an encrypted file locally, this is used for auto logins when the user opens the game
    local savedJson = {email = email, password = password}
    local compressed = love.data.compress("string", "zlib", json.encode(savedJson), 9)
    love.filesystem.write("data/userinfo.dat", compressed)
end

function API:LoginUserFromSavedInfo()
    local decompressed = love.data.decompress("string", "zlib", love.filesystem.read("data/userinfo.dat"))
    local jsonData = json.decode(decompressed)

    API:LoginUser(jsonData.email, jsonData.password, false)
end