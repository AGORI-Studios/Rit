local SettingsManager = {}

local settingsFilePath = "CacheData/User/Settings.rs"

love.filesystem.createDirectory("CacheData/User")

local SettingsDefault = {
    Game = {
        ScrollSpeed = 70,
    },
    Audio = {
        Master = 1,
        Effects = 1,
        Music = 1,
    }
}

function SettingsManager:loadSettings()
    local exists = love.filesystem.getInfo(settingsFilePath)
    if exists then
        self._settings = Json.decode(FileHandler:readEncryptedFile(settingsFilePath))
    else
        FileHandler:writeEncryptedFile(settingsFilePath, Json.encode(SettingsDefault))

        self._settings = SettingsDefault
    end
end

function SettingsManager:getSetting(category, setting)
    if category == "Game" and setting == "ScrollSpeed" then
        local speed = self._settings[category][setting]
        -- the base game height is 1080
        -- the scrollspeed is made with 1080 in mind
        -- convert it properly to the current window height
        return (speed/10) / 5 * (1080/Game._windowHeight)
    else
        return self._settings[category][setting]
    end
end

return SettingsManager