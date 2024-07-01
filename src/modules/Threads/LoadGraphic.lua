require "love.filesystem"
require "love.image"

local Cache = require "modules.Classes.Cache"

local inputChannel = love.thread.getChannel("ThreadChannels.LoadGraphic.Input")
local outputChannel = love.thread.getChannel("ThreadChannels.LoadGraphic.Output")

local allFiles = {...}
local allAssets = {}

for _, file in ipairs(allFiles) do
    local filepath = file

    local asset = Cache:loadImageData(filepath)

    table.insert(allAssets, {
        filepath, asset
    })
end

outputChannel:push(allAssets)