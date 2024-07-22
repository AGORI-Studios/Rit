local StorageAPI = {}
local STORAGER_SERVER_URL = "https://storage.googleapis.com/" -- ! TEMPORARY

function StorageAPI.downloadTestSong()
    if not https then
        return 
    end
    local code, body, headers = https.request(STORAGER_SERVER_URL .. "mapsets/TimeTraveler.Rit")
    print(STORAGER_SERVER_URL .. "mapsets/TimeTraveler.Rit")
    if code == 200 then
        love.filesystem.write("songs/TimeTraveler.rit", body)
    else
        print("ERROR : " .. code)
    end
end

return StorageAPI