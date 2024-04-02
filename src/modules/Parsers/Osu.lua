---@diagnostic disable: param-type-mismatch
local osuLoader = {}
local currentBlockName = ""
local folderPath

function osuLoader.load(chart, folderPath_, forDiff)
    curChart = "osu!"
    folderPath = folderPath_
    currentBlockName = ""

    local chart = love.filesystem.read(chart)
    bpm = 120
    crochet = (60/bpm)*1000
    stepCrochet = crochet/4

    for _, line in ipairs(chart:split("\n")) do
        osuLoader.processLine(line)
    end

    chart = nil
end

function osuLoader.processLine(line)
    if line:find("^%[") then
        local _currentBlockName, lineEnd = line:match("^%[(.+)%](.*)$")
        currentBlockName = _currentBlockName
        osuLoader.processLine(lineEnd)
    else
        ---@diagnostic disable-next-line: redefined-local
        local currentBlockName = currentBlockName:trim()
        local trimmed = line:trim()
        if trimmed == "" then
            -- empty line
        elseif currentBlockName == "General" then
            osuLoader.processGeneral(line)
        elseif currentBlockName == "Events" then
            osuLoader.processEvent(line)
        elseif currentBlockName == "TimingPoints" then
            osuLoader.addTimingPoint(line)
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
function osuLoader.processEvent(line)
    local split = line:split(",")
    if split[1] == "Video" and video and Video then -- Video,-64,"video.mp4"
        local video = line:match("^Video,.+\"(.+)\".*$")
        local videoPath = folderPath .. "/" .. video
        -- get filedata userdata
        local fileData = love.filesystem.newFileData(videoPath)
        states.game.Gameplay.background = Video(fileData)
    end
    if split[1] == "0" and not states.game.Gameplay.background then
        local bg = line:match("^0,.+,\"(.+)\".*$")
        --states.game.Gameplay.background = love.graphics.newImage(folderPath .. "/" .. bg)
        if love.filesystem.getInfo(folderPath .. "/" .. bg) then
            if bg:find(".jpg") or bg:find(".png") then
                states.game.Gameplay.background = love.graphics.newImage(folderPath .. "/" .. bg)
            end
        end
    end
end
function osuLoader.addTimingPoint(line)
    local split = line:split(",")
    local tp = {}

    tp.offset = tonumber(split[1]) or 0
    tp.beatLength = tonumber(split[2]) or 0
    tp.timingSignature = math.max(0, math.min(8, tonumber(split[3]) or 4)) or 4
    tp.sampleSetId = tonumber(split[4]) or 0
    tp.customSampleIndex = tonumber(split[5]) or 0
    tp.sampleVolume = tonumber(split[6]) or 0
    tp.timingChange = tonumber(split[7]) or 1
    tp.kiaiTimeActive = tonumber(split[8]) or 0

    if tp.timingSignature == 0 then
        tp.timingSignature = 4
    end

    if tp.beatLength >= 0 then
        -- beat shit
    else -- slider velocity (what we care about)
        tp.velocity = math.min(math.max(0.1, math.abs(-100 / tp.beatLength)), 10)
    end

    if tp.velocity then
        local velocity = {
            startTime = tp.offset,
            multiplier = tp.velocity
        }
        table.insert(states.game.Gameplay.sliderVelocities, velocity)
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
    note.x = tonumber(split[1]) or 0
    note.y = tonumber(split[2]) or 0
    note.startTime = tonumber(split[3]) or 0
    note.data = math.max(1, math.min(states.game.Gameplay.mode, math.floor(note.x/512*states.game.Gameplay.mode+1))) or 1

    --[[ if split[6] then
        note.endTime = tonumber(split[6]:split(":")[1]) or 0
    end ]]
    -- https://github.com/semyon422/chartbase/blob/b29e3e2922c2d5df86d8cf9da709de59a5fb30a8/osu/Osu.lua#L154
    note.type = tonumber(split[4]) or 0
    if bit.band(note.type, 2) == 2 then
        -- what repeat count... why is osu stuff so wacky to me
        local length = tonumber(split[8])
        note.endTime = length and note.startTime + length or 0
        addition = split[11] and split[11]:split(":") or {}
    elseif bit.band(note.type, 128) == 128 then
        addition = split[6] and split[6]:split(":") or {}
        note.endTime = tonumber(addition[1]) or 0
        table.remove(addition, 1)
    elseif bit.band(note.type, 8) == 8 then
        note.endTime = tonumber(split[6]) or 0
        addition = split[7] and split[7]:split(":") or {}
    else
        addition = split[6] and split[6]:split(":") or {}
    end

    if doAprilFools and Settings.options["Events"].aprilFools then note.data = 1; states.game.Gameplay.mode = 1 end

    local ho = HitObject(note.startTime, note.data, note.endTime)

    -- TODO: Add key sounds.
    ho.keySounds = {}

    table.insert(states.game.Gameplay.unspawnNotes, ho)
end

return osuLoader