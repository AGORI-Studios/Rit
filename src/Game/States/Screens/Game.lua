---@diagnostic disable: duplicate-set-field, inject-field
---@class GameScreen : State
local GameScreen = State:extend("GameScreen")

function GameScreen:new(data)
    State.new(self)
    GameScreen.instance = self

    local folderPath = data.path:match("(.+)/[^/]+$") .. "/"

    self.data = {
        filepath = data.path,
        folderpath = folderPath,
        mapType = data.map_type,
        length = data.length,
        path = "",
        folder = "",
        noteCount = 0,
        gameMode = "Mania",
        hitObjects = {},
        scrollVelocities = {}
    }

    if self.data.gameMode == "Mania" then
        self.hitObjectManager = HitObjectManager(self)
    else
        self.hitObjectManager = MobileObjectManager(self)
    end

    Parsers[self.data.mapType]:parse(self.data.filepath, folderPath)
    Script:loadScript(folderPath .. "script/script.lua")
    Script:call("Load")

    self.song = love.audio.newSource(self.data.song, "stream")
    self.hitObjectManager.hitObjects = self.data.hitObjects
    self.hitObjectManager.scrollVelocities = self.data.scrollVelocities
    self.hitObjectManager:initSVMarks()

    table.sort(self.hitObjectManager.hitObjects, function(a, b) return a.StartTime < b.StartTime end)
    self.hitObjectManager.scorePerNote = 1000000 / #self.data.hitObjects
    self.hitObjectManager.length = tonumber(self.data.length)
    self.totalNotes = #self.data.hitObjects
    
    if self.data.gameMode == "Mania" then
        self.hitObjectManager:createReceptors(self.data.mode)
    end

    -- setup le mobile inputs
    local curkeylist = GameplayBinds[self.data.mode]
    if love.system.isMobile() then
        local keys = {}
        for i, key in ipairs(string.splitAllChars(curkeylist)) do
            -- calculate size and position for the mobile button (1920 width, at bottom of screen)
            local size = {1920 / #curkeylist, 1080 / 2}
            local position = {(i - 1) * size[1], 1080 - size[2]}
            local color = {1, 1, 1}
            local alpha = 0.25
            local downAlpha = 0.5
            local border = true
            
            table.insert(keys, {
                key = key,
                size = size,
                position = position,
                color = color,
                alpha = alpha,
                downAlpha = downAlpha,
                border = border
            })
        end

        GameplayPad = VirtualPad(keys)
        VirtualPad._CURRENT = GameplayPad
    end

    self.BG = Background(self.data.bgFile)
    self.BG.zorder = -10
    self:add(self.BG)
    self.BG.scalingType = ScalingTypes.WINDOW_LARGEST

    self:add(self.hitObjectManager)

    self.HUD = HUD(self)
    self:add(self.HUD)

    self.score = 0
    self.accuracy = 0
    self.combo = 0
    self.maxCombo = 0
    self.rated = 0

    self.lerpedScore = 0
    self.lerpedAccuracy = 0

    self.judgement = Judgement()
    self.judgement.zorder = 999
    self.comboDisplay = Combo()
    self.comboDisplay.zorder = 1000
    self:add(self.judgement)
    self:add(self.comboDisplay)
end

function GameScreen:update(dt)
    State.update(self, dt)

    if not self.calculateScore then
        return
    end

    self:calculateAccuracy()
    self:calculateScore()

    self.lerpedScore = math.fpsLerp(self.lerpedScore, self.score, 25, dt)
    self.lerpedAccuracy = math.fpsLerp(self.lerpedAccuracy, self.accuracy, 25, dt)
    if tostring(self.lerpedScore):match("nan") then
        self.lerpedScore = 0
    end
    if tostring(self.lerpedAccuracy):match("nan") then
        self.lerpedAccuracy = 0
    end
end

function GameScreen:calculateAccuracy()
    -- use judgecount and total ntoes hit to calculate accuracy
    local judgeCount = self.hitObjectManager.judgeCounts
    local totalNotesHit = judgeCount["marvellous"] +
        judgeCount["perfect"] +
        judgeCount["great"] +
        judgeCount["good"] +
        judgeCount["bad"] +
        judgeCount["miss"]

    self.rated = (
        judgeCount["marvellous"] * 1 +
        judgeCount["perfect"] * 0.98 +
        judgeCount["great"] * 0.85 +
        judgeCount["good"] * 0.67 +
        judgeCount["bad"] * 0.5
    ) / totalNotesHit
    
    self.accuracy = self.rated
end

function GameScreen:calculateScore()
    local leMax = 1000000 * ModifierManager:getScoreMultiplier()

    local accScore = self.rated / self.totalNotes * (leMax * 0.85)
    local comboScore = self.maxCombo / self.totalNotes * (leMax * 0.15)

    self.score = accScore + comboScore
end

function GameScreen:kill()
    State.kill(self)
    self = nil
    self = nil
    if VirtualPad then
        VirtualPad._CURRENT = MenuPad
    end
end

return GameScreen
