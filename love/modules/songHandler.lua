-- Really messy code to load all songs........
function loadSongs()
    if not love.filesystem.getInfo("songs") then
        love.filesystem.createDirectory("songs")
        love.window.showMessageBox("Songs folder created!",
        "songs folder has been created at " .. love.filesystem.getSaveDirectory() .. "/songs", "info")
    end
    if love.filesystem.getInfo("songs/quaver") or love.filesystem.getInfo("songs/osu") or love.filesystem.getInfo("songs/fnf") or
        love.filesystem.getInfo("songs/quaverExtracted") or love.filesystem.getInfo("songs/osuExtracted") then
        love.window.showMessageBox("Songs folder structure outdated!",
            "songs folder structure is outdated, please move all songs to the songs folder and delete the old folders",
            "error")
    end

    songList = {}
    -- gross song loading... i know... i'm sorry...
    for i, v in ipairs(love.filesystem.getDirectoryItems("songs")) do
        -- check if the file is a directory
        if love.filesystem.getInfo("songs/" .. v).type == "directory" and v ~= "packs" then
            -- check if it has a .qua, .osu, or .json file
            for k, j in ipairs(love.filesystem.getDirectoryItems("songs/" .. v)) do
                if love.filesystem.getInfo("songs/" .. v .. "/" .. j).type == "file" then
                    if j:sub(-4) == ".qua" then
                        local title = love.filesystem.read("songs/" .. v .. "/" .. j):match("Title:(.-)\r?\n")
                        local difficultyName = love.filesystem.read("songs/" .. v .. "/" .. j):match(
                        "DifficultyName:(.-)\r?\n")
                        local BackgroundFile = love.filesystem.read("songs/" .. v .. "/" .. j):match(
                        "BackgroundFile:(.-)\r?\n")
                        local mode = love.filesystem.read("songs/" .. v .. j):match("Mode:(.-)\r?\n"):gsub("^%s*(.-)%s*$", "%1")
                        if mode ~= "Keys7" then
                            -- if song is already in the list, don't add it again
                            local alreadyInList = false
                            for i, v in ipairs(songList) do
                                if v.title == title and v.difficultyName == difficultyName then
                                    alreadyInList = true
                                end
                            end
                            if not alreadyInList then
                                songList[#songList + 1] = {
                                    filename = v,
                                    title = title,
                                    difficultyName = difficultyName or "???",
                                    BackgroundFile = BackgroundFile or "None",
                                    path = "songs/" .. v .. "/" .. j,
                                    folderPath = "songs/" .. v,
                                    type = "Quaver",
                                    rating = "",
                                    ratingColour = {1, 1, 1}
                                }
                                songList[#songList].rating = quaverLoader.getDiff(songList[#songList].path)
                            end
                        end
                    elseif j:sub(-4) == ".osu" then
                        local title = love.filesystem.read("songs/" .. v .. "/" .. j):match("Title:(.-)\r?\n")
                        local difficultyName = love.filesystem.read("songs/" .. v .. "/" .. j):match("Version:(.-)\r?\n")
                        local alreadyInList = false
                        for i, v in ipairs(songList) do
                            if v.title == title and v.difficultyName == difficultyName then
                                alreadyInList = true
                            end
                        end
                        if not alreadyInList then
                            songList[#songList + 1] = {
                                filename = v,
                                title = title,
                                difficultyName = difficultyName or "???",
                                BackgroundFile = "None",
                                path = "songs/" .. v .. "/" .. j,
                                folderPath = "songs/" .. v,
                                type = "osu!",
                                rating = "",
                                ratingColour = {1, 1, 1}
                            }
                            songList[#songList].rating = osuLoader.getDiff(songList[#songList].path)
                            songList[#songList].ratingColour = DiffCalc.ratingColours(tonumber(songList[#songList].rating) or 0)
                        end
                    elseif j:sub(-5) == ".json" then
                        gsubbedFile = j:gsub(".json", "")
                        local title = json.decode(love.filesystem.read("songs/" .. v .. "/" .. j)).song.song
                        local difficultyName = gsubbedFile:match("-(.*)")
                        local alreadyInList = false
                        for i, v in ipairs(songList) do
                            if v.title == title and v.difficultyName == difficultyName then
                                alreadyInList = true
                            end
                        end
                        if not alreadyInList then
                            songList[#songList + 1] = {
                                filename = v,
                                title = title,
                                difficultyName = difficultyName or "???",
                                BackgroundFile = "None",
                                path = "songs/" .. v .. "/" .. j,
                                folderPath = "songs/" .. v,
                                type = "FNF",
                                rating = "",
                                ratingColour = {1, 1, 1}
                            }
                            songList[#songList].rating = fnfLoader.getDiff(songList[#songList].path)
                            songList[#songList].ratingColour = DiffCalc.ratingColours(tonumber(songList[#songList].rating) or 0)
                        end
                    end
                end
            end
        elseif love.filesystem.getInfo("songs/" .. v).type == "file" then
            -- check if it is a .qp or .osz file
            if v:sub(-3) == ".qp" then
                love.filesystem.mount("songs/" .. v, "song")
                for k, j in ipairs(love.filesystem.getDirectoryItems("song")) do
                    if love.filesystem.getInfo("song/" .. j).type == "file" then
                        if j:sub(-4) == ".qua" then
                            local title = love.filesystem.read("song/" .. j):match("Title:(.-)\r?\n")
                            local difficultyName = love.filesystem.read("song/" .. j):match("DifficultyName:(.-)\r?\n")
                            local BackgroundFile = love.filesystem.read("song/" .. j):match("BackgroundFile:(.-)\r?\n")
                            local mode = love.filesystem.read("song/" .. j):match("Mode:(.-)\r?\n"):gsub("^%s*(.-)%s*$", "%1")
                            
                            if mode ~= "Keys7" then
                                local alreadyInList = false
                                for i, v in ipairs(songList) do
                                    if v.title == title and v.difficultyName == difficultyName then
                                        alreadyInList = true
                                    end
                                end
                                if not alreadyInList then
                                    songList[#songList + 1] = {
                                        filename = v,
                                        title = title,
                                        difficultyName = difficultyName or "???",
                                        BackgroundFile = BackgroundFile or "None",
                                        path = "song/" .. j,
                                        folderPath = "",
                                        type = "Quaver",
                                        rating = "",
                                        ratingColour = {1, 1, 1}
                                    }
                                    songList[#songList].rating = quaverLoader.getDiff(songList[#songList].path)
                                    songList[#songList].ratingColour = DiffCalc.ratingColours(tonumber(songList[#songList].rating) or 0)
                                end
                            end
                        end
                    end
                end
                love.filesystem.unmount("songs/" .. v)
            elseif v:sub(-4) == ".osz" then
                love.filesystem.mount("songs/" .. v, "song")
                for k, j in ipairs(love.filesystem.getDirectoryItems("song")) do
                    if love.filesystem.getInfo("song/" .. j).type == "file" then
                        if j:sub(-4) == ".osu" then
                            local title = love.filesystem.read("song/" .. j):match("Title:(.-)\r?\n")
                            local difficultyName = love.filesystem.read("song/" .. j):match("Version:(.-)\r?\n")
                            for i, v in ipairs(songList) do
                                if v.title == title and v.difficultyName == difficultyName then
                                    alreadyInList = true
                                end
                            end
                            if not alreadyInList then
                                songList[#songList + 1] = {
                                    filename = v,
                                    title = title,
                                    difficultyName = difficultyName or "???",
                                    BackgroundFile = "None",
                                    path = "song/" .. j,
                                    folderPath = "",
                                    type = "osu!",
                                    rating = "",
                                    ratingColour = {1, 1, 1}
                                }
                                songList[#songList].rating = osuLoader.getDiff(songList[#songList].path)
                                songList[#songList].ratingColour = DiffCalc.ratingColours(tonumber(songList[#songList].rating) or 0)
                            end
                        end
                    end
                end
                love.filesystem.unmount("songs/" .. v)
            end
        end
    end

    -- go through all songs, if it starts with " " then remove it
    for i, v in ipairs(songList) do
        if v.title:sub(1, 1) == " " then
            v.title = v.title:sub(2)
        end
        -- if first letter is lowercase, then make it uppercase
        if v.title:sub(1, 1):lower() == v.title:sub(1, 1) then
            v.title = v.title:sub(1, 1):upper() .. v.title:sub(2)
        end
    end
    -- sort the song list by title a-z, if its "packs", force it to top
    table.sort(songList, function(a, b)
        if a.title == "Packs" then
            return true
        elseif b.title == "Packs" then
            return false
        else
            return a.title < b.title
        end
    end)
end

function loadDefaultSongs()
    for i, v in ipairs(love.filesystem.getDirectoryItems("defaultsongs")) do
        -- check if the file is a directory
        if love.filesystem.getInfo("defaultsongs/" .. v).type == "directory" and v ~= "packs" then
            -- check if it has a .qua, .osu, or .json file
            for k, j in ipairs(love.filesystem.getDirectoryItems("defaultsongs/" .. v)) do
                if love.filesystem.getInfo("defaultsongs/" .. v .. "/" .. j).type == "file" then
                    if j:sub(-4) == ".qua" then
                        local title = love.filesystem.read("defaultsongs/" .. v .. "/" .. j):match("Title:(.-)\r?\n")
                        local difficultyName = love.filesystem.read("defaultsongs/" .. v .. "/" .. j):match(
                        "DifficultyName:(.-)\r?\n")
                        local BackgroundFile = love.filesystem.read("defaultsongs/" .. v .. "/" .. j):match(
                        "BackgroundFile:(.-)\r?\n")
                        local mode = love.filesystem.read("defaultsongs/" .. v .. "/" .. j):match("Mode:(.-)\r?\n"):gsub("^%s*(.-)%s*$", "%1")
                        if mode ~= "Keys7" then
                            -- if song is already in the list, don't add it again
                            local alreadyInList = false
                            for i, v in ipairs(songList) do
                                if v.title == title and v.difficultyName == difficultyName then
                                    alreadyInList = true
                                end
                            end
                            if not alreadyInList then
                                songList[#songList + 1] = {
                                    filename = v,
                                    title = title,
                                    difficultyName = difficultyName or "???",
                                    BackgroundFile = BackgroundFile or "None",
                                    path = "defaultsongs/" .. v .. "/" .. j,
                                    folderPath = "defaultsongs/" .. v,
                                    type = "Quaver",
                                    rating = "",
                                    ratingColour = {1, 1, 1}
                                }
                                songList[#songList].rating = quaverLoader.getDiff(songList[#songList].path)
                            end
                        end
                    elseif j:sub(-4) == ".osu" then
                        local title = love.filesystem.read("defaultsongs/" .. v .. "/" .. j):match("Title:(.-)\r?\n")
                        local difficultyName = love.filesystem.read("defaultsongs/" .. v .. "/" .. j):match("Version:(.-)\r?\n")
                        local alreadyInList = false
                        for i, v in ipairs(songList) do
                            if v.title == title and v.difficultyName == difficultyName then
                                alreadyInList = true
                            end
                        end
                        if not alreadyInList then
                            songList[#songList + 1] = {
                                filename = v,
                                title = title,
                                difficultyName = difficultyName or "???",
                                BackgroundFile = "None",
                                path = "defaultsongs/" .. v .. "/" .. j,
                                folderPath = "defaultsongs/" .. v,
                                type = "osu!",
                                rating = "",
                                ratingColour = {1, 1, 1}
                            }
                            songList[#songList].rating = osuLoader.getDiff(songList[#songList].path)
                            songList[#songList].ratingColour = DiffCalc.ratingColours(tonumber(songList[#songList].rating) or 0)
                        end
                    elseif j:sub(-5) == ".json" then
                        gsubbedFile = j:gsub(".json", "")
                        local title = json.decode(love.filesystem.read("defaultsongs/" .. v .. "/" .. j)).song.song
                        local difficultyName = gsubbedFile:match("-(.*)")
                        local alreadyInList = false
                        for i, v in ipairs(songList) do
                            if v.title == title and v.difficultyName == difficultyName then
                                alreadyInList = true
                            end
                        end
                        if not alreadyInList then
                            songList[#songList + 1] = {
                                filename = v,
                                title = title,
                                difficultyName = difficultyName or "???",
                                BackgroundFile = "None",
                                path = "defaultsongs/" .. v .. "/" .. j,
                                folderPath = "defaultsongs/" .. v,
                                type = "FNF",
                                rating = "",
                                ratingColour = {1, 1, 1}
                            }
                            songList[#songList].rating = fnfLoader.getDiff(songList[#songList].path)
                            songList[#songList].ratingColour = DiffCalc.ratingColours(tonumber(songList[#songList].rating) or 0)
                        end
                    end
                end
            end
        end
    end

    -- go through all songs, if it starts with " " then remove it
    for i, v in ipairs(songList) do
        if v.title:sub(1, 1) == " " then
            v.title = v.title:sub(2)
        end
        -- if first letter is lowercase, then make it uppercase
        if v.title:sub(1, 1):lower() == v.title:sub(1, 1) then
            v.title = v.title:sub(1, 1):upper() .. v.title:sub(2)
        end
    end
    table.sort(songList, function(a, b)
        return a.title < b.title
    end)
end