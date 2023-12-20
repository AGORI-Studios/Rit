function love.math.randomFloat(min, max, ignoreNum)
    local num = love.math.random(min, max)
    while num == ignoreNum do
        num = love.math.random(min, max)
    end
    return num
end

local o_lmr = love.math.random

function love.math.random(min, max, ignoreNum)
    local num = o_lmr(min, max)
    while num == ignoreNum do
        num = o_lmr(min, max)
    end
    return num
end

function love.math.randomChoice(...)
    local args = {...}
    return args[love.math.random(1, #args)]
end

function love.math.randomChoiceIgnore(ignoreNum, ...)
    local args = {...}
    local num = love.math.random(1, #args)
    while args[num] == ignoreNum do
        num = love.math.random(1, #args)
    end
    return args[num]
end

function love.math.randomChoiceIgnoreAll(ignoreNums, ...)
    local args = {...}
    local num = love.math.random(1, #args)
    while table.contains(ignoreNums, args[num]) do
        num = love.math.random(1, #args)
    end
    return args[num]
end
