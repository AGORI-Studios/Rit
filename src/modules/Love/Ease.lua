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