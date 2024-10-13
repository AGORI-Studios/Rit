local Receptor = Sprite:extend("Receptor")

function Receptor:new(lane, count)
    self.cache = {}
    if not Skin._noteAssets[count] then
        Skin._noteAssets[count] = Skin._noteAssets[1]
    end
    if not Skin._noteAssets[count][lane] then
        Skin._noteAssets[count][lane] = Skin._noteAssets[count][1]
    end
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
