
local lf = love.filesystem -- i use this a lot so i just made it a variable
songList = {}
local curPlayingSong = nil

function loadSongs(path) -- Gross yucky way of loading all of our songs in the given folder path
    print("Checking path: " .. path)
    for _, file in ipairs(lf.getDirectoryItems(path)) do
        if lf.getInfo(path .."/" .. file).type == "directory" then
            for _, song in ipairs(lf.getDirectoryItems(path .."/" .. file)) do
                --print("Checking " .. song)
                if lf.getInfo(path .."/" .. file .. "/" .. song).type == "file" then
                    -- is there a song cache? if not, cache it
                    if love.filesystem.getInfo(".cache/.songs/" .. file .. song .. ".cache") then
                        -- create a lua table from the cache (its just a serialized lua table)
                        local data = string.splitByLine(lf.read(".cache/.songs/" .. file .. song .. ".cache"))
                        local title = data[1]
                        local difficultyName = data[2]
                        local mode = data[3]
                        local Creator = data[4]
                        local AudioFile = data[5]
                        local Artist = data[6]
                        local Tags = string.split(data[7], ", ")
                        local bpm = data[8]
                        local previewTime = data[9]
                        local gamemode = data[10]
                        local mapID = data[11]
                        local nps = data[12]
                        local maptype = data[13]
                        data = {
                            title = title,
                            difficultyName = difficultyName,
                            mode = mode,
                            creator = Creator,
                            audioFile = AudioFile,
                            artist = Artist,
                            tags = Tags,
                            bpm = bpm,
                            previewTime = previewTime,
                            gamemode = gamemode,
                            mapID = mapID,
                            nps = nps,
                            type = maptype
                        }
                        -- tags is already a table in the cache

                        if nps == nil then
                            local nps = Parsers[maptype].load(path .."/" .. file .. "/" .. song, path .."/" .. file, difficultyName, true)
                            nps = nps
                            createSongCache(data, ".cache/.songs/" .. file .. song .. ".cache") -- re-cache it with the nps
                        end

                        print("Parsing default song cache file") -- THIS HAS TO BE HERE BECAUSE IT LOADS THEM TOO QUICKLY GRAHHHHH
                        
                        songList[title..mapID] = songList[title..mapID] or {}
                        songList[title..mapID][difficultyName] = {
                            filename = file,
                            title = title,
                            difficultyName = difficultyName,
                            path = path .."/" .. file .. "/" .. song,
                            folderPath = path .."/" .. file,
                            type = maptype,
                            nps = nps or 0,
                            creator = Creator,
                            artist = Artist,
                            tags = Tags,
                            mode = mode,
                            bpm = bpm,
                            previewTime = previewTime,
                            audioFile = AudioFile,
                            gameMode = gamemode,
                            eventsFile = data.eventsFile -- will just be nil if it doesn't exist
                        }

                        goto __EndLoop__
                    end
                    local ext = song:gsub(".*%.", "")
                    --print("Found song " .. song)
                    if ext == "qua" then
                        local fileData = lf.read(path .."/" .. file .. "/" .. song)
                        local title = fileData:match("Title:(.-)\r?\n")
                        local difficultyName = fileData:match("DifficultyName:(.-)\r?\n")
                        local mode = fileData:match("Mode:(.-)\r?\n"):gsub("^%s*(.-)%s*$", "%1")
                        local Creator = fileData:match("Creator:(.-)\r?\n")
                        local AudioFile = fileData:match("AudioFile:(.-)\r?\n"):trim()
                        local Artist = fileData:match("Artist:(.-)\r?\n")
                        local Tags = fileData:match("Tags:(.-)\r?\n"):strip()
                        local bpm = fileData:match("Bpm: (%d+)")
                        local mapID = fileData:match("MapSetId: (%d+)")
                        ---@diagnostic disable-next-line: param-type-mismatch
                        local previewTime = (fileData:match("SongPreviewTime: (%d+)") or ""):trim()
                        if previewTime == "" then
                            ---@diagnostic disable-next-line: cast-local-type
                            previewTime = 0
                        end

                        Tags = Tags:split(" ")

                        local nps = Parsers["Quaver"].load(path .."/" .. file .. "/" .. song, path .."/" .. file, difficultyName, true)

                        songList[title..mapID] = songList[title..mapID] or {}
                        songList[title..mapID][difficultyName] = {
                            filename = file,
                            title = title,
                            difficultyName = difficultyName,
                            path = path .."/" .. file .. "/" .. song,
                            folderPath = path .."/" .. file,
                            type = "Quaver",
                            nps = nps or 0,
                            creator = Creator,
                            artist = Artist,
                            tags = Tags,
                            mode = mode:match("%d+"),
                            bpm = bpm,
                            previewTime = tonumber(previewTime or 0),
                            audioFile = path .."/" .. file .. "/" .. AudioFile,
                            gameMode = 1,
                            mapID = mapID
                        }
                        songList[title..mapID].type = "Quaver"

                        createSongCache(songList[title..mapID][difficultyName], ".cache/.songs/" .. file .. song .. ".cache")
                    elseif ext == "osu" then
                        local fileData = lf.read(path .."/" .. file .. "/" .. song)
                        local title = fileData:match("Title:(.-)\r?\n")
                        local difficultyName = fileData:match("Version:(.-)\r?\n")
                        local AudioFile = fileData:match("AudioFilename:(.-)\r?\n"):trim()
                        local Creator = fileData:match("Creator:(.-)\r?\n")
                        local Artist = fileData:match("Artist:(.-)\r?\n")
                        local Tags = fileData:match("Tags:(.-)\r?\n"):strip()
                        local previewTime = fileData:match("PreviewTime:(.-)\r?\n"):trim()
                        local mapID = fileData:match("BeatmapSetID:(.-)\r?\n"):trim()
                        mapID = tonumber(mapID)
                        local keys = fileData:match("CircleSize:(.-)\r?\n"):trim()
                        keys = tonumber(keys)

                        local timingPoints = fileData:match("%[TimingPoints%]\r?\n(.-)\r?\n%[HitObjects%]")
                        local bpm = 120
                        for line in timingPoints:gmatch("[^\r\n]+") do
                            local split = line:split(",")
                            local tp = {}

                            tp.offset = tonumber(split[1]) or 0 -- MS per beat
                            tp.beatLength = tonumber(split[2]) or 0
                            tp.timingSignature = math.max(0, math.min(8, tonumber(split[3]) or 4)) or 4
                            tp.sampleSetId = tonumber(split[4]) or 0
                            tp.customSampleIndex = tonumber(split[5]) or 0
                            tp.sampleVolume = tonumber(split[6]) or 0
                            tp.timingChange = tonumber(split[7]) or 1
                            tp.kiaiTimeActive = tonumber(split[8]) or 0

                            if tp.timingSignature == 0 then
                                tp.timingSignature = 4
                            end

                            if tp.beatLength >= 0 then
                                -- beat shit
                                tp.beatLength = math.abs(tp.beatLength)
                                tp.measureLength = math.abs(tp.beatLength * tp.timingSignature)
                                tp.timingChange = true
                                if tp.beatLength < 1e-3 then
                                    tp.beatLength = 1
                                end
                                if tp.measureLength < 1e-3 then
                                    tp.measureLength = 1
                                end
                            else -- slider velocity (what we care about)
                                tp.velocity = math.min(math.max(0.1, math.abs(-100 / tp.beatLength)), 10)
                            end

                            local isSV = tp.sampleVolume == 0 or tp.beatLength < 0

                            if not isSV then
                                bpm = 60000/tp.beatLength
                            end
                        end
                        Tags = Tags:split(" ")

                        local Mode = fileData:match("Mode:(.-)\r?\n"):trim()
                        if Mode ~= "3" and Mode ~= "1" then goto continue end
                        local nps = Parsers["osu!"].load(path .."/" .. file .. "/" .. song, path .."/" .. file, difficultyName, true)
                        songList[title..mapID] = songList[title..mapID] or {}
                        songList[title..mapID][difficultyName] = {
                            filename = file,
                            title = title,
                            difficultyName = difficultyName,
                            path = path .."/" .. file .. "/" .. song,
                            folderPath = path .."/" .. file,
                            type = "osu!",
                            nps = nps,
                            creator = Creator,
                            artist = Artist,
                            tags = Tags,
                            bpm = bpm,
                            previewTime = tonumber(previewTime or 0),
                            audioFile = path .."/" .. file .. "/" .. AudioFile,
                            gameMode = Mode == "3" and 1 or Mode == "1" and 2 or 1,
                            mapID = mapID,
                            mode = keys
                        }
                        songList[title..mapID].type = "osu!"

                        createSongCache(songList[title..mapID][difficultyName], ".cache/.songs/" .. file .. song .. ".cache")
                        ::continue::
                    elseif ext == "ritc" then
                        local fileData = lf.read(path .."/" .. file .. "/" .. song)
                        local title = fileData:match("SongTitle:(.-)\r?\n")
                        local difficultyName = fileData:match("SongDiff:(.-)\r?\n")
                        local AudioFile = fileData:match("AudioFile:(.-)\r?\n"):trim()
                        local Creator = fileData:match("Creator:(.-)\r?\n")
                        local Artist = fileData:match("Artist:(.-)\r?\n")
                        local description = fileData:match("Description:(.-)\r?\n")
                        local Tags = fileData:match("Tags:(.-)\r?\n"):strip()
                        local bpm = fileData:match("%[Timings%]\r?\n(.-)\r?\n%[Hits%]")
                        local previewTime = fileData:match("PreviewTime:(.-)\r?\n"):trim()
                        local mapID = tonumber(fileData:match("MapID:(%d+)\r?\n"))
                        local Mode = tonumber(fileData:match("KeyAmount:(%d+)\r?\n"))
                        bpm = bpm:split("\r?\n")
                        bpm = bpm[1]:split(":")[2]
                        Tags = Tags:split(" ")

                        local nps = Parsers["Rit"].load(path .."/" .. file .. "/" .. song, path .."/" .. file, difficultyName, true)

                        songList[title..mapID] = songList[title..mapID] or {}
                        songList[title..mapID][difficultyName] = {
                            filename = file,
                            title = title,
                            difficultyName = difficultyName,
                            path = path .."/" .. file .. "/" .. song,
                            folderPath = path .."/" .. file,
                            type = "Rit",
                            nps = nps,
                            creator = Creator,
                            artist = Artist,
                            description = description,
                            tags = Tags,
                            bpm = bpm,
                            previewTime = tonumber(previewTime or 0),
                            audioFile = path .."/" .. file .. "/" .. AudioFile,
                            gameMode = 1,
                            mapID = mapID,
                            mode = Mode
                        }
                        songList[title..mapID].type = "Rit"

                        createSongCache(songList[title..mapID][difficultyName], ".cache/.songs/" .. file .. song .. ".cache")
                    elseif ext == "mc" then
                        local fileData = json.decode(lf.read(path .."/" .. file .. "/" .. song))
                        local title = fileData.meta.song.title
                        local difficultyName = fileData.meta.version
                        local AudioFile
                        local Creator = "Unknown"
                        local Artist = "Unknown"
                        local Tags = {"malody"}
                        local previewTime = 0
                        local mapID = 1
                        for _, note in ipairs(fileData.note) do
                            if note.type == 1 then
                                AudioFile = note.sound
                            end
                        end
                        local nps = Parsers["Malody"].load(path .."/" .. file .. "/" .. song, path .."/" .. file, difficultyName, true)
                        songList[title..mapID] = songList[title..mapID] or {}
                        songList[title..mapID][difficultyName] = {
                            filename = file,
                            title = title,
                            difficultyName = difficultyName,
                            path = path .."/" .. file .. "/" .. song,
                            folderPath = path .."/" .. file,
                            type = "Malody",
                            nps = nps,
                            npsColour = {1,1,1},
                            creator = Creator,
                            artist = Artist,
                            tags = Tags,
                            bpm = 120,
                            previewTime = previewTime,
                            audioFile = path .."/" .. file .. "/" .. AudioFile,
                            gameMode = fileData.meta.mode_ext and fileData.meta.mode_ext.column or 4,
                            mapID = mapID,
                            mode = 4
                        }
                        songList[title..mapID].type = "Malody"

                        createSongCache(songList[title..mapID], "songs/" .. file .. song .. ".cache")
                    elseif ext == "fsc" then
                        local filedata = json.decode(lf.read(path .."/" .. file .. "/" .. song))
                        local title = filedata.Metadata.Title
                        local difficultyName = filedata.Metadata.Difficulty
                        local AudioFile = filedata.AudioFile
                        local Creator = filedata.Metadata.Mapper
                        local Artist = filedata.Metadata.Artist
                        local Tags = filedata.Metadata.Tags
                        local bpm = nil
                        local mapID = 1
                        for i = 1, #filedata.TimingPoints do
                            if filedata.TimingPoints[i].bpm then
                                bpm = filedata.TimingPoints[i].bpm
                                break
                            end
                        end
                        local previewTime = filedata.Metadata.PreviewTime
                        local nps = Parsers["fluXis"].load(path .."/" .. file .. "/" .. song, path .."/" .. file, difficultyName, true)
                        Tags = Tags:split(" ")
                        songList[title..mapID] = songList[title..mapID] or {}
                        songList[title..mapID][difficultyName] = {
                            filename = file,
                            title = title,
                            difficultyName = difficultyName,
                            path = path .."/" .. file .. "/" .. song,
                            folderPath = path .."/" .. file,
                            type = "fluXis",
                            nps = nps,
                            npsColour = {1,1,1},
                            creator = Creator,
                            artist = Artist,
                            tags = Tags,
                            bpm = bpm,
                            previewTime = previewTime,
                            audioFile = path .."/" .. file .. "/" .. AudioFile,
                            gameMode = 1,
                            eventsFile = song:gsub(".fsc", ".ffx"),
                            mapID = mapID,
                            mode = 4
                        }
                        songList[title..mapID].type = "fluXis"

                        createSongCache(songList[title..mapID][difficultyName], ".cache/.songs/" .. file .. song .. ".cache")
                    elseif ext == "sm" then -- for stepmania, we have to call "smLoader.getDifficulties(chart)"
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
                                songList[diff.songName..0] = songList[diff.songName] or {}
                                songList[diff.songName..0][diff.name] = {
                                    filename = file,
                                    title = diff.songName,
                                    difficultyName = diff.name,
                                    path = path .."/" .. file .. "/" .. song,
                                    folderPath = path .."/" .. file,
                                    type = "Stepmania",
                                    nps = 0,
                                    npsColour = {1, 1, 1},
                                    creator = "Unknown",
                                    artist = "Artist",
                                    tags = {"stepmania"},
                                    bpm = 120,
                                    previewTime = 0,
                                    audioFile = path .. "/" .. file .. "/" .. diff.audioPath,
                                    gameMode = 1,
                                    mapID = 0,
                                    mode = 4,
                                }

                                songList[diff.songName..0][diff.name].type = "Stepmania"
                            end
                        end
                    end
                end
                
                ::__EndLoop__::
            end
        elseif lf.getInfo(path .."/" .. file).type == "file" then
            lf.mount(path .."/" .. file, "song")
            -- for all files in song/
            for _, song in ipairs(lf.getDirectoryItems("song")) do
                if love.filesystem.getInfo(".cache/.songs/" .. file .. song .. ".cache") then
                    local data = string.splitByLine(lf.read(".cache/.songs/" .. file .. song .. ".cache"))
                    local title = data[1]
                    local difficultyName = data[2]
                    local mode = data[3]
                    local Creator = data[4]
                    local AudioFile = data[5]
                    local Artist = data[6]
                    local Tags = string.split(data[7], ", ")
                    local bpm = data[8]
                    local previewTime = data[9]
                    local gamemode = data[10]
                    local mapID = data[11]
                    local nps = data[12]
                    local maptype = data[13]
                    data = {
                        title = title,
                        difficultyName = difficultyName,
                        mode = mode,
                        creator = Creator,
                        audioFile = AudioFile,
                        artist = Artist,
                        tags = Tags,
                        bpm = bpm,
                        previewTime = previewTime,
                        gamemode = gamemode,
                        mapID = mapID,
                        nps = nps,
                        type = maptype
                    }
                    -- tags is already a table in the cache

                    print("Parsing non-default song cache files")

                    if (data.nps or 0) == 0 then
                        local nps = Parsers[data.type].load("song/" .. song, "song", difficultyName, true)
                        data.nps = nps
                        createSongCache(data, ".cache/.songs/" .. file .. song .. ".cache") -- re-cache it with the nps
                    end
                        
                    songList[title..mapID] = songList[title..mapID] or {}
                    songList[title..mapID][difficultyName] = {
                        filename = file,
                        title = title,
                        difficultyName = difficultyName,
                        path = "song/" .. song,
                        folderPath = "song",
                        type = data.type,
                        nps = data.nps or 0,
                        creator = Creator,
                        artist = Artist,
                        tags = Tags,
                        mode = mode,
                        bpm = bpm,
                        previewTime = previewTime,
                        audioFile = AudioFile,
                        gameMode = gamemode,
                        eventsFile = data.eventsFile -- will just be nil if it doesn't exist
                    }

                    goto __EndLoop__
                end

                local ext = song:gsub(".*%.", "")
                if ext == "qua" then
                    local fileData = lf.read("song/" .. song)
                    local title = fileData:match("Title:(.-)\r?\n")
                    local difficultyName = fileData:match("DifficultyName:(.-)\r?\n")
                    local mode = fileData:match("Mode:(.-)\r?\n"):gsub("^%s*(.-)%s*$", "%1")
                    local Creator = fileData:match("Creator:(.-)\r?\n")
                    local AudioFile = fileData:match("AudioFile:(.-)\r?\n"):trim()
                    local Artist = fileData:match("Artist:(.-)\r?\n")
                    local Tags = fileData:match("Tags:(.-)\r?\n"):strip()
                    local Bpm = fileData:match("Bpm: (%d+)")
                    local mapID = fileData:match("MapSetId: (%d+)")
                    ---@diagnostic disable-next-line: param-type-mismatch
                    local previewTime = (fileData:match("SongPreviewTime: (%d+)") or ""):trim()
                    if previewTime == "" then
                        ---@diagnostic disable-next-line: cast-local-type
                        previewTime = 0
                    end
                    Tags = Tags:split(" ")

                    local nps = Parsers["Quaver"].load("song/" .. song, "song", difficultyName, true)

                    songList[title..mapID] = songList[title..mapID] or {}
                    songList[title..mapID][difficultyName] = {
                        filename = file,
                        title = title,
                        difficultyName = difficultyName,
                        path = "song/" .. song,
                        folderPath = "song",
                        type = "Quaver",
                        nps = nps,
                        npsColour = {1,1,1},
                        creator = Creator,
                        artist = Artist,
                        mode = mode:match("%d+"),
                        tags = Tags,
                        bpm = Bpm,
                        previewTime = tonumber(previewTime or 0),
                        audioFile = "song/" .. AudioFile,
                        gameMode = 1,
                        mapID = mapID
                    }
                    songList[title..mapID].type = "Quaver"

                    createSongCache(songList[title..mapID][difficultyName], ".cache/.songs/" .. file .. song .. ".cache")
                elseif ext == "osu" then
                    local fileData = lf.read("song/" .. song)
                    local title = fileData:match("Title:(.-)\r?\n")
                    local difficultyName = fileData:match("Version:(.-)\r?\n")
                    local AudioFile = fileData:match("AudioFilename:(.-)\r?\n"):trim()
                    local Mode = fileData:match("Mode:(.-)\r?\n"):trim()
                    local Creator = fileData:match("Creator:(.-)\r?\n")
                    local Artist = fileData:match("Artist:(.-)\r?\n")
                    local Tags = fileData:match("Tags:(.-)\r?\n"):strip()
                    local timingPoints = fileData:match("%[TimingPoints%]\r?\n(.-)\r?\n%[HitObjects%]")
                    local bpm = 120
                    local previewTime = fileData:match("PreviewTime:(.-)\r?\n"):trim()
                    local mapID = fileData:match("BeatmapSetID:(.-)\r?\n"):trim()
                    local keys = fileData:match("CircleSize:(.-)\r?\n"):trim()
                    keys = tonumber(keys)
                    mapID = tonumber(mapID)
                    for line in timingPoints:gmatch("[^\r\n]+") do
                        local split = line:split(",")
                        local tp = {}

                        tp.offset = tonumber(split[1]) or 0 -- MS per beat
                        tp.beatLength = tonumber(split[2]) or 0
                        tp.timingSignature = math.max(0, math.min(8, tonumber(split[3]) or 4)) or 4
                        tp.sampleSetId = tonumber(split[4]) or 0
                        tp.customSampleIndex = tonumber(split[5]) or 0
                        tp.sampleVolume = tonumber(split[6]) or 0
                        tp.timingChange = tonumber(split[7]) or 1
                        tp.kiaiTimeActive = tonumber(split[8]) or 0

                        if tp.timingSignature == 0 then
                            tp.timingSignature = 4
                        end

                        if tp.beatLength >= 0 then
                            -- beat shit
                            tp.beatLength = math.abs(tp.beatLength)
                            tp.measureLength = math.abs(tp.beatLength * tp.timingSignature)
                            tp.timingChange = true
                            if tp.beatLength < 1e-3 then
                                tp.beatLength = 1
                            end
                            if tp.measureLength < 1e-3 then
                                tp.measureLength = 1
                            end
                        else -- slider velocity (what we care about)
                            tp.velocity = math.min(math.max(0.1, math.abs(-100 / tp.beatLength)), 10)
                        end

                        local isSV = tp.sampleVolume == 0 or tp.beatLength < 0

                        if not isSV then
                            bpm = 60000/tp.beatLength
                        end
                     end
                    Tags = Tags:split(" ")
                    if Mode ~= "3" and Mode ~= "1" then goto continue end

                    local nps = Parsers["osu!"].load("song/" .. song, "song", difficultyName, true)

                    songList[title..mapID] = songList[title..mapID] or {}
                    songList[title..mapID][difficultyName] = {
                        filename = file,
                        title = title,
                        difficultyName = difficultyName,
                        path = "song/" .. song,
                        folderPath = "song",
                        type = "osu!",
                        nps = nps,
                        npsColour = {1,1,1},
                        creator = Creator,
                        artist = Artist,
                        tags = Tags,
                        bpm = bpm,
                        previewTime = tonumber(previewTime or 0),
                        audioFile = "song/" .. AudioFile,
                        gameMode = Mode == "3" and 1 or Mode == "1" and 2 or 1,
                        mapID = mapID,
                        mode = keys
                    }
                    songList[title..mapID].type = "osu!"

                    createSongCache(songList[title..mapID][difficultyName], ".cache/.songs/" .. file .. song .. ".cache")
                    ::continue::
                elseif ext == "fsc" then -- fluXis
                    local filedata = json.decode(lf.read("song/" .. song))
                    local title = filedata.Metadata.Title
                    local difficultyName = filedata.Metadata.Difficulty
                    local AudioFile = filedata.AudioFile
                    local Creator = filedata.Metadata.Mapper
                    local Artist = filedata.Metadata.Artist
                    local Tags = filedata.Metadata.Tags
                    local bpm = nil
                    local mapID = 1
                    for i = 1, #filedata.TimingPoints do
                        if filedata.TimingPoints[i].bpm then
                            bpm = filedata.TimingPoints[i].bpm
                            break
                        end
                    end
                    local previewTime = filedata.Metadata.PreviewTime
                    Tags = Tags:split(" ")

                    local nps = Parsers["fluXis"].load("song/" .. song, "song", difficultyName, true)
                    songList[title..mapID] = songList[title..mapID] or {}
                    songList[title..mapID][difficultyName] = {
                        filename = file,
                        title = title,
                        difficultyName = difficultyName,
                        path = "song/" .. song,
                        folderPath = "song",
                        type = "fluXis",
                        nps = nps,
                        npsColour = {1,1,1},
                        creator = Creator,
                        artist = Artist,
                        tags = Tags,
                        bpm = bpm,
                        previewTime = previewTime,
                        audioFile = "song/" .. AudioFile,
                        gameMode = 1,
                        eventsFile = song:gsub(".fsc", ".ffx"),
                        mapID = mapID,
                        mode = 4 -- too lazy to figure out the actual key mode
                    }

                    createSongCache(songList[title..mapID][difficultyName], ".cache/.songs/" .. file .. song .. ".cache")
                end

                ::__EndLoop__::
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

function createSongCache(data, path)
    local success, message = love.filesystem.write(
    path,
    string.format([[%s
%s
%d
%s
%s
%s
%s
%d
%d
%d
%d
%d
%s]], data.title, data.difficultyName, data.mode, data.creator, 
    data.audioFile, data.artist, table.concate(data.tags, " "),
    data.bpm, data.previewTime, data.gameMode, data.mapID, data.nps, data.type
))

    return success
end

function getCurPlayingSong()
    return curPlayingSong
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
    MenuSoundManager:playFromTime("music", (diff.previewTime or 0.01)/1000)
    MenuSoundManager:setLooping("music", true)

    curPlayingSong = diff.title:strip()

    menuBPM = diff.bpm

    if diff.audioFile:startsWith("song/") then
        lf.unmount(diff.path)
    end
end

local baseSoundData = {}

local sendTo = {
    tbl = {},
    index = "Audio"
}

local curDiff = {}
local channel = love.thread.getChannel("ThreadChannels.LoadSoundData.Output")
function updateAudioThread()
    if channel:peek() then
        local soundData = channel:pop()
        MenuSoundManager:newSound("music", soundData, 1, true, "stream")
        MenuSoundManager:playFromTime("music", (curDiff.previewTime or 0) / 1000)
        MenuSoundManager:setLooping("music", true)
    end
end

function playSelectedSong(song, songName)
    if songName == (curPlayingSong or "") then return end
    curPlayingSong = songName
    if not song or not song.children then return end
    local diff = table.random(song.children)

    if not diff then return end
    if not diff.audioFile then return end

    if diff.audioFile:startsWith("song/") then
        lf.mount("songs/" .. diff.filename, "song")
    end

    MenuSoundManager:stop("music")
    MenuSoundManager:removeAllSounds()
    curDiff = diff
    ThreadModules.LoadSoundData:start(diff.audioFile)

    if diff.audioFile:startsWith("song/") then
        lf.unmount(diff.path)
    end
end

function getSongFromNameAndDiff(name, diff)
    for songName, song in pairs(songList) do
        if songName == name then
            for diffName, diffData in pairs(song) do
                if diffName == diff then
                    return diffData
                end
            end
        end
    end
end

function loadReplays()
    -- replays are in replays/
    -- file name format: Rude Buster - The $!$! Squad [Insane] - 1715357155.ritreplay
    -- song name - difficulty - timestamp.ritreplay (its just a json file)
    local replays = {}
    local returnReplays = {}
    
    for _, file in ipairs(lf.getDirectoryItems("replays")) do
        if file:sub(-10) == ".ritreplay" then
            -- file has songname - diff then
            local songName, songDiff, timestamp = file:match("(.+) %- (.+) %- (%d+).ritreplay")
            songName = songName:strip()
            songDiff = songDiff:strip()
            if songName:strip() == states.menu.SongMenu.songName:strip() and songDiff:strip() == states.menu.SongMenu.songDiff:strip() then
                local replayData = json.decode(lf.read("replays/" .. file))
                replayData.time = timestamp
                replays[#replays + 1] = replayData
            end 
        end
    end
    -- we only want the top 5 scores (replay.score.score)
    table.sort(replays, function(a, b)
        return a.score.score > b.score.score
    end)
    for i = 1, 5 do
        if replays[i] then
            table.insert(returnReplays, replays[i])
        end
    end
    return returnReplays
end

--[[ function getSongReplays()
    threads.assets.loadReplays(_G, "___REPLAYS")
    threads.assets.start(function()
        states.menu.SongMenu.replays = _G.___REPLAYS
    end)
end ]]