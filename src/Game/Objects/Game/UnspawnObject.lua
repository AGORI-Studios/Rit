---@class UnspawnObject
local UnspawnObject = Class:extend("UnspawnObject")

function UnspawnObject:new(startTime, endTime, lane)
    self.StartTime = startTime or 0
    self.EndTime = endTime or 0
    self.Lane = lane or 1
end

return UnspawnObject