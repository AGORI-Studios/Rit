local function chooseSkin()
    -- get all folders in skin/
    if not love.filesystem.getInfo("skins") then
        love.filesystem.createDirectory("skins")
    end
    skins = {}
    for i, v in ipairs(love.filesystem.getDirectoryItems("defaultskins")) do
        if love.filesystem.getInfo("defaultskins/" .. v).type == "directory" then
            local folderPath = "defaultskins/" .. v
            -- get the skin.ini
            local skinIni = ini.load(folderPath .. "/skin.ini")
            -- get the skin name
            local skinName = skinIni["skin"]["name"]
            -- add it to the table
            curSkin = {
                name = skinName,
                folder = folderPath,
                ini = skinIni
            }
            table.insert(skins, curSkin)
        end
    end
    for i, v in ipairs(love.filesystem.getDirectoryItems("skins")) do
        if love.filesystem.getInfo("skins/" .. v).type == "directory" then
            local folderPath = "skins/" .. v
            -- get the skin.ini
            local skinIni = ini.load(folderPath .. "/skin.ini")
            -- get the skin name
            local skinName = skinIni["skin"]["name"]
            -- add it to the table
            curSkin = {
                name = skinName,
                folder = folderPath,
                ini = skinIni
            }
            table.insert(skins, curSkin)
        end
    end
end

local function selectSkin(skin) -- TODO: optimize skin loading
    skin = skin or 1
    skin = skins[skin]
    skinIni = skin.ini
    skinFolder = skin.folder
    skinName = skin.name
    notesize = skinIni["skin"]["notesize"]
    notesize = tonumber(notesize)
    antiAliasing = skinIni["skin"]["antiAliasing"]

    if antiAliasing then 
        love.graphics.setDefaultFilter("nearest", "nearest")
    else
        love.graphics.setDefaultFilter("linear", "linear")
    end
    
    hitsound = love.audio.newSource(skinFolder .. "/" .. skinIni["skin"]["hitsound"]:gsub('"', ""), "static")
    hitsound:setVolume(tonumber(skinIni["skin"]["hitsoundVolume"]))
    hitsoundCache = { -- allows for multiple hitsounds to be played at once
        hitsound:clone()
    }

    recepterUNPRESSED1 = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["receptor1UNPRESSED"]:gsub('"', ""))
    recepterPRESSED1 = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["receptor1PRESSED"]:gsub('"', ""))

    recepterUNPRESSED2 = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["receptor2UNPRESSED"]:gsub('"', ""))
    recepterPRESSED2 = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["receptor2PRESSED"]:gsub('"', ""))

    recepterUNPRESSED3 = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["receptor3UNPRESSED"]:gsub('"', ""))
    recepterPRESSED3 = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["receptor3PRESSED"]:gsub('"', ""))

    recepterUNPRESSED4 = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["receptor4UNPRESSED"]:gsub('"', ""))
    recepterPRESSED4 = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["receptor4PRESSED"]:gsub('"', ""))

    note1NORMAL = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["note1NORMAL"]:gsub('"', ""))
    note1HOLD = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["note1HOLD"]:gsub('"', ""))
    note1END = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["note1END"]:gsub('"', ""))
    
    note2NORMAL = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["note2NORMAL"]:gsub('"', ""))
    note2HOLD = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["note2HOLD"]:gsub('"', ""))
    note2END = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["note2END"]:gsub('"', ""))

    note3NORMAL = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["note3NORMAL"]:gsub('"', ""))
    note3HOLD = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["note3HOLD"]:gsub('"', ""))
    note3END = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["note3END"]:gsub('"', ""))

    note4NORMAL = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["note4NORMAL"]:gsub('"', ""))
    note4HOLD = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["note4HOLD"]:gsub('"', ""))
    note4END = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["note4END"]:gsub('"', ""))

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
        ["Miss"] = love.graphics.newImage(skinFolder .. "/" .. skinIni["skin"]["MISS"]:gsub('"', "")),
        ["Good"] = love.graphics.newImage(skinFolder .. "/" .. skinIni["skin"]["GOOD"]:gsub('"', "")),
        ["Great"] = love.graphics.newImage(skinFolder .. "/" .. skinIni["skin"]["GREAT"]:gsub('"', "")),
        ["Perfect"] = love.graphics.newImage(skinFolder .. "/" .. skinIni["skin"]["PERFECT"]:gsub('"', "")),
        ["Marvellous"] = love.graphics.newImage(skinFolder .. "/" .. skinIni["skin"]["MARVELLOUS"]:gsub('"', "")),
    }
    -- combo images
    combo0 = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["COMBO0"]:gsub('"', ""))
    combo1 = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["COMBO1"]:gsub('"', ""))
    combo2 = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["COMBO2"]:gsub('"', ""))
    combo3 = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["COMBO3"]:gsub('"', ""))
    combo4 = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["COMBO4"]:gsub('"', ""))
    combo5 = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["COMBO5"]:gsub('"', ""))
    combo6 = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["COMBO6"]:gsub('"', ""))
    combo7 = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["COMBO7"]:gsub('"', ""))
    combo8 = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["COMBO8"]:gsub('"', ""))
    combo9 = love.image.newImageData(skinFolder .. "/" .. skinIni["skin"]["COMBO9"]:gsub('"', ""))

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