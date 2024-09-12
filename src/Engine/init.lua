local path = ... .. "."

require(path .. "Lua")

require(path .. "Base")
require(path .. "Cache")
require(path .. "Format")
require(path .. "System")
require(path .. "Graphics")
require(path .. "Input")
require(path .. "Tween")

Game = TypedGroup(State)
Game._currentState = State()
Game:add(Game._currentState)
Game.debug = true
Game._windowWidth = 1280
Game._windowHeight = 720
Game._gameWidth = 1920
Game._gameHeight = 1080
Game.Tween = TweenManager()

function Game:SwitchState(state)
    self._currentState:kill()
    self:remove(self._currentState)
    self._currentState = state()
    self:add(self._currentState)
end

function Game:update(dt)
    self._currentState:update(dt)
    self.Tween:update(dt)
end

function Game:draw()
    self._currentState:draw()
end