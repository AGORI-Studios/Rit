local osuLoader = {}
local currentBlockName = ""
local folderPath

function osuLoader.load(chart, folderPath_, forDiff)
    curChart = "osu!"
    folderPath = folderPath_

    local chart = love.filesystem.read(chart)
    bpm = 120
    crochet = (60/bpm)*1000
    stepCrochet = crochet/4

    for _, line in ipairs(chart:split("\n")) do
        osuLoader.processLine(line)
    end
end

function osuLoader.processLine(line)
    if line:find("^%[") then
        local _currentBlockName, lineEnd = line:match("^%[(.+)%](.*)$")
        currentBlockName = _currentBlockName
        osuLoader.processLine(lineEnd)
    else
        local currentBlockName = currentBlockName:trim()
        local trimmed = line:trim()
        if trimmed == "" then
            -- empty line
        elseif currentBlockName == "General" then
            osuLoader.processGeneral(line)
        elseif currentBlockName == "Events" then
            -- events
        elseif currentBlockName == "TimingPoints" then
            -- timing points
        elseif currentBlockName == "HitObjects" then
            osuLoader.addHitObject(line)
        elseif currentBlockName == "Metadata" then
            osuLoader.processMetadata(line)
        elseif currentBlockName == "Difficulty" then
            osuLoader.processDifficulty(line)
        end
    end
end

function osuLoader.processDifficulty(line)
    local key, value = line:match("^(%a+):%s?(.*)")
    if key == "CircleSize" then
        states.game.Gameplay.mode = tonumber(value)
    end
end

function osuLoader.processGeneral(line)
    local key, value = line:match("^(%a+):%s?(.*)")
    if key == "AudioFilename" then
        local value = value:trim()
        --audioFile = love.audio.newSource(folderPath .. "/" .. value, "stream")
        states.game.Gameplay.soundManager:newSound("music", folderPath .. "/" .. value, 1, true, "stream")
    end
end
function osuLoader.processMetadata(line)
    local key, value = line:match("^(%a+):%s?(.*)")
    if key == "Title" then
        __title = value
    elseif key == "Artist" then
        __artist = value
    elseif key == "Creator" then
        __creator = value
    elseif key == "Version" then
        __diffName = value
    end
end

function osuLoader.addHitObject(line)
    local split = line:split(",")
    local note = {}
    local addition
    note.x = tonumber(split[1])
    note.y = tonumber(split[2])
    note.startTime = tonumber(split[3])
    note.data = math.max(1, math.min(states.game.Gameplay.mode, math.floor(note.x/512*states.game.Gameplay.mode+1)))

    note.endTime = tonumber(split[6])

    local ho = HitObject(note.startTime, note.data, note.endTime)
    table.insert(states.game.Gameplay.unspawnNotes, ho)
end

return osuLoader