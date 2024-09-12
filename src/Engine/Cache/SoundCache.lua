---@class SoundCache : BaseCache
local SoundCache = BaseCache:extend("SoundCache")

---@param path string
---@param soundType? string
---@return love.Source
function SoundCache:get(path, soundType)
    if not self._cache[path] then
        self._cache[path] = love.audio.newSource(path, soundType or "stream")
    end

    return self._cache[path]
end

return SoundCache