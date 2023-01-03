--[[----------------------------------------------------------------------------

This file is apart of Rit; a free and open sourced rhythm game made with LÖVE.

Copyright (C) 2022 GuglioIsStupid

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
                y = 2.4
            },
            "in-out-quad",
            function()
                Timer.tween(
                    0.1,
                    comboSize,
                    {
                        y = 2
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
            x = 1.4,
            y = 1.4
        },
        "in-out-quad",
        function()
            Timer.tween(
                0.1,
                ratingsize,
                {
                    x = 1,
                    y = 1
                },
                "in-out-quad"
            )
        end
    )
end

return {
    enter = function(self)
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
        previousFrameTime = 0
        additionalScore = 0
        additionalAccuracy = 0
        noteCounter = 0
    
        died = false
    
        ratingsize = {
            x = 1,
            y = 1
        }
        comboSize = {
            x = 2,
            y = 2
        }
    
        scoring["Marvellous"] = 0
        scoring["Perfect"] = 0
        scoring["Great"] = 0
        scoring["Good"] = 0
        scoring["Miss"] = 0
        combo = 0
    
        sv = {1} -- Scroll Velocity
    
        curJudgement = "none"
    end,

    update = function(self, dt)
        if musicTimeDo then
            musicTime = musicTime + musicPosValue[1] * dt
            musicPos = ((musicTime) * (speed)+100)
        end
        absMusicTime = math.abs(musicTime)
        if (musicTime > 0) and not audioFile:isPlaying() then
            if musicTimeDo then
                audioFile:play()
                if voices then -- support for fnf voices
                    voices:play()
                end
            end
        elseif musicTime > audioFile:getDuration() * 1000 then
            state.switch(songSelect)
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
                            health = health - 2
                            addJudgement("Miss")
                        end
                        table.remove(charthits[i], 1)
                    end
                end
            end
        end

        presence = {
            details = "Playing "..songTitle, 
            state = "Playing "..songDifficultyName,
            largeImageKey = "totallyreallogo",
            largeImageText = "Playing "..songTitle,
            startTimestamp = now
        }

        if chartEvents[1] then
            if chartEvents[1][1] <= absMusicTime then
                if settings.scrollvelocities then sv[1] = chartEvents[1][2] end
                --print(sv[1])
                table.remove(chartEvents, 1)
            end
        end
        if bpmEvents[1] then
            if bpmEvents[1][1] <= absMusicTime then
                beatHandler.setBPM(bpmEvents[1][2])
                table.remove(bpmEvents, 1)
            end
        end
        beatHandler.update(dt)

        if input:pressed("pause") then 
            if musicTimeDo then 
                pause()
            else
                musicTimeDo = true
                audioFile:play()
                if voices then -- support for fnf voices
                    voices:play()
                end
            end
        end

        for i = 1, #inputList do
            curInput = inputList[i]
            notes = charthits[i]
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
                    noteCounter = noteCounter + 1
                    if not notes[1][4] and not notes[1][5] then
                        if notes[1][1] - musicTime >= -80 and notes[1][1] - musicTime <= 180 or (notes[2] and notes[1][5] and notes[2][1] - musicTime >= -80 and notes[2][1] - musicTime <= 180) then
                            --print("Hit!")
                            --print(notes[1][1] - musicTime .. "ms")
                            pos = math.abs(notes[1][1] - musicTime)
                            if notes[2] and notes[1][5] and notes[2][1] - musicTime >= -80 and notes[2][1] - musicTime <= 180 then
                                pos = math.abs(notes[2][1] - musicTime)
                            end
                            if pos < 45 then
                                judgement = "Marvellous"
                                health = health + 2
                                additionalScore = additionalScore + 650
                                additionalAccuracy = additionalAccuracy + 100
                            elseif pos < 60 then
                                judgement = "Perfect"
                                health = health + 2
                                additionalScore = additionalScore + 500
                                additionalAccuracy = additionalAccuracy + 100
                            elseif pos < 75 then
                                judgement = "Great"
                                health = health + 2
                                additionalScore = additionalScore + 350
                                additionalAccuracy = additionalAccuracy + 75.55
                            elseif pos < 120 then
                                judgement = "Good"
                                health = health + 2
                                additionalScore = additionalScore + 200
                                additionalAccuracy = additionalAccuracy + 66.66
                            else
                                judgement = "Miss"
                                health = health - 2
                                additionalScore = additionalScore + 1.11
                            end

                            addJudgement(judgement)

                            if health > 100 then
                                health = 100
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
                                {accuracy = additionalAccuracy / noteCounter},
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

            if input:isDown(curInput) then
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
        end
        -- print graphics memory usage
        --print(tostring(math.floor(love.graphics.getStats().texturememory / 1048576)) .. "MB")

        if health <= 0 and not died then
            died = true
            Timer.tween(3, musicPosValue, {0}, "out-quad")
            Timer.tween(3, musicPitch, {0.005}, "out-quad", function()
                audioFile:stop()
                Timer.after(1, function()
                    state.switch(songSelect)
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
                            love.graphics.draw(receptors[i][PRESSEDMOMENTS[i]], -45 + 200 * (i - 1) - 275/2, 0, 0, notesize, notesize * (settings.downscroll and -1 or 1))
                        else
                            love.graphics.draw(receptors[i][PRESSEDMOMENTS[i]], -375 + 200 * (i - 1) - 275/2, 0, 0, notesize, notesize * (settings.downscroll and -1 or 1))
                        end
                    end 
                love.graphics.pop()

                love.graphics.push()
                    if settings.downscroll then 
                        love.graphics.translate(0, push.getHeight() - 175)
                        love.graphics.scale(1, -1)
                    end
                    love.graphics.translate(push.getWidth() / 2 - 175, 50)
                    
                    love.graphics.translate(0, -musicPos * sv[1])
                    
                    for i = 1, #charthits do
                        for j = #charthits[i], 1, -1 do
                            --if (charthits[i][j][1] * sv[1])/speed - (musicPos * sv[1]) <= 800 then
                                if mode == "Keys4" then
                                    if charthits[i][j][1]*speed * sv[1] - musicPos * sv[1] <= push.getHeight() + 200 then
                                        -- if the note is actually on screen (even with scroll velocity modifiers)
                                        if not charthits[i][j][5] then
                                            if charthits[i][j][4] then
                                                love.graphics.draw(noteImgs[i][2], -45 + 200 * (i - 1) - 275/2, (charthits[i][j][1]*speed+200)+(not settings.downscroll and 0 or -75) * sv[1], 0, notesize, notesize * (settings.downscroll and -1 or 1))
                                            else
                                                love.graphics.draw(noteImgs[i][1], -45 + 200 * (i - 1) - 275/2, (charthits[i][j][1]*speed+200-98) * sv[1], 0, notesize, notesize * (settings.downscroll and -1 or 1))
                                            end
                                        else
                                            love.graphics.draw(noteImgs[i][3], -45 + 200 * (i - 1) - 275/2, (charthits[i][j][1]*speed+200+(not settings.downscroll and 113 or -50)) * sv[1], 0, notesize, -notesize)
                                        end
                                    end
                                else
                                    love.graphics.draw(charthits[i][j][3], -375 + 200 * (i - 1) - 275/2, (charthits[i][j][1]*speed+200) * sv[1], 0, notesize, notesize * (settings.downscroll and -1 or 1))
                                end
                            --end
                        end
                    end
                love.graphics.pop()

                if curJudgement ~= "none" then
                    love.graphics.draw(judgementImages[curJudgement], push.getWidth() / 2+325-275, push.getHeight() / 2, 0, ratingsize.x, ratingsize.y, judgementImages[curJudgement]:getWidth() / 2, judgementImages[curJudgement]:getHeight() / 2)
                end
                if combo > 0 then
                    love.graphics.draw(
                        comboImages[1][combo % 10],
                        push.getWidth() / 2+360 - 275,
                        push.getHeight() / 2+100,
                        0,
                        comboSize.x,
                        comboSize.y,
                        comboImages[1][combo % 10]:getWidth() / 2,
                        comboImages[1][combo % 10]:getHeight() / 2
                    )
                    love.graphics.draw(
                        comboImages[2][math.floor(combo / 10 % 10)],
                        push.getWidth() / 2+330 - 275,
                        push.getHeight() / 2+100,
                        0,
                        comboSize.x,
                        comboSize.y,
                        comboImages[2][math.floor(combo / 10 % 10)]:getWidth() / 2,
                        comboImages[2][math.floor(combo / 10 % 10)]:getHeight() / 2
                    )
                    love.graphics.draw(
                        comboImages[3][math.floor(combo / 100 % 10)],
                        push.getWidth() / 2+300 - 275,
                        push.getHeight() / 2+100,
                        0,
                        comboSize.x,
                        comboSize.y,
                        comboImages[3][math.floor(combo / 100 % 10)]:getWidth() / 2,
                        comboImages[3][math.floor(combo / 100 % 10)]:getHeight() / 2
                    )
                end
                love.graphics.translate(push.getWidth() / 2, 0)
                love.graphics.rectangle("fill", -1000, 0, health * 8+10, 20, 10, 10)

                love.graphics.setFont(scoreFont)
                scoreFormat = string.format("%07d", round(scoring.score))
                if scoring.accuracy >= 100 then
                    accuracyFormat = "100.00%"
                else
                    accuracyFormat = string.format("%.2f%%", scoring.accuracy)
                end
                love.graphics.setFont(accuracyFont)
                love.graphics.printf(scoreFormat, 0, 0, 960, "right")
                love.graphics.printf(accuracyFormat, 0, 45, 960, "right")
                love.graphics.setFont(font)
            love.graphics.pop()
        end
    end,

    focus = function(_, f)
        print("focus: " .. tostring(f))
        if not f then
            pause()
        end
    end,

    leave = function()
        audioFile:stop()
        if voices then
            voices:stop()
        end

        Timer.clear()
    end
}
