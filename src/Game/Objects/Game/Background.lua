local Background = Class:extend("Background")

function Background:new(bgIMAGE, bgVIDEO)
    self.sprite = Sprite(bgIMAGE, 0, 0)
    self.sprite:centerOrigin()
    self.sprite.scalingType = ScalingTypes.WINDOW_STRETCH
    self.sprite:resize(Game._windowWidth, Game._windowHeight)
    
    self.video = Video(bgVIDEO, 0, 0)
    self.video:centerOrigin()
    self.video.scalingType = ScalingTypes.WINDOW_STRETCH
    self.video:resize(Game._windowWidth, Game._windowHeight)
end

function Background:update(dt)
    self.sprite:update(dt)
    self.video:update(dt)
end

function Background:resize(w, h)
    self.sprite:resize(w, h)
    self.video:resize(w, h)
end

function Background:draw()
    self.sprite:draw()
    self.video:draw()
end

return Background