---@diagnostic disable: deprecated
local console = {
    _NAME = "Console",
    _DESC = "A simple console library for Love2D",
    _CREATOR = "GuglioIsStupid",
    _LICENSE = "MIT",
    _VERSION = "1.0.0"
}
console.lines = {}
console.hidden = false
console.overridePrint = true
console.typing = false
console.typed = ""

local o_print = print

local utf8 = require("utf8")

if console.overridePrint then
    function print(...)
        o_print(...)

        for _, statement in ipairs({...}) do
            table.insert(console.lines, statement)
        end
    end
end

function console.print(...)
    o_print(...)

    for _, statement in ipairs({...}) do
        table.insert(console.lines, statement)
    end
end

local function execute(command)
    table.insert(console.lines, "> " .. command)

    local func, err = loadstring(command)
    if func then
        local success, result = pcall(func)
        if success then
            if tostring(result) ~= "nil" then
                table.insert(console.lines, tostring(result))
            end
        else
            table.insert(console.lines, "Error: " .. result)
        end
    else
        table.insert(console.lines, "Syntax Error: " .. err)
    end
end

function console.toggleView()
    console.hidden = not console.hidden
end

function console.toggleInput()
    console.typing = not console.typing
end

function console.textinput(t)
    if not console.typing or t == "`" then return end
    console.typed = console.typed .. t
end

function console.keypressed(k)
    if not console.hidden and console.typing then
        if k == "return" then
            console.typing = false
            execute(console.typed)
            console.typed = ""
        elseif k == "backspace" then
            if console.typed ~= "" then
                console.typed = string.sub(console.typed, 1, utf8.offset(console.typed, -1) - 1)
            end
        end
    end
end

function console.draw()
    if console.hidden then return end

    local lastColor = {love.graphics.getColor()}
    love.graphics.setColor(0.2, 0.2, 0.2, 0.5)
    local w, h = love.graphics.getDimensions()
    local cW, cH = w/3.25, h/3.25
    love.graphics.rectangle("fill", 0, 0, cW, cH)
    local tW, tH = cW-10, cH-10
    local fH = love.graphics.getFont():getHeight()
    local endHeight = tH-30

    love.graphics.setColor(1, 1, 1)

    for i, line in ipairs(console.lines) do
        if 5 + fH*(i-1) > endHeight then
            table.remove(console.lines, 1)
        end
        love.graphics.printf(line, 5, 5 + fH*(i-1), tW)
    end

    love.graphics.printf(console.typed, 5, 5 + endHeight, tW)

    love.graphics.setColor(lastColor)
end

return console