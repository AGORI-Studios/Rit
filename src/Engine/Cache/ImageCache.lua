local ImageCache = BaseCache:extend("ImageCache")

function ImageCache:get(path)
    if not self._cache[path] then
        self._cache[path] = love.graphics.newImage(path)
    end

    return self._cache[path]
end

return ImageCache