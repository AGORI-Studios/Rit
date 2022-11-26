local settingsIni = {}
settings = {}
settingsStr = [[
[Game]
downscroll = True
scrollspeed = 1.0
; Currently WIP, while it works, it's not recommended to use it
Scroll Velocities = False

[Graphics]
width = 1280
height = 720
fullscreen = False
vsync = False

[Audio]
volume = 1.0

[System]
version = 0.0.1-beta
]]

function settingsIni.loadSettings()
    
    if not love.filesystem.getInfo("settings.ini") then
        love.filesystem.write("settings.ini", settingsStr)
    end
    inifile = ini.load("settings.ini")
    settings.version = inifile["System"]["version"] or "Unknown"
    if settings.version ~= "0.0.1-beta" then
        love.filesystem.write("settings.ini", settingsStr)
    end
    settings.downscroll = inifile["Game"]["downscroll"]
    settings.scrollspeed = inifile["Game"]["scrollspeed"]
    settings.scrollvelocities = inifile["Game"]["Scroll Velocities"]

    settings.width = inifile["Graphics"]["width"]
    settings.height = inifile["Graphics"]["height"]
    settings.fullscreen = inifile["Graphics"]["fullscreen"]
    settings.vsync = inifile["Graphics"]["vsync"]

    settings.volume = inifile["Audio"]["volume"]

    settings.downscroll = settings.downscroll == "True"
    settings.scrollspeed = tonumber(settings.scrollspeed)
    settings.scrollvelocities = settings.scrollvelocities == "True"
    
    settings.width = tonumber(settings.width)
    settings.height = tonumber(settings.height)
    settings.vsync = settings.vsync == "True"
    settings.fullscreen = settings.fullscreen == "True"

    settings.volume = tonumber(settings.volume)
end
return settingsIni