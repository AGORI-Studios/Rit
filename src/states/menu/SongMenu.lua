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

local SongMenu = state()

local curMenu = "songSelect"
local now = os.time()

local curSongSelected = 1
local songSelectScrollOffset = 0

function SongMenu:enter()
    loadDefaultSongs()

    if discordRPC then
        discordRPC.presence = {
            details = "In the menu",
            state = "Selecting a song",
            largeImageKey = "totallyreallogo",
            largeImageText = "Rit" .. (__DEBUG__ and " DEBUG MODE" or "")
        }
    end
end

function SongMenu:selectSongDifficulty(_, chartVer)
    chartver = chartVer
    folderpath = songList[curSongSelected].folderPath
    songPath = songList[curSongSelected].path
    if chartver ~= "FNF" then
        states.game.Gameplay.chartVer = chartver
        states.game.Gameplay.songPath = songPath
        states.game.Gameplay.folderpath = folderpath
        switchState(states.game.Gameplay, 0.3, nil)
    end
end

function SongMenu:update(dt)
    if curMenu == "songSelect" then -- 41
        if input:pressed("up") then
            curSongSelected = curSongSelected - 1
            if curSongSelected < 1 then curSongSelected = #songList end

            songSelectScrollOffset = songSelectScrollOffset - fontHeight("default", songList[curSongSelected].title) + 6

            if songSelectScrollOffset < 0 then songSelectScrollOffset = 0 end

            if songSelectScrollOffset > (fontHeight("default", songList[curSongSelected].title) * (#songList - 12)) then
                songSelectScrollOffset = (fontHeight("default", songList[curSongSelected].title) * (#songList - 12))
            end
        elseif input:pressed("down") then
            curSongSelected = curSongSelected + 1
            if curSongSelected > #songList then curSongSelected = 1 end

            if curSongSelected > 41 then
                songSelectScrollOffset = songSelectScrollOffset + fontHeight("default", songList[curSongSelected].title) + 6
            end

            if songSelectScrollOffset < 0 then songSelectScrollOffset = 0 end

            if songSelectScrollOffset > (fontHeight("default", songList[curSongSelected].title) * (#songList - 12)) then
                songSelectScrollOffset = (fontHeight("default", songList[curSongSelected].title) * (#songList - 12))
            end
        end

        if input:pressed("confirm") then
            self:selectSongDifficulty(songList[curSongSelected].folderPath, songList[curSongSelected].type)
        end
    end
end

function SongMenu:draw()
    -- for all in songList 
    love.graphics.push()
    love.graphics.translate(0, -songSelectScrollOffset)
    for i, v in ipairs(songList) do
        if i == curSongSelected then
            love.graphics.setColor(1, 1, 1, 1)
        else
            love.graphics.setColor(0.5, 0.5, 0.5, 1)
        end
        love.graphics.print(v.title .. " - " .. v.difficultyName or "", 0, (i - 1) * (fontHeight("default", v.title)+6), 0, 2, 2)
    end
    love.graphics.pop()
end

return SongMenu