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

lineCount = 0
function osuLoader.load(chart)
    curChart = "osu!"
    local file = love.filesystem.read(chart)
    lines = love.filesystem.lines(chart)
    local readChart = false

    loadSkin("4k")

    for line in lines do 
        lineCount = lineCount + 1
        if line:find("AudioFilename: ") then 
            curLine = line
            local audioPath = curLine:gsub("AudioFilename: ", "")
            audioPath = "song/" .. audioPath
            audioFile = love.audio.newSource(audioPath, "stream")
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
                lane = x / 128 + 1
                lane = math.floor(lane)
                startTime = tonumber(startTime)
                hitSound = hitSound
                if lane > 5 then
                    debug.print("This is not a 4k chart!\nSupport for 5k+ charts will be added in the future.")
                    break
                end
                
                if startTime == nil then 
                    startTime = 0
                end
                if startTime ~= 0 then
                    local oldNote = nil
                    if #charthits[lane] > 0 then 
                        oldNote = charthits[lane][#charthits[lane]]
                    end
                    local hitObj = hitObject(startTime, lane, oldNote)
                    table.insert(charthits[lane], hitObj)
                    
                    if endtime then 
                        -- get the first number from 0:0:0:0 from the endtime
                        endtime = endtime:match("([^:]+)")
                        endtime = tonumber(endtime) or 0
                        local susLength = (endtime - startTime)
                        hitObj.sustainLength = susLength
                        susLength = hitObj.sustainLength / beatHandler.stepCrochet
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
    end
    Timer.after(2,
        function()
            state.switch(game)
            musicTimeDo = true
            audioFile:play()
        end
    )
end

return osuLoader