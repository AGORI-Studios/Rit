--[[----------------------------------------------------------------------------

This file is apart of Rit; a free and open sourced rhythm game made with LÖVE.

Copyright (C) 2023 GuglioIsStupid

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

------------------------------------------------------------------------------]]

local settingsIni = {}
settings = {}
settingsStr = [[
[Game]
; Makes the notes scroll down instead of up
downscroll = True

; scroll speed is the scroll speed ever
scrollspeed = 1.0

; Currently WIP, while it works, it's not recommended to use it
Scroll Velocities = False

; Start time is for the amount of time to wait before the song starts (In milliseconds)
startTime = 700

; Note spacing is the amount of space between each note (in pixels) ((its broken as fuck))
noteSpacing = 200

[Graphics]
; Screen width/height
width = 1280
height = 720

; Fullscreen mode
fullscreen = False

; Vertical sync
vsync = False

[Audio]
; Master volume
volume = 1.0

[System]
version = 0.0.3-beta
]]

function settingsIni.loadSettings()
    
    if not love.filesystem.getInfo("settings.ini") then
        love.filesystem.write("settings.ini", settingsStr)
    end
    inifile = ini.load("settings.ini")
    settings.version = inifile["System"]["version"] or "Unknown"
    if settings.version ~= "0.0.3-beta" then
        love.filesystem.write("settings.ini", settingsStr)
    end
    settings.downscroll = inifile["Game"]["downscroll"]
    settings.scrollspeed = inifile["Game"]["scrollspeed"]
    settings.scrollvelocities = inifile["Game"]["Scroll Velocities"]
    settings.startTime = inifile["Game"]["startTime"]
    settings.noteSpacing = inifile["Game"]["noteSpacing"]

    settings.width = inifile["Graphics"]["width"]
    settings.height = inifile["Graphics"]["height"]
    settings.fullscreen = inifile["Graphics"]["fullscreen"]
    settings.vsync = inifile["Graphics"]["vsync"]

    settings.volume = inifile["Audio"]["volume"]

    settings.downscroll = settings.downscroll == "True"
    settings.scrollspeed = tonumber(settings.scrollspeed)
    settings.scrollvelocities = settings.scrollvelocities == "True"
    settings.startTime = tonumber(settings.startTime)
    
    settings.width = tonumber(settings.width)
    settings.height = tonumber(settings.height)
    settings.vsync = settings.vsync == "True"
    settings.fullscreen = settings.fullscreen == "True"

    love.audio.setVolume(settings.volume)
end
return settingsIni