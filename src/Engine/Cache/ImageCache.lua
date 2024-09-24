---@class ImageCache : BaseCache
local ImageCache = BaseCache:extend("ImageCache")
ImageCache.threaded = {}

local channel = love.thread.getChannel("thread.image")
local outChannel = love.thread.getChannel("thread.image.out")

---@param path string
---@return love.Image
function ImageCache:get(path, threaded)
    if threaded then
        table.insert(self.threaded, {
            channel = outChannel,
            path = path
        })
        channel:push(path)
    end
    if not self._cache[path] then
        self._cache[path] = love.graphics.newImage(path)
    end

    return self._cache[path]
end

function ImageCache:update()
    for i = #self.threaded, 1, -1 do
        local data = self.threaded[i]
        local response = data.channel:pop()
        if response then
            self._cache[response.path] = love.graphics.newImage(response.image)
            table.remove(self.threaded, i)
        end
    end
end
    

return ImageCache
