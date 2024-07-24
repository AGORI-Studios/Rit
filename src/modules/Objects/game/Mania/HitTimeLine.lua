local HitTimeLine = Object:extend()

function HitTimeLine:new(time, colour)
    self.colour = colour
    self.alpha = 1
    self.time = time
end

function HitTimeLine:update(dt)
    self.alpha = self.alpha - 1 * dt
end

function HitTimeLine:draw()
    local lastColor = {love.graphics.getColor()}
    love.graphics.setColor(self.colour[1], self.colour[2], self.colour[3], self.alpha)
    love.graphics.rectangle("fill", (self.time/2) + (Inits.GameWidth/2), 515, 4, 20)
    love.graphics.setColor(lastColor)
end

return HitTimeLine