-- Hey! I see you investigating this file...
-- This file isn't exactly usedd *yet*, but it will be used in the future.

local modifiers = {}

modifiers.modList = {
    -- Notig mods
    "drunk",
    "tipsy"
}
modifiers.enabledList = {}
modifiers.curEnabled = {}

function modifiers:load()
    for i, v in pairs(modifiers.modList) do
        modifiers[v] = require("modules.modifiers." .. v)
        print("Loaded mod " .. v)
    end
end

function modifiers:applyMod(mod, beat, amount)
    if modifiers[mod] then
        table.insert(self.enabledList, {mod = mod, beat = beat, amount = amount})
        debug.print("Applied mod " .. mod .. " at beat " .. beat .. " with amount " .. amount)
    end
end

function modifiers:update(dt, curBeat)
    --print(curBeat)
    for i, v in pairs(modifiers.enabledList) do
        -- if current beat is the same as the beat the mod was applied
        if v.beat == curBeat then
            -- apply the mod
            modifiers[v.mod]:apply(v.amount)
            -- remove the mod from the list
            table.remove(modifiers.enabledList, i)
        end
    end

    for i, v in pairs(modifiers.curEnabled) do
        -- update the mod
        modifiers[v[1]]:update(dt, curBeat, v[2])
    end
end

function modifiers:removeMod(mod, beat)
    for i, v in pairs(modifiers.enabledList) do
        if v.mod == mod and v.beat == beat then
            table.remove(modifiers.enabledList, i)
        end
    end
end

function modifiers:clear()
    modifiers.enabledList = {}
    modifiers.curEnabled = {}
end

return modifiers