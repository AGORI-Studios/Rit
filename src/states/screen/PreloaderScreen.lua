local PreloaderScreen = state()
local doneLoading = false
local fade = 0
local allNoteImgs = {}

function PreloaderScreen:enter()
    threadLoader.newImage(self, "logo", "assets/images/ui/menu/logo.png")
    threadLoader.newImage(self, "songButton", "assets/images/ui/menu/songBtn.png")
    threadLoader.newImage(self, "statsBox", "assets/images/ui/menu/statsBox.png")
    threadLoader.newImage(self, "diffButton", "assets/images/ui/menu/diffBtn.png")
    threadLoader.newImage(self, "BGsongList", "assets/images/ui/menu/BGsongList.png")
    threadLoader.newImage(self, "barsHorizontal", "assets/images/ui/buttons/barsHorizontal.png")
    threadLoader.newImage(self, "download", "assets/images/ui/buttons/download.png")
    threadLoader.newImage(self, "import", "assets/images/ui/buttons/import.png")
    threadLoader.newImage(self, "gear", "assets/images/ui/buttons/gear.png")
    threadLoader.newImage(self, "home", "assets/images/ui/buttons/home.png")
    threadLoader.newImage(self, "categoryOpen", "assets/images/ui/menu/catOpen.png")
    threadLoader.newImage(self, "categoryClosed", "assets/images/ui/menu/catClosed.png")
    threadLoader.newImage(self, "twitterLogo", "assets/images/ui/icons/twitter.png")
    threadLoader.newImage(self, "kofiLogo", "assets/images/ui/icons/ko-fi.png")
    threadLoader.newImage(self, "discordLogo", "assets/images/ui/icons/discord.png")

    for i = 1, 5 do
        threadLoader.newImage(self, "BGball" .. i, "assets/images/ui/menu/BGball" .. i .. ".png")
    end

    threadLoader.start(function()
        doneLoading = true
        Timer.after(1, function()
            fade = 0
            doneLoading = false
            state.switch(states.menu.StartMenu)
        end)
    end)
end

function PreloaderScreen:update(dt)
    if doneLoading then 
        -- exponential fade out
        fade = math.min(fade + dt * 1.82, 1)
    end
end

function PreloaderScreen:draw()
    local percent = 0
    if threadLoader.resourceCount ~= 0 then percent = threadLoader.loadedCount / threadLoader.resourceCount end
    love.graphics.printf(
        (not doneLoading and ("Precaching Resources..." .. threadLoader.loadedCount .. "/" .. threadLoader.resourceCount) 
            or "Loaded!") ..
        "\n"..math.floor(percent * 100).."%", 
        0,Inits.GameHeight/2-100,Inits.GameWidth/2, "center", 0, 2, 2
    )
    -- loading bar
    love.graphics.rectangle("fill", (Inits.GameWidth*0.05),Inits.GameWidth/2, (Inits.GameWidth*0.9) * percent, 50)

    -- flash
    love.graphics.setColor(0, 0, 0, fade)
    love.graphics.rectangle("fill", 0, 0,Inits.GameWidth,Inits.GameHeight)
    love.graphics.setColor(1, 1, 1, 1)
end    

return PreloaderScreen