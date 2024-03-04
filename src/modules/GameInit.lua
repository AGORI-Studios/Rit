local GI = {}

function GI.LoadLibraries()
    Object = require("lib.class")
    Timer = require("lib.timer")
    json = require("lib.json")
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
end

function GI.LoadClasses()
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
    Popup = require("modules.Popup")
    skin = require("modules.Game.SkinHandler")
end

function GI.ClearOSModule()
    for k, v in pairs(os) do
        if k ~= "clock" and k ~= "date" and k ~= "difftime" and 
            k ~= "time" and k ~= "tmpname" and k ~= "getenv" and
            k ~= "setlocale" then
            os[k] = nil
        end
    end
end

function GI.LoadObjects()
    StrumObject = require("modules.Objects.game.StrumObject")
    HitObject = require("modules.Objects.game.HitObject")
    Playfield = require("modules.Objects.game.Playfield")

    SongButton = require("modules.Objects.menu.SongButton")
    Spectrum = require("modules.Objects.menu.Spectrum")
end

function GI.LoadParsers()
    quaverLoader = require("modules.Parsers.Quaver")
    osuLoader = require("modules.Parsers.Osu")
    smLoader = require("modules.Parsers.Stepmania")
    malodyLoader = require("modules.Parsers.Malody")
    ritLoader = require("modules.Parsers.Rit")
    cloneLoader = require("modules.Parsers.Clone")

    Parsers = {
        ["Quaver"] = quaverLoader,
        ["osu!"] = osuLoader,
        ["Stepmania"] = smLoader,
        ["Malody"] = malodyLoader,
        ["Rit"] = ritLoader,
        ["CloneHero"] = cloneLoader
    }
end

function GI.LoadDefaultFonts()
    Cache.members.font["default"] = love.graphics.newFont("assets/fonts/TT-Interphases-Pro-Trial-Light.ttf", 16)
    Cache.members.font["defaultBold"] = love.graphics.newFont("assets/fonts/TT-Interphases-Pro-Trial-Medium.ttf", 16)
    Cache.members.font["menu"] = love.graphics.newFont("assets/fonts/TT-Interphases-Pro-Trial-Light.ttf", 32)
    Cache.members.font["menuBold"] = love.graphics.newFont("assets/fonts/TT-Interphases-Pro-Trial-Medium.ttf", 22)
    Cache.members.font["menuBig"] = love.graphics.newFont("assets/fonts/TT-Interphases-Pro-Trial-Light.ttf", 64)
    Cache.members.font["menuBigBold"] = love.graphics.newFont("assets/fonts/TT-Interphases-Pro-Trial-Medium.ttf", 64)
    Cache.members.font["menuMedium"] = love.graphics.newFont("assets/fonts/TT-Interphases-Pro-Trial-Light.ttf", 48)
    Cache.members.font["menuMediumBold"] = love.graphics.newFont("assets/fonts/TT-Interphases-Pro-Trial-Medium.ttf", 48)

    -- some font functions
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
end

function GI.LoadStates()
    return {
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
end

function GI.LoadSubstates()
    return {
        game = {
            Pause = require("substates.game.Pause"),
        },
        menu = {
            Options = require("substates.menu.Options")
        }
    }
end

function GI.InitSteam()
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
        end
    end 
end

function GI.UpdateDiscord()
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

-- Love Functions
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

-- End of Love Functions

return GI