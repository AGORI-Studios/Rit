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

local inputList = {
    "confirm"
}

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

        inputs = {
            ["confirm"] = {
                pressed = false,
                down = false,
                released = false
            }
        }

        if isMobile or __DEBUG__ then
            mobileButtons = {
                ["confirm"] = {
                    pressed = false,
                    down = false,
                    released = false,

                    x = 900,
                    y = 400,
                    w = 300,
                    h = 300,

                    draw = function(self)
                        -- rounded rectangle, fill if down

                        if self.down then
                            love.graphics.setColor(1, 1, 1, 0.5)
                            love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, 50, 50)
                        end

                        love.graphics.setColor(1, 1, 1, 1)
                        love.graphics.rectangle("line", self.x, self.y, self.w, self.h, 50, 50)
                    end
                }
            }
        end
    end,

    update = function(self, dt)
        for i = 1, #inputList do
            local curInput = inputList[i]

            if not isMobile and __DEBUG__ and mobileButtons then
                inputs[curInput].pressed = input:pressed(curInput) or mobileButtons[curInput].pressed
                inputs[curInput].down = input:down(curInput) or mobileButtons[curInput].down
                inputs[curInput].released = input:released(curInput) or mobileButtons[curInput].released
            elseif not isMobile then
                inputs[curInput].pressed = input:pressed(curInput)
                inputs[curInput].down = input:down(curInput)
                inputs[curInput].released = input:released(curInput)
            elseif isMobile then
                inputs[curInput].pressed = mobileButtons[curInput].pressed
                inputs[curInput].down = mobileButtons[curInput].down
                inputs[curInput].released = mobileButtons[curInput].released
            end
        end

        if inputs["confirm"].pressed then
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

        if mobileButtons then
            for i,v in pairs(mobileButtons) do
                v.pressed = false
                v.released = false
            end
        end

        for i, v in pairs(inputs) do
            v.pressed = false
            v.released = false
        end
    end,

    touchpressed = function(self, id, x, y, dx, dy, pressure)
        if mobileButtons then
            for i, v in pairs(mobileButtons) do
                if x > v.x and x < v.x + v.w and y > v.y and y < v.y + v.h then
                    v.pressed = true
                    v.down = true
                end
            end
        end
    end,

    touchreleased = function(self, id, x, y, dx, dy, pressure)
        if mobileButtons then
            for i, v in pairs(mobileButtons) do
                if x > v.x and x < v.x + v.w and y > v.y and y < v.y + v.h then
                    v.released = true
                    v.down = false
                end
            end
        end
    end,

    touchmoved = function(self, id, x, y, dx, dy, pressure)
        if mobileButtons then
            for i, v in pairs(mobileButtons) do
                -- if its no longer in the button, set it to false
                if not (x > v.x and x < v.x + v.w and y > v.y and y < v.y + v.h) then
                    v.pressed = false
                    v.down = false
                    v.released = true
                end
            end
        end
    end,

    mousepressed = function(self, x, y, button)
        if mobileButtons then
            for i, v in pairs(mobileButtons) do
                if x > v.x and x < v.x + v.w and y > v.y and y < v.y + v.h then
                    v.pressed = true
                    v.down = true
                end
            end
        end 
    end,

    mousereleased = function(self, x, y, button)
        if mobileButtons then
            for i, v in pairs(mobileButtons) do
                if x > v.x and x < v.x + v.w and y > v.y and y < v.y + v.h then
                    v.released = true
                    v.down = false
                end
            end
        end
    end,

    mousemoved = function(self, x, y, dx, dy, istouch)
        if mobileButtons then
            for i, v in pairs(mobileButtons) do
                -- if its no longer in the button, set it to false
                if not (x > v.x and x < v.x + v.w and y > v.y and y < v.y + v.h) then
                    v.pressed = false
                    v.down = false
                    v.released = true
                end
            end
        end
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
    end,
    
    leave = function(self)
        mobileButtons = nil
    end
}