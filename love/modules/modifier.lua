-- Hey! I see you investigating this file...
-- This file isn't exactly usedd *yet*, but it will be used in the future.

local modifiers = {}

modifiers.modList = {
    -- Notig mods
    "drunk",
    "tipsy",
    "reverse"
}
modifiers.enabledList = {}
modifiers.curEnabled = {}
modifiers.reverseScale = 1 -- 1 means not flipped, -1 means flipped
modifiers.tweens = {}
modifiers.funcs = {}
modifiers.graphics = {}

function modifiers:load()
    for i, v in pairs(modifiers.modList) do
        modifiers[v] = require("modules.modifiers." .. v)
        --print("Loaded mod " .. v)
    end

    modifiers:clear()
end

function modifiers:applyMod(mod, beat, amount)
    if modifiers[mod] then
        table.insert(self.enabledList, {mod = mod, beat = beat, amount = amount})
       -- debug.print("Applied mod " .. mod .. " at beat " .. beat .. " with amount " .. amount)
    end
end

function modifiers:createSprite(name, img)
    local spr = {}
    spr.img = graphics.newImage(folderPath .. "/" .. img)

    --debug.print("Created sprite " .. name .. " with image " .. img)

    modifiers.graphics[name] = spr
end

function modifiers:changeProperty(name, prop, value)
    modifiers.graphics[name].img[prop] = value
end

function modifiers:getProperty(name, prop)
    return modifiers.graphics[name].img[prop]
end

function doMod(func, beat)
    table.insert(modifiers.funcs, {func = func, beat = beat})
end

function applyMod(mod, beat, amount)
    modifiers:applyMod(mod, beat, amount)
end
function removeMod(mod, beat)
    modifiers:removeMod(mod, beat)
end

function createSprite(name, img)
    modifiers:createSprite(name, img)
end

function changeProperty(name, prop, value)
    modifiers:changeProperty(name, prop, value)
    --debug.print("Changed property " .. prop .. " of sprite " .. name .. " to " .. value)
end

function getProperty(name, prop)
    return modifiers:getProperty(name, prop)
end

function modifiers:update(dt, curBeat)
    --print(curBeat)
    for i, v in pairs(modifiers.enabledList) do
        -- if current beat is the same as the beat the mod was applied
        if v.beat <= curBeat and audioFile:isPlaying() then
            -- apply the mod
            modifiers[v.mod]:apply(v.amount)
            -- remove the mod from the list
            --debug.print("Applied mod " .. v.mod .. " at beat " .. v.beat .. " with amount " .. v.amount)
            table.remove(modifiers.enabledList, i)
        end
    end

    for i, v in pairs(modifiers.curEnabled) do
        -- update the mod
        modifiers[v[1]]:update(dt, curBeat, v[2])
    end

    for i, v in pairs(modifiers.funcs) do
        if v.beat <= curBeat and audioFile:isPlaying() then
            v.func()
            table.remove(modifiers.funcs, i)
        end
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
    modifiers.reverseScale = 1
    modifiers.tweens = {}
    modifiers.funcs = {}
end

return modifiers