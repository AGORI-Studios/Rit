---@class TimingLine
---@diagnostic disable-next-line: assign-type-mismatch
local TimingLine = Object:extend()

function TimingLine:new(targetY)
    self.y = -2000
    self.currentTrackPosition = 0 
    self.targetY = targetY
end

function TimingLine:update()
    self.currentTrackPosition = states.game.Gameplay.currentTrackPosition
    self.y = self.targetY + (self.currentTrackPosition * (Modscript.downscroll and -Settings.options["General"].scrollspeed or Settings.options["General"].scrollspeed)) / states.game.Gameplay.trackRounding
end

function TimingLine:draw(width)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(2)
    love.graphics.line(0, self.y, width, self.y)
    love.graphics.setLineWidth(1)
end

return TimingLine