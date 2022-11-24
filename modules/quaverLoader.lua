local quaverLoader = {}
lineCount = 0
function quaverLoader.load(chart)
    -- read the first line of the file
    curChart = "Quaver"
    local file = love.filesystem.read(chart)

    for line in love.filesystem.lines(chart) do
        lineCount = lineCount + 1
        --if line:find("AudioFile: ") then
        if line:find("AudioFile:") then
            curLine = line
            local audioPath = curLine
            audioPath = audioPath:gsub("AudioFile: ", "")
            audioPath = "song/" .. audioPath
            audioFile = love.audio.newSource(audioPath, "stream")
            print(audioPath)
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
        if line:find("Bpm:") then
            curLine = line
            bpm = curLine
            -- trim the bpm of anything that isn't a number
            bpm = bpm:gsub("%D", "")
            bpm = tonumber(bpm) or 120
            print(bpm)
        end

        if not line:find("HitObjects:") and not line:find("HitObjects: []") then
            if line:find("- StartTime: ") then
                curLine = line
                startTime = curLine
                startTime = startTime:gsub("- StartTime: ", "")
                startTime = tonumber(startTime)
                --print("mf")
                -- get our next line
            end
            if line:find("  Lane: ") then
                -- if the next line has "- Lane: " in it, then it's the line with the lane
                curLine = line
                lane = curLine
                lane = lane:gsub("  Lane: ", "")
                lane = tonumber(lane)
                charthits[lane][#charthits[lane] + 1] = {startTime, 0, love.graphics.newImage(noteNORMAL), false}
            end
            if line:find("  EndTime: ") then
                curLine = line
                endTime = curLine
                endTime = endTime:gsub("  EndTime: ", "")
                local length = tonumber(endTime) - startTime
                endTime = tonumber(endTime)
                    
                for i = 1, length, 95/2/speed do
                    if i + 95/2/speed < length then
                        charthits[lane][#charthits[lane] + 1] = {startTime+i, 0, love.graphics.newImage(noteHOLD), true}
                    else
                        charthits[lane][#charthits[lane] + 1] = {startTime+i, 0, love.graphics.newImage(noteEND), true, true}
                    end
                end
            end
        end
    end
    --audioFile:setPitch(songRate)
    audioFile:play()
    musicTimeDo = true
end

return quaverLoader