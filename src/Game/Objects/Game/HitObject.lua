---@class HitObject : Sprite
local HitObject = Sprite:extend("HitObject")

function HitObject:new(data)
    local path = "Assets/IncludedSkins/SkinThrowbacks/notes/4K/note" .. data.Lane .. ".png"

    Sprite.new(self, path, 0, 0)

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