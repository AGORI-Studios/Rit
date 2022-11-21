inputList = {
    "one4",
    "two4",
    "three4",
    "four4"
}
return {
    enter = function(self)
        musicTime = 0
        speed = 1.25
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
            musicPos = musicTime * speed + 200
        end
        for i = 1, #charthits do
            for j = 1, #charthits[i] do
                if charthits[i][j] then
                    if charthits[i][j][1] - musicTime <= 280 then 
                        --print(charthits[i][1][1] - musicPos) -- why is this negative?
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
                    if notes[1][1] - musicPos >= 80 and notes[1][1] - musicPos <= 240 then
                        print("Hit!")
                        table.remove(notes, 1)
                    end
                end
                PRESSEDMOMENTS[i] = 2
            else
                PRESSEDMOMENTS[i] = 1
                --print(PRESSEDMOMENTS[i])
            end

            if input:down(curInput) then
                if notes[1] then
                    if notes[1][4] then
                        table.remove(notes, 1)
                    end
                end
            end
        end
    end,

    draw = function(self)
        love.graphics.push()
        love.graphics.translate(love.graphics.getWidth() / 2, 0)
        love.graphics.push()
        love.graphics.translate(0, -musicPos)
        for i = 1, #charthits do
            for j = 1, #charthits[i] do
                if charthits[i][j][1] - musicPos <= 720 then
                    if mode == "Keys4" then
                        love.graphics.draw(charthits[i][j][3], -200 + 100 * (i - 1), charthits[i][j][1]-PARTWHERERECEPTORSARE, 0, 0.5, 0.5)
                    else
                        love.graphics.draw(charthits[i][j][3], -375 + 100 * (i - 1), charthits[i][j][1]-PARTWHERERECEPTORSARE, 0, 0.5, 0.5)
                    end
                end
            end
        end

        

        love.graphics.pop()
        for i = 1, #receptors do
            if mode == "Keys4" then
                love.graphics.draw(receptors[2][PRESSEDMOMENTS[i]], -200 + 100 * (i - 1), 0, 0, 0.5, 0.5)
            else
                love.graphics.draw(receptors[i][PRESSEDMOMENTS[i]], -375 + 100 * (i - 1), 0, 0, 0.5, 0.5)
            end
            --print("COCK")
        end 
        love.graphics.pop()
    end,
}
