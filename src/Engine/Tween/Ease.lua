---@diagnostic disable: deprecated
---@class Ease
local Ease = {}

Ease.PI2 = math.pi / 2
Ease.EL = 2 * math.pi / 0.45
Ease.B1 = 1 / 2.75
Ease.B2 = 2 / 2.75
Ease.B3 = 1.5 / 2.75
Ease.B4 = 2.5 / 2.75
Ease.B5 = 2.25 / 2.75
Ease.B6 = 2.625 / 2.75
Ease.ELASTIC_AMPLITUDE = 1
Ease.ELASTIC_PERIOD = 0.4

function Ease.linear(t)
    return t
end

function Ease.quadIn(t)
    return t * t
end

function Ease.quadOut(t)
    return -t * (t - 2)
end

function Ease.quadInOut(t)
    if t <= 0.5 then
        return t * t * 2
    else
        t = t * 2 - 1
        return 1 - t * t * 2
    end
end

function Ease.cubeIn(t)
    return t * t * t
end

function Ease.cubeOut(t)
    t = t - 1
    return 1 + t * t * t
end

function Ease.cubeInOut(t)
    if t <= 0.5 then
        return t * t * t * 4
    else
        t = t * 2 - 1
        return 1 + t * t * t * 4
    end
end

function Ease.quartIn(t)
    return t * t * t * t
end

function Ease.quartOut(t)
    t = t - 1
    return 1 - t * t * t * t
end

function Ease.quartInOut(t)
    if t <= 0.5 then
        return t * t * t * t * 8
    else
        t = t * 2 - 2
        return (1 - t * t * t * t) / 2 + 0.5
    end
end

function Ease.quintIn(t)
    return t * t * t * t * t
end

function Ease.quintOut(t)
    t = t - 1
    return t * t * t * t * t + 1
end

function Ease.quintInOut(t)
    t = t * 2
    if t < 1 then
        return t * t * t * t * t / 2
    else
        t = t - 2
        return (t * t * t * t * t + 2) / 2
    end
end

function Ease.smoothStepIn(t)
    return 2 * Ease.smoothStepInOut(t / 2)
end

function Ease.smoothStepOut(t)
    return 2 * Ease.smoothStepInOut(t / 2 + 0.5) - 1
end

function Ease.smoothStepInOut(t)
    return t * t * (t * -2 + 3)
end

function Ease.smootherStepIn(t)
    return 2 * Ease.smootherStepInOut(t / 2)
end

function Ease.smootherStepOut(t)
    return 2 * Ease.smootherStepInOut(t / 2 + 0.5) - 1
end

function Ease.smootherStepInOut(t)
    return t * t * t * (t * (t * 6 - 15) + 10)
end

function Ease.sineIn(t)
    return -math.cos(Ease.PI2 * t) + 1
end

function Ease.sineOut(t)
    return math.sin(Ease.PI2 * t)
end

function Ease.sineInOut(t)
    return -math.cos(math.pi * t) / 2 + 0.5
end

function Ease.bounceIn(t)
    return 1 - Ease.bounceOut(1 - t)
end

function Ease.bounceOut(t)
    if t < Ease.B1 then
        return 7.5625 * t * t
    elseif t < Ease.B2 then
        t = t - Ease.B3
        return 7.5625 * t * t + 0.75
    elseif t < Ease.B4 then
        t = t - Ease.B5
        return 7.5625 * t * t + 0.9375
    else
        t = t - Ease.B6
        return 7.5625 * t * t + 0.984375
    end
end

function Ease.bounceInOut(t)
    if t < 0.5 then
        return (1 - Ease.bounceOut(1 - 2 * t)) / 2
    else
        return (1 + Ease.bounceOut(2 * t - 1)) / 2
    end
end

function Ease.circIn(t)
    return -(math.sqrt(1 - t * t) - 1)
end

function Ease.circOut(t)
    return math.sqrt(1 - (t - 1) * (t - 1))
end

function Ease.circInOut(t)
    if t <= 0.5 then
        return (math.sqrt(1 - t * t * 4) - 1) / -2
    else
        t = t * 2 - 2
        return (math.sqrt(1 - t * t) + 1) / 2
    end
end

function Ease.expoIn(t)
    return math.pow(2, 10 * (t - 1))
end

function Ease.expoOut(t)
    return -math.pow(2, -10 * t) + 1
end

function Ease.expoInOut(t)
    if t < 0.5 then
        return math.pow(2, 10 * (t * 2 - 1)) / 2
    else
        return (-math.pow(2, -10 * (t * 2 - 1)) + 2) / 2
    end
end

function Ease.backIn(t)
    return t * t * (2.70158 * t - 1.70158)
end

function Ease.backOut(t)
    t = t - 1
    return 1 - t * t * (-2.70158 * t - 1.70158)
end

function Ease.backInOut(t)
    t = t * 2
    if t < 1 then
        return t * t * (2.70158 * t - 1.70158) / 2
    else
        t = t - 2
        return (1 - t * t * (-2.70158 * t - 1.70158)) / 2 + 0.5
    end
end

function Ease.elasticIn(t)
    return -(Ease.ELASTIC_AMPLITUDE * math.pow(2,
        10 * (t - 1)) * math.sin((t - (Ease.ELASTIC_PERIOD / (2 * math.pi) * math.asin(1 / Ease.ELASTIC_AMPLITUDE))) * (2 * math.pi) / Ease.ELASTIC_PERIOD))
end

function Ease.elasticOut(t)
    return (Ease.ELASTIC_AMPLITUDE * math.pow(2,
        -10 * t) * math.sin((t - (Ease.ELASTIC_PERIOD / (2 * math.pi) * math.asin(1 / Ease.ELASTIC_AMPLITUDE))) * (2 * math.pi) / Ease.ELASTIC_PERIOD)
        + 1)
end

function Ease.elasticInOut(t)
    if t < 0.5 then
        return -0.5 * (math.pow(2, 10 * (t - 0.5)) * math.sin((t - (Ease.ELASTIC_PERIOD / 4)) * (2 * math.pi) / Ease.ELASTIC_PERIOD))
    else
        return math.pow(2, -10 * (t - 0.5)) * math.sin((t - (Ease.ELASTIC_PERIOD / 4)) * (2 * math.pi) / Ease.ELASTIC_PERIOD) * 0.5 + 1
    end
end

return Ease
