local path = ... .. "."

utf8 = require("utf8")

require(path .. "Lua")
require(path .. "Love")
require(path .. "PrebuiltDLL")
require(path .. "Lib")

tryExcept(
    function()
        ffi = require("ffi") ---@type ffilib|nil
    end,
    function(exception)
        print(exception)
        ffi = nil
    end
)

require(path .. "Base")
require(path .. "Cache")
require(path .. "Format")
require(path .. "System")
require(path .. "Graphics")
require(path .. "Input")
require(path .. "Tween")
require(path .. "Wait")
require(path .. "Save")

Locale = require(path .. "Locale")

Game = TypedGroup(State) --- @class Game:TypedGroup<State>
Game._currentState = State() --- @type State
Game:add(Game._currentState)
Game.objectDebug = false
Game.debug = true
local desktopWidth, desktopHeight = love.window.getDesktopDimensions()
Game._windowWidth = desktopWidth * 0.8
Game._windowHeight = desktopHeight * 0.8
Game._gameWidth = 1920
Game._gameHeight = 1080
Game.Tween = TweenManager() --- @type TweenManager
Game.Wait = WaitManager --- @type WaitManager

function Game:SwitchState(state, ...)
    self._currentState:kill()
    self:remove(self._currentState)
    self._currentState = state(...)
    ---@diagnostic disable-next-line: inject-field
    self._currentState.instance = self._currentState
    self:add(self._currentState)
end

local infoUpdateTimer = 0.25
local infoUpdateTimerMax = 0.25
local infoData = {
    ["FPS"] = {love.timer.getFPS()},
    ["Graphics Stats"] = math.formatStorage(love.graphics.getStats()),
    ["Renderer Info"] = {love.graphics.getRendererInfo()},
    ["Lua Memory"] = math.formatStorage(collectgarbage("count") * 1024),
    ["Game"] = "Game",
    ["Current State"] = "State"
}

function Game:update(dt)
    self._currentState:update(dt)
    self.Tween:update(dt)
    self.Wait:update(dt)
end

function Game:textinput(text)
    self._currentState:textinput(text)
end

function Game:draw()
    self._currentState:draw()

    if self.debug then
        self:__updateDebug()
        self:__printDebug()
    end
end

function Game:__updateDebug()
    if self.debug then
        if infoUpdateTimer >= infoUpdateTimerMax then
            infoData = {
                ["FPS"] = {love.timer.getFPS()},
                ["Graphics Stats"] = love.graphics.getStats(),
                ["Renderer Info"] = {love.graphics.getRendererInfo()},
                ["Lua Memory"] = math.formatStorage(collectgarbage("count") * 1024),
                ["Game"] = self:__tostring(),
                ["Current State"] = self._currentState:__tostring()
            }
            infoUpdateTimer = 0
        else
            infoUpdateTimer = infoUpdateTimer + love.timer.getDelta()
        end
    end
end

function Game:__printDebug()
    love.graphics.setColor(0, 0, 0, 1)

    local debugDisplay = "FPS: " .. infoData["FPS"][1] .. " / " .. infoData["FPS"][2] ..
        "\nRenderer Info: " .. infoData["Renderer Info"][1] .. " / " .. infoData["Renderer Info"][2] .. " / " .. infoData["Renderer Info"][3] .. " / " .. infoData["Renderer Info"][4] ..
        "\nGraphics Memory: " .. math.formatStorage(infoData["Graphics Stats"].texturememory) ..
        "\nDraw Calls: " .. infoData["Graphics Stats"].drawcalls ..
        "\nLua Memory: " .. infoData["Lua Memory"] ..
        "\nGame: " .. infoData["Game"] ..
        "\n\t- Current State: " .. infoData["Current State"]
        
    for x = -1, 1 do
        for y = -1, 1 do
            love.graphics.print(debugDisplay, 10 + x, 10 + y)
        end
    end
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(debugDisplay, 10, 10)
end

function Game:quit()
    self:kill()
end
