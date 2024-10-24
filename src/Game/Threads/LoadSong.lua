require "love.filesystem"
require "love.audio"
require "love.timer"
require "love.math"
require "love.sound"
require "Engine.Lua"

local data = ...

require "Engine.Format"
Parsers = require "Game.Parsing"
Class = require "Engine.Base.Class"
UnspawnObject = require "Game.Objects.Game.UnspawnObject"
UnspawnTap = require "Game.Objects.Game.Mobile.UnspawnTap"
UnspawnSlide = require "Game.Objects.Game.Mobile.UnspawnSlide"

instance = {
    hitObjects = {}
}

local channel = love.thread.getChannel("thread.song")
local outChannel = love.thread.getChannel("thread.song.out")

-- data is a table
-- holding filepath, and folderpath, and mapType
print(data, data.filepath, data.folderpath, data.mapType)

local path = data.filepath
local folder = data.folderpath
local mapType = data.mapType

instance.path = data.filepath
instance.folder = data.folderpath
instance.mapType = data.mapType
instance.length = data.length
instance.noteCount = data.noteCount
instance.gameMode = "Mania"

print(mapType, path, folder)

Parsers[mapType]:parse(path, folder)

outChannel:push({
    instance = instance
})
