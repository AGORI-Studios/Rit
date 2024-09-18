---@class SoundCache : BaseCache
local SoundCache = BaseCache:extend("SoundCache")
SoundCache.threaded = {}

local channel = love.thread.getChannel("thread.sound")
local outChannel = love.thread.getChannel("thread.sound.out")

---@param path string
---@param soundType? string
---@return love.Source
function SoundCache:get(path, soundType, threaded)
    if threaded then
        table.insert(self.threaded, {
            channel = outChannel,
            path = path
        })
        channel:push(path)
    end
    if not self._cache[path] then
        self._cache[path] = love.audio.newSource(path, soundType or "stream")
    end

    return self._cache[path]
end

function SoundCache:update()
    for i = #self.threaded, 1, -1 do
        local data = self.threaded[i]
        local response = data.channel:pop()
        if response then
            self._cache[response.path] = love.audio.newSource(response.source)
            table.remove(self.threaded, i)
        end
    end
end

return SoundCache