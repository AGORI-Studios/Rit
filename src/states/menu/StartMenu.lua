--[[----------------------------------------------------------------------------

This file is apart of Rit; a free and open sourced rhythm game made with LÖVE.

Copyright (C) 2023 GuglioIsStupid

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

------------------------------------------------------------------------------]]

local StartMenu = state()
local beat, time = 0, 0
local time2 = 0
local menuBPM = 120

local timers = {}

function StartMenu:enter()
    --logo = Image("assets/images/ui/menu/logo.png")
    logo = Sprite(0, 0, "assets/images/ui/menu/logo.png")
    logo:centerOrigin()

    twitterLogo = Sprite(1780, 950, "assets/images/ui/icons/twitter.png")
    kofiLogo = Sprite(1780, 825, "assets/images/ui/icons/ko-fi.png")
    discordLogo = Sprite(1650, 950, "assets/images/ui/icons/discord.png")

    twitterLogo:setScale(0.25)
    kofiLogo:setScale(0.25)
    discordLogo:setScale(0.25)

    logo.alignment = "center"

    logo.y = push.getHeight() / 1.45
    logo.x = push.getWidth() / 1.2
    
    if discordRPC then
        discordRPC.presence = {
            details = "In the menu",
            state = "",
            largeImageKey = "totallyreallogo",
            largeImageText = "Rit" .. (__DEBUG__ and " DEBUG MODE" or "")
        }
    end
end

function StartMenu:update(dt)
    time = time + 1000 * dt
    time2 = time2 + 1000 * dt

    if time > (60/menuBPM) * 1000 then
        local curBeat = math.floor((time2/1000) / (60/menuBPM))
        if curBeat % 2 == 0 then
            logo:setScale(1.05)
        end
        time = 0
    end

    local mx, my = love.mouse.getPosition()

    -- Logo parallax
    logo.x = push.getWidth() / 1.2 + (-mx / 50)
    logo.y = push.getHeight() / 1.45 + (-my / 50)

    if logo.scale.x > 1 then 
        logo:setScale(logo.scale.x - (dt * ((menuBPM/60))) * 0.1)
    end

    if input:pressed("confirm") then state.switch(states.menu.SongMenu) end
end

function StartMenu:mousepressed(x, y, b)
    local x, y = push.toGame(x, y)
    if b == 1 then
        if twitterLogo:isHovered(x, y) then
            love.system.openURL("https://twitter.com/GuglioIs2Stupid")
        elseif kofiLogo:isHovered(x, y) then
            love.system.openURL("https://ko-fi.com/guglioisstupid")
        elseif discordLogo:isHovered(x, y) then
            love.system.openURL("https://discord.gg/ehY5gMMPW8")
        end
    end
end

function StartMenu:draw()
    love.graphics.push()
        love.graphics.scale(0.35, 0.35)
        love.graphics.setColor(1, 1, 1)
        logo:draw()
    love.graphics.pop()
    twitterLogo:draw()
    kofiLogo:draw()
    discordLogo:draw()
end

return StartMenu