debug.consolelines = {}

function debug.print(...)
    -- print to fake console
    local args = {...}
    local str = ""
    for i = 1, #args do
        str = str .. tostring(args[i])
    end
    print(str)
    debug.consolelines[#debug.consolelines + 1] = str
end

function debug.drawConsole()
    -- draw fake console at top right
    love.graphics.setColor(0.2, 0.2, 0.2, 0.5)
    love.graphics.rectangle("fill", love.graphics.getWidth() - 300, 0, 300, 260)
    love.graphics.setColor(1, 1, 1, 1)
    for i = 1, #debug.consolelines do
        love.graphics.print(debug.consolelines[i], love.graphics.getWidth() - 300, 20 * i - 20)
    end

    if #debug.consolelines > 10 then
        table.remove(debug.consolelines, 1)
    end
end

function debug.clearConsole()
    -- clear fake console
    debug.consolelines = {}
end

function debug.drawdebug()
    love.graphics.print("Memory usage: " .. round(collectgarbage("count")) .. "KB", 0, 20)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 0, 40)
    love.graphics.print("Graphics memory usage: " .. round(love.graphics.getStats().texturememory / 1024) .. "KB", 0, 60)
    love.graphics.print("Music Time: " .. (musicTime or 0), 0, 80)
    love.graphics.print("Beat: " .. (math.floor(((musicTime or 0) / 1000) * (beatHandler.bpm/60)) or 0), 0, 100)
end

function debug.draw()
    debug.drawConsole()
    debug.drawdebug()
end

function debug.update(dt)
    -- update fake console
    if love.keyboard.isDown("lctrl") and love.keyboard.isDown("lshift") and love.keyboard.isDown("c") then
        debug.clearConsole()
    end
end