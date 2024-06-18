local FPSOverlay = Object:extend()

function FPSOverlay:new(options)
    local options = options or {}
    self.font = love.graphics.newFont("assets/fonts/Montserrat-Medium.ttf", 16)
    self.fps = 0
    self.time = 0
    self.x = options.x or 0
    self.y = options.y or 0
    self.width = options.width or 80
    self.height = options.height or 30
    self.cornerRadius = options.cornerRadius or 5
end

function FPSOverlay:update(dt)
    self.time = self.time + dt
    if self.time >= 1 then
        self.fps = love.timer.getFPS()
        self.time = 0
    end
end

function FPSOverlay:draw()
    local lastFont = love.graphics.getFont()
    local lastColor = {love.graphics.getColor()}
    
    love.graphics.setFont(self.font)
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, self.cornerRadius)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("FPS: " .. self.fps, self.x, self.y + self.height/2 - self.font:getHeight()/2, self.width, "center")
    
    love.graphics.setFont(lastFont)
    love.graphics.setColor(lastColor)
end

return FPSOverlay