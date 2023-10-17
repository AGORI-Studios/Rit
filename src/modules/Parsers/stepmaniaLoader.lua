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

function smLoader.load(chart, folderPath, forDiff)
    curChart = "stepmania"

    local readingNotes = false
    local readingBPMS = false
    local bpmIndex = 1
    
    local diffIndex = 1
    local beat = 0
    local measureIndex = 0

    local meta = {
        bpms = {},
        difficulties = {},
        songName = "",
        audioPath = "",
    }
    local measure = {}

    for line in love.filesystem.lines(chart) do
        local cont = true

        if cont then
            if not readingNotes then
                line = line:gsub(";", "")
                local stuff = line:split(":")
                if #stuff < 2 then
                    stuff = {line:gsub(":", "")}
                end

                if readingBPMS then
                    if line:find("#") or line:find(";") then
                        readingBPMS = false
                    end
                end

                if not readingBPMS then
                    if stuff[1] == "#BPMS" then
                        --readingBPMS = true
                        --if (stuff.size() != 1)
                        if #stuff ~= 1 then
                            bpmSeg = stuff[2]:split(",")
                            if #bpmSeg ~= 0 then
                                --for (int ii = 0; ii < bpmSeg.size(); ii += 2)
                                for ii = 1, #bpmSeg, 2 do
                                    local seg = {
                                        --std::stod(Chart::split(bpmSeg[ii], '=')[0]);
                                        startBeat = bpmSeg[ii]:split("=")[1],
                                        endBeat = math.huge,
                                        length = math.huge,
                                        bpm = bpmSeg[ii]:split("=")[2],
                                        startTime = 0
                                    }

                                    if bpmIndex ~= 1 then
                                        --meta.bpms.push_back(seg);
                                        local prevSeg = meta.bpms[bpmIndex - 1]
                                        prevSeg.endBeat = seg.startBeat
                                        prevSeg.length = ((prevSeg.endBeat - prevSeg.startBeat) / (prevSeg.bpm / 60)) * 1000
                                        seg.startTime = prevSeg.startTime + prevSeg.length
                                    end

                                    table.insert(meta.bpms, seg)
                                    bpmIndex = bpmIndex + 1
                                end
                            end
                        end
                    end
                    if stuff[1]:find("#NOTES") then
                        readingNotes = true
                        local diff = {
                            charter = "n/a",
                            name = "n/a",
                            notes = {},
                        }
                        table.insert(meta.difficulties, diff)
                    end

                    if stuff[1] == "#TITLE" then
                        meta.songName = stuff[2]
                    end
                    if stuff[1] == "#MUSIC" then
                        meta.audioPath = folderPath .. "/" .. stuff[2]
                        audioFile = love.audio.newSource(meta.audioPath, "stream")
                    end
                end
            else
                local line = line:gsub(";", "")
                local stuff = line:split(":")
                if line:find(":") and #stuff > 1 then
                    stuff[1] = stuff[1]:gsub(":", "")
                    stuff[1] = stuff[1]:gsub(" ", "")

                    if diffIndex == 2 then
                        meta.difficulties[diffIndex].charter = stuff[1]
                    elseif diffIndex == 3 then
                        meta.difficulties[diffIndex].name = stuff[1]
                    end
                    diffIndex = diffIndex + 1
                else
                    diffIndex = 1

                    if line:find(",") and line:find(";") then
                        --measure->push_back(iss.str());
                        table.insert(measure, line)
                    else
                        local lengthInRows = 192 / #measure
                        local rowIndex = 1

                        for i = 1, #measure do
                            local noteRow = (measureIndex * 192) + (lengthInRows * rowIndex)
                            beat = noteRow / 48

                            for n = 1, #measure[i] do
                                local thing = measure[i]:sub(n, n)

                                if thing == "0" then
                                    goto continue
                                end

                                local note = {
                                    beat = beat,
                                    -- convert beat to ms
                                    time = ((beat / meta.bpms[1].bpm) * 60) * 1000,
                                    lane = n,
                                }
                                if thing ~= "M" then -- mine
                                    if thing == "1" then
                                        note.type = "normal"
                                    elseif thing == "2" then
                                        note.type = "hold"
                                    elseif thing == "3" then
                                        note.type = "tail"
                                    elseif thing == "4" then
                                        note.type = "head"
                                    end
                                end

                                meta.difficulties[1].notes[noteRow] = note
                            end

                            ::continue::
                            rowIndex = rowIndex + 1
                        end

                        measure = {}
                        measureIndex = measureIndex + 1
                    end
                end
            end
        end
    end

    -- create our notes
    for _, diff in ipairs(meta.difficulties) do
        for _, note in ipairs(diff.notes) do
            if note.type == "normal" then
                local ho = HitObject(note.time, note.lane, nil, false)
                table.insert(states.game.Gameplay.unspawnNotes, ho)
            elseif note.type == "hold" then
                local ho = HitObject(note.time, note.lane, nil, true)
                table.insert(states.game.Gameplay.unspawnNotes, ho)
            elseif note.type == "head" then
                local ho = HitObject(note.time, note.lane, nil, true)
                table.insert(states.game.Gameplay.unspawnNotes, ho)
            elseif note.type == "tail" then
                local ho = HitObject(note.time, note.lane, nil, true)
                table.insert(states.game.Gameplay.unspawnNotes, ho)
            end
        end
    end

    return meta
end

function smLoader.getDifficulties(chart)
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

return smLoader