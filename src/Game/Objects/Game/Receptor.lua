local Receptor = Sprite:extend("Receptor")

function Receptor:new(lane)
    local unpressedPath = "Assets/IncludedSkins/SkinThrowbacks/notes/4K/receptor" .. lane .. "-unpressed.png"
    local pressedPath = "Assets/IncludedSkins/SkinThrowbacks/notes/4K/receptor" .. lane .. "-pressed.png"
    self.cache = {}
    self.cache["unpressed"] = Cache:get("Image", unpressedPath)
    self.cache["pressed"] = Cache:get("Image", pressedPath)

    Sprite.new(self, unpressedPath, 0, 0)

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