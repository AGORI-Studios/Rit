local PreloaderScreen = state()
doneLoading = false
local fade = {0}

local ritLogo = Cache:loadImage("assets/images/ui/menu/logo.png")

local rndTexts = {
    "So... How's the weather?",
    "Loading...",
    "Yes... It's still loading...",
    "Parsing maps take forever, don't blame me.",
    "I'm not stuck, I'm just... loading.",
    "Please wait, I'm still loading.",
    "While it may seem like I'm stuck, I'm still loading.",
    "Please be patient",
    "Are you still there?",
    "Still waiting it seems...",
    "Hey, I got to thank you for not closing the game quite yet."
}

local curRndText = ""
local rndTime = 0
local rndTimeMax = 5
local finishedSongs = false

local threadChannel = love.thread.getChannel("ThreadChannels.LoadSongs.Output")
local graphicThreadChannel = love.thread.getChannel("ThreadChannels.LoadGraphic.Output")

local total = 0
local loaded = 0

function PreloaderScreen:enter(last, args)
    -- Preload all non-skin textures, and load song data (Useful for when difficulty calculation is added)

    local assets = {
        "assets/images/ui/menu/statsBox.png",
        "assets/images/ui/menu/diffBtn.png",
        "assets/images/ui/menu/playBG.png",
        "assets/images/ui/buttons/barsHorizontal.png",
        "assets/images/ui/buttons/download.png",
        "assets/images/ui/buttons/import.png",
        "assets/images/ui/buttons/gear.png",
        "assets/images/ui/buttons/home.png",
        "assets/images/ui/menu/searchCatTab.png",
        "assets/images/ui/menu/menuBar.png",
        "assets/images/ui/menu/playTab.png",
        "assets/images/ui/icons/twitter.png",
        "assets/images/ui/icons/ko-fi.png",
        "assets/images/ui/icons/discord.png"
    }
    
    for i = 1, 5 do
        table.insert(assets, "assets/images/ui/menu/BGball" .. i .. ".png")
    end

    total = 1

    ThreadModules.LoadGraphic:start(unpack(assets))
    ThreadModules.LoadSongs:start()

    localize.loadLocale(Settings.options["General"].language)
end

function PreloaderScreen:update(dt)
    rndTime = rndTime + dt
    if rndTime >= rndTimeMax and loaded == total and not finishedSongs then
        curRndText = rndTexts[math.random(1, #rndTexts)]
        rndTime = 0
    end

    if threadChannel:peek() then
        songList = threadChannel:pop()
        finishedSongs = true
    end

    if graphicThreadChannel:peek() then
        local allGraphics = graphicThreadChannel:pop()
        for _, graphic in ipairs(allGraphics) do
            Cache.members.image[graphic[1]] = love.graphics.newImage(graphic[2])
        end
        
        loaded = loaded + 1
    end

    --print() -- this literally has to be here else it doesn't ever finish???? idfk dude

    if finishedSongs and loaded == total and not doneLoading then
        doneLoading = true

        Timer.after(0.25, function()
            fade[1] = 0
            
            Timer.tween(1, fade, {1}, 'in-out-cubic', function() state.switch(states.menu.StartMenu) end)
        end)
    end
end

function PreloaderScreen:draw()
    local percent = 0
    if total ~= 0 then percent = loaded / total end

    if loaded == 1 and not finishedSongs then
        love.graphics.printf(localize("Parsing Maps..."), 0,Inits.GameHeight/2+300,Inits.GameWidth/2, "center", 0, 2, 2)
    elseif loaded == total and finishedSongs then
        love.graphics.printf(localize("Loaded!"), 0,Inits.GameHeight/2+300,Inits.GameWidth/2, "center", 0, 2, 2)
    else
        love.graphics.printf(localize("Precaching Images...")..loaded.."/"..total.."\n"..math.floor(percent * 100).."%", 0,Inits.GameHeight/2+300,Inits.GameWidth/2, "center", 0, 2, 2)
    end
    
    if curRndText ~= "" then
        love.graphics.printf(curRndText, 0, Inits.GameHeight/2+350, Inits.GameWidth/2, "center", 0, 2, 2)
    end

    -- loading bar
    love.graphics.rectangle("fill", (Inits.GameWidth*0.05),Inits.GameWidth/2, (Inits.GameWidth*0.9) * percent, 50)
    love.graphics.setColor(1,1,1, percent)

    ---@diagnostic disable-next-line: need-check-nil
    love.graphics.draw(ritLogo, Inits.GameWidth/2, Inits.GameHeight/2, 0, 0.5, 0.5, ritLogo:getWidth()/2, ritLogo:getHeight()/2)
    love.graphics.setColor(1,1,1,1)

    love.graphics.setColor(0, 0, 0, fade[1])
    love.graphics.rectangle("fill", 0, 0,Inits.GameWidth,Inits.GameHeight)
    love.graphics.setColor(1, 1, 1, 1)
end

function PreloaderScreen:exit()
    rndTime = 0
    loaded = 0
    total = 0
    finishedSongs = false
    doneLoading = false

    threadChannel = love.thread.getChannel("ThreadChannels.LoadSongs.Output")
    graphicThreadChannel = love.thread.getChannel("ThreadChannels.LoadGraphic.Output")
end

return PreloaderScreen