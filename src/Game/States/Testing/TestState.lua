---@class TestState : State
local TestState = State:extend("TestState")

function TestState:new()
    State.new(self)

    self.TestSprite = Sprite("Assets/Textures/test.png", 1500, 100)
    self.TestDrawable = Drawable(1280, 100, 300, 200)
    self.TestDrawable.angle = 45

    self:add(self.TestSprite)
    self:add(self.TestDrawable)

    Game.Tween:tween(
        self.TestSprite,
        {
            y = 300,
            angle = 180
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

    self.TestSprite.x = 1500 + math.sin(love.timer.getTime()*5) * 300
end

return TestState