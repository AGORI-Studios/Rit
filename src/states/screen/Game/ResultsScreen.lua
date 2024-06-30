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
    curBlur = {1}
    updatingShader = true
    animatedTimings = {}

    args = {...}
    args = args[1]
    states.game.Gameplay.background = love.graphics.newImage("defaultSongs/FreedomDive/background desuuu.jpg")
    bg = states.game.Gameplay.background and
            states.game.Gameplay.background.image or
            states.game.Gameplay.background

    songname = __title
    diffname = __diffName

    score, acc, misses, rating = math.round(args.score), args.accuracy, arg.misses, args.rating
    combo = args.maxCombo
    judgeCounters = args.judgements

    timings = args.timings or {}

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
    love.graphics.printf(score, 1450, 465, 250, "center")

    love.graphics.setColor(0.3, 0.3, 0.3, 1)
    love.graphics.rectangle("fill", 125, 600, 830, 450, 15, 15)
    love.graphics.rectangle("fill", 965, 600, 830, 450, 15, 15)

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(localize("Your judgements will draw here when i actually add that lol"), 130, 605, 820, "left")
    love.graphics.printf(localize("Your timings will display on a graphy-like thing here"), 970, 605, 820, "left")

    love.graphics.printf(localize("Results for ") .. (songname or "UnknownSong") .. " on " .. (diffname or "UnknownDiff"), 15, 200, 1920, "left")
    -- ^ Idk where else to put this rn

    love.graphics.setColor(1, 1, 1)
end

return ResultsScreen