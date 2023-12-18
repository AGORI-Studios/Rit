fade = 1
masterVolume = 50
lerpedMasterVolume = 50
isLoading = false
__DEBUG__ = not love.filesystem.isFused()
if not __DEBUG__ then 
    function print() end -- disable print if not in debug mode, allows for better performance
end

require("modules.Utilities")
ffi = require("ffi")

Try(
    function()
        Steam = require("lib.sworks.main")
    end,
    function()
        Steam = nil
        print("Couldn't load Steamworks.")
    end
)
Try(
    function()
        discordRPC = require("lib.discordRPC")
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

__inits = require("init")
__WINDOW_WIDTH, __WINDOW_HEIGHT = __inits.__WINDOW_WIDTH, __inits.__WINDOW_HEIGHT

function love.load()
    __NOTE_OBJECT_WIDTH = 0
    -- Libraries 
    Object = require("lib.class")
    Timer = require("lib.timer")
    json = require("lib.json").decode
    state = require("lib.state")
    tinyyaml = require("lib.tinyyaml")
    ini = require("lib.ini")
    threadLoader = require("lib.loveloader")
    xml = require("lib.xml")
    lovefs = require("lib.lovefs.lovefs")

    -- Classes
    Group = require("modules.Classes.Group")
    Cache = require("modules.Classes.Cache")
    Point = require("modules.Classes.Point")
    Sprite = require("modules.Classes.Sprite")
    SoundManager = require("modules.Classes.SoundManager")
    require("modules.Game.SongHandler")
    skin = require("modules.Game.SkinHandler")
    require("modules.Game.Input")
    Modscript = require("modules.Game.Modscript")
    Settings = require("modules.Game.Settings")
    Settings.loadOptions()
    VersionChecker = require("modules.VersionChecker")

    -- Objects
    StrumObject = require("modules.Objects.game.StrumObject")
    HitObject = require("modules.Objects.game.HitObject")
    SongButton = require("modules.Objects.menu.SongButton")
    Playfield = require("modules.Objects.game.Playfield")

    -- Parsers
    quaverLoader = require("modules.Parsers.Quaver")
    osuLoader = require("modules.Parsers.Osu")
    smLoader = require("modules.Parsers.Stepmania")
    malodyLoader = require("modules.Parsers.Malody")
    ritLoader = require("modules.Parsers.Rit")

    --Cache.members.font["default"] = love.graphics.newFont("assets/fonts/Dosis-SemiBold.ttf", 16)
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
        }
    }
    substates = {
        game = {
            Pause = require("substates.game.Pause"),
        },
        menu = {
            Options = require("substates.menu.Options")
        }
    }

    if Steam then
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

    skinData = ini.parse(love.filesystem.read(skin:format("skin.ini")))

    if discordRPC then
        discordRPC.initialize("785717724906913843", true)
    end

    gameScreen = love.graphics.newCanvas(__inits.__GAME_WIDTH, __inits.__GAME_HEIGHT)

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
    threadLoader.update()
    local dt = math.min(dt, 1/30) -- cap dt to 30fps
    Timer.update(dt)
    input:update()
    if not isLoading then state.update(dt) end
    lerpedMasterVolume = math.fpsLerp(lerpedMasterVolume, masterVolume, 10, love.timer.getDelta())
    love.audio.setVolume(lerpedMasterVolume/100)

    if discordRPC then
        if love.timer.getTime() or 0 > discordRPC.nextPresenceUpdate then
            if discordRPC.presence then
                discordRPC.updatePresence(discordRPC.presence)
            end
            discordRPC.nextPresenceUpdate = love.timer.getTime() + 2.0
        end
        discordRPC.runCallbacks()
    end
end

function love.filedropped(file)
    
end

function love.keypressed(key)
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
    state.wheelmoved(x, y)

    if love.keyboard.isDown("lalt") then
        masterVolume = masterVolume + y * 5
    end
    masterVolume = math.clamp(masterVolume, 0, 100)
end

function love.mousepressed(x, y, b)
    state.mousepressed(x, y, b)
end

function toGameScreen(x, y)
    -- converts our mouse position to the game screen (canvas) with the correct ratio
    local ratio = 1
    ratio = math.min(__WINDOW_WIDTH/__inits.__GAME_WIDTH, __WINDOW_HEIGHT/__inits.__GAME_HEIGHT)
    local x, y = x - __WINDOW_WIDTH/2, y - __WINDOW_HEIGHT/2
    x, y = x / ratio, y / ratio
    x, y = x + __inits.__GAME_WIDTH/2, y + __inits.__GAME_HEIGHT/2

    return x, y
end

function love.draw()
    love.graphics.setCanvas(gameScreen)
    love.graphics.clear(0,0,0,1)
    state.draw()
    love.graphics.setCanvas()

    -- ratio
    local ratio = 1
    ratio = math.min(love.graphics.getWidth()/__inits.__GAME_WIDTH, love.graphics.getHeight()/__inits.__GAME_HEIGHT)
    love.graphics.setColor(1,1,1,1)
    -- draw game screen with the calculated ratio and center it on the screen
    love.graphics.draw(gameScreen, love.graphics.getWidth()/2, love.graphics.getHeight()/2, 0, ratio, ratio, __inits.__GAME_WIDTH/2, __inits.__GAME_HEIGHT/2)

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
        "Volume: " .. math.round(lerpedMasterVolume, 2)
    )
end
function love.quit()
    if Steam then
        Steam.shutdown()
    end
    if discordRPC then
        discordRPC.shutdown()
    end

    Settings.saveOptions()
end
