
local skin = {}

skin.name = Settings.options["General"].skin
skin.skins = {}

function skin:format(path)
    local ogPath = path
    local path = "defaultSkins/" .. self.name .. "/" .. path
    print("Checking path: " .. path)
    if love.filesystem.getInfo(path) then
        return path
    else
        local path = "Skins/" .. self.name .. "/" .. ogPath
        --[[ return path:gsub(skin.name, "skinThrowbacks") ]]
        print("Checking path: " .. path)
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

    for i, skinFolder in ipairs(skins) do
        local skinPath = baseDir .. "/" .. skinFolder
        if love.filesystem.getInfo(skinPath .. "/skin.ini") then
            local skinData = ini.parse(skinPath .. "/skin.ini")
            local name = skinData.Metadata.name
            local creator = skinData.Metadata.creator

            local skin = {
                name = name or skinFolder,
                creator = creator or "Unknown",
                path = skinPath
            }

            table.insert(skinList, skin)
        end
    end
end

function skin:getSkinCount()
    return #skinList
end

return skin