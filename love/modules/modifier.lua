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
modifiers.shaders = {}
modifiers.curShader = ""

function modifiers:load()
    for i, v in pairs(modifiers.modList) do
        modifiers[v] = require("modules.modifiers." .. v)
    end
    
    -- Reset the modifiers
    modifiers:applyMod("drunk", 0, 0)
    modifiers:applyMod("tipsy", 0, 0)
    modifiers:applyMod("reverse", 0, 1) 
end

function modifiers:applyMod(mod, beat, amount)
    if modifiers[mod] then
        table.insert(self.enabledList, {mod = mod, beat = beat, amount = amount})
       -- debug.print("Applied mod " .. mod .. " at beat " .. beat .. " with amount " .. amount)
    end
end

function modifiers:createSprite(name, img)
    local spr = {}
    tryExcept(
        function()
            spr.img = graphics.newImage(folderPath .. "/" .. img)
        end,
        function(err)
            debug.print("Error loading sprite " .. name)
        end
    )

    --debug.print("Created sprite " .. name .. " with image " .. img)

    if spr.img then
        modifiers.graphics[name] = spr
    end
end

function modifiers:changeSpriteProperty(name, prop, value)
    tryExcept(
        function()
            modifiers.graphics[name].img[prop] = value
        end,
        function(err)
            debug.print("Error changing property " .. prop .. " of sprite " .. name)
            return 0
        end
    )
end

function modifiers:getSpriteProperty(name, prop)
    return modifiers.graphics[name].img[prop]
end

function modifiers:newShader(name, file)
   tryExcept(
        function()
            modifiers.shaders[name] = love.graphics.newShader(folderPath .. "/" .. file)
        end,
        function(err)
            debug.print("Error loading shader " .. name)
            debug.print(err)
        end
    )
end

function modifiers:changeShaderProperty(name, prop, value)
    tryExcept(
        function()
            modifiers.shaders[name]:send(prop, value)
        end,
        function(err)
            debug.print("Error changing property " .. prop .. " of shader " .. name)
            debug.print(err)
        end
    )
end

function modifiers:applyShader(name)
    modifiers.curShader = name
end

-- Globals
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

function changeSpriteProperty(name, prop, value)
    modifiers:changeSpriteProperty(name, prop, value)
    --debug.print("Changed property " .. prop .. " of sprite " .. name .. " to " .. value)
end

function getSpriteProperty(name, prop)
    return modifiers:getSpriteProperty(name, prop)
end

function newShader(name, file)
    modifiers:newShader(name, file)
end

function changeShaderProperty(name, prop, value)
    modifiers:changeShaderProperty(name, prop, value)
end

function applyShader(name)
    -- check if shader is in modifers.shaders
    if modifiers.shaders[name] then
        modifiers:applyShader(name)
    else
        debug.print("Shader " .. name .. " does not exist")
    end
end
-- End globals

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
    modifiers.graphics = {}
    modifiers.shaders = {}
    modifiers.curShader = ""

    for i, v in pairs(modifiers.modList) do
        modifiers[v] = nil
    end

    create = nil
    update = nil
    key_pressed = nil
    update = nil
    hit = nil
end

return modifiers