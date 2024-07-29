local Modscript = {}

Modscript.funcs = require "modules.Game.Modding.ModscriptFunctions"
Modscript.timedFunctions = {}
Modscript.shaders = {}
Modscript.currentShader = ""

Modscript.downscroll = Settings.options["General"].downscroll

require("modules.Ease")
require("modules.Game.Modding.Modifiers")

currentPlayfield = 1

__defaultPositions = {{
    {x = 0, y = 0},
    {x = 0, y = 0},
    {x = 0, y = 0},
    {x = 0, y = 0}
}}

local activeMods = {{}}
local register = {}
local modArray = {}

function __quickRegister(mod)
    __registerMod(mod.name, mod)
end

function __registerMod(modName, mod, registerSubmods)
    local registerSubmods = (registerSubmods == nil and true) or false
    
    register[modName] = mod
    table.insert(modArray, mod)

    if registerSubmods then
        for _, name in ipairs(mod.submods) do
            local submod = mod.submods[name]
            __quickRegister(submod)
        end
    end
end

function Modscript:reset()
    self.downscroll = Settings.options["General"].downscroll
    for i = 1, #states.game.Gameplay.strumLineObjects.members do
        states.game.Gameplay.strumLineObjects.members[i].y = 50
    end

    states.game.Gameplay.ableToModscript = false

    function SetValue(name, val, playfield)
        local playfield = playfield or -1

        if playfield == -1 then
            for i = 1, states.game.Gameplay.playfields do
                SetValue(name, val, i)
            end
        else
            local mod = register[name]
            local mod = mod.parent or mod

            local name = mod.name

            if not activeMods[playfield] then activeMods[playfield] = {} end
            register[name]:setValue(val, playfield)

            if table.find(activeMods[playfield], name) then
                if mod.name ~= name then
                    table.insert(activeMods[playfield], mod.name)
                end
                table.insert(activeMods[playfield], name)
            end
        end
    end
end

function Modscript:load(script)
    self.downscroll = Settings.options["General"].downscroll
    for i = 1, #states.game.Gameplay.strumLineObjects.members do
        states.game.Gameplay.strumLineObjects.members[i].y = 50
    end

    local mods = {
        ConfusionModifier,
        DrunkModifier,
        ReverseModifier,
        BeatModifier
    }

    for _, mod in ipairs(mods) do
        __quickRegister(mod)
    end

    return false
end

function Modscript:updateObject(beat, obj, pos, playfield)
    for _, name in ipairs(activeMods[playfield]) do
        local mod = register[name]
        if not mod then break end

        if obj:isInstanceOf(HitObject) then
            mod:updateNote(beat, obj, pos, playfield)
        end
    end
end

function Modscript:getPos(time, diff, tDiff, beat, data, playfield, obj, exclusions, pos)
    local exclusions = exclusions or {}
    local pos = pos or Point()

    pos.x = __defaultPositions[playfield][data].x
    pos.y = strumY + diff
    pos.z = 0

    for _, name in ipairs(activeMods[playfield]) do
        if exclusions[name] then goto continue end
        local mod = register[name]
        if not mod then goto continue end
        pos = mod:getPos(time, diff*0.15, tDiff, beat, pos, data, playfield, obj)
        ::continue::
    end

    return pos
end

function Modscript:call(func, args)
    Try(
        function()
            if _G[func] then
                return _G[func](unpack(args or {}) or {})
            end
        end,
        function(e)
            print("FAILED TO CALL " .. func .. " | " .. e)
        end
    )
end

function Modscript:endSong()
    self.downscroll = Settings.options["General"].downscroll
end

return Modscript
