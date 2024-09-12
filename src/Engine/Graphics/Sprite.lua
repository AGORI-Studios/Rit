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

    self.origin.x = self.baseWidth/2
    self.origin.y = self.baseHeight/2

    self.offset.x = -self.origin.x
    self.offset.y = -self.origin.y
end

function Sprite:draw()
    love.graphics.push()
        love.graphics.setBlendMode(self.blendMode, self.blendModeAlpha)
        love.graphics.setColor(self.colour[1], self.colour[2], self.colour[3], self.alpha)
        
        love.graphics.draw(self.image, self.drawX, self.drawY, math.rad(self.angle), self.scale.x * self.windowScale.x, self.scale.y * self.windowScale.y, self.origin.x, self.origin.y)

        if Game.debug then
            love.graphics.translate(self.drawX, self.drawY)
            love.graphics.rotate(math.rad(self.angle))
            love.graphics.translate(-self.drawX, -self.drawY)
            love.graphics.translate(-self.origin.x * self.windowScale.x, -self.origin.y * self.windowScale.y)
            self:__debugDraw()
        end
    love.graphics.pop()
end

return Sprite