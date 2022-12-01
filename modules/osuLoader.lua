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
            local x, y, startTime, type, idk, endtime = line:match("([^,]+),([^,]+),([^,]+),([^,]+),([^,]+)")
            x = tonumber(x)
            if x < 500 then
                curLine = line
                lane = x / 128
                lane = math.floor(lane)
                startTime = tonumber(startTime)
                type = tonumber(type)
                hitSound = hitSound

                if lane > 4 then
                    print("This is not a 4k chart!\nSupport for 5k+ charts will be added in the future.")
                    choosingSong = true
                    break
                end
                
                if startTime == nil then 
                    startTime = 0
                end
                charthits[lane + 1][#charthits[lane+1] + 1] = {startTime, 0, 1, false}
                if endtime then 
                    length = startTime - endtime
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
                -- TODO!!!!!!
                -- add hold notes
            end
        end
    end
    audioFile:play()
    musicTimeDo = true
end

return osuLoader