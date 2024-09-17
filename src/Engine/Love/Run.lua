---@diagnostic disable: redundant-parameter
local threadEvent = love.thread.newThread("Engine/Threads/EventThread.lua")
local channel = {
    event = love.thread.getChannel("thread.event"),
    active = love.thread.getChannel("thread.event.active"),
    tick = love.thread.getChannel("thread.event.tick")
}

local clock = 0

local function event(name, a, ...)
    if name == "quit" and not love.quit() then
        channel.event:clear()
        channel.active:clear()
        channel.active:push(0)
        return a or 0, ...
    end

    return love.handlers[name](a, ...)
end

function love.run()
    local g_origin, g_clear, g_present = love.graphics.origin, love.graphics.clear, love.graphics.present
    local g_active, g_getBGColour = love.graphics.isActive, love.graphics.getBackgroundColor
    local e_pump, e_poll, t, n = love.event.pump, love.event.poll, {}, 0
    local t_step, t_getTime, t_sleep = love.timer.step, love.timer.getTime, love.timer.sleep
    local a, b

    ---@diagnostic disable-next-line: redundant-parameter
	if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then t_step() end

	local dt = 0

    t_step()
    collectgarbage()

	return function()
		if threadEvent:isRunning() then
            channel.active:clear()
            channel.active:push(1)
            a = channel.event:pop()
            while a do
                clock, b = channel.event:demand(), channel.event:demand()
                for i =  1, b do
                    t[i] = channel.event:demand()
                end
                n, a, b = b, event(a, unpack(t, 1, b))
                if a then
                    e_pump()
                    return a, b
                end
                a = channel.event:pop()
            end
        end

        e_pump()

        for name, a, b, c, d, e, f in e_poll() do
           a, b = event(name, a, b, c, d, e, f)
           if a then return a, b end
        end

        dt, clock = t_step(), t_getTime()

        love.update(dt)

        if g_active() then
            g_origin()
            g_clear(g_getBGColour())
            love.draw()
            g_present()
        end

        t_sleep((1 / 1000) - dt)
        collectgarbage("step")
	end
end