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
return {
    enter = function()
        now = os.time()
        -- offset is in milliseconds
        audioOffset = settings.settings.audioOffset
        offsetTimer = 0
        -- the bpm is 1 tick every tenth of a second
        beatHandler.setBPM(60)

        audio = love.audio.newSource("audio/offsetTest.ogg", "static")
        audio:setLooping(true)

        beatHandler.forceBeat()

        circSize = {50}

        presence = {
            state = "Setting their audio offset",
            largeImageKey = "totallyreallogo",
            largeImageText = "Rit"..(__DEBUG__ and " DEBUG MODE" or ""),
            startTimestamp = now
        }
    end,

    update = function(self, dt)
        offsetTimer = offsetTimer + 1000 * dt
        if not audio:isPlaying() then
            if offsetTimer >= math.abs(audioOffset) then
                audio:play()
            end
        end
        beatHandler.update(dt)
        if beatHandler.onBeat() then 
            Timer.tween((60/beatHandler.bpm) / 8, circSize, {100}, "out-quad", function()
                Timer.tween((60/beatHandler.bpm) / 4, circSize, {50}, "in-quad")
            end)
        end
    end,

    keypressed = function(self, key)
    end,

    draw = function()
        love.graphics.circle("fill", graphics.getWidth() / 2, graphics.getHeight() / 2, circSize[1])
    end,

    leave = function()
        audio:stop()
        audio = nil
        offsetTimer = nil
        circSize = nil
        audioOffset = nil
    end
}