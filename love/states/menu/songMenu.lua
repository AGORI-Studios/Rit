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
local function chooseSongDifficulty()
end

local inputList = {
    "up",
    "down",
    "left",
    "right",
    "extB",
    "confirm"
}

local function selectSongDifficulty(_, chartVer)
    graphics.fadeOut(0.25,function()
        if chartVer ~= "FNF" and chartVer ~= "packs" then
            Timer.tween(0.25, menuMusicVol, {0})

            song = songList[curSongSelected]
            filename = song.filename
            love.filesystem.mount("songs/"..filename, "song")
            songPath = song.path
            songTitle = song.title
            songDifficultyName = song.difficultyName
            songRating = song.rating
        end
        if chartVer == "Quaver" then
            quaverLoader.load(songPath, song.folderPath)
        elseif chartVer == "osu!" then 
            osuLoader.load(songPath, song.folderPath)
        elseif chartVer == "FNF" then
            curMenu = "fnf"
        elseif chartVer == "Stepmania" then
            stepmaniaLoader.load(songPath, filename)
        end
    end)
end

local function doFnfMoment(fnfMoment)
    song = songList[curSongSelected]
    filename = song.filename
    songPath = song.path
    songTitle = song.title
    songDifficultyName = song.difficultyName..(fnfMomentShiz[fnfMomentSelected] and " - Player" or " - Enemy")
    folderPath = song.folderPath
    songRating = song.rating
    Timer.tween(0.25, menuMusicVol, {0})
    fnfLoader.load(songPath, fnfMomentShiz[fnfMomentSelected], folderPath)
    curMenu = "songSelect"
end

return {
    enter = function(self)
        debug.print("info", "Entering song select")
        chartEvents = {}
        bpmEvents = {}
        now = os.time()
        songSpeed = 1
        chooseSongDifficulty()
        curMenu = "songSelect"

        inputs = {
            ["up"] = {
                pressed = false,
                down = false,
                released = false
            },
            ["down"] = {
                pressed = false,
                down = false,
                released = false
            },
            ["left"] = {
                pressed = false,
                down = false,
                released = false
            },
            ["right"] = {
                pressed = false,
                down = false,
                released = false
            },
            ["confirm"] = {
                pressed = false,
                down = false,
                released = false
            },
            ["extB"] = {
                pressed = false,
                down = false,
                released = false
            }
        }

        if isMobile or __DEBUG__ then
            mobileButtons = {
                ["up"] = {
                    pressed = false,
                    down = false,
                    released = false,

                    x = 150,
                    y = 400,
                    w = 150,
                    h = 150,

                    draw = function(self)
                        -- rounded rectangle, fill if down

                        if self.down then
                            love.graphics.setColor(1, 1, 1, 0.5)
                            love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, 50, 50)
                        end

                        love.graphics.setColor(1, 1, 1, 1)
                        love.graphics.rectangle("line", self.x, self.y, self.w, self.h, 50, 50)
                    end
                },
                ["down"] = {
                    pressed = false,
                    down = false,
                    released = false,

                    x = 150,
                    y = 550,
                    w = 150,
                    h = 150,

                    draw = function(self)
                        -- rounded rectangle, fill if down

                        if self.down then
                            love.graphics.setColor(1, 1, 1, 0.5)
                            love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, 50, 50)
                        end

                        love.graphics.setColor(1, 1, 1, 1)
                        love.graphics.rectangle("line", self.x, self.y, self.w, self.h, 50, 50)
                    end
                },
                ["left"] = {
                    pressed = false,
                    down = false,
                    released = false,

                    x = 0,
                    y = 475,
                    w = 150,
                    h = 150,

                    draw = function(self)
                        -- rounded rectangle, fill if down

                        if self.down then
                            love.graphics.setColor(1, 1, 1, 0.5)
                            love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, 50, 50)
                        end

                        love.graphics.setColor(1, 1, 1, 1)
                        love.graphics.rectangle("line", self.x, self.y, self.w, self.h, 50, 50)
                    end
                },
                ["right"] = {
                    pressed = false,
                    down = false,
                    released = false,

                    x = 300,
                    y = 475,
                    w = 150,
                    h = 150,

                    draw = function(self)
                        -- rounded rectangle, fill if down

                        if self.down then
                            love.graphics.setColor(1, 1, 1, 0.5)
                            love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, 50, 50)
                        end

                        love.graphics.setColor(1, 1, 1, 1)
                        love.graphics.rectangle("line", self.x, self.y, self.w, self.h, 50, 50)
                    end
                },
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
                },
                ["extB"] = {
                    pressed = false,
                    down = false,
                    released = false,

                    x = 90,
                    y = 90,
                    w = 75,
                    h = 75,

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

        containerList = {}

        for i, song in ipairs(songList) do
            local container = {}
            --[[
                filename = v,
                title = title,
                difficultyName = difficultyName or "???",
                BackgroundFile = "None",
                path = "songs/" .. v .. "/" .. j,
                folderPath = "songs/" .. v,
                type = "osu!",
                rating = "",
                ratingColour
            ]]
            -- check if BackgroundFile exists
            if song.BackgroundFile ~= "None" and song.BackgroundFile ~= "" then
                container.container = emptyContainer
            else
                container.container = emptyContainer
            end

            container.title = song.title
            container.difficultyName = song.difficultyName
            container.rating = song.rating
            container.ratingColour = song.ratingColour
            container.type = song.type
            container.x = 1920 - container.container:getWidth()/2

            table.insert(containerList, container)
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

        if curMenu == "songSelect" then
            presence = {
                state = "Picking a song to play",
                largeImageKey = "totallyreallogo",
                largeImageText = "Rit"..(__DEBUG__ and " DEBUG MODE" or ""),
                startTimestamp = now
            }
            if inputs["up"].pressed then 
                curSongSelected = curSongSelected - 1
                if curSongSelected < 1 then
                    curSongSelected = #songList
                end
                if curSongSelected < 8 then 
                    songSelectScrollOffset = songSelectScrollOffset + (emptyContainer:getHeight() + 60)
                end
                if songSelectScrollOffset > 0 then
                    songSelectScrollOffset = 0
                end
                if curSongSelected == #songList and #songList >= 8 then
                    songSelectScrollOffset = -(#songList - 8) * (emptyContainer:getHeight() + 60)
                    if songSelectScrollOffset < -(#songList - 8) * (emptyContainer:getHeight() + 60) then
                        songSelectScrollOffset = -(#songList - 8) * (emptyContainer:getHeight() + 60)
                    end
                end
            elseif inputs["down"].pressed then 
                curSongSelected = curSongSelected + 1
                if curSongSelected > #songList then
                    curSongSelected = 1
                end
                if curSongSelected > 8 then 
                    songSelectScrollOffset = songSelectScrollOffset - (emptyContainer:getHeight() + 60)
                    if songSelectScrollOffset < -(#songList - 8) * (emptyContainer:getHeight() + 60) then
                        songSelectScrollOffset = -(#songList - 8) * (emptyContainer:getHeight() + 60)
                    end
                end
                if songSelectScrollOffset < 8 and songSelectScrollOffset > 0 then
                    songSelectScrollOffset = 0
                end
                if curSongSelected == 1 then
                    songSelectScrollOffset = 0
                end
            end
            if inputs["confirm"].pressed then 
                selectSongDifficulty(curSongSelected, songList[curSongSelected].type)
            end

            if inputs["left"].pressed and (inputs["extB"].pressed or love.keyboard.isDown("lalt")) then
                songSpeed = songSpeed - 0.1
                if songSpeed < 0.1 then
                    songSpeed = 0.1
                end
            elseif inputs["right"].pressed and (inputs["extB"].pressed or love.keyboard.isDown("lalt")) then
                songSpeed = songSpeed + 0.1
                if songSpeed > 2 then
                    songSpeed = 2
                end
            end
        elseif curMenu == "fnf" then
            if inputs["right"].pressed then 
                fnfMomentSelected = fnfMomentSelected + 1
            elseif inputs["left"].pressed then
                fnfMomentSelected = fnfMomentSelected - 1
            end
    
            if fnfMomentSelected > #fnfMomentShiz then
                fnfMomentSelected = 1
            elseif fnfMomentSelected < 1 then
                fnfMomentSelected = #fnfMomentShiz
            end
    
            if inputs["confirm"].pressed then
                graphics.fadeOut(0.25,function()
                    doFnfMoment(fnfMomentShiz[fnfMomentSelected])
                end)
            end
        end
        if inputs["left"].pressed and (inputs["extB"].pressed or love.keyboard.isDown("lalt")) then
            songSpeed = songSpeed - 0.1
            if songSpeed < 0.1 then
                songSpeed = 0.1
            end
        elseif inputs["right"].pressed and (inputs["extB"].pressed or love.keyboard.isDown("lalt")) then
            songSpeed = songSpeed + 0.1
            if songSpeed > 2 then
                songSpeed = 2
            end
        end

        for i, container in ipairs(containerList) do
            if curSongSelected == i then
                -- lerp x to 1920 - container.container:getWidth() - 200
                container.x = math.lerp(container.x, 1920 - container.container:getWidth() - 210, 0.1)
            elseif i == curSongSelected + 1 then
                -- lerp x to 1920 - container.container:getWidth()/2 - 150
                container.x = math.lerp(container.x, 1920 - container.container:getWidth()/2-150, 0.1)
            elseif i == curSongSelected - 1 then
                -- lerp x to 1920 - container.container:getWidth()/2 - 150  
                container.x = math.lerp(container.x, 1920 - container.container:getWidth()/2-150, 0.1)
            else
                -- lerp x to 1920 - container.container:getWidth()/2 - 100
                container.x = math.lerp(container.x, 1920 - container.container:getWidth()/2-100, 0.1)
            end
        end

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

    wheelmoved = function(self, x, y)
        if curMenu == "songSelect" then
            if y > 0 then 
                curSongSelected = curSongSelected - 1
                if curSongSelected < 1 then
                    curSongSelected = #songList
                end
                if curSongSelected < 8 then 
                    songSelectScrollOffset = songSelectScrollOffset + (emptyContainer:getHeight() + 60)
                end
                if songSelectScrollOffset > 0 then
                    songSelectScrollOffset = 0
                end
                if curSongSelected == #songList and #songList >= 8 then
                    songSelectScrollOffset = -(#songList - 8) * (emptyContainer:getHeight() + 60)
                    if songSelectScrollOffset < -(#songList - 8) * (emptyContainer:getHeight() + 60) then
                        songSelectScrollOffset = -(#songList - 8) * (emptyContainer:getHeight() + 60)
                    end
                end
            elseif y < 0 then
                curSongSelected = curSongSelected + 1
                if curSongSelected > #songList then
                    curSongSelected = 1
                end
                if curSongSelected > 8 then 
                    songSelectScrollOffset = songSelectScrollOffset - (emptyContainer:getHeight() + 60)
                    if songSelectScrollOffset < -(#songList - 8) * (emptyContainer:getHeight() + 60) then
                        songSelectScrollOffset = -(#songList - 8) * (emptyContainer:getHeight() + 60)
                    end
                end
                if songSelectScrollOffset < 8 and songSelectScrollOffset > 0 then
                    songSelectScrollOffset = 0
                end
                if curSongSelected == 1 then
                    songSelectScrollOffset = 0
                end
            end
        end
    end,

    keypressed = function(self, key)
        if key == "b" then 
            autoplay = not autoplay
        end
    end,

    draw = function(self)
        if curMenu == "songSelect" then
            love.graphics.push()
                love.graphics.translate(0, songSelectScrollOffset)
                for i, container in ipairs(containerList) do
                    local y = (container.container:getHeight() + 60) * (i - 1)
                    local x = container.x
                    
                    love.graphics.draw(container.container.img, x, y, 0, 1.5, 1.5)
                    -- print song title using printf so it can't go out of bounds
                    -- if the first character of difficultyName is a space, remove it
                    if container.difficultyName:sub(1,1) == " " then
                        container.difficultyName = container.difficultyName:sub(2)
                    end
                    love.graphics.printf(
                        {
                            {1,1,1}, container.title .. (container.type ~= "packs" and ("\n" .. container.difficultyName) or ""), 
                            DiffCalc.ratingColours((tonumber(container.rating) or 0)*songSpeed), (container.type ~= "packs" and " (" .. (tonumber(container.rating) * songSpeed or "N/A") .. ")" or "")
                        },
                        x+10, 
                        y+2, 
                        container.container:getWidth() - 20, 
                        "left", 
                        0, 
                        2, 2
                    )
                end
            love.graphics.pop()
            -- Print song speed in top right
            love.graphics.print("Song speed: " .. songSpeed, push.getWidth() - (font:getWidth("Song speed: " .. songSpeed) * 2), 0, 0, 2, 2)
        elseif curMenu == "fnf" then
            love.graphics.print("Play as [</>]: " .. (fnfMomentShiz[fnfMomentSelected] and "Player" or "Enemy"), 0, 0, 0, 2, 2)
        end
    end,

    leave = function(self)
        mobileButtons = nil
    end,
}