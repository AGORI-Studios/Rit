fade = 1
masterVolume = 50
isLoading = false
__DEBUG__ = not love.filesystem.isFused()
if not __DEBUG__ then 
    function print() end -- disable print if not in debug mode, allows for better performance
end
__InJukebox = false

require("modules.Utilities")
ffi = require("ffi")

if love.system.getOS() ~= "NX" then
    if not __DEBUG__ then
        Try(
            function()
                Steam = require("lib.sworks.main")
            end,
            function()
                Steam = nil
                print("Couldn't load Steamworks.")
            end
        )
    end
    Try(
        function()
            discordRPC = require("lib.discordRPC") -- https://github.com/pfirsich/lua-discordRPC
            discordRPC.nextPresenceUpdate = 0
        end,
        function()
            discordRPC = nil
            print("Couldn't load Discord RPC.")
        end
    )
    Try(
        function()
            https = require("https") -- https://github.com/love2d/lua-https
        end,
        function()
            https = nil
            print("Couldn't load https.")
        end
    )
    Try(
        function()
            imgui = require("lib.cimgui")
        end,
        function()
            imgui = nil
            print("Couldn't load imgui.")
        end
    )
end

Inits = require("init")
__WINDOW_WIDTH, __WINDOW_HEIGHT = Inits.__WINDOW_WIDTH, Inits.__WINDOW_HEIGHT

local winOpacity = {1}
local volume = {1}
local curVol = 1
local isClosing = false

function love.load()
    __NOTE_OBJECT_WIDTH = 0 -- Determined from the width of the noteskins note object.
    
    -- Libraries 
    Object = require("lib.class")
    Timer = require("lib.timer")
    json = require("lib.json").decode
    json_encode = require("lib.json").encode
    state = require("lib.state")
    tinyyaml = require("lib.tinyyaml")
    ini = require("lib.ini")
    clone = require("lib.clone")
    threadLoader = require("lib.loveloader")
    xml = require("lib.xml")
    require("lib.lovefs.lovefs")
    require("lib.luafft")
    if love.system.getOS() ~= "NX" then
        Video = require("lib.aqua.Video")
    end

    if imgui then
        imgui.love.Init()
    end

    -- remove all os function EXCEPT non-harmful ones
    -- don't want modscriptors to do anything bad :)
    for k, v in pairs(os) do
        if k ~= "clock" and k ~= "date" and k ~= "difftime" and 
            k ~= "time" and k ~= "tmpname" and k ~= "getenv" and
            k ~= "setlocale" then
            os[k] = nil
        end
    end

    -- Classes
    Group = require("modules.Classes.Group")
    Cache = require("modules.Classes.Cache")
    Point = require("modules.Classes.Point")
    Sprite = require("modules.Classes.Sprite")
    SoundManager = require("modules.Classes.SoundManager")
    require("modules.Game.SongHandler")
    require("modules.Game.Input")
    Modscript = require("modules.Game.Modscript")
    Settings = require("modules.Game.Settings")
    Settings.loadOptions()
    VersionChecker = require("modules.VersionChecker")
    Popup = require("modules.Popup")
    skin = require("modules.Game.SkinHandler")

    skinList = {}
    skin:loadSkins("skins")
    skin:loadSkins("defaultSkins")
    if not love.filesystem.getInfo("skins") then
        love.filesystem.createDirectory("skins")
    end

    -- Objects
    StrumObject = require("modules.Objects.game.StrumObject")
    HitObject = require("modules.Objects.game.HitObject")
    Playfield = require("modules.Objects.game.Playfield")

    SongButton = require("modules.Objects.menu.SongButton")
    Spectrum = require("modules.Objects.menu.Spectrum")

    -- Parsers
    quaverLoader = require("modules.Parsers.Quaver")
    osuLoader = require("modules.Parsers.Osu")
    smLoader = require("modules.Parsers.Stepmania")
    malodyLoader = require("modules.Parsers.Malody")
    ritLoader = require("modules.Parsers.Rit")
    cloneLoader = require("modules.Parsers.Clone")

    --Cache.members.font["default"] = love.graphics.newFont("assets/fonts/Dosis-SemiBold.ttf", 16)
    -- Load fonts
    Cache.members.font["default"] = love.graphics.newFont("assets/fonts/TT-Interphases-Pro-Trial-Light.ttf", 16)
    Cache.members.font["defaultBold"] = love.graphics.newFont("assets/fonts/TT-Interphases-Pro-Trial-Medium.ttf", 16)
    Cache.members.font["menu"] = love.graphics.newFont("assets/fonts/TT-Interphases-Pro-Trial-Light.ttf", 32)
    Cache.members.font["menuBold"] = love.graphics.newFont("assets/fonts/TT-Interphases-Pro-Trial-Medium.ttf", 22)
    Cache.members.font["menuBig"] = love.graphics.newFont("assets/fonts/TT-Interphases-Pro-Trial-Light.ttf", 64)
    Cache.members.font["menuBigBold"] = love.graphics.newFont("assets/fonts/TT-Interphases-Pro-Trial-Medium.ttf", 64)
    Cache.members.font["menuMedium"] = love.graphics.newFont("assets/fonts/TT-Interphases-Pro-Trial-Light.ttf", 48)
    Cache.members.font["menuMediumBold"] = love.graphics.newFont("assets/fonts/TT-Interphases-Pro-Trial-Medium.ttf", 48)

    function setFont(font)
        local font = font or "default"
        love.graphics.setFont(Cache.members.font[font])
    end
    function fontWidth(font, text)
        local font, text = font or "default", text or "A"
        return Cache.members.font[font]:getWidth(text)
    end
    function fontHeight(font, text)
        local font, text = font or "default", text or "A"
        return Cache.members.font[font]:getHeight(text)
    end
    
    -- States
    states = {
        game = {
            Gameplay = require("states.game.Gameplay"),
        },
        menu = {
            StartMenu = require("states.menu.StartMenu"),
            SongMenu = require("states.menu.SongMenu"),
        },
        screens = {
            PreloaderScreen = require("states.screen.PreloaderScreen"),
            SplashScreen = require("states.screen.SplashScreen"),
            MapEditorScreen = require("states.screen.MapEditorScreen"),
            Importers = {
                QuaverImportScreen = require("states.screen.Importers.QuaverImportScreen"),
                OsuImportScreen = require("states.screen.Importers.OsuImportScreen"),
            },
            Jukebox = require("states.screen.JukeboxScreen"),
        }
    }
    -- Substates
    substates = {
        game = {
            Pause = require("substates.game.Pause"),
        },
        menu = {
            Options = require("substates.menu.Options")
        }
    }

    if Steam then -- Steam initailization
        if not Steam.init() or not Steam.isRunning() then
            print("Steam is not running.")
            Steam = nil
        else
            SteamUser = Steam.getUser()
            SteamUserName = SteamUser:getName()
            local SteamUserImgSteamData, width, height = SteamUser:getAvatar("small")
            if SteamUserImgSteamData then
                SteamUserAvatarSmall = love.graphics.newImage(love.image.newImageData(width, height, "rgba8", SteamUserImgSteamData))
            end
            local SteamUserImgSteamData, width, height = SteamUser:getAvatar("large")
            if SteamUserImgSteamData then
                SteamUserAvatarLarge = love.graphics.newImage(love.image.newImageData(width, height, "rgba8", SteamUserImgSteamData))
            end
        end
    end 

    -- Parse the skin's data file
    skinData = ini.parse(love.filesystem.read(skin:format("skin.ini")))

    if discordRPC then -- Discord RPC initialization
        discordRPC.initialize("785717724906913843", true)
    end

    gameScreen = love.graphics.newCanvas(Inits.GameWidth, Inits.GameHeight)

    MenuSoundManager = SoundManager()

    -- Lastly, switch to the preloader screen to preload all of our needed assets
    state.switch(states.screens.PreloaderScreen)
end

function switchState(newState, t, middleFunc)
    local t = t or 0.3
    isLoading = true
    Timer.tween(t, _G, {fade = 0}, "linear", function()
        if middleFunc then middleFunc() end
        state.switch(newState)
        isLoading = false
        Timer.tween(t, _G, {fade = 1}, "linear")
    end)
end

function love.update(dt)
    threadLoader.update() -- update the threads for asset loading
    local dt = math.min(dt, 1/30) -- cap dt to 30fps
    Timer.update(dt)
    input:update()
    if not isLoading then state.update(dt) end
    if not __InJukebox then
        love.audio.setVolume(volume[1] * (masterVolume/100))
    end

    if isClosing then 
        love.window.setWindowOpacity(winOpacity[1]) 
    end

    if discordRPC then
        if love.timer.getTime() or 0 > discordRPC.nextPresenceUpdate then
            if discordRPC.presence then
                discordRPC.updatePresence(discordRPC.presence)
            end
            discordRPC.nextPresenceUpdate = love.timer.getTime() + 2.0
        end
        discordRPC.runCallbacks()
    end

    MenuSoundManager:update(dt)

    if imgui then
        imgui.love.Update(dt)
        imgui.NewFrame()
    end
end

function love.filedropped(file)
    
end

function love.focus(f)
    state.focus(f)

    if not f and volume then
        Timer.tween(0.5, volume, {0.25}, "linear")
    elseif f and volume then
        Timer.tween(0.5, volume, {1}, "linear")
    end
end

function love.keypressed(key)
    if imgui then
        imgui.love.KeyPressed(key)
        if imgui.love.GetWantCaptureKeyboard() then return end
    end
    state.keypressed(key)

    if __DEBUG__ then
        if key == "f7" then
            state.switch(states.screens.MapEditorScreen)
        end
    end
end

function love.resize(w,h)
    __WINDOW_WIDTH, __WINDOW_HEIGHT = w, h
    state.resize(w,h)
end

function love.wheelmoved(x, y)
    if imgui then
        imgui.love.WheelMoved(x, y)
        if imgui.love.GetWantCaptureMouse() then return end
    end
    state.wheelmoved(x, y)

    if love.keyboard.isDown("lalt") then
        masterVolume = masterVolume + y * 5
    end
    masterVolume = math.clamp(masterVolume, 0, 100)
end

function love.mousepressed(x, y, b)
    if imgui then
        imgui.love.MousePressed(b)
        if imgui.love.GetWantCaptureMouse() then return end
    end
    state.mousepressed(x, y, b)
end

function love.mousereleased(x, y, b)
    if imgui then
        imgui.love.MouseReleased(b)
        if imgui.love.GetWantCaptureMouse() then return end
    end
    state.mousereleased(x, y, b)
end

function love.textinput(t)
    if imgui then
        imgui.love.TextInput(t)
        if imgui.love.GetWantCaptureKeyboard() then return end
    end
    state.textinput(t)
end

function love.keyreleased(key)
    if imgui then
        imgui.love.KeyReleased(key)
        if imgui.love.GetWantCaptureKeyboard() then return end
    end
    state.keyreleased(key)
end

function love.mousemoved(x, y, dx, dy, istouch)
    if imgui then
        imgui.love.MouseMoved(x, y)
        if imgui.love.GetWantCaptureMouse() then return end
    end
    state.mousemoved(x, y, dx, dy, istouch)
end

-- imgui doesn't support touch, so simulate mouse
function love.touchpressed(id, x, y, dx, dy, pressure)
    
    if imgui then
        love.mouse.setPosition(x, y)
        imgui.love.MousePressed(1)
        if imgui.love.GetWantCaptureMouse() then return end
    end
    state.touchpressed(id, x, y, dx, dy, pressure)
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    if imgui then
        love.mouse.setPosition(x, y)
        imgui.love.MouseReleased(1)
        if imgui.love.GetWantCaptureMouse() then return end
    end
    state.touchreleased(id, x, y, dx, dy, pressure)
end

function love.touchmoved(id, x, y, dx, dy, pressure)
    if imgui then
        love.mouse.setPosition(x, y)
        imgui.love.MouseMoved(x, y)
        if imgui.love.GetWantCaptureMouse() then return end
    end
    state.touchmoved(id, x, y, dx, dy, pressure)
end

function toGameScreen(x, y)
    -- converts our mouse position to the game screen (canvas) with the correct ratio
    local ratio = 1
    ratio = math.min(__WINDOW_WIDTH/Inits.GameWidth, __WINDOW_HEIGHT/Inits.GameHeight)

    local x, y = x - __WINDOW_WIDTH/2, y - __WINDOW_HEIGHT/2
    x, y = x / ratio, y / ratio
    x, y = x + Inits.GameWidth/2, y + Inits.GameHeight/2

    return x, y
end

function love.draw()
    love.graphics.setCanvas({gameScreen, stencil = true})
        love.graphics.clear(0,0,0,1)
        state.draw()
    love.graphics.setCanvas()

    -- ratio
    local ratio = 1
    ratio = math.min(love.graphics.getWidth()/Inits.GameWidth, love.graphics.getHeight()/Inits.GameHeight)
    love.graphics.setColor(1,1,1,1)
    -- draw game screen with the calculated ratio and center it on the screen
    love.graphics.draw(gameScreen, love.graphics.getWidth()/2, love.graphics.getHeight()/2, 0, ratio, ratio, Inits.GameWidth/2, Inits.GameHeight/2)

    for i, spr in ipairs(Modscript.funcs.sprites) do
        if spr.drawWithoutRes then
            spr:draw()
        end
    end

    -- info
    love.graphics.print(
        "FPS: " .. love.timer.getFPS() .. "\n" ..

        -- // debug info
        (__DEBUG__ and 
        
            ("Music Time: " .. (musicTime or "N/A") .. "\n" ..
            "Draw Calls: " .. love.graphics.getStats().drawcalls .. "\n" ..
            "Memory: " .. math.floor(collectgarbage("count")) .. "KB\n" ..
            "Graphics Memory: " .. math.floor(love.graphics.getStats().texturememory/1024/1024) .. "MB\n") 

            or ""
        ) ..
        -- //
       
        "Steam: " .. (Steam and "true" or "false") .. "\n" ..
        (Steam and "Steam User: " .. SteamUserName .. "\n" or "") ..
        "Volume: " .. math.round(masterVolume, 2)
    )

    -- draw Popup.popups
    for i, popup in ipairs(Popup.popups) do
        popup:draw()
    end

    if imgui then
        imgui.Render()
        imgui.love.RenderDrawLists()
    end
end

function love.quit()
    if discordRPC then
        discordRPC.shutdown()
    end

    Settings.saveOptions()

    if not isClosing then
        isClosing = true
        Timer.tween(0.5, winOpacity, {0}, "linear", function()
            love.event.quit()
        end)
        Timer.tween(0.5, volume, {0}, "linear")
        curVol = love.audio.getVolume()
        return true
    end
end
