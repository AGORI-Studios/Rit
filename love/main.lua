--[[----------------------------------------------------------------------------

This file is apart of Rit; a free and open sourced rhythm game made with LÖVE.

Copyright (C) 2022 GuglioIsStupid

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
-- TODO: seperate all game shiz into seperate states (menu, song select, gameplay, etc)
local desktopWidth, desktopHeight = love.window.getDesktopDimensions()
fnfMomentShiz = {
    true, false
}
songSelectScrollOffset = 0
if love.filesystem.isFused() and (love.system.getOS() == "Windows" or love.system.getOS() == "OS X") then
    discordRPC = require "lib.discordRPC"
    nextPresenceUpdate = 0
end
function love.load()
    __VERSION__ = love.filesystem.read("version.txt")
    require "modules.loveFuncs"
    inputMod = require "modules.input"
    input = inputMod:_load_config(
        {
            ["one4"] = {"key:d"},
            ["two4"] = {"key:f"},
            ["three4"] = {"key:j"},
            ["four4"] = {"key:k"},
            
            ["up"] = {"key:up"},
            ["down"] = {"key:down"},
            ["left"] = {"key:left"},
            ["right"] = {"key:right"},
            ["confirm"] = {"key:return"},
            
            ["pause"] = {"key:return"},
            ["restart"] = {"key:r"},
            ["quit"] = {"key:escape"}
        }
    )
    flipY = 1 -- for downscroll

    ini = require "lib.ini"
    if discordRPC then 
        discordRPC.initialize("785717724906913843", true) 
        function discordRPC.ready(userId, username, discriminator, avatar)
            print(string.format("Discord: ready (%s, %s, %s, %s)", userId, username, discriminator, avatar))
        end
    
        function discordRPC.disconnected(errorCode, message)
            print(string.format("Discord: disconnected (%d: %s)", errorCode, message))
        end
    
        function discordRPC.errored(errorCode, message)
            print(string.format("Discord: error (%d: %s)", errorCode, message))
        end
    end
    settingsIni = require "settings"
    settingsIni.loadSettings()

    if settings.downscroll then
        flipY = 1
    end

    function round(num)
        return math.floor(num + 0.5)
    end

    speed = settings.scrollspeed or 1

    quaverLoader = require "parsers.quaverLoader"
    osuLoader = require "parsers.osuLoader"
    stepmaniaLoader = require "parsers.stepmaniaLoader"
    fnfLoader = require "parsers.fnfLoader"

    receptors = {}

    state = require "modules.state"

    game = require "states.game"
    songSelect = require "states.songSelect"
    skinSelect = require "states.skinSelect"

    push = require "lib.push"
    Timer = require "lib.timer"
    charthits = {}
    for i = 1, 4 do
        charthits[i] = {}
    end
    curSongSelected = 1
    font = love.graphics.newFont("fonts/Dosis-SemiBold.ttf", 16)
    scoreFont = love.graphics.newFont("fonts/Dosis-SemiBold.ttf", 64)
    accuracyFont = love.graphics.newFont("fonts/Dosis-SemiBold.ttf", 48)
    love.graphics.setFont(font)
    love.graphics.setDefaultFilter("nearest", "nearest")

    fourkColours = {
        {255, 0, 0},
        {0, 255, 0},
        {0, 0, 255},
        {255, 255, 0}
    }
    sevenkColours = {
        {255, 0, 0},
        {0, 255, 0},
        {0, 0, 255},
        {255, 255, 0},
        {255, 0, 255},
        {0, 255, 255},
        {255, 255, 255}
    }
    musicTimeDo = false
    health = 100

    love.window.setMode(settings.width, settings.height, {resizable = true, vsync = settings.vsync, fullscreen = settings.fullscreen})
    --resolution.setup(settings.width, settings.height, 1920, 1080, {_type = "normal"})
    push.setupScreen(1920, 1080, {upscale = "normal"})

    fnfMomentSelected = 1
    
    state.switch(skinSelect)
end

function love.resize(w, h)
    --resolution.resize(w, h, 1920, 1080, {_type = "normal"})
    push.resize(w, h)
end

function love.update(dt)
    Timer.update(dt)
    state.update(dt)
    if discordRPC then 
        if nextPresenceUpdate < love.timer.getTime() or 0 then
            if presence then 
                discordRPC.updatePresence(presence)
            end
            nextPresenceUpdate = love.timer.getTime() + 2.0
        end
        discordRPC.runCallbacks()
    end

    input:update(dt)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
    if key == "k" and (choosingSong or choosingSkin) then
        love.system.openURL("https://ko-fi.com/A0A8GRXMX")
    end
end

function love.draw()
    push.start()
        state:draw()
        if choosingSong or choosingSkin then
            -- set x and y to bottom left corner of screen
            love.graphics.print("Press K to open my Ko-fi page!", 1545, 1040, 0, 2, 2)
        end
    push.finish()
end

function love.focus(f)
    state.focus(f)
end

function love.quit()
    if discordRPC then 
        discordRPC.shutdown()
    end
end