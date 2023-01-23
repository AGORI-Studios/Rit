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

local beatHandler = {}

beatHandler.beat = 0
beatHandler.beatTime = 0

beatHandler.bpm = 0

beatHandler.crochet = (60/beatHandler.bpm) * 1000
beatHandler.stepCrochet = beatHandler.crochet / 4

function beatHandler.setBPM(bpm)
    bpm = bpm or 120
    beatHandler.bpm = bpm
    beatHandler.crochet = (60/bpm) * 1000
    beatHandler.stepCrochet = beatHandler.crochet / 4
end

function beatHandler.getBeat()
    return beatHandler.beat
end

function beatHandler.getBeatTime()
    return beatHandler.beatTime
end

function beatHandler.getCrochet()
    return beatHandler.crochet
end

function beatHandler.getStepCrochet()
    return beatHandler.stepCrochet
end

function beatHandler.update(dt)
    beatHandler.beatTime = beatHandler.beatTime + dt
    if beatHandler.beatTime >= 60 / beatHandler.bpm then
        beatHandler.beat = beatHandler.beat + 1
        beatHandler.beatTime = 0
    end
end

return beatHandler