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
local allSettings

return {
    enter = function(self)
        allSettings = {
            "Game",
            "Graphics",
            "Audio"
        }

        gameSettings = {
            "downscroll",
            "underlay",
            "scroll speed",
            "scroll velocities",
            "start time",
            "note spacing",
            "autoplay",
            "audio offset",
            "lane cover",
            "skin"
        }
        graphicsSettings = {
            "width",
            "height",
            "fullscroll",
            "vsync"
        }
        audioSettings = {
            "master",
            "music",
            "sfx"
        }

        curSetting = 1
        curOption = ""

        love.keyboard.setKeyRepeat(true)
    end,

    update = function(self, dt)
        if input:pressed("down") then
            if curOption == "" then
                curSetting = curSetting + 1
                if curSetting > #allSettings then
                    curSetting = 1
                end
            elseif curOption == "Game" then
                curSetting = curSetting + 1
                if curSetting > #gameSettings then
                    curSetting = 1
                end
            elseif curOption == "Graphics" then
                curSetting = curSetting + 1
                if curSetting > #graphicsSettings then
                    curSetting = 1
                end
            elseif curOption == "Audio" then
                curSetting = curSetting + 1
                if curSetting > #audioSettings then
                    curSetting = 1
                end
            end
        elseif input:pressed("up") then
            if curOption == "" then
                curSetting = curSetting - 1
                if curSetting < 1 then
                    curSetting = #allSettings
                end
            elseif curOption == "Game" then
                curSetting = curSetting - 1
                if curSetting < 1 then
                    curSetting = #gameSettings
                end
            elseif curOption == "Graphics" then
                curSetting = curSetting - 1
                if curSetting < 1 then
                    curSetting = #graphicsSettings
                end
            elseif curOption == "Audio" then
                curSetting = curSetting - 1
                if curSetting < 1 then
                    curSetting = #audioSettings
                end
            end
        end

        if input:pressed("confirm") then 
            if curOption == "" then
                curOption = allSettings[curSetting]
                curSetting = 1
            elseif curOption == "Game" then
                -- if the value is a boolean, then toggle it
                if type(settings.settings[curOption][gameSettings[curSetting]]) == "boolean" then
                    settings.settings[curOption][gameSettings[curSetting]] = not settings.settings[curOption][gameSettings[curSetting]]
                end
                if gameSettings[curSetting] == "skin" then
                    state.switch(skinSelect)
                end
            elseif curOption == "Graphics" then
                if type(settings.settings[curOption][graphicsSettings[curSetting]]) == "boolean" then
                    settings.settings[curOption][graphicsSettings[curSetting]] = not settings.settings[curOption][graphicsSettings[curSetting]]
                end
            elseif curOption == "Audio" then
                if type(settings.settings[curOption][audioSettings[curSetting]]) == "boolean" then
                    settings.settings[curOption][audioSettings[curSetting]] = not settings.settings[curOption][audioSettings[curSetting]]
                end
            end
        elseif input:pressed("left") then
            if curOption == "Game" then
                if type(settings.settings[curOption][gameSettings[curSetting]]) == "number" then
                    settings.settings[curOption][gameSettings[curSetting]] = settings.settings[curOption][gameSettings[curSetting]] - (
                        gameSettings[curSetting] == "scroll speed" and 1
                        or gameSettings[curSetting] == "lane cover" and 0.01
                        or 1
                    )
                end
            elseif curOption == "Graphics" then
                if type(settings.settings[curOption][graphicsSettings[curSetting]]) == "number" then
                    settings.settings[curOption][graphicsSettings[curSetting]] = settings.settings[curOption][graphicsSettings[curSetting]] - 1
                end
            elseif curOption == "Audio" then
                if type(settings.settings[curOption][audioSettings[curSetting]]) == "number" then
                    settings.settings[curOption][audioSettings[curSetting]] = settings.settings[curOption][audioSettings[curSetting]] - 0.1
                end
            end
        elseif input:pressed("right") then
            if curOption == "Game" then
                if type(settings.settings[curOption][gameSettings[curSetting]]) == "number" then
                    settings.settings[curOption][gameSettings[curSetting]] = settings.settings[curOption][gameSettings[curSetting]] + (
                        gameSettings[curSetting] == "scroll speed" and 1
                        or gameSettings[curSetting] == "lane cover" and 0.01
                        or 1
                    )
                end
            elseif curOption == "Graphics" then
                if type(settings.settings[curOption][graphicsSettings[curSetting]]) == "number" then
                    settings.settings[curOption][graphicsSettings[curSetting]] = settings.settings[curOption][graphicsSettings[curSetting]] + 1
                end
            elseif curOption == "Audio" then
                if type(settings.settings[curOption][audioSettings[curSetting]]) == "number" then
                    settings.settings[curOption][audioSettings[curSetting]] = settings.settings[curOption][audioSettings[curSetting]] + 0.1
                end
            end

        elseif input:pressed("back") then
            if curOption == "" then
                state.switch(startMenu)
            else
                curOption = ""
            end
        end

        -- go through all possible settings, if its less than 0 then set it to 0
        for i=1,#allSettings do
            for j=1,#gameSettings do
                if type(settings.settings[allSettings[i]][gameSettings[j]]) == "number" then
                    if settings.settings[allSettings[i]][gameSettings[j]] < 0.0001 then
                        settings.settings[allSettings[i]][gameSettings[j]] = 0
                    end
                end
            end
            for j=1,#graphicsSettings do
                if type(settings.settings[allSettings[i]][graphicsSettings[j]]) == "number" then
                    if settings.settings[allSettings[i]][graphicsSettings[j]] < 0.0001 then
                        settings.settings[allSettings[i]][graphicsSettings[j]] = 0
                    end
                end
            end
            for j=1,#audioSettings do
                if type(settings.settings[allSettings[i]][audioSettings[j]]) == "number" then
                    if settings.settings[allSettings[i]][audioSettings[j]] < 0.0001 then
                        settings.settings[allSettings[i]][audioSettings[j]] = 0
                    end
                end
            end
        end
    end,

    draw = function(self)
        love.graphics.scale(2,2)
        if curOption == "" then
            love.graphics.print("Settings", 10, 10)
            for i=1,#allSettings do
                if i == curSetting then
                    love.graphics.setColor(1, 0, 0)
                else
                    love.graphics.setColor(1, 1, 1)
                end
                love.graphics.print(allSettings[i]:cap(), 10, 10 + (i * 20))
            end
        elseif curOption == "Game" then
            love.graphics.print("Game Settings", 10, 10)
            for i=1,#gameSettings do
                if i == curSetting then
                    love.graphics.setColor(1, 0, 0)
                else
                    love.graphics.setColor(1, 1, 1)
                end
                if gameSettings[i] ~= "lane cover" then
                    love.graphics.print(gameSettings[i]:cap() .. (gameSettings[i] ~= "skin" and ": " .. tostring(settings.settings[curOption][gameSettings[i]]) or ""), 10, 10 + (i * 20))
                else
                    love.graphics.print(gameSettings[i]:cap() .. (gameSettings[i] ~= "skin" and ": " .. tostring(settings.settings[curOption][gameSettings[i]]*100) .. "%" or ""), 10, 10 + (i * 20))
                end
            end
        elseif curOption == "Graphics" then
            love.graphics.print("Graphics Settings", 10, 10)
            for i=1,#graphicsSettings do
                if i == curSetting then
                    love.graphics.setColor(1, 0, 0)
                else
                    love.graphics.setColor(1, 1, 1)
                end
                love.graphics.print(graphicsSettings[i]:cap() .. ": " .. tostring(settings.settings[curOption][graphicsSettings[i]]), 10, 10 + (i * 20))
            end
        elseif curOption == "Audio" then
            love.graphics.print("Audio Settings", 10, 10)
            for i=1,#audioSettings do
                if i == curSetting then
                    love.graphics.setColor(1, 0, 0)
                else
                    love.graphics.setColor(1, 1, 1)
                end
                love.graphics.print(audioSettings[i]:cap() .. ": " .. tostring(settings.settings[curOption][audioSettings[i]]), 10, 10 + (i * 20))
            end
        end
        love.graphics.setColor(1, 1, 1)
    end,

    leave = function()
        settings.saveSettings()
        

        speed = settings.settings.Game["scroll speed"] or 1
        speedLane = {}
        for i = 1, 4 do
            speedLane[i] = speed
        end

        love.keyboard.setKeyRepeat(false)
    end
}