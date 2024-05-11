local HitObject = Sprite:extend()

HitObject.time = 0
HitObject.data = 1
HitObject.canBeHit = false
HitObject.tooLate = false
HitObject.wasGoodHit = false

HitObject.tail = {}
HitObject.parent = nil

HitObject.offsetX = 0
HitObject.offsetY = 0

HitObject.children = {}
HitObject.moveWithScroll = true

function HitObject:new(time, data, endTime) 
    self.super.new(self)

    self.moves = false

    self.x = states.game.Gameplay.strumX + (200) * (data-1)
    self.x = self.x + 25
    self.y = -2000

    self.time = time
    self.endTime = endTime
    self.data = data

    self.children = {}
    self.moveWithScroll = true

    self:load(skin:format("notes/" .. tostring(states.game.Gameplay.mode) .. "K/note" .. data .. ".png"))

    self:setGraphicSize(math.floor(self.width * 0.925))
    self.forcedDimensions = true
    self.dimensions = {width = 200, height = 200}
    self:updateHitbox()
    _G.__NOTE_OBJECT_WIDTH = 200

    self.x = self.x + (200) * (data-1)

    if self.endTime and self.endTime > self.time then
        local holdObj = Sprite():load(skin:format("notes/" .. tostring(states.game.Gameplay.mode) .. "K/note" .. data .. "-hold.png"))
        holdObj.endTime = self.endTime
        holdObj:setGraphicSize(math.floor(holdObj.width * 0.925))
        holdObj:updateHitbox()
        holdObj.x = self.x + (200) / 2 - (200) / 2
        holdObj.forcedDimensions = true
        holdObj.dimensions = {width = 200, height = 200}

        table.insert(self.children, holdObj)

        local endObj = Sprite():load(skin:format("notes/" .. tostring(states.game.Gameplay.mode) .. "K/note" .. data .. "-end.png"))
        holdObj.endTime = self.endTime
        endObj:setGraphicSize(math.floor(endObj.width * 0.925))
        endObj:updateHitbox()
        endObj.x = self.x + (200) / 2 - (200) / 2
        endObj.flipY = skin.flippedEnd
        if not Settings.options["General"].downscroll then
            endObj.scale.y = -1
        end
        endObj.forcedDimensions = true
        endObj.dimensions = {width = 200, height = 200}

        table.insert(self.children, endObj)
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

function HitObject:draw()
    -- Draws our note if it's within the screen's bounds
    if self.y < 1080 and self.y > -(self.height * self.scale.y) then
        for i, child in ipairs(self.children) do
            child:draw()
        end
        self.super.draw(self)
    end
end

return HitObject