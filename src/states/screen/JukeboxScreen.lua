---@diagnostic disable: need-check-nil
local Jukebox = state()
local curSong = nil
local curDiff = nil

local balls, bg

local time, time2, songTime = 0, 0, 0

--local equalizer

local orderedSongs = {}
local songIndex = 1

local rpcTimer = 0

local function playSong()
    curSong = orderedSongs[songIndex]
    curDiff = table.random(curSong)
    while (type(curDiff) == "string") do
        curDiff = table.random(curSong)
    end

    if curDiff.audioFile:startsWith("song/") then
        love.filesystem.mount("songs/" .. curDiff.filename, "song")
    end

    MenuSoundManager:stop("music")
    MenuSoundManager:newSound("music", curDiff.audioFile, 1, false, "stream")
    MenuSoundManager:play("music")
    MenuSoundManager:setLooping("music", false)

    startedTime = love.timer.getTime()
    endedTime = startedTime + MenuSoundManager:getDuration("music")

    if curDiff.audioFile:startsWith("song/") then
        love.filesystem.unmount(curDiff.path)
    end
end

local buttons = {
    -- media controls
    {
        x = 0,
        y = 1030,
        width = 100,
        height = 100,
        image = "assets/images/ui/menu/media/previous.png",
        placeholderText = localize("Prev"),
        onClick = function()
            songIndex = songIndex - 1
            if songIndex < 1 then
                songIndex = #orderedSongs
            end
            playSong()
        end,
        type = "once",
    },
    {
        x = 100,
        y = 1030,
        width = 100,
        height = 100,
        image = "assets/images/ui/menu/media/forward.png",
        placeholderText = localize("Play/Pause"),
        onClick = function()
            MenuSoundManager:play("music")
        end,
        type = "toggle",
        colour = {1, 1, 1}
    },
    {
        x = 200,
        y = 1030,
        width = 100,
        height = 100,
        image = "assets/images/ui/menu/media/next.png",
        placeholderText = localize("Next"),
        onClick = function()
            songIndex = songIndex + 1
            if songIndex > #orderedSongs then
                songIndex = 1
            end
            playSong()
        end,
        type = "once"
    },
    {
        x = 300,
        y = 1030,
        width = 100,
        height = 100,
        image = "assets/images/ui/menu/media/stop.png",
        placeholderText = localize("Stop"),
        onClick = function()
            MenuSoundManager:pause("music")
        end,
        type = "once"
    },
    {
        x = 400,
        y = 1030,
        width = 100,
        height = 100,
        image = "assets/images/ui/menu/media/rewind.png",
        placeholderText = localize("Restart"),
        onClick = function()
            MenuSoundManager:stop("music")
            --[[ MenuSoundManager:removeAllSounds() ]]
            MenuSoundManager:newSound("music", curDiff.audioFile, 1, false, "stream")
            MenuSoundManager:play("music")
            MenuSoundManager:setLooping("music", false)
        end,
        type = "once"
    },
    {
        x = 500,
        y = 1030,
        width = 100,
        height = 100,
        image = "assets/images/ui/menu/media/return.png",
        placeholderText = localize("Loop"),
        onClick = function()
            MenuSoundManager:setLooping("music", not MenuSoundManager:getLooping("music"))
        end,
        type = "toggle",
        colour = {1, 1, 1}
    }
}

local closeBtn

function Jukebox:enter()
    orderedSongs = {}
    for _, song in pairs(songList) do
        local rndDiff = table.random(song)
        while (type(rndDiff) == "string") do
            rndDiff = table.random(song)
        end
        song.title = rndDiff.title
        table.insert(orderedSongs, song)
        table.sort(orderedSongs, function(a, b) return a.title < b.title end)
    end

    balls = {}
    bg = Sprite(0, 0, "assets/images/ui/menu/playBG.png")
    for i = 1, 5 do
        balls[i] = Sprite(love.math.random(0, 1600), love.math.random(0, 720), "assets/images/ui/menu/BGball" .. i .. ".png")
        balls[i].ogX, balls[i].ogY = love.math.random(0, 1920 - balls[i].width), love.math.random(0, 1080 - balls[i].height)
        balls[i].velY = love.math.random(25, 50)
    end
    table.randomize(balls)

    -- media controls (load images)
    for _, button in ipairs(buttons) do
        if button.image and not button.img and love.filesystem.getInfo(button.image) then
            button.img = Sprite(button.x, button.y, button.image)
        end
    end

    -- top right
    closeBtn = Sprite(Inits.GameWidth - 75, 25, "assets/images/ui/menu/cross.png")
    closeBtn.color = {1, 0, 0}

    playSong()

    __InJukebox = true
end

function Jukebox:update(dt)
    time = time + 1000 * dt
    time2 = time2 + 1000 * dt
    --[[ songTime = MenuSoundManager:tell("music") ]]
    if MenuSoundManager:exists("music") then
        songTime = MenuSoundManager:tell("music")
    else
        songTime = 0
    end
    local mx, my = love.mouse.getPosition()
    local px, py = (-mx / 50), (-my / 50)

    rpcTimer = rpcTimer + dt
    if discordRPC and rpcTimer > 1 then
        rpcTimer = 0
        local formattedTime = string.format("%02d:%02d", math.floor(songTime / 60), math.floor(songTime % 60))
        discordRPC.presence = {
            details = localize("In the Jukebox"),
            -- time and what song
            state = localize("Listening to ") .. curSong.title,
            largeImageKey = "totallyreallogo",
            largeImageText = "Rit" .. (__DEBUG__ and " DEBUG MODE" or ""),
        }
        GameInit.UpdateDiscord()
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

    if MenuSoundManager:exists("music") and (not MenuSoundManager:isPlaying("music") and not MenuSoundManager:isPaused("music")) then

        songIndex = songIndex + 1
        if songIndex > #orderedSongs then
            songIndex = 1
        end
        playSong()
    end

    --[[ if equalizer and MenuSoundManager:getChannel("music") then
        equalizer:update(MenuSoundManager:getChannel("music").sound, soundData)
    end ]]

end

function Jukebox:mousepressed(x, y, button)
    local x, y = toGameScreen(x, y)
    if button == 1 then
        for _, button in ipairs(buttons) do
            if x > button.x and x < button.x + button.width and y > button.y and y < button.y + button.height then
                button.onClick()
            end
        end

        if x > closeBtn.x and x < closeBtn.x + closeBtn.width and y > closeBtn.y and y < closeBtn.y + closeBtn.height then
            switchState(states.menu.StartMenu, 0.3)
        end
    end
end

function Jukebox:draw()
    bg:draw()
    for _, bubble in ipairs(balls) do
        bubble:draw()
    end

    --[[ if equalizer then
        equalizer:draw()
    end ]]

    -- media controls
    for _, button in ipairs(buttons) do
        if button.img then
            if button.type == "toggle" then
                love.graphics.setColor(button.colour[1], button.colour[2], button.colour[3])
            end
            button.img:draw()
        else
            love.graphics.setColor(0.5, 0.5, 0.5)
            love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)
            love.graphics.setColor(0.15, 0.15, 0.15)
            love.graphics.printf(button.placeholderText, button.x, button.y + button.height / 2 - 10, button.width, "center")
        end
    end

    -- draw progress bar
    if MenuSoundManager:exists("music") then
        local percent = (MenuSoundManager:tell("music")) / MenuSoundManager:getDuration("music")
        love.graphics.setColor(0.70, 0.35, 0)
        
        local mediaWidth = #buttons * 100
        
        -- draw progress bar to right of media controls
        love.graphics.rectangle("fill", mediaWidth + 100, 1030, Inits.GameWidth - mediaWidth - 200, 100)
        love.graphics.setColor(0.50, 0.25, 0)
        love.graphics.rectangle("fill", mediaWidth + 100, 1030, (Inits.GameWidth - mediaWidth - 200) * percent, 100)
    end
    -- show title above progress bar, left aligned
    love.graphics.setColor(1, 1, 1)
    local lastFont = love.graphics.getFont()
    love.graphics.setFont(Cache.members.font["defaultBold"])
    love.graphics.printf(
        (curSong.title or localize("Unknown")),
        Inits.GameWidth/2-265, 990, Inits.GameWidth, "left",
        0, 2.25, 2.25
    )

    closeBtn:draw()
end

function Jukebox:exit()
    __InJukebox = false
end

return Jukebox