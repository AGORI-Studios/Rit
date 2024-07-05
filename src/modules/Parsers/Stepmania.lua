---@diagnostic disable: need-check-nil
-- https://github.com/Quaver/Quaver.API/blob/f798abe059f966573086ab47438b7a6bff144b67/Quaver.API/Maps/Parsers/Stepmania/StepFile.cs
local stepmaniaLoader = {}

local title, subtitle, artist, titleTransLit, subtitleTransLit, artistTransLit, 
    credit, banner, background, lyricsPath, cdTitle, music,
    musicLength, offset, sampleStart, sampleLength, selectable, bpms,
    stops, charts

local folderPath

local measures = {}
local timings = {}

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

        if not string.endsWith(path, ".ssc") then
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
                    

                    if metaIndex == 2 then
                        line = line:gsub("\t", ""):gsub(":", ""):trim()
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
        else
            if line:find("#DIFFICULTY:") then
                line = line:gsub("\t", ""):gsub("#DIFFICULTY:", ""):trim()
                table.insert(notes, {
                    songName = songName,
                    name = line,
                    audioPath = audioPath
                })
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

---@param number time
--- Gets the current bpm from the notes ms time
local function getCurBPM(time)
    local cur = nil

    for i = 1, #timings do
        if timings[i].time <= time then 
            cur = timings[i]
        end
    end

    if cur ~= nil then 
        return cur.bpm
    else 
        return timings[1].bpm or 100
    end
end

function stepmaniaLoader.load(chart, folderPath, diffName, forNPS)
    measures = {{}}
    timings = {}
    local songName = ""
    local audioPath = ""

    local path = chart

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

    for line in chart:gmatch("[^\r\n]+") do
        local line = line:strip()
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
                local str = line:sub(9):trim():gsub(";", "")
                ---@diagnostic disable-next-line: cast-local-type
                offset = tonumber(str)
            end
        end

        if inBpms then
            line = string.gsub(line, "#BPMS:", ""):trim()

            ---@diagnostic disable-next-line: param-type-mismatch
            local split = string.gsub(string.gsub(line, ";", ""), ",", ""):split("=")
            local beat = tonumber(split[1])
            local bpm_ = tonumber(split[2])
            if beat and bpm_ then
                table.insert(bpms, {
                    beat = beat,
                    bpm = bpm_
                })
            end
            --print("[BPM] ", beat,bpm)

            if line:find(";") then
                inBpms = false
            end

            if not bpm then
                bpm = bpms[#bpms].bpm
            end
        end

        if inStops then
            line = string.gsub(line, "#STOPS:", ""):trim()

            ---@diagnostic disable-next-line: param-type-mismatch
            local split = string.gsub(string.gsub(line, ";", ""), ",", ""):split("=")
            local beat = tonumber(split[1])
            local length = tonumber(split[2])
            if beat and length then
                table.insert(stops, {
                    beat = beat,
                    length = length
                })
            end

            if line:find(";") then
                inStops = false
            end
        end

        -- now go to the notes`
        if line:find("#NOTES:") then
            notesTag = true
        end

        if notesTag then
            if not string.endsWith(path, ".ssc") then
                if line:find(":") then
                    -- check if its the correct difficulty
                    local diff = line:sub(1, #line - 1):trim()
                    if diff == "dance-double" then
                        inCorrectDiff = false
                    end
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
            end

            ::continue1::

            if inCorrectDiff and not line:find(":") then                
                if string.startsWith(line, ",") then
                    table.insert(measures, {})
                    goto continue
                end

                table.insert(measures[#measures], line)

                ::continue::
            end
        else
            if line:find("#DIFFICULTY:") then
                local diff = line:gsub("\t", ""):gsub("#DIFFICULTY:", ""):trim()
                if diff == diffName then 
                    inCorrectDiff = true
                else
                    inCorrectDiff = false
                end
            end
        end
    end

    local currentTime = -offset * 1000
    local totalBeats = 0

    for _, measure in ipairs(measures) do
        local beatTimePerRow = 4 / #measure

        if #bpms ~= 0 and totalBeats >= bpms[1].beat then
            table.insert(timings, {
                time = currentTime,
                sig = 4,
                bpm = bpms[1].bpm
            })

            table.remove(bpms, 1)
        end

        for _, row in ipairs(measure) do
            local row = row:splitAllCharacters()

            for i = 1, 4 do -- only play left side of "dance-double" if its selected
                local noteType = tonumber(row[i])
                local lane = i

                if noteType == 1 then
                    local ho = HitObject(currentTime, lane, 0)
                    table.insert(states.game.Gameplay.unspawnNotes, ho)
                elseif noteType == 2 then
                    holdsInfo[lane].startTime = currentTime
                elseif noteType == 3 then
                    if holdsInfo[lane] then
                        local ho = HitObject(holdsInfo[lane].startTime, lane, currentTime)
                        table.insert(states.game.Gameplay.unspawnNotes, ho)
                    end
                end
            end

            currentTime = currentTime + (60000 / getCurBPM(currentTime)) * 4 / #measure
            totalBeats = totalBeats + beatTimePerRow

            if #stops ~= 0 and totalBeats >= stops[1].beat then
                currentTime = currentTime + (stops[1].length * 1000)

                table.insert(states.game.Gameplay.sliderVelocities, {
                    startTime = currentTime - (stops[1].length * 1000),
                    multiplier = 1
                })

                table.remove(stops, 1)
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