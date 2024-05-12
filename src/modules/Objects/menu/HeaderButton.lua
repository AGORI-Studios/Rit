local HeaderButton = Sprite:extend()

function HeaderButton:new(x, y, img)
    self.super.new(self, x, y, img)
    self:setScale(1.25)
    return self
end

return HeaderButton