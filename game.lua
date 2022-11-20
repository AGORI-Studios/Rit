local inputList = {
    "gameLeft",
    "gameDown",
    "gameUp",
    "gameRight"
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
    end,

    update = function(self, dt)
        musicTime = musicTime + 1000 * dt
        musicPos = musicTime * speed + 200
        for i = 1, #charthits do
            for j = 1, #charthits[i] do
                if charthits[i][j] then
                    if not charthits[i][j][3] then
                        if charthits[i][j][1] - musicTime <= 280 then 
                            --print(charthits[i][1][1] - musicPos) -- why is this negative?
                            table.remove(charthits[i], 1)
                        end
                    else
                        if charthits[i][j][1] - musicTime <= 280 - charthits[i][j][2] then 
                            print(charthits[i][1][1] - musicPos) -- why is this negative?
                            table.remove(charthits[i], 1)
                        end
                    end
                end
            end
        end

        for i = 1, #inputList do
            curInput = inputList[i]
            notes = charthits[i]
            if input:pressed(curInput) then
                --print("Pressed " .. curInput)
                if notes[1] then
                    --print(notes[1][1] - musicPos)
                    if notes[1][1] - musicPos >= 20 and notes[1][1] - musicPos <= 180 then
                        --print("Hit!")
                        table.remove(notes, 1)
                    end
                end
                PRESSEDMOMENTS[i] = 2
            else
                PRESSEDMOMENTS[i] = 1
                --print(PRESSEDMOMENTS[i])
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
                    if charthits[i][j][2] ~= 0 then
                        for k = 1, charthits[i][j][2] - charthits[i][j][1], 95/2 do 
                            --love.graphics.rectangle("fill", -200 + 100 * (i - 1), charthits[i][j][1]-PARTWHERERECEPTORSARE + (k - 1), 75, 1)
                            if k > 95/2 then
                                love.graphics.draw(charthits[i][j][5], -200 + 100 * (i - 1), charthits[i][j][1]-PARTWHERERECEPTORSARE + (k), 0, 0.5, 0.5)
                            else
                                love.graphics.draw(endnote, -200 + 100 * (i - 1), charthits[i][j][1]-PARTWHERERECEPTORSARE + (k), 0, 0.5, -0.5)
                            end
                        end
                    end
                    love.graphics.draw(charthits[i][j][3], -200 + 100 * (i - 1), charthits[i][j][1]-PARTWHERERECEPTORSARE, 0, 0.5, 0.5)
                end
            end
        end

        

        love.graphics.pop()
        for i = 1, #receptors do
            love.graphics.draw(receptors[i][PRESSEDMOMENTS[i]], -200 + 100 * (i - 1), 0, 0, 0.5, 0.5)
            --print("COCK")
        end 
        love.graphics.pop()
    end,
}
