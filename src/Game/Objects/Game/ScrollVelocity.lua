local ScrollVelocity = Class:extend("ScrollVelocity")

function ScrollVelocity:new(startTime, multiplier)
    self.StartTime = startTime or 0
    self.Multiplier = multiplier or 0
end

return ScrollVelocity