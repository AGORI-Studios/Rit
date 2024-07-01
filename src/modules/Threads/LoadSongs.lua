require "love.filesystem"
require "love.image"
require "love.audio"
require "love.sound"
require "love.math"
require "love.system"
require "love.timer"
require "love.window"
require "modules.Utilities"
require "modules.Game.SongHandler"
GameInit = require "modules.GameInit"
json = require "lib.jsonhybrid"
tinyyaml = require "lib.tinyyaml"

local channel = love.thread.getChannel("ThreadChannels.LoadSongs.Output")

GameInit.LoadParsers()

function HitObject(startTime, lane, endTime)
    local self = {}
    self.time = startTime
    self.endTime = endTime
    self.data = lane

    return self
end

states = {
    game = {
        Gameplay = {
            unspawnNotes = {},
            mode = 4,
            bpmAffectsScrollVelocity = false,
            timingPoints = {},
            strumX = 0,
            sliderVelocities = {}
        }
    }
}

local path = ...

loadSongs(path)
channel:push(true)
channel:push(songList)