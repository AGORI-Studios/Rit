local ritLoader = {}
local currentBlock = ""
local folderPath
local _forNPS
local noteCount, endNoteTime = 0, 0

local title, diff

function ritLoader.load(chart, folderPath_, diffName, forNPS)
    noteCount, endNoteTime = 0, 0
    _forNPS = forNPS or false
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

    if forNPS then
        states.game.Gameplay.unspawnNotes = {}
        states.game.Gameplay.timingPoints = {}
        states.game.Gameplay.sliderVelocities = {}

        return noteCount / (endNoteTime / 1000)
    end
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
    if _forNPS then return end
    table.insert(states.game.Gameplay.sliderVelocities, {
        startTime = (tonumber(info[1]) or 1) / Modifiers.Rate,
        multiplier = tonumber(info[2]) or 1
    })
end

function ritLoader.addHitObject(line)
    local info = line:split(":")
    local startTime = tonumber(info[1]) or 0
    local endTime = tonumber(info[2]) or 0
    local lane = tonumber(info[3]) or 1

    if not startTime then goto continue end

    if doAprilFools and Settings.options["Events"].aprilFools then lane = 1; states.game.Gameplay.mode = 1 end

    if not _forNPS then
        local ho = HitObject(startTime, lane, endTime)
        table.insert(states.game.Gameplay.unspawnNotes, ho)
    else
        noteCount = noteCount + 1
        endNoteTime = ((endTime and endTime ~= 0) and endTime) or startTime
    end

    ::continue::
end

function ritLoader.processMetadata(line)
    local key, value = line:match("^(%a+):%s?(.*)")
    if key == "SongTitle" then
        title = value
    elseif key == "SongDiff" then
        diff = value
    elseif key == "KeyAmount" then
        if _forNPS then return end
        states.game.Gameplay.mode = tonumber(value)
        states.game.Gameplay.strumX = states.game.Gameplay.strumX - ((states.game.Gameplay.mode - 4.5) * (100 + (not _forNPS and Settings.options["General"].columnSpacing or 0)))
    elseif key == "AudioFile" then
        local value = value:trim()
        if not _forNPS then
            states.game.Gameplay.soundManager:newSound("music", folderPath .. "/" .. value, 1, true, "stream")
        end
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