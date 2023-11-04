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

local HitObject = Sprite:extend()

HitObject.time = 0
HitObject.data = 1
HitObject.canBeHit = false
HitObject.tooLate = false
HitObject.wasGoodHit = false
HitObject.noteWasHit = false

HitObject.prevNote = nil
HitObject.nextNote = nil

HitObject.spawned = false

HitObject.tail = {}
HitObject.parent = nil
HitObject.blockHit = false

HitObject.sustainLength = 0
HitObject.isSustainNote = false

HitObject.SUSTAIN_SIZE = 44

HitObject.offsetX = 0
HitObject.offsetY = 0
HitObject.offsetAngle = 0
HitObject.multAlpha = 1
HitObject.multSpeed = 1

HitObject.hitHealth = 0.023
HitObject.missHealth = 0.475

HitObject.distance = 2000
HitObject.correctionOffset = 0

function HitObject:new(time, data, prevNote, sustainNote) 
    self.super.new(self)
    local sustainNote = sustainNote or false

    if not prevNote then
        prevNote = self
    end

    self.prevNote = prevNote
    self.isSustainNote = sustainNote
    self.moves = false

    self.x = self.x + states.game.Gameplay.strumX + 25
    self.y = -2000

    self.time = time
    self.data = data

    -- assets are like [mode]k_data
    if skinData["NoteAssets"][tostring(states.game.Gameplay.mode) .. "k_" .. data .. "_note"] then
        self:load(skin:format(skinData["NoteAssets"][tostring(states.game.Gameplay.mode) .. "k_" .. data .. "_note"]))
    else
        -- default to left
        self:load(skin:format(skinData["NoteAssets"]["1k_1_note"]))
    end

    self:setGraphicSize(math.floor(self.width * 0.925))
    _G.__NOTE_OBJECT_WIDTH = self.width

    self.x = self.x + (self.width * 0.925+4) * (data-1)

    if self.prevNote then
        self.prevNote.nextNote = self
    end

    if self.isSustainNote and self.prevNote then
        self.offsetX = self.offsetX + (self.width * 0.925)/2

        if skinData["NoteAssets"][tostring(states.game.Gameplay.mode) .. "k_" .. data .. "_hold_end"] then
            self:load(skin:format(skinData["NoteAssets"][tostring(states.game.Gameplay.mode) .. "k_" .. data .. "_hold_end"]))
        else
            -- default to left
            self:load(skin:format(skinData["NoteAssets"]["1k_1_hold_end"]))
        end
        self:updateHitbox()
        self.offsetX = self.offsetX - (self.width)/2
        self.flipY = not downscroll
        self.correctionOffset = downscroll and 67 or 58

        if self.prevNote.isSustainNote then
            self.prevNote.flipY = false
            if skinData["NoteAssets"][tostring(states.game.Gameplay.mode) .. "k_" .. data .. "_hold"] then
                self.prevNote:load(skin:format(skinData["NoteAssets"][tostring(states.game.Gameplay.mode) .. "k_" .. data .. "_hold"]))
            else
                -- default to left
                self.prevNote:load(skin:format(skinData["NoteAssets"]["1k_1_hold"]))
            end
            self.prevNote.scale.y = ((stepCrochet/100) * (1.0525)) * speed
            self.offsetY = 0
            self.prevNote.correctionOffset = downscroll and 0 or 35
        end
    end

    self.x = self.x + self.offsetX

    return self
end

function HitObject:update(dt)
    self.super.update(self, dt)

    self.canBeHit = self.time > musicTime - safeZoneOffset and self.time < musicTime + safeZoneOffset
    if self.time < musicTime - safeZoneOffset and not self.wasGoodHit then
        self.tooLate = true
    end
    
    if self.tooLate then
        self.alpha = 0.5
    end
end

function HitObject:changeHoldScale(multiplier) -- fuck dude.,,.,, my couch
    if self.isSustainNote then
        self.scale.y = ((stepCrochet/100) * (1.0525)) * (speed * multiplier)
        self.correctionOffset = downscroll and 0 and 35 * multiplier
        self:updateHitbox()
    end
end

function HitObject:clipToStrum(strum)
    local center = strum.y + (self.width * 0.925)/1.75
    local vert = center - self.y - self.correctionOffset
    if self.isSustainNote and ((self.wasGoodHit or (self.prevNote.wasGoodHit and not self.canBeHit))) then
        local rect = self.clipRect
        if not rect then
            rect = {x = 0, y = 0, width = (self.frameWidth), height = (self.frameHeight)}
        end

        if downscroll and self.y - self.offset.y * self.scale.y + self.height >= center then
            rect.width = self:getFrameWidth() * self.scale.x
            rect.height = (center - self.y) / self.scale.y * 1.3
            rect.y = self:getFrameHeight() - rect.height
        elseif not downscroll and self.y + self.offset.y <= center then
            rect.y = vert
            rect.width = self:getFrameWidth() * self.scale.x
            rect.height = self:getFrameHeight() * self.scale.y
        else
            rect.y = 0
            rect.width = self:getFrameWidth() * self.scale.x
            rect.height = self:getFrameHeight() * self.scale.y * 1.3
        end

        self.clipRect = rect
    end
end

function HitObject:draw()
    if self.y < 1080 and self.y > -(self.height * self.scale.y) then
        self.super.draw(self)
    end
end

return HitObject