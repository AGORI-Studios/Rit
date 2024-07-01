require "love.timer"
require "love.filesystem"

local channel = love.thread.getChannel("ThreadChannels.WriteFile.Output")

local allFiles = {...}

for _, filedata in ipairs(allFiles) do
    local filename = filedata.filename
    local filecontent = filedata.content

    love.filesystem.write(filename or "NoFileName.txt", filecontent or "")
end