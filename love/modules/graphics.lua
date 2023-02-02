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

local graphics = {}

graphics.cache = {}

function graphics.newImage(path)
    if not graphics.cache[path] then
        graphics.cache[path] = love.graphics.newImage(path)
    end
    return {
        img = graphics.cache[path],
        x = 0,
        y = 0,
        rotation = 0,
        scaleX = 1,
        scaleY = 1,
        offsetX = 0,
        offsetY = 0,
        shearX = 0,
        shearY = 0,

        getWidth = function(self)
            return self.img:getWidth()
        end,

        getHeight = function(self)
            return self.img:getHeight()
        end,

        draw = function(self, x, y, sx, sy)
            love.graphics.draw(
                self.img, 
                x or self.x, 
                y or self.y, 
                self.rotation, 
                sx or self.scaleX, 
                sy or self.scaleY, 
                self.img:getWidth() / 2 + self.offsetX,
                self.img:getHeight() / 2 + self.offsetY,
                self.shearX, 
                self.shearY
            )
        end
    }
end

function graphics.clearCache()
    graphics.cache = {}
end

function graphics.clearItemFromCache(path)
    graphics.cache[path] = nil
end

function graphics.getWidth()
    return push:getWidth()
end

function graphics.getHeight()
    return push:getHeight()
end



return graphics