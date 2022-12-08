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

local osuLoader = {}

lineCount = 0
function osuLoader.load(chart)
    curChart = "osu!"
    local file = love.filesystem.read(chart)
    lines = love.filesystem.lines(chart)
    local readChart = false

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
            if x < 500 then
                curLine = line
                lane = x / 128
                lane = math.floor(lane)
                startTime = tonumber(startTime)
                hitSound = hitSound
                if lane > 4 then
                    print("This is not a 4k chart!\nSupport for 5k+ charts will be added in the future.")
                    choosingSong = true
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
                            for i = 1, length, 95/2/speed do 
                                if i + 95/2/speed < length then 
                                    charthits[lane+1][#charthits[lane+1] + 1] = {startTime+i, 0, 1, true}
                                else
                                    charthits[lane+1][#charthits[lane+1] + 1] = {startTime+i, 0, 1, true, true}
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    Timer.after(2,
        function()
            musicTimeDo = true
        end
    )
end

return osuLoader