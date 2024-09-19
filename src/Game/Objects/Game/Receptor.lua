local Receptor = Sprite:extend("Receptor")

function Receptor:new(lane, count)
    self.cache = {}
    self.cache["unpressed"] = Skin._noteAssets[count][lane]["Unpressed"]
    self.cache["pressed"] = Skin._noteAssets[count][lane]["Pressed"]

    Sprite.new(self, Skin._noteAssets[count][lane]["Unpressed"], 0, 0, false)

    self.Lane = lane
    self.down = false

    self:centerOrigin()
end

function Receptor:update(dt)
    Sprite.update(self, dt)

    if self.down then
        self.image = self.cache["pressed"]
    else
        self.image = self.cache["unpressed"]
    end
end

return Receptor