---@class Sprite : Drawable
local Sprite = Drawable:extend("Sprite")

---@param image string|love.Image
---@param x number|nil
---@param y number|nil
function Sprite:new(image, x, y, threaded)
    if not threaded and image then
        if type(image) == "string" then
            self.image = Cache:get("Image", image)
        else
            self.image = image
        end

        self.baseWidth = self.image:getWidth()
        self.baseHeight = self.image:getHeight()
    elseif threaded and image then
        self.threadedAsset = threaded
        self.threadAssetToLoad = image
    end
    Drawable.new(self, x, y, self.baseWidth, self.baseHeight)

    self.offset.x = 0
    self.offset.y = 0
end

function Sprite:update(dt)
    if self.threadedAsset then
        self.image = Cache:get("Image", self.threadAssetToLoad)
        if self.image then
            self.baseWidth = self.image:getWidth()
            self.baseHeight = self.image:getHeight()
            self:resize(Game._windowWidth, Game._windowHeight)
            self.threadedAsset = false
        end
    end

    Drawable.update(self, dt)
end

function Sprite:setImage(image)
    if type(image) == "string" then
        self.image = Cache:get("Image", image)
    else
        self.image = image
    end

    self.baseWidth = self.image:getWidth()
    self.baseHeight = self.image:getHeight()
    self:resize(Game._windowWidth, Game._windowHeight)
end

function Sprite:draw()
    if not self.visible or not self.image then return end
    love.graphics.push()
        love.graphics.setBlendMode(self.blendMode, self.blendModeAlpha)
        love.graphics.setColor(self.colour[1], self.colour[2], self.colour[3], self.alpha)
        
        -- determine new scale
        local sx, sy = self.scale.x * self.windowScale.x, self.scale.y * self.windowScale.y
        if self.forcedDimensions then
            sx = self.dimensions[1] / self.baseWidth * self.windowScale.x
            sy = self.dimensions[2] / self.baseHeight * self.windowScale.y
        end
        love.graphics.draw(self.image, self.drawX, self.drawY, math.rad(self.angle), sx, sy, self.origin.x, self.origin.y)

        if Game.debug then
            love.graphics.translate(self.drawX, self.drawY)
            love.graphics.rotate(math.rad(self.angle))
            love.graphics.translate(-self.drawX, -self.drawY)
            love.graphics.translate(-self.origin.x * self.windowScale.x * self.scale.x, -self.origin.y * self.windowScale.y * self.scale.y)
            self:__debugDraw()
        end
    love.graphics.pop()
end

return Sprite