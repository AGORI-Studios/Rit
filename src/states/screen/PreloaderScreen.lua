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
local allNoteImgs = {}

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
            local inAllNoteImgsNOTE = false
            local inAllNoteImgsHOLD = false
            local inAllNoteImgsHOLD_END = false
            local inAllNoteImgsRECEPTOR_UNPRESSED = false
            local inAllNoteImgsRECEPTOR_PRESSED = false

            local nPath = skin:format(skinData["NoteAssets"][tostring(i) .. "k_" .. j .. "_note"])
            local hePath = skin:format(skinData["NoteAssets"][tostring(i) .. "k_" .. j .. "_hold_end"])
            local hPath = skin:format(skinData["NoteAssets"][tostring(i) .. "k_" .. j .. "_hold"])
            local rupPath = skin:format(skinData["NoteAssets"][tostring(i) .. "k_" .. j .. "_receptor_unpressed"])
            local rpPath = skin:format(skinData["NoteAssets"][tostring(i) .. "k_" .. j .. "_receptor_pressed"])

            for k, v in pairs(allNoteImgs) do
                if v == nPath then inAllNoteImgsNOTE = true end
                if v == hePath then inAllNoteImgsHOLD_END = true end
                if v == hPath then inAllNoteImgsHOLD = true end
                if v == rupPath then inAllNoteImgsRECEPTOR_UNPRESSED = true end
                if v == rpPath then inAllNoteImgsRECEPTOR_PRESSED = true end
            end

            if not inAllNoteImgsNOTE then
                table.insert(allNoteImgs, nPath)
                threadLoader.newImage(self, i .. "k_" .. j .. "_note", nPath)
            end
            if not inAllNoteImgsHOLD_END then
                table.insert(allNoteImgs, hePath)
                threadLoader.newImage(self, i .. "k_" .. j .. "_hold_end", hePath)
            end
            if not inAllNoteImgsHOLD then 
                table.insert(allNoteImgs, hPath)
                threadLoader.newImage(self, i .. "k_" .. j .. "_hold", hPath)
            end
            if not inAllNoteImgsRECEPTOR_UNPRESSED then
                table.insert(allNoteImgs, rupPath)
                threadLoader.newImage(self, i .. "k_" .. j .. "_note", rupPath)
            end
            if not inAllNoteImgsRECEPTOR_PRESSED then
                table.insert(allNoteImgs, rpPath)
                threadLoader.newImage(self, i .. "k_" .. j .. "_hold_end", rpPath)
            end
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
    if doneLoading then 
        -- exponential fade out
        fade = math.min(fade + dt * 1.82, 1)
    end
end

function PreloaderScreen:draw()
    local percent = 0
    if threadLoader.resourceCount ~= 0 then percent = threadLoader.loadedCount / threadLoader.resourceCount end
    love.graphics.printf(
        (not doneLoading and ("Precaching Resources..." .. threadLoader.loadedCount .. "/" .. threadLoader.resourceCount) 
            or "Loaded!") ..
        "\n"..math.floor(percent * 100).."%", 
        0,__inits.__GAME_HEIGHT/2-100,__inits.__GAME_WIDTH/2, "center", 0, 2, 2
    )
    -- loading bar
    love.graphics.rectangle("fill", (__inits.__GAME_WIDTH*0.05),__inits.__GAME_WIDTH/2, (__inits.__GAME_WIDTH*0.9) * percent, 50)

    -- flash
    love.graphics.setColor(0, 0, 0, fade)
    love.graphics.rectangle("fill", 0, 0,__inits.__GAME_WIDTH,__inits.__GAME_HEIGHT)
    love.graphics.setColor(1, 1, 1, 1)
end    

return PreloaderScreen