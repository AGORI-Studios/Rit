local Icon = Sprite:extend("Icon")

function Icon:new(type, x, y)
    local path = "Assets/Textures/Menu/Icons/" .. type .. ".png"
    Sprite.new(self, path, x, y, false)
    self.shakeDuration = 0
    self.shakeIntensity = 0
    self.shakeOffset = {x = 0, y = 0}
    self.backup = {x = x, y = y}
end

function Icon:onPress()
    self:shake()
end

function Icon:update(dt)
    if self.shakeDuration > 0 then
        self.shakeDuration = self.shakeDuration - dt
        self.shakeOffset.x = love.math.random(-self.shakeIntensity, self.shakeIntensity)
        self.shakeOffset.y = love.math.random(-self.shakeIntensity, self.shakeIntensity)

        self.x = self.backup.x + self.shakeOffset.x
        self.y = self.backup.y + self.shakeOffset.y
    else
        self.shakeOffset.x = 0
        self.shakeOffset.y = 0
        self.x = self.backup.x
        self.y = self.backup.y
    end

    Sprite.update(self, dt)
end

function Icon:shake(duration, intensity)
    self.shakeDuration = duration or 0.1
    self.shakeIntensity = intensity or 3
end

function Icon:checkCollision(x, y, w, h)
    -- self.drawX - (self.origin.x * self.windowScale.x) -- this gets the real x of the object
    w, h = w or 1, h or 1
    
    return x < self.drawX + self.width and
           self.drawX < x + w and
           y < self.drawY + self.height and
           self.drawY < y + h
end

function Icon:mousepressed(x, y, button, istouch, presses)
    if self:checkCollision(x, y) then
        self:onPress()
    end
end

return Icon