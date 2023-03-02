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
    chart = json.decode(love.filesystem.read(chart)).song

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

    noteData = chart.notes

    for _, section in ipairs(noteData) do 
        for _, songNotes in ipairs(section.sectionNotes) do 
            local daStrumTime = songNotes[1]
            local daNoteData = songNotes[2]
            local gottaHitNote = section.mustHitSection

            if (not gottaHitNote and daNoteData >= 4) or (gottaHitNote and daNoteData <= 3) then
                daNoteData = daNoteData % 4 + 1

                local oldNote = nil 
                if #charthits[daNoteData] > 0 then 
                    oldNote = charthits[daNoteData][#charthits[daNoteData]]
                end

                local hitObj = hitObject(daStrumTime, daNoteData, oldNote)
                hitObj.sustainLength = tonumber(songNotes[3]) or 0

                local susLength = hitObj.sustainLength / beatHandler.stepCrochet
                local floorSus = math.floor(susLength)

                table.insert(charthits[daNoteData], hitObj)

                if floorSus > 0 then 
                    for susNote = 0, floorSus+1 do 
                        local oldNote = charthits[daNoteData][#charthits[daNoteData]]

                        --local holdObj = hitObject(daStrumTime + (beatHandler.getStepCrochet() * susNote + 1) + (beatHandler.getStepCrochet() / math.roundDecimal(speed, 2)), daNoteData, oldNote, true)
                        local holdObj = hitObject(
                            daStrumTime + (beatHandler.stepCrochet * (susNote + 1)) + (beatHandler.stepCrochet / math.roundDecimal(speed, 2)),
                            daNoteData,
                            oldNote,
                            true
                        )
                        table.insert(charthits[daNoteData], holdObj)
                    end
                end
            end
        end
    end

    for i = 1, 4 do 
        table.sort(charthits[i], function(a, b) return a.time < b.time end)

        local offset = 0

        for j = 2, #charthits[i] do 
            local index = j - offset

            if charthits[i][index].time == charthits[i][index-1].time then 
                table.remove(charthits[i], index)
                offset = offset + 1
            end
        end
    end

    Timer.after(2,
        function()
            state.switch(game)
            musicTimeDo = true

            collectgarbage()
            if needsVoices then
                voices:play()
            end
            audioFile:play()
        end
    )
end                    

return fnfLoader