---@diagnostic disable: need-check-nil
-- https://github.com/Quaver/Quaver.API/blob/f798abe059f966573086ab47438b7a6bff144b67/Quaver.API/Maps/Parsers/Stepmania/StepFile.cs
local stepmaniaLoader = {}

local title, subtitle, artist, titleTransLit, subtitleTransLit, artistTransLit, 
    credit, banner, background, lyricsPath, cdTitle, music,
    musicLength, offset, sampleStart, sampleLength, selectable, bpms,
    stops, charts

local folderPath

function stepmaniaLoader.getDifficulties(path)
    local file = io.open(path, "r")
    local contents = file:read("*a")
    file:close()

    local notesTag = false
    local notes = {}
    local metaIndex = 0 -- #NOTES: tag index
    local isDanceSingle = false
    local songName = ""
    local audioPath = ""
    for line in contents:gmatch("[^\r\n]+") do
        if line:startsWith("#") then
            if line:startsWith("#TITLE:") then
                songName = line:sub(8):sub(1, #line:sub(8) - 1):trim()
            elseif line:startsWith("#MUSIC:") then
                audioPath = line:sub(8):sub(1, #line:sub(8) - 1):trim()
            end
        end
        if notesTag then
            if line:find(":") then
                metaIndex = metaIndex + 1
                if metaIndex == 1 then
                    local line = line:gsub("\t", ""):gsub(":", ""):trim()
                    if line:find("dance%-single") then
                        isDanceSingle = true
                    else
                        isDanceSingle = false
                    end
                end

                if metaIndex == 3 and isDanceSingle then
                    line = line:sub(1, #line - 1):trim()
                    table.insert(notes, {
                        songName = songName,
                        name = line,
                        audioPath = audioPath
                    })
                end
            else
                notesTag = false
            end
        end

        if line:find("#NOTES:") then
            notesTag = true
            metaIndex = 0
            isDanceSingle = false
        end
    end

    return notes
end

-- 1 tick = 1/48 of a beat
-- 1 beat = 48 ticks
-- 1 measure = 192 ticks
local function tickToMs(tick, bpm)
    local msPerBeat = 60000 / bpm
    local msPerTick = msPerBeat / 4
    return tick * msPerTick
end

function stepmaniaLoader.load(chart, folderPath, diffName, forNPS)
    local songName = ""
    local audioPath = ""
    print(diffName)

    local chart = love.filesystem.read(chart)

    states.game.Gameplay.mode = 4
    states.game.Gameplay.strumX = states.game.Gameplay.strumX - ((states.game.Gameplay.mode - 4.5) * (100 + Settings.options["General"].columnSpacing))
    
    local bpms = {}
    local stops = {}

    ---@diagnostic disable-next-line: assign-type-mismatch
    bpm = nil

    local inBpms = false
    local inStops = false

    local notesTag = false
    local inCorrectDiff = false

    local currentMeasure = 0
    local currentTick = 1
    local holdsInfo = {}
    for i = 1, 4 do
        holdsInfo[i] = {}
    end
    local ticksInRow = 0
    local currentLine = 0
    local offset = 0
    local notesCount
    -- bpms and stops can be multiline. so when we are in one, keep going until we find a ;

    local allLines = chart:split("\n")

    for line in chart:gmatch("[^\r\n]+") do
        currentLine = currentLine + 1
        if line:startsWith("#") then
            if line:startsWith("#TITLE:") then
                songName = line:sub(8):sub(1, #line:sub(8) - 1):trim()
            elseif line:startsWith("#MUSIC:") then
                audioPath = line:sub(8):sub(1, #line:sub(8) - 1):trim()
                if not forNPS then
                    states.game.Gameplay.soundManager:newSound("music", folderPath .. "/" .. audioPath, 1, true, "stream")
                end
            elseif line:startsWith("#BPMS:") then
                inBpms = true
            elseif line:startsWith("#STOPS:") then
                inStops = true
            elseif line:startsWith("#NOTES:") then
                inBpms = false
                inStops = false
            elseif line:startsWith("#OFFSET:") then
                --offset = tonumber(line:sub(9):sub(1, #line:sub(9) - 1):trim())
            end
        end

        if inBpms then
            line = line:sub(7):sub(1, #line:sub(7) - 1):trim()

            local split = line:split("=")
            local beat = tonumber(split[1])
            local bpm_ = tonumber(split[2])
            table.insert(bpms, {
                beat = beat,
                bpm = bpm_
            })

            if line:find(";") then
                inBpms = false
            end

            if not bpm then
                bpm = bpms[#bpms].bpm
            end
        end

        if inStops then
            line = line:sub(8):sub(1, #line:sub(8) - 1):trim()

            local split = line:split("=")
            local beat = tonumber(split[1])
            local length = tonumber(split[2])
            table.insert(stops, {
                beat = beat,
                length = length
            })

            if line:find(";") then
                inStops = false
            end
        end

        -- now go to the notes`
        if line:find("#NOTES:") then
            notesTag = true
        end

        if notesTag then
            if line:find(":") then
                -- check if its the correct difficulty
                local diff = line:sub(1, #line - 1):trim()
                if inCorrectDiff then
                    goto continue1
                end
                if diff == diffName then
                    inCorrectDiff = true
                    goto continue1
                else
                    inCorrectDiff = false
                end
            end

            ::continue1::

            if inCorrectDiff and not line:find(":") then
                local lanes = line:splitAllCharacters()
                --[[
                    All available note types:
                        - 1 = Tap
                        - 2 = Hold Head
                        - 3 Tail
                    Non available note types (for now):
                        - 4 = Roll Head
                        - 5 = Roll Tail
                        - A = Attack
                        - F = Fake
                ]]

                if line:find(",") then
                    currentMeasure = currentMeasure + 1
                    -- how many lines until the next measure (ticksInRow)
                    ticksInRow = 0

                    -- count all the ones and twos in the current measure
                    notesCount = 0

                    local index = 0
                    for i, line in ipairs(allLines) do
                        if i == currentLine then
                            index = i
                            break
                        end
                    end

                    for i = index, #allLines do
                        -- count all the notes in the current measure
                        if allLines[i]:find("1") or allLines[i]:find("2") then
                            notesCount = notesCount + 1
                        end

                        if allLines[i]:find(";") then
                            break
                        end
                    end

                    goto continue2
                end

                if line:find(";") then
                    inCorrectDiff = false
                    notesTag = false
                    break
                end

                for i, lane in ipairs(lanes) do
                    if lane == "0" then
                        goto continue3
                    end

                    local noteType = tonumber(lane)
                    local lane = i

                    if noteType == 1 then
                        -- use currentTick and currentMeasure to find the start time
                        local ms = tickToMs(currentTick, bpm)
                        local ho = HitObject(ms, lane, 0)
                        table.insert(states.game.Gameplay.unspawnNotes, ho)
                    elseif noteType == 2 then
                        holdsInfo[lane].startTick = currentTick
                    elseif noteType == 3 then
                        -- the end time for the hold
                        holdsInfo[lane].endTick = currentTick
                        local ms = tickToMs(holdsInfo[lane].startTick, bpm)
                        local endTime = tickToMs(holdsInfo[lane].endTick, bpm)
                        local ho = HitObject(ms, lane, endTime)
                        table.insert(states.game.Gameplay.unspawnNotes, ho)
                    end

                    currentTick = currentTick + 1

                    ::continue3::
                end

                ::continue2::
            end
        end
    end

    __title = songName
    __diffName = diffName

    if forNPS then
        -- find our average notes per second and return the nps

        local noteCount = #states.game.Gameplay.unspawnNotes
        local songLength = 0
        local endNote = states.game.Gameplay.unspawnNotes[#states.game.Gameplay.unspawnNotes]
        if endNote.endTime ~= 0 and endNote.endTime ~= endNote.time then
            songLength = endNote.endTime
        else
            songLength = endNote.time
        end

        states.game.Gameplay.unspawnNotes = {}
        states.game.Gameplay.timingPoints = {}
        states.game.Gameplay.sliderVelocities = {}

        return noteCount / (songLength / 1000)
    end
end


return stepmaniaLoader