require("love.event")
require("love.timer")

local getChannel = love.thread.getChannel
local channel, active = getChannel("EventThread"), getChannel("EventThreadActive")

local t, s, clock = {}, 0, love.timer.getTime()
local val, prevClock
local function push(id, a, ...)
    if a then
        t[id] = a
        return push(id+1, ...)
    end
    return id - 1
end

repeat val = active:pop()
    if val == 0 then
        break
    elseif val == 1 then
        s = 0
    end
    pcall(love.event.pump)
    prevClock, clock = clock, love.timer.getTime()
    for name, a, b, c, d, e, f in love.event.poll() do
        v = push(1, name, a, b, c, d, e, f)
        channel:push(name)
        channel:push(clock)
        channel:push(v)
        for i = 1, v do
            channel:push(t[i])
        end
    end

    v = clock - prevClock
    s = s + v
    love.timer.sleep(v < 0.001 and 0.001 or 0)
    collectgarbage("step")
until s > 1