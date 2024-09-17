---@class Wait
local Wait = Class:extend("Wait")

function Wait:new(duration, callback)
    self.Duration = duration
    self.Callback = callback
    self.Timer = 0
end

return Wait