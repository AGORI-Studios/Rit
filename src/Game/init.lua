local path = ... .. "."

require(path .. "External")
require(path .. "States")
require(path .. "Managers")
require(path .. "Objects")
require(path .. "Cache")
Parsers = require(path .. "Parsing")
SongCache:loadSongsPath("Assets/IncludedSongs")

local function setupFolders()
    love.filesystem.createDirectory("CacheData")
    love.filesystem.createDirectory("CacheData/Beatmaps")
    love.filesystem.createDirectory("Data")
    love.filesystem.createDirectory("Beatmaps")

        love.filesystem.write("readme.txt", [[
Folder structure:
- CacheData: Contains cached data for the game. Deleting this folder will cause the game to regenerate the cache, causing longer load times.
- Data: Contains data for the game. This folder is used for storing settings and other data.
- Beatmaps: Contains parsed beatmaps for the game. This folder for storing your beatmaps.
]])
end

function Game:initialize()
    setupFolders()
    
end

Game:initialize()
Game:SwitchState(States.Testing.TestState)
