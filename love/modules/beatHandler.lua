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
-- blah blah i made this code i do what i want with it
-- its simple and easy to use
local beatHandler = {}

beatHandler.beat = 0
beatHandler.beatTime = 0

beatHandler.bpm = 100

beatHandler.crochet = (60/beatHandler.bpm) * 1000
beatHandler.stepCrochet = beatHandler.crochet / 4

beatHandler.lastBeat = 0
beatHandler.curBeat = 0
beatHandler.isBeatHit = false

function beatHandler.setBPM(bpm)
    bpm = bpm or 100
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
    beatHandler.isBeatHit = false
    beatHandler.curBeat = math.floor((musicTime / 1000) * (beatHandler.bpm / 60))

    if math.abs(beatHandler.curBeat) > math.abs(beatHandler.lastBeat) then
        beatHandler.isBeatHit = true
        beatHandler.beat = beatHandler.beat + 1
        beatHandler.lastBeat = beatHandler.curBeat
    end
end

function beatHandler.reset()
    beatHandler.beat = 0
    beatHandler.beatTime = 0
    beatHandler.lastBeat = 0
    beatHandler.curBeat = 0
end

function beatHandler.onBeat()
    return beatHandler.isBeatHit
end

function beatHandler.setBeat(beat)
    beatHandler.beat = beat
end

function beatHandler.onStep()
    return beatHandler.beatTime % beatHandler.stepCrochet == 0
end

function beatHandler.onBeatNumber(beatNumber)
    return beatHandler.beat % beatNumber == 0 and beatHandler.onBeat()
end

function beatHandler.onStepNumber(stepNumber)
    return beatHandler.beatTime % (beatHandler.stepCrochet * stepNumber) == 0 and beatHandler.onStep()
end

return beatHandler