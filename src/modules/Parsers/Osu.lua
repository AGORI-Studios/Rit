---@diagnostic disable: param-type-mismatch
local osuLoader = {}
local currentBlockName = ""
local folderPath
local forNPS

local noteCount, endNoteTime = 0, 0

local eases = {
    "linear",               -- 0  Linear: no easing
    "out-quad",             -- 1  Easing Out: the changes happen fast at first, but then slow down toward the end
    "in-quad",              -- 2  Easing In: the changes happen slowly at first, but then speed up toward the end
    "in-quad",              -- 3  Quad In
    "out-quad",             -- 4  Quad Out
    "in-out-quad",          -- 5  Quad In/Out
    "in-cubic",             -- 6  Cubic In
    "out-cubic",            -- 7  Cubic Out
    "in-out-cubic",         -- 8  Cubic In/Out
    "in-quart",             -- 9  Quart In
    "out-quart",            -- 10 Quart Out
    "in-out-quart",         -- 11 Quart In/Out
    "in-quint",             -- 12 Quint In
    "out-quint",            -- 13 Quint Out
    "in-out-quint",         -- 14 Quint In/Out
    "in-sine",              -- 15 Sine In
    "out-sine",             -- 16 Sine Out
    "in-out-sine",          -- 17 Sine In/Out
    "in-expo",              -- 18 Expo In
    "out-expo",             -- 19 Expo Out
    "in-out-expo",          -- 20 Expo In/Out
    "in-circ",              -- 21 Circ In
    "out-circ",             -- 22 Circ Out
    "in-out-circ",          -- 23 Circ In/Out
    "in-elastic",           -- 24 Elastic In
    "out-elastic",          -- 25 Elastic Out
    "out-elastic",          -- 26 ElasticHalf Out
    "out-elastic",          -- 27 ElasticQuarter Out
    "in-out-elastic",       -- 28 Elastic In/Out
    "in-back",              -- 29 Back In
    "out-back",             -- 30 Back Out
    "in-out-back",          -- 31 Back In/Out
    "in-bounce",            -- 32 Bounce In
    "out-bounce",           -- 33 Bounce Out
    "in-out-bounce"         -- 34 Bounce In/Out
}

local function convertToEaseString(easeType)
    return eases[(easeType or 0) + 1]
end

local _bpm = nil

local currentBoardObject = nil

local function splitAndReplaceWithNull(line, delimiter)
    local result = {}
    local pattern = string.format("([^%s]*)(%s?)", delimiter, delimiter)
    
    for part, sep in line:gmatch(pattern) do
        if part == "" then
            table.insert(result, "NULL")
        else
            table.insert(result, part)
        end
        if sep == "" then break end
    end
    
    return result
end

function osuLoader.load(chart, folderPath_, diffName, _forNPS)
    noteCount, endNoteTime = 0, 0
    currentBoardObject = nil
    states.game.Gameplay.unspawnNotes = {}
    states.game.Gameplay.timingPoints = {}
    states.game.Gameplay.sliderVelocities = {}
    states.game.Gameplay.mode = 4
    forNPS = _forNPS or false
    _bpm = nil
    curChart = "osu!"
    folderPath = folderPath_
    currentBlockName = ""

    local storyboard = nil

    for i, item in ipairs(love.filesystem.getDirectoryItems(folderPath)) do
        if item:endsWith(".osb") then
            storyboard = love.filesystem.read(folderPath .. "/" .. item)
            break
        end
    end
    
    local chart = love.filesystem.read(chart)
    bpm = 120
    crochet = (60/bpm)*1000
    stepCrochet = crochet/4

    states.game.Gameplay.bpmAffectsScrollVelocity = true

    for _, line in ipairs(chart:split("\n")) do
        osuLoader.processLine(line)
    end

    chart = nil 

    if forNPS then
        states.game.Gameplay.unspawnNotes = {}
        states.game.Gameplay.timingPoints = {}
        states.game.Gameplay.sliderVelocities = {}

        return noteCount / (endNoteTime / 1000)
    end

    --[[ if storyboard then
        for _, line2 in ipairs(storyboard:split("\n")) do
            osuLoader.processLine(line2)
        end
    end ]]
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
    if key == "CircleSize" and states.game.Gameplay.gameMode == 1 then
        states.game.Gameplay.mode = tonumber(value)
        states.game.Gameplay.strumX = states.game.Gameplay.strumX - ((states.game.Gameplay.mode - 4.5) * (100 + Settings.options["General"].columnSpacing))
    end
end

function osuLoader.processGeneral(line)
    local key, value = line:match("^(%a+):%s?(.*)")
    if key == "AudioFilename" then
        local value = value:trim()
        --audioFile = love.audio.newSource(folderPath .. "/" .. value, "stream")
        if not forNPS then
            states.game.Gameplay.soundManager:newSound("music", folderPath .. "/" .. value, 1, true, "stream")
        end
    end
end
function osuLoader.processEvent(line)
    if not forNPS then
        local split = splitAndReplaceWithNull(line, ",")
        
        if split[1] == "Video" and video and Video then -- Video,-64,"video.mp4"
            local video = line:match("^Video,.+\"(.+)\".*$")
            local videoPath = folderPath .. "/" .. video
            -- get filedata userdata
            local fileData = love.filesystem.newFileData(videoPath)
            Try(
                function()
                    states.game.Gameplay.background = Video(fileData)
                end,
                function()
                    states.game.Gameplay.background = nil
                end
            )
        end
        if split[1] == "0" and not states.game.Gameplay.background then
            local bg = line:match("^0,.+,\"(.+)\".*$")
            if love.filesystem.getInfo(folderPath .. "/" .. bg) then
                if bg:find(".jpg") or bg:find(".png") then
                    states.game.Gameplay.background = love.graphics.newImage(folderPath .. "/" .. bg)
                end
            end
        end

        if split[1] == "Sprite" then
            if currentBoardObject then
                table.insert(currentBoardObject.events, {
                    type = "Hide",
                    ease = "linear",
                    startTime = currentBoardObject.events[#currentBoardObject.events].endTime,
                    endTime = currentBoardObject.events[#currentBoardObject.events].endTime,
                })
            end
            if split[2] == "Overlay" then split[2] = "Foreground" end

            if split[2] ~= "Background" then
                table.insert(states.game.Gameplay.storyBoardSprites[split[2]].members, StoryboardSprite(
                    split[3], 
                    folderPath .. "/" .. split[4]:gsub("\"", ""):gsub("\\", "/"), 
                    tonumber(split[5]), tonumber(split[6]), split[2]
                ))
            else
                table.addToFirstIndex(states.game.Gameplay.storyBoardSprites[split[2]].members, StoryboardSprite(
                    split[3], 
                    folderPath .. "/" .. split[4]:gsub("\"", ""):gsub("\\", "/"), 
                    tonumber(split[5]), tonumber(split[6]), split[2]
                ))
            end

            currentBoardObject = states.game.Gameplay.storyBoardSprites[split[2]].members[#states.game.Gameplay.storyBoardSprites[split[2]].members]

            --print("[osu!parser] SPRITE CREATED " .. tostring(currentBoardObject) .. " AT " .. "x" .. currentBoardObject.x, " y" .. currentBoardObject.y)
        elseif split[1] == "Animation" then
            if currentBoardObject then
                table.insert(currentBoardObject.events, {
                    type = "Hide",
                    ease = "linear",
                    startTime = currentBoardObject.events[#currentBoardObject.events].endTime,
                    endTime = currentBoardObject.events[#currentBoardObject.events].endTime,
                })
            end
            currentBoardObject = nil
        end

        if currentBoardObject then
            if string.sub(split[1], 1, 1) == " " then
                split[1] = "_" .. split[1]:sub(2)
            end
            if split[1] == "_F" then
                local ease = convertToEaseString(split[2])
                local startTime, endTime = tonumber(split[3]) or 0, tonumber(split[4]) or tonumber(split[3]) or 0
                local duration = (endTime - startTime) / 1000
                local startOpacity = tonumber(split[5]) or 0
                local endOpacity = tonumber(split[6]) or tonumber(split[5]) or 0

                --[[ print("END" .. endOpacity, "START" .. startOpacity) ]]

                table.insert(currentBoardObject.events, {
                    type = "Fade",
                    startTime = startTime,
                    endTime = endTime,
                    duration = duration,
                    startVal = 1 - endOpacity,
                    endVal = 1 - startOpacity,
                    ease = ease
                })
            elseif split[1] == "_M" then
                local ease = convertToEaseString(split[2])
                local startTime, endTime = tonumber(split[3]) or 0, tonumber(split[4]) or tonumber(split[3]) or 0
                local duration = (endTime - startTime) / 1000
                local startPosX = tonumber(split[5]) or 0
                local startPosY = tonumber(split[6]) or tonumber(split[5]) or 0
                local endPosX = tonumber(split[7]) or tonumber(split[5]) or 0
                local endPosY = tonumber(split[8]) or tonumber(split[7]) or tonumber(split[6]) or tonumber(split[5]) or 0

                startPosX, startPosY = Parsers["osu!"].convertPlayfieldToGame(startPosX, startPosY)
                endPosX, endPosY = Parsers["osu!"].convertPlayfieldToGame(endPosX, endPosY)

                table.insert(currentBoardObject.events, {
                    type = "MoveXY",
                    startTime = startTime,
                    endTime = endTime,
                    duration = duration,
                    startValX = startPosX,
                    endValX = endPosX,
                    startValY = startPosY,
                    endValY = endPosY,
                    ease = ease
                })
            elseif split[1] == "_R" then
                local ease = convertToEaseString(split[2])
                local startTime, endTime = tonumber(split[3]) or 0, tonumber(split[4]) or tonumber(split[3]) or 0
                local duration = (endTime - startTime) / 1000

                local startRot = tonumber(split[5]) or 0
                local endRot = tonumber(split[6]) or tonumber(split[5]) or 0

                table.insert(currentBoardObject.events, {
                    type = "Rotate",
                    startTime = startTime,
                    endTime = endTime,
                    duration = duration,
                    startVal = math.deg(startRot),
                    endVal = math.deg(endRot),
                    ease = ease
                })
            elseif split[1] == "_S" then
                print("[osu!parser] SCALE EVENT FOR StoryboardSprite")
                local ease = convertToEaseString(split[2])
                local startTime, endTime = tonumber(split[3]) or 0, tonumber(split[4]) or tonumber(split[3]) or 0
                local duration = (endTime - startTime) / 1000

                local startScale = tonumber(split[5]) or 0
                local endScale = tonumber(split[6]) or tonumber(split[5]) or 0

                table.insert(currentBoardObject.events, {
                    type = "Scale",
                    startTime = startTime,
                    endTime = endTime,
                    duration = duration,
                    startVal = startScale,
                    endVal = endScale,
                    ease = ease
                })
            elseif split[1] == "_C" then
                local ease = convertToEaseString(split[2])
                local startTime, endTime = tonumber(split[3]) or 0, tonumber(split[4]) or tonumber(split[3]) or 0
                local duration = (endTime - startTime) / 1000
                local startRGB = {}
                local endRGB = {}

                if split[4] == "NULL" then
                    startRGB = {
                        tonumber(split[5]) / 255,
                        tonumber(split[6]) / 255,
                        tonumber(split[7]) / 255,
                    }
                    endRGB = {
                        tonumber(split[5]) / 255,
                        tonumber(split[6]) / 255,
                        tonumber(split[7]) / 255,
                    }
                else
                    startRGB = {
                        tonumber(split[4]) / 255,
                        tonumber(split[5]) / 255,
                        tonumber(split[6]) / 255,
                    }
                    endRGB = {
                        tonumber(split[7]) / 255,
                        tonumber(split[8]) / 255,
                        tonumber(split[9]) / 255,
                    }
                end

                table.insert(currentBoardObject.events, {
                    type = "Colour",
                    startTime = startTime,
                    endTime = endTime,
                    duration = duration,
                    startRGB = startRGB,
                    endRGB = endRGB,
                    ease = ease
                })
            end

            table.sort(currentBoardObject.events, function(a, b)
                return a.startTime < b.startTime
            end)
        end
    end
end
function osuLoader.addTimingPoint(line)
    if forNPS then return end
    local split = line:split(",")
    local tp = {}

    tp.offset = tonumber(split[1]) or 0 -- MS per beat
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
        tp.beatLength = math.abs(tp.beatLength)
        tp.measureLength = math.abs(tp.beatLength * tp.timingSignature)
        tp.timingChange = true
        if tp.beatLength < 1e-3 then
            tp.beatLength = 1
        end
        if tp.measureLength < 1e-3 then
            tp.measureLength = 1
        end
    else -- slider velocity (what we care about)
        tp.velocity = math.min(math.max(0.1, math.abs(-100 / tp.beatLength)), 10)
    end

    local isSV = tp.sampleVolume == 0 or tp.beatLength < 0

    if isSV then
        local velocity = {
            startTime = tp.offset,
            multiplier = tp.velocity or 0
        }
        table.insert(states.game.Gameplay.sliderVelocities, velocity)
    else
        if not _bpm then _bpm = 60000/tp.beatLength; bpm = _bpm end
        table.insert(states.game.Gameplay.timingPoints, {
            StartTime = tp.offset,
            Bpm = 60000/tp.beatLength
        })
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
    if states.game.Gameplay.gameMode == 2 then
        states.game.Gameplay.mode = 2
        if bit.band(tonumber(split[5]) or 0, 10) ~= 0 then
            note.data = 2
        else
            note.data = 1
        end
    else
        note.data = math.max(1, math.min(states.game.Gameplay.mode, math.floor(note.x/512*states.game.Gameplay.mode+1))) or 1
    end

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

    if not forNPS then
        local ho = HitObject(note.startTime, note.data, note.endTime)
        table.insert(states.game.Gameplay.unspawnNotes, ho)
    else
        noteCount = noteCount + 1
        endNoteTime = ((note.endTime and note.endTime ~= 0) and note.endTime) or note.startTime
    end

end

function osuLoader.convertToPlayfield(x, y)
    local originalWidth, originalHeight = 1920, 1080
    local targetWidth, targetHeight = 640, 480

    local scaleFactor = targetHeight / originalHeight
    local offsetX = (originalWidth - (originalWidth * scaleFactor)) / 2
    local offsetY = (originalHeight - (originalHeight * scaleFactor)) / 2

    local newX = (x * scaleFactor) + (offsetX * scaleFactor)
    local newY = (y * scaleFactor) + (offsetY * scaleFactor)

    return newX, newY
end

function osuLoader.convertPlayfieldToGame(x, y)
    local scale = 1080 / 480  -- Scale based on the height
    local scaledWidth = 640 * scale
    local offsetX = (1920 - scaledWidth) / 2  -- Calculate horizontal offset
    
    local x1920 = math.floor(x * scale + offsetX)
    local y1080 = math.floor(y * scale)
    
    return x1920, y1080
end

return osuLoader