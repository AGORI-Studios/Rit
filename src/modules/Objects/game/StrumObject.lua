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

local StrumObject = Sprite:extend()

StrumObject.resetAnim = 0
StrumObject.data = 1

function StrumObject:new(x, y, data)
    self.super.new(self, x, y)
    self.data = data

    self.anims = {}
    if skinData["NoteAssets"][tostring(states.game.Gameplay.mode) .. "k_" .. data .. "_receptor_unpressed"] then
        self.anims[1] = skin:format(skinData["NoteAssets"][tostring(states.game.Gameplay.mode) .. "k_" .. data .. "_receptor_unpressed"])
    else
        -- default to left
        self.anims[1] = skin:format(skinData["NoteAssets"]["1k_1_receptor_unpressed"])
    end
    if skinData["NoteAssets"][tostring(states.game.Gameplay.mode) .. "k_" .. data .. "_receptor_pressed"] then
        self.anims[2] = skin:format(skinData["NoteAssets"][tostring(states.game.Gameplay.mode) .. "k_" .. data .. "_receptor_pressed"])
    else
        -- default to left
        self.anims[2] = skin:format(skinData["NoteAssets"]["1k_1_receptor_pressed"])
    end
    

    Cache:loadImage(self.anims[1], self.anims[2])

    self.graphic = Cache:loadImage(self.anims[1])

    -- todo. different note images for different lanes (skin dependent)

    self:updateHitbox()
    self:setGraphicSize(math.floor(self.width * 0.925))

    return self
end

function StrumObject:update(dt)
    if self.resetAnim > 0 then
        self.resetAnim = self.resetAnim - dt
        if self.resetAnim <= 0 then
            self.graphic = Cache:loadImage(self.anims[1])
        end
    end

    self.super.update(self, dt)
end

function StrumObject:postAddToGroup()
    self.graphic = Cache:loadImage(self.anims[1])
    self.x = self.x + (self.width * 0.925) * (self.data - 1)
    self.x = self.x + 25
    self.ID = self.data
end

function StrumObject:playAnim(anim)
    if anim == "pressed" then
        self.graphic = Cache:loadImage(self.anims[2])
    elseif anim == "unpressed" then
        self.graphic = Cache:loadImage(self.anims[1])
    end
end

return StrumObject