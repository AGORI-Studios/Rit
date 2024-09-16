local Receptor = Sprite:extend("Receptor")

function Receptor:new(lane)
    local path = "Assets/IncludedSkins/SkinThrowbacks/notes/4K/receptor" .. lane .. "-unpressed.png"

    Sprite.new(self, path, 0, 0)

    self.Lane = lane

    self:centerOrigin()
end

function Receptor:update(dt)
    Sprite.update(self, dt)
end

return Receptor