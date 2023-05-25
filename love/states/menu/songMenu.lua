local function chooseSongDifficulty()
end

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
        elseif chartVer == "packs" then -- Open pack selector
            graphics.fadeIn(0.25)
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

local function loadPackSongs(pack)
    packSongList = {}
    graphics.fadeOut(0.25, function()
        for i, v in pairs(packs) do
            if v.name == pack then
                for i2, v2 in pairs(v.songs) do
                    packSongList[#packSongList + 1] = v2
                    if i2 == 1 then
                        for i3, v3 in pairs(v2) do
                            print(i3, v3)
                        end
                    end
                end
            end
        end

        graphics.fadeIn(0.25)
        curMenu = "packSongs"
        songSelectScrollOffset = 0
    end)
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
        packSongList = {}
    end,

    update = function(self, dt)
        if curMenu == "songSelect" then
            presence = {
                state = "Picking a song to play",
                largeImageKey = "totallyreallogo",
                largeImageText = "Rit"..(__DEBUG__ and " DEBUG MODE" or ""),
                startTimestamp = now
            }
            if input:pressed("up") then
                curSongSelected = curSongSelected - 1
                if curSongSelected < 1 then
                    curSongSelected = #songList
                end
                if curSongSelected < 29 then 
                    songSelectScrollOffset = songSelectScrollOffset + (font:getHeight() * 1.5)
                end
                if songSelectScrollOffset > 0 then
                    songSelectScrollOffset = 0
                end
                if curSongSelected == #songList and #songList >= 29 then
                    songSelectScrollOffset = -(#songList - 29) * (font:getHeight() * 1.5)
                    if songSelectScrollOffset < -(#songList - 29) * (font:getHeight() * 1.5) then
                        songSelectScrollOffset = -(#songList - 29) * (font:getHeight() * 1.5)
                    end
                end
            elseif input:pressed("down") then
                curSongSelected = curSongSelected + 1
                if curSongSelected > #songList then
                    curSongSelected = 1
                end
                if curSongSelected > 29 then 
                    songSelectScrollOffset = songSelectScrollOffset - (font:getHeight() * 1.5)
                    if songSelectScrollOffset < -(#songList - 29) * 30 then
                        songSelectScrollOffset = -(#songList - 29) * 30
                    end
                end
                if songSelectScrollOffset < 29 and songSelectScrollOffset > 0 then
                    songSelectScrollOffset = 0
                end
                if curSongSelected == 1 then
                    songSelectScrollOffset = 0
                end
            end
            if input:pressed("confirm") then
                selectSongDifficulty(curSongSelected, songList[curSongSelected].type)
            end

            if input:pressed("left") and (input:down("extB") or love.keyboard.isDown("lalt")) then
                songSpeed = songSpeed - 0.1
                if songSpeed < 0.1 then
                    songSpeed = 0.1
                end
            elseif input:pressed("right") and (input:down("extB") or love.keyboard.isDown("lalt")) then
                songSpeed = songSpeed + 0.1
                if songSpeed > 2 then
                    songSpeed = 2
                end
            end
            elseif input:pressed("right") then
        elseif curMenu == "fnf" then
            if input:pressed("right") then 
                fnfMomentSelected = fnfMomentSelected + 1
            elseif input:pressed("left") then
                fnfMomentSelected = fnfMomentSelected - 1
            end
    
            if fnfMomentSelected > #fnfMomentShiz then
                fnfMomentSelected = 1
            elseif fnfMomentSelected < 1 then
                fnfMomentSelected = #fnfMomentShiz
            end
    
            if input:pressed("confirm") then
                graphics.fadeOut(0.25,function()
                    doFnfMoment(fnfMomentShiz[fnfMomentSelected])
                end)
            end
        elseif curMenu == "packs" or curMenu == "packSongs" then
            if input:pressed("up") then
                curSongSelected = curSongSelected - 1
                if curSongSelected < 1 then
                    curSongSelected = #songList
                end
                if curSongSelected < 29 then 
                    songSelectScrollOffset = songSelectScrollOffset + (font:getHeight() * 1.5)
                end
                if songSelectScrollOffset > 0 then
                    songSelectScrollOffset = 0
                end
                if curSongSelected == #songList and #songList >= 29 then
                    songSelectScrollOffset = -(#songList - 29) * (font:getHeight() * 1.5)
                    if songSelectScrollOffset < -(#songList - 29) * (font:getHeight() * 1.5) then
                        songSelectScrollOffset = -(#songList - 29) * (font:getHeight() * 1.5)
                    end
                end
            elseif input:pressed("down") then
                curSongSelected = curSongSelected + 1
                if curSongSelected > #songList then
                    curSongSelected = 1
                end
                if curSongSelected > 29 then 
                    songSelectScrollOffset = songSelectScrollOffset - (font:getHeight() * 1.5)
                    if songSelectScrollOffset < -(#songList - 29) * 30 then
                        songSelectScrollOffset = -(#songList - 29) * 30
                    end
                end
                if songSelectScrollOffset < 29 and songSelectScrollOffset > 0 then
                    songSelectScrollOffset = 0
                end
                if curSongSelected == 1 then
                    songSelectScrollOffset = 0
                end
            end
        if input:pressed("left") and (input:down("extB") or love.keyboard.isDown("lalt")) then
            songSpeed = songSpeed - 0.1
            if songSpeed < 0.1 then
                    songSpeed = 0.1
                end
            elseif input:pressed("right") and (input:down("extB") or love.keyboard.isDown("lalt")) then
                songSpeed = songSpeed + 0.1
                if songSpeed > 2 then
                    songSpeed = 2
                end
            elseif input:pressed("confirm") and curMenu == "packs" then
                local curPack = packs[curSongSelected].name
                loadPackSongs(curPack)
                print("Loaded pack songs for " .. curPack)
            elseif input:pressed("confirm") and curMenu == "packSongs" then
                selectSongDifficulty(curSongSelected, songList[curSongSelected].type)
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
                if curSongSelected < 29 then 
                    songSelectScrollOffset = songSelectScrollOffset + (font:getHeight() * 1.5)
                end
                if songSelectScrollOffset > 0 then
                    songSelectScrollOffset = 0
                end
                if curSongSelected == #songList and #songList >= 29 then
                    songSelectScrollOffset = -(#songList - 29) * (font:getHeight() * 1.5)
                    if songSelectScrollOffset < -(#songList - 29) * (font:getHeight() * 1.5) then
                        songSelectScrollOffset = -(#songList - 29) * (font:getHeight() * 1.5)
                    end
                end
            elseif y < 0 then
                curSongSelected = curSongSelected + 1
                if curSongSelected > #songList then
                    curSongSelected = 1
                end
                if curSongSelected > 29 then 
                    songSelectScrollOffset = songSelectScrollOffset - (font:getHeight() * 1.5)
                    if songSelectScrollOffset < -(#songList - 29) * 30 then
                        songSelectScrollOffset = -(#songList - 29) * 30
                    end
                end
                if songSelectScrollOffset < 29 and songSelectScrollOffset > 0 then
                    songSelectScrollOffset = 0
                end
                if curSongSelected == 1 then
                    songSelectScrollOffset = 0
                end
            end
        elseif curMenu == "packs" then

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
                for i, v in ipairs(songList) do
                    if i == curSongSelected then
                        graphics.setColor(1, 1, 1)
                    else
                        graphics.setColor(0.5, 0.5, 0.5)
                    end
                    love.graphics.print(
                        {
                            {1,1,1}, v.title .. (v.type ~= "packs" and (" - " .. v.difficultyName) or ""), 
                            DiffCalc.ratingColours((tonumber(v.rating) or 0)*songSpeed), (v.type ~= "packs" and " (" .. (tonumber(v.rating) * songSpeed or "N/A") .. ")" or "")
                        },
                        0, 
                        i * (font:getHeight() *1.5), 
                        0, 
                        2, 2
                    )
                    graphics.setColor(1,1,1)
                end
            love.graphics.pop()
            -- Print song speed in top right
            love.graphics.print("Song speed: " .. songSpeed, push.getWidth() - (font:getWidth("Song speed: " .. songSpeed) * 2), 0, 0, 2, 2)
        elseif curMenu == "fnf" then
            love.graphics.print("Play as [</>]: " .. (fnfMomentShiz[fnfMomentSelected] and "Player" or "Enemy"), 0, 0, 0, 2, 2)
        elseif curMenu == "packs" then
            love.graphics.push()
                love.graphics.translate(0, songSelectScrollOffset)
                for i, v in ipairs(packs) do
                    if i == curSongSelected then
                        graphics.setColor(1, 1, 1)
                    else
                        graphics.setColor(0.5, 0.5, 0.5)
                    end
                    love.graphics.print(v.name .. " - " .. v.creator, 0, i * (font:getHeight() *1.5), 0, 2, 2)
                    graphics.setColor(1,1,1)
                end
            love.graphics.pop()
        elseif curMenu == "packSongs" then
            love.graphics.push()
                love.graphics.translate(0, songSelectScrollOffset)
                for i, v in ipairs(packSongList) do -- table with all pack songs
                    if i == curSongSelected then
                        graphics.setColor(1, 1, 1)
                    else
                        graphics.setColor(0.5, 0.5, 0.5)
                    end
                    love.graphics.print((v.title or "") .. " - " .. v.difficultyName, 0, i * (font:getHeight() *1.5), 0, 2, 2)
                    graphics.setColor(1,1,1)
                end
            love.graphics.pop()
            love.graphics.print("Song speed: " .. songSpeed, push.getWidth() - (font:getWidth("Song speed: " .. songSpeed) * 2), 0, 0, 2, 2)
        end
    end,
}