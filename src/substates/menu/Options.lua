local Options = state()

local curOptionsTab = "General"

local tabs = {
    "General",
    "Keybinds"
}
local tabButtons = {}
local tabFrames = {}

local loveframes = require("lib.loveframes")
-- TEMPORARY OPTIONS MENU

local tabsYOffset = 0
local settingsYOffset = 0
local reminder = false
local reminderFade = 0

local mainframe

function Options:enter()
    -- if loveframes is already closed, respawn it
    if not loveframes.state then
        loveframes = require("lib.LoveFrames")
    end

    local mainframe = loveframes.Create("frame")

    mainframe:SetName("Options | SUBJECT TO CHANGE. TEMPORARY PLACEHOLDER.")
    mainframe:SetSize(1720, 880)
    mainframe:SetPos(100, 100)

    local sidebar = loveframes.Create("panel", mainframe)
    sidebar:SetPos(0, 25)
    sidebar:SetSize(300, 855)

    for i, v in ipairs(tabs) do
        local tab = loveframes.Create("button", sidebar)
        tab:SetPos(0, 50 * (i-1))
        tab:SetSize(300, 50)
        tab:SetText(v)
        tab.groupIndex = 1
        tab._index = i
        tab.OnClick = function()
            
        end
        table.insert(tabButtons, tab)
    end
    tabButtons[1]:OnClick()
    tabButtons[1].checked = true

    local settings = loveframes.Create("panel", mainframe)
    settings:SetPos(300, 25)
    settings:SetSize(1420, 855)

    local general = loveframes.Create("panel", settings)
    general:SetPos(0, 0)
    general:SetSize(1420, 855)

    local keybinds = loveframes.Create("panel", settings)
    keybinds:SetPos(0, 0)
    keybinds:SetSize(1420, 855)

    table.insert(tabFrames, general)
    table.insert(tabFrames, keybinds)

    function createGeneralTab()
        -- create a checkbox button for Settings.options["General"].downscroll
        local downscroll = loveframes.Create("checkbox", settings)
        downscroll:SetPos(10, 10)
        downscroll:SetText("Downscroll")
        downscroll:SetChecked(Settings.options["General"].downscroll)
        downscroll.OnChanged = function(object, checked)
            Settings.options["General"].downscroll = checked
        end

        -- numberbox for Settings.options["General"].scrollspeed
        local scrollspeed = loveframes.Create("numberbox", settings)
        scrollspeed:SetPos(10, 40)
        scrollspeed:SetSize(100, 25)
        scrollspeed:SetMinMax(1, 20)
        scrollspeed:SetIncreaseAmount(0.1)
        scrollspeed:SetDecreaseAmount(0.1)
        scrollspeed:SetDecimals(1)
        scrollspeed:SetValue(Settings.options["General"].scrollspeed)
        scrollspeed.OnValueChanged = function(object, value)
            Settings.options["General"].scrollspeed = value
        end

        local scrollspeedLabel = loveframes.Create("text", settings)
        scrollspeedLabel:SetPos(120, 40)
        scrollspeedLabel:SetText("Scrollspeed")
        scrollspeedLabel:SetFont(Cache.members.font["default"])
        scrollspeedLabel:SetSize(100, 25)

        local hitsoundVolume = loveframes.Create("numberbox", settings)
        hitsoundVolume:SetPos(10, 70)
        hitsoundVolume:SetSize(100, 25)
        hitsoundVolume:SetMinMax(0, 1)
        hitsoundVolume:SetIncreaseAmount(0.1)
        hitsoundVolume:SetDecreaseAmount(0.1)
        hitsoundVolume:SetDecimals(1)
        hitsoundVolume:SetValue(Settings.options["General"].hitsoundVolume)
        hitsoundVolume.OnValueChanged = function(object, value)
            Settings.options["General"].hitsoundVolume = value
        end

        local hitsoundVolumeLabel = loveframes.Create("text", settings)
        hitsoundVolumeLabel:SetPos(120, 70)
        hitsoundVolumeLabel:SetText("Hitsound Volume")
        hitsoundVolumeLabel:SetFont(Cache.members.font["default"])
        hitsoundVolumeLabel:SetSize(200, 25)

        local noScrollVelocity = loveframes.Create("checkbox", settings)
        noScrollVelocity:SetPos(10, 110)
        noScrollVelocity:SetText("No Scroll Velocity")
        noScrollVelocity:SetChecked(Settings.options["General"].noScrollVelocity)
        noScrollVelocity.OnChanged = function(object, checked)
            Settings.options["General"].noScrollVelocity = checked
        end

        if doAprilFools then
            -- setting for Settings.options["Events"].aprilFools
            local aprilFools = loveframes.Create("checkbox", settings)
            aprilFools:SetPos(10, 140)
            aprilFools:SetText("April Fools")
            aprilFools:SetChecked(Settings.options["Events"].aprilFools)
            aprilFools.OnChanged = function(object, checked)
                Settings.options["Events"].aprilFools = checked
            end
        end

        -- List for Settings.options["Skin"] (has skin.skins)
        local skinCollapse = loveframes.Create("collapsiblecategory", settings)
        skinCollapse:SetPos(10, 140 + (doAprilFools and 30 or 0))
        skinCollapse:SetSize(100, 100)
        skinCollapse:SetText("Skin")

        local skin_1 = loveframes.Create("list")
        skin_1:SetPos(0, 25)
        skin_1:SetSize(100, 100)
        skin_1:SetPadding(5)
        skin_1:SetSpacing(5)
        skinCollapse:SetObject(skin_1)
        -- set size depending on how many skins there are
        local skinListCount = skin:getSkinCount()
        skin_1:SetSize(100, 25 + (skinListCount * 30))

        local skinList_2 = {}
        for _, v in ipairs(skinList) do
            local skinButton = loveframes.Create("button")
            skinButton:SetText(v.name)
            skinButton.OnClick = function()
                Settings.options["Skin"] = {
                    name = v.name,
                    path = v.path, 
                    scale = v.scale,
                    flippedEnd = v.flippedEnd
                }
                skin.name = v.name
                skin.path = v.path
                skin.scale = v.scale
                skin.flippedEnd = v.flippedEnd
            end
            skin_1:AddItem(skinButton)
        end

        -- backgroundDim and backgroundBlur
        local backgroundDim = loveframes.Create("numberbox", settings)
        backgroundDim:SetPos(10, 270 + (doAprilFools and 30 or 0))
        backgroundDim:SetSize(100, 25)
        backgroundDim:SetMinMax(0, 1)
        backgroundDim:SetIncreaseAmount(0.1)
        backgroundDim:SetDecreaseAmount(0.1)
        backgroundDim:SetDecimals(1)
        backgroundDim:SetValue(Settings.options["General"].backgroundDim)
        backgroundDim.OnValueChanged = function(object, value)
            Settings.options["General"].backgroundDim = value
        end

        local backgroundDimLabel = loveframes.Create("text", settings)
        backgroundDimLabel:SetPos(120, 270 + (doAprilFools and 30 or 0))
        backgroundDimLabel:SetText("Background Dim")
        backgroundDimLabel:SetFont(Cache.members.font["default"])
        backgroundDimLabel:SetSize(200, 25)
        
        local backgroundBlur = loveframes.Create("numberbox", settings)
        backgroundBlur:SetPos(10, 300 + (doAprilFools and 30 or 0))
        backgroundBlur:SetSize(100, 25)
        backgroundBlur:SetMinMax(0, 1)
        backgroundBlur:SetIncreaseAmount(0.1)
        backgroundBlur:SetDecreaseAmount(0.1)
        backgroundBlur:SetDecimals(1)
        backgroundBlur:SetValue(Settings.options["General"].backgroundBlur)
        backgroundBlur.OnValueChanged = function(object, value)
            Settings.options["General"].backgroundBlur = value
        end

        local backgroundBlurLabel = loveframes.Create("text", settings) 
        backgroundBlurLabel:SetPos(120, 300 + (doAprilFools and 30 or 0))
        backgroundBlurLabel:SetText("Background Blur")
        backgroundBlurLabel:SetFont(Cache.members.font["default"])
        backgroundBlurLabel:SetSize(200, 25)

        local localeLabel = loveframes.Create("text", settings)
        localeLabel:SetPos(10, 330 + (doAprilFools and 30 or 0))
        localeLabel:SetText("Locale")
        localeLabel:SetFont(Cache.members.font["default"])
        localeLabel:SetSize(100, 25)

        local allLocales = love.filesystem.getDirectoryItems("locale/")
        local localeList = {}
        for _, v in ipairs(allLocales) do
            if v:sub(-5) == ".locale.json" then
                table.insert(localeList, v:sub(1, -6))
            end
        end

        local localeCollapse = loveframes.Create("collapsiblecategory", settings)
        localeCollapse:SetPos(10, 360 + (doAprilFools and 30 or 0))
        localeCollapse:SetSize(100, 100)
        localeCollapse:SetText("Locale")

        local locale_1 = loveframes.Create("list")
        locale_1:SetPos(0, 25)
        locale_1:SetSize(100, 100)
        locale_1:SetPadding(5)
        locale_1:SetSpacing(5)
        localeCollapse:SetObject(locale_1)
        -- set size depending on how many locales there are
        locale_1:SetSize(100, 25 + (#localeList * 30))

        local localeList_2 = {}
        for _, v in ipairs(localeList) do
            local localeButton = loveframes.Create("button")
            localeButton:SetText(v)
            localeButton.OnClick = function()
                Settings.options["General"].language = v
                localize.loadLocale(v)
            end
            locale_1:AddItem(localeButton)
        end

        -- noteScale and columnSpacing
        local noteSize = loveframes.Create("numberbox", settings)
        noteSize:SetPos(10, 390 + (doAprilFools and 30 or 0))
        noteSize:SetSize(100, 25)
        noteSize:SetMinMax(0.1, 2)
        noteSize:SetIncreaseAmount(0.1)
        noteSize:SetDecreaseAmount(0.1)
        noteSize:SetDecimals(1)
        noteSize:SetValue(Settings.options["General"].noteSize)
        noteSize.OnValueChanged = function(object, value)
            Settings.options["General"].noteSize = value
        end
        
        local noteSizeLabel = loveframes.Create("text", settings)
        noteSizeLabel:SetPos(120, 390 + (doAprilFools and 30 or 0))
        noteSizeLabel:SetText("Note Size")
        noteSizeLabel:SetFont(Cache.members.font["default"])
        noteSizeLabel:SetSize(100, 25)

        local columnSpacing = loveframes.Create("numberbox", settings)
        columnSpacing:SetPos(10, 420 + (doAprilFools and 30 or 0))
        columnSpacing:SetSize(100, 25)
        columnSpacing:SetMinMax(0, 100)
        columnSpacing:SetIncreaseAmount(1)
        columnSpacing:SetDecreaseAmount(1)
        columnSpacing:SetDecimals(0)
        columnSpacing:SetValue(Settings.options["General"].columnSpacing)
        columnSpacing.OnValueChanged = function(object, value)
            Settings.options["General"].columnSpacing = value
        end

        local columnSpacingLabel = loveframes.Create("text", settings)
        columnSpacingLabel:SetPos(120, 420 + (doAprilFools and 30 or 0))
        columnSpacingLabel:SetText("Column Spacing")
        columnSpacingLabel:SetFont(Cache.members.font["default"])
        columnSpacingLabel:SetSize(100, 200)
    end

    function createKeybindsTab()
        -- nothing. Just display "WIP"
        local wip = loveframes.Create("text", settings)
        wip:SetPos(10, 10)
        wip:SetText("WIP")
        wip:SetFont(Cache.members.font["default"])
        wip:SetSize(100, 25)

    end

    createGeneralTab()

    -- when loveframes is quit, kill the substate
    function loveframes.quit()
        state.killSubstate()
    end
end

function Options:update(dt)
    loveframes.update(dt)

    if input:pressed("back") then
        state.killSubstate()
    end
end

function Options:mousepressed(x, y, id)
    loveframes.mousepressed(x, y, id)
end

function Options:touchpressed(id, x, y, dx, dy, pressure)
    loveframes.mousepressed(x, y, 1) -- left click "simulation"
end

function Options:mousereleased(x, y, id)
    loveframes.mousereleased(x, y, id)
end

function Options:textinput(text)
    loveframes.textinput(text)
end

function Options:keypressed(key)
    loveframes.keypressed(key)
end

function Options:keyreleased(key)
    loveframes.keyreleased(key)
end

function Options:draw()
    loveframes.draw()
end

function Options:exit()
end

return Options