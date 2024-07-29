local Reverse = BaseModifier:extend()
Reverse.name = "Reverse"
Reverse.percents = {0} -- add more with each playfield
Reverse.submods = {}
Reverse.parent = nil
Reverse.active = false

local function scale(x, l1, h1, l2, h2)
    return ((x - l1) * (h2 - l2) / (h1 - l1) + l2)
end

function Reverse:getReverseValue(dir, playfield, scrolling)
    local suffix = ""
    if scrolling then suffix = "Scroll" end
    local receptors = states.game.Gameplay.strumLineObjects.members
    local kNum = states.game.Gameplay.mode
    local val = 0

    if dir >= kNum/2 then
        val = val + self:getSubmodValue("split" .. suffix, playfield)
    end

    if dir % 2 == 1 then
        val = val + self:getSubmodValue("alternate" .. suffix, playfield)
    end

    if suffix == "" then
        val = val + self:getValue(playfield) + self:getSubmodValue("reverse" .. dir, playfield)
    end
    
    return val
end

function Reverse:getPos(time, visualDiff, timeDiff, beat, pos, data, playfield, obj)
    local perc = self:getReverseValue(data, playfield)
    local shift = scale(perc, 0, 1, 50, 1080 - 250)
    local mult = scale(perc, 0, 1, 1, -1)
    shift = scale(self:getSubmodValue("centered", playfield), 0, 1, shift, (1080/2) - 56)

    pos.y = shift + (visualDiff * mult)

    return pos
end

function Reverse:getSubmods()
    local subMods = {"cross", "split", "alternate", "reverseScroll", "crossScroll", "splitScroll", "alternateScroll", "centered", "unboundedReverse"}

    for i = 1, states.game.Gameplay.mode do
        table.insert(subMods, "reverse" .. i)
    end

    return subMods
end

return Reverse