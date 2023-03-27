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

local quaverLoader = {}
lineCount = 0
function quaverLoader.load(chart, folderPath)
    -- read the first line of the file
    curChart = "Quaver"
    local file = love.filesystem.read(chart)
    modscript.loadScript(folderPath)

    for line in love.filesystem.lines(chart) do
        lineCount = lineCount + 1
        if line:find("AudioFile:") then
            curLine = line
            local audioPath = curLine
            audioPath = audioPath:gsub("AudioFile: ", "")
            audioPath = (folderPath == "" and "song/" .. audioPath or folderPath .. "/" .. audioPath)
            audioFile = love.audio.newSource(audioPath, "stream")
        end
        if line:find("Mode: ") then
            modeLine = line
            mode = modeLine:gsub("Mode: ", "")
            if mode == "Keys7" then
                loadSkin("7k")
            elseif mode == "Keys4" then
                loadSkin("4k")
            end
        end
        -- if the line has "- Bpm: " in it, then it's the line with the BPM
        if line:find("Bpm:") then
            curLine = line
            bpm = curLine
            -- trim the bpm of anything that isn't a number
            bpm = bpm:gsub("%D", "")
            bpm = tonumber(bpm) or 120
        end

        if not line:find("SliderVelocities:") then
            if line:find("- StartTime: ") then -- if the line has "- StartTime: " in it, then it's the line with the note's start time
                curLine = line
                startTime = curLine
                startTime = startTime:gsub("- StartTime: ", "")
                startTime = tonumber(startTime)
            end
            if line:find("Multiplier:") then 
                curLine = line
                multiplier = curLine
                multiplier = multiplier:gsub("Multiplier: ", "")
                multiplier = tonumber(multiplier)

                table.insert(chartEvents, {startTime, multiplier})
            end
        end

        if not line:find("TimingPoints:") then 
            if line:find("- StartTime: ") then -- if the line has "- StartTime: " in it, then it's the line with the note's start time
                curLine = line
                startTime = curLine
                startTime = startTime:gsub("- StartTime: ", "")
                startTime = tonumber(startTime) / songSpeed
            end
            if line:find("Bpm:") then 
                curLine = line
                bpm = curLine
                bpm = bpm:gsub("Bpm: ", "")
                bpm = tonumber(bpm)

                table.insert(bpmEvents, {startTime, bpm})
            end
        end

        if not line:find("HitObjects:") and not line:find("HitObjects: []") then
            if line:find("- StartTime: ") then
                curLine = line
                startTime = curLine
                startTime = startTime:gsub("- StartTime: ", "")
                startTime = tonumber(startTime)
                -- get our next line
            end
            if line:find("  Lane: ") then
                -- if the next line has "- Lane: " in it, then it's the line with the lane
                curLine = line
                lane = curLine
                lane = lane:gsub("  Lane: ", "")
                lane = tonumber(lane)
                charthits[lane][#charthits[lane] + 1] = {startTime, 0, 1, false}
            end
            if line:find("  EndTime: ") then
                curLine = line
                endTime = curLine
                endTime = endTime:gsub("  EndTime: ", "")
                local length = tonumber(endTime) - startTime
                endTime = tonumber(endTime)
                    
                for i = 1, length, noteImgs[lane][2]:getHeight()/2/speed do
                    if i + noteImgs[lane][2]:getHeight()/2/speed < length then
                        charthits[lane][#charthits[lane] + 1] = {startTime+i, 0, 1, true}
                    else
                        charthits[lane][#charthits[lane] + 1] = {startTime+i, 0, 1, true, true}
                    end
                end
            end
        end
    end

    -- go through chartHits and remove all overlapping notes
    for i = 1, 4 do 
        table.sort(charthits[i], function(a, b) return a[1] < b[1] end)

        local offset = 0

        for j = 2, #charthits[i] do 
            local index = j - offset

            if charthits[i][index] ~= nil and charthits[i][index+1] ~= nil then
                if (not charthits[i][index][4] and not charthits[i][index+1][4]) then
                    if charthits[i][index+1][1] - charthits[i][index][1] < 0.1 then
                        table.remove(charthits[i], index)
                        offset = offset + 1
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

return quaverLoader