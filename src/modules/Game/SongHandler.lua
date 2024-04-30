
local lf = love.filesystem -- i use this a lot so i just made it a variable
songList = {}
function loadSongs(path) -- Gross yucky way of loading all of our songs in the given folder path
    for _, file in ipairs(lf.getDirectoryItems(path)) do
        --print("Checking " .. file)
        if lf.getInfo(path .."/" .. file).type == "directory" then
            --print("Found folder " .. file)
            for _, song in ipairs(lf.getDirectoryItems(path .."/" .. file)) do
                --print("Checking " .. song)
                if lf.getInfo(path .."/" .. file .. "/" .. song).type == "file" then
                    --print("Found song " .. song)
                    if song:sub(-4) == ".qua" then
                        local fileData = lf.read(path .."/" .. file .. "/" .. song)
                        local title = fileData:match("Title:(.-)\r?\n")
                        local difficultyName = fileData:match("DifficultyName:(.-)\r?\n")
                        local mode = fileData:match("Mode:(.-)\r?\n"):gsub("^%s*(.-)%s*$", "%1")
                        local Creator = fileData:match("Creator:(.-)\r?\n")
                        local AudioFile = fileData:match("AudioFile:(.-)\r?\n"):trim()
                        local alreadyInList = false
                        for _, song in ipairs(songList) do
                            if song.title == title and song.difficultyName == difficultyName then
                                alreadyInList = true
                            end
                        end
                        if not alreadyInList then
                            songList[title] = songList[title] or {}
                            songList[title][difficultyName] = {
                                filename = file,
                                title = title,
                                difficultyName = difficultyName,
                                path = path .."/" .. file .. "/" .. song,
                                folderPath = path .."/" .. file,
                                type = "Quaver",
                                rating = "",
                                ratingColour = {1,1,1},
                                creator = Creator,
                                mode = mode:match("%d+"),
                                audioFile = path .."/" .. file .. "/" .. AudioFile
                            }
                            songList[title].type = "Quaver"
                        end
                    elseif song:sub(-4) == ".osu" then
                        local fileData = lf.read(path .."/" .. file .. "/" .. song)
                        local title = fileData:match("Title:(.-)\r?\n")
                        local difficultyName = fileData:match("Version:(.-)\r?\n")
                        local AudioFile = fileData:match("AudioFilename:(.-)\r?\n"):trim()
                        local alreadyInList = false
                        for _, song in ipairs(songList) do
                            if song.title == title and song.difficultyName == difficultyName then
                                alreadyInList = true
                            end
                        end
                        local Mode = fileData:match("Mode:(.-)\r?\n"):trim()
                        -- needs to be 3, else FUCK YOU! because 3 equals mania!!!
                        if Mode ~= "3" then goto continue end
                        if not alreadyInList then
                            songList[title] = songList[title] or {}
                            songList[title][difficultyName] = {
                                filename = file,
                                title = title,
                                difficultyName = difficultyName,
                                path = path .."/" .. file .. "/" .. song,
                                folderPath = path .."/" .. file,
                                type = "osu!",
                                rating = "",
                                ratingColour = {1,1,1},
                                audioFile = path .."/" .. file .. "/" .. AudioFile
                            }
                            songList[title].type = "osu!"
                        end
                        ::continue::
                    elseif song:sub(-5) == ".ritc" then
                        local fileData = lf.read(path .."/" .. file .. "/" .. song)
                        local title = fileData:match("SongTitle:(.-)\r?\n")
                        local difficultyName = fileData:match("SongDiff:(.-)\r?\n")
                        local AudioFile = fileData:match("AudioFile:(.-)\r?\n"):trim()
                        local alreadyInList = false
                        for _, song in ipairs(songList) do
                            if song.title == title and song.difficultyName == difficultyName then
                                alreadyInList = true
                            end
                        end
                        if not alreadyInList then
                            songList[title] = songList[title] or {}
                            songList[title][difficultyName] = {
                                filename = file,
                                title = title,
                                difficultyName = difficultyName,
                                path = path .."/" .. file .. "/" .. song,
                                folderPath = path .."/" .. file,
                                type = "Rit",
                                rating = "",
                                ratingColour = {1,1,1},
                                audioFile = path .."/" .. file .. "/" .. AudioFile
                            }
                            songList[title].type = "Rit"
                        end
                    elseif song:sub(-3) == ".mc" then
                        local fileData = json.decode(lf.read(path .."/" .. file .. "/" .. song))
                        local title = fileData.meta.song.title
                        local difficultyName = fileData.meta.version
                        local AudioFile
                        for i, note in ipairs(fileData.note) do
                            if note.type == 1 then
                                AudioFile = note.sound
                            end
                        end
                        local alreadyInList = false
                        for _, song in ipairs(songList) do
                            if song.title == title and song.difficultyName == difficultyName then
                                alreadyInList = true
                            end
                        end
                        if not alreadyInList then
                            songList[title] = songList[title] or {}
                            songList[title][difficultyName] = {
                                filename = file,
                                title = title,
                                difficultyName = difficultyName,
                                path = path .."/" .. file .. "/" .. song,
                                folderPath = path .."/" .. file,
                                type = "Malody",
                                rating = "",
                                ratingColour = {1,1,1},
                                audioFile = path .."/" .. file .. "/" .. AudioFile
                            }
                        end
                        songList[title].type = "Malody"
                    --[[ elseif song:sub(-6) == ".chart" then
                        -- check for song.ini in same path
                        local songIni = lf.getInfo(path .."/" .. file .. "/song.ini")
                        local songMeta
                        local chart = clone.parse(path .."/" .. file .. "/" .. song)
                        if songIni then
                            -- parse with ini.parse
                            songMeta = ini.parse(path .."/" .. file .. "/song.ini")
                        else
                            -- ignore
                            goto continue
                        end
                        local title = songMeta.Song.name
                        local diffName = "ExpertSingle"
                        local AudioFile = chart.meta.MusicStream:trim()
                        local alreadyInList = false
                        for _, song in ipairs(songList) do
                            if song.title == title and song.difficultyName == diffName then
                                alreadyInList = true
                            end
                        end
                        if not alreadyInList then
                            songList[title] = songList[title] or {}
                            songList[title][diffName] = {
                                filename = file,
                                title = title,
                                difficultyName = diffName,
                                path = path .."/" .. file .. "/" .. song,
                                folderPath = path .."/" .. file,
                                type = "CloneHero",
                                rating = "",
                                ratingColour = {1,1,1},
                                audioFile = path .."/" .. file .. "/" .. AudioFile
                            }
                        end
                        songList[title].type = "CloneHero"
                        ::continue:: ]]
                        -- With how stupid I am, stepmania is probably going to be the last thing I add (I say as clone hero is literally in the works too)
                    elseif song:sub(-3) == ".sm" then -- for stepmania, we have to call "smLoader.getDifficulties(chart)"
                        diffs = Parsers["Stepmania"].getDifficulties(path .."/" .. file .. "/" .. song)
                        -- has a table in a table (holds name and songName)
                        for _, diff in pairs(diffs) do
                            local alreadyInList = false
                            for _, song in ipairs(songList) do
                                print(song.title, diff.songName, song.difficultyName, diff.name)
                                if song.title == diff.songName and song.difficultyName == diff.name then
                                    alreadyInList = true
                                end
                            end

                            if not alreadyInList then
                                songList[diff.songName] = songList[diff.songName] or {}
                                songList[diff.songName][diff.name] = {
                                    filename = file,
                                    title = diff.songName,
                                    difficultyName = diff.name,
                                    path = path .."/" .. file .. "/" .. song,
                                    folderPath = path .."/" .. file,
                                    type = "Stepmania",
                                    rating = "",
                                    ratingColour = {1,1,1},
                                    audioFile = path .. "/" .. file .. "/" .. diff.audioPath
                                }
                            end
                        end 
                    end
                end
            end
        elseif lf.getInfo(path .."/" .. file).type == "file" then
            lf.mount(path .."/" .. file, "song")
            -- for all files in song/
            for _, song in ipairs(lf.getDirectoryItems("song")) do
                if song:sub(-4) == ".qua" then
                    local fileData = lf.read("song/" .. song)
                    local title = fileData:match("Title:(.-)\r?\n")
                    local difficultyName = fileData:match("DifficultyName:(.-)\r?\n")
                    local mode = fileData:match("Mode:(.-)\r?\n"):gsub("^%s*(.-)%s*$", "%1")
                    local Creator = fileData:match("Creator:(.-)\r?\n")
                    local AudioFile = fileData:match("AudioFile:(.-)\r?\n"):trim()
                    local alreadyInList = false
                    for _, song in ipairs(songList) do
                        if song.title == title and song.difficultyName == difficultyName then
                            alreadyInList = true
                        end
                    end
                    if not alreadyInList then
                        songList[title] = songList[title] or {}
                        songList[title][difficultyName] = {
                            filename = file,
                            title = title,
                            difficultyName = difficultyName,
                            path = "song/" .. song,
                            folderPath = "song",
                            type = "Quaver",
                            rating = "",
                            ratingColour = {1,1,1},
                            creator = Creator,
                            mode = mode:match("%d+"),
                            audioFile = "song/" .. AudioFile
                       }
                        songList[title].type = "Quaver"
                    end
                elseif song:sub(-4) == ".osu" then
                    local fileData = lf.read("song/" .. song)
                    local title = fileData:match("Title:(.-)\r?\n")
                    local difficultyName = fileData:match("Version:(.-)\r?\n")
                    local AudioFile = fileData:match("AudioFilename:(.-)\r?\n"):trim()
                    local alreadyInList = false
                    local Mode = fileData:match("Mode:(.-)\r?\n"):trim()
                    -- needs to be 3, else FUCK YOU!
                    if Mode ~= "3" then goto continue end
                    for _, song in ipairs(songList) do
                        if song.title == title and song.difficultyName == difficultyName then
                            alreadyInList = true
                        end
                    end
                    if not alreadyInList then
                        songList[title] = songList[title] or {}
                        songList[title][difficultyName] = {
                            filename = file,
                            title = title,
                            difficultyName = difficultyName,
                            path = "song/" .. song,
                            folderPath = "song",
                            type = "osu!",
                            rating = "",
                            ratingColour = {1,1,1},
                            audioFile = "song/" .. AudioFile
                        }
                        songList[title].type = "osu!"
                    end
                    ::continue::
                end
            end
            lf.unmount(path .."/" .. file)
        end
    end

    for _, song in ipairs(songList) do
        if song.title == " " then
            song.title = song.title:sub(2)
        end

        if song.title:sub(1,1):lower() == song.title:sub(1,1) then
            song.title = song.title:sub(1,1):upper() .. song.title:sub(2)
        end

        table.sort(songList, function(a, b)
            return a.title < b.title
        end)
    end
end

function playRandomSong()    
    -- get a random value with pairs
    local song = table.random(songList)
    if not song then return end
    local diff = table.random(song)

    if not diff then playRandomSong() return end
    if not diff.audioFile then playRandomSong() return end

    if diff.audioFile:startsWith("song/") then
        lf.mount("songs/" .. diff.filename, "song")
    end
    
    MenuSoundManager:stop("music")
    MenuSoundManager:removeAllSounds()
    MenuSoundManager:newSound("music", diff.audioFile, 1, true, "stream")
    MenuSoundManager:play("music")
    MenuSoundManager:setLooping("music", true)

    if diff.audioFile:startsWith("song/") then
        lf.unmount(diff.path)
    end
end

local baseSoundData = {}

function playSelectedSong(song)
    if not song or not song.children then return end
    local diff = table.random(song.children)

    if not diff then return end
    if not diff.audioFile then return end

    if diff.audioFile:startsWith("song/") then
        lf.mount("songs/" .. diff.filename, "song")
    end

    MenuSoundManager:stop("music")
    MenuSoundManager:removeAllSounds()
    --MenuSoundManager:newSound("music", diff.audioFile, 1, true, "stream")
    threadLoader.newSoundData(baseSoundData, "music", diff.audioFile)
    threadLoader.start(function()
        MenuSoundManager:newSound("music", baseSoundData.music, 1, true, "stream")
        MenuSoundManager:play("music")
        MenuSoundManager:setLooping("music", true)
    end)

    if diff.audioFile:startsWith("song/") then
        lf.unmount(diff.path)
    end
end