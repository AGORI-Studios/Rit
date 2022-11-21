local quaverLoader = {}
lineCount = 0
function quaverLoader.load(chart)
    -- read the first line of the file
    local file = io.open(chart, "r")

    for line in file:lines() do
        lineCount = lineCount + 1
        if line:find("AudioFile: ") then
            curLine = line
            local audioPath = curLine
            audioPath = audioPath:gsub("AudioFile: ", "")
            audioFile = love.audio.newSource(audioPath, "stream")
        end
        if line:find("Mode: ") then
            modeLine = line
            mode = modeLine:gsub("Mode: ", "")
            if mode == "Keys7" then
                for i = 1, 7 do
                    charthits[i] = {}
                end
                for i = 1, 7 do
                    receptors[i] = {love.graphics.newImage(receptor), love.graphics.newImage(receptorDown)}
                end
                inputList = {
                    "one7",
                    "two7",
                    "three7",
                    "four7",
                    "five7",
                    "six7",
                    "seven7"
                }
            end
        end
        -- if the line has "- Bpm: " in it, then it's the line with the BPM
        if line:find("Bpm: ") then
            curLine = line
            local bpm = curLine
            bpm = bpm:gsub("- Bpm: ", "") or bpm:gsub("Bpm: ", "")
            bpm = tonumber(bpm)
        end

        if not line:find("HitObjects:") and not line:find("HitObjects: []") then
            if line:find("- StartTime: ") then
                curLine = line
                local startTime = curLine
                startTime = startTime:gsub("- StartTime: ", "")
                startTime = tonumber(startTime)
                -- get our next line
                local nextLine = file:read()
                if nextLine ~= nil then
                    -- if the next line has "- Lane: " in it, then it's the line with the lane
                    if nextLine:find("Lane:") then
                        curLine = nextLine
                        local lane = curLine
                        lane = lane:gsub("  Lane: ", "")
                        lane = tonumber(lane)
                        lineAfter = file:read()
                        charthits[lane][#charthits[lane] + 1] = {startTime, 0, love.graphics.newImage(noteNORMAL), false}
                        if lineAfter ~= nil then
                            if lineAfter:find("  EndTime: ") then
                                curLine = lineAfter
                                local endTime = curLine
                                endTime = endTime:gsub("  EndTime: ", "")
                                local length = tonumber(endTime) - startTime
                                endTime = tonumber(endTime)
                                
                                for i = 1, length, 95/2 do
                                    if i + 95/2 < length then
                                        charthits[lane][#charthits[lane] + 1] = {startTime+i, 0, love.graphics.newImage(noteHOLD), true}
                                    else
                                        charthits[lane][#charthits[lane] + 1] = {startTime+i, 0, love.graphics.newImage(noteEND), true, true}
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    audioFile:play()
    musicTimeDo = true
end

return quaverLoader