local SongCacheFormat = {
    title = "",
    artist = "",
    source = "",
    tags = "",
    creator = "",
    diff_name = "",
    description = "",
    path = "",
    audio_path = "",
    bg_path = "",
    preview_time = 0,
    mapset_id = 0,
    map_id = 0,
    mode = 4,
    game_mode = "mania",
    map_type = "Quaver",
    hitobj_count = 0,
    ln_count = 0,
    length = 0,
    metaType = 2
}

local SongCache = Class:extend("SongCache")
SongCache.songs = {}

function SongCache:createCache(songData, filename, fileExt)
    local strOut = ""
    for key, _ in pairs(SongCacheFormat) do
        strOut = strOut .. key .. ":" .. songData[key] .. "\n"
    end

    FileHandler:writeEncryptedFile("CacheData/Beatmaps/" .. filename .. ".scache", strOut)

    return SongCacheFormat
end
 
function SongCache:loadCache(filename, ogPath, fileExt)
    if love.filesystem.getInfo("CacheData/Beatmaps/" .. filename .. ".scache") then
        local data = FileHandler:readEncryptedFile("CacheData/Beatmaps/" .. filename .. ".scache")
        local songData = {}
        for line in data:gmatch("[^\n]+") do
            local key, value = line:match("([^:]+):(.+)")
            if not key or not value then
                goto continue
            end
            songData[key] = value

            ::continue::
        end
        if songData["metaType"] == 1 then
            -- delete the cache file and reload the song
            love.filesystem.remove("CacheData/Beatmaps/" .. filename .. ".scache")
            return self:loadCache(filename, ogPath, fileExt)
        end
        return songData
    else
        if fileExt == ".qua" then
            local data = love.filesystem.read(ogPath)
            local songData = Parsers.Quaver:cache(data, filename, ogPath)
            songData.metaType = 2
            print("Caching " .. filename)
            return songData
        end
    end
end

function SongCache:loadSongsPath(path)
    local files = love.filesystem.getDirectoryItems(path)
    for _, file in ipairs(files) do
        local fileType = love.filesystem.getInfo(path .. "/" .. file).type
        if fileType == "directory" then
            for _, song in ipairs(love.filesystem.getDirectoryItems(path .. "/" .. file)) do
                if song:endsWith(".qua") then
                    local filename = song:gsub(".qua$", "")
                    local fullPath = path .. "/" .. file .. "/" .. song
                    local fileExt = ".qua"
                    
                    self:loadCache(filename, fullPath, fileExt)
                end
            end
        elseif fileType == "file" then
            if file:endsWith(".qp") then
                love.filesystem.mount(path .. "/" .. file, "song")
                
                for _, song in ipairs(love.filesystem.getDirectoryItems("song")) do
                    if song:endsWith(".qua") then
                        local filename = file:gsub(".qp$", "")
                        local fullPath = "song/" .. song
                        local fileExt = ".qua"
                        
                        self:loadCache(filename, fullPath, fileExt)
                    end
                end

                love.filesystem.unmount("song")
            end
        end
    end
end

return SongCache