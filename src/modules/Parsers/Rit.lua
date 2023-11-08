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
local ritLoader = {}
local currentBlock = ""
local folderPath

local title, diff

function ritLoader.load(chart, folderPath_, forDiff)
    curChart = "Rit"
    folderPath = folderPath_

    local chart = love.filesystem.read(chart)
    bpm = 0
    crochet = 0
    stepCrochet = 0

    for _, line in ipairs(chart:split("\n")) do
        ritLoader.processLine(line)
    end

    __title = title
    __diffName = diff
end

function ritLoader.processLine(line)
    if line:find("^%[") then
        local _currentBlock, lineEnd = line:match("^%[(.+)%](.*)$")
        currentBlock = _currentBlock
        ritLoader.processLine(lineEnd)
    else
        local currentBlock = currentBlock:trim()
        local trimmed = line:trim()
        if trimmed == "" then
            -- empty line
        elseif currentBlock == "Velocities" then
            ritLoader.processVelocities(line)
        elseif currentBlock == "Hits" then
            ritLoader.addHitObject(line)
        elseif currentBlock == "Meta" then
            ritLoader.processMetadata(line)
        elseif currentBlock == "Timings" then
            ritLoader.processTimings(line)
        end
    end
end

function ritLoader.processVelocities(line)
    local info = line:split(":")
    table.insert(states.game.Gameplay.sliderVelocities, {
        startTime = tonumber(info[1]),
        multiplier = tonumber(info[2])
    })
end

function ritLoader.addHitObject(line)
    local info = line:split(":")
    local startTime = tonumber(info[1])
    local endTime = tonumber(info[2])
    local lane = tonumber(info[3])

    if not startTime then goto continue end
    local hasSustain = true

    hasSustain = endTime > 0 and endTime ~= startTime
    local length = endTime - startTime

    local ho = HitObject(startTime, lane, nil, false)
    table.insert(states.game.Gameplay.unspawnNotes, ho)

    length = math.floor(length / stepCrochet)

    if length > 0 and hasSustain then
        for sustain = 0, length do
            local oldHo = states.game.Gameplay.unspawnNotes[#states.game.Gameplay.unspawnNotes]

            local slider = HitObject(startTime + (stepCrochet*sustain), lane, oldHo, true)
            table.insert(ho.tail, slider)
            table.insert(states.game.Gameplay.unspawnNotes, slider)
            oldHo:updateHitbox()
            slider.offset.y = slider.offset.y + 25
        end
    end

    ::continue::
end

function ritLoader.processMetadata(line)
    local key, value = line:match("^(%a+):%s?(.*)")
    if key == "SongTitle" then
        title = value
    elseif key == "SongDiff" then
        diff = value
    elseif key == "KeyAmount" then
        states.game.Gameplay.mode = tonumber(value)
    elseif key == "AudioFile" then
        local value = value:trim()
        audioFile = love.audio.newSource(folderPath .. "/" .. value, "stream")
    end
end

function ritLoader.processTimings(line)
    if bpm == 0 then
        bpm = tonumber(line:split(":")[2])
        crochet = (60/bpm)*1000
        stepCrochet = crochet/4
    else
        
    end
end

return ritLoader