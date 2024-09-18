---@diagnostic disable: duplicate-set-field, inject-field
---@class GameScreen : State
local GameScreen = State:extend("GameScreen")

local channel = love.thread.getChannel("thread.song")
local outChannel = love.thread.getChannel("thread.song.out")

function GameScreen:new()
    State.new(self)
    GameScreen.instance = self
    GameScreen.doneThread = false

    self.hitObjectManager = HitObjectManager(self)
    self:add(self.hitObjectManager)

    --[[ Parsers["Quaver"]:parse("Assets/IncludedSongs/lapix feat. mami - Irradiate (Nightcore Ver.) - 841472/147043.qua",
        "Assets/IncludedSongs/lapix feat. mami - Irradiate (Nightcore Ver.) - 841472/") ]]
    --[[  ]]
    --[[ Parsers["Quaver"]:parse("Assets/IncludedSongs/purpleeater/91021.qua", "Assets/IncludedSongs/purpleeater/") ]]
    LoadSong:start({
        filepath = "Assets/IncludedSongs/purpleeater/91021.qua",
        folderpath = "Assets/IncludedSongs/purpleeater/",
        mapType = "Quaver"
    })

    self.HUD = HUD(self)
    self:add(self.HUD)

    self.score = 0
    self.accuracy = 0

    --[[ self.hitObjectManager.started = true ]]
    --[[ Game.Wait(1000, function()
        self.hitObjectManager.started = true
        print("Started")
    end) ]]
end

function Game:update(dt)
    State.update(self, dt)

    if outChannel:peek() then
        local response = outChannel:pop()
        if response then
            local instance = response.instance

            GameScreen.instance.song = love.audio.newSource(instance.song, "stream")
            GameScreen.instance.hitObjectManager.hitObjects = instance.hitObjects
            self.doneThread = true

            for i = #GameScreen.instance.hitObjectManager.hitObjects, 2, -1 do
                if GameScreen.instance.hitObjectManager.hitObjects[i].StartTime == GameScreen.instance.hitObjectManager.hitObjects[i - 1].StartTime then
                    table.remove(GameScreen.instance.hitObjectManager.hitObjects, i)
                end
            end
            table.sort(GameScreen.instance.hitObjectManager.hitObjects, function(a, b) return a.StartTime < b.StartTime end)
            GameScreen.instance.hitObjectManager.scorePerNote = 1000000 / #GameScreen.instance.hitObjectManager.hitObjects
        end
    end

    if self.doneThread and not GameScreen.instance.hitObjectManager.started then
        GameScreen.instance.song:play()

        GameScreen.instance.hitObjectManager.started = true
    end
end

return GameScreen