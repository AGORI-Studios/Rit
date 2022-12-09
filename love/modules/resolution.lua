--[[----------------------------------------------------------------------------

This file is apart of Rit; a free and open sourced rhythm game made with LÖVE.

Copyright (C) 2022 GuglioIsStupid

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

local resolution = {}
local scale = {sx = 1, sy = 1}
local offset = {x = 0, y = 0}
local gameWidth, gameHeight = 1920, 1080
local gameCanvas = love.graphics.newCanvas(gameWidth, gameHeight)

-- available settings are "normal" (pixel-perfect), stretched, scaleX, and scaleY, normalWidth, and normalHeight
-- scaleX only scales the width, scaleY only scales the height
-- normalWidth and normalHeight are the width and height of the game in "normal" mode
-- "normal" is the default

local function setValues(w, h, gw, gh, settings)
    gameWidth = gw or 1920
    gameHeight = gh or 1080
    w = w or love.graphics.getWidth()
    h = h or love.graphics.getHeight()
    settings = settings or {_type = "normal"}

    scale = {sx = 1, sy = 1}
    offset = {x = 0, y = 0}

    gameCanvas = love.graphics.newCanvas(gameWidth, gameHeight)

    if settings._type == "normal" then
        local normalWidth = settings.normalWidth or gameWidth
        local normalHeight = settings.normalHeight or gameHeight
        scale.sx = w / normalWidth
        scale.sy = h / normalHeight
        offset.x = (w - gameWidth * scale.sx) / 2
        offset.y = (h - gameHeight * scale.sy) / 2

    elseif settings._type == "stretched" then

        scale.sx = w / gameWidth
        scale.sy = h / gameHeight

    elseif settings._type == "scaleX" then

        scale.sx = w / gameWidth
        scale.sy = scale.sx
        offset.y = (h - gameHeight * scale.sy) / 2

    elseif settings._type == "scaleY" then

        scale.sy = h / gameHeight
        scale.sx = scale.sy
        offset.x = (w - gameWidth * scale.sx) / 2

    else
        error("Invalid settings")
    end

    return scale, offset

end

function resolution.setup(wWidth, wHeight, width, height, settings)
    scale, offset = setValues(wWidth, wHeight, width, height, settings)
end

function resolution.getScale()
    return scale
end

function resolution.getOffset()
    return offset
end

function resolution.getWidth()
    return gameWidth
end

function resolution.getHeight()
    return gameHeight
end



function resolution.resize(wWidth, wHeight, width, height, settings)
    scale, offset = setValues(wWidth, wHeight, width, height, settings)
end

function resolution.start()
    love.graphics.push()
    love.graphics.scale(scale.sx, scale.sy)
    love.graphics.translate(offset.x, offset.y)
    love.graphics.setCanvas(gameCanvas)
    love.graphics.clear()
end

function resolution.stop()
    love.graphics.setCanvas()
    love.graphics.pop()
    love.graphics.draw(gameCanvas, offset.x, offset.y, 0, scale.sx, scale.sy)
end

return resolution
