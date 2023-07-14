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

local inputList = {
    "confirm"
}

return {
    enter = function(self)
        logo = love.graphics.newImage("assets/images/ui/menu/logo.png")

        logoSize = 1

        spectrum:setup()

        beat = 0
        time = 0

        inputs = {
            ["confirm"] = {
                pressed = false,
                down = false,
                released = false
            }
        }

        if isMobile or __DEBUG__ then
            mobileButtons = {
                ["confirm"] = {
                    pressed = false,
                    down = false,
                    released = false,

                    x = 900,
                    y = 400,
                    w = 300,
                    h = 300,

                    draw = function(self)
                        -- rounded rectangle, fill if down

                        if self.down then
                            love.graphics.setColor(1, 1, 1, 0.5)
                            love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, 50, 50)
                        end

                        love.graphics.setColor(1, 1, 1, 1)
                        love.graphics.rectangle("line", self.x, self.y, self.w, self.h, 50, 50)
                    end
                }
            }
        end
    end,

    update = function(self, dt)
        for i = 1, #inputList do
            local curInput = inputList[i]

            if not isMobile and __DEBUG__ and mobileButtons then
                inputs[curInput].pressed = input:pressed(curInput) or mobileButtons[curInput].pressed
                inputs[curInput].down = input:down(curInput) or mobileButtons[curInput].down
                inputs[curInput].released = input:released(curInput) or mobileButtons[curInput].released
            elseif not isMobile then
                inputs[curInput].pressed = input:pressed(curInput)
                inputs[curInput].down = input:down(curInput)
                inputs[curInput].released = input:released(curInput)
            elseif isMobile then
                inputs[curInput].pressed = mobileButtons[curInput].pressed
                inputs[curInput].down = mobileButtons[curInput].down
                inputs[curInput].released = mobileButtons[curInput].released
            end
        end

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

        if inputs["confirm"].pressed then
            state.switch(songSelect)
        end

        if mobileButtons then
            for i,v in pairs(mobileButtons) do
                v.pressed = false
                v.released = false
            end
        end

        for i, v in pairs(inputs) do
            v.pressed = false
            v.released = false
        end
    end,

    touchpressed = function(self, id, x, y, dx, dy, pressure)
        if mobileButtons then
            for i, v in pairs(mobileButtons) do
                if x > v.x and x < v.x + v.w and y > v.y and y < v.y + v.h then
                    v.pressed = true
                    v.down = true
                end
            end
        end
    end,

    touchreleased = function(self, id, x, y, dx, dy, pressure)
        if mobileButtons then
            for i, v in pairs(mobileButtons) do
                if x > v.x and x < v.x + v.w and y > v.y and y < v.y + v.h then
                    v.released = true
                    v.down = false
                end
            end
        end
    end,

    touchmoved = function(self, id, x, y, dx, dy, pressure)
        if mobileButtons then
            for i, v in pairs(mobileButtons) do
                -- if its no longer in the button, set it to false
                if not (x > v.x and x < v.x + v.w and y > v.y and y < v.y + v.h) then
                    v.pressed = false
                    v.down = false
                    v.released = true
                end
            end
        end
    end,

    mousepressed = function(self, x, y, button)
        if mobileButtons then
            for i, v in pairs(mobileButtons) do
                if x > v.x and x < v.x + v.w and y > v.y and y < v.y + v.h then
                    v.pressed = true
                    v.down = true
                end
            end
        end 
    end,

    mousereleased = function(self, x, y, button)
        if mobileButtons then
            for i, v in pairs(mobileButtons) do
                if x > v.x and x < v.x + v.w and y > v.y and y < v.y + v.h then
                    v.released = true
                    v.down = false
                end
            end
        end
    end,

    mousemoved = function(self, x, y, dx, dy, istouch)
        if mobileButtons then
            for i, v in pairs(mobileButtons) do
                -- if its no longer in the button, set it to false
                if not (x > v.x and x < v.x + v.w and y > v.y and y < v.y + v.h) then
                    v.pressed = false
                    v.down = false
                    v.released = true
                end
            end
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
        mobileButtons = nil
    end
}