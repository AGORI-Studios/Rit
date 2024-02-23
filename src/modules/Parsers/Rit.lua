local ritLoader = {}
local currentBlock = ""
local folderPath

local title, diff

function ritLoader.load(chart, folderPath_, forDiff)
    curChart = "Rit"
    folderPath = folderPath_

    ---@diagnostic disable-next-line: redefined-local
    local chart = love.filesystem.read(chart)
    bpm = 0
    crochet = 0
    stepCrochet = 0

    for _, line in ipairs(chart:split("\n")) do
        ritLoader.processLine(line)
    end

    __title = title
    __diffName = diff
end

function ritLoader.processLine(line)
    if line:find("^%[") then
        local _currentBlock, lineEnd = line:match("^%[(.+)%](.*)$")
        currentBlock = _currentBlock
        ritLoader.processLine(lineEnd)
    else
        ---@diagnostic disable-next-line: param-type-mismatch
        local currentBlock = currentBlock:trim()
        local trimmed = line:trim()
        if trimmed == "" then
            -- empty line
        elseif currentBlock == "Velocities" then
            ritLoader.processVelocities(line)
        elseif currentBlock == "Hits" then
            ritLoader.addHitObject(line)
        elseif currentBlock == "Meta" then
            ritLoader.processMetadata(line)
        elseif currentBlock == "Timings" then
            ritLoader.processTimings(line)
        end
    end
end

function ritLoader.processVelocities(line)
    local info = line:split(":")
    table.insert(states.game.Gameplay.sliderVelocities, {
        startTime = tonumber(info[1]),
        multiplier = tonumber(info[2])
    })
end

function ritLoader.addHitObject(line)
    local info = line:split(":")
    local startTime = tonumber(info[1])
    local endTime = tonumber(info[2])
    local lane = tonumber(info[3])

    if not startTime then goto continue end

    local ho = HitObject(startTime, lane, endTime)
    table.insert(states.game.Gameplay.unspawnNotes, ho)

    ::continue::
end

function ritLoader.processMetadata(line)
    local key, value = line:match("^(%a+):%s?(.*)")
    if key == "SongTitle" then
        title = value
    elseif key == "SongDiff" then
        diff = value
    elseif key == "KeyAmount" then
        states.game.Gameplay.mode = tonumber(value)
    elseif key == "AudioFile" then
        local value = value:trim()
        states.game.Gameplay.soundManager:newSound("music", folderPath .. "/" .. value, 1, true, "stream")
    end
end

function ritLoader.processTimings(line)
    if bpm == 0 then
        bpm = tonumber(line:split(":")[2])
        crochet = (60/bpm)*1000
        stepCrochet = crochet/4
    else
        
    end
end

return ritLoader