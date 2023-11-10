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

local Pause = state()

local options = {
    "Resume",
    "Restart",
    "Leave",
}

function Pause:enter()
    self.selection = 1
end

function Pause:update(dt)
    if input:pressed("up") then
        self.selection = self.selection - 1
    elseif input:pressed("down") then
        self.selection = self.selection + 1
    end

    self.selection = math.clamp(self.selection, 1, #options)

    if input:pressed("confirm") then
        if self.selection == 1 then
            states.game.Gameplay.inPause = false
        elseif self.selection == 2 then
            state.switch(states.game.Gameplay)
        elseif self.selection == 3 then
            state.switch(states.menu.SongMenu)
        end
        previousFrameTime = love.timer.getTime() * 1000
        states.game.Gameplay.escapeTimer = 0
        state.killSubstate()
    end
end

function Pause:draw() 
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(Cache.members.font["menuBig"])
    love.graphics.printf("Paused", 0, 100, push:getWidth(), "center")

    love.graphics.setFont(Cache.members.font["menuMedium"])
    for i, v in ipairs(options) do
        if i == self.selection then
            love.graphics.setColor(1, 1, 1, 1)
        else
            love.graphics.setColor(0.5, 0.5, 0.5, 1)
        end
        love.graphics.printf(v, 0, 200 + (i * 50), push:getWidth(), "center")
    end

    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.setFont(Cache.members.font["default"])
end

function Pause:exit()

end

return Pause