---@class HitObject : Sprite
local HitObject = Sprite:extend("HitObject")

function HitObject:new(data, count)
    Sprite.new(self, Skin._noteAssets[count][data.Lane]["Note"], 0, 0, false)

    self:centerOrigin()

    self.Data = data
    if data.EndTime ~= 0 and data.EndTime > data.StartTime then
        self.holdSprite = HoldObject(data.EndTime, data.Lane, count, self)
    end
    self.endY = data.EndTime
    self.moveWithScroll = true
end

function HitObject:update(dt) 
    Sprite.update(self, dt)

    if self.holdSprite then
        self.holdSprite.x = self.x
        self.holdSprite.y = self.y + self.baseHeight/2

        self.holdSprite:update(dt, self.endY)
    end
end

function HitObject:hit(time)
    States.Screens.Game.instance.judgement:hit(time)
end

function HitObject:resize(w, h)
    Sprite.resize(self, w, h)

    if self.holdSprite then
        self.holdSprite:resize(w, h)
    end
end

function HitObject:draw()
    if self.holdSprite then
        self.holdSprite:draw()
    end
    Sprite.draw(self)
end

return HitObject
