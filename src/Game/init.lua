local path = ... .. "."

require(path .. "States")

local foldersOutdated = false
local foldersLayoutVersion = "1"
local function setupFolders()
    if not love.filesystem.getInfo("layoutversion") then
        foldersOutdated = true
        love.filesystem.write("layoutversion", foldersLayoutVersion)
    else
        local layoutVersion = love.filesystem.read("layoutversion")
        if layoutVersion ~= foldersLayoutVersion then
            foldersOutdated = true
            love.filesystem.write("layoutversion", foldersLayoutVersion)
        end
    end

    if foldersOutdated then
        love.filesystem.createDirectory("CacheData")
        love.filesystem.createDirectory("Data")
        love.filesystem.createDirectory("Beatmaps")
    end
end

function Game:initialize()
    setupFolders()
    
end

Game:initialize()
Game:SwitchState(States.Testing.TestState)
