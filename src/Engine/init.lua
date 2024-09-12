local path = ... .. "."

Class = require("Lib.Class")

require(path .. "System")
require(path .. "Graphics")

Game = TypedGroup(State)
Game._currentState = State()
Game:add(Game._currentState)

function Game:SwitchState(state)
    self._currentState:kill()
    self:remove(self._currentState)
    self._currentState = state()
    self:add(self._currentState)
end
