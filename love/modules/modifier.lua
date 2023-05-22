-- Hey! I see you investigating this file...
-- This file isn't exactly usedd *yet*, but it will be used in the future.

local modifiers = {}

modifiers.modList = {
    -- Notig mods
    "drunk",
    "tipsy",
    "reverse",
}
modifiers.mods = {}
modifiers.enabledList = {}
modifiers.curEnabled = {}
modifiers.reverseScale = 1 -- 1 means not flipped, -1 means flipped
modifiers.tweens = {}
modifiers.funcs = {}
modifiers.funcsSimulated = {}
modifiers.graphics = {}
modifiers.draws = {}
modifiers.shaders = {}
modifiers.curShader = ""
modifiers.defaultX = {}
modifiers.defaultY = {}
modifiers.notePos = {}
for i = 1, 4 do
    modifiers.notePos[i] = 0
end
for i = 1, 4 do
    modifiers.defaultX[i] = 90 -(settings.settings.Game["note spacing"]*(#receptors/2-1)) + (settings.settings.Game["note spacing"] * (i-1))
end
for i = 1, 4 do
    modifiers.defaultY[i] = -35
end
modifiers.camera = {x=0,y=0,zoom=1}
modifiers.gameProperties = {["receptorsVisible"]=true,["healthbarVisible"]=true,["scoreVisible"]=true,["timebarVisible"]=true}
modifiers.musicPlaying = true

function getReverseForCol(l)
    local val = 0

    val = val + modifiers.reverseScale

    return val
end

function modifiers:load()
    for i, v in pairs(modifiers.modList) do
        modifiers.mods[v] = require("modules.modifiers." .. v)
        print("Loaded modifier " .. v)
    end
end

function modifiers:applyMod(mod, beat, amount, lane)
    local lane = lane or 0
    table.insert(self.enabledList, {mod = mod, beat = beat, amount = amount, lane = lane})
    -- debug.print("Applied mod " .. mod .. " at beat " .. beat .. " with amount " .. amount)
end

function modifiers:createSprite(name, img)
    local spr = {}
    tryExcept(
        function()
            spr.img = graphics.newImage(folderPath .. "/mod/" .. img)
        end,
        function(err)
            debug.print("error", "Error loading sprite " .. name)
        end
    )

    --debug.print("Created sprite " .. name .. " with image " .. img)

    if spr.img then
        modifiers.graphics[name] = spr
        modifiers.draws[#modifiers.draws + 1] = name

        modifiers.graphics[name].draw = function(self)
            modifiers.graphics[name].img:draw()
        end
        modifiers.graphics[name].update = function(self, dt)
            modifiers.graphics[name].img:update(dt)
        end
    end
end

function modifiers:changeSpriteProperty(name, prop, value)
    tryExcept(
        function()
            modifiers.graphics[name].img[prop] = value
        end,
        function(err)
            debug.print("error", "Error changing property " .. prop .. " of sprite " .. name)
            return 0
        end
    )
end

function modifiers:animateSprite(name, anim)
    modifiers.graphics[name].img:animate(anim)
end

function modifiers:getSpriteProperty(name, prop)
    return modifiers.graphics[name].img[prop]
end

function modifiers:newShader(name, file)
   tryExcept(
        function()
            modifiers.shaders[name] = love.graphics.newShader(folderPath .. "/mod/" .. file)
        end,
        function(err)
            debug.print("error","Error loading shader " .. name)
            debug.print("error",err)
        end
    )
end

function modifiers:changeShaderProperty(name, prop, value)
    tryExcept(
        function()
            modifiers.shaders[name]:send(prop, value)
        end,
        function(err)
            debug.print("error","Error changing property " .. prop .. " of shader " .. name)
            debug.print("error",err)
        end
    )
end

function modifiers:applyShader(name)
    modifiers.curShader = name
end

function modifiers:applySparrow(name, sparrow)
    modifiers.graphics[name].img:setSparrowSheet(sparrow)
end

function modifiers:addAnim(name, animName, prefix, framerate, loop)
    modifiers.graphics[name].img:addAnim(animName, prefix, framerate, loop)
end 

function modifiers:addAnimOffset(name, animName, ox, oy)
    modifiers.graphics[name].img:addAnimOffset(animName, ox, oy)
end

function modifiers:changeAnimSpeed(name, speed)
    modifiers.graphics[name].img:changeAnimSpeed(speed)
end

function modifiers:setCameraZoom(zoom)
    modifiers.camera.zoom = zoom
end

function modifiers:setCameraPos(x, y)
    modifiers.camera.x = x
    modifiers.camera.y = y
end

function modifiers:changeGameProperty(prop, value)
    modifiers.gameProperties[prop] = value
end

function modifiers:setMusicPlaying(value)
    modifiers.musicPlaying = value
end

function modifiers:createRect(name, x, y, w, h, color)
    modifiers.graphics[name] = graphics.newRect(x, y, w, h, color)
    modifiers.draws[#modifiers.draws + 1] = name
end

function modifiers:changeRectProperty(name, prop, value)
    modifiers.graphics[name][prop] = value
end

function modifiers:newCircle(name, x, y, radius, color)
    modifiers.graphics[name] = graphics.newCircle(x, y, radius, color)
    modifiers.draws[#modifiers.draws + 1] = name
end

function modifiers:changeCircleProperty(name, prop, value)
    modifiers.graphics[name][prop] = value
end

-- Globals
function doMod(func, beat)
    table.insert(modifiers.funcs, {func = func, beat = beat})
end

function doModSimulated(func, beat)
    table.insert(modifiers.funcsSimulated, {func = func, beat = beat})
end

function applyMod(mod, beat, amount, lane)
    modifiers:applyMod(mod, beat, amount, lane)
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

function animateSprite(name, anim)
    modifiers:animateSprite(name, anim)
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
        debug.print("error", "Shader " .. name .. " does not exist")
    end
end

function applySparrow(name, sparrow)
    modifiers:applySparrow(name, sparrow)
end

function addAnim(name, animName, prefix, framerate, loop)
    modifiers:addAnim(name, animName, prefix, framerate, loop)
end

function addAnimOffset(name, animName, ox, oy)
    modifiers:addAnimOffset(name, animName, ox, oy)
end

function changeAnimSpeed(name, speed)
    modifiers:changeAnimSpeed(name, speed)
end

function setCameraZoom(zoom)
    modifiers:setCameraZoom(zoom)
end

function setCameraPos(x, y)
    modifiers:setCameraPos(x, y)
end

function changeGameProperty(prop, value)
    modifiers:changeGameProperty(prop, value)
end

function setMusicPlaying(value)
    modifiers:setMusicPlaying(value)
    previousFrameTime = love.timer.getTime() * 1000
end

function createRect(name, x, y, w, h, color)
    modifiers:createRect(name, x, y, w, h, color)
end

function changeRectProperty(name, prop, value)
    modifiers:changeRectProperty(name, prop, value)
end

function newCircle(name, x, y, radius, color)
    modifiers:newCircle(name, x, y, radius, color)
end

function changeCircleProperty(name, prop, value)
    modifiers:changeCircleProperty(name, prop, value)
end

function setLaneScrollspeed(lane, speed)
    if lane == 0 then
        for i = 1, 4 do
            speedLane[i] = speed
        end
    else
        speedLane[lane] = speed
    end
end

-- End globals

function modifiers:update(dt, curBeat)
    local curBeatSimulated = math.floor((simulatedMusicTime / 1000) * (beatHandler.bpm / 60))
    --print(curBeat)
    for i, v in pairs(modifiers.enabledList) do
        -- if current beat is the same as the beat the mod was applied
        if v.beat <= curBeat and audioFile:isPlaying() then
            -- apply the mod
            modifiers.mods[v.mod]:apply(v.amount, v.lane)
            -- remove the mod from the list
            --debug.print("Applied mod " .. v.mod .. " at beat " .. v.beat .. " with amount " .. v.amount)
            
            table.remove(modifiers.enabledList, i)
        end
    end

    for i, v in pairs(modifiers.curEnabled) do
        -- update the mod
        modifiers.mods[v[1]]:update(dt, curBeat, v[2])
    end

    for i, v in pairs(modifiers.funcs) do
        if v.beat <= curBeat and audioFile:isPlaying() then
            v.func()
            table.remove(modifiers.funcs, i)
        end
    end

    for i, v in pairs(modifiers.funcsSimulated) do
        if v.beat <= curBeatSimulated then
            v.func()
            table.remove(modifiers.funcsSimulated, i)
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
    modifiers.funcsSimulated = {}
    modifiers.graphics = {}
    modifiers.shaders = {}
    modifiers.curShader = ""
    modscript.file = false
    modifiers.camera = {x = 0, y = 0, zoom = 1}
    notesize = 1
    modifiers.draws = {}
    modifiers.gameProperties = {["receptorsVisible"]=true,["healthbarVisible"]=true,["scoreVisible"]=true,["timebarVisible"]=true}
    modifiers.musicPlaying = true

    for _, v in pairs(modifiers.modList) do
        modifiers[v] = nil
    end

    create = nil
    update = nil
    key_pressed = nil
    update = nil
    hit = nil
end

return modifiers