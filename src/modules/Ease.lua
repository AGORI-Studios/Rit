local PI2 = math.pi / 2

local EL = 2 * math.pi / 0.45
local B1 = 1 / 2.75
local B2 = 2 / 2.75
local B3 = 1.5 / 2.75
local B4 = 2.5 / 2.75
local B5 = 2.25 / 2.75
local B6 = 2.625 / 2.75
local ELASTIC_AMPLITUDE = 1
local ELASTIC_PERIOD = 0.4

function linear(t)
    return t
end

function quadIn(t)
    return t * t
end

function quadOut(t)
    return -t * (t - 2)
end

function quadInOut(t)
    if t <= 0.5 then
        return t * t * 2
    else
        t = t - 1
        return 1 - t * t * 2
    end
end

function cubeIn(t)
    return t * t * t
end

function cubeOut(t)
    t = t - 1
    return 1 + t * t * t
end

function cubeInOut(t)
    if t <= 0.5 then
        return t * t * t * 4
    else
        t = t - 1
        return 1 + t * t * t * 4
    end
end

function quartIn(t)
    return t * t * t * t
end

function quartOut(t)
    t = t - 1
    return 1 - t * t * t * t
end

function quartInOut(t)
    if t <= 0.5 then
        return t * t * t * t * 8
    else
        t = t * 2 - 2
        return (1 - t * t * t * t) / 2 + 0.5
    end
end

function quintIn(t)
    return t * t * t * t * t
end

function quintOut(t)
    t = t - 1
    return t * t * t * t * t + 1
end

function quintInOut(t)
    t = t * 2
    if t < 1 then
        return t * t * t * t * t / 2
    else
        t = t - 2
        return (t * t * t * t * t + 2) / 2
    end
end

function smoothStepIn(t)
    return 2 * smoothStepInOut(t / 2)
end

function smoothStepOut(t)
    return 2 * smoothStepInOut(t / 2 + 0.5) - 1
end

function smoothStepInOut(t)
    return t * t * (t * -2 + 3)
end

function smootherStepIn(t)
    return 2 * smootherStepInOut(t / 2)
end

function smootherStepOut(t)
    return 2 * smootherStepInOut(t / 2 + 0.5) - 1
end

function smootherStepInOut(t)
    return t * t * t * (t * (t * 6 - 15) + 10)
end

function sineIn(t)
    return -math.cos(PI2 * t) + 1
end

function sineOut(t)
    return math.sin(PI2 * t)
end

function sineInOut(t)
    return -math.cos(math.pi * t) / 2 + 0.5
end

function bounceIn(t)
    return 1 - bounceOut(1 - t)
end

function bounceOut(t)
    if t < B1 then
        return 7.5625 * t * t
    elseif t < B2 then
        t = t - B3
        return 7.5625 * t * t + 0.75
    elseif t < B4 then
        t = t - B5
        return 7.5625 * t * t + 0.9375
    else
        t = t - B6
        return 7.5625 * t * t + 0.984375
    end
end

function bounceInOut(t)
    if t < 0.5 then
        return (1 - bounceOut(1 - 2 * t)) / 2
    else
        return (1 + bounceOut(2 * t - 1)) / 2
    end
end

function circIn(t)
    return -(math.sqrt(1 - t * t) - 1)
end

function circOut(t)
    return math.sqrt(1 - (t - 1) * (t - 1))
end

function circInOut(t)
    if t <= 0.5 then
        return (math.sqrt(1 - t * t * 4) - 1) / -2
    else
        t = t * 2 - 2
        return (math.sqrt(1 - t * t) + 1) / 2
    end
end

function expoIn(t)
    return math.pow(2, 10 * (t - 1))
end

function expoOut(t)
    return -math.pow(2, -10 * t) + 1
end

function expoInOut(t)
    if t < 0.5 then
        return math.pow(2, 10 * (t * 2 - 1)) / 2
    else
        return (-math.pow(2, -10 * (t * 2 - 1)) + 2) / 2
    end
end

function backIn(t)
    return t * t * (2.70158 * t - 1.70158)
end

function backOut(t)
    t = t - 1
    return 1 - t * t * (-2.70158 * t - 1.70158)
end

function backInOut(t)
    t = t * 2
    if t < 1 then
        return t * t * (2.70158 * t - 1.70158) / 2
    else
        t = t - 1
        return (1 - t * t * (-2.70158 * t - 1.70158)) / 2 + 0.5
    end
end

function elasticIn(t)
    t = t - 1
    return -(ELASTIC_AMPLITUDE * math.pow(2, 10 * t) * math.sin((t - (ELASTIC_PERIOD / (2 * math.pi) * math.asin(1 / ELASTIC_AMPLITUDE))) * (2 * math.pi) / ELASTIC_PERIOD))
end

function elasticOut(t)
    return (ELASTIC_AMPLITUDE * math.pow(2, -10 * t) * math.sin((t - (ELASTIC_PERIOD / (2 * math.pi) * math.asin(1 / ELASTIC_AMPLITUDE))) * (2 * math.pi) / ELASTIC_PERIOD) + 1)
end

function elasticInOut(t)
    if t < 0.5 then
        t = t * 2 - 0.5
        return -0.5 * (math.pow(2, 10 * t) * math.sin((t - (ELASTIC_PERIOD / 4)) * (2 * math.pi) / ELASTIC_PERIOD))
    else
        t = t * 2 - 1
        return math.pow(2, -10 * t) * math.sin((t - (ELASTIC_PERIOD / 4)) * (2 * math.pi) / ELASTIC_PERIOD) * 0.5 + 1
    end
end