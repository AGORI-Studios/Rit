require "love.sound"
require "love.timer"

local channel = love.thread.getChannel("thread.audio")
local outChannel = love.thread.getChannel("thread.audio.out")

while true do
    local path = channel:demand()
    if not path then
        goto continue
    end

    if path == "exit" then
        break
    end

    local source = love.sound.newSoundData(path)

    outChannel:push({
        source = source,
        path = path
    })

    ::continue::
    love.timer.sleep(0.1)
end
