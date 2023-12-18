--@name math.round
--@description Rounds a number to the nearest integer
--@param num number
--@param numDecimalPlaces number
--@return number
function math.round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

--@name math.clamp
--@description Clamps a number between a minimum and a maximum value
--@param low number
--@param n number
--@param high number
--@return number
function math.clamp(low, n, high)
    return math.min(math.max(low, n), high)
end

--@name math.sign
--@description Returns the sign of a number
--@param n number
--@return number
function math.sign(n)
    return n > 0 and 1 or n < 0 and -1 or 0
end

--@name math.distance
--@description Returns the distance between two points
--@param x1 number
--@param y1 number
--@param x2 number
--@param y2 number
--@return number
function math.distance(x1, y1, x2, y2)
    return math.sqrt((x2-x1) ^ 2 + (y2-y1) ^ 2)
end

--@name math.angle
--@description Returns the angle between two points
--@param x1 number
--@param y1 number
--@param x2 number
--@param y2 number
--@return number
function math.angle(x1, y1, x2, y2)
    return math.atan2(y2 - y1, x2 - x1)
end

--@name math.remapToRange
--@description Remaps a number from one range to another
--@param value number
--@param from1 number
--@param to1 number
--@param from2 number
--@param to2 number
--@return number
function math.remapToRange(value, from1, to1, from2, to2)
    return (value - from1) / (to1 - from1) * (to2 - from2) + from2
end

--@name math.lerp
--@description Linearly interpolates between two numbers
--@param a number
--@param b number
--@param t number
--@return number
function math.lerp(a, b, t)
    return a + (b - a) * t
end

--@name math.fpsLerp
--@description Linearly interpolates between two numbers, taking into account the time between frames
--@param a number
--@param b number
--@param t number
--@param dt number
--@return number
function math.fpsLerp(a, b, t, dt)
    return math.lerp(a, b, 1 - math.exp(-t * dt))
end