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
local args, scorings, ratings, songData, died, scoreTXT, score, acc, curRating, replayHits, hitsTable
local replayFormat = ""
local tweenedAcc
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
        acc = scorings.ratingPercentLerp
        score = math.floor(score)

        replayHits = args[4]
        hitsTable = args[5].hits
        songLength = args[5].songLength / (songSpeed or 1)

        debug.print("info", "Score: "..score.." - "..acc.."%")

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
        debug.print("info", "checking for death")
        if not died then
            debug.print("info", "not dead, looping")
            debug.print("info", tostring(#ratings))
            for i = #ratings, 1, -1 do
                debug.print("info", "loop iter: "..i)
                debug.print("info", tostring(acc >= ratings[i].acc)..tostring(((math.floor(scoring.ratingPercentLerp * 10000) / 100)) >= ratings[i].acc))
                if ((math.floor(scoring.ratingPercentLerp * 10000) / 100)) >= ratings[i].acc then
                    curRating = ratings[i].name
                    debug.print("info", "Acc >= "..ratings[i].acc.." - "..ratings[i].name)
                    -- break
                end
            end
        end
        if died then
            debug.print("info", "Failed, rating F")
        end

        scoreS = score
        accS = acc

        tweenAcc = {0}

        points = {}
        pointColors = {}
        for i = 1, #hitsTable do
            pos = hitsTable[i][1]
            time = hitsTable[i][2]
            -- pos of 0-28 is while
            -- 29-43 is green
            -- 44-102 is blue
            -- 103-135 is purple
            -- 136-180 is red
            -- afterwords, set its position based off the width and height of 900, 400

            if pos <= 28 then
                table.insert(points, {x = 0, y = 0})
                table.insert(pointColors, {r = 255, g = 255, b = 255})
            elseif pos <= 43 then
                table.insert(points, {x = 0, y = 0})
                table.insert(pointColors, {r = 0, g = 255, b = 0})
            elseif pos <= 102 then
                table.insert(points, {x = 0, y = 0})
                table.insert(pointColors, {r = 0, g = 0, b = 255})
            elseif pos <= 135 then
                table.insert(points, {x = 0, y = 0})
                table.insert(pointColors, {r = 255, g = 0, b = 255})
            elseif pos <= 180 then
                table.insert(points, {x = 0, y = 0})
                table.insert(pointColors, {r = 255, g = 0, b = 0})
            end
        end
        for i = 1, #points do
            -- set the x based off the musicTime, songLength and width of 900
            -- pos is ms, songLength is seconds
            points[i].x = (hitsTable[i][2] / (songLength * 1000)) * 900
            -- set the y based off the pos and height of 400
            points[i].y = (hitsTable[i][1] / 180) * 400
        end

        -- check if score is higher than the current highscore
        if love.filesystem.getInfo("results/" .. songData[1] .. "-" .. songData[2] .. ".ritsc") then
            local file = love.filesystem.read("results/" .. songData[1] .. "-" .. songData[2] .. ".ritsc")
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
        if love.filesystem.getInfo("results/" .. songData[1] .. "-" .. songData[2] .. ".ritsc") then
            love.filesystem.remove("results/" .. songData[1] .. "-" .. songData[2] .. ".ritsc")
        end
        love.filesystem.write("results/" .. songData[1] .. "-" .. songData[2] .. ".ritsc", string.format(scoreTXT, scoreS, accS, curRating))
        replayFormat = json.encode(replayHits)
        love.filesystem.write("replays/" .. os.time() .. "-" .. songData[1] .. "-" .. songData[2] .. ".ritreplay", replayFormat)
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
        --[[
        -- show our results in middle of screen w/ song name

        -- TODO: MAKE THIS SHIT LOOK BETTER!!!!
        love.graphics.print("Results for " .. songData[1] .. " - " .. songData[2], graphics.getWidth() / 2, graphics.getHeight() / 2, 0, 2, 2)
        love.graphics.print("Score: " .. score, graphics.getWidth() / 2, graphics.getHeight() / 2 + 32, 0, 2, 2)
        love.graphics.print("Accuracy: " .. ((math.floor(scoring.ratingPercentLerp * 10000) / 100)) .. "%", graphics.getWidth() / 2, graphics.getHeight() / 2 + 64, 0, 2, 2)
        love.graphics.print("Rating: " .. curRating .. (died and " - Died" or ""), graphics.getWidth() / 2, graphics.getHeight() / 2 + 96, 0, 2, 2)

        -- show a button to go back to song select
        love.graphics.print("Press enter to go back to song select", graphics.getWidth() / 2, graphics.getHeight() / 2 + 188, 0, 2, 2)
        --]]

        -- WIP Menu, just exists so people can see their scores :>

        -- BG
        graphics.setColor(0.7,0.7,0.7)
        love.graphics.rectangle("fill", -1000, -1000, 3000, 3000)

        -- Left bar
        love.graphics.setColor(0.9, 0.9, 0.9)
        love.graphics.rectangle("fill", 10, 10, 900, push:getHeight()-20, 10, 10)

        -- Left bar info
        love.graphics.push()
            love.graphics.scale(2,2)
            love.graphics.setColor(0, 0, 0)
            love.graphics.print("Results for " .. songData[1] .. " - " .. songData[2], 20, 20)
            love.graphics.print("Score: " .. score, 20, 52)
            love.graphics.print("Accuracy: " .. ((math.floor(scoring.ratingPercentLerp * 10000) / 100)) .. "%", 20, 84)
            love.graphics.print("Rating: " .. curRating .. (died and " - Died" or ""), 20, 116)
        love.graphics.pop()

        -- Accuracy circle
        love.graphics.push()
            love.graphics.translate(50, 400)
            love.graphics.scale(0.5, 0.5)
            love.graphics.setColor(0.5, 0.5, 0.5)
            love.graphics.circle("fill", 450, 450, 400)
            -- Draw a border around the circle, ((math.floor(scoring.ratingPercentLerp * 10000) / 100)) is 1-100
            love.graphics.setColor(0.25, 0.25, 0.25)
            love.graphics.setLineWidth(10)
            love.graphics.arc("line", "open", 450, 450, 400, 0, ((math.floor(scoring.ratingPercentLerp * 10000) / 100) / 100) * (2 * math.pi))
            love.graphics.setLineWidth(1)
        love.graphics.pop()

        -- Rating Graph
        graphics.setColor(0.9, 0.9, 0.9)
        -- draw large rounded rectangle on bottom right
        love.graphics.rectangle("fill", graphics.getWidth() - 925, graphics.getHeight() - 450, 900, 400, 10, 10)
        -- draw the points
        for i = 1, #points do
            graphics.setColor(pointColors[i].r/255, pointColors[i].g/255, pointColors[i].b/255)
            love.graphics.circle("fill", graphics.getWidth() - 925 + points[i].x, graphics.getHeight() - 450 + points[i].y, 5)
        end
    end
}