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
function tryExcept(func, except)
    local status, err = pcall(func)
    if not status then
        except(err)
    end
end

if not love.filesystem.isFused() then
    __DEBUG__ = true
else
    __DEBUG__ = false
    function print() return end -- disable print
end

function loadSongs()
    -- get all .qp files in songs/
    if not love.filesystem.getInfo("songs") then
        love.filesystem.createDirectory("songs")
        love.window.showMessageBox("Songs folder created!",
        "songs folder has been created at " .. love.filesystem.getSaveDirectory() .. "/songs", "info")
    end
    if not love.filesystem.getInfo("songs/packs") then
        love.filesystem.createDirectory("songs/packs")
    end
    if love.filesystem.getInfo("songs/quaver") or love.filesystem.getInfo("songs/osu") or love.filesystem.getInfo("songs/fnf") or
        love.filesystem.getInfo("songs/quaverExtracted") or love.filesystem.getInfo("songs/osuExtracted") then
        love.window.showMessageBox("Songs folder structure outdated!",
            "songs folder structure is outdated, please move all songs to the songs folder and delete the old folders",
            "error")
    end

    songList = {}
    packs = {}
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
                                type = "Quaver"
                            }
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
                                type = "osu!"
                            }
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
                                type = "FNF"
                            }
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
                                    type = "Quaver"
                                }
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
                                    type = "osu!"
                                }
                            end
                        end
                    end
                end
                love.filesystem.unmount("songs/" .. v)
            end
        end
    end

    -- go through all packs
    --[[
    for i, v in ipairs(love.filesystem.getDirectoryItems("packs")) do
        -- check if the file is a directory
        for k, j in ipairs(love.filesystem.getDirectoryItems("packs/" .. v)) do
            -- all packs have a pack.meta file
            -- they are formatted like this:
            --[[
                Name: TestPack
                Creator: GuglioIsStupid
                Description: This is a test pack
            if j == "pack.meta" then
                local name = love.filesystem.read("packs/" .. v .. "/" .. j):match("Name:(.-)\r?\n")
                local creator = love.filesystem.read("packs/" .. v .. "/" .. j):match("Creator:(.-)\r?\n")
                local description = love.filesystem.read("packs/" .. v .. "/" .. j):match("Description:(.-)\r?\n")
                -- add to packs
                packs[#packs + 1] = {
                    name = name or "???",
                    creator = creator or "???",
                    description = description or "???",
                    songs = {},
                    path = "packs/" .. v
                }
                print("Found pack " .. name .. " by " .. creator)

                -- go through all songs in the pack,
                -- packs ar formatted like:
                --[[
                    pack/
                        pack.meta
                        song1.qp
                        song2.osz
                        song3/
                for k, l in ipairs(love.filesystem.getDirectoryItems("packs/" .. v)) do
                    -- check if the file is a directory
                    if love.filesystem.getInfo("packs/" .. v .. "/" .. l).type == "directory" then
                        -- check if the directory has a .qua file
                        for m, n in ipairs(love.filesystem.getDirectoryItems("packs/" .. v .. "/" .. l)) do
                            if n:sub(-4) == ".qua" then
                                local title = love.filesystem.read("packs/" .. v .. "/" .. l .. "/" .. n):match("Title:(.-)\r?\n")
                                local difficultyName = love.filesystem.read("packs/" .. v .. "/" .. l .. "/" .. n):match("DifficultyName:(.-)\r?\n")
                                local BackgroundFile = love.filesystem.read("packs/" .. v .. "/" .. l .. "/" .. n):match("BackgroundFile:(.-)\r?\n")
                                -- add to packs
                                packs[#packs].songs[#packs[#packs].songs + 1] = {
                                    filename = l,
                                    title = title,
                                    difficultyName = difficultyName or "???",
                                    BackgroundFile = BackgroundFile:sub(2),
                                    path = "packs/" .. v .. "/" .. l .. "/" .. n,
                                    folderPath = "packs/" .. v .. "/" .. l,
                                    type = "Quaver",
                                }
                            elseif n:sub(-4) == ".osu" then
                                local title = love.filesystem.read("packs/" .. v .. "/" .. l .. "/" .. n):match("Title:(.-)\r?\n")
                                local difficultyName = love.filesystem.read("packs/" .. v .. "/" .. l .. "/" .. n):match("Version:(.-)\r?\n")
                                -- add to packs
                                packs[#packs].songs[#packs[#packs].songs + 1] = {
                                    filename = l,
                                    title = title,
                                    difficultyName = difficultyName or "???",
                                    path = "packs/" .. v .. "/" .. l .. "/" .. n,
                                    folderPath = "packs/" .. v .. "/" .. l,
                                    type = "osu!"
                                }
                            elseif n:sub(-5) == ".json" then
                                local title = love.filesystem.read("packs/" .. v .. "/" .. l .. "/" .. n):match('"title":"(.-)"')
                                local difficultyName = love.filesystem.read("packs/" .. v .. "/" .. l .. "/" .. n):match('"difficulty":"(.-)"')
                                local BackgroundFile = love.filesystem.read("packs/" .. v .. "/" .. l .. "/" .. n):match('"background":"(.-)"')
                                -- add to packs
                                packs[#packs].songs[#packs[#packs].songs + 1] = {
                                    filename = l,
                                    title = title or "???",
                                    difficultyName = difficultyName or "???",
                                    BackgroundFile = BackgroundFile,
                                    path = "packs/" .. v .. "/" .. l .. "/" .. n,
                                    folderPath = "packs/" .. v .. "/" .. l,
                                    type = "FNF",
                                }
                            end
                        end
                    elseif love.filesystem.getInfo("packs/" .. v .. "/" .. l).type == "file" then
                        if l:sub(-3) == ".qp" then
                            love.filesystem.mount("packs/" .. v .. "/" .. l, "qp")
                            for k, j in ipairs(love.filesystem.getDirectoryItems("qp")) do
                                if love.filesystem.getInfo("song/" .. j).type == "file" then
                                    if j:sub(-4) == ".qua" then
                                        local title = love.filesystem.read("song/" .. j):match("Title:(.-)\r?\n")
                                        local difficultyName = love.filesystem.read("song/" .. j):match("DifficultyName:(.-)\r?\n")
                                        local BackgroundFile = love.filesystem.read("song/" .. j):match("BackgroundFile:(.-)\r?\n")
                                        songList[#songList + 1] = {
                                            filename = v,
                                            title = title,
                                            difficultyName = difficultyName or "???",
                                            BackgroundFile = BackgroundFile:sub(2),
                                            path = "song/" .. j,
                                            folderPath = "qp",
                                            type = "Quaver",
                                        }
                                    end
                                end
                            end
                            love.filesystem.unmount("qp")
                        elseif l:sub(-4) == ".osz" then
                            love.filesystem.mount("packs/" .. v .. "/" .. l, "osz")
                            for k, j in ipairs(love.filesystem.getDirectoryItems("osz")) do
                                if love.filesystem.getInfo("song/" .. j).type == "file" then
                                    if j:sub(-4) == ".osu" then
                                        local title = love.filesystem.read("song/" .. j):match("Title:(.-)\r?\n")
                                        local difficultyName = love.filesystem.read("song/" .. j):match("Version:(.-)\r?\n")
                                        songList[#songList + 1] = {
                                            filename = v,
                                            title = title,
                                            difficultyName = difficultyName or "???",
                                            path = "song/" .. j,
                                            folderPath = "osz",
                                            type = "osu!"
                                        }
                                    end
                                end
                            end
                            love.filesystem.unmount("osz")
                        end
                    end
                end
            end
        end
    end
    --]]

    -- add "packs" to the song list
    songList[#songList + 1] = {
        filename = "packs",
        title = "Packs",
        difficultyName = "???",
        BackgroundFile = "None",
        path = "packs",
        folderPath = "packs",
        type = "packs"
    }

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

local desktopWidth, desktopHeight = love.window.getDesktopDimensions()
fnfMomentShiz = {
    true, false
}
songSelectScrollOffset = 0
-- love.filesystem.isFused() and
if (love.system.getOS() == "Windows" or love.system.getOS() == "OS X") then
    discordRPC = require "lib.discordRPC"
    nextPresenceUpdate = 0
end
function love.load()
    require "modules.overrides"
    require "modules.debug"
    DiffCalc = require "modules.DiffCalc"
    input = (require "lib.baton").new({
        controls = {
            -- 4K inputs

            one4 = { "axis:triggerleft+", "axis:leftx-", "axis:rightx-", "button:dpleft", "button:x", "key:d" },
            two4 = { "axis:lefty+", "axis:righty+", "button:leftshoulder", "button:dpdown", "button:a", "key:f" },
            three4 = { "axis:lefty-", "axis:righty-", "button:rightshoulder", "button:dpup", "button:y", "key:j" },
            four4 = { "axis:triggerright+", "axis:leftx+", "axis:rightx+", "button:dpright", "button:b", "key:k" },
            -- 7K inputs

            one7 = { "key:s" },
            two7 = { "key:d" },
            three7 = { "key:f" },
            four7 = { "key:space" },
            five7 = { "key:j" },
            six7 = { "key:k" },
            seven7 = { "key:l" },
            -- UI

            up = { "key:up", "button:dpup", "axis:lefty-" },
            down = { "key:down", "button:dpdown", "axis:lefty+" },
            left = { "key:left", "button:dpleft", "axis:leftx-" },
            right = { "key:right", "button:dpright", "axis:leftx+" },
            confirm = { "key:return", "button:a" },
            back = { "key:escape", "button:b" },
            pause = { "key:return", "button:start" },
            restart = { "key:r", "button:b" },
            extB = { "button:back" },
            volUp = { "button:rightshoulder" },
            volDown = { "button:leftshoulder" },
            quit = { "key:escape", "button:back" }
        },
        joystick = love.joystick.getJoysticks()[1]
    })
    graphics = require "modules.graphics"

    ini = require "lib.ini"
    xml = require "lib.xml".parse
    lume = require "lib.lume"
    json = require "lib.json"
    if discordRPC then
        discordRPC.initialize("785717724906913843", true)
    end
    settings = require "modules.settings"

    function round(num)
        return math.floor(num + 0.5)
    end

    speed = settings.settings.scrollspeed or 1
    speedLane = {}
    for i = 1, 4 do
        speedLane[i] = speed
    end
    autoplay = settings.settings.autoplay or false

    skinName = settings.settings.skin or "Circle Default"
    if love.filesystem.getInfo("skins/" .. skinName) then
        fffff = "skins/" .. skinName
    else
        fffff = "defaultskins/" .. skinName
    end
    skinJson = json.decode(love.filesystem.read(fffff .. "/skin.json"))
    skinFolder = fffff

    quaverLoader = require "parsers.quaverLoader"
    osuLoader = require "parsers.osuLoader"
    stepmaniaLoader = require "parsers.stepmaniaLoader"
    fnfLoader = require "parsers.fnfLoader"

    receptors = {}

    state = require "lib.gamestate"
    beatHandler = require "modules.beatHandler"
    -- Modchart handlers
    modifiers = require "modules.modifier"
    modscript = require "modules.modscriptAPI"

    -- Menus
    startMenu = require "states.menu.startMenu"
    settingsMenu = require "states.menu.settingsMenu"
    songSelect = require "states.menu.songMenu"
    skinSelect = require "states.menu.skinMenu"

    -- Gameplay
    game = require "states.game.play"
    resultsScreen = require "states.game.resultsScreen"

    -- Misc
    audioOffsetter = require "states.misc.audioOffset"

    push = require "lib.push"
    Timer = require "lib.timer"
    charthits = {}
    for i = 1, 4 do
        charthits[i] = {}
    end
    curSongSelected = 1
    font = love.graphics.newFont("fonts/Dosis-SemiBold.ttf", 16)
    scoreFont = love.graphics.newFont("fonts/Dosis-SemiBold.ttf", 64)
    accuracyFont = love.graphics.newFont("fonts/Dosis-SemiBold.ttf", 48)
    love.graphics.setFont(font)
    love.graphics.setDefaultFilter("nearest", "nearest")

    musicTimeDo = false
    health = 1

    love.window.setMode(settings.settings.Graphics.width, settings.settings.Graphics.height,
    { resizable = true, vsync = settings.settings.Graphics.vsync, fullscreen = settings.settings.Graphics.fullscreen })
    push.setupScreen(1920, 1080, { upscale = "normal" })

    fnfMomentSelected = 1

    if not love.filesystem.getInfo("fnf-note.blacklist") then
        love.filesystem.write("fnf-note.blacklist", "# Add the note types you want to chart generator to ignore.\n")
    end

    fnfBlacklist = {}
    for line in love.filesystem.lines("fnf-note.blacklist") do
        if line:sub(1, 1) ~= "#" then
            table.insert(fnfBlacklist, line)
        end
    end

    loadSongs()
    -- choose a random song
    song = songList[love.math.random(#songList)]
    -- get the song type
    songType = song.type
    -- get the song path
    songPath = song.path
    -- get the song folder path
    songFolderPath = song.folderPath
    songFilename = song.filename

    -- load audio
    if songType == "Quaver" then
        -- mount the qua file
        love.filesystem.mount("songs/"..songFilename, "song")
        local lines = love.filesystem.lines(songPath)
        for line in lines do
            if line:find("AudioFile:") then
                curLine = line
                audioPath = curLine:gsub("AudioFile: ", "")
                audioPath = (songFolderPath == "" and "song/" .. audioPath or folderPath .. "/" .. audioPath)
                menuMusic = love.audio.newSource(audioPath, "stream")
            elseif line:find("Bpm:") then
                curLine = line
                menuBPM = curLine:gsub("Bpm: ", "")
                menuBPM = menuBPM:gsub("%D", "")
                menuBPM = tonumber(menuBPM) or 120
            end
        end
    elseif songType == "osu!" then
        love.filesystem.mount("songs/"..songFilename, "song")
        local lines = love.filesystem.lines(songPath)
        linesIndex = 0
        for line in lines do
            linesIndex = linesIndex + 1
            if line:find("AudioFilename:") then
                curLine = line
                audioPath = curLine:gsub("AudioFilename: ", "")
                audioPath = (songFolderPath == "" and "song/" .. audioPath or folderPath .. "/" .. audioPath)
                menuMusic = love.audio.newSource(audioPath, "stream")
            elseif line:find("[TimingPoints]") then
                -- go to the next line
                curLine = lines[linesIndex + 1]
                -- get the bpm
                menuBPM = osuLoader.getBPM(curLine) or 120
            end
        end
    elseif songType == "FNF" then
        local file = json.decode(love.filesystem.read(songPath)).song
        menuBPM = file.bpm or 120
        menuMusic = love.audio.newSource(songPath .. "/Inst.ogg", "stream")
    end

    if menuMusic then
        menuMusic:setVolume(0.5)
        menuMusic:play()
        menuMusic:seek(0)
        menuMusic:setLooping(true)
    end

    menuMusicVol = { menuMusic:getVolume() }

    state.switch(startMenu)

    -- scissorScale is meant for 720p
    scissorScale = 1

    audioVol = 50
    love.audio.setVolume(audioVol / 100)
    volFade = 0

    -- Get rid of all of OS funcs except os.time
    for k, v in pairs(os) do
        if k ~= "time" and k ~= "date" then
            os[k] = nil
        end
    end
end

function love.resize(w, h)
    push.resize(w, h)

    state.resize(w, h)

    scissorScale = h / 720
end

function love.update(dt)
    Timer.update(dt)
    state.update(dt)
    if __DEBUG__ then debug.update(dt) end
    if discordRPC then
        if love.timer.getTime() or 0 > nextPresenceUpdate then
            if presence then
                discordRPC.updatePresence(presence)
            end
            nextPresenceUpdate = love.timer.getTime() + 2.0
        end
        discordRPC.runCallbacks()
    end

    if menuMusic then
        menuMusic:setVolume(menuMusicVol[1])
    end

    if input:getActiveDevice() == "joy" then
        if input:down("extB") then
            if input:pressed("volUp") then
                audioVol = audioVol + 5
            elseif input:pressed("volDown") then
                audioVol = audioVol - 5
            end

            -- apply volume
            if audioVol > 100 then audioVol = 100 end
            if audioVol < 0 then audioVol = 0 end
            if audioVol == 0 then
                love.audio.setVolume(0)
            else
                love.audio.setVolume(audioVol / 100)
            end
            volFade = 1
        end
    end

    input:update(dt)
end

function love.wheelmoved(x, y)
    state.wheelmoved(x, y)

    if love.keyboard.isDown("lalt") then
        if y > 0 then
            audioVol = audioVol + 5
        elseif y < 0 then
            audioVol = audioVol - 5
        end

        -- apply volume
        if audioVol > 100 then audioVol = 100 end
        if audioVol < 0 then audioVol = 0 end
        if audioVol == 0 then
            love.audio.setVolume(0)
        else
            love.audio.setVolume(audioVol / 100)
        end

        volFade = 1
    end
end

function love.keypressed(key)
    state.keypressed(key)

    debug.keypressed(key)

    if key == "o" then
        --[[
        if choosingSkin or choosingSong then -- currently unused
            state.switch(audioOffsetter)
        end
        --]]
    end

    --[[
    if key == "7" then
        scoring = {score=love.math.random(200000,1000000), ratingPercentLerp = love.math.randomFloat(0, 1),}
        combo=200
        state.switch(resultsScreen, scoring, {"Balls", "HARD"}, false, {{},{},{},{}}, {
            hits={{0, 100}, {20, 300}, {40,600}, {100, 1000}, {160, 20000}},
            songLength=200
        })
    end
    --]]
    if key == "f11" then
        __DEBUG__ = not __DEBUG__
    end
end

function love.textinput(text)
    state.textinput(text)
    debug.textinput(text)
end

function love.draw()
    push.start()
    state:draw()

    if volFade > 0 then
        volFade = volFade - 1 * love.timer.getDelta()
        -- draw vol slider in bottom right
        love.graphics.setColor(0, 0, 0, volFade - 0.4)
        love.graphics.rectangle("fill", 1800, 1020, 120, 60)
        love.graphics.setColor(1, 1, 1, volFade)
        -- set width based on audioVol
        love.graphics.rectangle("fill", 1800, 1020, audioVol * 1.2, 60)
        love.graphics.print(audioVol, 1820 - 2, 1030, 0, 2, 2)
        love.graphics.print(audioVol, 1820 + 2, 1030, 0, 2, 2)
        love.graphics.print(audioVol, 1820, 1030 - 2, 0, 2, 2)
        love.graphics.print(audioVol, 1820, 1030 + 2, 0, 2, 2)
        love.graphics.setColor(0, 0, 0, volFade)
        love.graphics.print(audioVol, 1820, 1030, 0, 2, 2)
        love.graphics.setColor(1, 1, 1, 1)
    end
    push.finish()

    if __DEBUG__ then debug.draw() end
end

function love.focus(f)
    state.focus(f)
end

function love.quit()
    if discordRPC then
        discordRPC.shutdown()
    end
end
