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
return {
    enter = function(self)
        logo = love.graphics.newImage("assets/images/ui/menu/logo.png")

        logoSize = 1

        spectrum:setup()

        beat = 0
        time = 0
    end,

    update = function(self, dt)
        time = time + dt * 1000

        if (time > (60/menuBPM) * 1000) then
            local curBeat = math.floor(menuMusic:tell() / (60/menuBPM))
            if curBeat % 2 == 0 then
                logoSize = 1.1
            end
            time = 0
        end

        spectrum:update(menuMusic, menuMusicData)

        if logoSize > 1 then
            logoSize = logoSize - (dt * ((menuBPM/60))) * 0.3
        end

        if input:pressed("confirm") then
            state.switch(songSelect)
        end
    end,

    draw = function(self)
        love.graphics.push()
            love.graphics.scale(0.35, 0.35)
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(
                logo, 
                push.getWidth()+1000, push.getHeight()+400, 
                0, 
                logoSize, logoSize, 
                logo:getWidth() / 2, logo:getHeight() / 2
            )
        love.graphics.pop()
        love.graphics.setColor(1, 1, 1)
        love.graphics.push()
            spectrum:draw()
        love.graphics.pop()
    end,

    leave = function(self)

    end
}