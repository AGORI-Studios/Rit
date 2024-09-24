---@class WaitManager
local WaitManager = Class:extend("WaitManager")
WaitManager.Waits = {}
WaitManager.Every = {}

---@param duration number
---@param callback function
---@param type string
function WaitManager:new(duration, callback, type)
    local type = type or "wait"
    local wait
    if type == "wait" then
        wait = Wait(duration/1000, callback)
        table.insert(self.Waits, wait)
    else
        wait = WaitEvery(duration/1000, callback)
        table.insert(self.Every, wait)
    end

    return wait
end

function WaitManager:remove(wait)
    for i, w in ipairs(self.Waits) do
        if w == wait then
            table.remove(self.Waits, i)
            break
        end
    end

    for i, w in ipairs(self.Every) do
        if w == wait then
            table.remove(self.Every, i)
            break
        end
    end
end

function WaitManager:update(dt)
    local finishedWaits = {}
    for _, wait in ipairs(self.Waits) do
        wait.Timer = wait.Timer + dt
        if wait.Timer >= wait.Duration then
            table.insert(finishedWaits, wait)
        end
    end

    for _, WaitEvery in ipairs(self.Every) do
        WaitEvery.EveryTimer = WaitEvery.EveryTimer + dt
        if WaitEvery.EveryTimer >= WaitEvery.Every then
            WaitEvery.EveryTimer = 0
            WaitEvery.Callback()
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
