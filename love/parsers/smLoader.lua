local stepLoader = {}

local readingNotes = false
local readingBPM = false
local readingSTOPS = false
local bpmIndex = 0

local diffIndex = 0
local beat = 0
local measureIndex = 0

function stepLoader.load(chart)
    bpm = 120
    mode = "Keys4"
    for line in love.filesystem.lines(chart) do
        local cont = true
        if line:find("#MUSIC:") then 
            local audioPath = line:gsub("#MUSIC:", "")
            audioPath = audioPath:gsub(";", "")
            audioPath = folderPath .. "/" .. audioPath
            audioFile = love.audio.newSource(audioPath, "stream")
        end

        if line:find("//") then 
            cont = false
        end
        if line:find(",") then 
            cont = true
        end

        if cont then 
            if not readingNotes then 
                if readingBPM then 
                    if line:find(";") or line:find("#") then 
                        readingBPM = false
                    else 
                        -- split the line from = 
                        local split = line:split("=")
                        -- get the bpm
                        bpm = split[2]
                        bpm = bpm:gsub(";", "")
                        bpm = tonumber(bpm)
                        
                        -- startBeat = split[1] without BPMS:
                        startBeat = split[1]:gsub("BPMS:", "")
                        startBeat = tonumber(startBeat)
                    end
                elseif readingSTOPS then 
                    if line:find(";") or line:find("#") then 
                        readingSTOPS = false
                    else 
                        -- split the line from = 
                        local split = line:split("=")
                        -- get the bpm
                        stop = split[2]
                        stop = stop:gsub(";", "")
                        stop = tonumber(stop)
                        
                        -- startBeat = split[1] without BPMS:
                        stopBeat = split[1]:gsub("STOPS:", "")
                        stopBeat = tonumber(stopBeat)
                    end
                end

                if not readingBPM and not readingSTOPS then 
                    if line:find("#BPMS:") then 
                        readingBPM = true
                    elseif line:find("#STOPS:") then 
                        readingSTOPS = true
                    elseif line:find("#NOTES:") then 
                        readingNotes = true
                        diffIndex = diffIndex + 1
                        measureIndex = 0
                        beat = 0
                    end
                end
            else
                diffIndex = 0

                if line:find(",") then 
                    measureIndex = measureIndex + 1
                    beat = 0
                else

                    lengthInRows = 192 / measureIndex

                    rowIndex = 0

                    if line:find(";") then 
                        readingNotes = false
                    end

                    if not line:find(";") and not line:find(",") and not line:find("//") and not line:find("#") then 
                        -- if the first character is a not a number
                        if line:sub(1, 1):match("%d") then 
                            beat = beat + 1
                        end
                    end

                    -- 1 = normal
                    -- 2 = head 
                    -- 3 = tail
                    -- 4 = head

                    for i = 1, #line do 
                        noteRow = (measureIndex * 192) + (lengthInRows * rowIndex)
                        beat = noteRow / 48
                        local char = line:sub(i, i)
                        if char ~= "," and char ~= ";" then 
                            -- if the char is 1 then its a note
                            if char == "1" then 
                                local lane = i
                                local time = ((beat / bpm) * 60000) + ((measureIndex * 4) / bpm) * 60000
                                if lane < 5 and time ~= 0 then 
                                    charthits[lane][#charthits[lane] + 1] = {time, 0, 1, false}
                                end
                            elseif char == "2" then 
                                local lane = i
                                local time = ((beat / bpm) * 60000) + ((measureIndex * 4) / bpm) * 60000
                                if lane < 5 and time ~= 0 then 
                                    charthits[lane][#charthits[lane] + 1] = {time, 0, 2, false}
                                end
                            elseif char == "3" then 
                                local lane = i
                                local time = ((beat / bpm) * 60000) + ((measureIndex * 4) / bpm) * 60000
                                if lane < 5 and time ~= 0 then 
                                    charthits[lane][#charthits[lane] + 1] = {time, 0, 3, false}
                                end
                            elseif char == "4" then 
                                local lane = i
                                local time = ((beat / bpm) * 60000) + ((measureIndex * 4) / bpm) * 60000
                                if lane < 5 and time ~= 0 then 
                                    charthits[lane][#charthits[lane] + 1] = {time, 0, 4, false}
                                end
                            end
                        end
                    end
                end
            end
        end 
    end
    --audioFile:setPitch(songRate)
    Timer.after(2,
        function()
            state.switch(game)
            musicTimeDo = true
            print(#chartEvents, #bpmEvents)
        end
    )
end

return stepLoader