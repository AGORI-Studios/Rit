--[[----------------------------------------------------------------------------

This file is apart of Rit; a free and open sourced rhythm game made with LÖVE.

Copyright (C) 2023 GuglioIsStupid

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the HitObjectpe that it will be useful,
but WITHitObjectUT ANY WARRANTY; witHitObjectut even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You sHitObjectuld have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

------------------------------------------------------------------------------]]
local smLoader = {}
local chart = nil
local sm = {}
local header = {}
local bpm = {}

local parsingBpm, parsingStop, parsingNotes, parsingNotesMetaData = false, false, false, false

local function newChart()
    local _chart = {
        measure = 0,
        offset = 0,
        mode = 0,
        notes = {},
        linesPerMeasure = {},
        metaData = {},
    }
    chart = _chart
    table.insert(sm.charts, _chart)
end

local function processLine(line)
    if parsingBpm then
        --
        return
    end
    if parsingStop then
        --
        return
    end
    if line:find("^#NOTES") then
        parsingNotes = true
        parsingNotesMetaData = true
        newChart()
    elseif parsingNotesMetaData then
        table.insert(chart.metaData, line:match("^(.-):.*$"))
        if #chart.metaData == 5 then
            parsingNotesMetaData = false
        end
    elseif self.parsingNotes and not line:find(",") and line:find("//") then
        return
    elseif self.parsingNotes and line:find("^[^,^;]+$") then
        parsingNotesMetaData = false
        processNotesLine(line)
    elseif self.parsingNotes and line:find("^;.*$") then
        parsingNotes = false
    elseif line:find("#%S+:.*") then
        processHeaderLine(line)
    end
end

local function processHeaderLine(line)
    local key, value = line:match("^#(%S+):(.*);$")
    if not key then
        key, value = line:match("^#(%S+)%s(.*)$")
    end
    key = key:upper()
    header[key] = value

    if key == "BPMS" then
        processBPM(value)
        if not line:find(";") then
            parsingBpm = true
        end
    end
end

local function processBPM(line)
    local tempValues = line:gsub(";", ""):split(",")
    for _, tempoValue in ipairs(tempoValues) do
        local beat, temp = tempoValue:match("^(.+)=(.+)$")
        if beat and tempo then
            table.insert(bpm, {
                beat = tonumber(beat),
                tempo = tonumber(tempo),
            })
        end
    end
end

local function processNotesLine(line)
    if tonumber(line) then
        chart.mode = math.max(chart.mode, #line)
    end
    for i = 1, #line do
        local noteType = line:sub(i,i)
        if noteType ~= "0" then
            table.insert(chart.notes, {
                type = noteType,
                measure = chart.measure,
                offset = chart.offset,
                line = i,
            })
        end
    end
    chart.offset = chart.offset + 1
    chart.linesPerMeasure[chart.measure] = (chart.linesPerMeasure[chart.measure] or 0) + 1
end

function smLoader.load(chart, folderPath, forDiff)
    curChart = "stepmania"

    sm = {
        header = {},
        bpm = {},
        stop = {},
        charts = {}
    }

    metaData = {
        format = "stepmania",

    }

    local chart = love.filesystem.read(chart)
    for _, line in ipairs(chart:split("\n")) do
        processLine(line)
    end
    
    -- make it work like the other loaders
    local chart = sm.charts[1]
    local notes = chart.notes
    local linesPerMeasure = chart.linesPerMeasure
    local metaData = chart.metaData

    local meta = {
        format = "stepmania",
        title = metaData[1],
        artist = metaData[2],
        source = metaData[3],
        tags = metaData[4],
        name = metaData[5],
        creator = metaData[6],
        audioPath = header["MUSIC"],
        backgroundFile = header["BACKGROUND"],
        previewTime = header["OFFSET"] or 0,
        noteCount = 0,
        length = 0,
        bpm = 0,
        inputMode = chart.mode
    }

    audioFile = love.audio.newSource(folderPath .. "/" .. meta.audioPath, "stream")

    for i = 1, #bpm do
        -- if its the first one, set meta.bpm to the bpm of the first timing point
        local timingPoint = bpm[i]
        if i == 1 then
            meta.bpm = timingPoint.tempo
            bpm = meta.bpm
            crochet = (60/bpm)*1000
            stepCrochet = crochet/4
        end
    end

    for i = 1, #notes do
        local note = notes[i]
        local startTime = note.offset
        local endTime = note.endTime or 0
        local lane = note.line

        local length = endTime - startTime

        local hasSustain = length ~= startTime

        local ho = HitObject(startTime, lane, nil, false)
        table.insert(states.game.Gameplay.unspawnNotes, ho)

        length = math.floor(length / stepCrochet)

        if length > 0 then
            for sustain = 0, length do
                local oldHo = states.game.Gameplay.unspawnNotes[#states.game.Gameplay.unspawnNotes]

                local slider = HitObject(startTime + (stepCrochet*sustain), lane, oldHo, true)
                table.insert(states.game.Gameplay.unspawnNotes, slider)
            end
        end
    end

    return meta

end

return smLoader