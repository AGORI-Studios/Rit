local TapNote = Drawable:extend("TapNote")

local tileWidth = 96
function TapNote:new(lane, startTime, width, hitsounds)
    self.lane = lane
    self.StartTime = startTime
    self.tileWidth = width
    self.hitsounds = hitsounds

    Drawable.new(self, (lane - 1) * tileWidth, 0, tileWidth * width, 64)
end

return TapNote