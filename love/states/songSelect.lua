local function chooseSongDifficulty()
end

local function selectSongDifficulty(song, chartVer)
    if chartVer == "Quaver" then
        song = songList[curSongSelected]
        filename = song.filename
        love.filesystem.mount("songs/quaver/"..filename, "song")
        songPath = song.path
        songTitle = song.title
        songDifficultyName = song.difficultyName
        BackgroundFile = love.graphics.newImage("song/" .. song.BackgroundFile)
        quaverLoader.load(songPath)
        choosingSong = false
    elseif chartVer == "osu!" then 
        song = songList[curSongSelected]
        filename = song.filename
        love.filesystem.mount("songs/osu/"..filename, "song")
        songPath = song.path
        songTitle = song.title
        songDifficultyName = song.difficultyName
        osuLoader.load(songPath)
        choosingSong = false
    elseif chartVer == "FNF" then
        fnfChartMoment = true
        choosingSong = false
    elseif chartVer == "Stepmania" then
        song = songList[curSongSelected]
        filename = song.filename
        songPath = song.path
        songTitle = song.title
        folderPath = song.folderPath
        songDifficultyName = song.difficultyName
        stepmaniaLoader.load(songPath, filename)
        choosingSong = false
    end
end

local function doFnfMoment(fnfMoment)
    song = songList[curSongSelected]
    filename = song.filename
    songPath = song.path
    songTitle = song.title
    songDifficultyName = song.difficultyName
    folderPath = song.folderPath
    --BackgroundFile = love.graphics.newImage("song/" .. song.BackgroundFile)
    fnfLoader.load(songPath, fnfMomentShiz[fnfMomentSelected])
    choosingSong = false
    fnfChartMoment = false
end

return {
    enter = function(self)
        debug.print("Entering song select")
        choosingSong = true
        fnfChartMoment = false
        chartEvents = {}
        bpmEvents = {}
        now = os.time()
        chooseSongDifficulty()
        presence = {
            details = nil, 
            state = "Picking a song to play",
            largeImageKey = "totallyreallogo",
            largeImageText = "Rit"..(__DEBUG__ and " DEBUG MODE" or ""),
            startTimestamp = now
        }
    end,

    update = function(self, dt)
        if choosingSong then
            if input:pressed("up") then
                curSongSelected = curSongSelected - 1
                if curSongSelected < 1 then
                    curSongSelected = #songList
                end
                if curSongSelected < 29 then 
                    songSelectScrollOffset = songSelectScrollOffset + 30
                end
                if songSelectScrollOffset > 0 then
                    songSelectScrollOffset = 0
                end
                if curSongSelected == #songList and #songList >= 29 then
                    songSelectScrollOffset = -(#songList - 29) * 30
                    if songSelectScrollOffset < -(#songList - 29) * 30 then
                        songSelectScrollOffset = -(#songList - 29) * 30
                    end
                end
            elseif input:pressed("down") then
                curSongSelected = curSongSelected + 1
                if curSongSelected > #songList then
                    curSongSelected = 1
                end
                if curSongSelected > 29 then 
                    songSelectScrollOffset = songSelectScrollOffset - 30
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
        elseif fnfChartMoment then
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
                doFnfMoment(fnfMomentShiz[fnfMomentSelected])
            end
        end
    end,

    keypressed = function(self, key)
        if key == "b" then 
            autoplay = not autoplay
        end
    end,

    draw = function(self)
        if choosingSong then
            love.graphics.push()
                love.graphics.translate(0, songSelectScrollOffset)
                for i, v in ipairs(songList) do
                    if i == curSongSelected then
                        love.graphics.setColor(1, 1, 1)
                    else
                        love.graphics.setColor(0.5, 0.5, 0.5)
                    end
                    love.graphics.print(v.title .. " - " .. v.difficultyName, 0, i * 35, 0, 2, 2)
                    love.graphics.setColor(1,1,1)
                end
            love.graphics.pop()
        elseif fnfChartMoment then
            love.graphics.print("Play as player? " .. tostring(fnfMomentShiz[fnfMomentSelected]), 0, 0, 0, 2, 2)
        end
    end,
}