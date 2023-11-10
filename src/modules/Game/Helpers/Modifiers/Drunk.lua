local Drunk = Modscript.BaseModifier:extend()
Drunk.amount = 0

function Drunk:enable(amount)
    self.super.enable(self, amount)
    self.amount = amount
end

function Drunk:disable()
    self.super.disable(self)
end

function Drunk:update(dt)
    if not self.enabled then return end
end

return Drunk