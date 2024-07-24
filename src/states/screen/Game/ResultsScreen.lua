local ResultsScreen = state()
local args = {}
local bg, songname, diffname
local score, acc, misses, rating
local combo
local judgeCounters
local timings = {}
local animatedTimings = {}

local curBlur = {1} -- 1 is basically no blur,.,., max blur is 8
local updatingShader = true

function ResultsScreen:enter(_, ...)
    local gameplayState = states.game.Gameplay
    gameplayState.judgements = {
        {
            name = "marvellous", img = skin:format("judgements/MARVELLOUS.png"),
            time = 23, scoreMultiplier = 1, weight = 125.000,
            forLN = true, colour = {1, 1, 1}
        },
        {
            name = "perfect", img = skin:format("judgements/PERFECT.png"),
            time = 40, scoreMultiplier = 0.93, weight = 122.950,
            forLN = true, colour = {247/255, 242/255, 84/255}
        },
        {
            name = "great", img = skin:format("judgements/GREAT.png"),
            time = 74, scoreMultiplier = 0.7, weight = 81.963,
            forLN = true, colour = {49/255, 188/255, 247/255}
        },
        {
            name = "good", img = skin:format("judgements/GOOD.png"),
            time = 103, scoreMultiplier = 0.55, weight = 40.975,
            forLN = false, colour = {10/255, 204/255, 23/255}
        },
        {
            name = "bad", img = skin:format("judgements/BAD.png"),
            time = 127, scoreMultiplier = 0.3, weight = 20.488,
            forLN = false, colour = {242/255, 120/255, 5/255}
        },
        {
            name = "miss", img = skin:format("judgements/MISS.png"),
            time = 160, scoreMultiplier = 0, weight = 0.000,
            forLN = false, colour = {133/255, 32/255, 4/255}
        }
    }
    curBlur = {1}
    updatingShader = true
    animatedTimings = {}

    args = {...}
    args = args[1]
    states.game.Gameplay.background = states.game.Gameplay.background or love.graphics.newImage("assets/images/ui/menu/playBG.png")
    bg = states.game.Gameplay.background and
            states.game.Gameplay.background.image or
            states.game.Gameplay.background

    songname = __title
    diffname = __diffName

    score, acc, misses, rating = math.round(args.score), args.accuracy, arg.misses, args.rating
    combo = args.maxCombo
    judgeCounters = args.judgements

    timings = args.timings or {}

    local noteCount = states.game.Gameplay.totalNoteCount or 423
    self.marvPert = judgeCounters.marvellous / noteCount
    self.perfPert = judgeCounters.perfect / noteCount
    self.greatPert = judgeCounters.great / noteCount
    self.goodPert = judgeCounters.good / noteCount
    self.badPert = judgeCounters.bad / noteCount
    self.missPert = judgeCounters.miss / noteCount

    Timer.after(0.2, function()
        Timer.tween(0.5, curBlur, {8}, "out-sine", function()
            updatingShader = false 
        end)
    end)
end

function ResultsScreen:update(dt)
    if updatingShader then
        if love.graphics.getSupportedShader() then
            shaders.blurShader_Results:send("blur_radius", curBlur[1])
        end
    end
end

function ResultsScreen:mousepressed(x, y, b)
    local x, y = toGameScreen(x, y)

    local canc = Header:mousepressed(x, y, b)
    if canc then return end
end

function ResultsScreen:draw()
    local gameplayState = states.game.Gameplay
    if love.graphics.getSupportedShader() then
        love.graphics.setShader(shaders.blurShader_Results)
    end
    love.graphics.draw(bg, 0, 0, 0, 1920/bg:getWidth(), 1080/bg:getHeight())
    if love.graphics.getSupportedShader() then
        love.graphics.setShader()
    end

    Header:draw()

    -- hell yeah, programmer-ui time!!
    love.graphics.setColor(0.3, 0.3, 0.3, 0.75)
    love.graphics.rectangle("fill", 0, 400, 1920, 680)

    love.graphics.setColor(0.3, 0.3, 0.3, 1)
    love.graphics.rectangle("fill", 125, 450, 1670, 125, 15, 15)

    love.graphics.setColor(1, 1, 1)
    local lastFont = love.graphics.getFont()

    love.graphics.setFont(Cache.members.font["defaultBoldX1.5"])
    love.graphics.printf(localize("Max Combo"), 300, 525, 150, "center")
    love.graphics.printf(localize("Accuracy"), 700, 525, 150, "center")
    love.graphics.printf(localize("Rating"), 1100, 525, 150, "center")
    love.graphics.printf(localize("Score"), 1500, 525, 150, "center")
    
    love.graphics.setFont(Cache.members.font["defaultBoldX2.5"])
    love.graphics.printf(combo, 300, 465, 150, "center")
    love.graphics.printf(string.format("%.2f", acc) .. "%", 650, 465, 250, "center")
    love.graphics.printf(string.format("%.2f", rating), 1050, 465, 250, "center")
    love.graphics.printf(love.format.commaSeperateNumbers(score), 1450, 465, 250, "center")

    love.graphics.setColor(0.3, 0.3, 0.3, 1)
    love.graphics.rectangle("fill", 125, 600, 830, 450, 15, 15) -- left bottom square
    love.graphics.rectangle("fill", 965, 600, 830, 450, 15, 15) -- right bottom square

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(Cache.members.font["defaultBoldX1.25"])

    -- Draw our judgement display, 10px padding between each bar
    love.graphics.setColor(gameplayState.judgements[1].colour)
    love.graphics.rectangle("fill", 250, 625, 680*self.marvPert, 35)
    love.graphics.print("Marvellous", 130, 628)

    love.graphics.setColor(gameplayState.judgements[2].colour)
    love.graphics.rectangle("fill", 250, 670, 680*self.perfPert, 35)
    love.graphics.print("Perfect", 130, 673)

    love.graphics.setColor(gameplayState.judgements[3].colour)
    love.graphics.rectangle("fill", 250, 715, 680*self.greatPert, 35)
    love.graphics.print("Great", 130, 718)

    love.graphics.setColor(gameplayState.judgements[4].colour)
    love.graphics.rectangle("fill", 250, 760, 680*self.goodPert, 35)
    love.graphics.print("Good", 130, 763)

    love.graphics.setColor(gameplayState.judgements[5].colour)
    love.graphics.rectangle("fill", 250, 805, 680*self.badPert, 35)
    love.graphics.print("Bad", 130, 808)

    love.graphics.setColor(gameplayState.judgements[6].colour)
    love.graphics.rectangle("fill", 250, 840, 680*self.missPert, 35)
    love.graphics.print("Miss", 130, 843)

    -- Timing graph-like display
    love.graphics.setFont(Cache.members.font["defaultBold"])
    local lastLineWidth = love.graphics.getLineWidth()
    love.graphics.setLineWidth(2)
    for i = 1, #gameplayState.judgements do
        local maxTime = 160
        local midPoint = 625 + 200
        local halfHeight = 400 / 2

        local startX = 1030
        local endX = 1030 + 740

        -- Draw lines based on judgement times (positive)
        local judgement = gameplayState.judgements[i]
        love.graphics.setColor(judgement.colour)
        local normalizedTime = judgement.time / maxTime
        local y = midPoint + (normalizedTime * halfHeight)
        local textX = startX - 60
        love.graphics.print(string.format("%.2f", judgement.time), textX, y - 6)

        love.graphics.line(startX, y, endX, y)

        -- Draw lines based on judgement times (negative)
        normalizedTime = -judgement.time / maxTime
        y = midPoint + (normalizedTime * halfHeight)
        love.graphics.print(string.format("%.2f", -judgement.time), textX, y - 6)
        love.graphics.line(startX, y, endX, y)
    end
    love.graphics.setLineWidth(lastLineWidth)

    local lastPointSize = love.graphics.getPointSize()
    love.graphics.setPointSize(5)
    for i, timing in ipairs(timings) do
        local colour = gameplayState.judgements[6].colour
        for _, judge in ipairs(gameplayState.judgements) do
            if math.abs(timing.time) <= judge.time then
                colour = judge.colour
                break
            end
        end
        love.graphics.setColor(colour)
        local pert = timing.musicTime / args.songLength
        local width = 740
        local x = 1030 + width * pert
        local midPoint = 625 + 200
        local maxTime = 160 
        local halfHeight = 400 / 2
        local normalizedTime = timing.time / maxTime
        local y = midPoint + (normalizedTime * halfHeight)
        y = math.clamp(605, y, 605 + 440)
        --[[ love.graphics.points(x, y) ]]
        love.graphics.circle("fill", x, y, 2)
    end
    love.graphics.setPointSize(lastPointSize)

    love.graphics.setFont(Cache.members.font["defaultBoldX2.5"])
    love.graphics.setColor(1, 1, 1)

    love.graphics.printf(localize("Results for ") .. (songname or "UnknownSong") .. " on " .. (diffname or "UnknownDiff"), 15, 200, 1920, "left")
    -- ^ Idk where else to put this rn

    love.graphics.setColor(1, 1, 1)

    love.graphics.setFont(lastFont)
end

return ResultsScreen