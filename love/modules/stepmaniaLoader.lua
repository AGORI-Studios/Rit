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

local stepLoader = {}
local List = {}

function stepLoader.load(chart, foldername)
    curChart = "Stepmania"
    local file = love.filesystem.read(chart)
    lines = love.filesystem.lines(chart)
    local readChart = false

    mode = "Keys4"

    for line in lines do 
        if line:find("#MUSIC:") then 
            curLine = line
            local audioPath = curLine:gsub("#MUSIC:", "")
            local audioPath = audioPath:gsub(";", "")
            audioFile = love.audio.newSource("songs/stepmania/" .. foldername .. "/" .. audioPath, "stream")
        end
        if line:find("#BPMS:") then 
            curLine = line
            bpm = curLine:gsub("#BPMS:0.000=", "")
            bpm = bpm:gsub(";", "")
            bpm = tonumber(bpm) or curLine:gsub("#BPMS:", "")
            bpm = tonumber(bpm) or 222
        end
        if line:find("#NOTES:") then 
            readChart = true
            difficultyName = line:match(":(.*):")
        end
        -- since stepmania chart timings are based on beats, we need to convert them to milliseconds
        -- charts are also like 0000, first number is first lane, second number is second lane, etc.
        
        if readChart then 
            if not line:find(";") and not line:find(",") and not line:find("//") and not line:find("#") then 
                -- if the first character is a not a number
                if line:sub(1, 1):match("%d") then 
                    lineCount = lineCount + 1
                end
            end
            for i = 1, #line do 
                local char = line:sub(i, i)
                if char ~= "," and char ~= ";" then 
                    -- if the char is 1 then its a note
                    if char == "1" then 
                        local lane = i
                        local beat = lineCount
                        local time = (beat / bpm) * 60000
                        if lane < 5 and time ~= 0 then 
                            charthits[lane][#charthits[lane] + 1] = {time, 0, 1, false}
                        end
                    end
                    
                end
            end
        end
    end

    musicTimeDo = true
end

return stepLoader