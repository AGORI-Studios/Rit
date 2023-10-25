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

