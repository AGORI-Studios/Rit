local Drawable = Class:extend("Drawable")

function Drawable:new(x, y, w, h)
    -- a drawable is an object that rescales itself based on the screen size

    self.x = x
    self.y = y 
    self.drawX = x
    self.drawY = y
    self.width = w
    self.height = h
    self.baseWidth = w
    self.baseHeight = h
    self.scale = {x = 1, y = 1}

    self.blendMode = "alpha"
    self.blendModeAlpha = "alphamultiply"

    self.colour = {1, 1, 1}
    self.alpha = 1

    self.scalingType = "aspect-fixed"

    self.windowScale = 1

    self:resize(Game._windowWidth, Game._windowHeight)
end

function Drawable:update(dt)
    if self.scalingType ~= "stretch" and self.scalingType ~= "window-stretch" then
        self.drawX = Game._windowWidth * (self.x / Game._gameWidth)
        self.drawY = Game._windowHeight * (self.y / Game._gameHeight)
    end
end

function Drawable:draw()
    love.graphics.push()
        local lastBlendMode, lastBlendModeAlpha = love.graphics.getBlendMode()
        local lastColour = {love.graphics.getColor()}
        love.graphics.setBlendMode(self.blendMode, self.blendModeAlpha)
        love.graphics.setColor(self.colour[1], self.colour[2], self.colour[3], self.alpha)

        love.graphics.rectangle("fill", self.drawX, self.drawY, self.width, self.height)

        love.graphics.setColor(lastColour)
        love.graphics.setBlendMode(lastBlendMode, lastBlendModeAlpha)

        if Game.debug then
            self:__debugDraw()
        end
    love.graphics.pop()
end

function Drawable:__debugDraw()
    love.graphics.push()
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("line", self.drawX, self.drawY, self.width, self.height)
        love.graphics.setColor(0, 0, 0)
        for x = -1, 1 do
            for y = -1, 1 do
                love.graphics.print("x: " .. math.floor(self.drawX) .. " y: " .. math.floor(self.drawY), self.drawX + x, self.drawY + y)
                love.graphics.print("w: " .. math.floor(self.width) .. " h: " .. math.floor(self.height), self.drawX + x, self.drawY + y + 10)
            end
        end
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("x: " .. math.floor(self.drawX) .. " y: " .. math.floor(self.drawY), self.drawX, self.drawY)
        love.graphics.print("w: " .. math.floor(self.width) .. " h: " .. math.floor(self.height), self.drawX, self.drawY + 10)
    love.graphics.pop()
end

function Drawable:resize(w, h)
    if self.scalingType == "stretch" then
        local scaleX = w / Game._gameWidth
        local scaleY = h / Game._gameHeight
        self.windowScale = math.min(scaleX, scaleY)
        self.width = self.baseWidth * self.windowScale
        self.height = self.baseHeight * self.windowScale
    elseif self.scalingType == "aspect-fixed" then
        local scale = math.min(w / Game._gameWidth, h / Game._gameHeight)
        self.windowScale = scale
        self.width = self.baseWidth * scale
        self.height = self.baseHeight * scale
    elseif self.scalingType == "window-fixed" then
        -- scales to the window size, but keeps the aspect ratio
        self.windowScale = 1
        self.width = self.baseWidth
        self.height = self.baseHeight

        if w / Game._gameWidth < h / Game._gameHeight then
            self.windowScale = w / Game._gameWidth
        else
            self.windowScale = h / Game._gameHeight
        end

        self.width = self.baseWidth * self.windowScale
        self.height = self.baseHeight * self.windowScale
    elseif self.scalingType == "window-stretch" then
        -- stretches the image to the window size
        self.windowScale = 1
        self.width = w
        self.height = h
    end
end

function Drawable:move(x, y)
    self.x = x
    self.y = y
end

function Drawable:scale(x, y)
    self.scale.x = x or 1
    self.scale.y = y or x or 1
end

return Drawable