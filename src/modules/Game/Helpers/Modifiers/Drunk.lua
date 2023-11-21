local Drunk = Modscript.BaseModifier:extend()
Drunk.amount = 0

function Drunk:enable(amount)
    self.super.enable(self, amount)
    self.amount = amount
end

function Drunk:disable()
    self.super.disable(self)
end

function Drunk:update(dt, beat)
    if not self.enabled then return end

    for i = 1, 4 do
        local xpos = 0

        xpos = xpos + self.amount * (math.cos(musicTime*0.001+i*(0.2)+1*(0.2))*receptors[i][1]:getWidth()*0.5)

        receptors[i][1].offset.x = xpos
        receptors[i][2].offset.x = xpos
    end
end

return Drunk