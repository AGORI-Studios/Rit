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

local Cache = {}

Cache.members = {
    image = {},
    font = {},
    sound = {},
    music = {},
    sprite = {},
}

function Cache:clear()
    for k, v in pairs(self.members) do
        self.members[k] = {}
    end
end

function Cache:loadImage(...) -- so we can load multiple images at once
    for i, v in ipairs({...}) do
        if not self.members.image[v] then
            self.members.image[v] = love.graphics.newImage(v)
        end

        if #{...} == 1 then
            return self.members.image[v]
        else
            if i == #{...} then
                return self.members.image[v]
            end
        end
    end
end

function Cache:loadFont(path, size)
    if not self.members.font[path] then
        self.members.font[path] = love.graphics.newFont(path, size)
    end

    return self.members.font[path]
end

function Cache:loadSound(path)
    if not self.members.sound[path] then
        self.members.sound[path] = love.audio.newSource(path, "static")
    end

    return self.members.sound[path]
end

function Cache:loadMusic(path)
    if not self.members.music[path] then
        self.members.music[path] = love.audio.newSource(path, "stream")
    end

    return self.members.music[path]
end

--[[ function Cache:loadSprite(path, width, height)
    if not self.members.sprite[path] then
        self.members.sprite[path] = Sprite(path, width, height)
    end

    return self.members.sprite[path]
end ]]

return Cache