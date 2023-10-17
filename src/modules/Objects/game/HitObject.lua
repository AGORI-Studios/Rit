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

local HitTypes = {
    "left",
    "down",
    "up",
    "right"
}

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

    self:load(skin:format(SkinJSON[HitTypes[data] .. " note"]))
    self:setGraphicSize(math.floor(self.width * 0.925))

    self.x = self.x + (self.width * 0.925+4) * (data-1)

    if self.prevNote then
        self.prevNote.nextNote = self
    end

    if self.isSustainNote and self.prevNote then
        self.offsetX = self.offsetX + (self.width * 0.925)/2

        self:load(skin:format(SkinJSON[HitTypes[data] .. " note hold end"]))
        self:updateHitbox()
        self.offsetX = self.offsetX - (self.width)/2
        self.flipY = true
        self.offsetY = 2

        if self.prevNote.isSustainNote then
            self.prevNote.flipY = false
            self.prevNote:load(skin:format(SkinJSON[HitTypes[data] .. " note hold"]))
            self.prevNote.scale.y = ((stepCrochet/100) * (0.475)) * speed
            self.offsetY = 0
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

function HitObject:followStrum(strum, fakeCrocet)
    local strumX, strumY = strum.x, strum.y
    local strumAngle = strum.angle
    local strumAlpha = strum.alpha
    local strumDirection = strum.direction

    self.distance = (0.45 * (musicTime - self.time) * speed)
    
    local angleDir = strumDirection * math.pi/180

    if copyAngle then
        self.angle = math.rad(strumAngle - 90 + strumAngle + self.offsetAngle)
    end

    if copyAlpha then
        self.alpha = strumAlpha * self.multAlpha
    end

    if copyX then
        self.x = strumX + math.cos(angleDir) * self.distance
    end

    self.y = strumY + self.offsetY + self.correctionOffset + math.sin(angleDir) * -self.distance
end

function HitObject:clipToStrum(strum)
    local center = strum.y + (self.width * 0.925)/1.75
    local vert = center - self.y
    if self.isSustainNote and ((self.wasGoodHit or (self.prevNote.wasGoodHit and not self.canBeHit))) then
        local rect = self.clipRect
        if not rect then
            rect = {x = 0, y = 0, width = (self.frameWidth), height = (self.frameHeight)}
        end

        if self.y + self.offset.y <= center then
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

return HitObject