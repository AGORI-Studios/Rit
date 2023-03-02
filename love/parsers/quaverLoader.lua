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
function quaverLoader.load(chart)
    -- read the first line of the file
    curChart = "Quaver"
    local file = love.filesystem.read(chart)

    for line in love.filesystem.lines(chart) do
        lineCount = lineCount + 1
        if line:find("AudioFile:") then
            curLine = line
            local audioPath = curLine
            audioPath = audioPath:gsub("AudioFile: ", "")
            audioPath = "song/" .. audioPath
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
                startTime = tonumber(startTime)
            end
            if line:find("Bpm:") then 
                curLine = line
                bpm = curLine
                bpm = bpm:gsub("Bpm: ", "")
                bpm = tonumber(bpm)

                table.insert(bpmEvents, {startTime, bpm})
                beatHandler.setBPM(tonumber(bpm) or 120)
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
                local oldNote
                if #charthits[lane] > 0 then
                    oldNote = charthits[lane][#charthits[lane]]
                end
                local hitObj = hitObject(startTime, lane, oldNote)
                table.insert(charthits[lane], hitObj)
            end
            if line:find("  EndTime: ") then
                curLine = line
                endTime = curLine
                endTime = endTime:gsub("  EndTime: ", "")
                local length = tonumber(endTime) - startTime
                endTime = tonumber(endTime)

                local susLength = length / beatHandler.stepCrochet
                local floorSus = math.floor(susLength)
                if floorSus > 0 then 
                    for susNote = 0, floorSus+1 do 
                        local oldNote = charthits[lane][#charthits[lane]]

                        local holdObj = hitObject(
                            startTime + (beatHandler.stepCrochet * (susNote + 1)) + (beatHandler.stepCrochet / math.roundDecimal(speed, 2)),
                            lane,
                            oldNote,
                            true
                        )
                        table.insert(charthits[lane], holdObj)
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
            audioFile:play()
        end
    )
    
end

return quaverLoader