local Confusion = BaseModifier:extend()
Confusion.name = "Confusion"
Confusion.percents = {0} -- add more with each playfield
Confusion.submods = {}
Confusion.parent = nil
Confusion.active = false

function Confusion:updateNote(beat, note, pos, playfield)
    note.angle = self:getValue(playfield) + self:getSubmodValue("confusion" .. note.data, playfield) + 
        self:getSubmodValue("note" .. note.data .. "Angle")
end

function Confusion:updateReceptor(beat, receptor, pos, playfield)
    receptor.angle = self:getValue(playfield) + self:getSubmodValue("confusion" .. receptor.data, playfield) + 
    self:getSubmodValue("receptor" .. receptor.data .. "Angle")
end

function Confusion:getSubmods()
    local subMods = {"noteAngle", "receptorAngle"}

    for i = 1, states.game.Gameplay.mode do
        table.insert(subMods, "note" .. i .. "Angle")
        table.insert(subMods, "receptor" .. i .. "Angle")
        table.insert(subMods, "confusion" .. i)
    end

    return subMods
end

return Confusion