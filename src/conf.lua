local __DEBUG__ = not love.filesystem.isFused()
local major, minor, revision, codename = love.getVersion()
json = require("lib.jsonhybrid")
---Tries to run a function, and if it fails, runs another function
---@param f function
---@param catchFunc function
---@return nil, any
function Try(f, catchFunc)
    local returnedValue, error = pcall(f)
    if not returnedValue then
        catchFunc(error)
    end

    return returnedValue, (error or false) --  not actually an error, just the value returned
end
local Settings = require("modules.Game.Settings")
Settings.loadOptions()
function love.conf(t)
    t.window.title = "Rit."
    if __DEBUG__ then
        t.window.title = t.window.title .. " | DEBUG | " .. jit.version .. " | " ..
            jit.os .. " " .. jit.arch .. " | LOVE " ..
            (
                major .. "." .. minor .. "." .. revision .. " - " .. codename
            )
    end
    t.identity = "rit"

    t.window.width = Settings.options["Video"].Width
    t.window.height = Settings.options["Video"].Height

    t.window.resizable = true
    t.window.vsync = Settings.options["Video"].VSYNC and 1 or 0
    
    t.console = __DEBUG__
    t.window.icon = "assets/images/icon.png"

    -- disable modules we don't need
    t.modules.physics = false
end