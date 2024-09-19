---@class HitObject : Sprite
local HitObject = Sprite:extend("HitObject")

function HitObject:new(data, count)
    Sprite.new(self, Skin._noteAssets[count][data.Lane]["Note"], 0, 0, false)

    self:centerOrigin()

    self.Data = data
end

function HitObject:update(dt) 
    Sprite.update(self, dt)
end

function HitObject:hit(time)
    print("TODO: Finish HitObject:hit()")
end

return HitObject