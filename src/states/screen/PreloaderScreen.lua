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

local PreloaderScreen = state()
local doneLoading = false
local fade = 0

function PreloaderScreen:enter()
    threadLoader.newImage(self, "logo", "assets/images/ui/menu/logo.png")
    threadLoader.newImage(self, "songButton", "assets/images/ui/menu/songBtn.png")
    threadLoader.newImage(self, "statsBox", "assets/images/ui/menu/statsBox.png")
    threadLoader.newImage(self, "diffButton", "assets/images/ui/menu/diffBtn.png")
    threadLoader.newImage(self, "BGsongList", "assets/images/ui/menu/BGsongList.png")
    threadLoader.newImage(self, "barsHorizontal", "assets/images/ui/buttons/barsHorizontal.png")
    threadLoader.newImage(self, "gear", "assets/images/ui/buttons/gear.png")
    threadLoader.newImage(self, "home", "assets/images/ui/buttons/home.png")
    threadLoader.newImage(self, "categoryOpen", "assets/images/ui/menu/catOpen.png")
    threadLoader.newImage(self, "categoryClosed", "assets/images/ui/menu/catClosed.png")
    threadLoader.newImage(self, "twitterLogo", "assets/images/ui/icons/twitter.png")
    threadLoader.newImage(self, "kofiLogo", "assets/images/ui/icons/ko-fi.png")
    threadLoader.newImage(self, "discordLogo", "assets/images/ui/icons/discord.png")

    for i = 1, 5 do
        threadLoader.newImage(self, "BGball" .. i, "assets/images/ui/menu/BGball" .. i .. ".png")
    end

    for i = 1, 10 do
        -- 1k to 10k
        for j = 1, i do
            threadLoader.newImage(self, i .. "k_" .. j .. "_note", skin:format(skinData["NoteAssets"][tostring(i) .. "k_" .. j .. "_note"]))
            threadLoader.newImage(self, i .. "k_" .. j .. "_hold_end", skin:format(skinData["NoteAssets"][tostring(i) .. "k_" .. j .. "_hold_end"]))
            threadLoader.newImage(self, i .. "k_" .. j .. "_hold", skin:format(skinData["NoteAssets"][tostring(i) .. "k_" .. j .. "_hold"]))

            threadLoader.newImage(self, i .. "k_" .. j .. "_note", skin:format(skinData["NoteAssets"][tostring(i) .. "k_" .. j .. "_receptor_unpressed"]))
            threadLoader.newImage(self, i .. "k_" .. j .. "_hold_end", skin:format(skinData["NoteAssets"][tostring(i) .. "k_" .. j .. "_receptor_pressed"]))
        end
    end
    threadLoader.start(function()
        doneLoading = true
        Timer.after(1, function()
            fade = 0
            doneLoading = false
            state.switch(states.menu.StartMenu)
        end)
    end)
end

function PreloaderScreen:update(dt)
    --- out exponential easing
    if doneLoading then 
        fade = math.min(1, fade + dt * 2)
    end
end

function PreloaderScreen:draw()
    local percent = 0
    if threadLoader.resourceCount ~= 0 then percent = threadLoader.loadedCount / threadLoader.resourceCount end
    love.graphics.printf(
        (not doneLoading and "Precaching Resources..." or "Loaded!") ..
        "\n"..threadLoader.loadedCount.."/"..threadLoader.resourceCount..
        "\n"..math.floor(percent * 100).."%", 
        0, push:getHeight()/2-100, push:getWidth()/2, "center", 0, 2, 2
    )
    -- loading bar
    love.graphics.rectangle("fill", (push:getWidth()*0.05), push:getHeight()/2, (push:getWidth()*0.9) * percent, 50)

    -- flash
    love.graphics.setColor(0, 0, 0, fade)
    love.graphics.rectangle("fill", 0, 0, push:getWidth(), push:getHeight())
    love.graphics.setColor(1, 1, 1, 1)
end    

return PreloaderScreen