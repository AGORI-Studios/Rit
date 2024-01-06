local StartMenu = state()
local beat, time = 0, 0
local time2 = 0
local menuBPM = 120

local timers = {
    buttons = {}
}

local soundData

local balls, bg, logo, twitterLogo, kofiLogo, discordLogo
local equalizer

local curMenu = 1
local curLogoScale = {2.25}
local logoScale = {2, 2}
local logoPos = {0, 0}

local curHover = 0 -- none
local doingTransition, didTransition = false, false

local buttons = {
    {
        text = "Play",
        action = function()
            state.switch(states.menu.SongMenu)
        end,
        x = 0,
        y = 0
    },
    {
        text = "Jukebox",
        action = function()
            love.window.showMessageBox("Jukebox - Coming Soon", "The Jukebox is currently in development. Please check back later!", "info")
        end,
        x = 0,
        y = 0
    },
    {
        text = "Options",
        action = function()
            state.substate(substates.menu.Options)
        end,
        x = 0,
        y = 0
    },
    {
        text = "Quit",
        action = function()
            love.event.quit()
        end,
        x = 0,
        y = 0
    }

}

local function enterFunc()
    doingTransition = true
    didTransition = true

    curMenu = 2
    Timer.tween(
        0.5, curLogoScale, 
        {
            1.85
        },
        "in-out-cubic"
    )
    Timer.tween(
        0.5, logoPos,
        {
            [1] = -1250,
            [2] = -450
        },
        "in-out-cubic"
    )
    for i = 1, #buttons do
        timers.buttons["_" .. i] = Timer.tween(
            1 * (i / 6),
            buttons[i],
            {
                x = __inits.__GAME_WIDTH - 400
            },
            "out-quad",
            function()
                timers.buttons["_" .. i] = nil
            end
        )
    end

    -- tween the logos to the left
    Timer.tween(
        0.5, twitterLogo,
        {
            x = 155
        },
        "in-out-cubic"
    )
    Timer.tween(
        0.5, kofiLogo,
        {
            x = 25
        },
        "in-out-cubic"
    )
    Timer.tween(
        0.5, discordLogo,
        {
            x = 25
        },
        "in-out-cubic"
    )
    Timer.after(1 * (#buttons / 6), function()
        doingTransition = false
    end)
end 

function StartMenu:enter()
    balls = {}
    bg = Sprite(0, 0, "assets/images/ui/menu/BGsongList.png")
    for i = 1, 5 do
        balls[i] = Sprite(love.math.random(0, 1600), love.math.random(0, 720), "assets/images/ui/menu/BGball" .. i .. ".png")
        balls[i].ogX, balls[i].ogY = love.math.random(0, 1920), love.math.random(0, 1080)
    end
    --logo = Image("assets/images/ui/menu/logo.png")
    logo = Sprite(0, 0, "assets/images/ui/menu/logo.png")
    logo:centerOrigin()
    logo.scale = Point(2.25, 2.25)

    twitterLogo = Sprite(1780, 950, "assets/images/ui/icons/twitter.png")
    kofiLogo = Sprite(1780, 825, "assets/images/ui/icons/ko-fi.png")
    discordLogo = Sprite(1650, 950, "assets/images/ui/icons/discord.png")

    twitterLogo:setScale(0.25)
    kofiLogo:setScale(0.25)
    discordLogo:setScale(0.25)

    logo.alignment = "center"

    logo.y =__inits.__GAME_HEIGHT / 0.9
    logo.x =__inits.__GAME_WIDTH / 1
    
    if discordRPC then
        discordRPC.presence = {
            details = "In the menu",
            state = "",
            largeImageKey = "totallyreallogo",
            largeImageText = "Rit" .. (__DEBUG__ and " DEBUG MODE" or "")
        }
    end

    loadSongs("defaultSongs")
    loadSongs("songs")
    if not MenuSoundManager:exists("music") then playRandomSong() end

    if MenuSoundManager:exists("music") then
        soundData = MenuSoundManager:getSoundData("music")

        -- equalizer that draws on top of the screen
        equalizer = Spectrum(soundData)
    end

    -- setup button pos (right align) offscreen in curMenu 1
    local buttonWidth = 400
    local buttonHeight = 100
    local buttonSpacing = 50
    buttonStartX = __inits.__GAME_WIDTH + buttonWidth
    local buttonStartY = __inits.__GAME_HEIGHT / 2 - ((buttonHeight + buttonSpacing) * #buttons) / 2
    
    for i = 1, #buttons do
        buttons[i].x = buttonStartX
        buttons[i].y = buttonStartY + (buttonHeight + buttonSpacing) * (i - 1)
    end
end

function StartMenu:update(dt)
    time = time + 1000 * dt
    time2 = time2 + 1000 * dt

    if time > (60/menuBPM) * 1000 then
        local curBeat = math.floor((time2/1000) / (60/menuBPM))
        if curBeat % 2 == 0 then
            logoScale[1], logoScale[2] = curLogoScale[1] + 0.1, curLogoScale[1] + 0.1
            logo:setScale(logoScale[1], logoScale[1])
        end
        time = 0
    end

    local mx, my = love.mouse.getPosition()

    -- Logo parallax
    local px, py = (-mx / 50), (-my / 50)
    logo.x = logoPos[1] + __inits.__GAME_WIDTH / 0.9 + px
    logo.y = logoPos[2] + __inits.__GAME_HEIGHT + py

    bg.x, bg.y = px * 0.025, py * 0.025

    for i = 1, #balls do
        balls[i].x = balls[i].ogX + px * 0.09 + (0.05 * i * 5)
        balls[i].y = balls[i].ogY + py * 0.09 + (0.05 * i * 5)
    end

    if logoScale[1] > curLogoScale[1] then
        logoScale[1] = math.fpsLerp(logoScale[1], curLogoScale[1], 5, dt)
        logoScale[2] = math.fpsLerp(logoScale[2], curLogoScale[1], 5, dt)
        logo:setScale(logoScale[1], logoScale[2])
    end
    if input:pressed("confirm") and curMenu == 1 then
        enterFunc()
    elseif input:pressed("confirm") and curMenu == 2 then
        if curHover ~= 0 then
            buttons[curHover].action()
        end
    end

    if equalizer and MenuSoundManager:getChannel("music") then
        equalizer:update(MenuSoundManager:getChannel("music").sound, soundData)
    end
    if not doingTransition and didTransition then
        for i = 1, #buttons do
            if timers.buttons["_" .. i] == nil then
                timers.buttons["_" .. i] = Timer.tween(
                    0.125,
                    buttons[i],
                    {
                        x = __inits.__GAME_WIDTH - (curHover == i and 450 or 400)
                    },
                    "out-quad",
                    function()
                        timers.buttons["_" .. i] = nil
                    end
                )
            end
        end
    end
end

function StartMenu:mousemoved(x, y)
    local x, y = toGameScreen(x, y)
    local wasAbleToHover = false
    if curMenu == 1 then return end

    for i = 1, #buttons do
        if buttons[i].x < x and x < buttons[i].x + 500 and buttons[i].y < y and y < buttons[i].y + 100 then
            curHover = i
            wasAbleToHover = true
        end
    end

    curHover = wasAbleToHover and curHover or 0
end

function StartMenu:mousepressed(x, y, b)
    if state.inSubstate then return end
    local x, y = toGameScreen(x, y)
    if b == 1 then
        if twitterLogo:isHovered(x, y) then
            love.system.openURL("https://twitter.com/AGORIStudios")
        elseif kofiLogo:isHovered(x, y) then
            love.system.openURL("https://ko-fi.com/guglioisstupid")
        elseif discordLogo:isHovered(x, y) then
            love.system.openURL("https://discord.gg/y5zz2Dm7A2")
        end
    end

    if curMenu == 2 then
        if b == 1 then
            for i = 1, #buttons do
                if buttons[i].x < x and x < buttons[i].x + 500 and buttons[i].y < y and y < buttons[i].y + 100 then
                    buttons[i].action()
                    return
                end
            end
        end
    else
        if b == 1 then
            enterFunc()
        end
    end
end

function StartMenu:draw()
    bg:draw()
    for i = 1, #balls do
        balls[i]:draw()
    end
    love.graphics.push()
        love.graphics.scale(0.35, 0.35)
        love.graphics.setColor(1, 1, 1)
        logo:draw()
    love.graphics.pop()

    love.graphics.push()
        if curMenu == 2 then -- 1080p window btw
            for i = 1, #buttons do
                love.graphics.setColor(0.70, 0.35, 0)
                love.graphics.rectangle("fill", buttons[i].x, buttons[i].y, 500, 100)
                -- darker outline
                love.graphics.setColor(0.50, 0.25, 0)
                love.graphics.setLineWidth(5)
                love.graphics.rectangle("line", buttons[i].x, buttons[i].y, 500, 100)
                love.graphics.setLineWidth(1)
                -- outline
                local lastFont = love.graphics.getFont()
                setFont("menuMediumBold")
                love.graphics.setColor(0, 0, 0)
                love.graphics.printf(buttons[i].text, buttons[i].x, buttons[i].y + 25, 500, "center")
                love.graphics.setFont(lastFont)
            end
        end
    love.graphics.pop()

    twitterLogo:draw()
    kofiLogo:draw()
    discordLogo:draw()

    if equalizer then
        equalizer:draw()
    end
end

return StartMenu