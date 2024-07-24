local skin = {}

skin.name = Settings.options["Skin"].name or "Circle Default"
skin.path = Settings.options["Skin"].path or "defaultSkins/Circle Default"
skin.scale = Settings.options["Skin"].scale or 1
skin.flippedEnd = Settings.options["Skin"].flippedEnd or false
skin.skins = {}

function skin:format(path)
    local ogPath = path
    local path = "defaultSkins/" .. self.path .. "/" .. path
    --print("Checking path: " .. path)
    if love.filesystem.getInfo(path) then
        return path
    else
        local path = "Skins/" .. self.path .. "/" .. ogPath
        --[[ return path:gsub(skin.name, "skinThrowbacks") ]]
        --print("Checking path: " .. path)
        if love.filesystem.getInfo(path) then
            return path
        else
            local path = "defaultSkins/skinThrowbacks/" .. ogPath
            return path
        end
    end
end

function skin:loadSkins(baseDir)
    local skins = love.filesystem.getDirectoryItems(baseDir)

    for _, skinFolder in ipairs(skins) do
        local skinPath = baseDir .. "/" .. skinFolder
        if love.filesystem.getInfo(skinPath .. "/skin.ini") then
            local skinData = ini.parse(skinPath .. "/skin.ini")
            local name = skinData.Metadata.name
            local creator = skinData.Metadata.creator
            local scale = skinData.Misceallaneous.noteSize or 1
            local skin = {
                name = name or skinFolder,
                creator = creator or "Unknown",
                path = skinFolder,
                scale = scale or 1
            }

            table.insert(skinList, skin)
        end
    end
end

function skin:getSkinCount()
    return #skinList
end

return skin