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

local input = {}
local Player = {}
Player.__index = Player
function input:_load_config(config)
    -- config will be given as a table
    -- you can use it to set up your input module
    -- inputs will be given as key:value pairs or {"key:value", "button:value", "axis:value"}

    -- example:
    -- config = {
    --     ["up"] = {"key:w", "button:dpup"},
    --     ["down"] = {"key:s", "button:dpdown"},
    --     ["left"] = {"key:a", "button:dpleft"},
    --     ["right"] = {"key:d", "button:dpright"},
    --     ["jump"] = {"key:space", "button:a"},
    --     ["shoot"] = {"key:z", "button:b"},
    --     ["pause"] = {"key:p", "button:start"}
    -- }


    -- load the config into the input module
    -- this will be called once at the start of the game

    local config = config or {}
    
    for k, v in pairs(config) do
        input[k] = Player:new(v)
    end

    return input
end

function Player:new(keys)
    -- for every key, make a new thing for pressing, holding, and releasing
    local self = setmetatable({}, Player)
    self.keys = keys
    self.pressed = false
    self.down = false
    self.released = false
    
    -- make out functions
    self.isDown = function()
        return self.down
    end
    self.isPressed = function()
        return self.pressed
    end
    self.isReleased = function()
        return self.released
    end

    return self
end

function Player:update()
    -- update the pressed, down, and released values
    self.pressed = false
    self.released = false

    for k, v in pairs(self.keys) do
        local key, value = v:match("(.+):(.+)")
        if key == "key" then
            if love.keyboard.isDown(value) then
                self.down = true
            else
                self.down = false
            end
        elseif key == "button" then
            if love.joystick.isDown(1, value) then
                self.down = true
            else
                self.down = false
            end
        elseif key == "axis" then
            local axis, direction = value:match("(.+)(%+)")
            if direction == "+" then
                if love.joystick.getAxis(1, axis) > 0.5 then
                    self.down = true
                else
                    self.down = false
                end
            else
                if love.joystick.getAxis(1, axis) < -0.5 then
                    self.down = true
                else
                    self.down = false
                end
            end
        end
    end

    if self.down and not self.wasDown then
        self.pressed = true
    elseif not self.down and self.wasDown then
        self.released = true
    end

    self.wasDown = self.down
end

function input:update()
    for k, v in pairs(self) do
        if type(v) == "table" then
            v:update()
        end
    end
end

function input:pressed(key)
    return self[key].pressed
end

function input:isDown(key)
    return self[key].down
end

function input:released(key)
    return self[key].released
end

return input