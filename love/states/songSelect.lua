local function chooseSongDifficulty()
    -- get all .qp files in songs/
    if not love.filesystem.getInfo("songs") then
        love.filesystem.createDirectory("songs")
        love.window.showMessageBox("Songs folder created!", "songs folder has been created at " .. love.filesystem.getSaveDirectory() .. "/songs", "info")
    end
    if not love.filesystem.getInfo("songs/quaver") then
        love.filesystem.createDirectory("songs/quaver")
    end
    if not love.filesystem.getInfo("songs/osu") then
        love.filesystem.createDirectory("songs/osu")
    end
    if not love.filesystem.getInfo("songs/stepmania") then
        love.filesystem.createDirectory("songs/stepmania")
    end
    if not love.filesystem.getInfo("songs/fnf") then
        love.filesystem.createDirectory("songs/fnf")
    end
    songList = {}
    for i, v in ipairs(love.filesystem.getDirectoryItems("songs/quaver")) do
        if love.filesystem.getInfo("songs/quaver/" .. v).type == "file" then
            love.filesystem.mount("songs/quaver/" .. v, "song")
            -- get all .qua files in the .qp file
            for k, j in ipairs(love.filesystem.getDirectoryItems("song")) do
                --print(j)
                --print(love.filesystem.getInfo("song/" .. j).type == "file")
                if love.filesystem.getInfo("song/" .. j).type == "file" then
                    --print("ok so")
                    if j:sub(-4) == ".qua" then
                        --print(j)
                        --print(love.filesystem.getInfo("song/" .. j).type == "file")
                        local title = love.filesystem.read("song/" .. j):match("Title:(.-)\r?\n")
                        local difficultyName = love.filesystem.read("song/" .. j):match("DifficultyName:(.-)\r?\n")
                        local BackgroundFile = love.filesystem.read("song/" .. j):match("BackgroundFile:(.-)\r?\n")
                        songList[#songList + 1] = {
                            filename = v,
                            title = title,
                            difficultyName = difficultyName or "???",
                            BackgroundFile = BackgroundFile:sub(2),
                            path = "song/" .. j,
                            type = "Quaver"
                        }
                    end
                end
            end
            love.filesystem.unmount("songs/quaver/"..v)
        end
    end
    for i, v in ipairs(love.filesystem.getDirectoryItems("songs/osu")) do 
        if love.filesystem.getInfo("songs/osu/" .. v).type == "file" then
            love.filesystem.mount("songs/osu/" .. v, "song")
            -- get all .qua files in the .qp file
            for k, j in ipairs(love.filesystem.getDirectoryItems("song")) do
                --print(j)
                --print(love.filesystem.getInfo("song/" .. j).type == "file")
                if love.filesystem.getInfo("song/" .. j).type == "file" then
                    --print("ok so")
                    if j:sub(-4) == ".osu" then
                        --print(j)
                        --print(love.filesystem.getInfo("song/" .. j).type == "file")
                        local title = love.filesystem.read("song/" .. j):match("Title:(.-)\r?\n")
                        local difficultyName = love.filesystem.read("song/" .. j):match("Version:(.-)\r?\n")
                        songList[#songList + 1] = {
                            filename = v,
                            title = title,
                            difficultyName = difficultyName or "???",
                            path = "song/" .. j,
                            type = "osu!"
                        }
                    end
                end
            end
            love.filesystem.unmount("songs/osu/"..v)
        end
    end
    for i, v in ipairs(love.filesystem.getDirectoryItems("songs/fnf")) do
        if love.filesystem.getInfo("songs/fnf/" .. v).type == "directory" then
            local songDir = "songs/fnf/" .. v
            for k, j in ipairs(love.filesystem.getDirectoryItems(songDir)) do
                if love.filesystem.getInfo(songDir .. "/" .. j).type == "file" then
                    if j:sub(-4) == "json" then
                        gsubbedFile = j:gsub(".json", "")
                        local difficultyName = gsubbedFile:match("-(.*)")
                        songList[#songList + 1] = {
                            filename = j,
                            title = json.decode(love.filesystem.read(songDir .. "/" .. j)).song.song,
                            difficultyName = difficultyName or "normal",
                            BackgroundFile = "None",
                            path = songDir .. "/" .. j,
                            folderPath = songDir,
                            type = "FNF"
                        }
                    end
                end
            end
        end
    end
    for i, v in ipairs(love.filesystem.getDirectoryItems("songs/stepmania")) do 
        -- stepmania songs are in folders
        if love.filesystem.getInfo("songs/stepmania/" .. v).type == "directory" then
            local songDir = "songs/stepmania/" .. v
            for k, j in ipairs(love.filesystem.getDirectoryItems(songDir)) do
                if love.filesystem.getInfo(songDir .. "/" .. j).type == "file" then
                    if j:sub(-3) == ".sm" then
                        local title = love.filesystem.read(songDir .. "/" .. j):match("#TITLE:(.-);")
                        local difficultyName = love.filesystem.read(songDir .. "/" .. j):match("#CREDIT:(.-);")
                        songList[#songList + 1] = {
                            filename = v,
                            title = title,
                            difficultyName = difficultyName or "???",
                            BackgroundFile = "None",
                            path = songDir .. "/" .. j,
                            folderPath = songDir,
                            type = "Stepmania"
                        }
                    end
                end
            end
        end
    end
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
        chartEvents = {}
        bpmEvents = {}
        chooseSongDifficulty()
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