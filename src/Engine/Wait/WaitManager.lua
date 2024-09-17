---@class WaitManager
local WaitManager = Class:extend("WaitManager")
WaitManager.Waits = {}

function WaitManager:new(duration, callback)
    local wait = Wait(duration/1000, callback)
    table.insert(self.Waits, wait)
    return wait
end

function WaitManager:update(dt)
    local finishedWaits = {}
    for _, wait in ipairs(self.Waits) do
        wait.Timer = wait.Timer + dt
        if wait.Timer >= wait.Duration then
            table.insert(finishedWaits, wait)
        end
    end

    for _, wait in ipairs(finishedWaits) do
        wait.Callback()
        for i, w in ipairs(self.Waits) do
            if w == wait then
                table.remove(self.Waits, i)
                break
            end
        end
    end
end

function WaitManager:clear()
    self.Waits = {}
end

return WaitManager