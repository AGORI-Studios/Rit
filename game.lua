inputList = {
    "one4",
    "two4",
    "three4",
    "four4"
}
return {
    enter = function(self)
        musicTime = -125
        speed = settings.scrollspeed or 1
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
    end,

    update = function(self, dt)
        if musicTimeDo then
            musicTime = musicTime + 1000 * dt
            musicPos = musicTime * speed+100
        end
        for i = 1, #charthits do
            for j = 1, #charthits[i] do
                if charthits[i][j] then
                    if charthits[i][j][1] - musicTime <= -100 then 
                        if not charthits[i][j][4] then
                            noteCounter = noteCounter + 1
                            additionalAccuracy = additionalAccuracy + 1.11
                            health = health - 2
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
                        end
                        table.remove(charthits[i], 1)
                    end
                end
            end
        end

        for i = 1, #inputList do
            curInput = inputList[i]
            notes = charthits[i]
            if input:pressed(curInput) then
               -- print("Pressed " .. curInput .. " at " .. musicPos .. "ms")
                --print("Pressed " .. curInput)
                if notes[1] then
                    --print(notes[1][1] - musicPos)
                    noteCounter = noteCounter + 1
                    if notes[1][1] - musicTime >= -50 and notes[1][1] - musicTime <= 150 then
                        --print("Hit!")
                        print(notes[1][1] - musicTime .. "ms")
                        pos = math.abs(notes[1][1] - musicTime)
                        if pos < 45 then
                            print("Perfect!")
                            health = health + 2
                            additionalScore = additionalScore + 650
                            additionalAccuracy = additionalAccuracy + 100
                        elseif pos < 65 then
                            print("Great!")
                            health = health + 2
                            additionalScore = additionalScore + 500
                            additionalAccuracy = additionalAccuracy + 75.55
                        elseif pos < 90 then
                            print("Good!")
                            health = health + 2
                            additionalScore = additionalScore + 350
                            additionalAccuracy = additionalAccuracy + 66.66
                        elseif pos < 130 then
                            print("Okay!")
                            health = health + 2
                            additionalScore = additionalScore + 200
                            additionalAccuracy = additionalAccuracy + 33.33
                        else
                            print("Miss!")
                            health = health - 2
                            additionalScore = additionalScore + 1.11
                        end
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

            if input:down(curInput) then
                PRESSEDMOMENTS[i] = 2
                if notes[1] then
                    if notes[1][4] then
                        if notes[1][1] - musicTime >= -50 and notes[1][1] - musicTime <= 50 then
                            table.remove(notes, 1)
                        end
                        
                    end
                end 
            else
                PRESSEDMOMENTS[i] = 1
            end
        end
    end,

    draw = function(self)
        if audioFile and audioFile:isPlaying() then
            love.graphics.push()
                love.graphics.push()
                    if not settings.downscroll then
                        love.graphics.scale(0.8, 0.8)
                        love.graphics.translate(love.graphics.getWidth() / 2, 50)
                    else
                        love.graphics.scale(0.8, -0.8)
                        love.graphics.translate(love.graphics.getWidth() / 2, -1080)
                    end
                    
                    love.graphics.translate(0, -musicPos)
                    
                    for i = 1, #charthits do
                        for j = #charthits[i], 1, -1 do
                            if charthits[i][j][1]/speed - musicPos <= 900 then
                                if mode == "Keys4" then
                                    if not charthits[i][j][5] then
                                        if charthits[i][j][4] then
                                            love.graphics.draw(charthits[i][j][3], 145 + 200 * (i - 1), charthits[i][j][1]*speed+200-100, 0, 1, flipY)
                                        else
                                            love.graphics.draw(charthits[i][j][3], 145 + 200 * (i - 1), charthits[i][j][1]*speed+200-24.5-100, 0, 1, flipY)
                                        end
                                    else
                                        love.graphics.draw(charthits[i][j][3], 145 + 200 * (i - 1), charthits[i][j][1]*speed+200+95+24.5-100, 0, 1, flipY)
                                    end
                                else
                                    love.graphics.draw(charthits[i][j][3], -375 + 200 * (i - 1), charthits[i][j][1]*speed+200-100, 0, 1, flipY)
                                end
                            end
                        end
                    end
                love.graphics.pop()
                
                love.graphics.push()
                    if not settings.downscroll then
                        love.graphics.scale(0.8, 0.8)
                        love.graphics.translate(love.graphics.getWidth() / 2, 50)
                    else
                        love.graphics.scale(0.8, -0.8)
                        love.graphics.translate(love.graphics.getWidth() / 2, -1080)
                    end
                    
                    for i = 1, #receptors do
                        if mode == "Keys4" then
                            love.graphics.draw(receptors[i][PRESSEDMOMENTS[i]], 145 + 200 * (i - 1), 0, 0, 1, flipY)
                        else
                            love.graphics.draw(receptors[i][PRESSEDMOMENTS[i]], -375 + 200 * (i - 1), 0, 0, 1, flipY)
                        end
                    end 
                love.graphics.pop()
                love.graphics.translate(love.graphics.getWidth() / 2, 0)
                love.graphics.rectangle("fill", -650, -50, health * 8+10, 20, 10, 10)

                love.graphics.setFont(scoreFont)
                scoreFormat = string.format("%07d", round(scoring.score))
                if scoring.accuracy >= 100 then
                    accuracyFormat = "100.00%"
                else
                    accuracyFormat = string.format("%.2f%%", scoring.accuracy)
                end
                love.graphics.setFont(accuracyFont)
                love.graphics.printf(scoreFormat, 0, 0, 1280, "right")
                love.graphics.printf(accuracyFormat, 0, 45, 1280, "right")
                love.graphics.setFont(font)
            love.graphics.pop()
        end
    end,
}
