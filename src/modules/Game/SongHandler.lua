
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
                    if love.filesystem.getInfo("cache/songs/" .. file .. song .. ".cache") then
                        -- create a lua table from the cache (its just a serialized lua table)
                        local data = json.decode(lf.read("cache/songs/" .. file .. song .. ".cache"))
                        local title = data.title
                        local difficultyName = data.difficultyName
                        local mode = data.mode
                        local Creator = data.creator
                        local AudioFile = data.audioFile
                        local Artist = data.artist
                        local Tags = data.tags
                        local bpm = data.bpm
                        local previewTime = data.previewTime
                        local gamemode = data.gameMode
                        -- tags is already a table in the cache

                        if data.nps == nil then
                            local nps = Parsers[data.type].load(path .."/" .. file .. "/" .. song, path .."/" .. file, difficultyName, true)
                            data.nps = nps
                            createSongCache(data, "cache/songs/" .. file .. song .. ".cache") -- re-cache it with the nps
                        end
                        
                        songList[title..Creator] = songList[title..Creator] or {}
                        songList[title..Creator][difficultyName] = {
                            filename = file,
                            title = title,
                            difficultyName = difficultyName,
                            path = path .."/" .. file .. "/" .. song,
                            folderPath = path .."/" .. file,
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
                        ---@diagnostic disable-next-line: param-type-mismatch
                        local previewTime = (fileData:match("SongPreviewTime: (%d+)") or ""):trim()
                        if previewTime == "" then
                            ---@diagnostic disable-next-line: cast-local-type
                            previewTime = 0
                        end

                        Tags = Tags:split(" ")

                        local nps = Parsers["Quaver"].load(path .."/" .. file .. "/" .. song, path .."/" .. file, difficultyName, true)

                        songList[title..Creator] = songList[title..Creator] or {}
                        songList[title..Creator][difficultyName] = {
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
                        }
                        songList[title..Creator].type = "Quaver"

                        createSongCache(songList[title..Creator][difficultyName], "cache/songs/" .. file .. song .. ".cache")
                    elseif ext == "osu" then
                        local fileData = lf.read(path .."/" .. file .. "/" .. song)
                        local title = fileData:match("Title:(.-)\r?\n")
                        local difficultyName = fileData:match("Version:(.-)\r?\n")
                        local AudioFile = fileData:match("AudioFilename:(.-)\r?\n"):trim()
                        local Creator = fileData:match("Creator:(.-)\r?\n")
                        local Artist = fileData:match("Artist:(.-)\r?\n")
                        local Tags = fileData:match("Tags:(.-)\r?\n"):strip()
                        local previewTime = fileData:match("PreviewTime:(.-)\r?\n"):trim()
                        -- osu's bpm is really stupid so we have to calculate it ourselves
                        -- like... THIS IS THEIR BPM SYSTEM?????
                        --[[
                            [TimingPoints]
                            2133,270.002700027,4,1,0,30,1,0
                        ]]
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
                        songList[title..Creator] = songList[title..Creator] or {}
                        songList[title..Creator][difficultyName] = {
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
                            gameMode = Mode == "3" and 1 or Mode == "1" and 2 or 1
                        }
                        songList[title..Creator].type = "osu!"

                        createSongCache(songList[title..Creator][difficultyName], "cache/songs/" .. file .. song .. ".cache")
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
                        bpm = bpm:split("\r?\n")
                        bpm = bpm[1]:split(":")[2]
                        Tags = Tags:split(" ")

                        local nps = Parsers["Rit"].load(path .."/" .. file .. "/" .. song, path .."/" .. file, difficultyName, true)

                        songList[title..Creator] = songList[title..Creator] or {}
                        songList[title..Creator][difficultyName] = {
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
                            gameMode = 1
                        }
                        songList[title..Creator].type = "Rit"

                        createSongCache(songList[title..Creator][difficultyName], "cache/songs/" .. file .. song .. ".cache")
                    elseif ext == "mc" then
                        local fileData = json.decode(lf.read(path .."/" .. file .. "/" .. song))
                        local title = fileData.meta.song.title
                        local difficultyName = fileData.meta.version
                        local AudioFile
                        local Creator = "Unknown"
                        local Artist = "Unknown"
                        local Tags = {"malody"}
                        local previewTime = 0
                        for _, note in ipairs(fileData.note) do
                            if note.type == 1 then
                                AudioFile = note.sound
                            end
                        end
                        local nps = Parsers["Malody"].load(path .."/" .. file .. "/" .. song, path .."/" .. file, difficultyName, true)
                        songList[title..Creator] = songList[title..Creator] or {}
                        songList[title..Creator][difficultyName] = {
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
                            gameMode = 1,
                        }
                        songList[title..Creator].type = "Malody"

                        createSongCache(songList[title..Creator], "songs/" .. file .. song .. ".cache")
                    elseif ext == "fsc" then
                        local filedata = json.decode(lf.read(path .."/" .. file .. "/" .. song))
                        local title = filedata.Metadata.Title
                        local difficultyName = filedata.Metadata.Difficulty
                        local AudioFile = filedata.AudioFile
                        local Creator = filedata.Metadata.Mapper
                        local Artist = filedata.Metadata.Artist
                        local Tags = filedata.Metadata.Tags
                        local bpm = nil
                        for i = 1, #filedata.TimingPoints do
                            if filedata.TimingPoints[i].bpm then
                                bpm = filedata.TimingPoints[i].bpm
                                break
                            end
                        end
                        local previewTime = filedata.Metadata.PreviewTime
                        local nps = Parsers["fluXis"].load(path .."/" .. file .. "/" .. song, path .."/" .. file, difficultyName, true)
                        Tags = Tags:split(" ")
                        songList[title..Creator] = songList[title..Creator] or {}
                        songList[title..Creator][difficultyName] = {
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
                            eventsFile = song:gsub(".fsc", ".ffx")
                        }

                        createSongCache(songList[title..Creator][difficultyName], "cache/songs/" .. file .. song .. ".cache")
                    end
                end
                
                ::__EndLoop__::
            end
        elseif lf.getInfo(path .."/" .. file).type == "file" then
            lf.mount(path .."/" .. file, "song")
            -- for all files in song/
            for _, song in ipairs(lf.getDirectoryItems("song")) do
                if love.filesystem.getInfo("cache/songs/" .. file .. song .. ".cache") then
                    local data = json.decode(lf.read("cache/songs/" .. file .. song .. ".cache"))
                    local title = data.title
                    local difficultyName = data.difficultyName
                    local mode = data.mode
                    local Creator = data.creator
                    local AudioFile = data.audioFile
                    local Artist = data.artist
                    local Tags = data.tags
                    local bpm = data.bpm
                    local previewTime = data.previewTime
                    local gamemode = data.gameMode
                    -- tags is already a table in the cache

                    if (data.nps or 0) == 0 then
                        local nps = Parsers[data.type].load("song/" .. song, "song", difficultyName, true)
                        data.nps = nps
                        createSongCache(data, "cache/songs/" .. file .. song .. ".cache") -- re-cache it with the nps
                    end
                        
                    songList[title..Creator] = songList[title..Creator] or {}
                    songList[title..Creator][difficultyName] = {
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

                    print(title..Creator..difficultyName)

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
                    ---@diagnostic disable-next-line: param-type-mismatch
                    local previewTime = (fileData:match("SongPreviewTime: (%d+)") or ""):trim()
                    if previewTime == "" then
                        ---@diagnostic disable-next-line: cast-local-type
                        previewTime = 0
                    end
                    Tags = Tags:split(" ")

                    local nps = Parsers["Quaver"].load("song/" .. song, "song", difficultyName, true)

                    songList[title..Creator] = songList[title..Creator] or {}
                    songList[title..Creator][difficultyName] = {
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
                    }
                    songList[title..Creator].type = "Quaver"

                    createSongCache(songList[title..Creator][difficultyName], "cache/songs/" .. file .. song .. ".cache")
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

                    songList[title..Creator] = songList[title..Creator] or {}
                    songList[title..Creator][difficultyName] = {
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
                        gameMode = Mode == "3" and 1 or Mode == "1" and 2 or 1
                    }
                    songList[title..Creator].type = "osu!"

                    createSongCache(songList[title..Creator][difficultyName], "cache/songs/" .. file .. song .. ".cache")
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
                    for i = 1, #filedata.TimingPoints do
                        if filedata.TimingPoints[i].bpm then
                            bpm = filedata.TimingPoints[i].bpm
                            break
                        end
                    end
                    local previewTime = filedata.Metadata.PreviewTime
                    Tags = Tags:split(" ")

                    local nps = Parsers["fluXis"].load("song/" .. song, "song", difficultyName, true)
                    songList[title..Creator] = songList[title..Creator] or {}
                    songList[title..Creator][difficultyName] = {
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
                        eventsFile = song:gsub(".fsc", ".ffx")
                    }

                    createSongCache(songList[title..Creator][difficultyName], "cache/songs/" .. file .. song .. ".cache")
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
    local cache = lf.newFile(path)
    cache:open("w")
    cache:write(json.encode(data))
    cache:close()
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