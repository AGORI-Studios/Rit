-- https://github.com/Quaver/Quaver.API/blob/f798abe059f966573086ab47438b7a6bff144b67/Quaver.API/Maps/Parsers/Stepmania/StepFile.cs

local stepmaniaLoader = {}

local title, subtitle, artist, titleTransLit, subtitleTransLit, artistTransLit, 
    credit, banner, background, lyricsPath, cdTitle, music,
    musicLength, offset, sampleStart, sampleLength, selectable, bpms,
    stops, charts

local folderPath

local measureTicks = 192
local beatTicks = 48
local stepTicks = 12
local curLine = 0

local Tempo = Object:extend()
local line

function Tempo:new(bpm, tick, time)
    self.bpm = bpm
    self.tick = tick
    self.time = time
end

function Tempo:timeToTick(time)
    return math.round((self.tick + (time - self.time) * measureTicks * self.bpm / 60) / 240000)
end

function Tempo:tickToTime(tick)
    return self.time + (tick - self.tick) * 240000 / measureTicks / self.bpm
end

local tempoMarkers = {}
local sectionNum = 0
local offset = 0

local allNotes = {}

function timeToTick(time)
    for i = 1, #tempoMarkers do
        local tempo = tempoMarkers[i+1]
        if tempo and tempo.time > time then
            return tempo:timeToTick(time)
        elseif not tempo then
            return tempoMarkers[i]:timeToTick(time)
        end
    end
end

function tickToTime(tick)
    for i = 1, #tempoMarkers do
        local tempo = tempoMarkers[i+1]
        if tempo and tempo.tick > tick then
            return tempo:tickToTime(tick)
        elseif not tempo then
            return tempoMarkers[i]:tickToTime(tick)
        end
    end
end

function tickToBPM(tick)
    for i = 1, #tempoMarkers do
        local tempo = tempoMarkers[i+1]
        if tempo and tempo.tick > tick then
            return tempo.bpm
        elseif not tempo then
            return tempoMarkers[i].bpm
        end
    end
end

function getTagValue(line, tag)
    if line:find("^#" .. tag .. ":") then
        return line:gsub("^#" .. tag .. ":", ""):gsub(";", "")
    end
end

function parseSMbpms(bpmString)
    --#BPMS:0.000=165.000,7.750=354.000,8.000=165.000;
    local bpmRe = "([%d%.]+)=([%d%.]+)"
    local smBpms = bpmString:split(",")
    for i = 1, #smBpms do
        print(smBpms[i])
        local reMatch = smBpms[i]:match(bpmRe)
        if reMatch and reMatch.start() == 0 then
            local currentTick = math.round(tonumber(reMatch[1]) * beatTicks)
            local currentBpm = tonumber(reMatch[2])
            local currentTime = tickToTime(currentTick)
            tempoMarkers[#tempoMarkers+1] = Tempo(currentBpm, currentTick, currentTime)
        end
    end
end

function stepmaniaLoader.getDifficulties(chart)
    local chart = love.filesystem.read(chart)
    local diffs = {}
    local lines = chart:split("\n")
    local songName = ""
    for i = 1, #lines do
        local line = lines[i]
        if line:find("^#TITLE:") then
            songName = line:gsub("^#TITLE:", ""):gsub(";", "")
        end
        if line:find("^#NOTES:") then
            local diff = lines[i+3]:split(":")[1]

            diffs[#diffs+1] = {
                songName = songName,
                name = diff,
                BackgroundFile = "",
            }
        end
    end
    return diffs
end

function stepmaniaLoader.load(chart, folderPath_, forDiff)
    curChart = "Stepmania"
    folderPath = folderPath_
    local chart = love.filesystem.read(chart)
    bpm = 0
    crochet = 0
    stepCrochet = 0
    
    stepmaniaLoader.parseChart(chart)

    __title = title
    ---@diagnostic disable-next-line: undefined-global
    __diffName = diff
end

local function readLine(lines)
    local line = lines[1]
    if line then
        table.remove(lines, 1)
        curLine = curLine + 1
    end
    return line
end

function stepmaniaLoader.parseChart(chart)
    local lines = chart:split("\n")

    while #lines > 0 do
        line = readLine(lines)
        local value
        if line:find("^#TITLE:") then
            title = line:gsub("^#TITLE:", ""):gsub(";", "")
            line = readLine(lines)
            goto continue
        end
        if line:find("^#OFFSET:") then
            local value = line:gsub("^#OFFSET:", ""):gsub(";", "")
            offset = tonumber(value) * 1000
            line = readLine(lines)
            goto continue
        end
        if line:find("^#BPMS:") then
            parseSMbpms(line:gsub("^#BPMS:", ""):gsub(";", ""))
            line = readLine(lines)
            goto continue
        end
        if line:find("^#MUSIC:") then
            local value = line:gsub("^#MUSIC:", ""):gsub(";", "")
            print(folderPath .. "/" .. value)
            states.game.Gameplay.soundManager:newSound("music", folderPath .. "/" .. value:strip(), 1, true, "stream")
            line = readLine(lines)
            goto continue
        end

        if line:strip() == "#NOTES:" then
            line = readLine(lines)
            local isDouble = (line:strip() == "dance-double:")
            -- double not supported (for now)
            if (line:strip() ~= "dance-single:") and not (not isDouble) then
                line = readLine(lines)
                goto continue
            end
            line = readLine(lines)
            line = readLine(lines)
            line = readLine(lines)
            local trackedHolds = {}
            while line and line:strip()[1] ~= ";" do
                measureNotes = {}
                if not line then break end
                while line and line:strip()[1] ~= "," do
                    if line:strip():match("^%d") then
                        measureNotes[#measureNotes+1] = line:strip():gsub(",", ""):splitAllCharacters()
                    end
                    line = readLine(lines)
                    if not line then break end
                
                    ticksPerRow = measureTicks / #measureNotes
                    bpm = tickToBPM(sectionNum * measureTicks)

                    local notes = {}
                    for i = 1, #measureNotes do
                        local notesRow = measureNotes[i]
                        for j = 1, #notesRow do
                            if notesRow[j] == "1" --[[ or notesRow[j] == "2" or notesRow[j] == "4" ]] then
                                local time = tickToTime(sectionNum * measureTicks + (i-1) * ticksPerRow)
                                local lane = j
                                local endTime = 0
                                local note = {time, lane, endTime}
                                table.insert(notes, note)
                            end
                        end
                    end
                    sectionNum = sectionNum + 1
                    table.insert(allNotes, notes)
                    if line then
                        if line:strip()[1] == ";" then
                            line = readLine(lines)
                        end
                    end
                    if not line then break end
                end
            end
        end

        ::continue::
    end

    for i = 1, #allNotes do
        for j = 1, #allNotes[i] do
            local note = allNotes[i][j]
            local startTime = note[1]
            local lane = note[2]
            local endTime = nil
            if lane == 0 then goto continue end

            local ho = HitObject(startTime, lane, endTime)
            table.insert(states.game.Gameplay.unspawnNotes, ho)
            ::continue::
        end
    end

    __title = title
    ---@diagnostic disable-next-line: undefined-global
    __diffName = diff
end


return stepmaniaLoader