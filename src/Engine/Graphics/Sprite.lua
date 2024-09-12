local Sprite = Drawable:extend("Sprite")

function Sprite:new(image, x, y)
    if type(image) == "string" then
        self.image = Cache:get("Image", image)
    else
        self.image = image
    end
    
    self.baseWidth = self.image:getWidth()
    self.baseHeight = self.image:getHeight()
    Drawable.new(self, x, y, self.baseWidth, self.baseHeight)
end

function Sprite:draw()
    love.graphics.push()
        local lastBlendMode, lastBlendModeAlpha = love.graphics.getBlendMode()
        love.graphics.setBlendMode(self.blendMode, self.blendModeAlpha)

        love.graphics.draw(self.image, self.drawX, self.drawY, 0, self.scale * self.windowScale, self.scale * self.windowScale)

        if Game.debug then
            self:__debugDraw()
        end
    love.graphics.pop()
end

return Sprite