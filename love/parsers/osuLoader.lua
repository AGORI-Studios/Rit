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

local osuLoader = {}

function osuLoader.getDiff(chart)
    songSpeed = 1
    charthits = {}
    for i = 1, 4 do
        charthits[i] = {}
    end
    bpmEvents = {}
    chartEvents = {}
    osuLoader.load(chart, "",  true) -- Run through the chart once to get the difficulty
    return DiffCalc:CalculateDiff()
end

function osuLoader.getBpm(line)
    -- https://github.com/semyon422/chartbase/blob/507866709138225c200ed8c360424d752f2e5981/osu/Osu.lua#LL100C41-L100C41
    local split = line:split(",")
    local tp = {}

    tp.offset = tonumber(split[1])
    tp.beatLength = tonumber(split[2])

	tp.beatLength = math.abs(tp.beatLength)

    -- get bpm 
    if tp.beatLength > 0 then
        bpm = 60 / tp.beatLength
    elseif tp.beatLength < 0 then
        bpm = 60 / (tp.beatLength * -1)
    else
        bpm = 120
    end

    return bpm
end

lineCount = 0
function osuLoader.load(chart, folderPath, forDiff)
    local forDiff = forDiff or false
    curChart = "osu!"
    local file = love.filesystem.read(chart)
    lines = love.filesystem.lines(chart)
    local readChart = false
    if not forDiff then
        modscript.loadScript(folderPath)
    end

    loadSkin("4k")

    for line in lines do 
        lineCount = lineCount + 1
        if line:find("AudioFilename: ") and not forDiff then
            curLine = line
            local audioPath = curLine:gsub("AudioFilename: ", "")
            audioPath = (folderPath == "" and "song/" .. audioPath or folderPath .. "/" .. audioPath)
            audioFile = love.audio.newSource(audioPath, "stream")
        end
        --[[
        if line:find("BackgroundFile:") then
            curLine = line
            local bgPath = curLine
            bgPath = bgPath:gsub("BackgroundFile: ", "")
            bgPath = (folderPath == "" and "song/" .. bgPath or folderPath .. "/" .. bgPath)
            tryExcept(function()
                bgFile = love.graphics.newImage(bgPath)
            end, function()
                bgFile = nil
            end)
        end
        --]]
        -- background is found in '0,0,"background desuuu.jpg",0,0', the numbers can and will change
        if line:find("0,0,") and not forDiff then 
            local bgPath = line:match("0,0,\"([^\"]+)\"") or ""
            bgPath = (folderPath == "" and "song/" .. bgPath or folderPath .. "/" .. bgPath)
            tryExcept(function()
                bgFile = graphics.newImage(bgPath)
            end, function()
                bgFile = nil
            end)
        end

        mode = "Keys4"
        bpm = 0
        if line:find("[HitObjects]") then 
            readChart = true
        end 
        if line:find(",") then 
            local x, _, startTime, _, _, endtime = line:match("([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+)") -- _ is used to ignore the values we don't need
            x = tonumber(x) or 128
            if x < 512 then
                curLine = line
                lane = x / 128
                lane = math.floor(lane)
                startTime = tonumber((startTime or 0)) / (songSpeed or 1)
                hitSound = hitSound
                if lane > 4 then
                    debug.print("warn", "This is not a 4k chart!\nSupport for 5k+ charts will be added in the future.")
                    break
                end
                
                if startTime == nil then 
                    startTime = 0
                end
                if startTime ~= 0 then
                    charthits[lane + 1][#charthits[lane+1] + 1] = {startTime, 0, 1, false}
                    -- check if the previous note has the same start time
                    if charthits[lane + 1][#charthits[lane+1] - 1] ~= nil then 
                        if charthits[lane + 1][#charthits[lane+1] - 1][1] == startTime then 
                            -- remove the previous note
                            charthits[lane + 1][#charthits[lane+1] - 1] = nil
                        end
                    end
                    if endtime then 
                        -- get the first number from 0:0:0:0 from the endtime
                        endtime = endtime:match("([^:]+)")
                        endtime = tonumber(endtime) or 0
                        length = endtime - startTime
                        if length ~= startTime then 
                            for i = 1, length, noteImgs[lane+1][2]:getHeight()/2 do 
                                if i + noteImgs[lane+1][2]:getHeight()/2 < length then 
                                    charthits[lane+1][#charthits[lane+1] + 1] = {startTime+i, 0, lane, true}
                                else
                                    charthits[lane+1][#charthits[lane+1] + 1] = {startTime+i, 0, lane, true, true}
                                end
                            end
                        end
                    end
                end
            end
        end

        -- go through the chart and remove all overlapping notes (Can't be hold or end)
    end
    for i = 1, 4 do
        table.sort(charthits[i], function(a, b)
            if a and b then
                return a[1] < b[1]
            else
                return false
            end
        end)

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
    if not forDiff then
        state.switch(game)
        musicTimeDo = true
    end
end

return osuLoader