local Modscript = {}
Modscript.vars = {}
local chunkMeta = {__index = _G}

Modscript.funcs = require "modules.Game.Helpers.ModscriptFunctions"

function Modscript:set(name, value)
    self.vars[name] = value
end

function Modscript:load(script)
    print("Loading modscript " .. script)
    local chunk
    Try(
        function()
            chunk = love.filesystem.load(script)
        end,
        function()
            return false
        end
    )

    setfenv(chunk, setmetatable(Modscript.vars, chunkMeta))
    thing = chunk()

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

    self:call("Start")
end

function Modscript:call(func, args)
    local args = args or {}
    if self.closed then
        return
    end

    self.lastCalled = func

    Try(
        function()
            if not self.vars then return end
            if not self.vars[func] then return end

            self.vars[func](unpack(args))
        end,
        function()
            print("Error in modscript function " .. func)
        end
    )
end

return Modscript