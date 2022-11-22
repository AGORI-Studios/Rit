inputList = {
    "one4",
    "two4",
    "three4",
    "four4"
}
return {
    enter = function(self)
        musicTime = 0
        speed = 1
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
                        print(charthits[i][1][1] - musicPos) -- why is this negative?
                        if not charthits[i][j][4] then
                            health = health - 2
                            if health < 0 then
                                health = 0
                            end
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
                    
                    if notes[1][1] - musicTime >= -50 and notes[1][1] - musicTime <= 150 then
                        --print("Hit!")
                        print(notes[1][1] - musicTime .. "ms")
                        pos = math.abs(notes[1][1] - musicTime)
                        if pos < 30 then
                            print("Perfect!")
                            health = health + 2
                        elseif pos < 55 then
                            print("Great!")
                            health = health + 2
                        elseif pos < 80 then
                            print("Good!")
                            health = health + 2
                        elseif pos < 120 then
                            print("Okay!")
                            health = health + 2
                        else
                            print("Miss!")
                            health = health - 2
                        end
                        if health > 100 then
                            health = 100
                        end
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
        if audioFile and audioFile:isPlaying()  then
            
            love.graphics.push()
                love.graphics.translate(love.graphics.getWidth() / 2, 50)
                love.graphics.push()
                    love.graphics.translate(0, -musicPos)
                    for i = 1, #charthits do
                        for j = #charthits[i], 1, -1 do
                            if charthits[i][j][1]/speed - musicPos <= 860 then
                                if mode == "Keys4" then
                                    if not charthits[i][j][5] then
                                        if charthits[i][j][4] then
                                            love.graphics.draw(charthits[i][j][3], 0 + 155 * (i - 1), charthits[i][j][1]*speed+200-100, 0, 0.8, 0.8)
                                        else
                                            love.graphics.draw(charthits[i][j][3], 0 + 155 * (i - 1), charthits[i][j][1]*speed+200-24.5-100, 0, 0.8, 0.8)
                                        end
                                    else
                                        love.graphics.draw(charthits[i][j][3], 0 + 155 * (i - 1), charthits[i][j][1]*speed+200+47.5-100, 0, 0.8, -0.8)
                                    end
                                else
                                    love.graphics.draw(charthits[i][j][3], -375 + 155 * (i - 1), charthits[i][j][1]*speed+200-100, 0, 0.8, 0.8)
                                end
                            end
                        end
                    end
                love.graphics.pop()

                for i = 1, #receptors do
                    if mode == "Keys4" then
                        love.graphics.draw(receptors[i][PRESSEDMOMENTS[i]], 0 + 155 * (i - 1), 0, 0, 0.8, 0.8)
                    else
                        love.graphics.draw(receptors[i][PRESSEDMOMENTS[i]], -375 + 155 * (i - 1), 0, 0, 0.8, 0.8)
                    end
                    --print("COCK")
                end 
                love.graphics.rectangle("fill", -650, -50, health * 8+10, 20, 10, 10)
            love.graphics.pop()
        end
    end,
}
