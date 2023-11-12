--[[----------------------------------------------------------------------------

This file is apart of Rit; a free and open sourced rhythm game made with LÖVE.

Copyright (C) 2023 GuglioIsStupid

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the HitObjectpe that it will be useful,
but WITHitObjectUT ANY WARRANTY; witHitObjectut even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You sHitObjectuld have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

------------------------------------------------------------------------------]]

local malodyLoader = {}
local chart, offset

local function getTime(bpm, beat, prevOffset) 
    return (1000 * (60/bpm) * beat) + prevOffset 
end

local function getBeat(beat) 
    return beat[1] + (beat[2] / beat[3]) 
end

local function getMilliSeconds(beat, offset)
    local _i = 1

    for i = 1, #chart.time do
        if getBeat(chart.time[i].beat) >= beat then
            break
        end

        offset = getTime(chart.time[i].bpm, getBeat(chart.time[i].beat), offset)
    end

    return getTime(bpm, beat, offset)    
end

function malodyLoader.load(chart_, folderPath, forDiff)
    chart = json(love.filesystem.read(chart_))

    local meta = chart.meta

    if meta.mode ~= 0 then
        states.game.Gameplay.mode = meta.mode
    end

    if (meta.mode_ext.column and meta.mode_ext.column ~= 4) then
        states.game.Gameplay.mode = meta.mode_ext.column
    end

    -- if theres only 1 timing point, then create 1 more (copy of the first one)
    if #chart.time == 1 then
        chart.time[2] = chart.time[1]
    end

    for i, timingPoint in ipairs(chart.time) do
        if i == 1 then
            bpm = timingPoint.bpm
            crochet = (60 / bpm) * 1000
            stepCrochet = crochet / 4
        end
    end

    for i, note in ipairs(chart.note) do
        if note.type ~= 1 then
            local startTime = getMilliSeconds(getBeat(note.beat), 0)
            local endTime = note.beatEnd and getMilliSeconds(getBeat(note.beatEnd), 0) or 0
            local lane = note.column + 1

            local ho = HitObject(startTime, lane, endTime)
        else
            audioFile = love.audio.newSource(folderPath .. "/" .. note.sound, "stream")
        end
    end

    __title = chart.meta.song.title
    __diffName = chart.meta.version
end

return malodyLoader