---@diagnostic disable: redundant-parameter
local OptionsMenu = state()
local bg
local curTab = "language"

--Yeah.....

local resolutions = {
    {1920, 1080},
    {1600, 900},
    {1366, 768},
    {1280, 720}, -- <- This is the default resolution
    {1024, 576},
    {854, 480},
    {640, 360},
}

local curResolution = 4

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

local tabOptions = {
    
}

local keybindsTabs = {
    ["1k"] = {

    },
    ["2k"] = {

    },
    ["3k"] = {

    },
    ["4k"] = {

    },
    ["5k"] = {

    },
    ["6k"] = {

    },
    ["7k"] = {

    },
    ["8k"] = {

    },
    ["9k"] = {

    },
    ["10k"] = {

    }
}

local curBindTab = "4k"

local tabs = {
    ["draw_language"] = function()
        
    end,
    ["update_language"] = function(dt)

    end,
    ["mousepressed_language"] = function()

    end,

    ["draw_controls"] = function()
        setFont("menuExtraBoldX1.5")
        love.graphics.print("Keybinds", 100, 275)
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.rectangle("line", 100, 325, 575, 1)
        love.graphics.setColor(0, 0, 0, 0.25)
        -- draw rect for length of the keybinds (10)
        love.graphics.rectangle("fill", 100, 340, 575, 35, 5, 5)
        love.graphics.setColor(1, 1, 1)
        for i = 1, 10 do
            if curBindTab == i .. "k" then
                love.graphics.setColor(1, 1, 1)
            else
                love.graphics.setColor(85/255, 15/255, 55/255)
            end
            love.graphics.print(i .. "k", 67 + 57.5*i - fontWidth("menuExtraBoldX1.5", i .. "k")/2, 340 + 35/2 - fontHeight("menuExtraBoldX1.5")/2)
        end
    end,
    ["update_controls"] = function(dt)

    end,
    ["mousepressed_controls"] = function(mx, my)
        for i = 1, 10 do
            if mx > 67 + 57.5*i - fontWidth("menuExtraBoldX1.5", i .. "k")/2 and mx < 67 + 57.5*i + fontWidth("menuExtraBoldX1.5", i .. "k")/2 and my > 340 and my < 375 then
                curBindTab = i .. "k"
            end
        end
    end,

    ["draw_video"] = function()
        setFont("menuExtraBoldX1.5")
        love.graphics.print("Video", 100, 275)
        setFont("defaultBoldX1.5")
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.rectangle("line", 100, 325, 575, 1)
        love.graphics.setColor(1, 1, 1)

        love.graphics.print("Screen Resolution", 105, 345)

        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.rectangle("line", 105, 395, 575, 1)
        love.graphics.setColor(1, 1, 1)

        VSYNC_switch:draw()

        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.rectangle("line", 105, 470, 575, 1)
        love.graphics.setColor(1, 1, 1)

        FPSCAP_switch:draw()
    end,
    ["update_video"] = function(dt)
        VSYNC_switch:update(dt)
        FPSCAP_switch:update(dt)
    end,
    ["mousepressed_video"] = function()
        
    end,

    ["draw_audio"] = function()

    end,
    ["update_audio"] = function(dt)

    end,
    ["mousepressed_audio"] = function()

    end,

    ["draw_online"] = function()

    end,
    ["update_online"] = function(dt)

    end,
    ["mousepressed_online"] = function()

    end,

    ["draw_editor"] = function()

    end,
    ["update_editor"] = function(dt)

    end,
    ["mousepressed_editor"] = function()

    end,

    ["draw_importData"] = function()

    end,
    ["update_importData"] = function(dt)

    end,
    ["mousepressed_importData"] = function()

    end,

    ["draw_skins"] = function()

    end,
    ["update_skins"] = function(dt)

    end,
    ["mousepressed_skins"] = function()

    end,

    ["draw_miscellaneous"] = function()

    end,
    ["update_miscellaneous"] = function(dt)

    end,
    ["mousepressed_miscellaneous"] = function()

    end,

    ["draw_about"] = function()

    end,
    ["update_about"] = function(dt)

    end,
    ["mousepressed_about"] = function()

    end
}

function OptionsMenu:enter(last)
    bg = Sprite(0, 0, "assets/images/ui/menu/playBG.png")
    VSYNC_switch = Switch("V-Sync", Settings.options["Video"]["VSYNC"], "Video", "VSYNC")
    VSYNC_switch.x, VSYNC_switch.y = 105, 410
    FPSCAP_switch = Switch("FPS Cap", Settings.options["Video"]["FPSCAP"], "Video", "FPSCAP")
    FPSCAP_switch.x, FPSCAP_switch.y = 105, 480
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
        end
    end

    if tabs["mousepressed_"..curTab] then
        tabs["mousepressed_"..curTab](mx, my)
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

function OptionsMenu:exit()
    
end


return OptionsMenu