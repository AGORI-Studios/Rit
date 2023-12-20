local SongMenu = state()

local songButtons = {
    ["osu!"] = {},
    ["Quaver"] = {},
    ["Malody"] = {},
    ["Rit"] = {},
    ["Stepmania"] = {},
    ["All"] = {}
}

local function shakeObject(o)
    Timer.tween(0.05, o, {x = o.x - 5}, "linear", function()
        Timer.tween(0.05, o, {x = o.x + 10}, "linear", function()
            Timer.tween(0.05, o, {x = o.x - 5})
        end)
    end)
end

local curSelected = 1
local balls = {}
local curSongType = "All"
local curTab = "songs" -- songs or diffs
local lerpedSongPos = 0
local transitioning = false
local curButton = nil
local lastCurSelected = 1
local inCat = false
local showCat = true
local inSidebar = false

local allTypes = {
    "All",
    "Rit",
    "Quaver",
    "osu!",
    "Malody",
    "Stepmania"
}

function SongMenu:enter()
    curTab = "songs"
    curSelected = 1
    lerpedSongPos = 0
    curButton = nil
    lastCurSelected = 1
    showCat = true
    inCat = false
    inSidebar = false
    songButton = Sprite(0, 0, "assets/images/ui/menu/songBtn.png")
    statsBox = Sprite(900, 125, "assets/images/ui/menu/statsBox.png")
    diffButton = Sprite(0, songButton.height-55, "assets/images/ui/menu/diffBtn.png")
    statsBox:setScale(1.75)
    bg = Sprite(0, 0, "assets/images/ui/menu/BGsongList.png")
    for i = 1, 5 do
        balls[i] = Sprite(love.math.random(0, 1920), love.math.random(0, 1080), "assets/images/ui/menu/BGball" .. i .. ".png")
    end

    bars = Sprite(1830, 0, "assets/images/ui/buttons/barsHorizontal.png")
    gear = Sprite(0, 0, "assets/images/ui/buttons/gear.png")
    home = Sprite(80, 0, "assets/images/ui/buttons/home.png")

    categoryOpen = Sprite(0, -125, "assets/images/ui/menu/catOpen.png")
    categoryClosed = Sprite(0, -125, "assets/images/ui/menu/catClosed.png")
    bars:setScale(1.5)
    gear:setScale(1.5)
    home:setScale(1.5)
    loadSongs("defaultSongs")
    loadSongs("songs")
    if discordRPC then
        discordRPC.presence = {
            details = "In the menu",
            state = "Selecting a song",
            largeImageKey = "totallyreallogo",
            largeImageText = "Rit" .. (__DEBUG__ and " DEBUG MODE" or "")
        }
    end

    songButtons = {
        ["osu!"] = {},
        ["Quaver"] = {},
        ["Malody"] = {},
        ["Rit"] = {},
        ["Stepmania"] = {},
        ["All"] = {}
    }

    curSelected = 1

    for i, song in pairs(songList) do
        local diffs = {}
        local bmType = nil
        local songName = nil
        for j, diff in pairs(song) do
            if type(diff) == "table" then
                table.insert(diffs, diff)
                songName = diff.title:trim()
                bmType = diff.type
            else
                bmType = diff
            end
        end
        local y = #songButtons[bmType] * songButton.height * 1.1

        local btn = SongButton(y, diffs, bmType, songName)

        table.insert(songButtons[bmType], btn)

        y = #songButtons["All"] * songButton.height * 1.1
        local allBtn = SongButton(y, diffs, bmType, songName)
        table.insert(songButtons["All"], allBtn)
    end
end

function SongMenu:update(dt)
    if state.inSubstate then return end
    if curTab == "songs" then
        curSelected = math.clamp(curSelected, 1, #songButtons[curSongType])
        lerpedSongPos = math.fpsLerp(lerpedSongPos, (-(curSelected - 2.5)) * songButton.height * 1.1, 25, dt)
        curButton = songButtons[curSongType][curSelected]
    else
        curSelected = math.clamp(curSelected, 1, #curButton.children)
        lerpedSongPos = math.fpsLerp(lerpedSongPos, (-(curSelected - 2.5)) * diffButton.height * 1.1, 25, dt)
    end
    
    if input:pressed("confirm") and not transitioning then
        if curTab == "songs" then
            showCat = false
            transitioning = true
            curTab = "diffs"
            lastCurSelected = curSelected
            curSelected = 1
            curButton.open = true

            for i, btn in ipairs(songButtons[curSongType]) do
                Timer.tween(0.1, btn, {x = -btn.width}, "out-quad", function()
                    btn.x = -btn.width
                    transitioning = false
                end)
            end
            for i, diff in ipairs(curButton.children) do
                Timer.tween(0.1, diff, {x = 0}, "out-quad", function()
                    diff.x = 0
                    transitioning = false
                end)
            end
        elseif curTab == "diffs" then
            local diff = curButton.children[curSelected]
            local songPath = diff.path
            local chartver = diff.chartVer
            local folderpath = diff.folderPath
            local filename = diff.filename
            local mode = diff.mode
            love.filesystem.mount("songs/" .. filename, "song")
            if chartver ~= "FNF" then
                states.game.Gameplay.chartVer = chartver
                states.game.Gameplay.songPath = songPath
                states.game.Gameplay.folderpath = folderpath
                switchState(states.game.Gameplay, 0.3, nil)
            end
        end
    elseif input:pressed("back") and not transitioning then
        if curTab == "diffs" then
            showCat = true
            transitioning = true
            curTab = "songs"
            curSelected = lastCurSelected
            
            for i, btn in ipairs(songButtons[curSongType]) do
                Timer.tween(0.1, btn, {x = 0}, "out-quad", function()
                    btn.x = 0
                    transitioning = false
                end)

                for i, diff in ipairs(btn.children) do
                    Timer.tween(0.1, diff, {x = -diff.width}, "out-quad", function()
                        diff.x = -diff.width
                        transitioning = false
                    end)
                end
            end
            
        else
            switchState(states.menu.StartMenu)
        end
    end

    if input:pressed("down") then curSelected = curSelected + 1 end
    if input:pressed("up") then curSelected = curSelected - 1 end
end

function SongMenu:wheelmoved(x, y)
    if state.inSubstate then return end
    curSelected = curSelected - y
end

function SongMenu:mousepressed(x, y, b)
    if state.inSubstate then return end
    local x, y = toGameScreen(x-10, y)
    if b == 1 then
        if gear:isHovered(x, y) then
            state.substate(substates.menu.Options)
        elseif home:isHovered(x, y) then
            state.switch(states.menu.StartMenu)
        elseif bars:isHovered(x, y) then
            --state.substate(substates.menu.Options)
            shakeObject(bars)
        end

        y = y - lerpedSongPos

        if categoryOpen:isHovered(x, y) and showCat then
            inCat = not inCat
        end

        if showCat and inCat then
            for i, type in ipairs(allTypes) do
                if y > 8 + -36 * (-i + 2) and y < 8 + -36 * (-i + 2) + 36 then
                    curSongType = type
                    inCat = false
                    curSelected = 1
                end
            end
        end

        for i, btn in ipairs(songButtons[curSongType]) do
            if btn:isHovered(x, y) then
                curSelected = i
                if curTab == "diffs" then
                    for i, diffBtn in ipairs(btn.children) do
                        if diffBtn:isHovered(x, y) then
                            curSelected = i
                        end
                    end
                end
            end
        end
    end
end

function SongMenu:keypressed(key)
end

function SongMenu:draw()
    bg:draw()
    --[[ for i, ball in ipairs(balls) do
        ball:draw()
    end ]]
    statsBox:draw()
    love.graphics.push()
    --[[ diffButton:draw()
    songButton:draw() ]]
    setFont("menuBold")
    love.graphics.translate(0, lerpedSongPos)
    for i, btn in ipairs(songButtons[curSongType]) do
        if curSelected ~= i then
            btn.color = {0.5, 0.5, 0.5}
        else
            btn.color = {1, 1, 1}
        end
        btn:draw()

        if btn.open then
            for j, diffBtn in ipairs(btn.children) do
                if curSelected ~= j then
                    diffBtn.color = {0.5, 0.5, 0.5}
                else
                    diffBtn.color = {1, 1, 1}
                end
                diffBtn:draw()

                love.graphics.setColor(1, 1, 1, 1)
                local name = diffBtn.name
                if fontWidth("menuBold", name) > 317 then
                    local newWidth = 0
                    local newString = ""
                    for i = 1, #name:splitAllCharacters() do
                        local char = name:sub(i, i)
                        newWidth = newWidth + fontWidth("menuBold", char)
                        if newWidth > 317 then
                            -- break, remove last 3, and add "..."
                            newString = newString:sub(1, #newString - 3) .. "..."
                            break
                        else
                            newString = newString .. char
                        end
                    end
                    name = newString
                end
                love.graphics.print(name, diffBtn.x + 10, diffBtn.y + 30, 0, 2, 2)
            end
        end
        love.graphics.setColor(1, 1, 1, 1)
    end
    if inCat and showCat then
        categoryOpen:draw()

        -- draw rect (line) with all types
        love.graphics.setColor(1, 1, 1, 1)
        for i, type in ipairs(allTypes) do
            love.graphics.setColor(240/255, 181/255, 114/255)
            love.graphics.rectangle("fill", 0, 8 + -36 * (-i + 2), categoryOpen.width-45, 36, 5, 5)
            love.graphics.setColor(241/255, 165/255, 114/255)
            love.graphics.rectangle("line", 0, 8 + -36 * (-i + 2), categoryOpen.width-45, 36, 5, 5)
            love.graphics.setColor(0, 0, 0)
            love.graphics.printf(type, -180, 0 + -36 * (-i + 2), categoryOpen.width-45, "center", 0, 1.5, 1.5)
            love.graphics.setColor(1, 1, 1)
        end
    elseif showCat then
        categoryClosed:draw()
    end
    if showCat then
        love.graphics.printf(curSongType, -615, -108, 1920/2, "center", 0, 1.75, 1.75) -- Song type
    end
    love.graphics.pop()
    love.graphics.setColor(51/255, 10/255, 41/255)
    love.graphics.rectangle("fill", 0, 0, 1920, 70)
    love.graphics.setColor(1, 1, 1)
    gear:draw()
    home:draw()
    bars:draw()
    setFont("menuBold")
    love.graphics.printf(SteamUserName, 180, 8, 1080/2, "left", 0, 2, 2) -- Steam name
    -- draw SteamUserAvatarSmall to the right of the name
    love.graphics.draw(SteamUserAvatarSmall, 180 + (fontWidth("menuBold", SteamUserName)*2) + 10, 3, 0, 2, 2)
    setFont("default")
end

return SongMenu