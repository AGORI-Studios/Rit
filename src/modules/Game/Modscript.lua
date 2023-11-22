local Modscript = {}

Modscript.funcs = require "modules.Game.Helpers.ModscriptFunctions"
Modscript.BaseModifier = require "modules.Game.Helpers.Modifiers.BaseModifier" 

-- modifiers
Modscript.modifiers = {}
function Modscript:loadModifiers()
    local files = love.filesystem.getDirectoryItems("modules/Game/Helpers/Modifiers")
    for i, v in pairs(files) do
        if v ~= "BaseModifier.lua" then
            local modifier = require("modules.Game.Helpers.Modifiers." .. v:sub(1, -5))
            self.modifiers[modifier.name] = modifier
        end
    end
end

function Modscript:set(name, value)
    _G[name] = value
end

local modlist = {}
local enabledMods = {}

function Modscript:load(script)
    print("Loading modscript " .. script)
    Try(
        function()
            chunk = love.filesystem.load(script)()
        end,
        function()
            return false
        end
    )

    self:set(
        "CreateSprite",
        function(name, path, x, y)
            local NewPath = states.game.Gameplay.M_folderPath .. "/mod/" .. path
            return self.funcs:createSprite(name, NewPath, x, y)
        end
    )

    self:set(
        "SetSpriteProperty",
        function(name, property, value)
            return self.funcs:setSpriteProperty(name, property, value)
        end
    )

    self:set(
        "GetSpriteProperty",
        function(name, property)
            return self.funcs:getSpriteProperty(name, property)
        end
    )

    self:set(
        "RemoveSprite",
        function(name)
            return self.funcs:removeSprite(name)
        end
    )

    self:set(
        "Close",
        function()
            closed = true
            return true
        end
    )

    self:set(
        "sprites",
        self.funcs.sprites
    )

    self:set(
        "SetMod",
        function(modifier, beat, amount)
            print(modifier, beat, amount, self.modifiers[modifier])
            if self.modifiers[modifier] then
                self.modifiers[modifier]:enable(amount, beat)
                table.insert(modlist, {modifier, amount, beat})
            end
        end
    )

    self.modifiers = {}
    self:loadModifiers()

    self:call("Start")
end

function Modscript:update(beat)
    for i, v in pairs(modlist) do
        print(v[3], beat)
        if beat >= v[3] then
            self.modifiers[v[1]]:enable(v[2])
            table.insert(enabledMods, self.modifiers[v[1]])
            table.remove(modlist, i)
        end
    end

    for i, v in pairs(enabledMods) do
        v:update(dt, beat)
    end
end

function Modscript:call(func, args)
    if _G[func] then
        return _G[func](unpack(args or {}) or {})
    end
end

return Modscript