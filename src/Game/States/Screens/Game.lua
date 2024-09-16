local Gameplay = State:extend()

function Gameplay:new()
    State.new(self)
    Gameplay.instance = self

    self.hitObjectManager = HitObjectManager(self)
    self:add(self.hitObjectManager)

    Parsers["Quaver"]:parse("Assets/IncludedSongs/lapix feat. mami - Irradiate (Nightcore Ver.) - 841472/147043.qua")
end

return Gameplay