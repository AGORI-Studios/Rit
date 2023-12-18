local Drunk = Modscript.BaseModifier:extend()
Drunk.amount = 0
Drunk.name = "Drunk"

function Drunk:enable(amount)
    self.super.enable(self, amount)
    self.amount = amount
end

function Drunk:disable()
    self.super.disable(self)
end

function Drunk:update(dt, beat, playfield)
    if not self.enabled then return end

    for i = 1, states.game.Gameplay.mode do
        local xpos = self.amount * (math.cos(musicTime*0.001+i*(0.2)+1*(0.2))*__NOTE_OBJECT_WIDTH*0.5)

        states.game.Gameplay.playfields[playfield].lanes[i].x = xpos
    end
end

return Drunk