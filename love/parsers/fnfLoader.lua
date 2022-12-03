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

json = require "lib.json"

local fnfLoader = {}

function fnfLoader.load(chart, isPlayer)
    curChart = "FNF"
    chart = json.decode(love.filesystem.read(chart))
    chart = chart["song"]

    songName = chart["song"]:gsub(" ", "-")
    songName = string.lower(songName)

    mode = "Keys4"

    for i = 1, #chart.notes do
        bpm = chart.notes[i].bpm
        
        if bpm then break end
    end
    if not bpm then
        bpm = 100
    end

    if chart.needsVoices then
        voices = love.audio.newSource("songs/fnf/" .. songName .. "/Voices.ogg", "stream")
    end
    audioFile = love.audio.newSource("songs/fnf/" .. songName .. "/Inst.ogg", "stream")

    for i = 1, #chart.notes do 
        eventBpm = chart.notes[i].bpm

        for j = 1, #chart.notes[i].sectionNotes do
            noteType = chart.notes[i].sectionNotes[j][2]
            if isPlayer then 
                if chart.notes[i].mustHitSection then
                    if noteType <= 3 and noteType >= 0 then
                        noteTime = chart.notes[i].sectionNotes[j][1]
                        noteLength = chart.notes[i].sectionNotes[j][3]

                        table.insert(charthits[noteType+1], {noteTime, 0, 1, false, false})

                        for i = 1, noteLength, 95/2/speed do
                            if i + 95/2/speed < noteLength then
                                charthits[noteType+1][#charthits[noteType+1] + 1] = {noteTime+i, 0, 1, true}
                            else
                                charthits[noteType+1][#charthits[noteType+1] + 1] = {noteTime+i, 0, 1, true, true}
                            end
                        end
                    end
                else
                    if noteType >= 4 and noteType <= 7 then 
                        noteTime = chart.notes[i].sectionNotes[j][1]
                        noteLength = chart.notes[i].sectionNotes[j][3]

                        table.insert(charthits[noteType-3], {noteTime, 0, 1, false, false})

                        for i = 1, noteLength, 95/2/speed do
                            if i + 95/2/speed < noteLength then
                                charthits[noteType-3][#charthits[noteType-3] + 1] = {noteTime+i, 0, 1, true}
                            else
                                charthits[noteType-3][#charthits[noteType-3] + 1] = {noteTime+i, 0, 1, true, true}
                            end
                        end
                    end
                end
            else
                if chart.notes[i].mustHitSection then
                    if noteType >= 4 and noteType <= 7 then 
                        noteTime = chart.notes[i].sectionNotes[j][1]
                        noteLength = chart.notes[i].sectionNotes[j][3]

                        table.insert(charthits[noteType-3], {noteTime, 0, 1, false, false})

                        for i = 1, noteLength, 95/2/speed do
                            if i + 95/2/speed < noteLength then
                                charthits[noteType-3][#charthits[noteType-3] + 1] = {noteTime+i, 0, 1, true}
                            else
                                charthits[noteType-3][#charthits[noteType-3] + 1] = {noteTime+i, 0, 1, true, true}
                            end
                        end
                    end
                else
                    if noteType <= 3 and noteType >= 0 then
                        noteTime = chart.notes[i].sectionNotes[j][1]
                        noteLength = chart.notes[i].sectionNotes[j][3]

                        table.insert(charthits[noteType+1], {noteTime, 0, 1, false, false})

                        for i = 1, noteLength, 95/2/speed do
                            if i + 95/2/speed < noteLength then
                                charthits[noteType+1][#charthits[noteType+1] + 1] = {noteTime+i, 0, 1, true}
                            else
                                charthits[noteType+1][#charthits[noteType+1] + 1] = {noteTime+i, 0, 1, true, true}
                            end
                        end
                    end
                end
            end
        end
        for i = 1, 4 do 
            table.sort(charthits[i], function(a, b) return a[1] < b[1] end)
        end
    end
    Timer.after(2,
        function()
            musicTimeDo = true
        end
    )
end                    

return fnfLoader