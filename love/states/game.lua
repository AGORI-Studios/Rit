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

function resize(img, width, height)
    local scaleX = width / img:getWidth()
    local scaleY = height / img:getHeight()

    return scaleX, scaleY
end

local function pause()
    musicTimeDo = false 
    love.audio.pause(audioFile)
    if voices then
        love.audio.pause(voices)
    end
end

local died
inputList = {
    "one4",
    "two4",
    "three4",
    "four4"
}
musicPosValue = {1000}
musicPitch = {1}
function addJudgement(judgement)
    scoring[judgement] = scoring[judgement] + 1
    if judgement ~= "Miss" then
        combo = combo + 1
        if comboTimer then 
            Timer.cancel(comboTimer)
        end
        comboSize.y = 1
        comboTimer = Timer.tween(
            0.1,
            comboSize,
            {
                y = 1.85
            },
            "in-out-quad",
            function()
                Timer.tween(
                    0.1,
                    comboSize,
                    {
                        y = 1.6
                    },
                    "in-out-quad"
                )
            end
        )
    else
        combo = 0
    end
    curJudgement = judgement

    if judgeTimer then 
        Timer.cancel(judgeTimer)
    end
    ratingsize.x = 1
    ratingsize.y = 1
    judgeTimer = Timer.tween(
        0.1,
        ratingsize,
        {
            x = 1.15,
            y = 1.15
        },
        "in-out-quad",
        function()
            Timer.tween(
                0.1,
                ratingsize,
                {
                    x = 0.85,
                    y = 0.85
                },
                "in-out-quad"
            )
        end
    )
end

return {
    enter = function(self)
        now = os.time()
        scoring = {
            score = 0,
            accuracy = 0,
            ["Marvellous"] = 0,
            ["Perfect"] = 0,
            ["Great"] = 0,
            ["Good"] = 0,
            ["Miss"] = 0
        }
    
        songRate = 1
    
        game = require "states.game"
        skinSelect = require "states.skinSelect"
        songSelect = require "states.songSelect"
    
        musicTime = -settings.startTime 
    
        PRESSEDMOMENTS = {
            [1] = 1,
            [2] = 1,
            [3] = 1,
            [4] = 1,
            [5] = 1,
            [6] = 1,
            [7] = 1
        }
        lastReportedPlaytime = 0
        previousFrameTime = love.timer.getTime() * 1000
        additionalScore = 0
        additionalAccuracy = 0
        noteCounter = 0
    
        died = false
    
        ratingsize = {
            x = 1,
            y = 1
        }
        comboSize = {
            x = 1.6,
            y = 1.6
        }
    
        scoring["Marvellous"] = 0
        scoring["Perfect"] = 0
        scoring["Great"] = 0
        scoring["Good"] = 0
        scoring["Miss"] = 0
        combo = 0
    
        sv = 1 -- Scroll Velocity
    
        curJudgement = "none"

        health = 1
        died = false
        musicPosValue = {1000}
        musicPitch = {1}
    end,

    update = function(self, dt)
        if musicTimeDo and not died then
            local time = love.timer.getTime()

            --musicTime = musicTime + musicPosValue[1] * dt

            musicTime = musicTime + (time * musicPosValue[1]) - previousFrameTime
            previousFrameTime = time * musicPosValue[1]

            musicPos = ((musicTime) * (speed)+100)
        elseif not musicTimeDo then
            previousFrameTime = love.timer.getTime() * 1000
        elseif musicTimeDo and died then
            musicTime = musicTime + musicPosValue[1] * dt
            musicPos = ((musicTime) * (speed)+100)
        end
        absMusicTime = math.abs(musicTime)
        if (musicTime > 0) and not audioFile:isPlaying() and not died then
            if musicTimeDo then
                audioFile:play()
                if voices then -- support for fnf voices
                    voices:play()
                end
                debug.print("Playing audio file")
            end
        elseif musicTime > audioFile:getDuration() * 1000 then
            state.switch(resultsScreen, scoring, {songTitle, songDifficultyName}, false)
        end
        for i = 1, #charthits do
            for j = 1, #charthits[i] do
                if charthits[i][j] then
                    if charthits[i][j][1] - musicTime <= -100 then 
                        if not charthits[i][j][4] then
                            noteCounter = noteCounter + 1
                            additionalAccuracy = additionalAccuracy + 1.11
                            if health < 0 then
                                health = 0
                            end
                            if accuracyTimer then
                                Timer.cancel(accuracyTimer)
                            end
                            accuracyTimer = Timer.tween(
                                0.35,
                                scoring,
                                {accuracy = additionalAccuracy / noteCounter},
                                "out-quad",
                                function()
                                    accuracyTimer = nil
                                end
                            )
                            health = health - 0.270
                            addJudgement("Miss")
                        end
                        table.remove(charthits[i], 1)
                    end
                end
            end
        end
        -- accuracy = (function()
        --     if noteCounter < 1 then
        --         return 100.0
        --     else
        --         return additionalAccuracy/noteCounter
        --     end
        -- end)()
        
        presence = {
            details = (autoplay and "Autoplaying " or "Playing ")..songTitle.." - "..songDifficultyName..(not musicTimeDo and " - Paused" or ""), 
            state = "Score: "..string.format("%07d", round(scoring.score)).." - "..string.format("%.2f%%", scoring.accuracy).." - "..combo..(combo == noteCounter and " FC" or " combo"),
            largeImageKey = "totallyreallogo",
            largeImageText = "Rit"..(__DEBUG__ and " DEBUG MODE" or ""),
            startTimestamp = now
        }
        
        if chartEvents[1] then
            if chartEvents[1][1] <= absMusicTime then
                if settings.scrollvelocities then 
                    sv = chartEvents[1][2] 
                    for i = 1, 4 do 
                        noteImgs[i][2].scaleY = 1 * sv
                    end
                end
                --print(sv)j
                table.remove(chartEvents, 1)
            end
        end
        if bpmEvents[1] then
            if bpmEvents[1][1] then
                if bpmEvents[1][1] <= absMusicTime then
                    beatHandler.setBPM(bpmEvents[1][2])
                    table.remove(bpmEvents, 1)
                end
            end
            
        end
        beatHandler.update(dt)

        if input:pressed("pause") then 
            if musicTimeDo then 
                pause()
            else
                musicTimeDo = true
                if musicTime >= 0 then
                    audioFile:play()
                    if voices then -- support for fnf voices
                        voices:play()
                    end
                end
            end
        end

        for i = 1, #inputList do
            curInput = inputList[i]
            notes = charthits[i]
            if not autoplay then
                if input:pressed(curInput) then
                -- print("Pressed " .. curInput .. " at " .. musicPos .. "ms")
                    --print("Pressed " .. curInput)
                    if hitsoundCache[#hitsoundCache]:isPlaying() then
                        hitsoundCache[#hitsoundCache] = hitsoundCache[#hitsoundCache]:clone()
                        hitsoundCache[#hitsoundCache]:play()
                    else
                        hitsoundCache[#hitsoundCache]:play()
                    end
                    for hit = 2, #hitsoundCache do
                        if not hitsoundCache[hit]:isPlaying() then
                            hitsoundCache[hit] = nil -- Nil afterwords to prevent memory leak
                        end --                             maybe, idk how love2d works lmfao
                    end
                    if notes[1] then
                        --print(notes[1][1] - musicPos)
                        if not notes[1][4] and not notes[1][5] then
                            if notes[1][1] - musicTime >= -80 and notes[1][1] - musicTime <= 180 or (notes[2] and notes[1][5] and notes[2][1] - musicTime >= -80 and notes[2][1] - musicTime <= 180) then
                                noteCounter = noteCounter + 1
                                --print("Hit!")
                                --print(notes[1][1] - musicTime .. "ms")
                                pos = math.abs(notes[1][1] - musicTime)
                                if notes[2] and notes[1][5] and notes[2][1] - musicTime >= -80 and notes[2][1] - musicTime <= 180 then
                                    pos = math.abs(notes[2][1] - musicTime)
                                end
                                if pos < 45 then
                                    judgement = "Marvellous"
                                    health = health + 0.135
                                    additionalScore = additionalScore + 650
                                    additionalAccuracy = additionalAccuracy + 100
                                elseif pos < 60 then
                                    judgement = "Perfect"
                                    health = health + 0.135
                                    additionalScore = additionalScore + 500
                                    additionalAccuracy = additionalAccuracy + 100
                                elseif pos < 75 then
                                    judgement = "Great"
                                    health = health + 0.135
                                    additionalScore = additionalScore + 350
                                    additionalAccuracy = additionalAccuracy + 75.55
                                elseif pos < 120 then
                                    judgement = "Good"
                                    health = health + 0.135
                                    additionalScore = additionalScore + 200
                                    additionalAccuracy = additionalAccuracy + 66.66
                                else
                                    judgement = "Miss"
                                    health = health - 0.270
                                    additionalAccuracy = additionalAccuracy + 1.11
                                end

                                addJudgement(judgement)

                                if health > 2 then
                                    health = 2
                                end
                                if scoringTimer then 
                                    Timer.cancel(scoringTimer)
                                end
                                if accuracyTimer then
                                    Timer.cancel(accuracyTimer)
                                end
                                scoringTimer = Timer.tween(
                                    0.35,
                                    scoring,
                                    {score = additionalScore},
                                    "out-quad",
                                    function()
                                        scoringTimer = nil
                                    end
                                )
                                accuracyTimer = Timer.tween(
                                    0.35,
                                    scoring,
                                    {accuracy = additionalAccuracy / (noteCounter + (scoring["Miss"] or 0))},
                                    "out-quad",
                                    function()
                                        accuracyTimer = nil
                                    end
                                )
                                table.remove(notes, 1)
                            end
                        end
                    end 
                end

                if input:down(curInput) then
                    PRESSEDMOMENTS[i] = 2
                    if notes[1] then
                        if notes[1][4] then
                            if notes[1][1] - musicTime >= -80 and notes[1][1] - musicTime <= 25 then
                                table.remove(notes, 1)
                            end
                        end
                    end 
                else
                    PRESSEDMOMENTS[i] = 1
                end
            else
                if notes[1] then
                    if notes[1][1] - musicTime >= -80 and notes[1][1] - musicTime <= 5 then
                        if not notes[1][4] then 
                            noteCounter = noteCounter + 1
                            if hitsoundCache[#hitsoundCache]:isPlaying() then
                                hitsoundCache[#hitsoundCache] = hitsoundCache[#hitsoundCache]:clone()
                                hitsoundCache[#hitsoundCache]:play()
                            else
                                hitsoundCache[#hitsoundCache]:play()
                            end
                            for hit = 2, #hitsoundCache do
                                if not hitsoundCache[hit]:isPlaying() then
                                    hitsoundCache[hit] = nil -- Nil afterwords to prevent memory leak
                                end --                             maybe, idk how love2d works lmfao
                            end
                            pos = math.abs(notes[1][1] - musicTime)
                            judgement = "Marvellous"
                            health = health + 0.135
                            additionalScore = additionalScore + 650
                            additionalAccuracy = additionalAccuracy + 100
                            addJudgement(judgement)

                            if health > 100 then
                                health = 1
                            end
                            if scoringTimer then 
                                Timer.cancel(scoringTimer)
                            end
                            if accuracyTimer then
                                Timer.cancel(accuracyTimer)
                            end
                            scoringTimer = Timer.tween(
                                0.35,
                                scoring,
                                {score = additionalScore},
                                "out-quad",
                                function()
                                    scoringTimer = nil
                                end
                            )
                            accuracyTimer = Timer.tween(
                                0.35,
                                scoring,
                                {accuracy = additionalAccuracy / (noteCounter + (scoring["Miss"] or 0))},
                                "out-quad",
                                function()
                                    accuracyTimer = nil
                                end
                            )
                        end
                        
                        table.remove(notes, 1)
                    end
                end
            end
        end
        -- print graphics memory usage
        --print(tostring(math.floor(love.graphics.getStats().texturememory / 1048576)) .. "MB")

        if health <= 0 and not died then
            died = true
            Timer.tween(3, musicPosValue, {0}, "out-quad")
            Timer.tween(3, musicPitch, {0.005}, "out-quad", function()
                audioFile:stop()
                Timer.after(0.6, function()
                    state.switch(resultsScreen, scoring, {songTitle, songDifficultyName}, true)
                end)
            end)
        elseif died then
            if musicPitch[1] < 0 then 
                musicPitch[1] = 0
            end
            audioFile:setPitch(musicPitch[1])
            if voices then
                voices:setPitch(musicPitch[1])
            end
        end
    end,

    draw = function(self)

        if musicTimeDo then
            love.graphics.push()
                love.graphics.push()
                    if settings.downscroll then 
                        love.graphics.translate(0, push.getHeight() - 175)
                        love.graphics.scale(1, -1)
                    end
                    love.graphics.translate(push.getWidth() / 2 - 175, 50)
                    for i = 1, #receptors do
                        if mode == "Keys4" then
                            receptors[i][PRESSEDMOMENTS[i]]:draw(45 + settings.noteSpacing * (i - 1) - 275/2, -100, notesize, notesize * (settings.downscroll and -1 or 1))
                        end
                    end 
                love.graphics.pop()

                love.graphics.push()
                    if settings.downscroll then 
                        love.graphics.translate(0, push.getHeight() - 175)
                        love.graphics.scale(1, -1)
                    end
                    love.graphics.translate(push.getWidth() / 2 - 175, 50)
                    
                    love.graphics.translate(0, -musicPos * sv)
                    
                    for i = 1, #charthits do
                        for j = #charthits[i], 1, -1 do
                            --if (charthits[i][j][1] * sv)/speed - (musicPos * sv) <= 800 then
                                if mode == "Keys4" then
                                    if charthits[i][j][1]*speed * sv - musicPos * sv <= push.getHeight() + 200 then
                                        -- if the note is actually on screen (even with scroll velocity modifiers)
                                        if not charthits[i][j][5] then
                                            if charthits[i][j][4] then
                                                noteImgs[i][2]:draw(45 + settings.noteSpacing * (i - 1) - 275/2, -100+(charthits[i][j][1]*speed+200)+(not settings.downscroll and 0 or -75) * sv, notesize, noteImgs[i][2].scaleY * notesize * (settings.downscroll and -1 or 1))
                                            else
                                                noteImgs[i][1]:draw(45 + settings.noteSpacing * (i - 1) - 275/2, -100+(charthits[i][j][1]*speed+200-98) * sv, notesize, notesize * (settings.downscroll and -1 or 1))
                                            end
                                        else
                                            noteImgs[i][3]:draw(45 + settings.noteSpacing * (i - 1) - 275/2, -100+(charthits[i][j][1]*speed+200+(not settings.downscroll and 113 or -50)) * sv, notesize, -notesize)
                                        end
                                    end
                                else
                                end
                            --end
                        end
                    end
                love.graphics.pop()

                if curJudgement ~= "none" then
                    judgementImages[curJudgement]:draw(nil, nil, ratingsize.x, ratingsize.y)
                end
                if combo > 0 then
                    -- determine the offsetX of the combo of how many digits it is
                    local offsetX = 0
                    if combo >= 10000 then
                        offsetX = 0
                    elseif combo >= 1000 then
                        offsetX = -5
                    elseif combo >= 100 then
                        offsetX = -10
                    elseif combo >= 10 then
                        offsetX = -15
                    else
                        offsetX = -20
                    end
                    comboImages[1][combo % 10]:draw(comboImages[1][combo % 10].x + offsetX, comboImages[1][combo % 10].y, comboSize.x, comboSize.y)
                    if math.floor(combo / 10 % 10) ~= 0 or combo >= 100 then
                        comboImages[2][math.floor(combo / 10 % 10)]:draw(comboImages[2][math.floor(combo / 10 % 10)].x + offsetX, comboImages[2][math.floor(combo / 10 % 10)].y, comboSize.x, comboSize.y)
                    end
                    if math.floor(combo / 100 % 10) ~= 0 or combo >= 1000 then
                        comboImages[3][math.floor(combo / 100 % 10)]:draw(comboImages[3][math.floor(combo / 100 % 10)].x + offsetX, comboImages[3][math.floor(combo / 100 % 10)].y, comboSize.x, comboSize.y)
                    end
                    if math.floor(combo / 1000 % 10) ~= 0 or combo >= 10000 then
                        comboImages[4][math.floor(combo / 1000 % 10)]:draw(comboImages[4][math.floor(combo / 1000 % 10)].x + offsetX, comboImages[4][math.floor(combo / 1000 % 10)].y, comboSize.x, comboSize.y)
                    end
                    if math.floor(combo / 10000 % 10) ~= 0 or combo >= 100000 then
                        comboImages[5][math.floor(combo / 10000 % 10)]:draw(comboImages[5][math.floor(combo / 10000 % 10)].x + offsetX, comboImages[5][math.floor(combo / 10000 % 10)].y, comboSize.x, comboSize.y)
                    end
                    if math.floor(combo / 100000 % 10) ~= 0 or combo >= 100000 then
                        comboImages[6][math.floor(combo / 100000 % 10)]:draw(comboImages[6][math.floor(combo / 100000 % 10)].x + offsetX, comboImages[6][math.floor(combo / 100000 % 10)].y, comboSize.x, comboSize.y)
                    end
                end
                love.graphics.translate(push.getWidth() / 2, 0)
                love.graphics.rectangle("fill", -1000, 0, health * 400+10, 20, 10, 10)

                love.graphics.setFont(scoreFont)
                scoreFormat = string.format("%07d", round(scoring.score))
                if scoring.accuracy >= 100 then
                    accuracyFormat = "100.00%"
                else
                    accuracyFormat = string.format("%.2f%%", scoring.accuracy)
                end
                love.graphics.setFont(accuracyFont)
                love.graphics.printf(scoreFormat, 0, 0, 960, "right")
                if accuracyFormat == "nan%" then 
                    accuracyFormat = "0.00%"
                end
                love.graphics.printf(accuracyFormat, 0, 45, 960, "right")
                love.graphics.setFont(font)

                -- Time remaining bar 
                -- will be a rounded rectangle that is 25px tall and push.getWidth() wide
                love.graphics.rectangle("fill", -push.getWidth()/2, push.getHeight() - 10, push.getWidth() * (1 - (musicTime/1000 / audioFile:getDuration())), 10, 10, 10)
            love.graphics.pop()
        end
    end,

    focus = function(_, f)
        debug.print("focus: " .. tostring(f))
        if not f then
            pause()
        end
    end,

    leave = function()
        musicTimeDo = false
        audioFile:stop()
        if voices then
            voices:stop()
            voices = nil
        end
        audioFile = nil

        for i = 1, #charthits do
            charthits[i] = {}
        end

        Timer.clear()
        presence = {}
    end
}
