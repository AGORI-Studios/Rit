---@class Sprite : Drawable
local Sprite = Drawable:extend("Sprite")

---@param image string|love.Image
---@param x number
---@param y number
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
        love.graphics.setBlendMode(self.blendMode, self.blendModeAlpha)
        love.graphics.setColor(self.colour[1], self.colour[2], self.colour[3], self.alpha)

        love.graphics.draw(self.image, self.drawX, self.drawY, 0, self.scale.x * self.windowScale, self.scale.y * self.windowScale)

        if Game.debug then
            self:__debugDraw()
        end
    love.graphics.pop()
end

return Sprite