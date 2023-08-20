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
graphics.fade = {1}

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
        sparrowSheet = false,
        curFrame = 1,
        frames = {},
        animations = {},
        isLooped = false,
        anims = {},
        xmlData = {},

        drawLayer = 1,

        r = 1,
        g = 1,
        b = 1,
        a = 1,

        width = graphics.cache[path]:getWidth(),
        height = graphics.cache[path]:getHeight(),

        getWidth = function(self)
            self.width = self.img:getWidth() * self.scaleX
            return self.img:getWidth() * self.scaleX
        end,

        animate = function(self, animName, func)
            self.curAnim = self.animations[animName]
            self.curName = animName
            
            self.time = 1 
            self.finished = false
            self.isLooped = self.curAnim.loop
        
        end,

        loadAnims = function(self)
            local frames = {}
		    local frame

            local isAnimated
            local isLooped

            -- parse xml
            --print(folderPath .. "/" .. self.sparrowSheet)
            local data = xml(love.filesystem.read(folderPath .. "/mod/" .. self.sparrowSheet))

            -- go inside TextureAtlas tag
            -- for all SubTextures, add it to the frames table with [i] index (number)
            for i, v in ipairs(data) do
                if v.tag == "SubTexture" then
                    local d = {
                        x = tonumber(v.attr.x),
                        y = tonumber(v.attr.y),
                        width = tonumber(v.attr.width),
                        height = tonumber(v.attr.height),
                        frameX = tonumber(v.attr.frameX) or 0,
                        frameY = tonumber(v.attr.frameY) or 0,
                        frameWidth = tonumber(v.attr.frameWidth) or 0,
                        frameHeight = tonumber(v.attr.frameHeight) or 0,
                    }
                    d.offset = {x=d.frameX, y=d.frameY, width=d.frameWidth, height=d.frameHeight}

                    local name = string.sub(v.attr.name, 1, -5)
                    if not self.xmlData[name] then self.xmlData[name] = {} end
                    table.insert(self.xmlData[name], d)
                    --print(self.xmlData[name])
                end
            end
        end,

        addAnim = function(self, name, prefix, framerate, loop)
            if framerate == nil then framerate = 24 end
            if loop == nil then loop = true end

            local anim = {
                prefix = prefix,
                framerate = framerate,
                loop = loop,
                frames = {}
            }

            local add = function(f)
                table.insert(anim.frames, {
                    quad = love.graphics.newQuad(f.x, f.y, f.width, f.height, self.img:getDimensions()),
                    data = f
                })
            end

            --print(self.xmlData[prefix])
            for _, f in ipairs(self.xmlData[prefix]) do
                add(f)
            end

            self.animations[name] = anim
            self.lastAnimAdded = name
        end,

        setSparrowSheet = function(self, file)
            self.sparrowSheet = file

            self:loadAnims()
        end,

        getHeight = function(self)
            self.height = self.img:getHeight() * self.scaleY
            return self.img:getHeight() * self.scaleY
        end,

        update = function(self, dt)
            if self.sparrowSheet then
                if self.curAnim then 
                    self.time = self.time + dt * self.curAnim.framerate
                    if self.time > #self.curAnim.frames then
                        if self.isLooped then
                            self.time = 1
                        else
                            self.time = #self.curAnim.frames
                            self.finished = true
                        end
                    end
                end
            end
        end,

        changeAnimSpeed = function(self, speed)
            self.curAnim.framerate = speed
        end,

        draw = function(self, x, y, sx, sy)
            local x = x or self.x
            local y = y or self.y
            local sx = sx or self.scaleX
            local sy = sy or self.scaleY
            
            graphics.setColor(self.r, self.g, self.b, self.a)
            if not self.sparrowSheet then
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
            else
                local frame 
                if self.curAnim then 
                    frame = self.curAnim.frames[math.floor(self.time)]
                else
                    frame = self.lastAnimAdded.frames[1]
                end

                ox = math.floor(frame.data.offset.width / 2 - frame.data.offset.width) + frame.data.offset.x + self.offsetX
                oy = math.floor(frame.data.offset.height / 2 - frame.data.offset.height) + frame.data.offset.y + self.offsetY

                love.graphics.draw(
                    self.img, 
                    frame.quad, 
                    self.x, 
                    self.y, 
                    self.rotation, 
                    sx or self.scaleX, 
                    sy or self.scaleY, 
                    ox,
                    oy,
                    self.shearX, 
                    self.shearY
                )
            end
            graphics.setColor(1, 1, 1, 1)
        end
    }
end

function graphics.newRectangle(x, y, width, height, color)
    local rect = {
        x = x,
        y = y,
        width = width,
        height = height,
        color = color,
        update = function(self, dt)
        end,
        draw = function(self)
            graphics.setColor(self.color)
            love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
            graphics.setColor(1, 1, 1, 1)
        end
    }
    return rect
end

function graphics.newCircle(x, y, radius, color)
    local circle = {
        x = x,
        y = y,
        radius = radius,
        color = color,
        update = function(self, dt)
        end,
        draw = function(self)
            graphics.setColor(self.color)
            love.graphics.circle("fill", self.x, self.y, self.radius)
            graphics.setColor(1, 1, 1, 1)
        end
    }
    return circle
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

function graphics.fadeIn(d, cb)
    Timer.tween(d, graphics.fade, {1}, "linear", cb or function() end)
end

function graphics.fadeOut(d, cb)
    Timer.tween(d, graphics.fade, {0}, "linear", cb or function() end)
end

function graphics.setFade(f)
    graphics.fade = f
end

function graphics.setColor(r,g,b,a)
    local r,g,b,a = r or 1, g or 1, b or 1, a or 1
    if type(r) == "table" then
        r,g,b,a = r[1] or 1, r[2] or 1, r[3] or 1, r[4] or 1
    end
    local f = graphics.fade[1]
    love.graphics.setColor(r*f,g*f,b*f,a)
end

return graphics