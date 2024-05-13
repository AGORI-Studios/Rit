local OptionsMenu = state()
local bg
local curTab = "language"
local secondaryTab = "none"

local buttons = {
    {
        text = "Language",
        tabName = "language"
    },
    {
        text = "Controls",
        tabName = "controls"
    },
    {
        text = "Video",
        tabName = "video"
    },
    {
        text = "Audio",
        tabName = "audio"
    },
    {
        text = "Online",
        tabName = "online"
    },
    {
        text = "Editor",
        tabName = "editor"
    },
    {
        text = "Import Data",
        tabName = "importData"
    },
    {
        text = "Skins",
        tabName = "skins"
    },
    {
        text = "Miscellaneous",
        tabName = "Miscellaneous"
    },
    {
        text = "About",
        tabName = "about"
    }
}

local tabs = {
    ["draw_language"] = function()
        
    end,
    ["update_language"] = function(dt)

    end,
    ["mousepressed_language"] = function()

    end,
}

function OptionsMenu:enter(last)
    bg = Sprite(0, 0, "assets/images/ui/menu/playBG.png")
end

function OptionsMenu:update(dt)
    if tabs["update_"..curTab] then
        tabs["update_"..curTab](dt)
    end
end

function OptionsMenu:mousepressed(x, y, b)
    local mx, my = toGameScreen(x, y)

    Header:mousepressed(mx, my, b)

    for i, v in ipairs(buttons) do
        local width = fontWidth("defaultBoldX1.25", v.text)
        local x = 90 + (Inits.GameWidth-275)/#buttons*i - width/2
        local y = 120 + 25 - fontHeight("defaultBoldX1.25")/2
        if mx > x and mx < x + width and my > y and my < y + fontHeight("defaultBoldX1.25") then
            curTab = v.tabName
            secondaryTab = "none"
        end
    end

    if tabs["mousepressed_"..curTab] then
        tabs["mousepressed_"..curTab]()
    end
end

function OptionsMenu:draw()
    local lastFont = love.graphics.getFont()
    local lastColor = {love.graphics.getColor()}

    bg:draw()

    setFont("defaultBoldX1.25")
    love.graphics.setColor(0, 0, 0, 0.2)
    love.graphics.rectangle("fill", -25, 200, Inits.GameWidth+50, Inits.GameHeight, 125, 125)
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.setColor(0, 0, 0, 0.95)
    love.graphics.rectangle("fill", 150, 120, Inits.GameWidth-275, 50, 5, 5)
    love.graphics.setColor(1, 1, 1, 1)
    -- centered text on the black rectangle. NO BACKGROUND FOR THEM
    for i, v in ipairs(buttons) do
        local width = fontWidth("defaultBoldX1.25", v.text)
        -- get x based off i and width
        local x = 90 + (Inits.GameWidth-275)/#buttons*i - width/2
        local y = 120 + 25 - fontHeight("defaultBoldX1.25")/2
        if curTab == v.tabName then
            love.graphics.setColor(232/255,86/255,86/255)
        else
            love.graphics.setColor(1, 1, 1)
        end
        love.graphics.print(v.text, x, y)
    end

    if tabs["draw_"..curTab] then
        tabs["draw_"..curTab]()
    end

    Header:draw()
    
    love.graphics.setFont(lastFont)
    love.graphics.setColor(lastColor)
end

return OptionsMenu