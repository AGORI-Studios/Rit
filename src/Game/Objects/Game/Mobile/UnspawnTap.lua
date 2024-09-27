local UnspawnTap = Class:extend("UnspawnTap")

function UnspawnTap:new(lane, startTime, width, hitsounds, noteVer)
    self.lane = lane
    self.StartTime = startTime
    self.tileWidth = width
    self.hitsounds = hitsounds
    self.noteVer = noteVer or "TAP"
end

return UnspawnTap