require "love.graphics"
require "love.timer"

local channel = love.thread.getChannel("thread.font")
local outChannel = love.thread.getChannel("thread.font.out")

while true do
    local data = channel:demand()
    if not data then
        goto continue
    end

    if data.path == "exit" then
        break
    end

    local font = love.graphics.newFont(data.path, data.size or 12)

    outChannel:push({
        font = font,
        path = data.path,
        size = data.size
    })

    ::continue::
    love.timer.sleep(0.1)
end
