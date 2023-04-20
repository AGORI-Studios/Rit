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
settingsStr = love.system.getOS() ~= "NX" and [[
[Game]
; Makes the notes scroll down instead of up
; UPSCROLL IS NOT AS STABLE AS DOWNSCROLL, USE AT YOUR OWN RISK! MAY BREAK VISUALS!
downscroll = True

; scroll speed is the scroll speed ever
scrollspeed = 1.0

; Currently WIP, while it works, it's not recommended to use it
Scroll Velocities = False

; Start time is for the amount of time to wait before the song starts (In milliseconds)
startTime = 700

; Note spacing is the amount of space between each note (in pixels) ((its broken a bit tho))
noteSpacing = 200

; Autoplay - automatically play songs without user input. Can also be toggled with B in song select.
autoplay = False

; Audio Offset - the amount of time to offset the audio by (in milliseconds)
audioOffset = 0

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
version = settingsVer1/0.0.3-beta
]] or [[
; Makes the notes scroll down instead of up
; UPSCROLL IS NOT AS STABLE AS DOWNSCROLL, USE AT YOUR OWN RISK! MAY BREAK VISUALS!
downscroll = True

; scroll speed is the scroll speed ever
scrollspeed = 1.0

; Currently WIP, while it works, it's not recommended to use it
Scroll Velocities = False

; Start time is for the amount of time to wait before the song starts (In milliseconds)
startTime = 700

; Note spacing is the amount of space between each note (in pixels) ((its broken a bit tho))
noteSpacing = 200

; Autoplay - automatically play songs without user input. Can also be toggled with B in song select.
autoplay = False

; Audio Offset - the amount of time to offset the audio by (in milliseconds)
audioOffset = 0

[Graphics]

; Vertical sync
vsync = False

[Audio]
; Master volume
volume = 1.0

[System]
version = settingsVer1/0.0.3-beta
]] -- NX (Nintendo Switch)

function settingsIni.loadSettings()
    settings.curSystem = love.system.getOS()
    if not love.filesystem.getInfo("settings.ini") then
        love.filesystem.write("settings.ini", settingsStr)
    end
    inifile = ini.load("settings.ini")
    settings.version = inifile["System"]["version"] or "Unknown"
    if settings.version ~= "settingsVer1/0.0.3-beta" then
        love.filesystem.write("settings.ini", settingsStr)
    end
    settings.downscroll = inifile["Game"]["downscroll"] == "True" or false
    settings.scrollspeed = tonumber(inifile["Game"]["scrollspeed"]) or 1.0
    settings.scrollvelocities = inifile["Game"]["Scroll Velocities"] == "True"
    settings.startTime = tonumber(inifile["Game"]["startTime"]) or 700
    settings.noteSpacing = tonumber(inifile["Game"]["noteSpacing"]) or 200
    settings.autoplay = inifile["Game"]["autoplay"] == "True" or false
    settings.audioOffset = tonumber(inifile["Game"]["audioOffset"]) or 0

    if settings.curSystem ~= "NX" then
        settings.width = tonumber(inifile["Graphics"]["width"]) or 1280
        settings.height = tonumber(inifile["Graphics"]["height"]) or 720
        settings.fullscreen = inifile["Graphics"]["fullscreen"] == "True" or false
    else
        settings.width = 1920
        settings.height = 1080
        settings.fullscreen = false
    end
    settings.vsync = inifile["Graphics"]["vsync"] == "True" or false

    settings.volume = inifile["Audio"]["volume"] or 1.0

    love.audio.setVolume(settings.volume)
end

return settingsIni
