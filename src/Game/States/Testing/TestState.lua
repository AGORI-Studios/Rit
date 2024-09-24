---@class TestState : State
local TestState = State:extend("TestState")

function TestState:new()
    State.new(self)

    --[[ self.TestSprite = Sprite("Assets/Textures/test.png", 0, 0) ]]
    --[[ self.TestDrawable = Drawable(200, 200, 300, 200)
    self.TestDrawable.scalingType = ScalingTypes.WINDOW_STRETCH
    self.TestDrawable.angle = 45
    self.TestDrawable:resize(Game._windowWidth, Game._windowHeight)
    --]]


    --[[ Game.Tween:tween(
        self.TestSprite,
        {
            y = 0,
        },
        1,
        {
            ease = Ease.backInOut,
            type = TweenType.PINGPONG
        }
    ) ]]
end

function TestState:update(dt)
    State.update(self, dt)

    --[[ self.TestSprite.x = 1500 + math.sin(love.timer.getTime()*5) * 300 ]]
end

return TestState
