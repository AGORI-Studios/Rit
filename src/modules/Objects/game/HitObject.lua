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

    self.x = self.x + states.game.Gameplay.strumX + 25
    self.y = -2000

    self.time = time
    self.endTime = endTime
    self.data = data

    self.children = {}
    self.moveWithScroll = true

    self:load(skin:format("notes/" .. tostring(states.game.Gameplay.mode) .. "K/note" .. data .. ".png"))

    self:setGraphicSize(math.floor(self.width * 0.925))
    _G.__NOTE_OBJECT_WIDTH = self.width

    self.x = self.x + (self.width * 0.925+4) * (data-1)

    if self.endTime and self.endTime > self.time then
        local holdObj = Sprite():load(skin:format("notes/" .. tostring(states.game.Gameplay.mode) .. "K/note" .. data .. "-hold.png"))
        holdObj.endTime = self.endTime

        table.insert(self.children, holdObj)

        local endObj = Sprite():load(skin:format("notes/" .. tostring(states.game.Gameplay.mode) .. "K/note" .. data .. "-end.png"))
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

local function findBezierPosition(bezier, lane, position)
    if position > 1 then position = 1 end
    if position < 0 then position = 0 end
    return bezier:evaluate(position)
end

function HitObject:draw(bezier)
    if self.y < 1080 and self.y > -(self.height * self.scale.y) then
        -- use y position for finding the position on the bezier curve
        local x, y = findBezierPosition(bezier, self.data, (self.y + self.height * self.scale.y) / 1080)
        -- if downscroll, go backwards through the bezier curve
        y = Settings.options["General"].downscroll and 1080 - y or y
        for i, child in ipairs(self.children) do
            child:draw(x, y)
        end
        self.super.draw(self, x, y)
    end
end

return HitObject