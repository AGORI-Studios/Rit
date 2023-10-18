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
local quaverLoader = {}

function quaverLoader.load(chart, folderPath, forDiff)

    curChart = "Quaver"

    local chart = tinyyaml.parse(love.filesystem.read(chart):gsub("\r\n", "\n"))
    
    local meta = {
        format = "Quaver",
        title = chart.Title,
        artist = chart.Artist,
        source = chart.Source,
        tags = chart.Tags,
        name = chart.DifficultyName,
        creator = chart.Creator,
        audioPath = chart.AudioFile,
        backgroundFile = chart.BackgroundFile,
        previewTime = chart.PreviewTime or 0,
        noteCount = 0,
        length = 0,
        bpm = 0,
        inputMode = chart.Mode
    }

    audioFile = love.audio.newSource(folderPath .. "/" .. meta.audioPath, "stream")

    for i = 1, #chart.TimingPoints do
        -- if its the first one, set meta.bpm to the bpm of the first timing point
        local timingPoint = chart.TimingPoints[i]
        if i == 1 then
            meta.bpm = timingPoint.Bpm
            bpm = meta.bpm
            crochet = (60/bpm)*1000
            stepCrochet = crochet/4
        end
    end

    for i = 1, #chart.HitObjects do
        local hitObject = chart.HitObjects[i]
        local startTime = hitObject.StartTime
        local endTime = hitObject.EndTime or 0
        local lane = hitObject.Lane

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

    __title = meta.title
    __diffName = meta.name
end

return quaverLoader