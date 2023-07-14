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
spectrumDivideColours = true
function love.load()
    isMobile = love.system.getOS() == "Android" or love.system.getOS() == "iOS"
    require "modules.overrides"
    require "modules.debug"
    require "modules.songHandler"
    DiffCalc = require "modules.DiffCalc"
    input = (require "lib.baton").new({
        controls = {
            gameLeft = { "axis:triggerleft+", "axis:leftx-", "axis:rightx-", "button:dpleft", "button:x", "key:d" },
            gameDown = { "axis:lefty+", "axis:righty+", "button:leftshoulder", "button:dpdown", "button:a", "key:f" },
            gameUp = { "axis:lefty-", "axis:righty-", "button:rightshoulder", "button:dpup", "button:y", "key:j" },
            gameRight = { "axis:triggerright+", "axis:leftx+", "axis:rightx+", "button:dpright", "button:b", "key:k" },

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

    speed = settings.settings.Game["scroll speed"] or 1
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
    spectrum = require "modules.spectrum"
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
    complex = require "lib.complex"
    require "lib.luafft"
    
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
    loadDefaultSongs()
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
                audioPath = (songFolderPath == "" and "song/" .. audioPath or songFolderPath .. "/" .. audioPath)
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
                menuBPM = 120
            end
        end
    elseif songType == "FNF" then
        local file = json.decode(love.filesystem.read(songPath)).song
        menuBPM = file.bpm or 120
        menuMusic = love.audio.newSource(songFolderPath .. "/Inst.ogg", "stream")
    end

    menuMusicData = love.sound.newSoundData(songType ~= "FNF" and audioPath or songFolderPath .. "/Inst.ogg")

    songSpeed = 1
    charthits = {}
    for i = 1, 4 do
        charthits[i] = {}
    end
    bpmEvents = {}
    chartEvents = {}

    if menuMusic then
        menuMusic:setVolume(0.5)
        menuMusic:play()
        menuMusic:seek(0)
        menuMusic:setLooping(true)
    end

    menuMusicVol = { menuMusic:getVolume() }

    state.switch(settingsMenu)

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

function love.mousepressed(x, y, button)
    state.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    state.mousereleased(x, y, button)
end

function love.mousemoved(x, y, dx, dy, istouch)
    state.mousemoved(x, y, dx, dy, istouch)
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    state.touchpressed(id, x, y, dx, dy, pressure)
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    state.touchreleased(id, x, y, dx, dy, pressure)
end

function love.touchmoved(id, x, y, dx, dy, pressure)
    state.touchmoved(id, x, y, dx, dy, pressure)
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

function love.filedropped(file)
    if state.current() == songSelect then
        
    end
end

function love.wheelmoved(x, y)
    state.wheelmoved(x, y)

    if love.keyboard.isDown("lalt") then
        if y > 0 then
            settings.settings.Audio.master = settings.settings.Audio.master + 0.05
        elseif y < 0 then
            settings.settings.Audio.master = settings.settings.Audio.master - 0.05
        end

        -- apply volume
        if settings.settings.Audio.master > 1 then settings.settings.Audio.master = 1 end
        if settings.settings.Audio.master < 0 then settings.settings.Audio.master = 0 end
        if settings.settings.Audio.master == 0 then
            love.audio.setVolume(0)
        else
            love.audio.setVolume(settings.settings.Audio.master)
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
    love.graphics.setColor(1, 1, 1)
    if volFade > 0 then
        volFade = volFade - 1 * love.timer.getDelta()
        -- draw vol slider in bottom right
        love.graphics.setColor(0, 0, 0, volFade - 0.4)
        love.graphics.rectangle("fill", 1800, 1020, 120, 60)
        love.graphics.setColor(1, 1, 1, volFade)
        -- set width based on audioVol
        love.graphics.rectangle("fill", 1800, 1020, settings.settings.Audio.master*100 * 1.2, 60)
        love.graphics.print(settings.settings.Audio.master*100, 1820 - 2, 1030, 0, 2, 2)
        love.graphics.print(settings.settings.Audio.master*100, 1820 + 2, 1030, 0, 2, 2)
        love.graphics.print(settings.settings.Audio.master*100, 1820, 1030 - 2, 0, 2, 2)
        love.graphics.print(settings.settings.Audio.master*100, 1820, 1030 + 2, 0, 2, 2)
        love.graphics.setColor(0, 0, 0, volFade)
        love.graphics.print(settings.settings.Audio.master*100, 1820, 1030, 0, 2, 2)
        love.graphics.setColor(1, 1, 1, 1)
    end
    push.finish()

    if __DEBUG__ then debug.draw() end

    love.graphics.push()
        if mobileButtons then
            for i, v in pairs(mobileButtons) do
                -- for some reason, on mobile, they are offseted(??????)
                v:draw()
            end
        end
    love.graphics.pop()
end

function love.focus(f)
    state.focus(f)
end

function love.quit()
    if discordRPC then
        discordRPC.shutdown()
    end

    settings.saveSettings()
end
