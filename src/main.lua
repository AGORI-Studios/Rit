fade = 1
masterVolume = 50
isLoading = false
__DEBUG__ = not love.filesystem.isFused()
if not __DEBUG__ then 
    function print() end -- disable print if not in debug mode, allows for better performance
end

local __isGit
local __isGitFile = love.filesystem.getInfo("isgit.bool")
if __isGitFile then
   -- get first line of file
    local file = love.filesystem.newFile("isgit.bool")
    file:open("r")
    __isGit = file:read()
    file:close()
    __isGit = __isGit:match("true") and true or false
else
    __isGit = false
end
print("isGit: " .. tostring(__isGit))

__InJukebox = false

require("modules.Utilities")
ffi = require("ffi")

if love.system.getOS() ~= "NX" then -- For obvious reasons, don't use c libraries on the nintendo switch.
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

local GameInit = require("modules.GameInit")

function love.load()
    __NOTE_OBJECT_WIDTH = 0 -- Determined from the width of the noteskins note object.
    
    GameInit.LoadLibraries()

    if imgui then
        imgui.love.Init()
    end

    -- remove all os function EXCEPT non-harmful ones
    -- don't want modscriptors to do anything bad :)
    GameInit.ClearOSModule()

    -- Classes
    GameInit.LoadClasses()

    -- Skins, create skins directory if it doesn't exist
    skinList = {}
    skin:loadSkins("skins")
    skin:loadSkins("defaultSkins")
    if not love.filesystem.getInfo("skins") then
        love.filesystem.createDirectory("skins")
    end

    -- Objects
    GameInit.LoadObjects()

    -- Parsers
    GameInit.LoadParsers()

    -- Load fonts
    GameInit.LoadDefaultFonts()
    
    -- States
    states = GameInit.LoadStates()

    -- Substates
    substates = GameInit.LoadSubstates()

    -- Parse the skin's data file
    skinData = ini.parse(love.filesystem.read(skin:format("skin.ini")))

    -- Initialize 3rd party applications
    GameInit.InitSteam()
    if discordRPC then -- Discord RPC initialization
        discordRPC.initialize("785717724906913843", true)
    end

    gameScreen = love.graphics.newCanvas(Inits.GameWidth, Inits.GameHeight)

    MenuSoundManager = SoundManager()

    -- Lastly, switch to the preloader screen to preload all of our needed assets

    masterVolume = Settings.options["General"].globalVolume * 100
    print("Master Volume: " .. masterVolume)
    state.switch(states.screens.PreloaderScreen)

    local CurrentDateTime = os.date("*t") -- if april first, set the boolean "doAprilFools" to true
    if CurrentDateTime.month == 4 and CurrentDateTime.day == 1 then
        doAprilFools = true
    end
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
    Timer.update(dt)
    input:update()
    if not isLoading then state.update(dt) end

    if not __InJukebox then
        love.audio.setVolume(volume[1] * (masterVolume/100))
    end

    if isClosing then 
        love.window.setWindowOpacity(winOpacity[1]) 
    end

    GameInit.UpdateDiscord()

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

    -- info
    love.graphics.print(
        "FPS: " .. love.timer.getFPS() .. "\n" ..

        -- debug info
        (__DEBUG__ and 
        
            ("Music Time: " .. (musicTime or "N/A") .. "\n" ..
            "Draw Calls: " .. love.graphics.getStats().drawcalls .. "\n" ..
            "Memory: " .. math.floor(collectgarbage("count")) .. "KB\n" ..
            "Graphics Memory: " .. math.floor(love.graphics.getStats().texturememory/1024/1024) .. "MB\n") 

            or ""
        ) ..
        --
       
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
