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

fade = 1
isLoading = false

function love.load()
    speed = 2.5
    -- Libraries 
    Object = require("lib.Classic")
    Timer = require("lib.Timer")
    input = (require "lib.baton").new({
        controls = {
            gameLeft = { "axis:triggerleft+", "axis:leftx-", "axis:rightx-", "button:dpleft", "button:x", "key:d" },
            gameDown = { "axis:lefty+", "axis:righty+", "button:leftshoulder", "button:dpdown", "button:a", "key:f" },
            gameUp = { "axis:lefty-", "axis:righty-", "button:rightshoulder", "button:dpup", "button:y", "key:j" },
            gameRight = { "axis:triggerright+", "axis:leftx+", "axis:rightx+", "button:dpright", "button:b", "key:k" },

            -- UI
            up = { "key:up", "button:dpup", "axis:lefty-" },
            down = { "key:down", "button:dpdown", "axis:lefty+" },
            left = { "key:left", "button:dpleft", "axis:leftx-" },
            right = { "key:right", "button:dpright", "axis:leftx+" },

            confirm = { "key:return", "button:a" },
            back = { "key:escape", "button:b" },

            pause = { "key:return", "button:start" },
            restart = { "key:r", "button:b" },

            -- Misc
            extB = { "button:back" },
            volUp = { "button:rightshoulder" },
            volDown = { "button:leftshoulder" },

            quit = { "key:escape", "button:back" }
        },
        joystick = love.joystick.getJoysticks()[1]
    })
    json = require("lib.json").decode
    push = require("lib.push")
    lume = require("lib.lume")
    state = require("lib.state")
    tinyyaml = require("lib.tinyyaml")

    -- Classes
    Group = require("modules.Classes.Group")
    Cache = require("modules.Classes.Cache")
    Point = require("modules.Classes.Point")
    Sprite = require("modules.Classes.Sprite")
    util = require("modules.util")
    require("modules.Game.songs")

    -- Objects
    StrumObject = require("modules.Objects.game.StrumObject")
    HitObject = require("modules.Objects.game.HitObject")

    -- Parsers
    quaverLoader = require("modules.Parsers.quaverLoader")
    osuLoader = require("modules.Parsers.osuLoader")

    cache = {
        images = {},
        sprites = {},
        fonts = {},
        sounds = {},
        music = {}
    }

    cache.fonts["default"] = love.graphics.newFont("assets/fonts/Dosis-SemiBold.ttf", 16)
    function setFont(font)
        love.graphics.setFont(cache.fonts[font])
    end
    function fontWidth(font, text)
        return cache.fonts[font]:getWidth(text)
    end
    function fontHeight(font, text)
        return cache.fonts[font]:getHeight(text)
    end
    
    -- States
    states = {
        game = {
            Gameplay = require("states.game.Gameplay"),
        },
        menu = {
            StartMenu = require("states.menu.StartMenu"),
            SongMenu = require("states.menu.SongMenu"),
        },
    }

    --love.window.setMode(1280, 720, {fullscreen = false, resizable = true})
    push.setupScreen(1920, 1080, {fullscreen = false, resizable = true, upscale = "normal"})
    
    state.switch(states.menu.StartMenu)
end

function switchState(newState, t, middleFunc)
    local t = t or 0.3
    isLoading = true
    Timer.tween(t, _G, {fade = 0}, "linear", function()
        if middleFunc then middleFunc() end
        state.switch(newState)
        isLoading = false
        Timer.tween(t, _G, {fade = 1}, "linear")
    end)
end

function love.update(dt)
    local dt = math.min(dt, 1/30) -- cap dt to 30fps
    Timer.update(dt)
    if not isLoading then state.update(dt) end
    input:update()
end

function love.resize(w,h)
    push.resize(w,h)
    state.resize(w,h)
end

function love.draw()
    push:start()
    love.graphics.setColor(1, 1, 1)
    state.draw()
    push:finish()

    love.graphics.print(
        "FPS: " .. love.timer.getFPS() .. "\n" ..
        "Music Time: " .. (musicTime or "N/A") .. "\n" ..
        "Draw Calls: " .. love.graphics.getStats().drawcalls .. "\n" ..
        "Memory: " .. math.floor(collectgarbage("count")) .. "KB\n" ..
        "Graphics Memory: " .. math.floor(love.graphics.getStats().texturememory/1024/1024) .. "MB\n"
    )
end