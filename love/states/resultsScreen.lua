local args, scorings, ratings, songData, died, scoreTXT, score, acc, curRating
return {
    enter = function(self, _, ...)
        now = os.time()
        if not love.filesystem.getInfo("results") then
            love.filesystem.createDirectory("results")
        end
        args = {...}
        scorings = args[1]
        songData = args[2]
        died = args[3]

        scoreTXT = [[
Score: %d
Accuracy: %d%%
Rating: %s
]]

        score = scorings.score
        acc = scorings.accuracy

        debug.print("Score: "..score.." - "..acc.."%")

        ratings = {
            {name = "SS", acc = 100},
            {name = "S", acc = 90},
            {name = "A", acc = 80},
            {name = "B", acc = 60},
            {name = "C", acc = 40},
            {name = "D", acc = 10},
            {name = "F", acc = 0}
        }

        curRating = "F"

        -- the accuracy is scorings.accuracy
        -- the score is scorings.score
        debug.print("checking for death")
        if not died then
            debug.print("not dead, looping")
            debug.print(tostring(#ratings))
            for i = #ratings, 1, -1 do
                debug.print("loop iter: "..i)
                debug.print(tostring(acc >= ratings[i].acc)..tostring(scorings.accuracy >= ratings[i].acc))
                if scorings.accuracy >= ratings[i].acc then
                    curRating = ratings[i].name
                    debug.print("Acc >= "..ratings[i].acc.." - "..ratings[i].name)
                    -- break
                end
            end
        end
        if died then
            debug.print("Failed, rating F")
        end

        scoreS = score
        accS = acc

        -- check if score is higher than the current highscore
        if love.filesystem.getInfo("results/" .. songData[1] .. "-" .. songData[2] .. ".txt") then
            local file = love.filesystem.read("results/" .. songData[1] .. "-" .. songData[2] .. ".txt")
            local oldScore = tonumber(file:match("Score: (%d+)"))
            local oldAcc = tonumber(file:match("Accuracy: (%d+)%%"))

            if oldScore > score then
                scoreS = oldScore
            else
                scoreS = score
            end

            if oldAcc > acc then
                accS = oldAcc
            else
                accS = acc
            end
            -- accS and scoreS are for rewriting the file results
        end

        -- Temporary cuz i'm too stupid to make it work rn!!!! (I'm not stupid, I'm just lazy, its 4:26am)
        if love.filesystem.getInfo("results/" .. songData[1] .. "-" .. songData[2] .. ".txt") then
            love.filesystem.remove("results/" .. songData[1] .. "-" .. songData[2] .. ".txt")
        end
        love.filesystem.write("results/" .. songData[1] .. "-" .. songData[2] .. ".txt", string.format(scoreTXT, scoreS, accS, curRating))

        presence = {
            details = (autoplay and "Autoplaying " or "Playing ")..songData[1].." - "..songData[2].. " - Results", 
            state = "Score: "..scoreS.." - "..accS.."% - "..combo..(combo == noteCounter and " FC" or " combo"),
            largeImageKey = "totallyreallogo",
            largeImageText = "Rit"..(__DEBUG__ and " DEBUG MODE" or ""),
            startTimestamp = now
        }
    end,

    update = function(self, dt)
        if input:pressed("confirm") then
            -- if it isn't 4k, the skin is all fucked up so go back to skin select
            if #receptors == 4 then
                state.switch(songSelect)
            else
                state.switch(skinSelect)
            end
        end

        presence = {
            details = (autoplay and "Autoplaying " or "Playing ")..songData[1].." - "..songData[2].. " - Results", 
            state = "Score: "..scoreS.." - "..accS.."% - "..combo..(combo == noteCounter and " FC" or " combo"),
            largeImageKey = "totallyreallogo",
            largeImageText = "Rit"..(__DEBUG__ and " DEBUG MODE" or ""),
            startTimestamp = now
        }
    end,

    draw = function(self)
        -- show our results in middle of screen w/ song name

        -- TODO: MAKE THIS SHIT LOOK BETTER!!!!
        love.graphics.print("Results for " .. songData[1] .. " - " .. songData[2], graphics.getWidth() / 2, graphics.getHeight() / 2, 0, 2, 2)
        love.graphics.print("Score: " .. score, graphics.getWidth() / 2, graphics.getHeight() / 2 + 32, 0, 2, 2)
        love.graphics.print("Accuracy: " .. (math.floor(acc * 100) / 100) .. "%", graphics.getWidth() / 2, graphics.getHeight() / 2 + 64, 0, 2, 2)
        love.graphics.print("Rating: " .. curRating .. (died and " - Died" or ""), graphics.getWidth() / 2, graphics.getHeight() / 2 + 96, 0, 2, 2)

        -- show a button to go back to song select
        love.graphics.print("Press enter to go back to song select", graphics.getWidth() / 2, graphics.getHeight() / 2 + 188, 0, 2, 2)
    end
}