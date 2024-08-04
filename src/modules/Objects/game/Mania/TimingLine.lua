---@class TimingLine
---@diagnostic disable-next-line: assign-type-mismatch
local TimingLine = Object:extend()

function TimingLine:new(targetY, info)
    self.y = -2000
    self.targetY = targetY
    self.info = {
        songPos = info.songPos or 0,
        offset = info.offset or 0
    }

    self:update(self.info.offset)
end

function TimingLine:update(offset)
    self.currentTrackPosition = offset - self.info.offset
    self.y = self.targetY + (
        self.currentTrackPosition * (
            Modscript.downscroll and Settings.options["General"].scrollspeed or -Settings.options["General"].scrollspeed)
            / 100
        )
end

function TimingLine:draw(width)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(2)
    love.graphics.line(0, self.y, width, self.y)
    love.graphics.setLineWidth(1)
end

return TimingLine