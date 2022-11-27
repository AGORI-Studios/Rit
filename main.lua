local desktopWidth, desktopHeight = love.window.getDesktopDimensions()
fnfMomentShiz = {
    true, false
}
function love.load()
    __VERSION__ = love.filesystem.read("version.txt")
    require "modules.loveFuncs"
    input = (require "lib.baton").new({ -- Load the input for it to work properly
        controls = {
            one4 = {'key:d', 'axis:leftx-', 'button:dpleft'},
            two4 = {'key:f', 'axis:leftx+', 'button:dpright'},
            three4 = {'key:j', 'axis:lefty-', 'button:dpup'},
            four4 = {'key:k', 'axis:lefty+', 'button:dpdown'},

            one7 = {'key:s', 'axis:leftx-', 'button:dpleft'},
            two7 = {'key:d', 'axis:leftx+', 'button:dpright'},
            three7 = {'key:f', 'axis:lefty-', 'button:dpup'},
            four7 = {'key:space'},
            five7 = {'key:j', 'axis:lefty+', 'button:dpdown'},
            six7 = {'key:k'},
            seven7 = {'key:l'},

            up = {'key:up', 'axis:lefty-', 'button:dpup'},
            down = {'key:down', 'axis:lefty+', 'button:dpdown'},
            left = {'key:left', 'axis:leftx-', 'button:dpleft'},
            right = {'key:right', 'axis:leftx+', 'button:dpright'},
            confirm = {'key:return'},
        },
        joystick = love.joystick.getJoysticks()[1]
    })
    flipY = 1 -- for downscroll

    ini = require "lib.ini"
    settingsIni = require "settings"
    settingsIni.loadSettings()

    if settings.downscroll then
        flipY = 1
    end

    scoring = {
        score = 0,
        accuracy = 0,
        ["Marvellous"] = 0,
        ["Perfect"] = 0,
        ["Great"] = 0,
        ["Good"] = 0,
        ["Miss"] = 0
    }

    songRate = 1

    function round(num)
        return math.floor(num + 0.5)
    end

    receptors = {}
    game = require "game"
    quaverLoader = require "modules.quaverLoader"
    stepmaniaLoader = require "modules.stepmaniaLoader"
    fnfLoader = require "modules.fnfLoader"

    push = require "lib.push"
    Timer = require "lib.timer"
    charthits = {}
    for i = 1, 4 do
        charthits[i] = {}
    end
    curSongSelected = 1
    font = love.graphics.newFont("fonts/Dosis-Semibold.ttf", 16)
    scoreFont = love.graphics.newFont("fonts/Dosis-Semibold.ttf", 64)
    accuracyFont = love.graphics.newFont("fonts/Dosis-Semibold.ttf", 48)
    love.graphics.setFont(font)
    love.graphics.setDefaultFilter("nearest", "nearest")

    fourkColours = {
        {255, 0, 0},
        {0, 255, 0},
        {0, 0, 255},
        {255, 255, 0}
    }
    sevenkColours = {
        {255, 0, 0},
        {0, 255, 0},
        {0, 0, 255},
        {255, 255, 0},
        {255, 0, 255},
        {0, 255, 255},
        {255, 255, 255}
    }
    musicTimeDo = false
    health = 100
    game:enter()

    love.window.setMode(settings.width, settings.height, {resizable = true, vsync = settings.vsync, fullscreen = settings.fullscreen})
    push.setupScreen(1920, 1080, {upscale = "normal"})

    choosingSkin = true
    curSkinSelected = 1
    fnfMomentSelected = 1
    chooseSkin()

end

function love.resize(w, h)
    push.resize(w, h)
end

function chooseSkin()
    -- get all folders in skin/
    if not love.filesystem.getInfo("skins") then
        love.filesystem.createDirectory("skins")
    end
    skins = {}
    for i, v in ipairs(love.filesystem.getDirectoryItems("defaultskins")) do
        if love.filesystem.getInfo("defaultskins/" .. v).type == "directory" then
            local folderPath = "defaultskins/" .. v
            -- get the skin.ini
            local skinIni = ini.load(folderPath .. "/skin.ini")
            -- get the skin name
            local skinName = skinIni["skin"]["name"]
            -- add it to the table
            curSkin = {
                name = skinName,
                folder = folderPath,
                ini = skinIni
            }
            table.insert(skins, curSkin)
        end
    end
    for i, v in ipairs(love.filesystem.getDirectoryItems("skins")) do
        if love.filesystem.getInfo("skins/" .. v).type == "directory" then
            local folderPath = "skins/" .. v
            -- get the skin.ini
            local skinIni = ini.load(folderPath .. "/skin.ini")
            -- get the skin name
            local skinName = skinIni["skin"]["name"]
            -- add it to the table
            curSkin = {
                name = skinName,
                folder = folderPath,
                ini = skinIni
            }
            table.insert(skins, curSkin)
        end
    end
end

function selectSkin(skin)
    skin = skin or 1
    skin = skins[skin]
    skinIni = skin.ini
    skinFolder = skin.folder
    skinName = skin.name
    notesize = skinIni["skin"]["notesize"]
    notesize = tonumber(notesize)
    
    hitsound = love.audio.newSource(skinFolder .. "/" .. skinIni["skin"]["hitsound"]:gsub('"', ""), "static")
    hitsound:setVolume(tonumber(skinIni["skin"]["hitsoundVolume"]))
    hitsoundCache = {
        hitsound:clone()
    }
    -- set isMultiple to a boolean
    recepterUNPRESSED1 = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["receptor1UNPRESSED"]:gsub('"', ""))
    recepterPRESSED1 = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["receptor1PRESSED"]:gsub('"', ""))

    recepterUNPRESSED2 = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["receptor2UNPRESSED"]:gsub('"', ""))
    recepterPRESSED2 = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["receptor2PRESSED"]:gsub('"', ""))

    recepterUNPRESSED3 = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["receptor3UNPRESSED"]:gsub('"', ""))
    recepterPRESSED3 = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["receptor3PRESSED"]:gsub('"', ""))

    recepterUNPRESSED4 = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["receptor4UNPRESSED"]:gsub('"', ""))
    recepterPRESSED4 = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["receptor4PRESSED"]:gsub('"', ""))

    note1NORMAL = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["note1NORMAL"]:gsub('"', ""))
    note1HOLD = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["note1HOLD"]:gsub('"', ""))
    note1END = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["note1END"]:gsub('"', ""))
    
    note2NORMAL = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["note2NORMAL"]:gsub('"', ""))
    note2HOLD = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["note2HOLD"]:gsub('"', ""))
    note2END = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["note2END"]:gsub('"', ""))

    note3NORMAL = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["note3NORMAL"]:gsub('"', ""))
    note3HOLD = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["note3HOLD"]:gsub('"', ""))
    note3END = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["note3END"]:gsub('"', ""))

    note4NORMAL = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["note4NORMAL"]:gsub('"', ""))
    note4HOLD = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["note4HOLD"]:gsub('"', ""))
    note4END = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["note4END"]:gsub('"', ""))

    receptors[1] = {love.graphics.newImage(recepterUNPRESSED1), love.graphics.newImage(recepterPRESSED1), 0}
    receptors[2] = {love.graphics.newImage(recepterUNPRESSED2), love.graphics.newImage(recepterPRESSED2), 0}
    receptors[3] = {love.graphics.newImage(recepterUNPRESSED3), love.graphics.newImage(recepterPRESSED3), 0}
    receptors[4] = {love.graphics.newImage(recepterUNPRESSED4), love.graphics.newImage(recepterPRESSED4), 0}

    noteImgs = {
        {love.graphics.newImage(note1NORMAL), love.graphics.newImage(note1HOLD), love.graphics.newImage(note1END)},
        {love.graphics.newImage(note2NORMAL), love.graphics.newImage(note2HOLD), love.graphics.newImage(note2END)},
        {love.graphics.newImage(note3NORMAL), love.graphics.newImage(note3HOLD), love.graphics.newImage(note3END)},
        {love.graphics.newImage(note4NORMAL), love.graphics.newImage(note4HOLD), love.graphics.newImage(note4END)}
    }

    judgementImages = {
        ["Miss"] = love.graphics.newImage(skinFolder .. "/" .. skinIni["skin"]["MISS"]:gsub('"', "")),
        ["Good"] = love.graphics.newImage(skinFolder .. "/" .. skinIni["skin"]["GOOD"]:gsub('"', "")),
        ["Great"] = love.graphics.newImage(skinFolder .. "/" .. skinIni["skin"]["GREAT"]:gsub('"', "")),
        ["Perfect"] = love.graphics.newImage(skinFolder .. "/" .. skinIni["skin"]["PERFECT"]:gsub('"', "")),
        ["Marvellous"] = love.graphics.newImage(skinFolder .. "/" .. skinIni["skin"]["MARVELLOUS"]:gsub('"', "")),
    }
    combo0 = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["COMBO0"]:gsub('"', ""))
    combo1 = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["COMBO1"]:gsub('"', ""))
    combo2 = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["COMBO2"]:gsub('"', ""))
    combo3 = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["COMBO3"]:gsub('"', ""))
    combo4 = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["COMBO4"]:gsub('"', ""))
    combo5 = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["COMBO5"]:gsub('"', ""))
    combo6 = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["COMBO6"]:gsub('"', ""))
    combo7 = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["COMBO7"]:gsub('"', ""))
    combo8 = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["COMBO8"]:gsub('"', ""))
    combo9 = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["COMBO9"]:gsub('"', ""))

    comboImages = {
        [1] = {
            [0] = love.graphics.newImage(combo0),
            [1] = love.graphics.newImage(combo1),
            [2] = love.graphics.newImage(combo2),
            [3] = love.graphics.newImage(combo3),
            [4] = love.graphics.newImage(combo4),
            [5] = love.graphics.newImage(combo5),
            [6] = love.graphics.newImage(combo6),
            [7] = love.graphics.newImage(combo7),
            [8] = love.graphics.newImage(combo8),
            [9] = love.graphics.newImage(combo9)
        },
        [2] = {
            [0] = love.graphics.newImage(combo0),
            [1] = love.graphics.newImage(combo1),
            [2] = love.graphics.newImage(combo2),
            [3] = love.graphics.newImage(combo3),
            [4] = love.graphics.newImage(combo4),
            [5] = love.graphics.newImage(combo5),
            [6] = love.graphics.newImage(combo6),
            [7] = love.graphics.newImage(combo7),
            [8] = love.graphics.newImage(combo8),
            [9] = love.graphics.newImage(combo9)
        },
        [3] = {
            [0] = love.graphics.newImage(combo0),
            [1] = love.graphics.newImage(combo1),
            [2] = love.graphics.newImage(combo2),
            [3] = love.graphics.newImage(combo3),
            [4] = love.graphics.newImage(combo4),
            [5] = love.graphics.newImage(combo5),
            [6] = love.graphics.newImage(combo6),
            [7] = love.graphics.newImage(combo7),
            [8] = love.graphics.newImage(combo8),
            [9] = love.graphics.newImage(combo9)
        },
        [4] = {
            [0] = love.graphics.newImage(combo0),
            [1] = love.graphics.newImage(combo1),
            [2] = love.graphics.newImage(combo2),
            [3] = love.graphics.newImage(combo3),
            [4] = love.graphics.newImage(combo4),
            [5] = love.graphics.newImage(combo5),
            [6] = love.graphics.newImage(combo6),
            [7] = love.graphics.newImage(combo7),
            [8] = love.graphics.newImage(combo8),
            [9] = love.graphics.newImage(combo9)
        }
    }
    choosingSkin = false
    choosingSong = true

    musicPos = 0
    --quaverLoader.load("chart.qua")
    chooseSongDifficulty()
    dt = 0
end

function chooseSongDifficulty()
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
                            difficultyName = difficultyName,
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
    for i, v in ipairs(love.filesystem.getDirectoryItems("songs/fnf")) do
        if love.filesystem.getInfo("songs/fnf/" .. v).type == "directory" then
            local songDir = "songs/fnf/" .. v
            for k, j in ipairs(love.filesystem.getDirectoryItems(songDir)) do
                print("3")
                print(songDir .. "/" .. j)
                if love.filesystem.getInfo(songDir .. "/" .. j).type == "file" then
                    if j:sub(-4) == "json" then
                        gsubbedFile = j:gsub(".json", "")
                        -- split from the second - (of first if there is one)
                        local difficultyName = gsubbedFile:match("-(.*)")
                        songList[#songList + 1] = {
                            filename = j,
                            title = json.decode(love.filesystem.read(songDir .. "/" .. j)).song.song,
                            difficultyName = difficultyName,
                            BackgroundFile = "None",
                            path = songDir .. "/" .. j,
                            type = "FNF"
                        }
                    end
                end
            end
        end
    end
end

function selectSongDifficulty(song, chartVer)
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
    elseif chartVer == "FNF" then
        fnfChartMoment = true
        choosingSong = false
        print("fnfChartMoment")
    end
end

function love.update(dt)
    Timer.update(dt)
    if not choosingSkin and not choosingSong and not fnfChartMoment then
        game:update(dt)
    elseif choosingSkin then
        if input:pressed("up") then
            curSkinSelected = curSkinSelected - 1
            if curSkinSelected < 1 then
                curSkinSelected = #skins
            end
        elseif input:pressed("down") then
            curSkinSelected = curSkinSelected + 1
            if curSkinSelected > #skins then
                curSkinSelected = 1
            end
        end
        if input:pressed("confirm") then
            selectSkin(curSkinSelected)
        end
    elseif choosingSong then
        if input:pressed("up") then
            curSongSelected = curSongSelected - 1
            if curSongSelected < 1 then
                curSongSelected = #songList
            end
        elseif input:pressed("down") then
            curSongSelected = curSongSelected + 1
            if curSongSelected > #songList then
                curSongSelected = 1
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
    input:update(dt)
end

function doFnfMoment(fnfMoment)
    song = songList[curSongSelected]
    filename = song.filename
    songPath = song.path
    songTitle = song.title
    songDifficultyName = song.difficultyName
    --BackgroundFile = love.graphics.newImage("song/" .. song.BackgroundFile)
    fnfLoader.load(songPath, fnfMomentShiz[fnfMomentSelected])
    choosingSong = false
    fnfChartMoment = false
end

function love.draw()
    push.start()
        if not choosingSkin and not choosingSong and not fnfChartMoment then
            game:draw()
            love.graphics.print(
                "FPS: " .. love.timer.getFPS() ..
                "\nMusic time: " .. musicTime, 
                10, 20, 0, 2, 2
            )
        elseif choosingSkin then
            for i, v in ipairs(skins) do
                if i == curSkinSelected then
                    love.graphics.setColor(1, 1, 1)
                else
                    love.graphics.setColor(0.5, 0.5, 0.5)
                end
                love.graphics.print(v.name, 0, i * 35, 0, 2, 2)
                love.graphics.setColor(1,1,1)
            end
        elseif choosingSong then
            for i, v in ipairs(songList) do
                if i == curSongSelected then
                    love.graphics.setColor(1, 1, 1)
                else
                    love.graphics.setColor(0.5, 0.5, 0.5)
                end
                love.graphics.print(v.title .. " - " .. v.difficultyName, 0, i * 35, 0, 2, 2)
                love.graphics.setColor(1,1,1)
            end
        elseif fnfChartMoment then
            love.graphics.print("Play as player? " .. tostring(fnfMomentShiz[fnfMomentSelected]), 0, 0, 0, 2, 2)
        end
    push.finish()
end

-- test push