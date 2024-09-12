local Sprite = Drawable:extend("Sprite")

function Sprite:new(image, x, y)
    Sprite.super.new(self)

    self.image = image
    
    self.baseWidth = self.image:getWidth()
    self.baseHeight = self.image:getHeight()
    self.windowScale = 1
    self.scalingType = "aspect-fixed" -- can be stretch, aspect-fixed, window-fixed, window-stretch
end

function Sprite:resize(w, h)
    -- need to calculate the "scale" of the image
    -- so that it can be resized based on the screen size
    -- No stretching
    if self.scalingType == "stretch" then
        local scaleX = w / 1920
        local scaleY = h / 1080
        self.windowScale = math.min(scaleX, scaleY)
        self.width = self.baseWidth * self.windowScale
        self.height = self.baseHeight * self.windowScale
    elseif self.scalingType == "aspect-fixed" then
        local scale = math.min(w / 1920, h / 1080)
        self.windowScale = scale
        self.width = self.baseWidth * scale
        self.height = self.baseHeight * scale
    elseif self.scalingType == "window-fixed" then
        -- scales to the window size, but keeps the aspect ratio
        self.windowScale = 1
        self.width = self.baseWidth
        self.height = self.baseHeight
        
        if w / 1920 < h / 1080 then
            self.windowScale = w / 1920
        else
            self.windowScale = h / 1080
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

function Sprite:draw()
    love.graphics.draw(self.image, self.x, self.y, 0, self.scale * self.windowScale, self.scale * self.windowScale)
end

return Sprite