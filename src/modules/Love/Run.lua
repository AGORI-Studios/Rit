love._FPSCap = 300
love._unfocusedFPSCap = 15
function love.run()
    love.graphics.present()

    love.math.setRandomSeed(os.time())
    love.load()

    collectgarbage()
    collectgarbage("stop")

    local garbageCollection = true
    local function runFunction()
        love.event.pump()
        for name, a, b, c, d, e, f in love.event.poll() do
            if name == "quit" then
                if not love.quit or not love.quit() then
                    if love.audio then
                        love.audio.stop()
                    end
                    return a or 0
                end
            end
            love.handlers[name](a, b, c, d, e, f)
        end

        local dt = love.timer.step()
        local isFocused = love.window.hasFocus()

        local fpsCap = isFocused and love._FPSCap or love._unfocusedFPSCap

        love.update(dt)
        if love.graphics.isActive() then
            love.graphics.origin()
            love.graphics.clear(love.graphics.getBackgroundColor())
            love.draw()
            love.graphics.present()
        end

        love.timer.sleep(1 / fpsCap - dt)

        if isFocused then
            collectgarbage("step")
            garbageCollection = true
        elseif garbageCollection then
            collectgarbage()
            garbageCollection = false
        end
    end

    while true do
        runFunction()
    end
end