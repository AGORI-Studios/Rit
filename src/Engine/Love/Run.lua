---@diagnostic disable: redundant-parameter
local threadEvent = love.thread.newThread("Engine/Threads/EventThread.lua")
local channel = {
    event = love.thread.getChannel("thread.event"),
    active = love.thread.getChannel("thread.event.active"),
    tick = love.thread.getChannel("thread.event.tick")
}

local function event(name, a, ...)
    if name == "quit" and not love.quit() then
        channel.event:clear()
        channel.active:clear()
        channel.active:push(0)
        return a or 0, ...
    end

    return love.handlers[name](a, ...)
end

love._framerate = 500

function love.run()
    local g_origin, g_clear, g_present = love.graphics.origin, love.graphics.clear, love.graphics.present
    local g_active, g_getBGColour = love.graphics.isActive, love.graphics.getBackgroundColor
    local e_pump, e_poll, t, n = love.event.pump, love.event.poll, {}, 0
    local t_step, t_sleep, t_getTime = love.timer.step, love.timer.sleep, love.timer.getTime

    ---@diagnostic disable-next-line: redundant-parameter
	if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then t_step() end

	local dt = 0
    local lastFrame = 0

    t_step()
    collectgarbage()

	return function()
		if threadEvent:isRunning() then
            channel.active:clear()
            channel.active:push(1)
            a = channel.event:pop()
            while a do
                b = channel.event:demand()
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

        dt = t_step()

        love.update(dt)

        while love._framerate and t_getTime() - lastFrame < 1 / love._framerate do
            t_sleep(0.0005)
        end

        lastFrame = t_getTime()
        if g_active() then
            g_origin()
            g_clear(g_getBGColour())
            love.draw()
            g_present()
        end

        t_sleep(0.001)
        collectgarbage("step")
	end
end