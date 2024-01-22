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

    mainframe:SetName("Options")
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

        -- List for Settings.options["General"].skin (has skin.skins)
        local skinCollapse = loveframes.Create("collapsiblecategory", settings)
        skinCollapse:SetPos(10, 70)
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
        for i, v in ipairs(skinList) do
            local skinButton = loveframes.Create("button")
            skinButton:SetText(v.name)
            skinButton.OnClick = function()
                Settings.options["General"].skin = v.name
                skin.name = v.name
                skin.path = v.path
            end
            skin_1:AddItem(skinButton)
        end
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
end

function Options:mousepressed(x, y, id)
    loveframes.mousepressed(x, y, id)
end

function Options:mousereleased(x, y, id)
    loveframes.mousereleased(x, y, id)
end

function Options:draw()
    loveframes.draw()
end

return Options