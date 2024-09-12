local FontCache = BaseCache:extend("FontCache")

function FontCache:get(path, size)
    if not self._cache[path] then
        self._cache[path] = love.graphics.newFont(path, size or 12)
    end

    return self._cache[path]
end

return FontCache