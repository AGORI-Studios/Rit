---@diagnostic disable: need-check-nil, param-type-mismatch
local SongMenu = state()

local songButtons = {}

local curSelected = 1
local balls = {}
local curSongType = "All"
curTab = "songs" -- songs or diffs
local lerpedSongPos = 0
local transitioning = false
local curButton = nil
local lastCurSelected = 1
local showCat = true
local inSidebar = false

local songTimer
local typing = false
local searchText = ""
SongMenu.replays = {}

local utf8 = require("utf8")

function SongMenu:enter()
    typing = false
    searchText = ""
    curTab = "songs"
    lerpedSongPos = 0
    curButton = nil
    showCat = true
    inSidebar = false
    songButton = Sprite(0, 0, "assets/images/ui/menu/songBtn.png")
    statsBox = Sprite(900, 125, "assets/images/ui/menu/statsBox.png")
    diffButton = Sprite(0, songButton.height-55, "assets/images/ui/menu/diffBtn.png")
    statsBox:setScale(1.75)
    bg = Sprite(0, 0, "assets/images/ui/menu/playBG.png")
    playTab = Sprite(1920/1.7, 85, "assets/images/ui/menu/playTab.png")
    for i = 1, 5 do
        balls[i] = Sprite(love.math.random(0, 1600), love.math.random(0, 720), "assets/images/ui/menu/BGball" .. i .. ".png")
        balls[i].alpha = 0.71
        balls[i].blend = "lighten"
        balls[i].blendAlphaMode = "premultiplied"
        balls[i].ogX, balls[i].ogY = love.math.random(0, 1920 - balls[i].width), love.math.random(0, 1080 - balls[i].height)
        balls[i].velY = love.math.random(25, 50)
    end
    table.randomize(balls)

    searchCatTab = Sprite(0, -140, "assets/images/ui/menu/searchCatTab.png")
    magnifyingGlass = Sprite(370, -132, "assets/images/ui/menu/magnifyingGlass.png")
    searchCatTab.blend = "screen"

    magnifyingGlass:setScale(1.25)

    if discordRPC then
        discordRPC.presence = {
            details = "In the menu",
            state = "Selecting a song",
            largeImageKey = "totallyreallogo",
            largeImageText = "Rit" .. (__DEBUG__ and " DEBUG MODE" or "")
        }
        GameInit.UpdateDiscord()
    end

    songButtons = {}

    for i, song in pairs(songList) do
        local diffs = {}
        local bmType = nil
        local songName = nil
        local creator = nil
        local artist = nil
        local description = nil
        local tags = nil
        for j, diff in pairs(song) do
            if type(diff) == "table" then
                table.insert(diffs, diff)
                songName = diff.title:trim()
                bmType = diff.type
                creator = diff.creator
                artist = diff.artist
                description = diff.description
                tags = diff.tags
            else
                -- if diff is a key in songButtons, then don't set it
                if songButtons[diff] then
                    bmType = diff
                end
            end
        end
        local y = #songButtons * songButton.height * 0.75
        local btn = SongButton(y, diffs, bmType, songName, artist, creator, description or "This map has no description.", tags or {})
        btn.x = -125
        table.insert(songButtons, btn)
    end
    
    -- sort the songButtons by name
    table.sort(songButtons, function(a, b)
        return a.name < b.name
    end)

    for i, btn in ipairs(songButtons) do
        btn.y = (i - 1) * songButton.height * 0.75
    end

    SearchAlgorithm:setUpSongButtons(songButtons)

    if songButtons[lastCurSelected] then
        playSelectedSong(songButtons[lastCurSelected])
    end

    curSelected = lastCurSelected

    if curSelected > #songButtons then
        curSelected = #songButtons
    end
    if lastCurSelected > #songButtons then
        lastCurSelected = #songButtons
    end
end

function SongMenu:update(dt)
    if states.game.Gameplay.soundManager then
        states.game.Gameplay.soundManager:removeAllSounds()
    end
    if state.inSubstate then return end
    if curTab == "songs" then
        curSelected = math.clamp(curSelected, 1, #songButtons)
        lerpedSongPos = math.fpsLerp(lerpedSongPos, (-(curSelected - 2.5)) * songButton.height * 0.75 + 250, 25, dt)
        if curButton then
            curButton.selected = false
        end
        ---@class curButton : SongButton
        curButton = songButtons[curSelected]
        if curButton then
            curButton.selected = true
        end
    else
        if curButton then
            curSelected = math.clamp(curSelected, 1, #curButton.children)
        else
            curSelected = 1
        end
        lerpedSongPos = math.fpsLerp(lerpedSongPos, (-(curSelected - 2.5)) * diffButton.height * 1.1, 25, dt)
    end

    for i, bubble in ipairs(balls) do
        bubble.ogX = bubble.ogX + math.sin((love.timer.getTime()*1000) / (100 * i)) * 0.05
        -- velY is the speed of the bubble
        bubble.ogY = bubble.ogY - bubble.velY * dt

        if bubble.ogY < -bubble.height then
            bubble.ogY = Inits.GameHeight + 100
            bubble.ogX = love.math.random(0, 1920 - bubble.width)
            bubble.velY = love.math.random(25, 50)
        end

        bubble.x = bubble.ogX
        bubble.y = bubble.ogY
    end
    
    if input:pressed("confirm") and not transitioning then
        if curTab == "songs" then
            if typing then
                typing = false
                if searchText == "" then 
                    songButtons = SearchAlgorithm.allSongButtons
                    if curButton then
                        curButton.selected = false
                        for i, btn in ipairs(songButtons) do
                            btn.y = (i - 1) * songButton.height * 0.75
                        end
                    end
                    curButton = songButtons[curSelected]
                else
                    songButtons = SearchAlgorithm:doSearch(searchText)
                    for i, btn in ipairs(songButtons) do
                        btn.y = (i - 1) * songButton.height * 0.75
                    end
                    curSelected = 1
                    curButton = songButtons[curSelected]
                    if curButton then
                        playSelectedSong(curButton)
                    end
                end
            elseif not typing and curButton then
                showCat = false
                transitioning = true
                curTab = "diffs"
                lastCurSelected = curSelected
                curSelected = 1
                 curButton.open = true

                -- songName and songDiff
                self.songName = curButton.name
                self.songDiff = curButton.children[curSelected].name
                getSongReplays()

                for i, diff in ipairs(curButton.children) do
                    Timer.tween(0.1, diff, {x = 0}, "out-quad", function()
                        diff.x = 0
                        transitioning = false
                    end)
                end
            end
        elseif curTab == "diffs" then
            local diff = curButton.children[curSelected]
            local songPath = diff.path
            local chartver = diff.chartVer
            local folderpath = diff.folderPath
            local filename = diff.filename
            local diffName = diff.name
            local mode = diff.mode
            love.filesystem.mount("songs/" .. filename, "song")
            if chartver ~= "FNF" then
                states.game.Gameplay.chartVer = chartver
                states.game.Gameplay.songPath = songPath
                states.game.Gameplay.folderpath = folderpath
                states.game.Gameplay.difficultyName = diffName
                switchState(states.game.Gameplay, 0.3, nil)
            end
            MenuSoundManager:removeAllSounds()
        end
    elseif input:pressed("back") and not transitioning then
        if curTab == "diffs" then
            showCat = true
            transitioning = true
            curTab = "songs"
            curSelected = lastCurSelected
            if curButton then
                curButton.open = false
            end
            
            for _, btn in ipairs(songButtons) do
                for _, diff in ipairs(btn.children) do
                    Timer.tween(0.1, diff, {x = -diff.width}, "out-quad", function()
                        diff.x = -diff.width
                        transitioning = false
                    end)
                end
            end
            
        else
            switchState(states.menu.StartMenu)
        end
    end

    if input:pressed("down") then 
        curSelected = curSelected + 1 
        if curTab == "songs" then
            curSelected = math.clamp(curSelected, 1, #songButtons)
            lastCurSelected = curSelected
            if songTimer then Timer.cancel(songTimer) end
            songTimer = Timer.after(1, function()
                if songButtons[lastCurSelected] then
                    playSelectedSong(songButtons[lastCurSelected])
                end
            end)
        elseif curTab == "diffs" then
            if curButton then
                curSelected = math.clamp(curSelected, 1, #curButton.children)
                self.songName = curButton.name
                self.songDiff = curButton.children[curSelected].name
            else
                curSelected = 1
            end
            getSongReplays()
        end
    end
    if input:pressed("up") then 
        curSelected = curSelected - 1 
        if curTab == "songs" then
            curSelected = math.clamp(curSelected, 1, #songButtons)
            lastCurSelected = curSelected
            if songTimer then Timer.cancel(songTimer) end
            songTimer = Timer.after(1, function()
                if songButtons[lastCurSelected] then
                    playSelectedSong(songButtons[lastCurSelected])
                end
            end)
        elseif curTab == "diffs" then
            if curButton then
                curSelected = math.clamp(curSelected, 1, #curButton.children)
                self.songName = curButton.name
                self.songDiff = curButton.children[curSelected].name
            end
            getSongReplays()
        end
    end
end

function SongMenu:wheelmoved(x, y)
    if state.inSubstate then return end
    curSelected = curSelected - y
    if curTab == "songs" then
        lastCurSelected = curSelected
        if songTimer then Timer.cancel(songTimer) end
        songTimer = Timer.after(1, function()
            if songButtons[lastCurSelected] then
                playSelectedSong(songButtons[lastCurSelected])
            end
        end)
    end
end

function SongMenu:mousepressed(x, y, b)
    if state.inSubstate then return end
    local x, y = toGameScreen(x-10, y)
    Header:mousepressed(x, y, b)
    if b == 1 then
        y = y - lerpedSongPos

        if searchCatTab:isHovered(x, y) and showCat then
            typing = not typing
        end

        for i, btn in ipairs(songButtons) do
            if curTab == "diffs" then
                for i, diffBtn in ipairs(btn.children) do
                    if diffBtn:isHovered(x, y) then
                        if curSelected == i then
                            local diff = curButton.children[curSelected]
                            local songPath = diff.path
                            local chartver = diff.chartVer
                            local folderpath = diff.folderPath
                            local filename = diff.filename
                            local diffName = diff.name
                            local mode = diff.mode
                            
                            love.filesystem.mount("songs/" .. filename, "song")
                            
                            if chartver ~= "FNF" then
                                states.game.Gameplay.chartVer = chartver
                                states.game.Gameplay.songPath = songPath
                                states.game.Gameplay.folderpath = folderpath
                                states.game.Gameplay.difficultyName = diffName
                                switchState(states.game.Gameplay, 0.3, nil)
                            end
                            MenuSoundManager:removeAllSounds()
                        else
                            curSelected = i
                        end
                    end
                end
            elseif curTab == "songs" then
                if btn:isHovered(x, y) then
                    if curSelected == i and curButton then
                        showCat = false
                        transitioning = true
                        curTab = "diffs"
                        lastCurSelected = curSelected
                        curSelected = 1
                        curButton = btn
                        curButton.open = true
                        self.songName = curButton.name
                        self.songDiff = curButton.children[curSelected].name
                        getSongReplays()
                        for i, diff in ipairs(curButton.children) do
                            Timer.tween(0.1, diff, {x = 0}, "out-quad", function()
                                diff.x = 0
                                transitioning = false
                            end)
                        end
                    else
                        curSelected = i
                        lastCurSelected = curSelected
                        if songTimer then Timer.cancel(songTimer) end
                        songTimer = Timer.after(1, function()
                            if songButtons[lastCurSelected] then
                                playSelectedSong(songButtons[lastCurSelected])
                            end
                        end)
                    end
                end
            end
        end
    end
end

function SongMenu:keypressed(key)
    if key == "backspace" and typing then
        local byteoffset = utf8.offset(searchText, -1)
        if byteoffset then
            searchText = string.sub(searchText, 1, byteoffset - 1)
        end
    end
end

function SongMenu:textinput(t)
    if typing then
        searchText = searchText .. (t or "")
    end
end

function SongMenu:draw()
    bg:draw()
    for i = 1, #balls do
        balls[i]:draw()
    end
    playTab:draw()
    if curTab == "songs" then
        local lastFont = love.graphics.getFont()
        if curButton then
            local name = (curButton.name or "Unknown"):strip()
            local artist = (curButton.artist or "Unknown"):strip()
            local mapper = (curButton.creator or "Unknown"):strip()
            local desc = (curButton.description or "This map has no description."):strip()
            local descLength = #desc:splitAllCharacters()
            local maxLength = ("Hi this is testing a \"very long\" description in rit to see how it displays. Look off? Please report it. Description's should look no longer than this.")
            if descLength > #maxLength:splitAllCharacters() then
                desc = desc:sub(1, #maxLength) .. "..."
            end
            --1920/1.7, 85
            love.graphics.setColor(0, 0, 0, 0.25)
            love.graphics.rectangle("fill", 1920/1.15, 310, 1920/9, 425, 25, 25)

            love.graphics.setColor(0, 0, 0, 0.6)
            love.graphics.rectangle("fill", 1920/1.625, 775, 1920/2.74, 235, 25, 25)

            love.graphics.setColor(1, 0.8, 0.8, 0.15)
            love.graphics.rectangle("fill", 1920/1.625, 275, 1920/2.74, 4, 10, 10)

            love.graphics.rectangle("fill", 1920/1.1, 125, 125, 125, 10, 10)
            
            love.graphics.setColor(1, 1, 1)
            setFont("menuExtraBoldX2.5")

            if fontWidth("menuExtraBoldX2.5", name) > 550 then
                local newWidth = 0
                local newString = ""
                for i = 1, #name:splitAllCharacters() do
                    local char = name:sub(i, i)
                    newWidth = newWidth + fontWidth("menuExtraBoldX2.5", char)
                    if newWidth > 550 then
                        -- break, remove last 3, and add "..."
                        newString = newString:sub(1, #newString - 3) .. "..."
                        break
                    else
                        newString = newString .. char
                    end
                end
                name = newString
            end
            love.graphics.print(name, 1920/1.625, 105, 0, 1, 1)

            setFont("menuExtraBoldX1.5")
            if fontWidth("menuExtraBoldX1.5", artist) > 400 then
                local newWidth = 0
                local newString = ""
                for i = 1, #artist:splitAllCharacters() do
                    local char = artist:sub(i, i)
                    newWidth = newWidth + fontWidth("menuExtraBoldX1.5", char)
                    if newWidth > 317 then
                        newString = newString:sub(1, #newString - 3) .. "..."
                        break
                    else
                        newString = newString .. char
                    end
                end
                artist = newString
            end

            love.graphics.setColor(200/255, 80/255, 104/255)
            love.graphics.print("By " .. (artist or "Unknown"), 1920/1.625, 125 + 40, 0, 1, 1)
            
            setFont("menuBoldX1.5")

            if fontWidth("menuBoldX1.5", mapper) > 400 then
                local newWidth = 0
                local newString = ""
                for i = 1, #mapper:splitAllCharacters() do
                    local char = mapper:sub(i, i)
                    newWidth = newWidth + fontWidth("menuBoldX1.5", char)
                    if newWidth > 317 then
                        newString = newString:sub(1, #newString - 3) .. "..."
                        break
                    else
                        newString = newString .. char
                    end
                end
                mapper = newString
            end

            love.graphics.setColor(225/255, 105/255, 129/255)
            love.graphics.print("Mapped by " .. (mapper or "Unknown"), 1920/1.625, 125 + 75, 0, 1, 1)

            setFont("NatsRegular26")
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(desc, 1920/1.6, 800, 1920/4, "left", 0, 1.5, 1.5)
        end

        love.graphics.setFont(lastFont)
    end

    --[[ if curTab == "diffs" then
        --statsBox:draw()
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("fill", 900, 125, 920, 800, 5, 5)
        love.graphics.setColor(0, 0, 0)
        love.graphics.setLineWidth(5)
        love.graphics.rectangle("line", 900, 125, 920, 800, 5, 5)
        love.graphics.setColor(1, 1, 1)

        if curButton then
            local diff = curButton.children[curSelected]
            if diff then
                love.graphics.setColor(1, 1, 1)
                -- left align, only button info we display, is name and chart version
                love.graphics.printf(curButton.name:strip() .. " | " .. diff.name:strip(), 905, 125, 920, "left", 0, 2, 2)
                love.graphics.printf(diff.chartVer, 905, 125 + 50, 920, "left", 0, 2, 2)

                love.graphics.setLineWidth(5)
                love.graphics.line(905, 125 + 100, 1815, 125 + 100)

                for i, replay in ipairs(self.replays) do
                    love.graphics.setColor(0.5, 0.5, 0.5)
                    love.graphics.rectangle("fill", 905, 125 + 100 + 100 * (i-1), 920, 100)
                    love.graphics.setColor(0, 0, 0)
                    love.graphics.rectangle("line", 905, 125 + 100 + 100 * (i-1), 920, 100)
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.printf(os.date("%Y-%m-%d %H:%M:%S", replay.time), 905, 125 + 100 + 100 * (i-1), 920, "left", 0, 2, 2)
                    love.graphics.printf("Score: " .. math.floor(replay.score.score), 905, 125 + 125 + 100 * (i-1), 920, "left", 0, 2, 2)
                    love.graphics.printf("Accuracy: " .. string.format("%.2f", replay.score.accuracy) .. "%", 905, 125 + 150 + 100 * (i-1), 920, "left", 0, 2, 2)
                end
            end
        end

        love.graphics.setLineWidth(1)
    end ]]
    love.graphics.push()
    --[[ diffButton:draw()
    songButton:draw() ]]
    setFont("menuBold")
    love.graphics.translate(0, lerpedSongPos)
    for i, btn in ipairs(songButtons) do
        -- dont draw if it's out of bounds with lerpedSongPos
        if not btn.open then
            if not (btn.y + lerpedSongPos > 1080 or btn.y + lerpedSongPos < -btn.height) then
                if curSelected ~= i then
                    btn.color = {0.5, 0.5, 0.5}
                else
                    btn.color = {1, 1, 1}
                end
                btn:draw(0, lerpedSongPos, curSelected, #songButtons)
            end
        elseif btn.open then
            for j, diffBtn in ipairs(btn.children) do
                if curSelected ~= j then
                    diffBtn.color = {0.5, 0.5, 0.5}
                else
                    diffBtn.color = {1, 1, 1}
                end
                diffBtn:draw(0, lerpedSongPos)

                love.graphics.setColor(1, 1, 1, 1)
                local name = diffBtn.name
                if fontWidth("menuBold", name) > 317 then
                    local newWidth = 0
                    local newString = ""
                    for i = 1, #name:splitAllCharacters() do
                        local char = name:sub(i, i)
                        newWidth = newWidth + fontWidth("menuBold", char)
                        if newWidth > 317 then
                            -- break, remove last 3, and add "..."
                            newString = newString:sub(1, #newString - 3) .. "..."
                            break
                        else
                            newString = newString .. char
                        end
                    end
                    name = newString
                end
                love.graphics.print(name, diffBtn.x + 10, diffBtn.y + 30, 0, 2, 2)
            end
        end
        love.graphics.setColor(1, 1, 1, 1)
    end
    if showCat then
        magnifyingGlass:draw()
        love.graphics.print(searchText, 30, -132, 0, 1.25, 1.25)
        searchCatTab:draw()
    end
    love.graphics.pop()
    
    Header:draw()
    
    setFont("default")
end

return SongMenu