require "love.image"
require "love.timer"

local channel = love.thread.getChannel("thread.image")
local outChannel = love.thread.getChannel("thread.image.out")

while true do
    local path = channel:demand()
    if not path then
        goto continue
    end

    if path == "exit" then
        break
    end

    local image = love.image.newImageData(path)

    outChannel:push({
        image = image,
        path = path
    })

    ::continue::
    love.timer.sleep(0.1)
end
