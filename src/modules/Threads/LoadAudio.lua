require "love.filesystem"
require "love.audio"

local inputChannel = love.thread.getChannel("ThreadChannels.LoadAudio.Input")
local outputChannel = love.thread.getChannel("ThreadChannels.LoadAudio.Output")

local filename = ...

outputChannel:push(love.audio.newSource(filename, "stream"))