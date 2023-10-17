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
local lf = love.filesystem -- i use this a lot so i just made it a variable
songList = {}
function loadDefaultSongs()
    print("Loading default songs...")
    songList = {}
    
    if not lf.getInfo("songs") then
        lf.createDirectory("songs")
        love.window.showMessageBox("Songs folder created!",
        "songs folder has been created at " .. lf.getSaveDirectory() .. "/songs", "info")
    end
   
    --for all files in defaultSongs/
    for _, file in ipairs(lf.getDirectoryItems("defaultSongs")) do
        --print("Checking " .. file)
        if lf.getInfo("defaultSongs/" .. file).type == "directory" then
            --print("Found folder " .. file)
            for _, song in ipairs(lf.getDirectoryItems("defaultSongs/" .. file)) do
                --print("Checking " .. song)
                if lf.getInfo("defaultSongs/" .. file .. "/" .. song).type == "file" then
                    --print("Found song " .. song)
                    if song:sub(-4) == ".qua" then
                        local fileData = lf.read("defaultSongs/" .. file .. "/" .. song)
                        local title = fileData:match("Title:(.-)\r?\n")
                        local difficultyName = fileData:match("DifficultyName:(.-)\r?\n")
                        local BackgroundFile = fileData:match("BackgroundFile:(.-)\r?\n")
                        local mode = fileData:match("Mode:(.-)\r?\n"):gsub("^%s*(.-)%s*$", "%1")
                        if mode == "Keys4" then
                            local alreadyInList = false
                            for _, song in ipairs(songList) do
                                if song.title == title and song.difficultyName == difficultyName then
                                    alreadyInList = true
                                end
                            end
                            if not alreadyInList then
                                songList[#songList+1] = {
                                    filename = v,
                                    title = title,
                                    difficultyName = difficultyName,
                                    BackgroundFile = BackgroundFile,
                                    path = "defaultSongs/" .. file .. "/" .. song,
                                    folderPath = "defaultSongs/" .. file,
                                    type = "Quaver",
                                    rating = "",
                                    ratingColour = {1,1,1},
                                }
                            end
                        end
                    elseif song:sub(-4) == ".osu" then
                        local fileData = lf.read("defaultSongs/" .. file .. "/" .. song)
                        local title = fileData:match("Title:(.-)\r?\n")
                        local difficultyName = fileData:match("Version:(.-)\r?\n")
                        local BackgroundFile = fileData:match("0,0,(.-)\r?\n")
                        local alreadyInList = false
                        for _, song in ipairs(songList) do
                            if song.title == title and song.difficultyName == difficultyName then
                                alreadyInList = true
                            end
                        end
                        if not alreadyInList then
                            songList[#songList+1] = {
                                filename = v,
                                title = title,
                                difficultyName = difficultyName,
                                BackgroundFile = BackgroundFile,
                                path = "defaultSongs/" .. file .. "/" .. song,
                                folderPath = "defaultSongs/" .. file,
                                type = "osu!",
                                rating = "",
                                ratingColour = {1,1,1},
                            }
                        end
                        -- With how stupid I am, stepmania is probably going to be the last thing I add
                    --[[ elseif song:sub(-3) == ".sm" then -- for stepmania, we have to call "smLoader.getDifficulties(chart)"
                        diffs = smLoader.getDifficulties("defaultSongs/" .. file .. "/" .. song)
                        -- has a table in a table (holds name and songName)

                        for _, diff in ipairs(diffs) do
                            local alreadyInList = false
                            for _, song in ipairs(songList) do
                                if song.title == diff.songName and song.difficultyName == diff.name then
                                    alreadyInList = true
                                end
                            end

                            if not alreadyInList then
                                songList[#songList+1] = {
                                    filename = v,
                                    title = diff.songName,
                                    difficultyName = diff.name,
                                    BackgroundFile = diff.BackgroundFile,
                                    path = "defaultSongs/" .. file .. "/" .. song,
                                    folderPath = "defaultSongs/" .. file,
                                    type = "Stepmania",
                                    rating = "",
                                    ratingColour = {1,1,1},
                                }
                            end
                        end ]]
                    end
                end
            end
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
    -- calls the loader.audioFile to play the song
    
    local song = songList[love.math.random(1, #songList)]
    audioFile = nil

    if song.type == "osu!" then
        osuLoader.getSong(song.folderPath, song.path)
    elseif song.type == "Quaver" then
        quaverLoader.getSong(song.folderPath, song.path)
    end
end