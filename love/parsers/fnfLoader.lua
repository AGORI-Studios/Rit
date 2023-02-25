--[[----------------------------------------------------------------------------

This file is apart of Rit; a free and open sourced rhythm game made with LÖVE.

Copyright (C)  GuglioIsStupid

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
    loadSkin("4k")

    for i = 1, #chart.notes do
        bpm = chart.notes[i].bpm
        
        if bpm then break end
    end
    if not bpm then
        bpm = 100
    end

    local needsVoices = chart.needsVoices

    if needsVoices then
        voices = love.audio.newSource(folderPath .. "/Voices.ogg", "stream")
    end
    audioFile = love.audio.newSource(folderPath .. "/Inst.ogg", "stream")

    for i = 1, #chart.notes do 
        eventBpm = chart.notes[i].bpm

        for j = 1, #chart.notes[i].sectionNotes do
            noteType = chart.notes[i].sectionNotes[j][2]
            if isPlayer then 
                if chart.notes[i].mustHitSection then
                    if noteType <= 3 and noteType >= 0 then
                        noteTime = chart.notes[i].sectionNotes[j][1]
                        noteLength = chart.notes[i].sectionNotes[j][3]
                        noteVer = chart.notes[i].sectionNotes[j][4] or ""

                        if not table.find(fnfBlacklist, noteVer) then
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
                else
                    if noteType >= 4 and noteType <= 7 then 
                        noteTime = chart.notes[i].sectionNotes[j][1]
                        noteLength = chart.notes[i].sectionNotes[j][3]
                        noteVer = chart.notes[i].sectionNotes[j][4] or ""

                        if not table.find(fnfBlacklist, noteVer) then
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
                end
            else
                if chart.notes[i].mustHitSection then
                    if noteType >= 4 and noteType <= 7 then 
                        noteTime = chart.notes[i].sectionNotes[j][1]
                        noteLength = chart.notes[i].sectionNotes[j][3]
                        noteVer = chart.notes[i].sectionNotes[j][4] or ""

                        if not table.find(fnfBlacklist, noteVer) then
                            table.insert(charthits[noteType-3], {noteTime, 0, 1, false, false})

                            for i = 1, noteLength, noteImgs[noteType-3][2]:getHeight()/2/speed do
                                if i + noteImgs[noteType-3][2]:getHeight()/2/speed < noteLength then
                                    charthits[noteType-3][#charthits[noteType-3] + 1] = {noteTime+i, 0, 1, true}
                                else
                                    charthits[noteType-3][#charthits[noteType-3] + 1] = {noteTime+i, 0, 1, true, true}
                                end
                            end
                        end
                    end
                else
                    if noteType <= 3 and noteType >= 0 then
                        noteTime = chart.notes[i].sectionNotes[j][1]
                        noteLength = chart.notes[i].sectionNotes[j][3]
                        noteVer = chart.notes[i].sectionNotes[j][4] or ""

                        if not table.find(fnfBlacklist, noteVer) then
                            table.insert(charthits[noteType+1], {noteTime, 0, 1, false, false})

                            for i = 1, noteLength, noteImgs[noteType+1][2]:getHeight()/2/speed do
                                if i + noteImgs[noteType+1][2]:getHeight()/2/speed < noteLength then
                                    charthits[noteType+1][#charthits[noteType+1] + 1] = {noteTime+i, 0, 1, true}
                                else
                                    charthits[noteType+1][#charthits[noteType+1] + 1] = {noteTime+i, 0, 1, true, true}
                                end
                            end
                        end
                    end
                end
            end
        end
        for i = 1, 4 do 
            table.sort(charthits[i], function(a, b) return a[1] < b[1] end)

            local offset = 0

            for j = 2, #charthits[i] do 
                local index = j - offset

                if charthits[i][index] ~= nil and charthits[i][index+1] ~= nil then
                    if (not charthits[i][index][4] and not charthits[i][index+1][4]) then
                        if charthits[i][index+1][1] - charthits[i][index][1] < 0.1 then
                            debug.print("Removed overlapping note")
                            table.remove(charthits[i], index)
                            offset = offset + 1
                        end
                    end
                end
            end
        end
    end
    Timer.after(2,
        function()
            state.switch(game)
            musicTimeDo = true
        end
    )
end                    

return fnfLoader