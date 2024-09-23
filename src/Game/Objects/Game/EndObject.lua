---@class EndObject : Sprite
local EndObject = Sprite:extend("EndObject")

function EndObject:new(endTime, lane, count, parent)
    Sprite.new(self, Skin._noteAssets[count][lane]["End"], 0, 0, false)
    self.parent = parent
    self:centerOrigin()

    self.endTime = endTime
end

function EndObject:update(dt) 
    Sprite.update(self, dt)
end

function EndObject:hit(time)
    print("TODO: Finish EndObject:hit()")
end

return EndObject