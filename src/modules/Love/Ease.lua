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

function love.ease.inCubic(t, b, c, d)
    t = t / d
    return c * t * t * t + b
end

function love.ease.outCubic(t, b, c, d)
    t = t / d - 1
    return c * (t * t * t + 1) + b
end

function love.ease.inOutCubic(t, b, c, d)
    t = t / d * 2
    if t < 1 then
        return c / 2 * t * t * t + b
    else
        t = t - 2
        return c / 2 * (t * t * t + 2) + b
    end
end

function love.ease.inQuart(t, b, c, d)
    t = t / d
    return c * t * t * t * t + b
end

function love.ease.outQuart(t, b, c, d)
    t = t / d - 1
    return -c * (t * t * t * t - 1) + b
end

function love.ease.inOutQuart(t, b, c, d)
    t = t / d * 2
    if t < 1 then
        return c / 2 * t * t * t * t + b
    else
        t = t - 2
        return -c / 2 * (t * t * t * t - 2) + b
    end
end

function love.ease.inQuint(t, b, c, d)
    t = t / d
    return c * t * t * t * t * t + b
end

function love.ease.outQuint(t, b, c, d)
    t = t / d - 1
    return c * (t * t * t * t * t + 1) + b
end

function love.ease.inOutQuint(t, b, c, d)
    t = t / d * 2
    if t < 1 then
        return c / 2 * t * t * t * t * t + b
    else
        t = t - 2
        return c / 2 * (t * t * t * t * t + 2) + b
    end
end

function love.ease.inSine(t, b, c, d)
    return -c * math.cos(t / d * (math.pi / 2)) + c + b
end

function love.ease.outSine(t, b, c, d)
    return c * math.sin(t / d * (math.pi / 2)) + b
end

function love.ease.inOutSine(t, b, c, d)
    return -c / 2 * (math.cos(math.pi * t / d) - 1) + b
end

function love.ease.inExpo(t, b, c, d)
    if t == 0 then
        return b
    else
        return c * 2 ^ (10 * (t / d - 1)) + b - c * 0.001
    end
end

function love.ease.outExpo(t, b, c, d)
    if t == d then
        return b + c
    else
        return c * 1.001 * (-2 ^ (-10 * t / d) + 1) + b
    end
end

function love.ease.inOutExpo(t, b, c, d)
    if t == 0 then
        return b
    elseif t == d then
        return b + c
    else
        t = t / d * 2
        if t < 1 then
            return c / 2 * 2 ^ (10 * (t - 1)) + b - c * 0.0005
        else
            t = t - 1
            return c / 2 * 1.0005 * (-2 ^ (-10 * t) + 2) + b
        end
    end
end

function love.ease.inCirc(t, b, c, d)
    t = t / d
    return(-c * (math.sqrt(1 - t * t) - 1) + b)
end

function love.ease.outCirc(t, b, c, d)
    t = t / d - 1
    return(c * math.sqrt(1 - t * t) + b)
end

function love.ease.inOutCirc(t, b, c, d)
    t = t / d * 2
    if t < 1 then
        return -c / 2 * (math.sqrt(1 - t * t) - 1) + b
    else
        t = t - 2
        return c / 2 * (math.sqrt(1 - t * t) + 1) + b
    end
end