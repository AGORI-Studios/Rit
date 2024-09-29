---@class SongManager
local SongManager = {}
SongManager.songCache = {}

function SongManager:getSongList()
    local sortedList = {}
    for _, v in pairs(self.songCache) do
        table.insert(sortedList, v)
    end
    
    table.sort(sortedList, function(a, b)
        return a.index < b.index
    end)

    return sortedList
end

function SongManager:loadSongList()
    self.songCache = {}

    local index = 1
    local diffIndexes = {}
    local songList = love.filesystem.getDirectoryItems("CacheData/Beatmaps/")

    for _, v in ipairs(songList) do
        local songData = self:loadCache(v, "CacheData/Beatmaps/" .. v, ".scache")
        if not self.songCache[songData.mapset_id] then
            diffIndexes[songData.mapset_id] = 1
            self.songCache[songData.mapset_id] = {
                title = songData.title or "Unknown",
                artist = songData.artist or "Unknown",
                difficulties = {},
                index = index
            }

            index = index + 1
        end
        songData.index = diffIndexes[songData.mapset_id]
        self.songCache[songData.mapset_id].difficulties[songData.map_id] = songData
        diffIndexes[songData.mapset_id] = diffIndexes[songData.mapset_id] + 1
    end

    return self.songCache
end

function SongManager:loadCache(filename, ogPath, fileExt)
    if love.filesystem.getInfo("CacheData/Beatmaps/" .. filename) then
        local data = FileHandler:readEncryptedFile("CacheData/Beatmaps/" .. filename)
        local songData = {}
        for line in data:gmatch("[^\n]+") do
            local key, value = line:match("([^:]+):(.+)")
            if not key or not value then
                goto continue
            end
            songData[key] = value

            ::continue::
        end
        return songData
    end

    print("Failed to load cache for " .. filename)
end

return SongManager
