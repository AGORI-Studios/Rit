---@class FontCache : BaseCache
local FontCache = BaseCache:extend("FontCache")

---@param path string
---@param size? number
---@return love.Font
function FontCache:get(path, size)
    if not self._cache[path] then
        self._cache[path] = love.graphics.newFont(path, size or 12)
    end

    return self._cache[path]
end

return FontCache