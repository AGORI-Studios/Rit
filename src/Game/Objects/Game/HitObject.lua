---@class HitObject : Sprite
local HitObject = Sprite:extend("HitObject")

function HitObject:new(startTime, endTime, lane)

end

function HitObject:update(dt)
    Sprite.update(self, dt)
end

return HitObject