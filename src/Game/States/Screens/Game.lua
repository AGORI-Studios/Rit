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
    self.combo = 0
    self.maxCombo = 0
    self.rated = 0
    self.totalNotes = 0

    self.lerpedScore = 0
    self.lerpedAccuracy = 0

    self.judgement = Judgement()
    self.comboDisplay = Combo()
    self:add(self.judgement)
    self:add(self.comboDisplay)
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

            table.sort(GameScreen.instance.hitObjectManager.hitObjects, function(a, b) return a.StartTime < b.StartTime end)
            GameScreen.instance.hitObjectManager.scorePerNote = 1000000 / #GameScreen.instance.hitObjectManager.hitObjects
            GameScreen.instance.hitObjectManager.length = tonumber(instance.length)
            GameScreen.instance.data = response.instance
            GameScreen.instance.totalNotes = #GameScreen.instance.hitObjectManager.hitObjects

            GameScreen.instance.hitObjectManager:createReceptors(GameScreen.instance.data.mode)
        end
    end

    if not GameScreen.instance then return end
    GameScreen.instance:calculateAccuracy()
    GameScreen.instance:calculateScore()

    GameScreen.instance.lerpedScore = math.fpsLerp(GameScreen.instance.lerpedScore, GameScreen.instance.score, 25, dt)
    GameScreen.instance.lerpedAccuracy = math.fpsLerp(GameScreen.instance.lerpedAccuracy, GameScreen.instance.accuracy, 25, dt)
    if tostring(GameScreen.instance.lerpedScore):match("nan") then
        GameScreen.instance.lerpedScore = 0
    end
    if tostring(GameScreen.instance.lerpedAccuracy):match("nan") then
        GameScreen.instance.lerpedAccuracy = 0
    end

    if self.doneThread and not GameScreen.instance.hitObjectManager.started and GameScreen.instance.song then
        GameScreen.instance.song:play()

        GameScreen.instance.hitObjectManager.started = true
    end
end

function GameScreen:calculateAccuracy()
    -- use judgecount and total ntoes hit to calculate accuracy
    local judgeCount = GameScreen.instance.hitObjectManager.judgeCounts
    local totalNotesHit = judgeCount["marvellous"] +
        judgeCount["perfect"] +
        judgeCount["great"] +
        judgeCount["good"] +
        judgeCount["bad"] +
        judgeCount["miss"]
    local totalNotes = GameScreen.instance.totalNotes

    GameScreen.instance.rated = (
        judgeCount["marvellous"] * 1 +
        judgeCount["perfect"] * 0.98 +
        judgeCount["great"] * 0.85 +
        judgeCount["good"] * 0.67 +
        judgeCount["bad"] * 0.5
    ) / totalNotesHit
    
    GameScreen.instance.accuracy = GameScreen.instance.rated
end

function GameScreen:calculateScore()
    local scoreMult = ModifierManager:getScoreMultiplier()
    local leMax = 1000000 * scoreMult

    local accScore = GameScreen.instance.rated / GameScreen.instance.totalNotes * (leMax * 0.85)
    local comboScore = GameScreen.instance.maxCombo / GameScreen.instance.totalNotes * (leMax * 0.15)

    GameScreen.instance.score = accScore + comboScore
end

function GameScreen:kill()
    State.kill(self)
    GameScreen.instance = nil
    self = nil
end

return GameScreen