local function chooseSkin()
    -- get all folders in skin/
    if not love.filesystem.getInfo("skins") then
        love.filesystem.createDirectory("skins")
    end
    skins = {}
    for i, v in ipairs(love.filesystem.getDirectoryItems("defaultskins")) do
        if love.filesystem.getInfo("defaultskins/" .. v).type == "directory" then
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
        if love.filesystem.getInfo("skins/" .. v).type == "directory" then
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

local function selectSkin(skin) -- TODO: optimize skin loading
    skin = skin or 1
    skin = skins[skin]
    skinJson = skin.json
    skinFolder = skin.folder
    skinName = skin.name
    notesize = skinJson["skin"]["4k"]["note size"]
    notesize = tonumber(notesize)
    antiAliasing = skinJson["skin"]["4k"]["antialiasing"]

    if antiAliasing then 
        love.graphics.setDefaultFilter("nearest", "nearest")
    else
        love.graphics.setDefaultFilter("linear", "linear")
    end
    
    hitsound = love.audio.newSource(skinFolder .. "/" .. skinJson["skin"]["4k"]["hitsound"]:gsub('"', ""), "static")
    hitsound:setVolume(tonumber(skinJson["skin"]["4k"]["hitsound volume"]))
    hitsoundCache = { -- allows for multiple hitsounds to be played at once
        hitsound:clone()
    }

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

    judgementImages = { -- images for the judgement text
        ["Miss"] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["judgements"]["MISS"]:gsub('"', "")),
        ["Good"] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["judgements"]["GOOD"]:gsub('"', "")),
        ["Great"] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["judgements"]["GREAT"]:gsub('"', "")),
        ["Perfect"] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["judgements"]["PERFECT"]:gsub('"', "")),
        ["Marvellous"] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["judgements"]["MARVELLOUS"]:gsub('"', "")),
    }

    comboImages = {}

    --[[
    comboImages = { -- need to optimize this too lmfaoooo
        [1] = {
            [0] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO0"]:gsub('"', "")),
            [1] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO1"]:gsub('"', "")),
            [2] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO2"]:gsub('"', "")),
            [3] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO3"]:gsub('"', "")),
            [4] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO4"]:gsub('"', "")),
            [5] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO5"]:gsub('"', "")),
            [6] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO6"]:gsub('"', "")),
            [7] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO7"]:gsub('"', "")),
            [8] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO8"]:gsub('"', "")),
            [9] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO9"]:gsub('"', ""))
        },
        [2] = {
            [0] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO0"]:gsub('"', "")),
            [1] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO1"]:gsub('"', "")),
            [2] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO2"]:gsub('"', "")),
            [3] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO3"]:gsub('"', "")),
            [4] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO4"]:gsub('"', "")),
            [5] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO5"]:gsub('"', "")),
            [6] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO6"]:gsub('"', "")),
            [7] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO7"]:gsub('"', "")),
            [8] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO8"]:gsub('"', "")),
            [9] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO9"]:gsub('"', ""))
        },
        [3] = {
            [0] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO0"]:gsub('"', "")),
            [1] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO1"]:gsub('"', "")),
            [2] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO2"]:gsub('"', "")),
            [3] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO3"]:gsub('"', "")),
            [4] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO4"]:gsub('"', "")),
            [5] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO5"]:gsub('"', "")),
            [6] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO6"]:gsub('"', "")),
            [7] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO7"]:gsub('"', "")),
            [8] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO8"]:gsub('"', "")),
            [9] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO9"]:gsub('"', ""))
        },
        [4] = {
            [0] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO0"]:gsub('"', "")),
            [1] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO1"]:gsub('"', "")),
            [2] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO2"]:gsub('"', "")),
            [3] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO3"]:gsub('"', "")),
            [4] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO4"]:gsub('"', "")),
            [5] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO5"]:gsub('"', "")),
            [6] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO6"]:gsub('"', "")),
            [7] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO7"]:gsub('"', "")),
            [8] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO8"]:gsub('"', "")),
            [9] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO9"]:gsub('"', ""))
        }
    --]]

    for i = 1, 6 do
        comboImages[i] = {}
        for j = 0, 9 do
            comboImages[i][j] = graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO" .. j]:gsub('"', ""))
        end
    end

    love.graphics.setDefaultFilter("linear", "linear")
    choosingSkin = false
    choosingSong = true

    musicPos = 0
    --quaverLoader.load("chart.qua")
    state.switch(songSelect)
    dt = 0
end

return {
    enter = function(self)
        choosingSkin = true
        choosingSong = false
        musicTimeDo = false
        curSkinSelected = 1
        now = os.time()
        chooseSkin()
    end,

    update = function(self, dt)
        presence = {
            details = nil, 
            state = "Picking a skin to use",
            largeImageKey = "totallyreallogo",
            largeImageText = "Rit",
            startTimestamp = now
        }
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

    draw = function(self)
        for i, v in ipairs(skins) do
            if i == curSkinSelected then
                love.graphics.setColor(1, 1, 1)
            else
                love.graphics.setColor(0.5, 0.5, 0.5)
            end
            love.graphics.print(v.name, 0, i * 35, 0, 2, 2)
            love.graphics.setColor(1,1,1)
        end
    end
}