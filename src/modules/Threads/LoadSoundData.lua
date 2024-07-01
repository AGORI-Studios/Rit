require "love.filesystem"
require "love.sound"

local inputChannel = love.thread.getChannel("ThreadChannels.LoadSoundData.Input")
local outputChannel = love.thread.getChannel("ThreadChannels.LoadSoundData.Output")

local filename = ...

outputChannel:push(love.sound.newSoundData(filename))