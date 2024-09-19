---@diagnostic disable: duplicate-set-field, inject-field
---@class GameScreen : State
local GameScreen = State:extend("GameScreen")

local channel = love.thread.getChannel("thread.song")
local outChannel = love.thread.getChannel("thread.song.out")

function GameScreen:new(data)
    State.new(self)
    GameScreen.instance = self
    GameScreen.doneThread = false

    self.hitObjectManager = HitObjectManager(self)
    self:add(self.hitObjectManager)

    --[[ Parsers["Quaver"]:parse("Assets/IncludedSongs/lapix feat. mami - Irradiate (Nightcore Ver.) - 841472/147043.qua",
        "Assets/IncludedSongs/lapix feat. mami - Irradiate (Nightcore Ver.) - 841472/") ]]
    --[[  ]]
    --[[ Parsers["Quaver"]:parse("Assets/IncludedSongs/purpleeater/91021.qua", "Assets/IncludedSongs/purpleeater/") ]]
    --[[ LoadSong:start({
        filepath = "Assets/IncludedSongs/purpleeater/91021.qua",
        folderpath = "Assets/IncludedSongs/purpleeater/",
        mapType = "Quaver"
    }) ]]
    print(data.path) -- Assets/IncludedSongs/LeftRight/93184.qua
    -- i want Assets/IncludedSongs/LeftRight/93184/ (length varies)
    local folderPath = data.path:match("(.+)/[^/]+$") .. "/"
    outChannel:clear()
    LoadSong:start({
        filepath = data.path,
        folderpath = folderPath,
        mapType = data.map_type,
        length = data.length
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
            print("HELPPP MEEEEEE")
            local instance = response.instance

            GameScreen.instance.song = love.audio.newSource(instance.song, "stream")
            GameScreen.instance.hitObjectManager.hitObjects = instance.hitObjects
            self.doneThread = true

            table.sort(GameScreen.instance.hitObjectManager.hitObjects, function(a, b) return a.StartTime < b.StartTime end)
            GameScreen.instance.hitObjectManager.scorePerNote = 1000000 / #GameScreen.instance.hitObjectManager.hitObjects
            GameScreen.instance.hitObjectManager.length = tonumber(instance.length)
            GameScreen.instance.data = response.instance

            GameScreen.instance.hitObjectManager:createReceptors(GameScreen.instance.data.mode)
        end
    end

    if not GameScreen.instance then return end
    if self.doneThread and not GameScreen.instance.hitObjectManager.started and GameScreen.instance.song then
        GameScreen.instance.song:play()

        GameScreen.instance.hitObjectManager.started = true
    end
end

function GameScreen:kill()
    State.kill(self)
    GameScreen.instance = nil
    self = nil
end

return GameScreen