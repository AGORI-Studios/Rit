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
    paused = true
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
        comboTimer = Timer.tween(0.1, comboSize, {y = 1.85, x = 1.6}, "in-out-quad", function()
            comboTimer = Timer.tween(0.1, comboSize, {y = 1.6,}, "in-out-quad")
        end)
    else
        combo = 0
    end
    curJudgement = judgement

    additionalScore = additionalScore + scoring.scorePoints[judgement]

    if judgeTimer then 
        Timer.cancel(judgeTimer)
    end
    ratingsize.x = 1
    ratingsize.y = 1
    judgeTimer = Timer.tween(0.1, ratingsize, {x = 1.15, y = 1.15}, "in-out-quad", function()
        judgeTimer = Timer.tween(0.1, ratingsize, {x = 0.85, y = 0.85}, "in-out-quad")
    end)

    if waitTmr then 
        Timer.cancel(waitTmr)
    end

    waitTmr = Timer.after(0.35, function()
        Timer.tween(0.1, ratingsize, {x = 0, y = 0}, "in-out-quad")
        Timer.tween(0.1, comboSize, {y = 0, x = 0}, "in-out-quad")
    end)
    game:calculateRating()
end

return {
    enter = function(self)
        now = os.time()
        scoring = {
            score = 0,
            accuracy = 0,
            health = 1,
            healthTween = 1,
            ["Marvellous"] = 0,
            ["Perfect"] = 0,
            ["Great"] = 0,
            ["Good"] = 0,
            ["Miss"] = 0,
            scorePoints = {
                ["Marvellous"] = 0,
                ["Perfect"] = 0,
                ["Great"] = 0,
                ["Good"] = 0,
                ["Miss"] = 0
            }
        }
    
        songRate = 1
    
        game = require "states.game"
        skinSelect = require "states.skinSelect"
        songSelect = require "states.songSelect"
    
        musicTime = -settings.startTime 
        simulatedMusicTime = -settings.startTime
    
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
        simulatedPreviousFrameTime = love.timer.getTime() * 1000
        additionalScore = 0
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

        scoring.totalNotes = 0

        -- count all notes that are NOT holds or ends
        for i = 1, #charthits do
            for j = 1, #charthits[i] do
                if not charthits[i][j][5] and not charthits[i][j][4] then
                    scoring.totalNotes = scoring.totalNotes + 1
                end
            end
        end

        -- If the player were to get full marvellous, they would get 1,000,000 score
        -- meaning with each note, they would get 1,000,000 / totalNotes
        -- All perfects would be 800,000 / totalNotes
        -- All greats would be 600,000 / totalNotes
        -- All goods would be 400,000 / totalNotes
        -- All misses would be 0
        scoring.scorePoints["Marvellous"] = 1000000 / scoring.totalNotes
        scoring.scorePoints["Perfect"] = 800000 / scoring.totalNotes
        scoring.scorePoints["Great"] = 600000 / scoring.totalNotes
        scoring.scorePoints["Good"] = 400000 / scoring.totalNotes
        scoring.scorePoints["Miss"] = 0

        scoring.ratingPercent = 0
        scoring.ratingPercentLerp = 0

        for i, v in ipairs(scoring.scorePoints) do
            v = math.floor(v)
        end

        combo = 0
    
        sv = 1 -- Scroll Velocity
    
        curJudgement = "none"

        died = false
        musicPosValue = {1000}
        musicPitch = {1}

        if #receptors ~= 4 then 
            inputList = {
                "one7",
                "two7",
                "three7",
                "four7",
                "five7",
                "six7",
                "seven7"
            }
        else
            -- 4k
            inputList = {
                "one4",
                "two4",
                "three4",
                "four4"
            }
        end

        modifiers:load()
        --modifiers:applyMod("tipsy", 1, 5)
        --modifiers:applyMod("drunk", 1, 5)
        
        strumlineY = {-35}
        whereNotesHit = {-35}

        gameCanvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())

        audioFile:setPitch(songSpeed)
        if voices then
            voices:setPitch(songSpeed)
        end
    end,

    calculateRating = function(self)
		scoring.ratingPercent = scoring.score / ((noteCounter + scoring["Miss"]) * scoring.scorePoints["Marvellous"])
		if scoring.ratingPercent == nil or scoring.ratingPercent < 0 then 
			scoring.ratingPercent = 0
		elseif scoring.ratingPercent > 1 then
			scoring.ratingPercent = 1
		end
	end,

    update = function(self, dt)
        simulatedTime = love.timer.getTime()

        simulatedMusicTime = simulatedMusicTime + (simulatedTime * 1000)  - simulatedPreviousFrameTime
        simulatedPreviousFrameTime = simulatedTime * 1000
        absSimulatedMusicTime = math.abs(simulatedMusicTime)
        if musicTimeDo and not died and modifiers.musicPlaying then
            local time = love.timer.getTime()

            musicTime = musicTime + (time * musicPosValue[1]) - previousFrameTime
            previousFrameTime = time * musicPosValue[1]

            musicPos = ((musicTime) * (speed)+100)
        elseif not musicTimeDo then
            previousFrameTime = love.timer.getTime() * 1000
        elseif musicTimeDo and died and modifiers.musicPlaying then
            musicTime = musicTime + musicPosValue[1] * dt
            musicPos = ((musicTime) * (speed)+100)
        end

        if not paused then 
            modifiers:update(dt, beatHandler.beat)
        end

        absMusicTime = math.abs(musicTime)

        if (musicTime > 0 - settings.audioOffset) and not audioFile:isPlaying() and not died and modifiers.musicPlaying then
            if musicTimeDo then
                audioFile:play()
                if voices then -- support for fnf voices
                    voices:play()
                end
                debug.print("info", "Playing audio file")
            end
        elseif musicTime > (audioFile:getDuration() * 1000) / songSpeed then 
            state.switch(resultsScreen, scoring.score > 1000000 and 1000000 or scoring.score, {songTitle, songDifficultyName}, false)
        end
        for i = 1, #charthits do
            for j = 1, #charthits[i] do
                if charthits[i][j] then
                    if charthits[i][1][1] - musicTime <= -100 then 
                        if not charthits[i][1][4] then
                            noteCounter = noteCounter + 1
                            if scoring.health < 0 then
                                scoring.health = 0
                            end
                            scoring.health = scoring.health - 0.270
                            addJudgement("Miss")
                        end
                        table.remove(charthits[i], 1)
                    end
                end
            end
        end

        scoring.healthTween = math.lerp(scoring.healthTween, scoring.health, 0.05)
        scoring.ratingPercentLerp = math.lerp(scoring.ratingPercentLerp, scoring.ratingPercent, 0.05)

        for i = 1, 4 do
            for _, hitObject in ipairs(charthits[i]) do
                hitObject[2] = (whereNotesHit[1] + (-((musicTime - hitObject[1]) * 0.6 * speed))) * modifiers.reverseScale
            end
        end
        
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
                table.remove(chartEvents, 1)
            end
        end
        if bpmEvents[1] then
            if bpmEvents[1][1] then
                if bpmEvents[1][1] <= absMusicTime then
                    beatHandler.setBPM(bpmEvents[1][2] * songSpeed)
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
                paused = false
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
                    for j = 1, #charthits[1] do
                        if notes[j] then
                            if not notes[j][4] and not notes[j][5] then
                                if notes[j][1] - musicTime >= -80 and notes[j][1] - musicTime <= 180 or (notes[2] and notes[1][5] and notes[2][1] - musicTime >= -80 and notes[2][1] - musicTime <= 180) then
                                    noteCounter = noteCounter + 1
                                    pos = math.abs(notes[j][1] - musicTime)
                                    if pos < 28 then
                                        judgement = "Marvellous"
                                        scoring.health = scoring.health + 0.135
                                    elseif pos < 43 then
                                        judgement = "Perfect"
                                        scoring.health = scoring.health + 0.135
                                    elseif pos < 102 then
                                        judgement = "Great"
                                        scoring.health = scoring.health + 0.135
                                    elseif pos < 135 then
                                        judgement = "Good"
                                        scoring.health = scoring.health + 0.135
                                    else
                                        judgement = "Miss"
                                        scoring.health = scoring.health - 0.270
                                    end

                                    addJudgement(judgement)

                                    if scoring.health > 2 then
                                        scoring.health = 2
                                    end
                                    if scoringTimer then 
                                        Timer.cancel(scoringTimer)
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
                                    table.remove(notes, j)

                                    if hit then hit(i, judgement) end

                                    break
                                end
                            end
                        end 
                    end
                end

                if input:down(curInput) then
                    PRESSEDMOMENTS[i] = 2
                    if notes[1] then
                        if notes[1][4] then
                            if notes[1][1] - musicTime <= -15 then
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
                            scoring.health = scoring.health + 0.135
                            additionalScore = additionalScore + scoring.scorePoints["Marvellous"]
                            addJudgement(judgement)

                            if scoring.health > 100 then
                                scoring.health = 1
                            end
                            if scoringTimer then 
                                Timer.cancel(scoringTimer)
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
                        end
                        
                        table.remove(notes, 1)
                    end
                end
            end
        end

        if scoring.health <= 0 and not died then
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

        if update then 
            update(beatHandler.curBeat, musicTime, dt)
        end

        for i,v in pairs(modifiers.graphics) do
            v:update(dt)
        end
    end,

    keypressed = function(self, key)
        if key_pressed then key_pressed(key) end
    end,

    draw = function(self)
        if musicTimeDo then
            love.graphics.setCanvas(gameCanvas)
                love.graphics.clear()
                love.graphics.push()
                    love.graphics.push()
                        love.graphics.translate(push.getWidth() / 2, push.getHeight() / 2)
                        love.graphics.translate(modifiers.camera.x, modifiers.camera.y)
                        love.graphics.scale(modifiers.camera.zoom, modifiers.camera.zoom)
                        -- draw in order of modifiers.graphics[name].img.drawLayer
                        for i = 1, #modifiers.draws do 
                            modifiers.graphics[modifiers.draws[i]]:draw()
                        end
                    love.graphics.pop()

                    love.graphics.push()
                        if settings.downscroll then 
                            love.graphics.translate(0, push.getHeight() - 175)
                            love.graphics.scale(1, -1)
                        else
                            love.graphics.translate(0, 175)
                        end
                        love.graphics.translate(push.getWidth() / 2 - 175, 50)
                        for i = 1, #receptors do
                            receptors[i][PRESSEDMOMENTS[i]]:draw(90 -(settings.noteSpacing*(#receptors/2-1)) + (settings.noteSpacing * (i-1)), strumlineY[1], notesize, notesize * (settings.downscroll and -1 or 1))
                        end 
                    love.graphics.pop()

                    love.graphics.push()
                        if settings.downscroll then 
                            love.graphics.translate(0, push.getHeight() - 175)
                            love.graphics.scale(1, -1)
                        else
                            love.graphics.translate(0, 175)
                        end
                        love.graphics.translate(push.getWidth() / 2 - 175, 50)
                        
                        --love.graphics.translate(0, -musicPos * sv)
                        
                        for i = 1, #charthits do
                            for j = #charthits[i], 1, -1 do
                                if math.abs(charthits[i][j][2]) <= 1100 then
                                    -- if the note is actually on screen (even with scroll velocity modifiers)
                                    if not charthits[i][j][5] then
                                        
                                        if charthits[i][j][4] then
                                            noteImgs[i][2]:draw(90 -(settings.noteSpacing*(#receptors/2-1)) + (settings.noteSpacing * (i-1)), charthits[i][j][2], notesize, noteImgs[i][2].scaleY * notesize * (settings.downscroll and -1 or 1))
                                        else
                                            noteImgs[i][1]:draw(90 -(settings.noteSpacing*(#receptors/2-1)) + (settings.noteSpacing * (i-1)), charthits[i][j][2], notesize, notesize * (settings.downscroll and -1 or 1))
                                        end
                                    else
                                        noteImgs[i][3]:draw(90 -(settings.noteSpacing*(#receptors/2-1)) + (settings.noteSpacing * (i-1)), charthits[i][j][2]+50, notesize, -notesize)
                                    end
                                end
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
                    if modifiers.gameProperties["healthbarVisible"] then 
                        love.graphics.setColor(healthBarColor)
                        love.graphics.rectangle("fill", -1000, 0, scoring.healthTween * 400+10, 20, 10, 10)
                        love.graphics.setColor(1, 1, 1, 1)
                    end

                    if modifiers.gameProperties["scoreVisible"] then
                        love.graphics.setFont(scoreFont)
                        scoreFormat = string.format("%07d", round(scoring.score))
                        love.graphics.setFont(accuracyFont)
                        love.graphics.setColor(uiTextColor)
                        love.graphics.printf(scoring.score > 1000000 and 1000000 or scoreFormat, 0, 0, 960, "right")
                        love.graphics.printf(((math.floor(scoring.ratingPercentLerp * 10000) / 100)) .. "%", 0, 45, 960, "right")
                        love.graphics.setColor(1, 1, 1, 1)
                        love.graphics.setFont(font)
                    end

                    if modifiers.gameProperties["timebarVisible"] then
                        -- Time remaining bar 
                        love.graphics.setColor(timeBarColor)
                        love.graphics.rectangle("fill", -push.getWidth()/2, push.getHeight() - 10, push.getWidth() * (1 - (musicTime/1000 / audioFile:getDuration())), 10, 10, 10)
                        love.graphics.setColor(1, 1, 1, 1)
                    end
                love.graphics.pop()
            love.graphics.setCanvas()

            love.graphics.setColor(1, 1, 1, 1)
            if modifiers.curShader ~= "" then
                love.graphics.setShader(modifiers.shaders[modifiers.curShader])
            end
            -- resize canvas to strech to screen
            love.graphics.draw(gameCanvas, 0, 0, 0, push:getWidth() / gameCanvas:getWidth(), push:getHeight() / gameCanvas:getHeight())
            love.graphics.setShader()

        end
    end,

    resize = function(self,w, h)
        -- resize canvas to strech to new screen size
        gameCanvas = love.graphics.newCanvas(w, h)
    end,

    focus = function(self, f)
        --debug.print("focus: " .. tostring(f))
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

        charthits = {}
        for i = 1, 4 do
            charthits[i] = {}
        end

        graphics.clearCache()

        Timer.clear()
        presence = {}
        camera = {x=0, y=0, zoom=1}

        modifiers:clear()
    end
}
