local Options = state()

local curOptionsTab = "General"

local tabs = {
    "General",
    "Keybinds"
}

-- TEMPORARY OPTIONS MENU

local tabsYOffset = 0
local settingsYOffset = 0
local reminder = false
local reminderFade = 0

function Options:enter()
    love.graphics.setLineWidth(3)
end

function Options:update(dt)
    reminderFade = reminderFade - dt
end

function Options:mousepressed(x, y, id)
    if id == 1 then
        local mx, my = push.toGame(x, y)
        if curOptionsTab == "General" then
            if mx >= 600 and mx <= 660 and my >= 120 and my <= 150 then
                Settings.options["General"].downscroll = not Settings.options["General"].downscroll
            end

            if mx >= 700 and mx <= 730 and my >= 156 and my <= 186 then
                Settings.options["General"].scrollspeed = Settings.options["General"].scrollspeed - 0.05
            elseif mx >= 740 and mx <= 770 and my >= 156 and my <= 186 then
                Settings.options["General"].scrollspeed = Settings.options["General"].scrollspeed + 0.05
            end

            Settings.options["General"].scrollspeed = math.clamp(Settings.options["General"].scrollspeed, 0.5, 10)
        end

        if mx >= 110 and mx <= 375 and my >= 205 and my <= 240+75 then
            reminderFade = 1
            love.system.openURL("file://" .. love.filesystem.getSaveDirectory() .. "/")
        end

        if mx >= push:getWidth()-200 and mx <= push:getWidth()-100 and my >= 100 and my <= 150 then
            state.killSubstate()
        end
    end
end

function Options:draw()
    love.graphics.setFont(Cache.members.font["defaultBold"])
    love.graphics.setColor(0,0,0,0.5)
    love.graphics.rectangle("fill",0,0,push:getWidth(),push:getHeight())
    love.graphics.setColor(1,1,1)
    love.graphics.print("Temporary Settings Menu", 300, 0, 0, 2, 2)
    love.graphics.setColor(0.25,0.25,0.25,1)
    love.graphics.rectangle("fill", 100, 100, push:getWidth()-200, push:getHeight()-200, 5, 5)
    love.graphics.setColor(0,0,0,1)
    love.graphics.line(400,100,400,push:getHeight()-100)
    love.graphics.setColor(1,1,1,1)

    -- tab buttons
    for i = 1, #tabs do
        love.graphics.setColor(0.5,0.5,0.5,1)
        love.graphics.rectangle("fill", 110, 110 + (95 * (i-1)) - tabsYOffset, 275, 75, 5, 5)

        love.graphics.setColor(0,0,0,1)
        love.graphics.print(tabs[i], 125, 125 + (95 * (i-1)) - tabsYOffset, 0, 2, 2)
    end

    love.graphics.setColor(1,1,1,1)

    -- downscroll option
    if curOptionsTab == "General" then
        love.graphics.print("Downscroll", 425, 115 - settingsYOffset, 0, 2, 2)

        if Settings.options["General"].downscroll then
            love.graphics.setColor(0,1,0)
        else
            love.graphics.setColor(1,0,0)
        end
        love.graphics.rectangle("fill", 600, 120, 60, 30, 5, 5)
        love.graphics.setColor(1,1,1)

        love.graphics.print("Scrollspeed\t" .. Settings.options["General"].scrollspeed, 425, 150 - settingsYOffset, 0, 2, 2)
        -- left and right buttons
        love.graphics.setColor(1,0,0)
        love.graphics.rectangle("fill", 700, 156, 30, 30, 5, 5)
        love.graphics.setColor(0,1,0)
        love.graphics.rectangle("fill", 740, 156, 30, 30, 5, 5)
    end
    love.graphics.setColor(1,1,1,reminderFade)
    love.graphics.printf("Please edit keybinds_config.ini to modify\nyour keybinds.", 0, push:getHeight()/2-100, push:getWidth()/2, "center", 0, 2, 2)
    love.graphics.setColor(1,1,1,1)

    love.graphics.setFont(Cache.members.font["default"])

    love.graphics.setColor(1,0,0)
    love.graphics.rectangle("fill", push:getWidth()-200, 100, 100, 50, 5, 5)
    love.graphics.setColor(1,1,1)
end

return Options