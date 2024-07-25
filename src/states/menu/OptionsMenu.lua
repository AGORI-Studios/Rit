---@diagnostic disable: redundant-parameter, param-type-mismatch
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
        text = "Gameplay",
        tabName = "gameplay"
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
        tabName = "miscellaneous"
    },
    {
        text = "About",
        tabName = "about"
    }
}

local tabOptions = {

}

local curBindTab = "4k"
local curSelectedBind = 1

-- I should of probably made this use my "Group" class, but oh well.
-- I suck at coding option menus, but if it works, it works.
local tabs = {
    ["draw_language"] = function()
        setFont("menuExtraBoldX1.5")
        love.graphics.print(localize("Language"), 100, 275)
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.rectangle("line", 100, 325, 575, 1)
        love.graphics.setColor(1, 1, 1)
        setFont("defaultBoldX1.5")
    end,
    ["update_language"] = function(dt)

    end,
    ["mousepressed_language"] = function()

    end,

    ["draw_gameplay"] = function()
        setFont("menuExtraBoldX1.5")
        love.graphics.print(localize("Gameplay"), 100, 275)
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.rectangle("line", 100, 325, 575, 1)
        love.graphics.setColor(1, 1, 1)
        setFont("defaultBoldX1.5")

        DOWNSCROLL_switch:draw()
        NSV_switch:draw()
        SCROLLSPEED_slider:draw()
        BACKGROUNDDIM_slider:draw()
        BACKGROUNDBLUR_slider:draw()
    end,
    ["update_gameplay"] = function(dt)
        DOWNSCROLL_switch:update(dt)
        NSV_switch:update(dt)
        SCROLLSPEED_slider:update(dt)
        BACKGROUNDDIM_slider:update(dt)
        BACKGROUNDBLUR_slider:update(dt)
    end,
    ["mousepressed_gameplay"] = function(mx, my)
        DOWNSCROLL_switch:mousepressed(mx, my)
        NSV_switch:mousepressed(mx, my)
        SCROLLSPEED_slider:mousepressed(mx, my)
        BACKGROUNDDIM_slider:mousepressed(mx, my)
        BACKGROUNDBLUR_slider:mousepressed(mx, my)
    end,
    ["mousemoved_gameplay"] = function(mx, my, mdx, mdy)
        SCROLLSPEED_slider:mousemoved(mx, my, mdx, mdy)
        BACKGROUNDDIM_slider:mousemoved(mx, my, mdx, mdy)
        BACKGROUNDBLUR_slider:mousemoved(mx, my, mdx, mdy)
    end,
    ["mousereleased_gameplay"] = function(mx, my)
        SCROLLSPEED_slider:mousereleased(mx, my)
        BACKGROUNDDIM_slider:mousereleased(mx, my)
        BACKGROUNDBLUR_slider:mousereleased(mx, my)
    end,
    ["keypressed_gameplay"] = function(k)
        SCROLLSPEED_slider:keypressed(k)
        BACKGROUNDDIM_slider:keypressed(k)
        BACKGROUNDBLUR_slider:keypressed(k)
    end,

    ["draw_controls"] = function()
        setFont("menuExtraBoldX1.5")
        love.graphics.print(localize("Controls"), 100, 275)
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

        local subbed = string.gsub(curBindTab, "k", "")
        local keyCount = tonumber(subbed)
        local splitted = string.splitAllCharacters(Settings.options["Keybinds"][curBindTab .. "Binds"])
        love.graphics.setColor(1, 1, 1)
        for i = 1, keyCount do
            local char = splitted[i]
            if char == " " then char = "SP" end
            local button = KB_Buttons[i]
            button.x, button.y = 105 + 80 * (i-1), 400

            if curSelectedBind == i then
                love.graphics.setColor(1, 1, 1)
                button.color = {1, 1, 1}
            else
                love.graphics.setColor(0.5, 0.5, 0.5)
                button.color = {0.5, 0.5, 0.5}
            end
            button:draw()
            love.graphics.printf(string.upper(char), 143 + 80 * (i-1) - Inits.GameWidth/2, 417, Inits.GameWidth, "center")
        end

        curSelectedBind = math.clamp(1, curSelectedBind or 0, keyCount)
        --[[ keybindsTabs[curBindTab]:draw() ]]
    end,
    ["update_controls"] = function(dt)

    end,
    ["mousepressed_controls"] = function(mx, my)
        for i = 1, 10 do
            if mx > 67 + 57.5*i - fontWidth("menuExtraBoldX1.5", i .. "k")/2 and mx < 67 + 57.5*i + fontWidth("menuExtraBoldX1.5", i .. "k")/2 and my > 340 and my < 375 then
                curBindTab = i .. "k"
            end
        end

        local subbed = string.gsub(curBindTab, "k", "")
        local keyCount = tonumber(subbed)
        for i = 1, keyCount do
            local button = KB_Buttons[i]

            if mx >= button.x and mx <= button.x + button.width and my >= button.y and my <= button.y + button.height then
                curSelectedBind = i
            end
        end
    end,
    ["textinput_controls"] = function(t)
        local subbed = string.gsub(curBindTab, "k", "")
        local keyCount = tonumber(subbed)
        
        if curSelectedBind and curSelectedBind >= 1 and curSelectedBind <= keyCount then
            local keybinds = Settings.options["Keybinds"][curBindTab .. "Binds"]
            local splitted = string.splitAllCharacters(keybinds)
            
            -- Update the character at the current bind position
            if splitted[curSelectedBind] then
                splitted[curSelectedBind] = t
            end
            
            -- Reassemble the keybinds string
            local newKeybinds = table.concat(splitted)
            Settings.options["Keybinds"][curBindTab .. "Binds"] = newKeybinds
        end
    end,

    ["draw_video"] = function()
        setFont("menuExtraBoldX1.5")
        love.graphics.print(localize("Video"), 100, 275)
        setFont("defaultBoldX1.5")
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.rectangle("line", 100, 325, 575, 1)
        love.graphics.setColor(1, 1, 1)

        --love.graphics.print(localize("Screen Resolution"), 105, 345) -- TODO: Make the dropdown for this option

        VSYNC_switch:draw()
        UNFOCUSEDFPS_switch:draw()
        SHADERS_switch:draw()
        SCREENRESOLUTION_dropdown:draw()
        FPSOPTIONS_dropdown:draw()
    end,
    ["update_video"] = function(dt)
        VSYNC_switch:update(dt)
        UNFOCUSEDFPS_switch:update(dt)
        SHADERS_switch:update(dt)
    end,
    ["mousepressed_video"] = function(mx, my, b)
        dontCont = SCREENRESOLUTION_dropdown:mousepressed(mx, my, b)
        if dontCont then
            return 
        end
        local dontCont = FPSOPTIONS_dropdown:mousepressed(mx, my, b)
        if dontCont then
            setFpsCapFromSetting()
            return 
        end
        VSYNC_switch:mousepressed(mx, my)
        UNFOCUSEDFPS_switch:mousepressed(mx, my)
        SHADERS_switch:mousepressed(mx, my)
    end,

    ["draw_audio"] = function()
        setFont("menuExtraBoldX1.5")
        love.graphics.print(localize("Audio"), 100, 275)
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.rectangle("line", 100, 325, 575, 1)
        love.graphics.setColor(1, 1, 1)

        setFont("defaultBoldX1.5")
        GLOBAL_slider:draw()
        HITSOUND_slider:draw()
    end,
    ["update_audio"] = function(dt)
        GLOBAL_slider:update(dt)
        HITSOUND_slider:update(dt)
    end,
    ["mousepressed_audio"] = function(mx, my, b)
        GLOBAL_slider:mousepressed(mx, my, b)
        HITSOUND_slider:mousepressed(mx, my, b)
    end,
    ["mousereleased_audio"] = function(mx, my, b)
        GLOBAL_slider:mousereleased(mx, my, b)
        HITSOUND_slider:mousereleased(mx, my, b)
    end,
    ["mousemoved_audio"] = function(mx, my, mdx, mdy)
        GLOBAL_slider:mousemoved(mx, my, mdx, mdy)
        HITSOUND_slider:mousemoved(mx, my, mdx, mdy)
    end,
    ["keypressed_audio"] = function(key)
        GLOBAL_slider:keypressed(key)
        HITSOUND_slider:keypressed(key)
    end,


    ["draw_online"] = function()
        setFont("menuExtraBoldX1.5")
        love.graphics.print(localize("Online"), 100, 275)
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.rectangle("line", 100, 325, 575, 1)
        love.graphics.setColor(1, 1, 1)
    end,
    ["update_online"] = function(dt)

    end,
    ["mousepressed_online"] = function()

    end,

    ["draw_editor"] = function()
        setFont("menuExtraBoldX1.5")
        love.graphics.print(localize("Editor"), 100, 275)
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.rectangle("line", 100, 325, 575, 1)
        love.graphics.setColor(1, 1, 1)
    end,
    ["update_editor"] = function(dt)

    end,
    ["mousepressed_editor"] = function()

    end,

    ["draw_importData"] = function()
        setFont("menuExtraBoldX1.5")
        love.graphics.print(localize("Import Data"), 100, 275)
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.rectangle("line", 100, 325, 575, 1)
        love.graphics.setColor(1, 1, 1)
    end,
    ["update_importData"] = function(dt)

    end,
    ["mousepressed_importData"] = function()

    end,

    ["draw_skins"] = function()
        setFont("menuExtraBoldX1.5")
        love.graphics.print(localize("Skins"), 100, 275)
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.rectangle("line", 100, 325, 575, 1)
        love.graphics.setColor(1, 1, 1)

        SKIN_dropdown:draw()
    end,
    ["update_skins"] = function(dt)
        SKIN_dropdown:update(dt)
    end,
    ["mousepressed_skins"] = function(mx, my, b)
        local dontCont = SKIN_dropdown:mousepressed(mx, my, b)
        if dontCont then return end
    end,

    ["draw_miscellaneous"] = function()
        setFont("menuExtraBoldX1.5")
        love.graphics.print(localize("Miscellaneous"), 100, 275)
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.rectangle("line", 100, 325, 575, 1)
        love.graphics.setColor(1, 1, 1)
    end,
    ["update_miscellaneous"] = function(dt)

    end,
    ["mousepressed_miscellaneous"] = function()

    end,

    ["draw_about"] = function()
        setFont("menuExtraBoldX1.5")
        love.graphics.print(localize("About"), 100, 275)
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.rectangle("line", 100, 325, 575, 1)
        love.graphics.setColor(1, 1, 1)
    end,
    ["update_about"] = function(dt)

    end,
    ["mousepressed_about"] = function()

    end
}

function OptionsMenu:enter(last)
    bg = Sprite(0, 0, "assets/images/ui/menu/playBG.png")
    -- [[ LANGUAGE TAB ]] --
    -- [[ GAMEPLAY TAB ]] --
    DOWNSCROLL_switch = Switch("Downscroll", false, "General", "downscroll")
    DOWNSCROLL_switch.x, DOWNSCROLL_switch.y = 105, 340

    NSV_switch = Switch("No SV", false, "General", "noScrollVelocity")
    NSV_switch.x, NSV_switch.y = 105, 400

    SCROLLSPEED_slider = Slider("Scrollspeed", 1, "General", "scrollspeed", 0.1, 5)
    SCROLLSPEED_slider.x, SCROLLSPEED_slider.y = 105, 460

    BACKGROUNDDIM_slider = Slider("BG Dim", 0.5, "General", "backgroundDim", 0, 1)
    BACKGROUNDDIM_slider.x, BACKGROUNDDIM_slider.y = 105, 520

    BACKGROUNDBLUR_slider = Slider("BG Blur", 2.5, "General", "backgroundBlur", 0, 10)
    BACKGROUNDBLUR_slider.x, BACKGROUNDBLUR_slider.y = 105, 580
    -- [[ CONTROLS TAB ]] --
    --[[ KB_Button = Sprite(0, 0,) ]]
    KB_Buttons = {}
    for i = 1, 10 do
        KB_Buttons[i] = Sprite(0, 0, "assets/images/ui/menu/options/kbKey.png")
    end
    -- [[ VIDEO TAB ]] --
    SCREENRESOLUTION_dropdown = Dropdown("Screen Resolution", {
        "640x360",
        "1280x720",
        "1664x936",
        "1920x1080"
    }, nil, "Video", "ScreenRes")
    SCREENRESOLUTION_dropdown.x, SCREENRESOLUTION_dropdown.y = 105, 345
    function SCREENRESOLUTION_dropdown:onSelect(option)
        local split = string.split(option, "x")
        local w, h = split[1], split[2]
        Settings.options["Video"].Width, Settings.options["Video"].Height = w, h
        love.window.setWindowSize(w, h)
        love.resize(w, h)
        Settings.options["Video"]["ScreenRes"] = w .. "x" .. h
    end
    VSYNC_switch = Switch("VSYNC (Not currently implemented.)", false, "Video", "VSYNC")
    VSYNC_switch.x, VSYNC_switch.y = 105, 400
    
    UNFOCUSEDFPS_switch = Switch("Unfocus FPS", false, "Video", "UnfocusedFPS")
    UNFOCUSEDFPS_switch.x, UNFOCUSEDFPS_switch.y = 105, 460

    SHADERS_switch = Switch("Shaders", false, "Video", "Shaders")
    SHADERS_switch.x, SHADERS_switch.y = 105, 520

    FPSOPTIONS_dropdown = Dropdown("FPS Cap", {
        "60",
        "120",
        "240",
        "500",
        "Unlimited"
    }, nil, "Video", "FPS")
    FPSOPTIONS_dropdown.x, FPSOPTIONS_dropdown.y = 105, 585
    -- [[ AUDIO TAB ]] --
    GLOBAL_slider = Slider("Global Vol", 50, "Audio", "global", 0, 100)
    GLOBAL_slider.x, GLOBAL_slider.y = 105, 340
    GLOBAL_slider.textXOffset = -15
    function GLOBAL_slider:onValueChanged(val)
        masterVolume = val
    end

    HITSOUND_slider = Slider("Hitsound Vol", 50, "Audio", "hitsound", 0, 100)
    HITSOUND_slider.x, HITSOUND_slider.y = 105, 400
    HITSOUND_slider.textXOffset = -15
    -- [[ ONLINE TAB ]] --
    -- [[ EDITOR TAB ]] --
    -- [[ IMPORT DATA TAB ]] --
    -- [[ SKINS TAB ]] --
    local allSkinNames = {}
    for _, skin in ipairs(skinList) do
        table.insert(allSkinNames, skin.name)
    end

    SKIN_dropdown = Dropdown("Skin", allSkinNames, nil, "Skin", "name")
    SKIN_dropdown.x, SKIN_dropdown.y = 105, 340
    function SKIN_dropdown:onSelect(option)
        for _, lskin in ipairs(skinList) do
            if lskin.name == option then
                Settings.options["Skin"] = {
                    name = lskin.name,
                    path = lskin.path,
                    scale = lskin.scale,
                    flippedEnd = lskin.flippedEnd
                }
                skin.name = lskin.name
                skin.path = lskin.path
                skin.scale = lskin.scale
                skin.flippedEnd = lskin.flippedEnd
                skinData = ini.parse(love.filesystem.read(skin:format("skin.ini")))
                skinData.Miscellaneous = skinData.Miscellaneous or skinData.Misceallaneous

                break
            end
        end
    end
    -- [[ MISCELLANEOUS TAB ]] --
    -- [[ ABOUT TAB ]] --
end

function OptionsMenu:update(dt)
    if tabs["update_"..curTab] then
        tabs["update_"..curTab](dt)
    end
end

function OptionsMenu:mousepressed(x, y, b)
    local mx, my = toGameScreen(x, y)

    local canc = Header:mousepressed(mx, my, b)
    if canc then return end

    for i, v in ipairs(buttons) do
        local width = fontWidth("defaultBoldX1.25", v.text)
        local x = 90 + (Inits.GameWidth-275)/#buttons*i - width/2
        local y = 120 + 25 - fontHeight("defaultBoldX1.25")/2
        if mx > x and mx < x + width and my > y and my < y + fontHeight("defaultBoldX1.25") then
            curTab = v.tabName
        end
    end

    if tabs["mousepressed_"..curTab] then
        tabs["mousepressed_"..curTab](mx, my, b)
    end
end

function OptionsMenu:mousemoved(x, y, dx, dy)
    local mx, my = toGameScreen(x, y)

    if tabs["mousemoved_"..curTab] then
        tabs["mousemoved_"..curTab](mx, my)
    end
end

function OptionsMenu:mousereleased(x, y, b)
    local mx, my = toGameScreen(x, y)

    if tabs["mousereleased_"..curTab] then
        tabs["mousereleased_"..curTab](mx, my)
    end
end

function OptionsMenu:keypressed(k)
    if tabs["keypressed_"..curTab] then
        tabs["keypressed_"..curTab](k)
    end
end

function OptionsMenu:textinput(t)
    if tabs["textinput_"..curTab] then
        tabs["textinput_"..curTab](string.lower(t))
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

    love.graphics.setColor(1,1,1)
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