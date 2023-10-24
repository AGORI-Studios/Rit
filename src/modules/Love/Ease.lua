love.ease = {}

function love.ease.linear(t, b, c, d)
    return c * t / d + b
end

function love.ease.inQuad(t, b, c, d)
    t = t / d
    return c * t * t + b
end

function love.ease.outQuad(t, b, c, d)
    t = t / d
    return -c * t * (t - 2) + b
end

function love.ease.inOutQuad(t, b, c, d)
    t = t / d * 2
    if t < 1 then
        return c / 2 * t * t + b
    else
        return -c / 2 * ((t - 1) * (t - 3) - 1) + b
    end
end

function love.ease.outInQuad(t, b, c, d)
    if t < d / 2 then
        return love.ease.outQuad(t * 2, b, c / 2, d)
    else
        return love.ease.inQuad((t * 2) - d, b + c / 2, c / 2, d)
    end
end