require "love.event"
require "love.thread"

local pump, poll, getChannel = love.event.pump, love.event.poll, love.thread.getChannel

local channel = {
    event = getChannel("thread.event"),
    active = getChannel("thread.event.active"),
    tick = getChannel("thread.event.tick")
}

local getTime, sleep = love.timer.getTime, love.timer.sleep

local t, s, clock = {}, 0, getTime()
local function push(i, a, ...)
    if a then 
        t[i] = a
        return push(i + 1, ...)
    end

    return i - 1
end

repeat v = channel.active:pop()
    if v == 0 then
        break
    elseif v == 1 then
        s = 0
    end

    pcall(pump)
    prev, clock = clock, getTime()
    for name, a, b, c, d, e, f in poll do
        v = push(1, a, b, c, d, e, f)
        channel.event:push(name)
        channel.event:push(clock)
        channel.event:push(v)
        for i = 1, v do
            channel.event:push(t[i])
        end

        v = clock - prev
        s = s + v
        channel.tick:clear()
        channel.tick:push(s)

        sleep(v < 0.001 and 0.001 or 0)
        collectgarbage(true)
    end
until s > 1
