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
local function chooseSkin()
    -- get all folders in skin/
    if not love.filesystem.getInfo("skins") then
        love.filesystem.createDirectory("skins")
    end
    skins = {}
    for i, v in ipairs(love.filesystem.getDirectoryItems("defaultskins")) do
        if love.filesystem.getInfo("defaultskins/" .. v).type == "directory" and love.filesystem.getInfo("defaultskins/" .. v .. "/skin.json") then
            local folderPath = "defaultskins/" .. v
            -- get the skin.json
            local skinJson = json.decode(love.filesystem.read(folderPath .. "/skin.json"))
            -- get the skin name
            local skinName = skinJson["skin"]["name"]
            -- add it to the table
            curSkin = {
                name = skinName,
                folder = folderPath,
                json = skinJson
            }
            table.insert(skins, curSkin)
        end
    end
    for i, v in ipairs(love.filesystem.getDirectoryItems("skins")) do
        if love.filesystem.getInfo("skins/" .. v).type == "directory" and love.filesystem.getInfo("skins/" .. v .. "/skin.json") then
            local folderPath = "skins/" .. v
            -- get the skin.ini
            local skinJson = json.decode(love.filesystem.read(folderPath .. "/skin.json"))
            -- get the skin name
            local skinName = skinJson["skin"]["name"]
            -- add it to the table
            curSkin = {
                name = skinName,
                folder = folderPath,
                json = skinJson
            }
            table.insert(skins, curSkin)
        end
    end
end

local function selectSkin(skin)
    skin = skin or 1
    skin = skins[skin]
    skinJson = skin.json
    skinFolder = skin.folder
    skinName = skin.name
    choosingSkin = false
    choosingSong = true

    spectrumDivideColours = true
    DiffCalc.divideRatingColours = {}
    for i = 1, 7 do
        DiffCalc.divideRatingColours[i] = true
    end

    musicPos = 0
    settings.settings.skin = skinName
    state.switch(settingsMenu)
    dt = 0
    for i = 1, 4 do charthits[i] = {} end
end

function loadSkin(skinVer)
    notesize = skinJson["skin"]["note size"] or "1"
    notesize = tonumber(notesize)
    antiAliasing = skinJson["skin"]["antialiasing"]
    
    if antiAliasing then 
        love.graphics.setDefaultFilter("nearest", "nearest")
    else
        love.graphics.setDefaultFilter("linear", "linear")
    end
        
    if love.filesystem.getInfo(skinFolder .. "/" .. skinJson["skin"]["hitsound"]:gsub('"', "")) then
        hitsound = love.audio.newSource(skinFolder .. "/" .. skinJson["skin"]["hitsound"]:gsub('"', ""), "static")
    else
        hitsound = love.audio.newSource("defaultskins/skinThrowbacks/hitsound.wav", "static")
    end
    hitsound:setVolume(tonumber(skinJson["skin"]["hitsound volume"] or 1) * settings.settings.Audio.sfx)
    hitsoundCache = { -- allows for multiple hitsounds to be played at once
        hitsound:clone()
    }
    
    receptors = {}
    
    receptors[1] = {graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["left receptor unpressed"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["left receptor pressed"]:gsub('"', "")), 0}
    receptors[2] = {graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["down receptor unpressed"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["down receptor pressed"]:gsub('"', "")), 0}
    receptors[3] = {graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["up receptor unpressed"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["up receptor pressed"]:gsub('"', "")), 0}
    receptors[4] = {graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["right receptor unpressed"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["right receptor pressed"]:gsub('"', "")), 0}
    
    noteImgs = {
        {graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["left note"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["left note hold"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["left note hold end"]:gsub('"', ""))},
        {graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["down note"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["down note hold"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["down note hold end"]:gsub('"', ""))},
        {graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["up note"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["up note hold"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["up note hold end"]:gsub('"', ""))},
        {graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["right note"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["right note hold"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["right note hold end"]:gsub('"', ""))}
    }
        
    local judgementNames = {"MISS", "GOOD", "GREAT", "PERFECT", "MARVELLOUS"}

    judgementImages = {}
    -- when adding it to the table, make all the keys except the first one lowercase
    for i = 1, #judgementNames do
        if love.filesystem.getInfo(skinFolder .. "/" .. skinJson["skin"]["judgements"][judgementNames[i]]) then
            local lowerName = string.title(judgementNames[i])
            judgementImages[lowerName] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["judgements"][judgementNames[i]]:gsub('"', ""))
        else
            local lowerName = string.title(judgementNames[i])
            judgementImages[lowerName] = graphics.newImage("defaultskins/skinThrowbacks/judgements/" .. judgementNames[i] .. ".png")
        end
    end 

    healthBarColor = skinJson["skin"]["ui"]["healthBarColor"]
    uiTextColor = skinJson["skin"]["ui"]["uiTextColor"]
    timeBarColor = skinJson["skin"]["ui"]["timeBarColor"]

    if love.filesystem.getInfo(skinFolder .. "/" .. skinJson["skin"]["ui"]["menu"]["mainmenu"]["container"]) then
        emptyContainer = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["ui"]["menu"]["mainmenu"]["container"])
    else
        emptyContainer = graphics.newImage("defaultskins/skinThrowbacks/ui/Menu/MainMenu/container.png")
    end
    
    comboImages = {}
    
    for i = 1, 6 do
        comboImages[i] = {}
        for j = 0, 9 do
            if love.filesystem.getInfo(skinFolder .. "/" .. skinJson["skin"]["combo"]["COMBO" .. j]) then
                comboImages[i][j] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["combo"]["COMBO" .. j]:gsub('"', ""))
            else
                comboImages[i][j] = graphics.newImage("defaultskins/skinThrowbacks/combo/COMBO" .. j .. ".png")
            end
            comboImages[i][j].x = push.getWidth() / 2+325-275 + skinJson["skin"]["rating position"]["x"]
            comboImages[i][j].x = comboImages[i][j].x - (i - 1) * (comboImages[i][j]:getWidth() - 5) + 25
            comboImages[i][j].y = push.getHeight() / 2 + skinJson["skin"]["rating position"]["y"] + 50
        end
    end
    
    for k, v in pairs(judgementImages) do
        v.x = push.getWidth() / 2+325-275 + skinJson["skin"]["rating position"]["x"]
        v.y = push.getHeight() / 2 + skinJson["skin"]["rating position"]["y"]
    end
    
    love.graphics.setDefaultFilter("linear", "linear")
end

return {
    enter = function(self)
        choosingSkin = true
        choosingSong = false
        musicTimeDo = false
        curSkinSelected = 1
        now = os.time()
        presence = {
            state = "Picking a skin to use",
            largeImageKey = "totallyreallogo",
            largeImageText = "Rit"..(__DEBUG__ and " DEBUG MODE" or ""),
            startTimestamp = now
        }
        chooseSkin()
    end,

    update = function(self, dt)
        if input:pressed("up") then
            curSkinSelected = curSkinSelected - 1
            if curSkinSelected < 1 then
                curSkinSelected = #skins
            end
        elseif input:pressed("down") then
            curSkinSelected = curSkinSelected + 1
            if curSkinSelected > #skins then
                curSkinSelected = 1
            end
        end
        if input:pressed("confirm") then
            selectSkin(curSkinSelected)
        end
    end,

    wheelmoved = function(self, x, y)
        if y > 0 then
            curSkinSelected = curSkinSelected - 1
            if curSkinSelected < 1 then
                curSkinSelected = #skins
            end
        elseif y < 0 then
            curSkinSelected = curSkinSelected + 1
            if curSkinSelected > #skins then
                curSkinSelected = 1
            end
        end
    end,

    draw = function(self)
        for i, v in ipairs(skins) do
            if i == curSkinSelected then
                graphics.setColor(1, 1, 1)
            else
                graphics.setColor(0.5, 0.5, 0.5)
            end
            love.graphics.print(v.name, 0, i * 35, 0, 2, 2)
            graphics.setColor(1,1,1)
        end
    end
}