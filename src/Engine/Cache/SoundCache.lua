local SoundCache = BaseCache:extend("SoundCache")

function SoundCache:get(path, soundType)
    if not self._cache[path] then
        self._cache[path] = love.audio.newSource(path, soundType or "stream")
    end

    return self._cache[path]
end

return SoundCache