require "love.timer"

local channel = love.thread.getChannel("ThreadChannels.Print.Output")

while true do
    local message = channel:pop()

    if message then -- Don't stop printing until we are actually finished all the prints
        print(unpack(message))
        goto continue
    end

    love.timer.sleep(0.1)

    ::continue::
end