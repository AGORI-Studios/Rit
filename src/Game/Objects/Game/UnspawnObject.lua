---@class UnspawnObject
local UnspawnObject = Class:extend()

function UnspawnObject:new(startTime, endTime, lane)
    self.startTime = startTime or 0
    self.endTime = endTime or 0
    self.lane = lane or 1
end

return UnspawnObject