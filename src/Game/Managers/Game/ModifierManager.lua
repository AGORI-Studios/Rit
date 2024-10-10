local ModifierManager = Class:extend("ModifierManager")

ModifierManager.Modifiers = {
    -- {Name, Description, ScoreMultAddition}
    {
        "No LN", "Disables Long Notes", -0.25, -- applies if the map has long notes
    },
    {
        "No SV", "Disables Scroll Velocity", -0.25, -- applies if the map has a scroll velocity
    },
    {
        "Fade Out", "Notes fade out as they approach the receptors", 0.1,
    },
    {
        "Fade In", "Notes fade in as they approach the receptors", 0.1,
    },
    {
        "Mirror", "Notes are mirrored (Left -> Right, Up -> Down)", 0,
    }
}

ModifierManager.ActiveModifiers = {
}

function ModifierManager:getModifier(name)
    for _, mod in ipairs(self.Modifiers) do
        if mod[1] == name then
            return mod
        end
    end
end

function ModifierManager:getScoreMultiplier()
    local curMult = 1

    if States.Screens.Game.LongNotes and table.contains(self.ActiveModifiers, "No LN") then
        curMult = curMult + self:getModifier("No LN")[3]
    end

    if States.Screens.Game.ScrollVelocity and table.contains(self.ActiveModifiers, "No SV") then
        curMult = curMult + self:getModifier("No SV")[3]
    end

    for _, mod in ipairs(self.ActiveModifiers) do
        curMult = curMult + self:getModifier(mod)[3]
    end

    return curMult
end

return ModifierManager
