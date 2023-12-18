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

function love.ease.inElastic(t, b, c, d, a, p)
    if t == 0 then
        return b
    end

    t = t / d

    if t == 1 then
        return b + c
    end

    if not p then
        p = d * 0.3
    end

    local s

    if not a or a < math.abs(c) then
        a = c
        s = p / 4
    else
        s = p / (2 * math.pi) * math.asin(c / a)
    end

    t = t - 1
    return -(a * 2 ^ (10 * t) * math.sin((t * d - s) * (2 * math.pi) / p)) + b
end

function love.ease.outElastic(t, b, c, d, a, p)
    if t == 0 then
        return b
    end

    t = t / d

    if t == 1 then
        return b + c
    end

    if not p then
        p = d * 0.3
    end

    local s

    if not a or a < math.abs(c) then
        a = c
        s = p / 4
    else
        s = p / (2 * math.pi) * math.asin(c / a)
    end

    return a * 2 ^ (-10 * t) * math.sin((t * d - s) * (2 * math.pi) / p) + c + b
end

function love.ease.inOutElastic(t, b, c, d, a, p)
    if t == 0 then
        return b
    end

    t = t / d * 2

    if t == 2 then
        return b + c
    end

    if not p then
        p = d * (0.3 * 1.5)
    end

    local s

    if not a or a < math.abs(c) then
        a = c
        s = p / 4
    else
        s = p / (2 * math.pi) * math.asin(c / a)
    end

    if t < 1 then
        t = t - 1
        return -0.5 * (a * 2 ^ (10 * t) * math.sin((t * d - s) * (2 * math.pi) / p)) + b
    else
        t = t - 1
        return a * 2 ^ (-10 * t) * math.sin((t * d - s) * (2 * math.pi) / p) * 0.5 + c + b
    end
end

function love.ease.inBack(t, b, c, d, s)
    if not s then
        s = 1.70158
    end

    t = t / d
    return c * t * t * ((s + 1) * t - s) + b
end

function love.ease.outBack(t, b, c, d, s)
    if not s then
        s = 1.70158
    end

    t = t / d - 1
    return c * (t * t * ((s + 1) * t + s) + 1) + b
end

function love.ease.inOutBack(t, b, c, d, s)
    if not s then
        s = 1.70158
    end

    s = s * 1.525
    t = t / d * 2
    if t < 1 then
        return c / 2 * (t * t * ((s + 1) * t - s)) + b
    else
        t = t - 2
        return c / 2 * (t * t * ((s + 1) * t + s) + 2) + b
    end
end