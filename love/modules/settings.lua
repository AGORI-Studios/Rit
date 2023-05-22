sh = {}
sh.baseSettings = {
    ["Game"] = {
        ["downscroll"] = true,
        ["underlay"] = true,
        ["scroll speed"] = 1.0,
        ["scroll velocities"] = true,
        ["start time"] = 700,
        ["note spacing"] = 200,
        ["autoplay"] = false,
        ["audio offset"] = 0
    },
    ["Graphics"] = {
        width = 1280,
        height = 720,
        fullscroll = false,
        vsync = false
    },
    ["Audio"] = {
        Master = 1.0,
        Music = 1.0,
        SFX = 1.0
    },
    ["System"] = {
        version = "1"
    },

    skin = "Circle Default" -- The skin chosen by the player.
}

function sh.saveSettings(base) 
    local saveStr = ""
    -- use lume to save the settings table
    local saveString = base and lume.serialize(base) or lume.serialize(sh.settings)
    love.filesystem.write("settings.ritsettings", saveString)
end

function sh.loadSettings()
    if love.filesystem.getInfo("settings.ritsettings") then
        local settings = love.filesystem.read("settings.ritsettings")
        return lume.deserialize(settings)
    else
        return false
    end
end

sh.settings = sh.loadSettings() or sh.baseSettings
print(sh.settings["Game"]["scroll speed"])

return sh