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

local function selectSkin(skin) -- TODO: seperate functions for different skin amounts
    skin = skin or 1
    skin = skins[skin]
    skinJson = skin.json
    skinFolder = skin.folder
    skinName = skin.name
    choosingSkin = false
    choosingSong = true

    musicPos = 0
    settings.skin = skinName
    state.switch(settingsMenu)
    dt = 0
    for i = 1, 4 do charthits[i] = {} end
end

function loadSkin(skinVer)
    if skinVer == "4k" then
        notesize = skinJson["skin"]["4k"]["note size"] or "1"
        notesize = tonumber(notesize)
        antiAliasing = skinJson["skin"]["4k"]["antialiasing"]
    
        if antiAliasing then 
            love.graphics.setDefaultFilter("nearest", "nearest")
        else
            love.graphics.setDefaultFilter("linear", "linear")
        end
        
        if love.filesystem.getInfo(skinFolder .. "/" .. skinJson["skin"]["4k"]["hitsound"]:gsub('"', "")) then
            hitsound = love.audio.newSource(skinFolder .. "/" .. skinJson["skin"]["4k"]["hitsound"]:gsub('"', ""), "static")
        else
            hitsound = love.audio.newSource("defaultskins/skinThrowbacks/hitsound.wav", "static")
        end
        hitsound:setVolume(tonumber(skinJson["skin"]["4k"]["hitsound volume"] or 1))
        hitsoundCache = { -- allows for multiple hitsounds to be played at once
            hitsound:clone()
        }
    
        receptors = {}
    
        receptors[1] = {graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["left receptor unpressed"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["left receptor pressed"]:gsub('"', "")), 0}
        receptors[2] = {graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["down receptor unpressed"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["down receptor pressed"]:gsub('"', "")), 0}
        receptors[3] = {graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["up receptor unpressed"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["up receptor pressed"]:gsub('"', "")), 0}
        receptors[4] = {graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["right receptor unpressed"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["right receptor pressed"]:gsub('"', "")), 0}
    
        noteImgs = {
            {graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["left note"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["left note hold"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["left note hold end"]:gsub('"', ""))},
            {graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["down note"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["down note hold"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["down note hold end"]:gsub('"', ""))},
            {graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["up note"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["up note hold"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["up note hold end"]:gsub('"', ""))},
            {graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["right note"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["right note hold"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["right note hold end"]:gsub('"', ""))}
        }
        
        local judgementNames = {"MISS", "GOOD", "GREAT", "PERFECT", "MARVELLOUS"}
        --[[
        judgementImages = { -- images for the judgement text
            ["Miss"] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["judgements"]["MISS"]:gsub('"', "")),
            ["Good"] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["judgements"]["GOOD"]:gsub('"', "")),
            ["Great"] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["judgements"]["GREAT"]:gsub('"', "")),
            ["Perfect"] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["judgements"]["PERFECT"]:gsub('"', "")),
            ["Marvellous"] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["judgements"]["MARVELLOUS"]:gsub('"', "")),
        }
        --]]
        judgementImages = {}
        -- when adding it to the table, make all the keys except the first one lowercase
        for i = 1, #judgementNames do
            if love.filesystem.getInfo(skinFolder .. "/" .. skinJson["skin"]["4k"]["judgements"][judgementNames[i]]) then
                local lowerName = string.title(judgementNames[i])
                judgementImages[lowerName] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["judgements"][judgementNames[i]]:gsub('"', ""))
            else
                local lowerName = string.title(judgementNames[i])
                judgementImages[lowerName] = graphics.newImage("defaultskins/skinThrowbacks/judgements/" .. judgementNames[i] .. ".png")
            end
        end 

        healthBarColor = skinJson["skin"]["4k"]["ui"]["healthBarColor"]
        uiTextColor = skinJson["skin"]["4k"]["ui"]["uiTextColor"]
        timeBarColor = skinJson["skin"]["4k"]["ui"]["timeBarColor"]
    
        comboImages = {}
    
        for i = 1, 6 do
            comboImages[i] = {}
            for j = 0, 9 do
                if love.filesystem.getInfo(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO" .. j]) then
                    comboImages[i][j] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO" .. j]:gsub('"', ""))
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
    elseif skinVer == "7k" then
        notesize = skinJson["skin"]["7k"]["note size"] or "1"
        notesize = tonumber(notesize)
        antiAliasing = skinJson["skin"]["7k"]["antialiasing"]

        if antiAliasing then 
            love.graphics.setDefaultFilter("nearest", "nearest")
        else
            love.graphics.setDefaultFilter("linear", "linear")
        end

        if love.filesystem.getInfo(skinFolder .. "/" .. skinJson["skin"]["4k"]["hitsound"]:gsub('"', "")) then
            hitsound = love.audio.newSource(skinFolder .. "/" .. skinJson["skin"]["4k"]["hitsound"]:gsub('"', ""), "static")
        else
            hitsound = love.audio.newSource("defaultskins/skinThrowbacks/hitsound.wav", "static")
        end
        hitsound:setVolume(tonumber(skinJson["skin"]["7k"]["hitsound volume"]))
        hitsoundCache = { -- allows for multiple hitsounds to be played at once
            hitsound:clone()
        }

        receptors = {}

        comboImages = {}

        receptors[1] = {graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["receptor 1 unpressed"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["receptor 1 pressed"]:gsub('"', "")), 0}
        receptors[2] = {graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["receptor 2 unpressed"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["receptor 2 pressed"]:gsub('"', "")), 0}
        receptors[3] = {graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["receptor 3 unpressed"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["receptor 3 pressed"]:gsub('"', "")), 0}
        receptors[4] = {graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["receptor 4 unpressed"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["receptor 4 pressed"]:gsub('"', "")), 0}
        receptors[5] = {graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["receptor 5 unpressed"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["receptor 5 pressed"]:gsub('"', "")), 0}
        receptors[6] = {graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["receptor 6 unpressed"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["receptor 6 pressed"]:gsub('"', "")), 0}
        receptors[7] = {graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["receptor 7 unpressed"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["receptor 7 pressed"]:gsub('"', "")), 0}

        noteImgs = {
            {graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["note 1"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["note 1 hold"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["note 1 hold end"]:gsub('"', ""))},
            {graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["note 2"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["note 2 hold"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["note 2 hold end"]:gsub('"', ""))},
            {graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["note 3"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["note 3 hold"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["note 3 hold end"]:gsub('"', ""))},
            {graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["note 4"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["note 4 hold"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["note 4 hold end"]:gsub('"', ""))},
            {graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["note 5"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["note 5 hold"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["note 5 hold end"]:gsub('"', ""))},
            {graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["note 6"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["note 6 hold"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["note 6 hold end"]:gsub('"', ""))},
            {graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["note 7"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["note 7 hold"]:gsub('"', "")), graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["note 7 hold end"]:gsub('"', ""))}
        }

        local judgementNames = {"MISS", "GOOD", "GREAT", "PERFECT", "MARVELLOUS"}
        --[[
        judgementImages = { -- images for the judgement text
            ["Miss"] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["judgements"]["MISS"]:gsub('"', "")),
            ["Good"] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["judgements"]["GOOD"]:gsub('"', "")),
            ["Great"] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["judgements"]["GREAT"]:gsub('"', "")),
            ["Perfect"] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["judgements"]["PERFECT"]:gsub('"', "")),
            ["Marvellous"] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["judgements"]["MARVELLOUS"]:gsub('"', "")),
        }
        --]]
        judgementImages = {}
        -- when adding it to the table, make all the keys except the first one lowercase
        for i = 1, #judgementNames do
            if love.filesystem.getInfo(skinFolder .. "/" .. skinJson["skin"]["4k"]["judgements"][judgementNames[i]]) then
                local lowerName = string.title(judgementNames[i])
                judgementImages[lowerName] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["judgements"][judgementNames[i]]:gsub('"', ""))
            else
                local lowerName = string.title(judgementNames[i])
                judgementImages[lowerName] = graphics.newImage("defaultskins/skinThrowbacks/judgements/" .. judgementNames[i] .. ".png")
            end
        end 

        comboImages = {}
    
        for i = 1, 6 do
            comboImages[i] = {}
            for j = 0, 9 do
                if love.filesystem.getInfo(skinFolder .. "/" .. skinJson["skin"]["7k"]["combo"]["COMBO" .. j]) then
                    comboImages[i][j] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["7k"]["combo"]["COMBO" .. j]:gsub('"', ""))
                else
                    comboImages[i][j] = graphics.newImage("defaultskins/skinThrowbacks/combo/COMBO" .. j .. ".png")
                end
                comboImages[i][j].x = push.getWidth() / 2+325-275 + skinJson["skin"]["rating position"]["x"]
                comboImages[i][j].x = comboImages[i][j].x - (i - 1) * (comboImages[i][j]:getWidth() - 5) + 25
                comboImages[i][j].y = push.getHeight() / 2 + skinJson["skin"]["rating position"]["y"] + 50
            end
        end
            
        healthBarColor = skinJson["skin"]["7k"]["ui"]["healthBarColor"]
        uiTextColor = skinJson["skin"]["7k"]["ui"]["uiTextColor"]
        timeBarColor = skinJson["skin"]["7k"]["ui"]["timeBarColor"]
    
        comboImages = {}
    
        for i = 1, 6 do
            comboImages[i] = {}
            for j = 0, 9 do
                if love.filesystem.getInfo(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO" .. j]) then
                    comboImages[i][j] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO" .. j]:gsub('"', ""))
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

        for i = 1, 7 do charthits[i] = {} end
    end
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