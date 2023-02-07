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
                -- 7K CHART!!! Reloading skin for 7k!!!

                notesize = skinJson["skin"]["7k"]["note size"]
                notesize = tonumber(notesize)
                antiAliasing = skinJson["skin"]["7k"]["antialiasing"]

                if antiAliasing then 
                    love.graphics.setDefaultFilter("nearest", "nearest")
                else
                    love.graphics.setDefaultFilter("linear", "linear")
                end

                hitsound = love.audio.newSource(skinFolder .. "/" .. skinJson["skin"]["7k"]["hitsound"]:gsub('"', ""), "static")
                hitsound:setVolume(tonumber(skinJson["skin"]["7k"]["hitsound volume"]))
                hitsoundCache = { -- allows for multiple hitsounds to be played at once
                    hitsound:clone()
                }

                receptors[1] = {graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["receptor 1 unpressed"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["receptor 1 pressed"]:gsub('"', "")), 0}
                receptors[2] = {graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["receptor 2 unpressed"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["receptor 2 pressed"]:gsub('"', "")), 0}
                receptors[3] = {graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["receptor 3 unpressed"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["receptor 3 pressed"]:gsub('"', "")), 0}
                receptors[4] = {graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["receptor 4 unpressed"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["receptor 4 pressed"]:gsub('"', "")), 0}
                receptors[5] = {graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["receptor 5 unpressed"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["receptor 5 pressed"]:gsub('"', "")), 0}
                receptors[6] = {graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["receptor 6 unpressed"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["receptor 6 pressed"]:gsub('"', "")), 0}
                receptors[7] = {graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["receptor 7 unpressed"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["receptor 7 pressed"]:gsub('"', "")), 0}

                noteImgs = {
                    {graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["note 1"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["note 1 hold"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["note 1 hold end"]:gsub('"', ""))},
                    {graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["note 2"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["note 2 hold"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["note 2 hold end"]:gsub('"', ""))},
                    {graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["note 3"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["note 3 hold"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["note 3 hold end"]:gsub('"', ""))},
                    {graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["note 4"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["note 4 hold"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["note 4 hold end"]:gsub('"', ""))},
                    {graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["note 5"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["note 5 hold"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["note 5 hold end"]:gsub('"', ""))},
                    {graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["note 6"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["note 6 hold"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["note 6 hold end"]:gsub('"', ""))},
                    {graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["note 7"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["note 7 hold"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["note 7 hold end"]:gsub('"', ""))}
                }

                judgementImages = { -- images for the judgement text
                    ["Miss"] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["judgements"]["MISS"]:gsub('"', "")),
                    ["Good"] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["judgements"]["GOOD"]:gsub('"', "")),
                    ["Great"] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["judgements"]["GREAT"]:gsub('"', "")),
                    ["Perfect"] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["judgements"]["PERFECT"]:gsub('"', "")),
                    ["Marvellous"] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["judgements"]["MARVELLOUS"]:gsub('"', "")),
                }

                for i = 1, 6 do
                    comboImages[i] = {}
                    for j = 0, 9 do
                        comboImages[i][j] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["combo"]["COMBO" .. j]:gsub('"', ""))
                        comboImages[i][j].x = push.getWidth() / 2+325-275 + skinJson["skin"]["rating position"]["x"]
                        comboImages[i][j].x = comboImages[i][j].x - (i - 1) * (comboImages[i][j]:getWidth() - 5) + 25
                        comboImages[i][j].y = push.getHeight() / 2 + skinJson["skin"]["rating position"]["y"] + 50
                    end
                end
            
                for k, v in pairs(judgementImages) do
                    v.x = push.getWidth() / 2+325-275 + skinJson["skin"]["rating position"]["x"]
                    v.y = push.getHeight() / 2 + skinJson["skin"]["rating position"]["y"]
                end

                for i = 1, 7 do charthits[i] = {} end
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