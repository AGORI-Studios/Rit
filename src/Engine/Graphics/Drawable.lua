---@class Drawable
local Drawable = Class:extend("Drawable")

---@param x number
---@param y number
---@param w number
---@param h number
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

    self.scalingType = ScalingTypes.ASPECT_FIXED

    self.windowScale = {x = 1, y = 1}
    self.angle = 0 -- 0-360, uses math.rad in runtime
    self.origin = {x = 0, y = 0}
    self.offset = {x = 0, y = 0}
    self.addOrigin = true

    self:resize(Game._windowWidth, Game._windowHeight)
end

function Drawable:centerOrigin()
    self.origin.x = self.width / 2
    self.origin.y = self.height / 2
end

function Drawable:update(dt)
    if self.scalingType ~= ScalingTypes.STRETCH and self.scalingType ~= ScalingTypes.WINDOW_STRETCH then
        --[[ self.drawX = Game._windowWidth * ((self.x + self.offset.x) / Game._gameWidth)
        self.drawY = Game._windowHeight * (self.y + self.offset.y) / Game._gameHeight ]]
        local drawX, drawY = self.x, self.y

        drawX = drawX + self.offset.x
        drawY = drawY + self.offset.y

        if self.addOrigin then
            drawX = drawX + self.origin.x*2
            drawY = drawY + self.origin.y*2
        end

        self.drawX = Game._windowWidth * (drawX / Game._gameWidth)
        self.drawY = Game._windowHeight * (drawY / Game._gameHeight)
    end
end

---@param w number
---@param h number
function Drawable:resize(w, h)
    if self.scalingType == ScalingTypes.STRETCH then
        local scaleX = w / Game._gameWidth
        local scaleY = h / Game._gameHeight
        self.windowScale.x, self.windowScale.y = math.min(scaleX, scaleY), math.min(scaleX, scaleY)
        self.width = self.baseWidth * self.windowScale.x
        self.height = self.baseHeight * self.windowScale.y
    elseif self.scalingType == ScalingTypes.ASPECT_FIXED then
        local scale = math.min(w / Game._gameWidth, h / Game._gameHeight)
        self.windowScale.x, self.windowScale.y = scale, scale
        self.width = self.baseWidth * scale
        self.height = self.baseHeight * scale
    elseif self.scalingType == ScalingTypes.WINDOW_FIXED then
        -- scales to the window size, but keeps the aspect ratio
        self.windowScale.x, self.windowScale.y = 1, 1
        self.width = self.baseWidth
        self.height = self.baseHeight

        if w / Game._gameWidth < h / Game._gameHeight then
            self.windowScale.x = w / Game._gameWidth
            self.windowScale.y = w / Game._gameWidth
        else
            self.windowScale = h / Game._gameHeight
            self.windowScale.y = h / Game._gameHeight
        end

        self.width = self.baseWidth * self.windowScale.x
        self.height = self.baseHeight * self.windowScale.y
    elseif self.scalingType == ScalingTypes.WINDOW_STRETCH then
        -- Stretches the image to the window size
        self.width = w
        self.height = h

        self.windowScale.x = w / self.baseWidth
        self.windowScale.y = h / self.baseHeight

        self.drawX = 0
        self.drawY = 0
    end
end

function Drawable:draw()
    love.graphics.push()
        local lastBlendMode, lastBlendModeAlpha = love.graphics.getBlendMode()
        local lastColour = {love.graphics.getColor()}
        -- we have to convert with love.graphics.rotate
        love.graphics.translate(self.drawX + self.width / 2, self.drawY + self.height / 2)
        love.graphics.rotate(math.rad(self.angle))
        love.graphics.translate(-self.drawX - self.width / 2, -self.drawY - self.height / 2)
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

function Drawable:move(x, y)
    self.x = x
    self.y = y
end

function Drawable:scale(x, y)
    self.scale.x = x or 1
    self.scale.y = y or x or 1
end

function Drawable:destroy()
    self:kill()
end

function Drawable:kill()
    self = nil
end

return Drawable