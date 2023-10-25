--[[----------------------------------------------------------------------------

This file is apart of Rit; a free and open sourced rhythm game made with LÖVE.

Copyright (C) 2023 GuglioIsStupid

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

------------------------------------------------------------------------------]]

-- https://github.com/Quaver/Quaver.API/blob/f798abe059f966573086ab47438b7a6bff144b67/Quaver.API/Maps/Parsers/Stepmania/StepFile.cs

local stepmaniaLoader = {}

local title, subtitle, artist, titleTransLit, subtitleTransLit, artistTransLit, 
    credit, banner, background, lyricsPath, cdTitle, music,
    musicLength, offset, sampleStart, sampleLength, selectable, bpms,
    stops, charts

local function parseBpms(line)
    local bpms = {}
    local split = line:split(",")

    for i, bpm in ipairs(split) do
        local bpmSplit = bpm:gsub(",", ""):gsub(";", ""):split("=")
        if #bpmSplit ~= 2 then
            goto continue
        end

        --[[ bpms[#bpms+1] = {
            beat = tonumber(bpmSplit[1]),
            bpm = tonumber(bpmSplit[2]),
        } ]]
        table.insert(bpms, {
            beat = tonumber(bpmSplit[1] or 0),
            bpm = tonumber(bpmSplit[2] or 222.22),
        })

        ::continue::
    end

    return bpms
end

local function parseStops(line)
    local stops = {}
    local split = line:split(",")

    for i, stop in ipairs(split) do
        if (stop ~= nil and stop ~= "") then
            goto continue
        end

        local stopSplit = stop:gsub(",", ""):gsub(";", ""):split("=")
        if #stopSplit ~= 2 then
            goto continue
        end

        stops[#stops+1] = {
            beat = tonumber(stopSplit[1]),
            seconds = tonumber(stopSplit[2]),
        }

        ::continue::
    end

    return stops
end

local function parseMeasure(line)
    local notes = {}

    for i, char in ipairs(line:splitAllCharacters()) do
        table.insert(notes, tonumber(char))
    end

    return notes
end

local function parse(lines)
    local currentChart = nil

    local inBpms, inStops = false, false

    for i, line in ipairs(lines) do
        local trimmedLine = line:trim()

        if trimmedLine:startsWith("#") and trimmedLine:find(":") then
            local split = trimmedLine:split(":")

            local key = split[1]:gsub("#", ""):trim()
            local value
            if split[2] then
                value = split[2]:gsub(";", ""):gsub(":", ""):trim()
            end

            if key == "TITLE" then
                title = value
            elseif key == "SUBTITLE" then
                subtitle = value
            elseif key == "ARTIST" then
                artist = value
            elseif key == "TITLETRANSLIT" then
                titleTransLit = value
            elseif key == "SUBTITLETRANSLIT" then
                subtitleTransLit = value
            elseif key == "ARTISTTRANSLIT" then
                artistTransLit = value
            elseif key == "CREDIT" then
                credit = value
            elseif key == "BANNER" then
                banner = value
            elseif key == "BACKGROUND" then
                background = value
            elseif key == "LYRICSPATH" then
                lyricsPath = value
            elseif key == "CDTITLE" then
                cdTitle = value
            elseif key == "MUSIC" then
                music = value
            elseif key == "MUSICLENGTH" then
                musicLength = tonumber(value)
            elseif key == "OFFSET" then
                offset = tonumber(value)
            elseif key == "SAMPLESTART" then
                sampleStart = tonumber(value)
            elseif key == "SAMPLELENGTH" then
                sampleLength = tonumber(value)
            elseif key == "SELECTABLE" then
            elseif key == "BPMS" then
                inBpms = true
                bpms = parseBpms(value)
                if line:find(";") then
                    inBpms = false
                end
            elseif key == "STOPS" then
                inStops = true

                stops = (value == nil or value == "") and {} or parseStops(value)
                if line:find(";") then
                    inStops = false
                end
            elseif key == "NOTES" then
                local chart = {measures = {}}
                currentChart = chart
                charts[#charts+1] = chart
            end
        elseif inBpms then
            addRangeBpms(parseBpms(line))
            if line:find(";") then
                inBpms = false
            end
        elseif inStops then
            addRangeStops(parseStops(line))
            if line:find(";") then
                inStops = false
            end
        elseif trimmedLine:startsWith("//") then
            -- comment
        elseif currentChart and not currentChart.grooveRadarValues then
            local value = trimmedLine:gsub(":", "")

            if not currentChart.type then
                currentChart.type = value
            elseif not currentChart.description then
                currentChart.description = value
            elseif not currentChart.difficulty then
                currentChart.difficulty = value
            elseif not currentChart.numericalMeter then
                currentChart.numericalMeter = value
            elseif not currentChart.grooveRaderValues then
                currentChart.grooveRadarValues = value
            end
        elseif currentChart and currentChart.grooveRadarValues and not (trimmedLine == nil or trimmedLine == "") then
            if trimmedLine:startsWith(",") then
                currentChart.measures = {
                    {}
                }
            end
            -- currentChart.Measures.Last().Notes.Add(StepFileChartMeasure.ParseLine(trimmedLine));
            currentChart.measures[#currentChart.measures+1] = {
                notes = parseMeasure(trimmedLine),
            }
        end
    end
end

function stepmaniaLoader.load(chart, folderPath, forDiff)
    charts = {}
    parse(love.filesystem.read(chart):split("\n"))

    audioFile = love.audio.newSource(folderPath .. "/" .. music, "stream")

    __title = title
    __diffName = charts[1].difficulty

    local totalBeats = 0
    local bpmCache = bpms
    local stopCache = stops

    local chart = charts[1]

    local currentTime = -offset * 1000

    for i, measure in ipairs(chart.measures) do
        if not measure.notes then
            goto continue
        end
        local beatTimePerRow = 4 / #measure.notes
        local storedLongs = {}

        if #bpmCache ~= 0 and totalBeats >= bpmCache[1].beat then
            bpm = bpmCache[1].bpm
            crochet = (60 / bpm) * 1000
            stepCrochet = crochet / 4

            table.remove(bpmCache, 1)
        end

        for j, row in ipairs(measure.notes) do
                if row == 0 then -- Nothing
                elseif row == 1 then -- Normal
                    --StartTime = (int) Math.Round(currentTime, MidpointRounding.AwayFromZero),
                    local startTime = math.round(currentTime)
                    local lane = j
                    local ho = HitObject(startTime, lane, nil, false)
                    table.insert(states.game.Gameplay.unspawnNotes, ho)
                elseif row == 2 then -- Head
                    --[[
                        qua.HitObjects.Add(new HitObjectInfo
                                    {
                                        StartTime = (int) Math.Round(currentTime, MidpointRounding.AwayFromZero),
                                        EndTime = int.MinValue,
                                        Lane = i + 1
                                    });
                    ]]
                    local startTime = math.round(currentTime)
                    local lane = j -- opposite of math.huge for endTime
                    local endTime = -math.huge
                    storedLongs[i] = {
                        startTime = startTime,
                        lane = lane,
                        endTime = endTime,
                    }
                elseif row == 3 then
                    local lane = j
                    local long = storedLongs[lane] or {startTime = currentTime, lane = j, endTime = currentTime}
                    local startTime = long.startTime
                    local endTime = math.round(currentTime)

                    local length = endTime - startTime

                    local hasSustain = length ~= startTime

                    local ho = HitObject(startTime, lane, nil, false)
                    table.insert(states.game.Gameplay.unspawnNotes, ho)

                    length = math.floor(length / stepCrochet)

                    if length > 0 then
                        for sustain = 0, length do
                            local oldHo = states.game.Gameplay.unspawnNotes[#states.game.Gameplay.unspawnNotes]

                            local slider = HitObject(startTime + (stepCrochet*sustain), lane, oldHo, true)
                            table.insert(ho.tail, slider)
                            table.insert(states.game.Gameplay.unspawnNotes, slider)
                            slider.correctionOffset = (ho.height * 0.925)/2
                            oldHo:updateHitbox()
                        end
                    end
                end
        end
        ::continue::
    end
end

function stepmaniaLoader.getDifficulties(chart)
    -- just returns a list of all the difficulties (names)

    local diffs = {}
    local songName = ""

    local lines = {}
    for line in love.filesystem.lines(chart) do
        table.insert(lines, line)
    end
    local lineIndex = 1

    for line in love.filesystem.lines(chart) do

        if line:find("#TITLE:") then
            line = line:gsub("#TITLE:", ""):gsub(";", "")
            songName = line
        end
        if line:find("#NOTES") then
            local diff = lines[lineIndex + 3]:split(":")[1]
            table.insert(diffs, {
                name = diff:trim(),
                songName = songName,
            })
        end

        lineIndex = lineIndex + 1
    end

    return diffs
end

return stepmaniaLoader