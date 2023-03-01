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
graphics.drawTable = {}
for layer = 1, 100 do 
    graphics.drawTable[layer] = {}
end
graphics.drawTable[100].notes = {}
for i = 1, 4 do 
    graphics.drawTable[100].notes[i] = {}
end

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
        layer = 0,
        stencilInfo = nil,

        getWidth = function(self)
            return self.img:getWidth()
        end,

        getHeight = function(self)
            return self.img:getHeight()
        end,

        draw = function(self, x, y, sx, sy)
            if x == nil then x = self.x end
            if y == nil then y = self.y end
            if sx == nil then sx = self.scaleX end
            if sy == nil then sy = self.scaleY end      
            if self.stencilInfo then 
                rect = {
                    x = x + self.stencilInfo.x,
                    y = y + self.stencilInfo.y,
                    w = self.stencilInfo.width,
                    h = self.stencilInfo.height
                }
                local function stencil()
                    love.graphics.push()
                    love.graphics.translate(rect.x + rect.w / 2, rect.y + rect.h / 2)
                    love.graphics.translate(-rect.w / 2, -rect.h / 2)
                    love.graphics.rectangle("fill", 0, 0, rect.w, rect.h)
                    print(rect.w, rect.h)
                    love.graphics.pop()
                end
                love.graphics.stencil(stencil, "replace", 1)
			    love.graphics.setStencilTest("greater", 0)
            end

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

            if self.stencilInfo then 
                self.stencilInfo = nil
                love.graphics.setStencilTest()
            end
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

function graphics.add(obj, layer)
    if layer == nil then obj.layer = 0 end
    if graphics.drawTable[layer] == nil then graphics.drawTable[layer] = {} end
end

function graphics.addNotes(num, obj)
    if graphics.drawTable[100].notes[num] == nil then graphics.drawTable[100].notes[num] = {} end
    table.insert(graphics.drawTable[100].notes[num], obj)
end

function graphics.draw()
    -- draw objects with a lower layer first
    for i = 0, #graphics.drawTable do
        if graphics.drawTable[i] ~= nil then
            for j = 1, #graphics.drawTable[i] do
                graphics.drawTable[i][j]:draw()
            end
        end
    end
end

function graphics.drawNotes()
    for i = 1, 4 do
        for j = 1, #graphics.drawTable[100].notes[i] do
            if graphics.drawTable[100].notes[i][j].isSustainNote then 
                love.graphics.setScissor(-400, 100, 3000, 632) -- lazy way out of ugly stuff at top if missed
            end
            graphics.drawTable[100].notes[i][j]:draw()
            
            love.graphics.setScissor()
        end
    end
end

function graphics.drawReceptors()
    love.graphics.push()
        love.graphics.scale(0.8, 0.8)
        for i = 1, 4 do 
            receptors[i][receptors[i][3]]:draw()
        end
    love.graphics.pop()
end

function graphics.removeNote(lane, note)
    for i = 1, #graphics.drawTable[100].notes[lane] do
        if graphics.drawTable[100].notes[lane][i] == note then
            table.remove(graphics.drawTable[100].notes[lane], i)
            break
        end
    end
end


return graphics