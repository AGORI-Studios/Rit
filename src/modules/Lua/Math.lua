--[[----------------------------------------------------------------------------

This file is apart of Rit; a free and open sourced rhythm game made with LÖVE.

Copyright (C) 2023 GuglioIsStupid

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

------------------------------------------------------------------------------]]

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

--@name math.fastSin
--@description Returns the sine of a number, faster than math.sin but less accurate
--@param n number
--@return number
function math.fastSin(n)
    local n = n * 0.3183098862
    if n > 1 then
        n = n - bit.rshift(bit.lshift(math.ceil(n), 1), 1) * 2
    elseif n < -1 then
        n = n + bit.rshift(bit.lshift(math.ceil(-n), 1), 1) * 2
    end
    
    if n > 0 then
        return n * (3.1 + n * (0.5 + n * (-7.2 + n * 3.6)))
    else
        return n * (3.1 - n * (0.5 + n * (7.2 - n * 3.6)))
    end
end

--@name math.fastCos
--@description Returns the cosine of a number, faster than math.cos but less accurate
--@param n number
--@return number
function math.fastCos(n)
    return math.fastSin(n + 1.570796327)
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