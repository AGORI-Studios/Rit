---@class FontCache : BaseCache
local FontCache = BaseCache:extend("FontCache")
FontCache.threaded = {}

local channel = love.thread.getChannel("thread.font")
local outChannel = love.thread.getChannel("thread.font.out")

---@param path string
---@param size? number
---@return love.Font
function FontCache:get(path, size, threaded)
    if threaded then
        table.insert(self.threaded, {
            channel = outChannel,
            path = path,
            size = size
        })
        channel:push({
            path = path,
            size = size
        })
    end
    if not self._cache[path .. (size or "")] then
        self._cache[path .. (size or "")] = love.graphics.newFont(path, size)
    end

    return self._cache[path .. (size or "")]
end

function FontCache:update()
    for i = #self.threaded, 1, -1 do
        local data = self.threaded[i]
        local response = data.channel:pop()
        if response then
            self._cache[response.path .. response.size] = love.graphics.newFont(response.font, response.size)
            table.remove(self.threaded, i)
        end
    end
end

return FontCache
