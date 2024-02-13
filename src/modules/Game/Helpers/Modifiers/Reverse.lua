local Reverse = Modscript.BaseModifier:extend()
Reverse.name = "Reverse"
Reverse.enabled = false
-- no amount, just true/false

function Reverse:enable()
    self.super.enable(self)
    -- Simply just flips the playfield
    self.enabled = true
end

function Reverse:disable()
    self.super.disable(self)
    self.enabled = false
end

-- no need to update

return Reverse