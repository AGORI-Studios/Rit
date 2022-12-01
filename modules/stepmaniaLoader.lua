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
            bpm = tonumber(bpm)
        end
        if line:find("#NOTES:") then 
            readChart = true
            difficultyName = line:match(":(.*):")
        end
        -- since stepmania chart timings are based on beats, we need to convert them to milliseconds
        -- charts are also like 0000, first number is first lane, second number is second lane, etc.
        
        if readChart then 
            if not line:find(";") and not line:find(",") and not line:find("//") and not line:find("#") then 
                lineCount = lineCount + 1
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

    audioFile:play()
    musicTimeDo = true
end

return stepLoader