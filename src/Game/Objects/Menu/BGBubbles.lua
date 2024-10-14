local BGBubbles = TypedGroup:extend("BGBubbles")

function BGBubbles:get()
    if not BGBubbles.instance then
        BGBubbles.instance = BGBubbles()
    end

    return BGBubbles.instance
end

function BGBubbles:new()
    TypedGroup.new(self, Sprite)
    self.deleteOnClear = false
    self.bubbles = {}
    for i = 1, 5 do
        local bubble = Sprite("Assets/Textures/Menu/Bubbles/BGBubble" .. i .. ".png", 0, 0)
        self.bubbles[i] = bubble
        self:add(bubble)

        bubble.alpha = 0.71
        bubble.blendMode = "lighten"
        bubble.blendModeAlpha = "premultiplied"
        bubble.ogX, bubble.ogY = love.math.random(0, 1920 - bubble.baseWidth), love.math.random(0, 1080 - bubble.baseHeight)
        bubble.velY = love.math.random(25, 50)
    end
end

function BGBubbles:update(dt)
    TypedGroup.update(self, dt)
    for i, bubble in pairs(self.bubbles) do
        bubble.ogX = bubble.ogX + math.sin((love.timer.getTime()*1000) / 250 / i) * (12.5 * i) * dt
        bubble.ogY = bubble.ogY - bubble.velY * dt

        if bubble.ogY < -bubble.baseHeight then
            bubble.ogY = 1080+100
            bubble.ogX = love.math.random(0, 1920 - bubble.baseWidth)
            bubble.velY = love.math.random(25, 50)
        end

        bubble.x = bubble.ogX
        bubble.y = bubble.ogY
    end
end

return BGBubbles