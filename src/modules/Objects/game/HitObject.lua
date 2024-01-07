local HitObject = Sprite:extend()

HitObject.time = 0
HitObject.data = 1
HitObject.canBeHit = false
HitObject.tooLate = false
HitObject.wasGoodHit = false
HitObject.noteWasHit = false

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

HitObject.children = {}
HitObject.moveWithScroll = true

function HitObject:new(time, data, endTime, sustainNote) 
    self.super.new(self)
    local sustainNote = sustainNote or false

    self.isSustainNote = sustainNote
    self.moves = false

    self.x = self.x + states.game.Gameplay.strumX + 25
    self.y = -2000

    self.time = time
    self.endTime = endTime
    self.data = data

    self.children = {}
    self.moveWithScroll = true

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

    if self.endTime and self.endTime > self.time then
        local holdObj = Sprite():load(skin:format(skinData["NoteAssets"][tostring(states.game.Gameplay.mode) .. "k_" .. data .. "_hold"]))
        holdObj.endTime = self.endTime

        table.insert(self.children, holdObj)

        local endObj = Sprite():load(skin:format(skinData["NoteAssets"][tostring(states.game.Gameplay.mode) .. "k_" .. data .. "_hold_end"]))
        holdObj.endTime = self.endTime
        if not Settings.options["General"].downscroll then
            endObj.scale.y = -1
        end

        table.insert(self.children, endObj)
    end

    self.x = self.x + self.offsetX

    if #self.children > 0 then
        self.children[1].x = self.x + self.children[1].width/4.5 - ((self.data - 1) * (self.width))
        self.children[2].x = self.x + self.children[1].width/4.5 - ((self.data - 1) * (self.width))
    end

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

function HitObject:draw()
    if self.y < 1080 and self.y > -(self.height * self.scale.y) then
        for i, child in ipairs(self.children) do
            child:draw()
        end
        self.super.draw(self)
    end
end

return HitObject