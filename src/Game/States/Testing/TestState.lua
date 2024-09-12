---@class TestState : State
local TestState = State:extend("TestState")

function TestState:new()
    State.new(self)

    self.TestSprite = Sprite("Assets/Textures/test.png", 100, 100)

    self:add(self.TestSprite)

    Game.Tween:tween(
        self.TestSprite,
        {
            y = 300
        },
        1,
        {
            ease = Ease.backInOut,
            type = TweenType.PINGPONG
        }
    )
end

function TestState:update(dt)
    State.update(self, dt)

    self.TestSprite.x = 100 + math.sin(love.timer.getTime()*5) * 100
end

return TestState