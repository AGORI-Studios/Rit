---@diagnostic disable: undefined-global
local Modscript = {}

Modscript.funcs = require "modules.Game.Modding.ModscriptFunctions"
Modscript.BaseModifier = require "modules.Game.Modding.Modifiers.BaseModifier" 
Modscript.timedFunctions = {}
Modscript.shaders = {}
Modscript.currentShader = ""

-- modifiers
Modscript.modifiers = {}
function Modscript:loadModifiers()
    local files = love.filesystem.getDirectoryItems("modules/Game/Modding/Modifiers")
    for _, v in pairs(files) do
        if v ~= "BaseModifier.lua" then
            local modifier = require("modules.Game.Modding.Modifiers." .. v:sub(1, -5))
            self.modifiers[modifier.name] = modifier
        end
    end

    Modscript.Reverse = Modscript.modifiers.Reverse()
end

function Modscript:set(name, value)
    _G[name] = value
end

local modlist = {{}}
local enabledMods = {{}}

function Modscript:load(script)
    self.timedFunctions = {}
    self.shaders = {}
    self.currentShader = ""
    --print("Loading modscript " .. script)
    -- Set all of the functions for modscripting
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
            try(
                function()
                    self.funcs:createSprite(name, NewPath, x, y)
                end,
                function()
                    return false
                end
            )
        end
    )

    self:set(
        "AddSpriteAnimation",
        function(name, animation)
            try(
                function()
                    self.funcs:addSpriteAnimation(name, animation)
                end,
                function()
                    return false
                end
            )
        end
    )

    self:set(
        "SetSpriteAnimation",
        function(name, animation)
            try(
                function()
                    self.funcs:setSpriteAnimation(name, animation)
                end,
                function()
                    return false
                end
            )
        end
    )

    self:set(
        "SetSpriteProperty",
        function(name, property, value)
            Try(
                function()
                    self.funcs:setSpriteProperty(name, property, value)
                end,
                function()
                    return false
                end
            )
        end
    )

    self:set(
        "GetSpriteProperty",
        function(name, property)
            Try(
                function()
                    return self.funcs:getSpriteProperty(name, property)
                end,
                function()
                    return false
                end
            )
        end
    )

    self:set(
        "RemoveSprite",
        function(name)
            Try(
                function()
                    self.funcs:removeSprite(name)
                end,
                function()
                    return false
                end
            )
        end
    )

    self:set(
        "DoMod",
        function(func, beat)
            table.insert(modlist[self.funcs.currentPlayfield], {func, beat, self.funcs.currentPlayfield})
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
        "ApplyMod",
        function(modifier, beat, amount)
            if self.modifiers[modifier] then
                self.modifiers[modifier]:enable(amount, beat)
                table.insert(modlist[self.funcs.currentPlayfield], {modifier, amount, beat, self.funcs.currentPlayfield})
            end
        end
    )

    self:set(
        "RemoveMod",
        function(modifier, beat)
            if self.modifiers[modifier] then
                self.modifiers[modifier]:disable(beat)
            end
        end
    )

    self:set(
        "CreatePlayfield",
        function(x, y)
            table.insert(modlist, {}) -- add a new mods table for the new playfield
            table.insert(enabledMods, {})
            states.game.Gameplay:addPlayfield(x, y)
        end
    )

    self:set(
        "SetPlayfield",
        function(id)
            self.funcs.currentPlayfield = id
        end
    )

    self:set(
        "MovePlayfield",
        function(x, y)
            self.funcs:movePlayfield(x, y)
        end
    )

    self:set(
        "NewShader",
        function(name, path)
            Try(
                function()
                    self.shaders[name] = love.graphics.newShader(states.game.Gameplay.M_folderPath .. "/mod/" .. path)
                end,
                function()
                    return false
                end
            )
        end
    )

    self:set(
        "SetShader",
        function(name)
            self.currentShader = name
        end
    )

    self:set(
        "SetShaderProperty",
        function(property, value)
            Try(
                function()
                    self.shaders[self.currentShader]:send(property, value)
                end,
                function()
                    return false
                end
            )
        end
    )
end

function Modscript:update(dt, beat)
    for i, v in pairs(modlist) do
        for j, playfieldmods in ipairs(v) do
            if beat >= playfieldmods[3] then
                self.modifiers[playfieldmods[1]]:enable(playfieldmods[2])
                table.insert(enabledMods[playfieldmods[4]], self.modifiers[playfieldmods[1]])
                table.remove(modlist, i)
            end
        end        
    end

    for i, v in pairs(enabledMods) do
        for j, mod in ipairs(v) do
            mod:update(dt, beat, i)
        end
    end

    for i, v in pairs(self.timedFunctions) do
        if beat >= v[2] then
            self:call(v[1], v[3])
            table.remove(self.timedFunctions, i)
        end
    end
end

function Modscript:call(func, args)
    if _G[func] then
        return _G[func](unpack(args or {}) or {})
    end
end

function Modscript:getReverse()
    return self.Reverse.enabled and -1 or 1
end

return Modscript
