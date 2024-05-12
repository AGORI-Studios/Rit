---@class Header
---@diagnostic disable-next-line: assign-type-mismatch
local Header = Object:extend()

local function shakeObject(o)
    Timer.tween(0.05, o, {x = o.x - 5}, "linear", function()
        Timer.tween(0.05, o, {x = o.x + 10}, "linear", function()
            Timer.tween(0.05, o, {x = o.x - 5})
        end)
    end)
end

local bars, gear, home, import, barVert, menuBar

function Header:new()
    --[[ bars = Sprite(1830, 0, "assets/images/ui/buttons/barsHorizontal.png")
    gear = Sprite(0, 0, "assets/images/ui/buttons/gear.png")
    home = Sprite(80, 0, "assets/images/ui/buttons/home.png")
    import = Sprite(1760, -2, "assets/images/ui/buttons/import.png")
    barVert = Sprite(150, 0, "assets/images/ui/buttons/barIcon.png")
    menuBar = Sprite(0, 0, "assets/images/ui/menu/menuBar.png") ]]
    bars = HeaderButton(1830, 0, "assets/images/ui/buttons/barsHorizontal.png")
    gear = HeaderButton(0, 0, "assets/images/ui/buttons/gear.png")
    home = HeaderButton(80, 0, "assets/images/ui/buttons/home.png")
    import = HeaderButton(1760, -2, "assets/images/ui/buttons/import.png")
    barVert = Sprite(150, 0, "assets/images/ui/buttons/barIcon.png")
    menuBar = Sprite(0, 0, "assets/images/ui/menu/menuBar.png")
    menuBar.alpha = 0.75

    barVert:setScale(1.25)

    return self
end 

function Header:mousepressed(x, y, b)
    if gear:isHovered(x, y) then
        if love.system.getOS() ~= "Android" and love.system.getOS() ~= "iOS" then
            state.substate(substates.menu.Options)
        else
            shakeObject(gear)
        end
    elseif home:isHovered(x, y) then
        switchState(states.menu.StartMenu, 0.3)
        if networking.connected then
            networking.hub:publish({
                message = {
                    action = "updateServerInfo_FORCEREMOVEUSER",
                    id = networking.currentServerID,
                    user = {
                        steamID = tostring(SteamID),
                        name = tostring(SteamUserName)
                    }
                }
            })
        end
    elseif bars:isHovered(x, y) then
        shakeObject(bars)
    elseif import:isHovered(x, y) then
        if love.system.getOS() ~= "Android" and love.system.getOS() ~= "iOS" then
            switchState(states.screens.Importers.QuaverImportScreen, 0.3)
            if networking.connected then
                networking.hub:publish({
                    message = {
                        action = "updateServerInfo_FORCEREMOVEUSER",
                        id = networking.currentServerID,
                        user = {
                            steamID = tostring(SteamID),
                            name = tostring(SteamUserName)
                        }
                    }
                })
            end
        else
            shakeObject(import)
        end
    end
end

function Header:draw()
    menuBar:draw()
    gear:draw()
    home:draw()
    barVert:draw()
    bars:draw()
    import:draw()

    setFont("menuExtraBoldX2")
    love.graphics.setColor(203/255, 36/255, 145/255)
    love.graphics.printf(SteamUserName or localize.localize("Not Logged In"), 260, 12, 1080/2, "left", 0, 1, 1) -- Steam name
    love.graphics.setColor(1, 1, 1)
    -- draw SteamUserAvatarSmall to the right of the name
    if SteamUserAvatarSmall then
        love.graphics.draw(SteamUserAvatarSmall, 185, 10, 0, 2, 2)
    end

    setFont("default")
end

return Header:new()