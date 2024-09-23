---@class HoldObject : VertexSprite
local HoldObject = VertexSprite:extend("HoldObject")

function HoldObject:new(endTime, lane, count, parent)
    VertexSprite.new(self, Skin._noteAssets[count][lane]["Hold"], 0, 0, 16)
    self.parent = parent
    self.child = EndObject(endTime, lane, count, self)
    self:centerOrigin()
    self.forcedDimensions = true
    self.dimensions = {self.image:getWidth(), self.image:getHeight()}

    self.endTime = endTime
    self.lane = lane
    self.length = 0
    self.currentY = self.y
end

function HoldObject:update(dt, endY)
    local parentY = self.parent.y
    local length = endY - parentY
    self.dimensions[2] = length - self.child.baseHeight
    self.origin.y = 0

    self.child.x = self.x
    self.child.y = self.y + self.dimensions[2]
    if Skin.flipHoldEnd then
        self.child.scale.y = -1
    end

    self.child:update(dt)
    VertexSprite.update(self, dt)
end

function HoldObject:hit(time)
    print("TODO: Finish HoldObject:hit()")
end

function HoldObject:draw()
    VertexSprite.draw(self)
    self.child:draw()
end

return HoldObject