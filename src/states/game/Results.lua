local Results = state()

local args, now

local scorings, songInfo, died

local scoreTXT = ""

local ratings = {
    {name = "SS", acc = 100},
    {name = "S", acc = 90},
    {name = "A", acc = 80},
    {name = "B", acc = 60},
    {name = "C", acc = 40},
    {name = "D", acc = 10},
    {name = "F", acc = 0}
}

local curRating = "F"

function Results:enter(_, ...)
    args = {...}
    now = os.time()

    if not love.filesystem.getInfo("results") then
        love.filesystem.createDirectory("results")
    end

    scorings = args[1]
    songInfo = args[2]
    died = args[3]

    scoreTXT = [[
Score: %d
Accuracy: %d%%
Rating: %s
    ]]

    curRating = "F"

    if not died then
        for i = #ratings, 1, -1 do
            if (scorings.accuracy >= ratings[i].acc) then
                curRating = ratings[i].name
                break
            end
        end
    end
    local scoreS = scorings.score
    local accS = scorings.accuracy

    local tweenedAcc = {0}

    points = {}
    pointColors = {}
    --todo, points for accuracy
end

function Results:update(dt)

end

function Results:draw()
    love.graphics.setColor(1,1,1,1)
    love.graphics.printf(
        string.format(
            scoreTXT,
            scorings.score,
            scorings.accuracy,
            curRating
        ),
        0, 0,
        __inits.__GAME_WIDTH,
        "center",
        0, 3, 3
    )
    love.graphics.setColor(1,1,1,1)
end

return Results