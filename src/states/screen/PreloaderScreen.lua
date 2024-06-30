local PreloaderScreen = state()
local doneLoading = false
local fade = {0}
local lerpedFinshed = 0

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

function PreloaderScreen:enter(last, args)
    -- Preload all non-skin textures, and load song data (Useful for when difficulty calculation is added)
    threads.assets.newImage(self, "songButton", "assets/images/ui/menu/songBtn.png")
    threads.assets.newImage(self, "statsBox", "assets/images/ui/menu/statsBox.png")
    threads.assets.newImage(self, "diffButton", "assets/images/ui/menu/diffBtn.png")
    threads.assets.newImage(self, "playBG", "assets/images/ui/menu/playBG.png")
    threads.assets.newImage(self, "barsHorizontal", "assets/images/ui/buttons/barsHorizontal.png")
    threads.assets.newImage(self, "download", "assets/images/ui/buttons/download.png")
    threads.assets.newImage(self, "import", "assets/images/ui/buttons/import.png")
    threads.assets.newImage(self, "gear", "assets/images/ui/buttons/gear.png")
    threads.assets.newImage(self, "home", "assets/images/ui/buttons/home.png")
    threads.assets.newImage(self, "searchCatTab", "assets/images/ui/menu/searchCatTab.png")
    threads.assets.newImage(self, "menuBar", "assets/images/ui/menu/menuBar.png")
    threads.assets.newImage(self, "playTab", "assets/images/ui/menu/playTab.png")

    threads.assets.newImage(self, "twitterLogo", "assets/images/ui/icons/twitter.png")
    threads.assets.newImage(self, "kofiLogo", "assets/images/ui/icons/ko-fi.png")
    threads.assets.newImage(self, "discordLogo", "assets/images/ui/icons/discord.png")

    for i = 1, 5 do
        threads.assets.newImage(self, "BGball" .. i, "assets/images/ui/menu/BGball" .. i .. ".png")
    end

    threads.assets.loadSongs(self, "songList")

    threads.assets.start(function()
        doneLoading = true
        Timer.after(0.25, function()
            fade[1] = 0
            doneLoading = false
            
            Timer.tween(1, fade, {1}, 'in-out-cubic', function() state.switch(states.menu.StartMenu) end)
        end)
    end)

    localize.loadLocale(Settings.options["General"].language)
end

function PreloaderScreen:update(dt)
    if not doneLoading then
        lerpedFinshed = math.fpsLerp(lerpedFinshed, (threads.assets.loadedCount) / threads.assets.resourceCount, 25)
    end

    rndTime = rndTime + dt
    if rndTime >= rndTimeMax and threads.assets.resourceCount == 20 then
        curRndText = rndTexts[math.random(1, #rndTexts)]
        rndTime = 0
    end
end

function PreloaderScreen:draw()
    local percent = 0
    if threads.assets.resourceCount ~= 0 then percent = (threads.assets.loadedCount) / threads.assets.resourceCount end

    if threads.assets.loadedCount == 20 then
        love.graphics.printf(localize("Parsing Maps..."), 0,Inits.GameHeight/2+300,Inits.GameWidth/2, "center", 0, 2, 2)
    elseif threads.assets.loadedCount == threads.assets.resourceCount then
        love.graphics.printf(localize("Loaded!"), 0,Inits.GameHeight/2+300,Inits.GameWidth/2, "center", 0, 2, 2)
    else
        love.graphics.printf(localize("Precaching Resources...")..(threads.assets.loadedCount).."/"..threads.assets.resourceCount.."\n"..math.floor(percent * 100).."%", 0,Inits.GameHeight/2+300,Inits.GameWidth/2, "center", 0, 2, 2)
    end
    
    if curRndText ~= "" then
        love.graphics.printf(curRndText, 0, Inits.GameHeight/2+400, Inits.GameWidth/2, "center", 0, 2, 2)
    end

    -- loading bar
    love.graphics.rectangle("fill", (Inits.GameWidth*0.05),Inits.GameWidth/2, (Inits.GameWidth*0.9) * lerpedFinshed, 50)
    love.graphics.setColor(1,1,1, lerpedFinshed)

    love.graphics.draw(ritLogo, Inits.GameWidth/2, Inits.GameHeight/2, 0, 0.5, 0.5, ritLogo:getWidth()/2, ritLogo:getHeight()/2)
    love.graphics.setColor(1,1,1,1)

    love.graphics.setColor(0, 0, 0, fade[1])
    love.graphics.rectangle("fill", 0, 0,Inits.GameWidth,Inits.GameHeight)
    love.graphics.setColor(1, 1, 1, 1)
end    

return PreloaderScreen