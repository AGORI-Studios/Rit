local Game = State:extend("Game")

function Game:new()
    State.new(self)
    Game.instance = self

    self.hitObjectManager = HitObjectManager(self)
    self:add(self.hitObjectManager)

    Parsers["Quaver"]:parse("Assets/IncludedSongs/lapix feat. mami - Irradiate (Nightcore Ver.) - 841472/147043.qua",
        "Assets/IncludedSongs/lapix feat. mami - Irradiate (Nightcore Ver.) - 841472/")

    for i = #self.hitObjectManager.hitObjects, 2, -1 do
        if self.hitObjectManager.hitObjects[i].StartTime == self.hitObjectManager.hitObjects[i - 1].StartTime then
            table.remove(self.hitObjectManager.hitObjects, i)
        end
    end
    table.sort(self.hitObjectManager.hitObjects, function(a, b) return a.StartTime < b.StartTime end)
    self.hitObjectManager.scorePerNote = 1000000 / #self.hitObjectManager.hitObjects

    self.song:play()

    self.HUD = HUD(self)
    self:add(self.HUD)

    self.score = 0
    self.accuracy = 0
end

return Game