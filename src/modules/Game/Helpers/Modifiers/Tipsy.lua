local Tipsy = Modscript.BaseModifier:extend()
Tipsy.amount = 0
Tipsy.name = "Tipsy"

function Tipsy:enable(amount)
    self.super.enable(self, amount)
    self.amount = amount
end

function Tipsy:disable()
    self.super.disable(self)
end

function Tipsy:update(dt, beat, playfield)
    if not self.enabled then return end

    for i = 1, states.game.Gameplay.mode do
        local ypos = self.amount * (math.cos(musicTime*0.001+i*(1.2)+1*(1.2))*__NOTE_OBJECT_WIDTH*0.5)

        states.game.Gameplay.playfields[playfield].lanes[i].y = ypos
    end
end

return Tipsy