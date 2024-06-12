local StartMenu = state()
local beat, time = 0, 0
local time2 = 0
menuBPM = 120

local balls, bg, logo, twitterLogo, kofiLogo, discordLogo

local curMenu = 1
local curLogoScale = {1.85}
local logoScale = {2, 2}
local logoPos = {0, 0}
local curHover = 0 -- none

local curLocale = localize.getLocaleName()

local borderImg = love.graphics.newImage("assets/images/ui/menu/buttons/bigBtnBorder.png")
local buttons = {
    {
        border = borderImg,
        img = love.graphics.newImage("assets/images/ui/menu/buttons/playBtn.png"),
        text = nil,
        textX = 0,
        textY = 0,
        x = Inits.GameWidth - 650,
        y = Inits.GameHeight/2 - 250,
        scaleBorder = 1.25,
        scale = 1.25,
        color = {1, 1, 1},
        down = false,
        action = function()
            switchState(states.menu.SongMenu, 0.3)
        end
    },
    {
        border = borderImg,
        img = love.graphics.newImage("assets/images/ui/menu/buttons/ohBtn.png"),
        text = love.graphics.newImage("assets/images/ui/menu/buttons/ohBtnText.png"),
        textX = 0,
        textY = 0,
        x = Inits.GameWidth - 350,
        y = Inits.GameHeight/2 - 250,
        scaleBorder = 1.25,
        scale = 1.25,
        color = {1, 1, 1},
        down = false,
        action = function()
            switchState(states.menu.Multiplayer.ServerMenu, 0.3)
        end
    },
    {
        img = love.graphics.newImage("assets/images/ui/menu/buttons/lilCuteBtnOwo.png"),
        text = "Jukebox",
        textX = 0,
        textY = 0,
        x = Inits.GameWidth - 650,
        y = Inits.GameHeight/2+50,
        scaleBorder = 1.25,
        scale = 1.25,
        color = {1, 1, 1},
        down = false,
        action = function()
            switchState(states.screens.Jukebox, 0.3)
        end
    },
    {
        img = love.graphics.newImage("assets/images/ui/menu/buttons/lilCuteBtnOwo.png"),
        text = "Settings",
        textX = 0,
        textY = 0,
        x = Inits.GameWidth - 350,
        y = Inits.GameHeight/2+50,
        scaleBorder = 1.25,
        scale = 1.25,
        color = {1, 1, 1},
        down = false,
        action = function()
            switchState(states.menu.OptionsMenu, 0.3)
        end
    },
    {
        img = love.graphics.newImage("assets/images/ui/menu/buttons/lilCuteBtnOwo.png"),
        text = "Credits",
        textX = 0,
        textY = 0,
        x = Inits.GameWidth - 650,
        y = Inits.GameHeight/2 + 150,
        scaleBorder = 1.25,
        scale = 1.25,
        color = {1, 1, 1},
        down = false,
        action = function()
            switchState(states.menu.CreditsMenu, 0.3)
        end
    },
    {
        img = love.graphics.newImage("assets/images/ui/menu/buttons/lilCuteBtnOwo.png"),
        text = "Quit",
        textX = 0,
        textY = 0,
        x = Inits.GameWidth - 350,
        y = Inits.GameHeight/2 + 150,
        scaleBorder = 1.25,
        scale = 1.25,
        color = {1, 1, 1},
        down = false,
        action = function()
            love.event.quit()
        end
    }
}
if curLocale == "es-LATAM" then
    buttons[1].text = love.graphics.newImage("assets/images/ui/menu/buttons/playBtnTextES.png")
elseif curLocale == "pt-BR" then
    buttons[1].text = love.graphics.newImage("assets/images/ui/menu/buttons/playBtnTextPT.png")
elseif curLocale == "fr-FR" then
    buttons[1].text = love.graphics.newImage("assets/images/ui/menu/buttons/playBtnTextFR.png")
else
    buttons[1].text = love.graphics.newImage("assets/images/ui/menu/buttons/playBtnText.png")
end

function StartMenu:enter()
    balls = {}
    bg = Sprite(0, 0, "assets/images/ui/menu/playBG.png")
    for i = 1, 5 do
        balls[i] = Sprite(love.math.random(0, 1600), love.math.random(0, 720), "assets/images/ui/menu/BGball" .. i .. ".png")
        balls[i].alpha = 0.71
        balls[i].blend = "lighten"
        balls[i].blendAlphaMode = "premultiplied"
        balls[i].ogX, balls[i].ogY = love.math.random(0, 1920 - balls[i].width), love.math.random(0, 1080 - balls[i].height)
        balls[i].velY = love.math.random(25, 50)
    end
    table.randomize(balls)
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

    logo.y =Inits.GameHeight
    logo.x =Inits.GameWidth * 0.5
    
    if discordRPC then
        discordRPC.presence = {
            details = "In the menu",
            state = "",
            largeImageKey = "totallyreallogo",
            largeImageText = "Rit" .. (__DEBUG__ and " DEBUG MODE" or "")
        }
        GameInit.UpdateDiscord()
    end

    if not MenuSoundManager:exists("music") then playRandomSong() end
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

    local mx, my = toGameScreen(love.mouse.getPosition())

    for i = 1, #buttons do
        if love.mouse.isDown(1) and mx > buttons[i].x and mx < buttons[i].x + buttons[i].img:getWidth() * buttons[i].scale and my > buttons[i].y and my < buttons[i].y + buttons[i].img:getHeight() * buttons[i].scale then
            buttons[i].down = true
        else
            buttons[i].down = false
        end

        if not buttons[i].down then
            if buttons[i].img then
                if mx > buttons[i].x and mx < buttons[i].x + buttons[i].img:getWidth() * buttons[i].scale and my > buttons[i].y and my < buttons[i].y + buttons[i].img:getHeight() * buttons[i].scale then
                    buttons[i].scale = math.fpsLerp(buttons[i].scale, 1.4, 5, love.timer.getDelta()) 
                    buttons[i].scaleBorder = math.fpsLerp(buttons[i].scaleBorder, 1.5, 5, love.timer.getDelta())
                else
                    buttons[i].scale = math.fpsLerp(buttons[i].scale, 1.25, 5, love.timer.getDelta())
                    buttons[i].scaleBorder = math.fpsLerp(buttons[i].scaleBorder, 1.25, 5, love.timer.getDelta())
                end
                buttons[i].color[1], buttons[i].color[2], buttons[i].color[3] = math.fpsLerp(buttons[i].color[1], 1, 8, love.timer.getDelta()), 
                                    math.fpsLerp(buttons[i].color[2], 1, 5, love.timer.getDelta()),
                                    math.fpsLerp(buttons[i].color[3], 1, 5, love.timer.getDelta())
            end
        else
            -- we can safely assume that the button is hovered
            buttons[i].scale = math.fpsLerp(buttons[i].scale, 1.3, 5, love.timer.getDelta())
            buttons[i].color[1], buttons[i].color[2], buttons[i].color[3] = math.fpsLerp(buttons[i].color[1], 0.7, 5, love.timer.getDelta()), 
                                math.fpsLerp(buttons[i].color[2], 0.9, 5, love.timer.getDelta()), 
                                math.fpsLerp(buttons[i].color[3], 0.7, 5, love.timer.getDelta())
        end

    end

    -- Logo parallax
    local px, py = (-mx / 50), (-my / 50)
    logo.x = logoPos[1] + Inits.GameWidth * 0.5 + px
    logo.y = logoPos[2] + Inits.GameHeight + py

    bg.x, bg.y = px * 0.0125, py * 0.0125

    --[[ for i = 1, #balls do
        balls[i].x = balls[i].ogX + px * 0.09 + (0.05 * i * 5)
        balls[i].y = balls[i].ogY + py * 0.09 + (0.05 * i * 5)
    end ]]

    if logoScale[1] > curLogoScale[1] then
        logoScale[1] = math.fpsLerp(logoScale[1], curLogoScale[1], 5, dt)
        logoScale[2] = math.fpsLerp(logoScale[2], curLogoScale[1], 5, dt)
        logo:setScale(logoScale[1], logoScale[2])
    end

    for i, bubble in ipairs(balls) do
        bubble.ogX = bubble.ogX + math.sin(time2 / (100 * i)) * 0.05
        -- velY is the speed of the bubble
        bubble.ogY = bubble.ogY - bubble.velY * dt

        if bubble.ogY < -bubble.height then
            bubble.ogY = Inits.GameHeight + 100
            bubble.ogX = love.math.random(0, 1920 - bubble.width)
            bubble.velY = love.math.random(25, 50)
        end

        bubble.x = bubble.ogX + px * 0.09 + (0.05 * i * 5)
        bubble.y = bubble.ogY + py * 0.09 + (0.05 * i * 5)
    end

    if state.inSubstate then return end

    if input:pressed("back") then
        love.event.quit()
    end
end

function StartMenu:mousemoved(x, y)
    local x, y = toGameScreen(x, y)
end

function StartMenu:mousepressed(x, y, b)
    if state.inSubstate then return end
    local x, y = toGameScreen(x, y)
end

function StartMenu:mousereleased(x, y, b)
    if state.inSubstate then return end
    local x, y = toGameScreen(x, y)
    for i = 1, #buttons do
        if x > buttons[i].x and x < buttons[i].x + buttons[i].img:getWidth() * buttons[i].scale and y > buttons[i].y and y < buttons[i].y + buttons[i].img:getHeight() * buttons[i].scale then
            buttons[i].action()
        end
    end
end

function StartMenu:touchreleased(id, x, y, dx, dy, pressure)
    if state.inSubstate then return end
    local x, y = toGameScreen(x, y)
    for i = 1, #buttons do
        if x > buttons[i].x and x < buttons[i].x + buttons[i].img:getWidth() * buttons[i].scale and y > buttons[i].y and y < buttons[i].y + buttons[i].img:getHeight() * buttons[i].scale then
            buttons[i].action()
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

    local lastColor = {love.graphics.getColor()}
    local lastFont = love.graphics.getFont()
    love.graphics.setColor(0, 0, 0, 0.13)
    love.graphics.rectangle("fill", Inits.GameWidth - 695, Inits.GameHeight/2 - 300, 650, 570, 75, 75)
    setFont("menuBold")
    for i = 1, #buttons do
        local x, y = buttons[i].x, buttons[i].y
        local borderX = x
        local borderY = y
        if buttons[i].border then
            borderX = borderX - (buttons[i].border:getWidth() * buttons[i].scaleBorder - buttons[i].border:getWidth() * 1.25) / 2
            borderY = borderY - (buttons[i].border:getHeight() * buttons[i].scaleBorder - buttons[i].border:getHeight() * 1.25) / 2
        end
        x = x - (buttons[i].img:getWidth() * buttons[i].scale - buttons[i].img:getWidth() * 1.25) / 2
        y = y - (buttons[i].img:getHeight() * buttons[i].scale - buttons[i].img:getHeight() * 1.25) / 2
        local textX, textY = x + buttons[i].textX, y + buttons[i].textY
        if type(buttons[i].text) == "string" then
            -- center text
            local width = fontWidth("menuBold", buttons[i].text)
            local height = fontHeight("menuBold", buttons[i].text)
            textX = textX + (buttons[i].img:getWidth() * buttons[i].scale - width * buttons[i].scale) / 2
            textY = textY + (buttons[i].img:getHeight() * buttons[i].scale - height * buttons[i].scale) / 2 - 2
        else
            textX = textX + (buttons[i].img:getWidth() * buttons[i].scale - buttons[i].text:getWidth() * buttons[i].scale) / 2
            textY = textY + (buttons[i].img:getHeight() * buttons[i].scale - buttons[i].text:getHeight() * buttons[i].scale) / 2
        end
        if buttons[i].border then
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(buttons[i].border, borderX, borderY, 0, buttons[i].scaleBorder, buttons[i].scaleBorder)
        end
        if buttons[i].img then
            love.graphics.setColor(buttons[i].color)
            love.graphics.draw(buttons[i].img, x, y, 0, buttons[i].scale, buttons[i].scale)
        end
        if buttons[i].text then
            if type(buttons[i].text) == "string" then
                love.graphics.print(buttons[i].text, textX, textY, 0, buttons[i].scale, buttons[i].scale)
            else
                love.graphics.draw(buttons[i].text, textX, textY, 0, buttons[i].scale, buttons[i].scale)
            end
        end
    end

    setFont("NatsRegular26")
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.print("Rit " .. __VERSION__, 10, Inits.GameHeight - 75)

    love.graphics.setColor(lastColor)
    love.graphics.setFont(lastFont)
    
    --[[ twitterLogo:draw()
    kofiLogo:draw()
    discordLogo:draw() ]]
end

return StartMenu