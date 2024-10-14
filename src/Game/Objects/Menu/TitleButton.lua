local TitleButton = Sprite:extend("TitleButton")

function TitleButton:new(text, path, borderPath, x, y, callback)
    self.display = Text(text, x, y, 20, {1, 1, 1, 1}, nil, nil, nil, nil, true, 1920)
    if borderPath then
        self.Border = Sprite(borderPath, x, y, true)
    end
    Sprite.new(self, path, x, y)

    self:centerOrigin()
    self.Border:centerOrigin()
    self.display:centerOrigin()

    self.Callback = callback
    self.down = false
    self.released = false
    self.baseScale = {x = 1, y = 1}
end

function TitleButton:update(dt)
    Sprite.update(self, dt)
    if self.Border then
        self.Border:update(dt)
    end

    local mx, my = love.mouse.getPosition()

    if self.down and self.released then
        self.released = false
        self:hit()
    elseif self.down and not love.mouse.isDown(1) then
        self.released = true
    end

    self.down = love.mouse.isDown(1) and self:checkCollision(mx, my)

    if self:checkCollision(mx, my) and not self.down then
        self.scale.x, self.scale.y = math.fpsLerp(self.scale.x, self.baseScale.x * 1.1, 25, dt), math.fpsLerp(self.scale.y, self.baseScale.y * 1.1, 25, dt)
        if self.Border then
            self.Border.scale.x, self.Border.scale.y = math.fpsLerp(self.Border.scale.x, self.baseScale.x * 1.1, 25, dt), math.fpsLerp(self.Border.scale.y, self.baseScale.y * 1.1, 25, dt)
        end
        self.display.scale.x, self.display.scale.y = math.fpsLerp(self.display.scale.x, 1.1, 25, dt), math.fpsLerp(self.display.scale.y, 1.1, 25, dt)
    elseif self:checkCollision(mx, my) and self.down then
        self.scale.x, self.scale.y = math.fpsLerp(self.scale.x, self.baseScale.x, 25, dt), math.fpsLerp(self.scale.y, self.baseScale.y, 25, dt)
        if self.Border then
            self.Border.scale.x, self.Border.scale.y = math.fpsLerp(self.Border.scale.x, self.baseScale.x, 25, dt), math.fpsLerp(self.Border.scale.y, self.baseScale.y, 25, dt)
        end
        self.display.scale.x, self.display.scale.y = math.fpsLerp(self.display.scale.x, 1, 25, dt), math.fpsLerp(self.display.scale.y, 1, 25, dt)
    else
        self.scale.x, self.scale.y = math.fpsLerp(self.scale.x, self.baseScale.x, 25, dt), math.fpsLerp(self.scale.y, self.baseScale.y, 25, dt)
        if self.Border then
            self.Border.scale.x, self.Border.scale.y = math.fpsLerp(self.Border.scale.x, self.baseScale.x, 25, dt), math.fpsLerp(self.Border.scale.y, self.baseScale.y, 25, dt)
        end
        self.display.scale.x, self.display.scale.y = math.fpsLerp(self.display.scale.x, 1, 25, dt), math.fpsLerp(self.display.scale.y, 1, 25, dt)
    end

    self.display:update(dt)

    if self.released and self.Callback then
        self.Callback(self)
    end

    self.released = false
end

function TitleButton:resize(w, h)
    Sprite.resize(self, w, h)
    if self.Border then
        self.Border:resize(w, h)
    end
    self.display:resize(w, h)
end

function TitleButton:hit()
    if self.Callback then
        self.Callback()
    end
end

function TitleButton:setScale(x, y)
    self.baseScale = {x = x, y = y}
    Sprite.setScale(self, x, y)
    if self.Border then
        self.Border:setScale(x, y)
    end
    self.display:setScale(x, y)
end

function TitleButton:draw()
    if self.Border then
        self.Border:draw()
    end
    self.Border:draw()
    Sprite.draw(self)
    self.display:draw()
end

return TitleButton
