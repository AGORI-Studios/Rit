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

local SplashScreen = state()
local timer = 0
local fade = {1}
local progression = 0
local positions = {
    {x=0,y=-100},
    {x=0,y=1090}
}

function SplashScreen:enter()
    Timer.tween(1, positions[1], {y = push:getHeight()/2-100}, "in-expo")
    Timer.after(1.5, function()
        Timer.tween(1, positions[2], {y = push:getHeight()/2}, "in-expo")

        Timer.after(1.5, function()
            Timer.tween(0.75, fade, {0}, "out-quad", function()
                state.switch(states.menu.StartMenu)
            end)
        end)
    end)
end

function SplashScreen:update(dt)
    
end

function SplashScreen:draw()
    love.graphics.setColor(1,1,1,fade[1])
    love.graphics.printf(
        "Rit.",
        positions[1].x, positions[1].y,
        push:getWidth()/3,
        "center",
        0, 3, 3
    )
    love.graphics.printf(
        "A game by AGORI Studios.",
        positions[2].x, positions[2].y,
        push:getWidth()/3,
        "center",
        0, 3, 3
    )
    love.graphics.setColor(1,1,1,1)
end

return SplashScreen