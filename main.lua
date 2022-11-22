function love.load()
    input = (require "baton").new({ -- Load the input for it to work properly
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
            confirm = {'key:return'},
        },
        joystick = love.joystick.getJoysticks()[1]
    })

    receptors = {}
    game = require "game"
    quaverLoader = require "quaverLoader"
    stepmaniaLoader = require "stepmaniaLoader"

    ini = require "lib.ini"
    charthits = {}
    for i = 1, 4 do
        charthits[i] = {}
    end
    curSongSelected = 1
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
    game:enter()

    love.window.setMode(1280, 720, {resizable = false, vsync = false})

    --quaverLoader.load("chart.qua")

    choosingSkin = true
    curSkinSelected = 1
    chooseSkin()
    PARTWHERERECEPTORSARE = 100
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
    recepterUNPRESSED = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["receptorUNPRESSED"]:gsub('"', ""))
    recepterPRESSED = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["receptorPRESSED"]:gsub('"', ""))
    noteNORMAL = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["noteNORMAL"]:gsub('"', ""))
    noteHOLD = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["noteHOLD"]:gsub('"', ""))
    noteEND = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["noteEND"]:gsub('"', ""))
    choosingSkin = false
    choosingSong = true

    for i = 1, 4 do
        receptors[i] = {love.graphics.newImage(recepterUNPRESSED), love.graphics.newImage(recepterPRESSED)}
    end

    musicPos = 0
    --quaverLoader.load("chart.qua")
    chooseSongDifficulty()
    dt = 0
end

function chooseSongDifficulty()
    -- get all .qp files in songs/
    if not love.filesystem.getInfo("songs") then
        love.filesystem.createDirectory("songs")
    end
    songList = {}
    for i, v in ipairs(love.filesystem.getDirectoryItems("songs")) do
        if love.filesystem.getInfo("songs/" .. v).type == "file" then
            love.filesystem.mount("songs/" .. v, "song")
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
                        songList[#songList + 1] = {
                            filename = v,
                            title = title,
                            difficultyName = difficultyName,
                            path = "song/" .. j
                        }
                    end
                end
            end
            love.filesystem.unmount("songs/"..v)
        end
    end
end

function selectSongDifficulty(song)
    song = songList[curSongSelected]
    filename = song.filename
    print(filename)
    love.filesystem.mount("songs/"..filename, "song")
    songPath = song.path
    songTitle = song.title
    songDifficultyName = song.difficultyName
    print(songPath)
    quaverLoader.load(songPath)
    choosingSong = false
end

function love.update(dt)
    if not choosingSkin and not choosingSong then
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
            selectSongDifficulty(curSongSelected)
        end
    end
    input:update(dt)
end

function love.draw()
    if not choosingSkin and not choosingSong then
        game:draw()
        love.graphics.print(
            "FPS: " .. love.timer.getFPS() ..
            "\nMusic time: " .. musicTime, 
            10, 10
        )
    elseif choosingSkin then
        for i, v in ipairs(skins) do
            if i == curSkinSelected then
                love.graphics.setColor(1, 1, 1)
            else
                love.graphics.setColor(0.5, 0.5, 0.5)
            end
            love.graphics.print(v.name, 0, i * 20)
            love.graphics.setColor(1,1,1)
        end
    elseif choosingSong then
        for i, v in ipairs(songList) do
            if i == curSongSelected then
                love.graphics.setColor(1, 1, 1)
            else
                love.graphics.setColor(0.5, 0.5, 0.5)
            end
            love.graphics.print(v.title .. " - " .. v.difficultyName, 0, i * 20)
            love.graphics.setColor(1,1,1)
        end
    end
end

-- test push