--[[----------------------------------------------------------------------------

This file is apart of Rit; a free and open sourced rhythm game made with LÖVE.

Copyright (C) 2023 GuglioIsStupid

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

------------------------------------------------------------------------------]]
debug.consolelines = {}
debug.usecolor = true
debug.outfile = "log.txt"
debug.logLines = {}
debug.logmodes = {
    {name="trace",color="\27[34m",colprint={0,0,1}},
    {name="debug",color="\27[36m",colprint={0,1,1}},
    {name="info",color="\27[32m",colprint={0,1,0}},
    {name="warn",color="\27[33m",colprint={1,1,0}},
    {name="error",color="\27[31m",colprint={1,0,0}},
    {name="fatal",color="\27[35m",colprint={1,0,1}},
}
debug.consoleTyping = false
debug.command = ""
debug.commandLines = {}
function debug.print(inf, ...)
    -- print to fake console
    local args = {...}
    local str = ""
    local col = {1,1,1}
    -- the console lines should be given so console can do 
    --[[
        love.graphics.print({{col}, str},)
    --]] 
    local time = os.time()
    -- get hours, minutes, seconds, should be formatted like [HH:MM:SS]
    local hours = os.date("%H", time) or 0
    local minutes = os.date("%M", time) or 0
    local seconds = os.date("%S", time) or 0
    local curPrintCol, name
    str = "[" .. hours .. ":" .. minutes .. ":" .. seconds .. "] "
    time = hours .. ":" .. minutes .. ":" .. seconds
    for i = 1, #args do
        str = str .. tostring(args[i]) .. " "
    end
    for i = 1, #debug.logmodes do
        if debug.logmodes[i].name == inf then
            col = debug.logmodes[i].colprint
            if debug.usecolor then
                str = str
            end
            curPrintCol = debug.logmodes[i].color
            curPrintName = debug.logmodes[i].name
        end
    end
    local logstr = str
    -- now we print to console w/ the color
    local prntStr = ""
    local msg = (...) or ""
    local info = debug.getinfo(2, "Sl")
    local lineinfo = info.short_src .. ":" .. info.currentline
    -- output to console 
    print('[' .. curPrintName .. ' | ' .. time .. ']' .. lineinfo .. ': ' .. msg)
    table.insert(debug.logLines, logstr)
    table.insert(debug.consolelines, {col, str})
end

function debug.drawConsole()
    -- draw fake console at top right
    love.graphics.setColor(0.2, 0.2, 0.2, 0.5)
    love.graphics.rectangle("fill", love.graphics.getWidth() - 300, 0, 300, 260)
    love.graphics.setColor(1, 1, 1, 1)
    for i = 1, #debug.consolelines do
        love.graphics.print(debug.consolelines[i], love.graphics.getWidth() - 300, 20 * i)
    end

    if #debug.consolelines > 10 then
        table.remove(debug.consolelines, 1)
    end
end

function debug.typeConsole()
    -- another console specifically for typing, shows at top left and the width is until the other console
    love.graphics.setColor(0.2, 0.2, 0.2, 0.5)
    love.graphics.rectangle("fill", 0, 0, 300, 20)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(debug.command, 8, 0)
    love.graphics.print(">", 0, 0)
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
    love.graphics.print("sv: " .. tostring(sv or 0), 0, 120)
end

function debug.logfile()
    print("Writing log to " .. debug.outfile)
    love.filesystem.write(debug.outfile, table.concat(debug.logLines, "\n"))
end

function debug.keypressed(k)
    if k == "lctrl" then
        debug.consoleTyping = not debug.consoleTyping
    elseif k == "backspace" then
        debug.command = debug.command:sub(1, -2)
    elseif k == "return" then
        -- execute command
        local cmd = debug.command
        debug.command = ""
        debug.commandLines[#debug.commandLines + 1] = cmd
        local func, err = loadstring(cmd)
        if func then
            local success, err = pcall(func)
            if not success then
                debug.print("error", err)
            end
        else
            debug.print("error", err)
        end
        return
    end
end

function debug.textinput(t)
    if debug.consoleTyping and t ~= "lctrl" and t ~= "lshift" and t ~= "return" and t ~= "backspace" and t ~= "escape" and t ~= "tab" and t ~= "rshift" and t ~= "rctrl" and __DEBUG__ then
        debug.command = debug.command .. t
    end
end

function debug.draw()
    debug.drawConsole()
    debug.drawdebug()
    if debug.consoleTyping then
        debug.typeConsole()
    end
end

function debug.update(dt)
    -- update fake console
    if love.keyboard.isDown("lctrl") and love.keyboard.isDown("lshift") and love.keyboard.isDown("c") then
        debug.clearConsole()
    end
end