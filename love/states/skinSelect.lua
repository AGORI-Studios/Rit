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

    recepterUNPRESSED1 = love.image.newImageData(skinFolder .. "/" .. skinJson["skin"]["4k"]["left receptor unpressed"]:gsub('"', ""))
    recepterPRESSED1 = love.image.newImageData(skinFolder .. "/" .. skinJson["skin"]["4k"]["left receptor pressed"]:gsub('"', ""))

    recepterUNPRESSED2 = love.image.newImageData(skinFolder .. "/" .. skinJson["skin"]["4k"]["down receptor unpressed"]:gsub('"', ""))
    recepterPRESSED2 = love.image.newImageData(skinFolder .. "/" .. skinJson["skin"]["4k"]["down receptor pressed"]:gsub('"', ""))

    recepterUNPRESSED3 = love.image.newImageData(skinFolder .. "/" .. skinJson["skin"]["4k"]["up receptor unpressed"]:gsub('"', ""))
    recepterPRESSED3 = love.image.newImageData(skinFolder .. "/" .. skinJson["skin"]["4k"]["up receptor pressed"]:gsub('"', ""))

    recepterUNPRESSED4 = love.image.newImageData(skinFolder .. "/" .. skinJson["skin"]["4k"]["right receptor unpressed"]:gsub('"', ""))
    recepterPRESSED4 = love.image.newImageData(skinFolder .. "/" .. skinJson["skin"]["4k"]["right receptor pressed"]:gsub('"', ""))

    note1NORMAL = love.image.newImageData(skinFolder .. "/" .. skinJson["skin"]["4k"]["left note"]:gsub('"', ""))
    note1HOLD = love.image.newImageData(skinFolder .. "/" .. skinJson["skin"]["4k"]["left note hold"]:gsub('"', ""))
    note1END = love.image.newImageData(skinFolder .. "/" .. skinJson["skin"]["4k"]["left note hold end"]:gsub('"', ""))
    
    note2NORMAL = love.image.newImageData(skinFolder .. "/" .. skinJson["skin"]["4k"]["down note"]:gsub('"', ""))
    note2HOLD = love.image.newImageData(skinFolder .. "/" .. skinJson["skin"]["4k"]["down note hold"]:gsub('"', ""))
    note2END = love.image.newImageData(skinFolder .. "/" .. skinJson["skin"]["4k"]["down note hold end"]:gsub('"', ""))

    note3NORMAL = love.image.newImageData(skinFolder .. "/" .. skinJson["skin"]["4k"]["up note"]:gsub('"', ""))
    note3HOLD = love.image.newImageData(skinFolder .. "/" .. skinJson["skin"]["4k"]["up note hold"]:gsub('"', ""))
    note3END = love.image.newImageData(skinFolder .. "/" .. skinJson["skin"]["4k"]["up note hold end"]:gsub('"', ""))

    note4NORMAL = love.image.newImageData(skinFolder .. "/" .. skinJson["skin"]["4k"]["right note"]:gsub('"', ""))
    note4HOLD = love.image.newImageData(skinFolder .. "/" .. skinJson["skin"]["4k"]["right note hold"]:gsub('"', ""))
    note4END = love.image.newImageData(skinFolder .. "/" .. skinJson["skin"]["4k"]["right note hold end"]:gsub('"', ""))

    receptors[1] = {love.graphics.newImage(recepterUNPRESSED1), love.graphics.newImage(recepterPRESSED1), 0}
    receptors[2] = {love.graphics.newImage(recepterUNPRESSED2), love.graphics.newImage(recepterPRESSED2), 0}
    receptors[3] = {love.graphics.newImage(recepterUNPRESSED3), love.graphics.newImage(recepterPRESSED3), 0}
    receptors[4] = {love.graphics.newImage(recepterUNPRESSED4), love.graphics.newImage(recepterPRESSED4), 0}

    noteImgs = {
        {love.graphics.newImage(note1NORMAL), love.graphics.newImage(note1HOLD), love.graphics.newImage(note1END)},
        {love.graphics.newImage(note2NORMAL), love.graphics.newImage(note2HOLD), love.graphics.newImage(note2END)},
        {love.graphics.newImage(note3NORMAL), love.graphics.newImage(note3HOLD), love.graphics.newImage(note3END)},
        {love.graphics.newImage(note4NORMAL), love.graphics.newImage(note4HOLD), love.graphics.newImage(note4END)}
    }

    judgementImages = { -- images for the judgement text
        ["Miss"] = love.graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["judgements"]["MISS"]:gsub('"', "")),
        ["Good"] = love.graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["judgements"]["GOOD"]:gsub('"', "")),
        ["Great"] = love.graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["judgements"]["GREAT"]:gsub('"', "")),
        ["Perfect"] = love.graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["judgements"]["PERFECT"]:gsub('"', "")),
        ["Marvellous"] = love.graphics.newImage(skinFolder .. "/" .. skinJson["skin"]["4k"]["judgements"]["MARVELLOUS"]:gsub('"', "")),
    }
    -- combo images
    combo0 = love.image.newImageData(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO0"]:gsub('"', ""))
    combo1 = love.image.newImageData(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO1"]:gsub('"', ""))
    combo2 = love.image.newImageData(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO2"]:gsub('"', ""))
    combo3 = love.image.newImageData(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO3"]:gsub('"', ""))
    combo4 = love.image.newImageData(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO4"]:gsub('"', ""))
    combo5 = love.image.newImageData(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO5"]:gsub('"', ""))
    combo6 = love.image.newImageData(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO6"]:gsub('"', ""))
    combo7 = love.image.newImageData(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO7"]:gsub('"', ""))
    combo8 = love.image.newImageData(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO8"]:gsub('"', ""))
    combo9 = love.image.newImageData(skinFolder .. "/" .. skinJson["skin"]["4k"]["combo"]["COMBO9"]:gsub('"', ""))

    comboImages = { -- need to optimize this too lmfaoooo
        [1] = {
            [0] = love.graphics.newImage(combo0),
            [1] = love.graphics.newImage(combo1),
            [2] = love.graphics.newImage(combo2),
            [3] = love.graphics.newImage(combo3),
            [4] = love.graphics.newImage(combo4),
            [5] = love.graphics.newImage(combo5),
            [6] = love.graphics.newImage(combo6),
            [7] = love.graphics.newImage(combo7),
            [8] = love.graphics.newImage(combo8),
            [9] = love.graphics.newImage(combo9)
        },
        [2] = {
            [0] = love.graphics.newImage(combo0),
            [1] = love.graphics.newImage(combo1),
            [2] = love.graphics.newImage(combo2),
            [3] = love.graphics.newImage(combo3),
            [4] = love.graphics.newImage(combo4),
            [5] = love.graphics.newImage(combo5),
            [6] = love.graphics.newImage(combo6),
            [7] = love.graphics.newImage(combo7),
            [8] = love.graphics.newImage(combo8),
            [9] = love.graphics.newImage(combo9)
        },
        [3] = {
            [0] = love.graphics.newImage(combo0),
            [1] = love.graphics.newImage(combo1),
            [2] = love.graphics.newImage(combo2),
            [3] = love.graphics.newImage(combo3),
            [4] = love.graphics.newImage(combo4),
            [5] = love.graphics.newImage(combo5),
            [6] = love.graphics.newImage(combo6),
            [7] = love.graphics.newImage(combo7),
            [8] = love.graphics.newImage(combo8),
            [9] = love.graphics.newImage(combo9)
        },
        [4] = {
            [0] = love.graphics.newImage(combo0),
            [1] = love.graphics.newImage(combo1),
            [2] = love.graphics.newImage(combo2),
            [3] = love.graphics.newImage(combo3),
            [4] = love.graphics.newImage(combo4),
            [5] = love.graphics.newImage(combo5),
            [6] = love.graphics.newImage(combo6),
            [7] = love.graphics.newImage(combo7),
            [8] = love.graphics.newImage(combo8),
            [9] = love.graphics.newImage(combo9)
        }
    }

    love.graphics.setDefaultFilter("linear", "linear")
    choosingSkin = false
    choosingSong = true

    musicPos = 0
    --quaverLoader.load("chart.qua")
    state.switch(songSelect)
    dt = 0

    now = os.time()
end

return {
    enter = function(self)
        choosingSkin = true
        choosingSong = false
        musicTimeDo = false
        curSkinSelected = 1
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