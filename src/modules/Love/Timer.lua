function love.timer.getMicroTime()
    return love.timer.getTime() * 1000
end

function love.timer.getMSDelta()
    return love.timer.getDelta() * 1000
end

function love.timer.getAverageMSDelta()
    return love.timer.getAverageDelta() * 1000
end