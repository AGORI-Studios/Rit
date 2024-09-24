---@class WaitEvery
local WaitEvery = Class:extend("WaitEvery")

function Wait:new(every, callback)
    self.Every = every
    self.Callback = callback
    self.Timer = 0
    self.EveryTimer = 0
end

return WaitEvery
