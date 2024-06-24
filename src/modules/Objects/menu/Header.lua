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

local showUserDropdown = false

function Header:new()
    bars = HeaderButton(1830, 0, "assets/images/ui/buttons/barsHorizontal.png")
    gear = HeaderButton(0, 0, "assets/images/ui/buttons/gear.png")
    home = HeaderButton(80, 0, "assets/images/ui/buttons/home.png")
    import = HeaderButton(1760, -2, "assets/images/ui/buttons/import.png")
    barVert = Sprite(150, 0, "assets/images/ui/buttons/barIcon.png")
    menuBar = Sprite(0, 0, "assets/images/ui/menu/menuBar.png")
    menuBar.alpha = 0.75

    barVert:setScale(1.25)

    self.userData = {
        OverallRating = 0,
        averageAccuracy = 0, -- actually stored as an altogether accuracy of ALL plays. We calculate the average on the fly
        totalScore = 0,
        plays = 0,
        totalHits = 0,

        wins = 0,
        losses = 0
    }

    return self
end

function Header:mousepressed(x, y, b)
    if gear:isHovered(x, y) then
        if love.system.getSystem() ~= "Mobile" then
           --switchState(states.menu.OptionsMenu, 0.3)
           state.substate(substates.menu.Options)
        else
            shakeObject(gear)
        end
        return true
    elseif home:isHovered(x, y) then
        switchState(states.menu.StartMenu, 0.3)
        if Steam then
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
        end
        return true
    elseif bars:isHovered(x, y) then
        shakeObject(bars)
        return true
    elseif import:isHovered(x, y) then
        if love.system.getSystem() ~= "Mobile" then
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

        return true
    else
        -- check if SteamUserAvatarSmall is clicked
        local s, w, h = 1, 50, 50
        if SteamUserAvatarMedium then
            s = 1
            w = SteamUserAvatarMedium:getWidth() * s
            h = SteamUserAvatarMedium:getHeight() * s
        end

        if x >= 185 and x <= 185 + w and y >= 10 and y <= 10 + h then
            showUserDropdown = not showUserDropdown
            return true
        end
    end

    if showUserDropdown then
        if x >= 170 and x <= 170 + 400 and y >= 75 and y <= 75 + 300 then
            print("IN BOUNDS")
            return true
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
    if SteamUserAvatarMedium then
        love.graphics.draw(SteamUserAvatarMedium, 185, 10, 0, 1, 1)
    end

    if showUserDropdown then
        love.graphics.setColor(0, 0, 0, 0.75)
        love.graphics.rectangle("fill", 185, 75, 400, 300)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", 185, 75, 400, 300)

        local lastFont = love.graphics.getFont()
        love.graphics.setFont(Cache.members.font["defaultBoldX1.5"])

        love.graphics.print("Stats for " .. (SteamUserName or "UNKNOWN (LOCAL)"), 200, 100)
        love.graphics.print("Overall Rating: " .. string.format("%.2f", self.userData.OverallRating), 200, 120)
        local acc = 0
        if self.userData.plays > 0 then
            acc = self.userData.averageAccuracy / self.userData.plays
        end
        love.graphics.print("Average Accuracy: " .. string.format("%.2f", acc) .. "%", 200, 140)
        love.graphics.print("Total Score: " .. math.floor(self.userData.totalScore), 200, 160)
        love.graphics.print("Plays: " .. self.userData.plays, 200, 180)
        love.graphics.print("Total Hits: " .. self.userData.totalHits, 200, 200)

        love.graphics.setFont(lastFont)
    end

    setFont("default")
end

return Header:new()