local UnspawnSlide = Class:extend("UnspawnSlide")

function UnspawnSlide:new(lane, startTime, endTime, width, endWidth, hitsounds, noteVer, data)
    self.lane = lane
    self.StartTime = startTime
    self.tileWidth = width
    self.endTime = endTime
    self.endWidth = endWidth
    self.hitsounds = hitsounds
    self.noteVer = noteVer or "TAP"
    self.vertData = data
end

return UnspawnSlide